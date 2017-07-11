/*******
 * Name     scheduledSendAttendeeEmail
 * Pupose   This will send email to the Attendee based upon the 
 *          Event Reminder Days Variable field on event object and Event Date on event object
 ******/

global without sharing class scheduledSendAttendeeEmail implements Schedulable {
    // This will be used to save the status which will not be included in sending reminder
    FINAL string ATTENDEESTATUS = 'Registered';
    
    global void execute(SchedulableContext SC) {
    //global void execute() {
        // This will save Email Template Name 
        string EmailTemplateName = 'Event_Reminder';
        
        // This list will have all the attandee id to which email will be send
        set<id> lstSendEmailAttendee = new set<id>();
        
        // code to get allevents which are schdule in future
        List<EventApi__Event__c> lstEvents =        [Select 
                                                    id,
                                                    CFAMN__Event_Reminder_Days_Variable__c,
                                                    EventApi__Start_Date__c,
                                                    
                                                    /* inner Query to get attendee information */
                                                    (select 
                                                    id,
                                                    EventApi__Preferred_Email__c ,
                                                    EventApi__Status__c
                                                    From EventApi__Attendees__r)
                                                    
                                                    From EventApi__Event__c
                                                    where EventApi__Status__c = 'Active' AND 
                                                    CFAMN__Enable_Event_Reminder__c = True AND
                                                    EventApi__Start_Date__c >= :system.today()];
        system.debug('\n--lstEvents--'+lstEvents);
                                                
        // iterating rocrds to get Events where (today = Event Start Date - Event Reminder Days Variable )
        for(EventApi__Event__c event : lstEvents){
            
            // If Reminder value if is blank then make it 0
            Integer ReminderDays = ((event.CFAMN__Event_Reminder_Days_Variable__c == null ) ? 0 : event.CFAMN__Event_Reminder_Days_Variable__c).intValue();
            system.debug('\n--ReminderDays--'+ReminderDays+'\n--event.EventApi__Start_Date__c--'+event.EventApi__Start_Date__c+'\n--today & reminder--'+system.today().addDays(ReminderDays)+'\n--Condition--'+(event.EventApi__Start_Date__c == system.today().addDays(ReminderDays)));
            
            // check if Event date  is equal to today plus reminder date
            if(event.EventApi__Start_Date__c == system.today().addDays(ReminderDays)){
                
                // getting all attendee for event
                for(EventApi__Attendee__c attendee : event.EventApi__Attendees__r){
                        
                    // code to check if attandee is not changed
                    if(attendee.EventApi__Status__c == ATTENDEESTATUS){
                        // store Attendee in list
                        lstSendEmailAttendee.add(attendee.id);    
                    }
                    
                }
            }
        }
        
        // code to send email for each Attendee
        system.debug('\n--lstSendEmailAttendee--'+lstSendEmailAttendee);
        if(!lstSendEmailAttendee.isEmpty()){
            // creating batch instance to set query
            batchAttendeeUpdate batchObj = new batchAttendeeUpdate();
            
            // creating query which will passed in batch
            batchObj.strQuery = 'select id,EventApi__Preferred_Email__c From EventApi__Attendee__c where id IN (';
            
            // This will store ids list to be used in qyery
            string strIds = '';
            
            for(id attendee : lstSendEmailAttendee){ 
                strIds += '\''+attendee+'\',';
            }
            strIds += strIds.substring(0,strIds.length()-1);
            system.debug('\n--strIds--'+strIds);
            
            // adding left bracket
            strIds += ')';
            
            // combining id list into mail query
            batchObj.strQuery += strIds;
            system.debug('\n--batchObj--'+batchObj.strQuery);
            
            // executing bacth
            Database.executeBatch(batchObj);
        }
    } 
}