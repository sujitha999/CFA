/**
 *
 * Test class for the MediaAsset_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
private class Test_MediaAsset_Trigger {

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
    static void testMediaAssetShare () {

        buildData();

        PagesApi__Media_Asset__c ma = new PagesApi__Media_Asset__c();
        ma.BusinessGroup__c = businessGroups[0].Id;
        ma.PagesApi__Filename__c = 'Test Name';
        ma.PagesApi__MIME_Type__c = 'JPEG';
        ma.PagesApi__Path__c = 'http://www.google.com';

        insert ma;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM PagesApi__Media_Asset__Share WHERE ParentId = :ma.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

        ma.BusinessGroup__c = businessGroups[1].Id;

        update ma;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM PagesApi__Media_Asset__Share WHERE ParentId = :ma.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

    }
}