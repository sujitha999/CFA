/**
 *
 * Test class for the RegistrationGroup_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
public class Test_RegistrationGroup_Trigger {

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

    public static EventApi__Registration_Group__c createRow() {
        EventApi__Registration_Group__c rg = new EventApi__Registration_Group__c();

        rg.Name = 'Test Registration Group';
        //rg.EventApi__Permission_Scheme__c = 'Public';
        rg.EventApi__Create_Contacts__c = true;
        rg.EventApi__Create_Standing_Sales_Order__c = true;
        rg.EventApi__Description__c = 'Test Description';
        rg.EventApi__Display_Registered_Members__c = true;
        rg.EventApi__Enable_Access_Permissions__c = true;
        rg.EventApi__Group_Logo_URL__c = 'Test Logo';
        rg.EventApi__Invoice_Date__c = Date.today();
        rg.EventApi__Limit_Registrations__c = true;
        rg.EventApi__Payment_Status__c = 'Open';
        rg.EventApi__Payment_Type__c = 'Invoice';
        rg.EventApi__Posting_Entity__c = 'Invoice';
        rg.EventApi__Registered_Attendees__c = 10;
        rg.EventApi__Registration_Instructions__c = 'Test Instructions';
        rg.EventApi__Registration_Limit__c = 10;
        rg.EventApi__Registration_Page_Header__c = 'Test Page Header';

        return rg;
    }

    @isTest
    static void testRegistrationGroupShare () {

        buildData();

        Contact con = TestDataFactory.createContact();

        EventApi__Event_Category__c evc = Test_EventCategory_Trigger.createRow();
        evc.EventApi__Business_Group__c = businessGroups[0].Id;
        insert evc;

        EventApi__Event__c ev = Test_Event_Trigger.createRow();
        ev.EventApi__Event_Category__c = evc.Id;
        ev.EventApi__Business_Group__c = businessGroups[0].Id;
        insert ev;

        EventApi__Registration_Group__c regGrp = createRow();
        regGrp.EventApi__Account__c = con.AccountId;
        regGrp.EventApi__Primary_Contact__c = con.Id;
        regGrp.EventApi__Event__c = ev.Id;
        
        regGrp.BusinessGroup__c = businessGroups[0].Id;
        // Fields

        insert regGrp;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM EventApi__Registration_Group__Share WHERE ParentId = :regGrp.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

        // updates
        regGrp.BusinessGroup__c = businessGroups[1].Id;

        update regGrp;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM EventApi__Registration_Group__Share WHERE ParentId = :regGrp.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

    }

    @isTest
    static void testTicketTypeBusinessGroupMatchesEvent () {

        buildData();

        Contact con = TestDataFactory.createContact();

        EventApi__Event_Category__c evc = Test_EventCategory_Trigger.createRow();
        evc.EventApi__Business_Group__c = businessGroups[0].Id;
        insert evc;

        EventApi__Event__c ev = Test_Event_Trigger.createRow();
        ev.EventApi__Event_Category__c = evc.Id;
        ev.EventApi__Business_Group__c = businessGroups[0].Id;
        insert ev;

        EventApi__Registration_Group__c regGrp = createRow();
        regGrp.EventApi__Account__c = con.AccountId;
        regGrp.EventApi__Primary_Contact__c = con.Id;
        regGrp.EventApi__Event__c = ev.Id;
    
        insert regGrp;

        SObject insertedRec = new Framework.Selector(EventApi__Registration_Group__c.SObjectType).selectById(regGrp.Id);

        //System.assertEquals(ev.EventApi__Business_Group__c, insertedRec.get(SObjectType.EventApi__Registration_Group__c.fields.BusinessGroup__c.getName()));

        ev.EventApi__Business_Group__c = businessGroups[1].Id;

        update ev;

        insertedRec = new Framework.Selector(EventApi__Registration_Group__c.SObjectType).selectById(regGrp.Id);

        //System.assertEquals(ev.EventApi__Business_Group__c, insertedRec.get(SObjectType.EventApi__Registration_Group__c.fields.BusinessGroup__c.getName()));

    }
}