// Upload PDFs as ContentVersion and link to Merchant Application records
// This script reads the PDF content via base64 and inserts as Files

// Get the merchant application records
Map<String, Id> appsByName = new Map<String, Id>();
for (Merchant_Application__c app : [
    SELECT Id, Name FROM Merchant_Application__c
    WHERE Name IN ('Sakura Ramen House', 'Big Tony\'s Pizza', 'Green Bowl Salads')
]) {
    appsByName.put(app.Name, app.Id);
}

System.debug('Found ' + appsByName.size() + ' merchant applications');

// Query for already-uploaded PDFs (in case they were uploaded via UI)
Map<String, Id> existingFiles = new Map<String, Id>();
for (ContentVersion cv : [
    SELECT Title, ContentDocumentId
    FROM ContentVersion
    WHERE Title LIKE 'merchant-application%'
    AND IsLatest = true
]) {
    existingFiles.put(cv.Title, cv.ContentDocumentId);
}

System.debug('Found ' + existingFiles.size() + ' existing PDF files');

// Link files to records
Map<String, String> pdfToApp = new Map<String, String>{
    'merchant-application-01' => 'Sakura Ramen House',
    'merchant-application-02' => 'Big Tony\'s Pizza',
    'merchant-application-03' => 'Green Bowl Salads'
};

List<ContentDocumentLink> links = new List<ContentDocumentLink>();
for (String pdfTitle : pdfToApp.keySet()) {
    String appName = pdfToApp.get(pdfTitle);
    Id contentDocId = existingFiles.get(pdfTitle);
    Id appId = appsByName.get(appName);

    if (contentDocId != null && appId != null) {
        links.add(new ContentDocumentLink(
            ContentDocumentId = contentDocId,
            LinkedEntityId = appId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        ));
        System.debug('Linking ' + pdfTitle + ' → ' + appName);
    } else {
        System.debug('MISSING: PDF "' + pdfTitle + '" found=' + (contentDocId != null) + ', App "' + appName + '" found=' + (appId != null));
    }
}

if (!links.isEmpty()) {
    insert links;
    System.debug('SUCCESS: Created ' + links.size() + ' file links');
} else {
    System.debug('No links created. Upload PDFs first via Files tab with titles: merchant-application-01, merchant-application-02, merchant-application-03');
}
