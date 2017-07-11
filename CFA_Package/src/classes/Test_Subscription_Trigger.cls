/**
 *
 * Test class for the Subscription_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
private class Test_Subscription_Trigger {

    static OrderApi__Business_Group__c[] businessGroups = new OrderApi__Business_Group__c[]{};
    static Group[] groups = new Group[]{};
    static Account acct = new Account();
    static Contact con = new Contact();
    static OrderApi__Subscription_Plan__c subPlan = new OrderApi__Subscription_Plan__c();
    static OrderApi__Item__c itm;
    static OrderApi__Item_Class__c itmClass;
    static OrderApi__Payment_Method__c pMethod = new OrderApi__Payment_Method__c();
    

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

        con = TestDataFactory.createContact();

        subPlan = Test_SubscriptionPlan_Trigger.createRow();
        subPlan.OrderApi__Business_Group__c = businessGroups[0].Id;
        insert subPlan;

        pMethod = new OrderApi__Payment_Method__c();
        pMethod.OrderApi__Contact__c = con.Id;
        pMethod.OrderApi__Account__c = con.AccountId;
        pMethod.OrderApi__Full_Name__c = 'Test User';
        pMethod.OrderApi__Is_Active__c = true;
        pMethod.OrderApi__Is_Declined__c = false;
        pMethod.OrderApi__Is_Expired__c = false;
        pMethod.OrderApi__Is_Valid__c = true;
        pMethod.OrderApi__Number__c = '4111111111111111';
        pMethod.OrderApi__Payment_Method_Token__c = '';
        pMethod.OrderApi__Payment_Method_Type__c = '';
        pMethod.OrderApi__Card_Type__c = 'VISA';
        pMethod.OrderApi__Month__c = 01;
        pMethod.OrderApi__Year__c = Date.Today().Year() + 5 ;
        insert pMethod;

        itmClass = new OrderApi__Item_Class__c();
        itmClass.Name = 'Test Class';
        itmClass.OrderApi__Is_Active__c = false;
        itmClass.OrderApi__Business_Group__c = businessGroups[0].Id;
        itmClass.OrderApi__Enable_Assignments__c = false;
        itmClass.OrderApi__Is_Subscription__c = true;
        itmClass.OrderApi__Assignment_SObject__c = 'TEST__C';
        insert itmClass;

        OrderApi__Assignment_Role__c ar = new OrderApi__Assignment_Role__c();
        ar.Name = 'Role1';
        ar.OrderApi__Item_Class__c = itmClass.Id;
        ar.OrderApi__Is_Active__c = true;
        ar.OrderApi__Is_Default__c = true;
        ar.OrderApi__Receives_Email_Notifications__c = true;
        ar.OrderApi__Is_Primary__c = true;
        ar.OrderApi__Description__c = 'test description...';
        insert ar;

        itmClass.OrderApi__Is_Active__c = true;
        itmClass.OrderApi__Enable_Assignments__c = true;
        update itmClass;

        itm = new OrderApi__Item__c();
        itm.Name = 'test';
        itm.OrderApi__Price__c = 1;
        itm.OrderApi__Item_Class__c = itmClass.Id;
        itm.OrderApi__Business_Group__c = businessGroups[0].Id;
        itm.OrderApi__Is_Subscription__c = true;
        itm.OrderApi__Is_Active__c = false;
        insert itm;
    }

    @isTest
    static void testSubscriptionShare () {

        buildData();

        OrderApi__Subscription__c sub = new OrderApi__Subscription__c();
        sub.OrderApi__Payment_Method__c = pMethod.Id;
        sub.OrderApi__Subscription_Plan__c = subPlan.Id;
        sub.OrderApi__Business_Group__c = businessGroups[0].Id;
        sub.OrderApi__Contact__c = con.Id;
        sub.OrderApi__Item__c = itm.Id;
        sub.OrderApi__Item_Class__c = itmClass.Id;
        sub.OrderApi__Is_Active__c = true;
        sub.OrderApi__Status__c = 'Active';
        sub.OrderApi__Subscription_Plan__c = subPlan.Id;
        sub.OrderApi__Activated_Date__c = Date.today();

        insert sub;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Subscription__Share WHERE ParentId = :sub.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

        // updates
        sub.OrderApi__Business_Group__c = businessGroups[1].Id;
        update sub;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Subscription__Share WHERE ParentId = :sub.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);
    }
}