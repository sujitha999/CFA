/**
 *
 * Test class for the Venue_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
private class Test_Venue_Trigger {

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

    public static EventApi__Venue__c createRow() {
        EventApi__Event_Category__c cat = Test_EventCategory_Trigger.createRow();
        cat.EventApi__Business_Group__c = businessGroups[0].Id;
        insert cat;

        ev = Test_Event_Trigger.createRow();
        ev.EventApi__Business_Group__c = businessGroups[0].Id;
        ev.EventApi__Event_Category__c = cat.Id;
        insert ev;

        EventApi__Venue__c vn = new EventApi__Venue__c();
        vn.EventApi__Event__c = ev.Id;
        vn.Name = 'Test Venue';
        //vn.EventApi__Capacity__c = '0-49';
        //vn.EventApi__Type__c = 'Church';
        return vn;
    }

    @isTest
    static void testVenueShare () {

        buildData();

        EventApi__Venue__c ven = createRow();
        insert ven;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM EventApi__Venue__Share WHERE ParentId = :ven.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

        ev.EventApi__Business_Group__c = businessGroups[1].Id;
        update ev;

        //TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM EventApi__Venue__Share WHERE ParentId = :ven.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);
    }

    @isTest
    static void testVenueBusinessGroupMatchesEvent () {

        buildData();

        EventApi__Venue__c ven = createRow();
        insert ven;

        SObject insertedRec = new Framework.Selector(EventApi__Venue__c.SObjectType).selectById(ven.Id);

        System.assertEquals(ev.EventApi__Business_Group__c, insertedRec.get(SObjectType.EventApi__Venue__c.fields.BusinessGroup__c.getName()));

        ev.EventApi__Business_Group__c = businessGroups[1].Id;
        update ev;

        insertedRec = new Framework.Selector(EventApi__Venue__c.SObjectType).selectById(ven.Id);

        //System.assertEquals(ev.EventApi__Business_Group__c, insertedRec.get(SObjectType.EventApi__Venue__c.fields.BusinessGroup__c.getName()));
    }
}