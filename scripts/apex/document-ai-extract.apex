// Document AI - Extract data from a Merchant Application PDF
// Run in Developer Console (Execute Anonymous)
// This calls the Document AI extract-data API using a named credential or direct token

// 1. Get a ContentVersion (the PDF file)
ContentVersion cv = [
    SELECT Id, VersionData, FileType, Title
    FROM ContentVersion
    WHERE Title LIKE 'merchant-application-01%'
    AND IsLatest = true
    LIMIT 1
];

System.debug('Processing: ' + cv.Title + ' (' + cv.FileType + ')');

// 2. Base64 encode the file
String base64Data = EncodingUtil.base64Encode(cv.VersionData);

// 3. Build the JSON schema for extraction
String schemaConfig = '{' +
    '"$schema": "http://json-schema.org/draft-07/schema#",' +
    '"type": "object",' +
    '"description": "Extract all fields from this Pronto merchant partnership application.",' +
    '"properties": {' +
        '"restaurantName": {"type": "string", "description": "Name of the restaurant"},' +
        '"legalBusinessName": {"type": "string", "description": "Legal business entity name"},' +
        '"businessAddress": {"type": "string", "description": "Full business address"},' +
        '"phoneNumber": {"type": "string", "description": "Business phone number"},' +
        '"email": {"type": "string", "description": "Business email address"},' +
        '"taxIdEIN": {"type": "string", "description": "Tax ID or EIN number"},' +
        '"businessLicenseNumber": {"type": "string", "description": "Business license number"},' +
        '"ownerName": {"type": "string", "description": "Name of the restaurant owner"},' +
        '"ownerEmail": {"type": "string", "description": "Owner email address"},' +
        '"cuisineType": {"type": "string", "description": "Type of cuisine served"},' +
        '"preferredTier": {"type": "string", "description": "Partnership tier: Basic, Plus, or Premium"},' +
        '"estimatedWeeklyOrders": {"type": "string", "description": "Estimated weekly orders"},' +
        '"healthInspectionScore": {"type": "number", "description": "Health inspection score out of 100"},' +
        '"offersCatering": {"type": "boolean", "description": "Whether catering is offered"},' +
        '"signatureDate": {"type": "string", "description": "Date application was signed"}' +
    '}' +
'}';

// 4. Build the request payload
Map<String, Object> payload = new Map<String, Object>{
    'mlModel' => 'VertexAIGemini25Flash',
    'schemaConfig' => schemaConfig,
    'files' => new List<Map<String, String>>{
        new Map<String, String>{
            'mimeType' => 'application/pdf',
            'data' => base64Data
        }
    }
};

// 5. Make the API call
HttpRequest req = new HttpRequest();
req.setEndpoint(URL.getOrgDomainUrl().toExternalForm() +
    '/services/data/v65.0/ssot/document-processing/actions/extract-data');
req.setMethod('POST');
req.setHeader('Content-Type', 'application/json');
req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
req.setBody(JSON.serialize(payload));
req.setTimeout(120000);

Http http = new Http();
HttpResponse res = http.send(req);

System.debug('Status: ' + res.getStatusCode());

if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
    Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
    List<Object> dataList = (List<Object>) response.get('data');
    if (dataList != null && !dataList.isEmpty()) {
        Map<String, Object> firstResult = (Map<String, Object>) dataList[0];
        String extractedJson = (String) firstResult.get('data');
        extractedJson = extractedJson.replace('&quot;', '"').replace('&#92;', '\\');
        System.debug('EXTRACTED DATA:');
        System.debug(extractedJson);
    }
} else {
    System.debug('ERROR ' + res.getStatusCode() + ': ' + res.getBody());
}
