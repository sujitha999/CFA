/**
 *
 * Test class for the EventPage_Trigger Class
 * @author Nikilesh Kopparthi
 *
 **/

@isTest
public class Test_EventPage_Trigger {

    static OrderApi__Business_Group__c[] businessGroups = new OrderApi__Business_Group__c[]{};
    static Group[] groups = new Group[]{};
    static EventApi__Event_Page__c ep = new EventApi__Event_Page__c();
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
        rule.apexClass = EventPage_Trigger.class.getName();
        rule.namespace = '';
        rule.isEnabled = true;
        rule.sObjectName = 'EventApi__Event_Page__c';
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

    public static EventApi__Event_Page__c createRow() {
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
        
        ep.Event__c = ev.id;
        ep.EventApi__Navigation_Label__c = 'Test Label';
        ep.EventApi__Page_Name__c = 'Test Page';
        return ep;
        
    }

    @isTest
    static void testEventPage () {

        buildData();
        
        EventApi__Event_Page__c epp = createRow();
        insert epp;
    }
}