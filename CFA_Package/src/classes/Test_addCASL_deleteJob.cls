@isTest
private class Test_addCASL_deleteJob {

    static OrderApi__Business_Group__c[] businessGroups = new OrderApi__Business_Group__c[]{};
    static Group[] groups = new Group[]{};

    @testSetup
    static void setupTest() {
        //Data Setup

        TestDataFactory.testInstall();
        TestDataFactory.sharingSetup();
    }
    
    private static void buildData() {
        if(businessGroups.isEmpty()) {
            Map<String, SObject[]> testData = TestDataFactory.buildData();
            businessGroups = (OrderApi__Business_Group__c[])testData.get(TestDataFactory.BUSINESSGROUPLABEL);
            groups = (Group[])testData.get(TestDataFactory.PUBLICGROUPLABEL);
        }
    }
    
    
    // insert badge type
    @isTest
    static void checkDuplicateBadge () {
        
        buildData();
        
        OrderApi__Badge_Type__c bt1 = Test_BadgeType_Trigger.createRow();
        bt1.Name = 'Btest1';
        bt1.BusinessGroup__c = businessGroups[0].Id;
        bt1.TypeId__c = 'CASLImp';
        
        // inserting data
        insert new OrderApi__Badge_Type__c[] {bt1};
        
        // insert contact
        Contact con = TestDataFactory.createContact();
        
        Test.startTest();
        
        OrderApi__Badge__c badge = new OrderApi__Badge__c();
        badge.OrderApi__Badge_Type__c = bt1.Id;
        badge.OrderApi__Is_Active__c = true;
        badge.OrderApi__Contact__c = con.Id;
        badge.OrderApi__Expired_Date__c = system.today().addDays(1);
        badge.OrderApi__Awarded_Date__c = system.today();
        badge.Implied_Consent_Manual_Reference__c = 'test';
        insert  badge;
        
        // insert duplicate badge
        badge = new OrderApi__Badge__c();
        badge.OrderApi__Badge_Type__c = bt1.Id; 
        badge.OrderApi__Is_Active__c = true;
        badge.OrderApi__Contact__c = con.Id;
        badge.OrderApi__Expired_Date__c = system.today().addDays(1);
        badge.OrderApi__Awarded_Date__c = system.today();
        try{
            insert badge;
        }
        catch(Exception ex){
            
        }
        
        // calling sechule class to delete Badge
        String sch = '0  00 1 3 * ?';
        system.schedule('Test', sch, new DeleteCASLBadgeScheduler());
        
        test.stopTest();
          
    }
    
    
    // insert badge type
    @isTest
    static void insertCASLbadgeValidate () {
        
        // contact inserting contact
        contact con = new contact(
            LastName = 'Default Contact',
            FirstName = 'Fonteva'
        );
        
        contact con1 = new contact(
            LastName = 'Contact',
            FirstName = 'Fonteva',
            MailingCountry = 'Canada'
        );
        insert new List<contact>{
            con,
            con1
        };
        
        buildData();
        
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
        
        
        OrderApi__Badge_Type__c bt1 = Test_BadgeType_Trigger.createRow();
        bt1.Name = 'Btest1';
        bt1.BusinessGroup__c = businessGroups[0].Id;
        bt1.TypeId__c = 'CASLImp';
        
        // inserting data
        insert new OrderApi__Badge_Type__c[] {bt1};
        
        // insert sales order
        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c();
        so.OrderApi__Billing_Street__c = 'street asd';
        so.OrderApi__Billing_City__c = 'street asd';
        so.OrderApi__Billing_State__c = 'street asd';
        so.OrderApi__Billing_Country__c = 'United s';
        so.OrderApi__Billing_Postal_Code__c = '12312';
        so.OrderApi__Contact__c = con1.Id;
        so.OrderApi__Business_Group__c = businessGroups[0].Id;
        insert so;
        
        // insert sales order line
        OrderApi__Sales_Order_Line__c sol = new OrderApi__Sales_Order_Line__c();
        sol.OrderApi__Sales_Order__c = so.Id;
        //sol.OrderApi__Item__c = itm.Id;
        //sol.OrderApi__Subscription_Plan__c = subPlan.Id;
        sol.OrderApi__Auto_Calculate_Activation_Date__c = true;
        //sol.EventApi__Event__c = Event.id;
        sol.OrderApi__Contact__c = con1.id;
        insert sol;
         
         // Set mock callout class 
        Test.startTest();
    
        // updating sales order line
        so.OrderApi__Status__c = 'Closed';
        so.OrderApi__Posting_Status__c = 'Posted';
        so.OrderApi__Is_Posted__c = true;
        update so;
        
        test.stopTest();
          
    }

}