/**
 *
 * Test class for the TicketBlock_Trigger Class
 * @author Nikilesh Kopparthi
 *
 **/

@isTest
public class Test_TicketBlock_Trigger {

    static OrderApi__Business_Group__c[] businessGroups = new OrderApi__Business_Group__c[]{};
    static Group[] groups = new Group[]{};
    static EventApi__Ticket_Block__c tb = new EventApi__Ticket_Block__c();
    static EventApi__Ticket_Type__c tt = new EventApi__Ticket_Type__c();
    static EventApi__Event__c ev = new EventApi__Event__c();

    @testSetup
    static void setupTest() {
        //Data Setup
        TestDataFactory.testInstall();
        TestDataFactory.sharingSetup();
        // Create a routing rule 
        Framework.RegisteredObject[] rObjs = new List<Framework.RegisteredObject>();
        Framework.RegisteredObject rObj = new Framework.RegisteredObject();
        rObj.apexClass = TicketBlock_Trigger.class.getName();
        rObj.namespace = '';
        rObj.isEnabled = true;
        rObj.sObjectName = 'EventApi__Ticket_Block__c';
        rObj.SOQLLimit = '2000';
        rObj.SOQLOrderBy = 'Name ASC';
        rObj.triggersEnabled = true;
        rObjs.add(rObj);
        Framework.Config.push(rObjs);      
    }

    private static void buildData() {
        if(businessGroups.isEmpty()) {
            Map<String, SObject[]> testData = TestDataFactory.buildData();
            businessGroups = (OrderApi__Business_Group__c[])testData.get(TestDataFactory.BUSINESSGROUPLABEL);
            groups = (Group[])testData.get(TestDataFactory.PUBLICGROUPLABEL);
        }
    }

    public static EventApi__Ticket_Block__c createRow() {
        EventApi__Event_Category__c cat = Test_EventCategory_Trigger.createRow();
        cat.EventApi__Business_Group__c = businessGroups[0].Id;
        insert cat;

        ev = Test_Event_Trigger.createRow();
        ev.EventApi__Business_Group__c = businessGroups[0].Id;
        ev.EventApi__Event_Category__c = cat.Id;
        ev.EducationCreditValue__c = 3.00;
        ev.EventApi__Capacity__c = 100; 
        ev.EventApi__Quantity_Sold__c = 9;      
        insert ev;
        
        tb.Event__c = ev.id;
        tb.EventApi__Number_Of_Available_Tickets__c = 100;
        tb.EventApi__Ticket_Block_Name__c = 'Test Block';
        return tb;
        
    }

    @isTest
    static void testTicketBlock () {

        buildData();
        
        EventApi__Ticket_Block__c tbb = createRow();
        insert tbb;
    }
}