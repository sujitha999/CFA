/*******
 * Name     batchAttendeeUpdate
 * Pupose   This will update the attendee so that email can be send to each attandee
 ******/

global class batchAttendeeUpdate implements Database.Batchable<sObject> {
    
    // This will save query from difference class which can be used in start method
    public string strQuery {get;set;}
    
    // Start Method will automactically called once batch executed
    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('\n--strQuery--'+strQuery);
        return Database.getQueryLocator(strQuery);
    }
    
    // logic for updating attendee
    global void execute(Database.BatchableContext BC, List<sobject> scope) {
        // This list will have all the attandee to which email will be send
        List<EventApi__Attendee__c> lstSendEmailAttendee = new List<EventApi__Attendee__c>();
        
        // iteration to prepare list of email which will be send to attendee
        for(EventApi__Attendee__c attendee : (List<EventApi__Attendee__c>)scope){
            attendee.CFAMN__Send_Email__c = true;
            lstSendEmailAttendee.add(attendee);
        }
        
        // if list is not empty
        if(!lstSendEmailAttendee.isEmpty()){
            update lstSendEmailAttendee; 
        }
    }
    
    // final method after batch completed
    global void finish(Database.BatchableContext BC) {
    }

}