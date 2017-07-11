/**
 *
 * Test class for the Vendor_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
public class Test_Vendor_Trigger {

    static OrderApi__Business_Group__c[] businessGroups = new OrderApi__Business_Group__c[]{};
    static Group[] groups = new Group[]{};
    static EventApi__Event__c ev;

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

    public static EventApi__Vendor__c createRow() {
        EventApi__Event_Category__c cat = Test_EventCategory_Trigger.createRow();
        cat.EventApi__Business_Group__c = businessGroups[0].Id;
        insert cat;

        ev = Test_Event_Trigger.createRow();
        ev.EventApi__Business_Group__c = businessGroups[0].Id;
        ev.EventApi__Event_Category__c = cat.Id;
        insert ev;

        EventApi__Vendor__c vnd = new EventApi__Vendor__c();
        vnd.EventApi__Event__c = ev.Id;
        vnd.Name = 'Test Vendor';
        vnd.EventApi__Type__c = 'Airline';
        return vnd;
    }

    @isTest
    static void testVendorShare () {

        buildData();

        EventApi__Vendor__c vdr = createRow();
        insert vdr;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM EventApi__Vendor__Share WHERE ParentId = :vdr.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

        ev.EventApi__Business_Group__c = businessGroups[1].Id;
        update ev;

        //TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM EventApi__Vendor__Share WHERE ParentId = :vdr.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

    }

    @isTest
    static void testVendorBusinessGroupMatchesEvent () {

        buildData();

        EventApi__Vendor__c vdr = createRow();
        insert vdr;

        SObject insertedRec = new Framework.Selector(EventApi__Vendor__c.SObjectType).selectById(vdr.Id);

        System.assertEquals(ev.EventApi__Business_Group__c, insertedRec.get(SObjectType.EventApi__Vendor__c.fields.BusinessGroup__c.getName()));

        ev.EventApi__Business_Group__c = businessGroups[1].Id;
        update ev;

        insertedRec = new Framework.Selector(EventApi__Vendor__c.SObjectType).selectById(vdr.Id);

        //System.assertEquals(ev.EventApi__Business_Group__c, insertedRec.get(SObjectType.EventApi__Vendor__c.fields.BusinessGroup__c.getName()));

    }
}