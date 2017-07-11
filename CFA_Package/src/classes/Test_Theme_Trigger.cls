/**
 *
 * Test class for the Theme_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
private class Test_Theme_Trigger {

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
    static void testThemeShare () {

        buildData();

        PagesApi__Theme__c thm = new PagesApi__Theme__c();
        thm.Name = 'Theme 1';
        thm.BusinessGroup__c = businessGroups[0].Id;

        insert thm;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM PagesApi__Theme__Share WHERE ParentId = :thm.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

        thm.BusinessGroup__c = businessGroups[1].Id;
        update thm;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM PagesApi__Theme__Share WHERE ParentId = :thm.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);
    }
}