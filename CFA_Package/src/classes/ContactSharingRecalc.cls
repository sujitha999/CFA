global class ContactSharingRecalc implements Database.Batchable<sObject>{
    
    // The start method is called at the beginning of a sharing recalculation.
    // This method returns a SOQL query locator containing the records 
    // to be recalculated. 
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id FROM Contact WHERE LastModifiedDate = YESTERDAY]);  
    }
    
    // The executeBatch method is called for each chunk of records returned from start.  
    global void execute(Database.BatchableContext BC, SObject[] scope){
       // Create a map for the chunk of records passed into method.
       //Map<ID, OrderApi__Badge__c> badgeMap = new Map<ID, Job__c>((OrderApi__Badge__c[])scope);  
       
       Set<Id> cons = new Set<Id>();

       for(Contact con :  (Contact[])scope) {
          cons.add(con.Id);
       }

       OrderApi__Badge__c[] badges = [SELECT Id, BusinessGroup__c, OrderApi__Contact__c FROM OrderApi__Badge__c WHERE OrderApi__Contact__c in :cons];

        // Create a list of Job__Share objects to be inserted.
        ContactShare[] newJobShrs = new ContactShare[]{};
               
        // Locate all existing sharing records for the Job records in the batch.
        // Only records using an Apex sharing reason for this app should be returned. 
        ContactShare[] oldJobShrs = [SELECT Id FROM ContactShare WHERE ContactId IN :cons AND RowCause = 'Manual Sharing']; 
        
        Delete oldJobShrs;

        Badge_Trigger.rss.ShareWithGroup(badges);
 
    }
    
    // The finish method is called at the end of a sharing recalculation.
    global void finish(Database.BatchableContext BC){  
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {UserInfo.getUserEmail()}; 
        mail.setToAddresses(toAddresses); 
        mail.setSubject('Contact Society Membership Recalculation Completed.');
        mail.setPlainTextBody
                      ('The Contact Society Membership Recalculation Completed successfully');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}