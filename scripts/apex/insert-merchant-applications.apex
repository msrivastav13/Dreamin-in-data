// Step 1: Insert Merchant Application records
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
System.debug('Inserted ' + apps.size() + ' Merchant Application records');

for (Merchant_Application__c app : apps) {
    System.debug('  ' + app.Name + ' → ' + app.Id);
}
