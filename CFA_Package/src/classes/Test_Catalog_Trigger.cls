/**
 *
 * Test class for the Catalog_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
private class Test_Catalog_Trigger {

    static OrderApi__Business_Group__c[] businessGroups = new OrderApi__Business_Group__c[]{};
    static Group[] groups = new Group[]{};
    static OrderApi__Payment_Gateway__c pg;
    static OrderApi__Store__c st;

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

    public static OrderApi__Catalog__c createRow() {
        
        PagesApi__Theme__c theme = new PagesApi__Theme__c();
        theme.Name = 'testTheme';
        insert theme;
        
        pg = new OrderApi__Payment_Gateway__c();
        pg.OrderApi__Business_Group__c = businessGroups[0].Id;
        pg.OrderApi__Is_Enabled__c = true;
        pg.OrderApi__Token__c = 'EBVTQugrEH4PuvRLEkatnBttqrf';
        pg.OrderApi__Gateway_Type__c = 'Test';
        insert pg;

        st = new OrderApi__Store__c();
        st.OrderApi__Enable_Access_Permissions__c = false;
        st.OrderApi__Description__c = 'custom description for store';
        st.OrderApi__Theme__c = theme.Id;
        st.OrderApi__Gateway__c = pg.Id;
        st.OrderApi__Business_Group__c = businessGroups[0].Id;
        insert st;

        OrderApi__Catalog__c cat = new OrderApi__Catalog__c();
        cat.OrderApi__Is_Published__c = true;
        cat.OrderApi__Store__c = st.Id;
        return cat;
    }

    @isTest
    static void testCatalogShare () {

        buildData();

        OrderApi__Catalog__c ctlg = createRow();
        insert ctlg;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Catalog__Share WHERE ParentId = :ctlg.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

        st.OrderApi__Business_Group__c = businessGroups[1].Id;
        pg.OrderApi__Business_Group__c = businessGroups[1].Id;
        update pg;
        update st;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Catalog__Share WHERE ParentId = :ctlg.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

    }

    @isTest
    static void testCatalogBusinessGroupMatchesStore () {

        buildData();

        OrderApi__Catalog__c ctlg = createRow();
        insert ctlg;

        SObject insertedRec = new Framework.Selector(OrderApi__Catalog__c.SObjectType).selectById(ctlg.Id);

        System.assertEquals(st.OrderApi__Business_Group__c, insertedRec.get(SObjectType.OrderApi__Catalog__c.fields.BusinessGroup__c.getName()));

        st.OrderApi__Business_Group__c = businessGroups[1].Id;
        pg.OrderApi__Business_Group__c = businessGroups[1].Id;
        update pg;
        update st;

        insertedRec = new Framework.Selector(OrderApi__Catalog__c.SObjectType).selectById(ctlg.Id);

        System.assertEquals(st.OrderApi__Business_Group__c, insertedRec.get(SObjectType.OrderApi__Catalog__c.fields.BusinessGroup__c.getName()));

    }
}