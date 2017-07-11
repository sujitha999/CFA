/**
 *
 * Test class for the CampaignPage_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
private class Test_CampaignPage_Trigger {

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
    static void testCampaignPageShare () {

        buildData();

        OrderApi__Payment_Gateway__c gateway = new OrderApi__Payment_Gateway__c(
            OrderApi__Business_Group__c = businessGroups[0].Id,
            OrderApi__Is_Enabled__c = true,
            OrderApi__Token__c = 'EBVTQugrEH4PuvRLEkatnBttqrf',
            OrderApi__Gateway_Type__c = 'Test');
        
        insert gateway;

        PagesApi__Theme__c theme = new PagesApi__Theme__c(
            Name = 'testTheme');
        insert theme;

        OrderApi__Store__c store = new OrderApi__Store__c(
            Name = 'Test',
            OrderApi__Business_Group__c = businessGroups[0].Id,
            OrderApi__Gateway__c = gateway.Id,
            OrderApi__Theme__c = theme.Id);

        insert store;

        PagesApi__Site__c siteObj = new PagesApi__Site__c(
            Name = 'Test',
            OrderApi__Business_Group__c = businessGroups[0].Id,
            PagesApi__Is_Published__c = true,
            PagesApi__Site_Url__c = 'https://www.google.com',
            OrderApi__Store__c = store.Id,
            PagesApi__Theme__c = theme.id);
        
        insert siteObj;

        OrderApi__Campaign_Page__c campaignPage = new OrderApi__Campaign_Page__c();
        campaignPage.OrderApi__Shopping_Cart_Enabled__c = true;
        campaignPage.OrderApi__Store__c = store.Id;
        campaignPage.OrderApi__Business_Group__c = businessGroups[0].Id;

        insert campaignPage;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel, RowCause FROM OrderApi__Campaign_Page__Share WHERE ParentId = :campaignPage.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

        gateway.OrderApi__Business_Group__c = businessGroups[1].Id;

        update gateway;

        store.OrderApi__Business_Group__c = businessGroups[1].Id;

        update store;

        siteObj.OrderApi__Business_Group__c = businessGroups[1].Id;

        update siteObj;

        campaignPage.OrderApi__Business_Group__c = businessGroups[1].Id;

        update campaignPage;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel, RowCause FROM OrderApi__Campaign_Page__Share WHERE ParentId = :campaignPage.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

    }
}