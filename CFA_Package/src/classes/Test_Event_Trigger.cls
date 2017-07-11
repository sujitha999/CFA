/**
 *
 * Test class for the Event_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
public class Test_Event_Trigger {

    static OrderApi__Business_Group__c[] businessGroups = new OrderApi__Business_Group__c[]{};
    static Group[] groups = new Group[]{};
    static String timezone = 'America/Adak';

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

    public static EventApi__Event__c createRow() {

        EventApi__Event__c ev = new EventApi__Event__c();
        ev.Name = 'Test Event';
        ev.EventApi__Event_Key__c = 'ABCD';
        ev.EventApi__Start_Date_Time__c = Datetime.now();
        //ev.EventApi__Archived_Date__c = Date.today();
        ev.EventApi__Attendees__c = 10;
        //ev.EventApi__Cancelled_Date__c = Date.today();
        ev.EventApi__Capacity__c = 100;
        ev.EventApi__Description__c = 'Test Desc';
        ev.EventApi__Enable_Access_Permissions__c = false;
        //ev.EventApi__Enable_Community_Page__c = true;
        ev.EventApi__Enable_Registration_Groups__c = true;
        //ev.EventApi__Enable_Speakers_Page__c = true;
        //ev.EventApi__Enable_Sponsors_Page__c = true;
        ev.EventApi__Enable_Sponsors__c = true;
        ev.EventApi__Enable_Waitlist__c = true;
        //ev.EventApi__Enable_Website__c = true;
        ev.EventApi__Enable_Schedule_Items__c = true;
        ev.EventApi__End_Date_Time__c = Datetime.now().addDays(4);
        //ev.EventApi__Exhibitor_Revenue__c = 100.00;
        ev.EventApi__Is_Active__c = true;
        ev.EventApi__Is_Published__c = true;
        //ev.EventApi__Location_Information__c = 'Test Location Information';
        //ev.EventApi__Non_Ticket_Revenue__c = 100.00;
        //ev.EventApi__Organizer_Description__c = 'Test Description';
        //ev.EventApi__Organizer_Name__c = 'Test Organizer Name';
        //ev.EventApi__Published_Date__c = Date.today();
        //ev.EventApi__Registration_Group_Type__c = 'Group';
        ev.EventApi__Registration_Instructions__c = 'Test Instructions';
        ev.EventApi__Registration_Style__c = 'Conference';
        //ev.EventApi__Registration_Type__c = 'Ticket';
        //ev.EventApi__Speakers_Invited__c = 10;
        //ev.EventApi__Speakers__c = 10;
        //ev.EventApi__Sponsor_Revenue__c = 100.00;
        ev.EventApi__Status__c = 'Active';
        //ev.EventApi__Ticket_Revenue__c = 100.00;
        ev.EventApi__Ticket_Sales_Start_Date__c = Date.today();
        ev.EventApi__Time_Zone__c = '(GMT-09:00) '+timezone;
        ev.EventApi__Topic__c = 'Airlines';
        //ev.EventApi__Type__c = 'Attraction';
        //ev.EventApi__Venue_Name__c = 'Test Venue';
        ev.EventApi__Waitlist_Entries__c = 10;
        //ev.EventApi__Website_URL__c = 'www.salesforce.com';

        return ev;

    }

    @isTest
    static void testEventShare () {

        buildData();

        EventApi__Event_Category__c cat = Test_EventCategory_Trigger.createRow();
        cat.EventApi__Business_Group__c = businessGroups[0].Id;

        insert cat;

        EventApi__Event__c ev = createRow();
        ev.EventApi__Business_Group__c = businessGroups[0].Id;
        ev.EventApi__Event_Category__c = cat.Id;

        insert ev;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel, RowCause FROM EventApi__Event__Share WHERE ParentId = :ev.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

        ev.EventApi__Business_Group__c = businessGroups[1].Id;

        update ev;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel, RowCause FROM EventApi__Event__Share WHERE ParentId = :ev.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

    }
}