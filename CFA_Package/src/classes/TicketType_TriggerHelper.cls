/**
 *
 * Call containing logics for TicketType_Trigger Domain class
 * @author Nikilesh
 *
 **/
public without sharing class TicketType_TriggerHelper {
    
    // This Method will update Ticket Quantity to sold quantity
    // condition when Historical_ticket_quantity is changed
    public static void updateTicketQuantity(list<EventApi__Ticket_Type__c> lstTickets, Map<Id,sobject> oldMap){
        
        // set will have event ids
        set<id> lstEventids = new set<id>();
        
         // for each record updated to save related event id
        for(EventApi__Ticket_Type__c Ticket : lstTickets){
            /*lstEventids.add(Ticket.EventApi__Event__c);*/
            
            // if historical data is not blank
            if(Ticket.CFAMN__Historical_ticket_quantity__c != null){
                //assign avaliable quantity to sold quantity
                Ticket.EventApi__Quantity_Available__c = Ticket.EventApi__Quantity_Sold__c;
            }
        }
        
        
        /****
        // code to create map of Event and Event record
        Map<id,EventApi__Event__c> mapEventDetails = new Map<id,EventApi__Event__c>([select id,EventApi__Quantity_Remaining__c from EventApi__Event__c where id IN :lstEventids]);
        system.debug('\n--mapEventDetails--'+mapEventDetails);
        
        // for each record updated
        for(EventApi__Ticket_Type__c Ticket : lstTickets){
            /*****
             * Previous Logic
            // code to get old data using type casting
            EventApi__Ticket_Type__c oldData = (EventApi__Ticket_Type__c) oldMap.get(Ticket.id);
            
            // condition check if Historical_ticket_quantity is changed
            if(oldData.CFAMN2__Historical_ticket_quantity__c != Ticket.CFAMN2__Historical_ticket_quantity__c){
                
                // assign avaliable quantity to sold quantity
                Ticket.EventApi__Quantity_Available__c = Ticket.EventApi__Quantity_Sold__c;
                system.debug('\n--Ticket--'+Ticket);
            }
            ****/
            
            
            /*** 
             * New logic update valiable quantity to sold quantity when event Remaining quantity is 0 or less then 0
            ***/
            
            /***
            // code to check if event types exist in map
            if(mapEventDetails.containsKey(Ticket.EventApi__Event__c)){
                
                // if event remaing quantity is 0 or less then 0 update Ticket type
                if(mapEventDetails.get(Ticket.EventApi__Event__c).EventApi__Quantity_Remaining__c <= 0){
                    
                    //assign avaliable quantity to sold quantity
                    Ticket.EventApi__Quantity_Available__c = Ticket.EventApi__Quantity_Sold__c;
                    system.debug('\n--Ticket--'+Ticket);
                }
            }
        }
        **/
    }

}