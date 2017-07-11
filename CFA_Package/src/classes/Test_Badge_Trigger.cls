/**
 *
 * Test class for the Badge_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
private class Test_Badge_Trigger {

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
    static void testContactBadgeUpdateShare () {

        buildData();

        Test.startTest();
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

        badge.OrderApi__Badge_Type__c = bt2.Id;
        update badge;
        Test.stopTest();

        TestDataFactory.sharingAssert(
            [SELECT ContactId, UserOrGroupId, ContactAccessLevel FROM ContactShare WHERE ContactId = :con.Id AND UserOrGroupId = :groups[1].Id],
            SObjectType.ContactShare.fields.ContactAccessLevel.getName());

    }

    @isTest
    static void testContactBadgeShareOnCreate () {

        buildData();

        Test.startTest();
        OrderApi__Badge_Type__c bt1 = Test_BadgeType_Trigger.createRow();
        bt1.BusinessGroup__c = businessGroups[0].Id;

        insert bt1;

        Contact con = TestDataFactory.createContact();

        OrderApi__Badge__c badge = new OrderApi__Badge__c();
        badge.OrderApi__Badge_Type__c = bt1.Id;
        badge.OrderApi__Is_Active__c = true;
        badge.OrderApi__Contact__c = con.Id;

        insert  badge;
        Test.stopTest();

        TestDataFactory.sharingAssert(
            [SELECT ContactId, UserOrGroupId, ContactAccessLevel FROM ContactShare WHERE ContactId = :con.Id AND UserOrGroupId = :groups[0].Id],
            SObjectType.ContactShare.fields.ContactAccessLevel.getName());

    }

    @isTest
    static void testContactBadgeShareWhenDeletingOneBadge () {

        buildData();

        Test.startTest();
        OrderApi__Badge_Type__c bt1 = Test_BadgeType_Trigger.createRow();
        bt1.Name = 'Btest1';
        bt1.BusinessGroup__c = businessGroups[0].Id;

        OrderApi__Badge_Type__c bt3 = Test_BadgeType_Trigger.createRow();
        bt3.Name = 'Btest3';
        bt3.BusinessGroup__c = businessGroups[0].Id;

        insert new OrderApi__Badge_Type__c[]{bt1, bt3};

        Contact con = TestDataFactory.createContact();

        OrderApi__Badge__c badge = new OrderApi__Badge__c();
        badge.OrderApi__Badge_Type__c = bt1.Id;
        badge.OrderApi__Is_Active__c = true;
        badge.OrderApi__Contact__c = con.Id;

        OrderApi__Badge__c bdg2 = new OrderApi__Badge__c();
        bdg2.OrderApi__Badge_Type__c = bt3.Id;
        bdg2.OrderApi__Is_Active__c = true;
        bdg2.OrderApi__Contact__c = con.Id;

        insert  new OrderApi__Badge__c[] {badge, bdg2};
        delete bdg2;
        Test.stopTest();

        TestDataFactory.sharingAssert(
            [SELECT ContactId, UserOrGroupId, ContactAccessLevel FROM ContactShare WHERE ContactId = :con.Id AND UserOrGroupId = :groups[0].Id],
            SObjectType.ContactShare.fields.ContactAccessLevel.getName());

    }

    @isTest
    static void testContactBadgeShareWhenDeletingOneTypeOfBadge () {

        buildData();

        Test.startTest();
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

        OrderApi__Badge__c bdg2 = new OrderApi__Badge__c();
        bdg2.OrderApi__Badge_Type__c = bt2.Id;
        bdg2.OrderApi__Is_Active__c = true;
        bdg2.OrderApi__Contact__c = con.Id;

        insert  new OrderApi__Badge__c[] {badge, bdg2};

        delete badge;
        Test.stopTest();

        TestDataFactory.sharingAssert(
            [SELECT ContactId, UserOrGroupId, ContactAccessLevel FROM ContactShare WHERE ContactId = :con.Id AND UserOrGroupId = :groups[1].Id],
            SObjectType.ContactShare.fields.ContactAccessLevel.getName());

    }

    @isTest
    static void testContactBadgeShareWhenDeletingOneTypeOfBadgeWithTwoOfOne () {

        buildData();

        Test.startTest();
        OrderApi__Badge_Type__c bt1 = Test_BadgeType_Trigger.createRow();
        bt1.Name = 'Btest1';
        bt1.BusinessGroup__c = businessGroups[0].Id;

        OrderApi__Badge_Type__c bt2 = Test_BadgeType_Trigger.createRow();
        bt2.Name = 'Btest2';
        bt2.BusinessGroup__c = businessGroups[1].Id;

        OrderApi__Badge_Type__c bt3 = Test_BadgeType_Trigger.createRow();
        bt3.Name = 'Btest3';
        bt3.BusinessGroup__c = businessGroups[0].Id;

        insert new OrderApi__Badge_Type__c[] {bt1, bt2, bt3};

        Contact con = TestDataFactory.createContact();

        OrderApi__Badge__c badge = new OrderApi__Badge__c();
        badge.OrderApi__Badge_Type__c = bt1.Id;
        badge.OrderApi__Is_Active__c = true;
        badge.OrderApi__Contact__c = con.Id;

        OrderApi__Badge__c bdg2 = new OrderApi__Badge__c();
        bdg2.OrderApi__Badge_Type__c = bt2.Id;
        bdg2.OrderApi__Is_Active__c = true;
        bdg2.OrderApi__Contact__c = con.Id;

        OrderApi__Badge__c bdg3 = new OrderApi__Badge__c();
        bdg3.OrderApi__Badge_Type__c = bt3.Id;
        bdg3.OrderApi__Is_Active__c = true;
        bdg3.OrderApi__Contact__c = con.Id;

        insert  new OrderApi__Badge__c[] {badge, bdg2, bdg3};

        delete badge;
        Test.stopTest();

        TestDataFactory.sharingAssert(
            [SELECT ContactId, UserOrGroupId, ContactAccessLevel FROM ContactShare WHERE ContactId = :con.Id AND UserOrGroupId = :groups[0].Id],
            SObjectType.ContactShare.fields.ContactAccessLevel.getName());
        
        TestDataFactory.sharingAssert(
            [SELECT ContactId, UserOrGroupId, ContactAccessLevel FROM ContactShare WHERE ContactId = :con.Id AND UserOrGroupId = :groups[1].Id],
            SObjectType.ContactShare.fields.ContactAccessLevel.getName());

    }
}