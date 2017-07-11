@isTest
private class ContactBadgeSharingTest {

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
    
    @isTest
    static void testContactSharingRecalc () {
        buildData();
        
        OrderApi__Badge_Type__c bt1 = Test_BadgeType_Trigger.createRow();
        bt1.Name = 'Btest1';
        bt1.BusinessGroup__c = businessGroups[0].Id;

        OrderApi__Badge_Type__c bt2 = Test_BadgeType_Trigger.createRow();
        bt2.Name = 'Btest2';
        bt2.BusinessGroup__c = businessGroups[1].Id;

        insert new OrderApi__Badge_Type__c[] {bt1, bt2};

        Contact con = TestDataFactory.createContact();

        OrderApi__Badge__c badge = new OrderApi__Badge__c();
        badge.OrderApi__Badge_Type__c = bt1.Id;
        badge.OrderApi__Is_Active__c = true;
        badge.OrderApi__Contact__c = con.Id;

        insert  badge;
        
        Test.startTest();
        
        // running badge sharing batch
        Database.executeBatch(new BadgeSharingRecalc());
        
        // schduling contact sharing class
        ContactSharingRecalcSchedule sh1 = new ContactSharingRecalcSchedule();      
        String sch = '0  00 1 3 * ?';
       system.schedule('Test', sch, sh1);
        
        
        Test.stopTest();
    }

}