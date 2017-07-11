/**
 *
 * Test class for the MediaAssetCollection_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
private class Test_MediaAssetCollection_Trigger {

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
    static void testMediaAssetCollectionShare () {

        buildData();

        PagesApi__Media_Asset_Collection__c mac = new PagesApi__Media_Asset_Collection__c();
        mac.Name = 'Test';
        mac.BusinessGroup__c = businessGroups[0].Id;

        insert mac;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM PagesApi__Media_Asset_Collection__Share WHERE ParentId = :mac.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

        mac.BusinessGroup__c = businessGroups[1].Id;

        update mac;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM PagesApi__Media_Asset_Collection__Share WHERE ParentId = :mac.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

    }
}