/**
 *
 * Test class for the SourceCode_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
private class Test_SourceCode_Trigger {

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
    static void testSourceCodeShare () {

        buildData();

        OrderApi__Source_Code__c sc = new OrderApi__Source_Code__c();
        sc.Name = 'Super Code';
        sc.OrderApi__Business_Group__c = businessGroups[0].Id;
        sc.OrderApi__Active__c = true;

        insert sc;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Source_Code__Share WHERE ParentId = :sc.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);
        
        // updates
        sc.OrderApi__Business_Group__c = businessGroups[1].Id;

        update sc;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Source_Code__Share WHERE ParentId = :sc.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);
    }
}