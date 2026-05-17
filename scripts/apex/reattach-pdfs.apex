// Re-attach PDFs to Merchant Application records to trigger ContentVersion ingestion
// (ContentVersion only ingests files created/updated AFTER the data stream exists)

// 1. Find existing links
List<ContentDocumentLink> existingLinks = [
    SELECT Id, ContentDocumentId, LinkedEntityId
    FROM ContentDocumentLink
    WHERE LinkedEntityId IN (
        SELECT Id FROM Merchant_Application__c
        WHERE Name IN ('Sakura Ramen House', 'Big Tony\'s Pizza', 'Green Bowl Salads')
    )
];

System.debug('Found ' + existingLinks.size() + ' existing file links');

// Save the mapping before deleting
Map<Id, Id> docToEntity = new Map<Id, Id>();
for (ContentDocumentLink link : existingLinks) {
    docToEntity.put(link.ContentDocumentId, link.LinkedEntityId);
}

// 2. Delete existing links
if (!existingLinks.isEmpty()) {
    delete existingLinks;
    System.debug('Deleted ' + existingLinks.size() + ' links');
}

// 3. Re-create links (triggers fresh ingestion)
List<ContentDocumentLink> newLinks = new List<ContentDocumentLink>();
for (Id docId : docToEntity.keySet()) {
    newLinks.add(new ContentDocumentLink(
        ContentDocumentId = docId,
        LinkedEntityId = docToEntity.get(docId),
        ShareType = 'V',
        Visibility = 'AllUsers'
    ));
}

if (!newLinks.isEmpty()) {
    insert newLinks;
    System.debug('Re-created ' + newLinks.size() + ' file links — ingestion should trigger');
}
