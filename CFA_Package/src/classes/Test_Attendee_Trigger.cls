/**
 *
 * Test class for the Attendee_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
public class Test_Attendee_Trigger {

    static OrderApi__Business_Group__c[] businessGroups = new OrderApi__Business_Group__c[]{};
    static Group[] groups = new Group[]{};
    static EventApi__Attendee__c at = new EventApi__Attendee__c();
    static EventApi__Ticket_Type__c tt = new EventApi__Ticket_Type__c();
    static EventApi__Event__c ev = new EventApi__Event__c();

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

    public static EventApi__Attendee__c createRow(integer cap, string status) {
        EventApi__Event_Category__c cat = Test_EventCategory_Trigger.createRow();
        cat.EventApi__Business_Group__c = businessGroups[0].Id;
        insert cat;

        ev = Test_Event_Trigger.createRow();
        ev.EventApi__Business_Group__c = businessGroups[0].Id;
        ev.EventApi__Event_Category__c = cat.Id;
        ev.EducationCreditValue__c = 3.00;
        ev.EventApi__Capacity__c = cap; 
        ev.EventApi__Quantity_Sold__c = 9;      
        insert ev;

        tt = new EventApi__Ticket_Type__c();
        tt.EventApi__Event__c = ev.Id;
        tt.EventApi__Event_Category__c = cat.Id;
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
        tt.EventApi__Price__c = 100.00;
        tt.EventApi__Quantity_Available__c = 100;
        tt.EventApi__Quantity_Sold__c = 100;
        insert tt;
        Contact c = TestDataFactory.createContact();
        at.EventApi__Contact__c = c.Id;
        at.EventApi__Ticket_Type__c = tt.Id;
        at.EventApi__Event__c = tt.EventApi__Event__c;
        at.EventApi__status__c = status;
        at.EventApi__Registration_Date__c = Date.today();
        at.EventApi__Full_Name__c = 'Test Full Name';
        return at;
    }

    @isTest
    static void testAttendeeEarnedCredit () {

        buildData();
        
        EventApi__Attendee__c att = createRow(1,'Registered');
        insert att;
    
        att.EducationCreditEarned__c = true;
        update att;     
        
    }
    
    @isTest
    static void testAttendeeEarnedCredit1 () {

        buildData();
        
        EventApi__Attendee__c att = createRow(4,'Registered');      
        insert att;
        
       
        /**
        EventApi__Event__c e = [select id,EventApi__Quantity_Sold__c,EventApi__Capacity__c from EventApi__Event__c ];
        system.debug('\n--e--'+e);
        e.EventApi__Quantity_Sold__c = 3;
        update e;
        **/
         
        att.EducationCreditEarned__c = true;
        att.EventApi__Status__c = 'Cancelled';
        update att;             
            
        
    }
    
    @isTest
    static void testAttendeeEarnedCredit2 () {

        buildData();
        
        EventApi__Attendee__c att = createRow(4,'Invited');     
        insert att;
        
       
        /**
        EventApi__Event__c e = [select id,EventApi__Quantity_Sold__c,EventApi__Capacity__c from EventApi__Event__c ];
        system.debug('\n--e--'+e);
        e.EventApi__Quantity_Sold__c = 3;
        update e;
        **/
         
        att.EducationCreditEarned__c = true;
        att.EventApi__Status__c = 'Registered';
        update att;             
            
        
    }
}