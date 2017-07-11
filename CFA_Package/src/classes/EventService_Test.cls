/*******
 * Name     :   EventService_Test
 * Purpose  :   This Test class will cover following class
 * EventService
 ******/
 
@isTest
private class EventService_Test {
    
    /****************
     * Name     :   setupData
     * Purpose  :   This will create data needed by test class
     ****************/
    @testSetup
    private static void setupData() {
        
         //Data Setup
        TestDataFactory.testInstall();
        TestDataFactory.sharingSetup();
        
        // creating Event_Category
        EventApi__Event_Category__c EventCategory = new EventApi__Event_Category__c(
            Name = 'Test category'
            );
        insert new List<EventApi__Event_Category__c>{
            EventCategory
        };
        
        // creating event
        EventApi__Event__c Event = new EventApi__Event__c(
            EventApi__Event_Category__c = EventCategory.id,
            EventApi__Event_Key__c = '123',
            Name = 'test event',
            EventApi__Status__c = 'Active',
            CFAMN__Enable_Event_Reminder__c = true,
            EventApi__Ticket_Sales_Start_Date__c = system.today(),
            EventApi__Registration_Style__c = 'Simple',
            EventApi__Start_Date__c = system.today().addDays(1),
            CFAMN__Event_Reminder_Days_Variable__c = 1,
            EventApi__Capacity__c = 100,
            EventApi__Quantity_Sold__c = 0,
            EventApi__Start_Date_Time__c = system.today().addDays(1),
            EventApi__End_Date_Time__c = system.today().addDays(2)
            );
        insert new List<EventApi__Event__c>{
            Event
        };
        
        // creating Ticket_Type
        EventApi__Ticket_Type__c ticketType = new EventApi__Ticket_Type__c(
            Name = 'Registration Test',
            EventApi__UOM__c = 'Ticket',
            EventApi__Price__c = 100,
            EventApi__Event__c = Event.id,
            EventApi__Quantity_Available__c = 10
            );
        insert new List<EventApi__Ticket_Type__c>{
            ticketType
        };
            
    }
    
    /*************
     * Name     :   Method1
     * Purpose  :   This method will decrease Tickets Remaining to 0
    *************/
    private static testMethod void Method1() {
        
        // query event created in test setup
        List<EventApi__Event__c> lstUpdateEvent =  new List<EventApi__Event__c>();
        for(EventApi__Event__c event : [select 
                                        EventApi__Capacity__c,
                                        EventApi__Quantity_Sold__c 
                                        From EventApi__Event__c 
                                        where Name = 'test event']){
            // assign capacity to sold to make Tickets Remaining to 0
            event.EventApi__Quantity_Sold__c = event.EventApi__Capacity__c;
            
            // adding to List
            lstUpdateEvent.add(event);
        }
        
        // check if we found any event to be updated
        if(!lstUpdateEvent.isEmpty()){
            update lstUpdateEvent;
        }
    }
}