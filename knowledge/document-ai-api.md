# Document AI — Extract Data API

## Endpoint
```
POST {instance_url}/services/data/v65.0/ssot/document-processing/actions/extract-data
```

**Note:** Use `v65.0` — v66.0 may return 404 on some instances. Alternate path (without `/actions/`): `ssot/document-processing/extract-data`

## Supported Models
- `VertexAIGemini25Flash` (Gemini 2.5 Flash)
- `OpenAIGPT4Omni` (GPT-4o)

**Important:** The model name in the UI ("Gemini 2.5 Flash") maps to `VertexAIGemini25Flash` in the API. Using `gemini-fast` returns an error.

## Request Payload
```json
{
  "mlModel": "VertexAIGemini25Flash",
  "schemaConfig": "<JSON schema as string>",
  "files": [
    {
      "mimeType": "application/pdf",
      "data": "<base64-encoded-file>"
    }
  ]
}
```

## Schema Format (JSON Schema draft-07)
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "description": "Global extraction instructions go here (schema-level prompt)",
  "properties": {
    "fieldName": {
      "type": "string|number|boolean",
      "description": "Description helps the LLM find the right value"
    }
  }
}
```

## Optional Query Parameters
- `?extractDataWithConfidenceScore=true` — returns 0-1 confidence per field
- `?startPage=1&endPage=5` — extract from specific PDF pages only

## Response Format
```json
{
  "data": [
    {
      "data": "{\"fieldName\": {\"type\": \"string\", \"value\": \"extracted value\"}, ...}"
    }
  ]
}
```

The `data[0].data` field is a JSON string with HTML entities (`&quot;`, `&#92;`) that needs unescaping.

## Authentication
- Standard OAuth 2.0 Bearer token
- Or `UserInfo.getSessionId()` from Apex

## Key Learnings
1. **This is an on-demand API** — no need to wait for Data Streams to trigger
2. The UI Document AI config (schema) you created is for the automated pipeline
3. The API lets you extract from any PDF/image immediately without the pipeline
4. The schema you define in the UI can be reused as the `schemaConfig` in API calls
5. Supported file types: PDF, PNG, JPG, JPEG, TIFF, BMP

## How to See Data in the UI (DLO)
The Document AI UI config + DLO pipeline is **separate** from the API:
- **UI/DLO path:** Files flow through ContentVersion data stream → Document AI processes them → writes to output DLO. This requires the data stream to detect new files.
- **API path:** Call the endpoint directly, get results immediately. No DLO involved unless you write the results yourself.

For the demo, the **API path is the best way to show instant extraction**. The DLO path is for production automation at scale.

## Generate Schema API (Auto-Extraction)

You do NOT need to manually write schemas. The `generate-schema` endpoint reads your document and produces a schema automatically:

```
POST {instance_url}/services/data/v65.0/ssot/document-processing/actions/generate-schema
```

### Request
```json
{
  "mlModel": "VertexAIGemini25Flash",
  "files": [
    {
      "mimeType": "application/pdf",
      "data": "<base64-encoded-file>"
    }
  ]
}
```

### Response
```json
{
  "error": null,
  "metadata": {
    "filePages": 2,
    "fileSize": 121373,
    "fileType": "application/pdf"
  },
  "schema": "<JSON schema string with HTML entities>"
}
```

The `schema` field contains the auto-generated JSON Schema (needs `&quot;` → `"` unescaping). Feed this directly into the `extract-data` endpoint's `schemaConfig` parameter.

### Demo Flow (fully automated)
1. Call `generate-schema` with the PDF → get back a schema
2. Call `extract-data` with the same PDF + the returned schema → get extracted values
3. Zero manual schema authoring needed

---

## Scripts Created
- `scripts/document-ai/extract-merchant-application.sh` — Shell script using curl
- `scripts/apex/document-ai-extract.apex` — Apex version for Developer Console

## Reference
- Testbed repo: https://github.com/ananth-anto/sf-datacloud-idp-testbed
- API docs: https://developer.salesforce.com/docs/data/connectapi/references/spec?meta=extractDocumentAIConfigData
