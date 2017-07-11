@isTest
private class TXWR_ProcessSO_Test {
    
    
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
           cons.apexClass = SalesOrder_Trigger.class.getName();
           cons.namespace = '';
           cons.isEnabled = true;
           cons.sObjectName = 'OrderApi__Sales_Order__c';
           cons.executionOrder = 0;
           rules.add(cons);
           Framework.Config.push(rules);                
           isInstalled = true;
       }
   }
    
   static testMethod void validateSOLInsert() {
        
        // inserting custom setting
        Taxware_Configuration__c objCS = new Taxware_Configuration__c();
        objCS.Name = 'Main';
        objCS.Endpoint__c = 'Main';
        //objCS.Good_Srv_Code__c = 'TEST-CFA';
        //objCS.Org_Code__c = '3010';
        objCS.Password__c = 'Testing';
        objCS.Secret_Key__c = 'Testing';
        objCS.Username__c = 'Testing';
        
        insert new list<Taxware_Configuration__c>{
            objCS
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
        EventApi__Ticket_Sales_Start_Date__c = system.today(),
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
        
        OrderApi__Item__c itm = new OrderApi__Item__c();
        itm.OrderApi__Item_Class__c = itmClass.Id;
        itm.OrderApi__Business_Group__c = bg.id;
        itm.OrderApi__Is_Active__c = false;
        itm.Name = 'T-shirt';
        itm.OrderApi__Price__c = 10;
        itm.OrderApi__Is_Subscription__c = true;
        itm.Tax_With_Taxware__c = true;     
        itm.Good_Srv_Code__c = '3010';
        itm.EventApi__Event__c = Event.Id;
        insert itm;
        
        OrderApi__Item_Subscription_Plan__c isp = new OrderApi__Item_Subscription_Plan__c();
        isp.OrderApi__Is_Default__c = true;
        isp.OrderApi__Item__c = itm.Id;
        isp.OrderApi__Subscription_Plan__c = subPlan.Id;
        insert isp;

        itm.OrderApi__Is_Active__c = true;
        update itm;
        
        // insert venue
        EventApi__Venue__c ven = new EventApi__Venue__c(
            Name = 'test',
            EventApi__Event__c = Event.id,
            EventApi__Street__c = 'test street',
            EventApi__City__c = 'test City',
            EventApi__State__c = 'test State',
            EventApi__Country__c = 'test Country',
            EventApi__Postal_Code__c = 'test street',
            EventApi__Is_Primary_Venue__c = true
        );
        insert ven;
        
        // contact inserting contact
        contact con = new contact(
            LastName = 'Default Contact',
            FirstName = 'Fonteva'
        );
        
        contact con1 = new contact(
            LastName = 'Contact',
            FirstName = 'Fonteva'
        );
        insert new List<contact>{
            con,
            con1
        };
        
        // insert sales order
        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c();
        so.OrderApi__Billing_Street__c = 'street asd';
        so.OrderApi__Billing_City__c = 'street asd';
        so.OrderApi__Billing_State__c = 'street asd';
        so.OrderApi__Billing_Country__c = 'United s';
        so.OrderApi__Billing_Postal_Code__c = '12312';
        insert so;
        
        // insert sales order line
        OrderApi__Sales_Order_Line__c sol = new OrderApi__Sales_Order_Line__c();
        sol.OrderApi__Sales_Order__c = so.Id;
        sol.OrderApi__Item__c = itm.Id;
        sol.OrderApi__Subscription_Plan__c = subPlan.Id;
        sol.OrderApi__Auto_Calculate_Activation_Date__c = true;
        sol.EventApi__Event__c = Event.id;
        sol.OrderApi__Contact__c = con1.id;
        insert sol;
        
        install();
         
         // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpTaxwareResponse());
        Test.startTest();
    
        // updating sales order line
        so.Taxware_SO__c = true; 
        so.OrderApi__Status__c = 'Closed';
        so.OrderApi__Posting_Status__c = 'Posted';
        so.OrderApi__Is_Posted__c = true;
        update so;
        
        Test.stopTest();
        
  }

}