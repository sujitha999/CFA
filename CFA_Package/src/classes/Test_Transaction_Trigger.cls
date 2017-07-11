/**
 *
 * Test class for the Transaction_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
private class Test_Transaction_Trigger {

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
    static void testTransactionShare () {

        buildData();

        OrderApi__Transaction__c trn = new OrderApi__Transaction__c();
        trn.OrderApi__Business_Group__c = businessGroups[1].Id;

        insert trn;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Transaction__Share WHERE ParentId = :trn.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

        trn.OrderApi__Business_Group__c = businessGroups[0].Id;

        update trn;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Transaction__Share WHERE ParentId = :trn.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

    }
}