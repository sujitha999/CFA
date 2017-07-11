/**
 *
 * Test class for the Speaker_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
public class Test_Speaker_Trigger {

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

    public static EventApi__Speaker__c createRow() {
        EventApi__Event_Category__c cat = Test_EventCategory_Trigger.createRow();
        cat.EventApi__Business_Group__c = businessGroups[0].Id;

        insert cat;

        ev = Test_Event_Trigger.createRow();
        ev.EventApi__Business_Group__c = businessGroups[0].Id;
        ev.EventApi__Event_Category__c = cat.Id;

        insert ev;

        

        EventApi__Speaker__c sp = new EventApi__Speaker__c();
        sp.Name = 'Test Speaker';
        //sp.EventApi__Expertise_Topic__c = 'Aging';
        sp.EventApi__Status__c = 'Invited';
        //sp.EventApi__Agreement_Status__c = 'Sent';
        //sp.EventApi__Agreement_Signed_Date__c = Date.today();
        //sp.EventApi__Speaking_Fee__c = 100.00;
        //sp.EventApi__Invited_Date__c = Date.today();
        //sp.EventApi__Date_Declined__c = Date.today();
        sp.EventApi__Company_Name__c = 'Test Account Name';
        sp.EventApi__Title__c = 'Test Title';
        sp.EventApi__Email__c = 'test@fonteva.com';
        sp.EventApi__Bio__c = 'Test Bio';
        sp.EventApi__Special_Requests__c = 'Test Special Requests';
        sp.EventApi__Phone__c = '29082982373';
        sp.EventApi__Other_Phone__c = '392348493287';
        //sp.EventApi__Assistant_Name__c = 'Test Assistant Name';
        //sp.EventApi__Assistant_Email__c = 'test@salesforce.com';
        sp.EventApi__Event__c = ev.Id;
        return sp;
    }

    @isTest
    static void testSpeakerShare () {

        buildData();

        EventApi__Speaker__c spkr = createRow();
        insert spkr;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel 
                        FROM EventApi__Speaker__Share 
                        WHERE ParentId = :spkr.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]
                        );

        ev.EventApi__Business_Group__c = businessGroups[1].Id;
        update ev;

        /*TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel 
                        FROM EventApi__Speaker__Share 
                        WHERE ParentId = :spkr.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]
                        );*/

    }

    @isTest
    static void testSpeakerBusinessGroupMatchesEvent () {

        buildData();
        
        EventApi__Speaker__c spkr = createRow();
        insert spkr;

        SObject insertedRec = new Framework.Selector(EventApi__Speaker__c.SObjectType).selectById(spkr.Id);

        System.assertEquals(ev.EventApi__Business_Group__c, insertedRec.get(SObjectType.EventApi__Speaker__c.fields.BusinessGroup__c.getName()));

        ev.EventApi__Business_Group__c = businessGroups[1].Id;
        update ev;

        insertedRec = new Framework.Selector(EventApi__Speaker__c.SObjectType).selectById(spkr.Id);

        //System.assertEquals(ev.EventApi__Business_Group__c, insertedRec.get(SObjectType.EventApi__Speaker__c.fields.BusinessGroup__c.getName()));

    }
}