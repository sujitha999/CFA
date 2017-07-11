/**
 *
 * Test class for the Receipt_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
private class Test_Receipt_Trigger {

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
    static void testReceiptShare () {

        buildData();

        OrderApi__Receipt__c rpt = new OrderApi__Receipt__c();
        rpt.OrderApi__Business_Group__c = businessGroups[0].Id;

        insert rpt;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Receipt__Share WHERE ParentId = :rpt.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

        // updates
        rpt.OrderApi__Business_Group__c = businessGroups[1].Id;

        update rpt;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Receipt__Share WHERE ParentId = :rpt.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

    }
}