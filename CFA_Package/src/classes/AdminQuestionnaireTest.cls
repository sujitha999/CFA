@isTest
private class AdminQuestionnaireTest{
    
    @testsetup
    static void createLead(){
        
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
            EventApi__Start_Date_Time__c = system.today(),
            EventApi__End_Date_Time__c = system.today().addDays(1)
            );
        insert new List<EventApi__Event__c>{
            Event
        };
        
        // creating Attendee
        EventApi__Attendee__c attendee = new EventApi__Attendee__c(
            EventApi__Event__c = Event.id,
            CFAMN__Send_Email__c = true,
            EventApi__Email__c = 'abc@gmail.com',
            EventApi__Status__c = 'Registered'
            );
        insert new List<EventApi__Attendee__c>{
            attendee
        };
        
        // insert PagesApi__Form_Response__c
        PagesApi__Form_Response__c fRes = new PagesApi__Form_Response__c();
        fRes.EventApi__Attendee__c = attendee.Id;
        insert fRes;
    }
    
    private static testMethod void Method1() {
        
        // getting Event
        EventApi__Event__c eve = [SELECT ID
                                    FROM EventApi__Event__c 
                                    WHERE EventApi__Event_Key__c = '123'];
        
        System.currentPageReference().getParameters().put('id', eve.Id);
        adminQuestionnaire obj = new adminQuestionnaire();
        
        // calling methods
        obj.getAttendeeResponses();
        obj.getAttendeeQuestions();
        string res = obj.xlsHeader;
    }

}