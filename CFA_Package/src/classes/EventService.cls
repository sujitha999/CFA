/**
 *
 * Service class for PagesApi__Site__c
 * @author Vishal Shah
 *
 **/

public without sharing class EventService {
  public static String className = EventService.class.getName();
  
  /**
     * Default logic for SObject.
     *
     * @param records  =>  List of EventApi__Event__c.
     */
    public static void setDefaults(EventApi__Event__c[] records) {
        Framework.Log.push(className,'setDefaults');

        Set<Id> bgids = new Set<Id> ();
        for (EventApi__Event__c ev : records) {
          if(ev.EventApi__Business_Group__c != null) {
            bgids.add(ev.EventApi__Business_Group__c);
          }
        }

        Map<Id, Id> bgsite = new Map<Id, Id>();
        for (PagesApi__Site__c s : [SELECT Id, OrderApi__Business_Group__c FROM PagesApi__Site__c WHERE OrderApi__Business_Group__c in :bgids]) {
          bgsite.put(s.OrderApi__Business_Group__c, s.Id);
        }

        for (EventApi__Event__c evnt : records) {
          evnt.Site__c = bgsite.get(evnt.EventApi__Business_Group__c);
        }

        Framework.Log.pop();
    }
    
    /**
     * Name         :   updateTicketRemainingonTicketType
     * Pupose       :   This will update the Ticket_Type ticket remaing field 
     *                  When ticket remaining on event is 0
     * Created Date :   
     **/
    /*public static void updateTicketRemainingonTicketType(EventApi__Event__c[] records) {
        
        // This will save the event ids whoes ticket remaining is 0
        set<id> setEventIds = new set<id>();
        
        // This will save ticket types to be updated
        list<EventApi__Ticket_Type__c> lstUpdateTicket = new list<EventApi__Ticket_Type__c>();
        
        // iterating all events records
        for(EventApi__Event__c event : records){
            
            // if EventApi__Quantity_Remaining is 0 add to set
            if(event.EventApi__Attendees__c == event.EventApi__Capacity__c || event.EventApi__Attendees__c >= event.EventApi__Capacity__c){
                setEventIds.add(event.id);
            }
            system.debug('\n--setEventIds--'+setEventIds);
        }
        // code to get related Ticket Type
        for(EventApi__Ticket_Type__c ticketType : [Select 
                                        id,
                                        EventApi__Quantity_Available__c,
                                        EventApi__Quantity_Sold__c,
                                        CFAMN__Historical_ticket_quantity__c
                                        From EventApi__Ticket_Type__c 
                                        where EventApi__Event__c IN :setEventIds 
                                        AND CFAMN__Historical_ticket_quantity__c = NULL])
        { 
            system.debug('\n--ticketType--'+ticketType);
            // copy Ticket Quantit y to Historical Ticket Quantity
            ticketType.CFAMN__Historical_ticket_quantity__c = ticketType.EventApi__Quantity_Available__c;
            
            // adding to list for updating
            lstUpdateTicket.add(ticketType);
        }
        system.debug('\n---lstUpdateTicket---'+lstUpdateTicket);
        
        // creating save point 
        Savepoint sp = Database.setSavepoint();
        
        // check if list has records for updating
        if(!lstUpdateTicket.isEmpty()){
            try{
                update lstUpdateTicket;
                system.debug('\n---lstUpdateTicket---'+lstUpdateTicket);
            }
            catch(Exception ex){
               system.debug('\n--ex--'+ex.getmessage());
               
               // Rollback to the previous null value
               Database.rollback(sp);
            }
        }
    } */
}