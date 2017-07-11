global class BadgeSharingRecalc implements Database.Batchable<sObject>{


	// String to hold email address that emails will be sent to. 
    // Replace its value with a valid email address.
    //**static String emailAddress = 'admin@yourcompany.com';
    
    // The start method is called at the beginning of a sharing recalculation.
    // This method returns a SOQL query locator containing the records 
    // to be recalculated. 
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, BusinessGroup__c, OrderApi__Contact__c 
                                         FROM OrderApi__Badge__c]);  
    }
    
    // The executeBatch method is called for each chunk of records returned from start.  
    global void execute(Database.BatchableContext BC, SObject[] scope){
       // Create a map for the chunk of records passed into method.
       //Map<ID, OrderApi__Badge__c> badgeMap = new Map<ID, Job__c>((OrderApi__Badge__c[])scope);  
       
       Set<Id> cons = new Set<Id>();

       for(OrderApi__Badge__c bdg :  (OrderApi__Badge__c[])scope) {
       		cons.add(bdg.OrderApi__Contact__c);
       }

        // Create a list of Job__Share objects to be inserted.
        ContactShare[] newJobShrs = new ContactShare[]{};
               
        // Locate all existing sharing records for the Job records in the batch.
        // Only records using an Apex sharing reason for this app should be returned. 
        ContactShare[] oldJobShrs = [SELECT Id FROM ContactShare WHERE ContactId IN :cons AND RowCause = 'Manual Sharing']; 
        
        Delete oldJobShrs;

        Badge_Trigger.rss.ShareWithGroup(scope);
 
    }
    
    // The finish method is called at the end of a sharing recalculation.
    global void finish(Database.BatchableContext BC){  
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'vshah@fonteva.com'}; 
        mail.setToAddresses(new String[]{'vshah@fonteva.com'}); 
        mail.setSubject('Apex Sharing Recalculation Completed.');
        mail.setPlainTextBody
                      ('The Apex sharing recalculation finished processing');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}