// All-in-one script: Insert records + upload PDFs + link them
// Run this in Developer Console (Execute Anonymous)
//
// PREREQUISITE: Upload the 3 PDFs manually first via:
//   Setup > Files > Upload Files
//   Use exact names: merchant-application-01, merchant-application-02, merchant-application-03
//
// This script then creates the parent records and links the files.

// 1. Insert Merchant Application records
List<Merchant_Application__c> apps = new List<Merchant_Application__c>();

apps.add(new Merchant_Application__c(
    Name = 'Sakura Ramen House',
    Applicant_Email__c = 'owner@sakuraramen.com',
    Status__c = 'Submitted',
    Submission_Date__c = Date.newInstance(2026, 4, 28)
));

apps.add(new Merchant_Application__c(
    Name = 'Big Tony\'s Pizza',
    Applicant_Email__c = 'info@bigtonys.com',
    Status__c = 'Submitted',
    Submission_Date__c = Date.newInstance(2026, 5, 2)
));

apps.add(new Merchant_Application__c(
    Name = 'Green Bowl Salads',
    Applicant_Email__c = 'hello@greenbowlsf.com',
    Status__c = 'Submitted',
    Submission_Date__c = Date.newInstance(2026, 5, 10)
));

insert apps;
System.debug('✓ Inserted ' + apps.size() + ' Merchant Application records');

// 2. Build lookup maps
Map<String, Id> appsByName = new Map<String, Id>();
for (Merchant_Application__c app : apps) {
    appsByName.put(app.Name, app.Id);
}

// 3. Find uploaded PDFs
Map<String, Id> filesByTitle = new Map<String, Id>();
for (ContentVersion cv : [
    SELECT Id, ContentDocumentId, Title
    FROM ContentVersion
    WHERE Title IN (
        'merchant-application-01',
        'merchant-application-02',
        'merchant-application-03'
    )
    AND IsLatest = true
]) {
    filesByTitle.put(cv.Title, cv.ContentDocumentId);
}

System.debug('Found ' + filesByTitle.size() + ' uploaded PDFs');

// 4. Link PDFs to records
Map<String, String> pdfToApp = new Map<String, String>{
    'merchant-application-01' => 'Sakura Ramen House',
    'merchant-application-02' => 'Big Tony\'s Pizza',
    'merchant-application-03' => 'Green Bowl Salads'
};

List<ContentDocumentLink> links = new List<ContentDocumentLink>();
for (String pdfTitle : pdfToApp.keySet()) {
    String appName = pdfToApp.get(pdfTitle);
    Id contentDocId = filesByTitle.get(pdfTitle);
    Id appId = appsByName.get(appName);

    if (contentDocId != null && appId != null) {
        links.add(new ContentDocumentLink(
            ContentDocumentId = contentDocId,
            LinkedEntityId = appId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        ));
        System.debug('  Linking ' + pdfTitle + ' → ' + appName);
    } else {
        System.debug('  ⚠ Missing: PDF=' + (contentDocId != null) + ', App=' + (appId != null) + ' for ' + pdfTitle);
    }
}

if (!links.isEmpty()) {
    insert links;
    System.debug('✓ Created ' + links.size() + ' file links');
} else {
    System.debug('⚠ No PDFs found. Upload them via Setup > Files first with exact titles.');
}
