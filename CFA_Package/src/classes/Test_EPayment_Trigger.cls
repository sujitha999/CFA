/**
 *
 * Test class for the EPayment_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
private class Test_EPayment_Trigger {

    static OrderApi__Business_Group__c[] businessGroups = new OrderApi__Business_Group__c[]{};
    static Group[] groups = new Group[]{};
    static Account a;
    static Contact c;
    static OrderApi__GL_Account__c gla;
    static OrderApi__Payment_Gateway__c pg;
    static OrderApi__Payment_Method__c pMethod;
    static OrderApi__Invoice__c inv;
    static OrderApi__Item_Class__c itmc;
    static OrderApi__Item__c itm;
    static OrderApi__Invoice_Line__c il;


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

        c = TestDataFactory.createContact();

        gla = new OrderApi__GL_Account__c();
        gla.Name = 'GL Account';
        gla.OrderApi__Business_Group__c = businessGroups[0].Id;
        insert gla;

        pg = new OrderApi__Payment_Gateway__c();
        pg.Name = 'Test Gateway';
        pg.OrderApi__Business_Group__c = businessGroups[0].Id;
        insert pg;

        pMethod = new OrderApi__Payment_Method__c();
        pMethod.OrderApi__Contact__c = c.Id;
        pMethod.OrderApi__Account__c = c.AccountId;
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

        itmc = new OrderApi__Item_Class__c();
        itmc.Name = 'Test Class';
        itmc.OrderApi__Is_Active__c = true;
        itmc.OrderApi__Business_Group__c = businessGroups[0].Id;
        insert itmc;

        itm = new OrderApi__Item__c();
        itm.Name = 'test';
        itm.OrderApi__Price__c = 1;
        itm.OrderApi__Item_Class__c = itmc.Id;
        itm.OrderApi__Business_Group__c = businessGroups[0].Id;
        insert itm;

        inv = new OrderApi__Invoice__c();
        inv.OrderApi__Account__c = c.AccountId;
        inv.OrderApi__Contact__c = c.Id;
        inv.OrderApi__Business_Group__c = businessGroups[0].Id;
        insert inv;

        il = new OrderApi__Invoice_Line__c();
        il.OrderApi__Item__c = itm.Id;
        il.OrderApi__Sale_Price__c = 10;
        il.OrderApi__Invoice__c = inv.Id;
        il.OrderApi__Business_Group__c = businessGroups[0].Id;
        insert il;
    }

    @isTest
    static void testEPaymentShare () {

        buildData();

        OrderApi__EPayment__c epay = new OrderApi__EPayment__c();
        epay.OrderApi__Business_Group__c = businessGroups[0].Id;

        insert epay;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__EPayment__Share WHERE ParentId = :epay.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

        // updates
        gla.OrderApi__Business_Group__c = businessGroups[1].Id;
        update gla;

        pg.OrderApi__Business_Group__c = businessGroups[1].Id;
        update pg;

        itmc.OrderApi__Business_Group__c = businessGroups[1].Id;
        update itmc;

        itm.OrderApi__Business_Group__c = businessGroups[1].Id;
        update itm;

        inv.OrderApi__Business_Group__c = businessGroups[1].Id;
        update inv;

        il.OrderApi__Business_Group__c = businessGroups[1].Id;
        update il;

        epay.OrderApi__Business_Group__c = businessGroups[1].Id;
        update epay;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__EPayment__Share WHERE ParentId = :epay.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

    }

    @isTest
    static void testEPaymentDeleteTransactionDetails () {

        buildData();

        OrderApi__EPayment__c epay = new OrderApi__EPayment__c();
        epay.OrderApi__Business_Group__c = businessGroups[0].Id;

        insert epay;

        OrderApi__EPayment__c ep = [SELECT Id, OrderApi__Number__c FROM OrderApi__EPayment__c WHERE Id = :epay.Id LIMIT 1];

        System.assertEquals(null, ep.OrderApi__Number__c);

    }
}