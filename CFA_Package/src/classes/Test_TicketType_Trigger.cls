/**
 *
 * Test class for the TicketType_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
public class Test_TicketType_Trigger {

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

    public static EventApi__Ticket_Type__c createRow() {
        EventApi__Event_Category__c cat = Test_EventCategory_Trigger.createRow();
        cat.EventApi__Business_Group__c = businessGroups[0].Id;
        insert cat;

        ev = Test_Event_Trigger.createRow();
        ev.EventApi__Business_Group__c = businessGroups[0].Id;
        ev.EventApi__Event_Category__c = cat.Id;
        insert ev;

        EventApi__Ticket_Type__c tt = new EventApi__Ticket_Type__c();
        tt.EventApi__Event__c = ev.Id;
        //tt.EventApi__Event_Category__c = cat.Id;
        tt.Name = 'Test Item Name';
        tt.EventApi__UOM__c = 'Ticket';
        tt.EventApi__Price__c = 100.00;
        tt.EventApi__Cost__c = 100.00;
        tt.EventApi__Description__c = 'Test Description';
        tt.EventApi__Display_Available_Inventory__c = true;
        tt.EventApi__Early_Bird_End_Date__c = Date.today();
        tt.EventApi__Early_Bird_Price__c = 100.00;
        tt.EventApi__Enable_Access_Permissions__c = true;
        tt.EventApi__Enable_Early_Bird_Price__c = true;
        tt.EventApi__Enable_Onsite_Price__c = true;
        tt.EventApi__Inventory_Status__c = 'In-Stock';
        tt.EventApi__Is_Active__c = true;
        tt.EventApi__Is_Published__c = true;
        tt.EventApi__Is_Tax_Deductible__c = true;
        tt.EventApi__Onsite_Price__c = 100.00;
        //tt.EventApi__Price__c = 100.00;
        tt.EventApi__Quantity_Available__c = 100;
        tt.EventApi__Quantity_Sold__c = 100;
        return tt;
    }

    @isTest
    static void testTicketTypeShare () {

        buildData();

        EventApi__Ticket_Type__c tTyp = createRow();

        insert tTyp;

        /*TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel 
                        FROM EventApi__Ticket_Type__Share 
                        WHERE ParentId = :tTyp.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]
                        );*/

        ev.EventApi__Business_Group__c = businessGroups[1].Id;

        update ev;

        /*TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel 
                        FROM EventApi__Ticket_Type__Share 
                        WHERE ParentId = :tTyp.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]
                        );*/

    }

    @isTest
    static void testTicketTypeBusinessGroupMatchesEvent () {

        buildData();
        
        EventApi__Ticket_Type__c tTyp = createRow();

        insert tTyp;

        SObject insertedRec = new Framework.Selector(EventApi__Ticket_Type__c.SObjectType).selectById(tTyp.Id);

        System.assertEquals(ev.EventApi__Business_Group__c, insertedRec.get(SObjectType.EventApi__Ticket_Type__c.fields.BusinessGroup__c.getName()));

        ev.EventApi__Business_Group__c = businessGroups[1].Id;

        update ev;

        insertedRec = new Framework.Selector(EventApi__Ticket_Type__c.SObjectType).selectById(tTyp.Id);

        //System.assertEquals(ev.EventApi__Business_Group__c, insertedRec.get(SObjectType.EventApi__Ticket_Type__c.fields.BusinessGroup__c.getName()));

    }
}