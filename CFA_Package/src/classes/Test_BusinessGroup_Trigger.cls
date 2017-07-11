/**
 *
 * Test class for the BusinessGroup_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
private class Test_BusinessGroup_Trigger {

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
    static void testBusinessGroupShare () {
        buildData();

        OrderApi__Business_Group__c bg = businessGroups[0];

        TestDataFactory.sharingAssert( [SELECT ParentId, UserOrGroupId, AccessLevel, RowCause FROM OrderApi__Business_Group__Share WHERE ParentId = :bg.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

        bg.SystemPublicGroupId__c = businessGroups[1].SystemPublicGroupId__c;

        update bg;

        TestDataFactory.sharingAssert( [SELECT ParentId, UserOrGroupId, AccessLevel, RowCause FROM OrderApi__Business_Group__Share WHERE ParentId = :bg.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

    }

    @isTest
    static void testInvalidBusinessGroupPublicGroupId () {
        OrderApi__Business_Group__c bg = new OrderApi__Business_Group__c(Name = 'Test', SystemPublicGroupId__c = 'sdf');
        TestDataFactory.dbInsert(bg, 'Public Group Id is invalid');
    }
}