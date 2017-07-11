/**
 *
 * Test class for the SalesOrder_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
private class Test_SalesOrder_Trigger {

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
    static void testSalesOrderShare () {

        buildData();

        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c();
        so.OrderApi__Business_Group__c = businessGroups[0].Id;

        insert so;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Sales_Order__Share WHERE ParentId = :so.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);
        
        // updates
        so.OrderApi__Business_Group__c = businessGroups[1].Id;
        update so;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Sales_Order__Share WHERE ParentId = :so.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

    }
}