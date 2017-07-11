/**
 *
 * Test class for the Sponsor_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
public class Test_Sponsor_Trigger {

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

    public static EventApi__Sponsor__c createRow() {
        Contact con = TestDataFactory.createContact();

        EventApi__Event_Category__c cat = Test_EventCategory_Trigger.createRow();
        cat.EventApi__Business_Group__c = businessGroups[0].Id;
        insert cat;

        ev = Test_Event_Trigger.createRow();
        ev.EventApi__Business_Group__c = businessGroups[0].Id;
        ev.EventApi__Event_Category__c = cat.Id;
        insert ev;


        EventApi__Sponsor_Package__c sprPckg = Test_SponsorPackage_Trigger.createRow();
        sprPckg.EventApi__Event__c = ev.Id;
        sprPckg.EventApi__Event_Category__c = ev.EventApi__Event_Category__c;
        
        insert sprPckg;

        EventApi__Sponsor__c sp = new EventApi__Sponsor__c();
        sp.Name = 'Test Sponsor Name'; 
        sp.EventApi__Description__c = 'Test Description';
        sp.EventApi__Event__c = sprPckg.EventApi__Event__c;
        sp.EventApi__Sponsor_Package__c = sprPckg.Id;
        sp.EventApi__Account__c = con.AccountId;
        sp.EventApi__Contact__c = con.Id;
        return sp;
    }


    @isTest
    static void testSponsorShare () {

        buildData();

        EventApi__Sponsor__c spnr = createRow();
        insert spnr;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel, RowCause FROM EventApi__Sponsor__Share WHERE ParentId = :spnr.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

        ev.EventApi__Business_Group__c = businessGroups[1].Id;
        update ev;

        //TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel, RowCause FROM EventApi__Sponsor__Share WHERE ParentId = :spnr.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

    }

    @isTest
    static void testSponsorBusinessGroupMatchesEvent () {

        buildData();

        EventApi__Sponsor__c spnr = createRow();
        insert spnr;

        SObject insertedRec = new Framework.Selector(EventApi__Sponsor__c.SObjectType).selectById(spnr.Id);

        System.assertEquals(ev.EventApi__Business_Group__c, insertedRec.get(SObjectType.EventApi__Sponsor__c.fields.BusinessGroup__c.getName()));

        ev.EventApi__Business_Group__c = businessGroups[1].Id;
        update ev;

        insertedRec = new Framework.Selector(EventApi__Sponsor__c.SObjectType).selectById(spnr.Id);

        //System.assertEquals(ev.EventApi__Business_Group__c, insertedRec.get(SObjectType.EventApi__Sponsor__c.fields.BusinessGroup__c.getName()));

    }
}