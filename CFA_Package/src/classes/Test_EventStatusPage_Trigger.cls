/**
 *
 * Test class for the EventStatusPage_Trigger Class
 * @author Nikilesh Kopparthi
 *
 **/

@isTest
public class Test_EventStatusPage_Trigger {

    static OrderApi__Business_Group__c[] businessGroups = new OrderApi__Business_Group__c[]{};
    static Group[] groups = new Group[]{};
    static EventApi__Event_Status__c es = new EVentApi__Event_Status__c();
    static EventApi__Event_Page__c ep = new EventApi__Event_Page__c();
    static EventApi__Event_Status_Page__c esp = new EventApi__Event_Status_Page__c();
    static EventApi__Ticket_Type__c tt = new EventApi__Ticket_Type__c();
    static EventApi__Event__c ev = new EventApi__Event__c();

    @testSetup
    static void setupTest() {
        //Data Setup
        TestDataFactory.testInstall();
        TestDataFactory.sharingSetup();
        // Create a routing rule 
        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule rule = new Framework.RoutingRule();
        rule.apexClass = EventStatusPage_Trigger.class.getName();
        rule.namespace = '';
        rule.isEnabled = true;
        rule.sObjectName = 'EventApi__Event_Status_Page__c';
        rule.executionOrder = 1;
        rules.add(rule);
        Framework.Config.push(rules);               
    }

    private static void buildData() {
        if(businessGroups.isEmpty()) {
            Map<String, SObject[]> testData = TestDataFactory.buildData();
            businessGroups = (OrderApi__Business_Group__c[])testData.get(TestDataFactory.BUSINESSGROUPLABEL);
            groups = (Group[])testData.get(TestDataFactory.PUBLICGROUPLABEL);
        }
    }

    public static EventApi__Event_Status_Page__c createRow() {
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
        
        es.EventApi__Enable_Transition_for_Status__c = FALSE;
        es.EventApi__Event__c = ev.id;
        es.EventApi__Is_Current_Status_for_Event__c = TRUE;
        es.EventApi__Is_Event_Published__c = TRUE;
        es.EventApi__Order__c = 1;
        insert es;
        
        ep.Event__c = ev.id;
        ep.EventApi__Navigation_Label__c = 'Test Label';
        ep.EventApi__Page_Name__c = 'Test Page';
        insert ep;
        
        esp.EventApi__Event_Page__c = ep.id;
        esp.EventApi__Event_Status__c = es.id;
        esp.EventApi__Is_Published__c = TRUE;
        esp.EventApi__Order__c = 1;
        return esp;
        
    }

    @isTest
    static void testEventStatusPage () {

        buildData();
        
        EventApi__Event_Status_Page__c espp = createRow();
        insert espp;
    }
}