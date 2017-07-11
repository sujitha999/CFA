@isTest
private class AttendeeCancellationAutomationTest {

 @testSetup
    private static void setupData() {
        
        // creating Event_Category
        EventApi__Event_Category__c EventCategory = new EventApi__Event_Category__c(
            Name = 'Test category'
        );
        insert new List<EventApi__Event_Category__c>{
            EventCategory
        };
        
        OrderApi__Business_Group__c bg = new OrderApi__Business_Group__c();
        bg.name = 'test';
        bg.Org_Code__c = 'Testing';
        insert bg;

        OrderApi__Subscription_Plan__c subPlan = new OrderApi__Subscription_Plan__c();
        subPlan.OrderApi__Business_Group__c = bg.Id;
        //subPlan.Sub_Advance_Calendar_Period__c = 90;
        subPlan.OrderApi__Calendar_End_Day__c = '31';
        subPlan.OrderApi__Calendar_End_Month__c = '05 - May';
        subPlan.OrderApi__Type__c = 'Calendar';
        subPlan.OrderApi__Is_Active__c = true;
        insert subPlan;

        OrderApi__Item_Class__c itmClass = new OrderApi__Item_Class__c();
        itmClass.OrderApi__Business_Group__c = bg.Id;
        itmClass.OrderApi__Is_Subscription__c = true;
        insert itmClass;
        
        OrderApi__Item__c itm = new OrderApi__Item__c();
        itm.OrderApi__Item_Class__c = itmClass.Id;
        itm.OrderApi__Business_Group__c = bg.id;
        itm.OrderApi__Is_Active__c = false;
        itm.Name = 'T-shirt';
        itm.OrderApi__Price__c = 10;
        itm.OrderApi__Is_Subscription__c = true;
        itm.Tax_With_Taxware__c = true;     
        itm.Good_Srv_Code__c = '3010';                                       
        insert itm;

        OrderApi__Item_Subscription_Plan__c isp = new OrderApi__Item_Subscription_Plan__c();
        isp.OrderApi__Is_Default__c = true;
        isp.OrderApi__Item__c = itm.Id;
        isp.OrderApi__Subscription_Plan__c = subPlan.Id;
        insert isp;

        itm.OrderApi__Is_Active__c = true;
        update itm;
        
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
            EventApi__Start_Date_Time__c = system.today().addDays(-1),
            EventApi__End_Date_Time__c = system.today().addDays(1)
            //Cancellation_Fee_End_Date__c = system.today().addDays(-1)
        );
        insert new List<EventApi__Event__c>{
            Event
        };
        
        // insert venue
        EventApi__Venue__c ven = new EventApi__Venue__c(
            Name = 'test',
            EventApi__Event__c = Event.id,
            EventApi__Street__c = 'test street',
            EventApi__City__c = 'test City',
            EventApi__State__c = 'test State',
            EventApi__Country__c = 'test Country',
            EventApi__Postal_Code__c = 'test street'
        );
        insert ven;
        
        // insert sales order
        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c();
        insert so;
        
        OrderApi__Sales_Order_Line__c sol = new OrderApi__Sales_Order_Line__c();
        sol.OrderApi__Sales_Order__c = so.Id;
        sol.OrderApi__Item__c = itm.Id;
        sol.OrderApi__Subscription_Plan__c = subPlan.Id;
        sol.OrderApi__Auto_Calculate_Activation_Date__c = true;
        sol.OrderApi__Is_Tax__c = false;
        sol.OrderApi__Sales_Order_Line__c = NULL;
        insert sol;
        
        // creating receipt data
        OrderApi__Receipt__c receipt = new OrderApi__Receipt__c();
        receipt.OrderApi__Sales_Order__c = so.Id;
        insert receipt; 
        
        
        // insert receipt line
        OrderApi__Receipt_Line__c rlines = new OrderApi__Receipt_Line__c();
        rlines.OrderApi__Receipt__c = receipt.id;
        
        insert rlines;
        
        
        // creating Attendee
        EventApi__Attendee__c attendee = new EventApi__Attendee__c(
            EventApi__Event__c = Event.id,
            Send_Email__c = true,
            EventApi__Email__c = 'abc@gmail.com',
            EventApi__Status__c = 'Registered',
            EventApi__Refund_Requested__c = false,
            EventApi__Sales_Order__c = so.Id
        );
        
        // creating Attendee
        EventApi__Attendee__c attendee1 = new EventApi__Attendee__c(
            EventApi__Event__c = Event.id,
            Send_Email__c = true,
            EventApi__Email__c = 'abcd@gmail.com',
            EventApi__Status__c = 'Registered',
            EventApi__Refund_Requested__c = false,
            EventApi__Sales_Order__c = so.Id
        );
        
        insert new List<EventApi__Attendee__c>{
            attendee,
            attendee1
        };
            
    }
    
     private static testMethod void vaidatePositiveCases() {
         
        TestDataFactory.testInstall();
        TestDataFactory.sharingSetup();
        // Create a routing rule 
        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule rule = new Framework.RoutingRule();
        rule.apexClass = 'Attendee_Trigger';
        rule.namespace = '';
        rule.isEnabled = true;
        rule.sObjectName = 'EventApi__Attendee__c';
        rule.executionOrder = 1;
        rules.add(rule);
        Framework.Config.push(rules);  
         
        test.startTest();
        List<EventApi__Attendee__c> lstAttendee = [Select id from EventApi__Attendee__c where EventApi__Email__c = 'abc@gmail.com'];
        for(EventApi__Attendee__c rec  : lstAttendee){
            rec.EventApi__Refund_Requested__c = true;
        }
        
        update lstAttendee;
        test.stopTest();       
        
    }
    
    
     private static testMethod void vaidateErrorCases() {
         
        TestDataFactory.testInstall();
        TestDataFactory.sharingSetup();
        // Create a routing rule 
        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule rule = new Framework.RoutingRule();
        rule.apexClass = 'Attendee_Trigger';
        rule.namespace = '';
        rule.isEnabled = true;
        rule.sObjectName = 'EventApi__Attendee__c';
        rule.executionOrder = 1;
        rules.add(rule);
        Framework.Config.push(rules); 
         
        test.startTest();
        
        List<EventApi__Event__c> lstEve = [Select id from EventApi__Event__c limit 1];
        lstEve[0].Cancellation_Fee_End_Date__c = system.today().addDays(-2);
        update lstEve[0];
        
        List<EventApi__Attendee__c> lstAttendee = [Select id from EventApi__Attendee__c where EventApi__Email__c = 'abcd@gmail.com'];
        for(EventApi__Attendee__c rec  : lstAttendee){
            rec.EventApi__Refund_Requested__c = true;
        }   
         
        
        update lstAttendee;
        test.stopTest();
    }

}