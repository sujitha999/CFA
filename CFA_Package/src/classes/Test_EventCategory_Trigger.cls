/**
 *
 * Test class for the EventCategory_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
public class Test_EventCategory_Trigger {

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

    public static EventApi__Event_Category__c createRow() {
        EventApi__Event_Category__c cat = new EventApi__Event_Category__c();
        cat.Name = 'Test Event Category';
        //cat.EventApi__Background_Color__c = 'Green';
        //cat.EventApi__Foreground_Color__c = 'Green';
        cat.EventApi__Description__c = 'Test Desc';
        cat.EventApi__Enable_Access_Permissions__c = true;
        cat.EventApi__Enable_Registration_Groups__c = true;
        cat.EventApi__Enable_Sponsors__c = true;
        //cat.EventApi__Organizer_Description__c = 'Test Org Desc';
        //cat.EventApi__Organizer_Name__c = 'Test Org Name';
        //cat.EventApi__Registration_Group_Type__c = 'Group';
        cat.EventApi__Registration_Instructions__c = 'Test Instructions';
        cat.EventApi__Registration_Style__c = 'Box Office';
        //cat.EventApi__Registration_Type__c = 'Ticket';
        //cat.EventApi__Topic__c = 'Airlines';
        cat.EventApi__Capacity__c = 100;
        //cat.EventApi__Type__c = 'Award Ceremony';

        return cat;
    }

    @isTest
    static void testEventCategoryShare () {

        buildData();

        EventApi__Event_Category__c cat = createRow();
        cat.EventApi__Business_Group__c = businessGroups[0].Id;

        insert cat;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel, RowCause FROM EventApi__Event_Category__Share WHERE ParentId = :cat.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);
        
        // updates
        cat.EventApi__Business_Group__c = businessGroups[1].Id;

        update cat;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel, RowCause FROM EventApi__Event_Category__Share WHERE ParentId = :cat.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

    }
}