/**
 *
 * Test class for the Batch_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
private class Test_Batch_Trigger {

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
    static void testBatchShare () {

        buildData();

        OrderApi__Batch__c b = new OrderApi__Batch__c();
        b.Name = 'Test';
        b.OrderApi__Business_Group__c = businessGroups[0].Id;
        b.OrderApi__Expected_Amount__c = 1;
        b.OrderApi__Expected_Count__c = 1;

        insert b;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Batch__Share WHERE ParentId = :b.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

        b.OrderApi__Business_Group__c = businessGroups[1].Id;

        update b;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Batch__Share WHERE ParentId = :b.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

    }
}