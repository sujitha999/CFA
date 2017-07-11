@isTest
private class AttendeeCASLServiceTest {
    
    static Boolean isInstalled = false;

    private static void install() {
       if (!isInstalled) {           
           
           Framework.Installer.install();
           PagesApi.PackageScripts.install();
           OrderApi.PackageScripts.install();               
           EventApi.PackageScripts.install();
           
           // Create a routing rule for Contact
           Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
           Framework.RoutingRule cons = new Framework.RoutingRule();
           cons.apexClass = Attendee_Trigger.class.getName();
           cons.namespace = '';
           cons.isEnabled = true;
           cons.sObjectName = 'EventApi__Attendee__c';
           cons.executionOrder = 0;
           rules.add(cons);
           Framework.Config.push(rules);                
           isInstalled = true;
       }
   }

    @testSetup
    static void setupTest() {
    
        //Data Setup
        //TestDataFactory.testInstall();
        install();
    }
    
    // insert badge type
    @isTest
    static void validateAttendee() {
        
        OrderApi__Business_Group__c bg = new OrderApi__Business_Group__c();
        bg.name = 'test';
        bg.Org_Code__c = 'Testing';
        bg.SystemPublicGroupId__c = '00G610000019GVxEAM';
        insert bg;
        
        
        
        OrderApi__Badge_Type__c bt1 = Test_BadgeType_Trigger.createRow();
        bt1.Name = 'Btest1';
        bt1.BusinessGroup__c = bg.Id;
        bt1.TypeId__c = 'CASLImp';
        bt1.TypeId__c = 'CASLImp';
        
        // inserting data
        insert new OrderApi__Badge_Type__c[] {bt1};
        
        // insert contact
        Contact con = new Contact();
        con.LastName = 'Last con';
        insert new List<contact> {con};
        
        Contact con1 = new Contact();
        con1.LastName = 'Tes';
        con1.MailingCountry = 'CANADA';
        insert con1;
        
        // isert badge
        OrderApi__Badge__c badge = new OrderApi__Badge__c();
        badge.OrderApi__Badge_Type__c = bt1.Id;
        badge.OrderApi__Is_Active__c = true;
        badge.OrderApi__Contact__c = con1.Id;
        badge.OrderApi__Expired_Date__c = system.today().addDays(1);
        badge.OrderApi__Awarded_Date__c = system.today();
        badge.Created_By_Trigger__c = true;
        insert badge;
        
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
        Enable_Event_Reminder__c = true,
        EventApi__Ticket_Sales_Start_Date__c = system.today().addDays(-2),
        EventApi__Registration_Style__c = 'Simple',
        EventApi__Start_Date__c = system.today().addDays(1),
        Event_Reminder_Days_Variable__c = 1,
        EventApi__Capacity__c = 100,
        EventApi__Quantity_Sold__c = 0,
        EventApi__Start_Date_Time__c = system.today(),
        EventApi__End_Date_Time__c = system.today().addDays(1)
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
            EventApi__Quantity_Available__c = 10,
            BusinessGroup__c = bg.Id
        );
        insert new List<EventApi__Ticket_Type__c>{
            ticketType
        };
        
        // creating Attendee
        EventApi__Attendee__c attendee = new EventApi__Attendee__c(
            EventApi__Event__c = Event.id,
            Send_Email__c = true,
            EventApi__Email__c = 'abc@gmail.com',
            EventApi__Status__c = 'Registered',
            EventApi__Contact__c = con.Id,
            EventApi__Ticket_Type__c = ticketType.Id
            );
        insert new List<EventApi__Attendee__c>{
            attendee
        };
        
        attendee.EventApi__Contact__c = con1.Id;
        update attendee;
        
    }

}