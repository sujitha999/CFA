/**
 *
 * Test class for the SponsorPackage_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
public class Test_SponsorPackage_Trigger {

    static OrderApi__Business_Group__c[] businessGroups = new OrderApi__Business_Group__c[]{};
    static Group[] groups = new Group[]{};

    @testSetup
    static void setupTest() {
        //Data Setup
        TestDataFactory.testInstall();
        TestDataFactory.sharingSetup();
    }

    static void buildData() {
        if(businessGroups.isEmpty()) {
            Map<String, SObject[]> testData = TestDataFactory.buildData();
            businessGroups = (OrderApi__Business_Group__c[])testData.get(TestDataFactory.BUSINESSGROUPLABEL);
            groups = (Group[])testData.get(TestDataFactory.PUBLICGROUPLABEL);
        }
    }

    public static EventApi__Sponsor_Package__c createRow() {
        

        EventApi__Sponsor_Package__c spp = new EventApi__Sponsor_Package__c();
        
        spp.Name = 'Test Sponsor Package';
        spp.EventApi__Price__c = 100.00;
        spp.EventApi__Quantity_Available__c = 100;
        spp.EventApi__Quantity_Sold__c = 10;
        spp.EventApi__Enable_Access_Permissions__c = true;
        spp.EventApi__Image_Path__c = 'www.salesforce.com';
        spp.EventApi__Cost__c = 100.00;
        return spp;
    }

    @isTest
    static void testSponsorPackageShare () {

        buildData();

        EventApi__Event_Category__c cat = Test_EventCategory_Trigger.createRow();
        cat.EventApi__Business_Group__c = businessGroups[0].Id;
        insert cat;
        
        EventApi__Event__c ev = Test_Event_Trigger.createRow();
        ev.EventApi__Business_Group__c = businessGroups[0].Id;
        ev.EventApi__Event_Category__c = cat.Id;
        insert ev;

        EventApi__Sponsor_Package__c sprPckg = createRow();
        sprPckg.EventApi__Event__c = ev.Id;
        sprPckg.EventApi__Event_Category__c = ev.EventApi__Event_Category__c;
        
        insert sprPckg;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel, RowCause 
            FROM EventApi__Sponsor_Package__Share 
            WHERE ParentId = :sprPckg.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

        ev.EventApi__Business_Group__c = businessGroups[1].Id;

        update ev;

        /*TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel, RowCause
            FROM EventApi__Sponsor_Package__Share 
            WHERE ParentId = :sprPckg.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);*/

    }

    @isTest
    static void testSponsorPackageBusinessGroupMatchesEvent () {

        buildData();
        
        EventApi__Event_Category__c cat = Test_EventCategory_Trigger.createRow();
        cat.EventApi__Business_Group__c = businessGroups[0].Id;
        insert cat;
        
        EventApi__Event__c ev = Test_Event_Trigger.createRow();
        ev.EventApi__Business_Group__c = businessGroups[0].Id;
        ev.EventApi__Event_Category__c = cat.Id;
        insert ev;

        EventApi__Sponsor_Package__c sprPckg = createRow();
        sprPckg.EventApi__Event__c = ev.Id;
        sprPckg.EventApi__Event_Category__c = ev.EventApi__Event_Category__c;
        
        insert sprPckg;

        SObject insertedRec = new Framework.Selector(EventApi__Sponsor_Package__c.SObjectType).selectById(sprPckg.Id);

        System.assertEquals(ev.EventApi__Business_Group__c, insertedRec.get(SObjectType.EventApi__Sponsor_Package__c.fields.EventApi__Business_Group__c.getName()));

        ev.EventApi__Business_Group__c = businessGroups[1].Id;

        update ev;

        insertedRec = new Framework.Selector(EventApi__Sponsor_Package__c.SObjectType).selectById(sprPckg.Id);

        //System.assertEquals(ev.EventApi__Business_Group__c, insertedRec.get(SObjectType.EventApi__Sponsor_Package__c.fields.EventApi__Business_Group__c.getName()));

    }
}