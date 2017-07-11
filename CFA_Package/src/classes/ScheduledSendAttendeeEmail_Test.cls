/*******
 * Name     ScheduledSendAttendeeEmail_Test
 * Purpose   This Test class will cover following class
 * scheduledSendAttendeeEmail
 * batchAttendeeUpdate
 ******/
 
@isTest
private class ScheduledSendAttendeeEmail_Test {
    
    /****************
     * Name     :   setupData
     * Purpose  :   This will create data needed by test class
     ****************/
    @testSetup
    private static void setupData() {
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
            CFAMN__Event_Reminder_Days_Variable__c = 1
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
            
    }
    
    /*************
     * Name     :   Method1
     * Purpose  :   This method will schdule the class
    *************/
  private static testMethod void Method1() {
      // refresh governer Limits
      Test.startTest();
        scheduledSendAttendeeEmail objClass = new scheduledSendAttendeeEmail();
        System.schedule('Scheduled Job 99', '0 0 23 * * ?', new scheduledSendAttendeeEmail());
        test.stopTest();
  }
  
  /*************
     * Name     :   Method2
     * Purpose  :   This method will execute the batch class
    *************/
  private static testMethod void Method2() {
      // refresh governer Limits
      Test.startTest();
        batchAttendeeUpdate batchClass = new batchAttendeeUpdate();
        batchClass.strQuery = 'select id from EventApi__Attendee__c';
        Database.executeBatch(batchClass);
        test.stopTest();
  }

}