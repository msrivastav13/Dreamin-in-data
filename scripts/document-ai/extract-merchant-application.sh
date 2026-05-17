#!/bin/bash
# Document AI - Extract data from Merchant Application PDF
# Usage: ./extract-merchant-application.sh [path-to-pdf]
#
# This script calls the Data Cloud Document AI extract-data API directly.
# It sends a PDF + JSON schema and gets back structured extracted data.

set -e

# Default to first merchant application if no arg provided
PDF_FILE="${1:-../../document-ai-samples/merchant-application-01.pdf}"

# Get credentials from SF CLI
echo "Getting Salesforce credentials..."
INSTANCE_URL=$(sf org display --json 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['result']['instanceUrl'])")
ACCESS_TOKEN=$(sf org display --json 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['result']['accessToken'])")

echo "Instance URL: $INSTANCE_URL"
echo "PDF File: $PDF_FILE"

# Base64 encode the PDF
echo "Encoding PDF..."
BASE64_DATA=$(base64 -i "$PDF_FILE")

# JSON Schema for merchant application extraction
SCHEMA=$(cat <<'SCHEMA_EOF'
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "description": "Extract all fields from this Pronto food delivery merchant partnership application form.",
  "properties": {
    "restaurantName": {
      "type": "string",
      "description": "Name of the restaurant"
    },
    "legalBusinessName": {
      "type": "string",
      "description": "Legal business entity name"
    },
    "businessAddress": {
      "type": "string",
      "description": "Full business address"
    },
    "phoneNumber": {
      "type": "string",
      "description": "Business phone number"
    },
    "email": {
      "type": "string",
      "description": "Business email address"
    },
    "website": {
      "type": "string",
      "description": "Business website URL"
    },
    "taxIdEIN": {
      "type": "string",
      "description": "Tax ID or EIN number"
    },
    "businessLicenseNumber": {
      "type": "string",
      "description": "Business license number"
    },
    "ownerName": {
      "type": "string",
      "description": "Name of the restaurant owner"
    },
    "ownerPhone": {
      "type": "string",
      "description": "Owner phone number"
    },
    "ownerEmail": {
      "type": "string",
      "description": "Owner email address"
    },
    "cuisineType": {
      "type": "string",
      "description": "Type of cuisine served"
    },
    "averagePrepTime": {
      "type": "string",
      "description": "Average food preparation time"
    },
    "operatingHours": {
      "type": "string",
      "description": "Business operating hours"
    },
    "seatingCapacity": {
      "type": "number",
      "description": "Number of seats in the restaurant"
    },
    "numberOfLocations": {
      "type": "number",
      "description": "Number of restaurant locations"
    },
    "yearsInBusiness": {
      "type": "number",
      "description": "How many years the business has operated"
    },
    "preferredTier": {
      "type": "string",
      "description": "Partnership tier chosen: Basic, Plus, or Premium"
    },
    "estimatedWeeklyOrders": {
      "type": "string",
      "description": "Estimated number of weekly orders"
    },
    "deliveryRadiusPreference": {
      "type": "string",
      "description": "Preferred delivery radius in miles"
    },
    "offersCatering": {
      "type": "boolean",
      "description": "Whether the restaurant offers catering"
    },
    "healthInspectionScore": {
      "type": "number",
      "description": "Latest health inspection score out of 100"
    },
    "lastInspectionDate": {
      "type": "string",
      "description": "Date of last health inspection"
    },
    "foodHandlerCertifications": {
      "type": "string",
      "description": "Number of certified food handler staff"
    },
    "allergenMenuAvailable": {
      "type": "boolean",
      "description": "Whether an allergen menu is available"
    },
    "bankName": {
      "type": "string",
      "description": "Bank name for payouts"
    },
    "signatureDate": {
      "type": "string",
      "description": "Date the application was signed"
    }
  }
}
SCHEMA_EOF
)

# Escape the schema for JSON embedding
SCHEMA_ESCAPED=$(echo "$SCHEMA" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read().strip()))")

# Build the request payload
PAYLOAD=$(python3 -c "
import json, sys

schema = $SCHEMA_ESCAPED
base64_data = '''$BASE64_DATA'''

payload = {
    'mlModel': 'VertexAIGemini25Flash',
    'schemaConfig': schema,
    'files': [{
        'mimeType': 'application/pdf',
        'data': base64_data
    }]
}

print(json.dumps(payload))
")

# Try the API call (try both endpoint paths)
echo ""
echo "Calling Document AI extract-data API..."
echo "========================================="

API_VERSION="v65.0"
ENDPOINT="$INSTANCE_URL/services/data/$API_VERSION/ssot/document-processing/actions/extract-data"

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d "$PAYLOAD")

# Extract HTTP status code (last line)
HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | sed '$d')

# If 404, try alternate path
if [ "$HTTP_CODE" = "404" ]; then
  echo "Got 404, trying alternate path..."
  ENDPOINT="$INSTANCE_URL/services/data/$API_VERSION/ssot/document-processing/extract-data"
  RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$ENDPOINT" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -d "$PAYLOAD")
  HTTP_CODE=$(echo "$RESPONSE" | tail -1)
  BODY=$(echo "$RESPONSE" | sed '$d')
fi

# If still 404, try v66.0
if [ "$HTTP_CODE" = "404" ]; then
  echo "Got 404, trying v66.0..."
  API_VERSION="v66.0"
  ENDPOINT="$INSTANCE_URL/services/data/$API_VERSION/ssot/document-processing/actions/extract-data"
  RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$ENDPOINT" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -d "$PAYLOAD")
  HTTP_CODE=$(echo "$RESPONSE" | tail -1)
  BODY=$(echo "$RESPONSE" | sed '$d')
fi

echo ""
echo "HTTP Status: $HTTP_CODE"
echo "Endpoint used: $ENDPOINT"
echo ""

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
  echo "SUCCESS! Extracted data:"
  echo "========================================="
  echo "$BODY" | python3 -c "
import sys, json

response = json.load(sys.stdin)
if 'data' in response and response['data']:
    nested = response['data'][0].get('data', '')
    nested = nested.replace('&quot;', '\"').replace('&#92;', '\\\\')
    extracted = json.loads(nested)
    print(json.dumps(extracted, indent=2, ensure_ascii=False))
else:
    print(json.dumps(response, indent=2))
"
else
  echo "ERROR:"
  echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
fi
