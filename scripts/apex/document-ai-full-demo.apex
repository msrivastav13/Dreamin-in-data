// ===================================================
// Document AI Full Demo — End-to-End Automated Flow
// ===================================================
// This script demonstrates:
// 1. Auto-generating a schema from a PDF (no manual authoring)
// 2. Extracting structured data using that schema
// 3. Listing Document AI configurations
// 4. Triggering a Document AI run
//
// Run in Developer Console (Execute Anonymous)
// ===================================================

System.debug('=== DOCUMENT AI FULL DEMO ===');
System.debug('');

// --- Step 0: Get a merchant application PDF ---
ContentVersion cv = [
    SELECT Id, Title, FileType, ContentSize
    FROM ContentVersion
    WHERE Title LIKE 'merchant-application-sakura%'
    AND IsLatest = true
    LIMIT 1
];
System.debug('Document: ' + cv.Title + ' (' + cv.FileType + ', ' + cv.ContentSize + ' bytes)');
System.debug('');

// --- Step 1: Auto-generate schema from the document ---
System.debug('--- STEP 1: GENERATE SCHEMA ---');
String schema = DocumentAIService.generateSchemaFromFile(cv.Id);
System.debug('Generated schema:');
System.debug(schema);
System.debug('');

// --- Step 2: Extract data using the generated schema ---
System.debug('--- STEP 2: EXTRACT DATA ---');
Map<String, Object> extracted = DocumentAIService.extractDataFromFile(cv.Id, schema);
if (extracted != null) {
    System.debug('Extracted ' + extracted.size() + ' fields:');
    for (String fieldName : extracted.keySet()) {
        Map<String, Object> fieldData = (Map<String, Object>) extracted.get(fieldName);
        System.debug('  ' + fieldName + ': ' + fieldData.get('value'));
    }
} else {
    System.debug('ERROR: No data extracted');
}
System.debug('');

// --- Step 3: List Document AI configurations ---
System.debug('--- STEP 3: LIST CONFIGURATIONS ---');
String configs = DocumentAIService.getConfigurations();
System.debug('Configurations: ' + configs);
System.debug('');

// --- Step 4: Get specific configuration ---
System.debug('--- STEP 4: GET MERCHANT_APPLICATION CONFIG ---');
String config = DocumentAIService.getConfiguration('Merchant_Application');
System.debug('Config details: ' + config);
System.debug('');

// --- Step 5: Trigger run (processes files from UDMO) ---
System.debug('--- STEP 5: TRIGGER RUN ---');
String runResult = DocumentAIService.runConfiguration('Merchant_Application');
System.debug('Run result: ' + runResult);
System.debug('');

System.debug('=== DEMO COMPLETE ===');
