/**
 *
 * Test class for the Store_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
public class Test_Store_Trigger {

    static OrderApi__Business_Group__c[] businessGroups = new OrderApi__Business_Group__c[]{};
    static Group[] groups = new Group[]{};
    static OrderApi__Payment_Gateway__c pg;

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

    public static OrderApi__Store__c createRow() {

        PagesApi__Theme__c theme = new PagesApi__Theme__c();
        theme.Name = 'testTheme';
        insert theme;
        
        pg = new OrderApi__Payment_Gateway__c();
        pg.OrderApi__Business_Group__c = businessGroups[0].Id;
        pg.OrderApi__Is_Enabled__c = true;
        pg.OrderApi__Token__c = 'EBVTQugrEH4PuvRLEkatnBttqrf';
        pg.OrderApi__Gateway_Type__c = 'Test';
        insert pg;

        OrderApi__Store__c stre = new OrderApi__Store__c();
        stre.Name = 'Dummy Store';
        stre.OrderApi__Theme__c = theme.Id;
        stre.OrderApi__Gateway__c = pg.Id;

        return stre;

    }

    @isTest
    static void testStoreShare () {

        buildData();

        OrderApi__Store__c stre = createRow();
        stre.OrderApi__Business_Group__c = businessGroups[0].Id;

        insert stre;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Store__Share WHERE ParentId = :stre.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

        pg.OrderApi__Business_Group__c = businessGroups[1].Id;
        update pg;

        stre.OrderApi__Business_Group__c = businessGroups[1].Id;

        update stre;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Store__Share WHERE ParentId = :stre.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

    }

    @isTest
    static void testStorePaymentSaveFlag () {

        buildData();

        OrderApi__Store__c stre = createRow();
        stre.OrderApi__Business_Group__c = businessGroups[0].Id;

        insert stre;

        OrderApi__Store__c store = [SELECT Id, OrderApi__Enable_Guest_Save_Payment__c FROM OrderApi__Store__c WHERE Id = :stre.Id];

        System.assertEquals(false, store.OrderApi__Enable_Guest_Save_Payment__c);

    }
}