public class DocumentAIService {

    private static final String API_VERSION = 'v65.0';
    private static final String BASE_PATH = '/services/data/' + API_VERSION + '/ssot/document-processing';
    private static final String DEFAULT_MODEL = 'VertexAIGemini25Flash';

    public class DocumentAIResult {
        @AuraEnabled public String schema { get; set; }
        @AuraEnabled public Map<String, Object> extractedData { get; set; }
        @AuraEnabled public Map<String, Object> metadata { get; set; }
        @AuraEnabled public String configurationId { get; set; }
        @AuraEnabled public String error { get; set; }
    }

    /**
     * Full end-to-end flow:
     * 1. Generate schema from a document
     * 2. Extract data using that schema
     * Returns both the schema and extracted data
     */
    @AuraEnabled
    public static DocumentAIResult processDocument(Id contentVersionId) {
        DocumentAIResult result = new DocumentAIResult();

        ContentVersion cv = [
            SELECT VersionData, FileType, Title, ContentSize
            FROM ContentVersion
            WHERE Id = :contentVersionId
            LIMIT 1
        ];

        String base64Data = EncodingUtil.base64Encode(cv.VersionData);
        String mimeType = getMimeType(cv.FileType);

        // Step 1: Generate schema
        String generatedSchema = generateSchema(base64Data, mimeType);
        if (generatedSchema == null) {
            result.error = 'Failed to generate schema from document';
            return result;
        }
        result.schema = generatedSchema;

        // Step 2: Extract data using generated schema
        Map<String, Object> extracted = extractData(base64Data, mimeType, generatedSchema);
        result.extractedData = extracted;

        return result;
    }

    /**
     * Generate a JSON schema from a document.
     * Calls: POST /ssot/document-processing/actions/generate-schema
     */
    @AuraEnabled
    public static String generateSchema(String base64Data, String mimeType) {
        Map<String, Object> payload = new Map<String, Object>{
            'mlModel' => DEFAULT_MODEL,
            'files' => new List<Map<String, String>>{
                new Map<String, String>{
                    'mimeType' => mimeType,
                    'data' => base64Data
                }
            }
        };

        HttpResponse res = callApi('POST', BASE_PATH + '/actions/generate-schema', JSON.serialize(payload));

        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            String schemaStr = (String) response.get('schema');
            return unescapeHtml(schemaStr);
        }
        System.debug('generate-schema error: ' + res.getStatusCode() + ' ' + res.getBody());
        return null;
    }

    /**
     * Generate schema directly from a ContentVersion record.
     */
    @AuraEnabled
    public static String generateSchemaFromFile(Id contentVersionId) {
        ContentVersion cv = [
            SELECT VersionData, FileType FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1
        ];
        String base64Data = EncodingUtil.base64Encode(cv.VersionData);
        return generateSchema(base64Data, getMimeType(cv.FileType));
    }

    /**
     * Extract structured data from a document using a schema.
     * Calls: POST /ssot/document-processing/actions/extract-data
     */
    @AuraEnabled
    public static Map<String, Object> extractData(String base64Data, String mimeType, String schemaConfig) {
        Map<String, Object> payload = new Map<String, Object>{
            'mlModel' => DEFAULT_MODEL,
            'schemaConfig' => schemaConfig,
            'files' => new List<Map<String, String>>{
                new Map<String, String>{
                    'mimeType' => mimeType,
                    'data' => base64Data
                }
            }
        };

        HttpResponse res = callApi('POST', BASE_PATH + '/actions/extract-data', JSON.serialize(payload));

        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> dataList = (List<Object>) response.get('data');
            if (dataList != null && !dataList.isEmpty()) {
                Map<String, Object> firstResult = (Map<String, Object>) dataList[0];
                String extractedJson = (String) firstResult.get('data');
                extractedJson = unescapeHtml(extractedJson);
                return (Map<String, Object>) JSON.deserializeUntyped(extractedJson);
            }
        }
        System.debug('extract-data error: ' + res.getStatusCode() + ' ' + res.getBody());
        return null;
    }

    /**
     * Extract data directly from a ContentVersion record using a schema.
     */
    @AuraEnabled
    public static Map<String, Object> extractDataFromFile(Id contentVersionId, String schemaConfig) {
        ContentVersion cv = [
            SELECT VersionData, FileType FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1
        ];
        String base64Data = EncodingUtil.base64Encode(cv.VersionData);
        return extractData(base64Data, getMimeType(cv.FileType), schemaConfig);
    }

    /**
     * Get all Document AI configurations.
     * Calls: GET /ssot/document-processing/configurations
     */
    @AuraEnabled
    public static String getConfigurations() {
        HttpResponse res = callApi('GET', BASE_PATH + '/configurations', null);
        return res.getBody();
    }

    /**
     * Get a specific Document AI configuration by ID or API name.
     * Calls: GET /ssot/document-processing/configurations/{idOrApiName}
     */
    @AuraEnabled
    public static String getConfiguration(String idOrApiName) {
        HttpResponse res = callApi('GET', BASE_PATH + '/configurations/' + idOrApiName, null);
        return res.getBody();
    }

    /**
     * Trigger Document AI processing run for a configuration.
     * Calls: POST /ssot/document-processing/configurations/{idOrApiName}/actions/run
     */
    @AuraEnabled
    public static String runConfiguration(String idOrApiName) {
        HttpResponse res = callApi('POST', BASE_PATH + '/configurations/' + idOrApiName + '/actions/run', null);
        return res.getBody();
    }

    /**
     * Get Document AI global configuration.
     * Calls: GET /ssot/document-processing/global-config
     */
    @AuraEnabled
    public static String getGlobalConfig() {
        HttpResponse res = callApi('GET', BASE_PATH + '/global-config', null);
        return res.getBody();
    }

    // --- Private helpers ---

    private static HttpResponse callApi(String method, String path, String body) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + path);
        req.setMethod(method);
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);
        if (body != null) {
            req.setBody(body);
        }
        return new Http().send(req);
    }

    private static String getMimeType(String fileType) {
        Map<String, String> mimeTypes = new Map<String, String>{
            'PDF' => 'application/pdf',
            'PNG' => 'image/png',
            'JPG' => 'image/jpeg',
            'JPEG' => 'image/jpeg',
            'TIFF' => 'image/tiff',
            'BMP' => 'image/bmp'
        };
        return mimeTypes.containsKey(fileType.toUpperCase())
            ? mimeTypes.get(fileType.toUpperCase())
            : 'application/octet-stream';
    }

    private static String unescapeHtml(String input) {
        if (input == null) return null;
        return input.replace('&quot;', '"')
                    .replace('&#92;', '\\')
                    .replace('&amp;', '&')
                    .replace('&lt;', '<')
                    .replace('&gt;', '>');
    }
}
