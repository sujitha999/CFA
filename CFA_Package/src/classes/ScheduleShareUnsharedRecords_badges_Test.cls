@isTest
private class ScheduleShareUnsharedRecords_badges_Test {


    @testSetup
    static void setupTest() {
        
        OrderApi__Business_Group__c bg = new OrderApi__Business_Group__c();
        bg.name = 'test';
        bg.Org_Code__c = 'Testing';
        insert bg;
        
        OrderApi__Badge_Type__c bt1 = Test_BadgeType_Trigger.createRow();
        bt1.Name = 'Btest1';
        bt1.BusinessGroup__c = bg.Id;
        bt1.CFAMN__TypeId__c = 'CASLImp';
        
        // inserting data
        insert new OrderApi__Badge_Type__c[] {bt1};
        
        // insert contact
        Contact con = TestDataFactory.createContact(); 
        
        OrderApi__Badge__c badge = new OrderApi__Badge__c();
        badge.OrderApi__Badge_Type__c = bt1.Id;
        badge.OrderApi__Is_Active__c = true;
        badge.OrderApi__Contact__c = con.Id;
        badge.OrderApi__Expired_Date__c = system.today().addDays(1);
        badge.OrderApi__Awarded_Date__c = system.today();
        badge.Recalculate_Sharing__c = true;
        badge.CFAMN__Implied_Consent_Manual_Reference__c = 'test';
        insert  badge;
    }
    
    
    
    // insert badge type
    @isTest
    static void validateShareUnsharebadges () {
        
        Test.startTest();
        
        // calling sechule class to delete Badge
        String sch = '0  00 1 3 * ?';
        system.schedule('Test', sch, new ScheduleShareUnsharedRecords_badges());
        
        test.stopTest();
          
    }

}