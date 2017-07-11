/**
 *
 * Test class for the Site_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
private class Test_Site_Trigger {

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
    static void testSiteShare () {

        buildData();

        PagesApi__Theme__c t = new PagesApi__Theme__c();
        t.Name = 'TEST THEME';
        insert t;

        PagesApi__Site__c s = new PagesApi__Site__c();
        s.Name = 'TEST SITE';
        s.PagesApi__Theme__c = t.Id;
        s.PagesApi__Site_URL__c = 'https://test.site.url';
        s.OrderApi__Business_Group__c = businessGroups[0].Id;
        insert s;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM PagesApi__Site__Share WHERE ParentId = :s.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);
        
        // updates
        s.OrderApi__Business_Group__c = businessGroups[1].Id;

        update s;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM PagesApi__Site__Share WHERE ParentId = :s.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

    }
}