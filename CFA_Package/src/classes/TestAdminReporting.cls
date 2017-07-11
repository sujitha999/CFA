@isTest 
public class TestAdminReporting
{
    @testSetup 
    public static void datasetup()
    {
        EventApi__Event__c  evnt = new EventApi__Event__c();
        evnt.Name = 'Testing Event';
        evnt.EventApi__Status__c = 'Planned';
        evnt.EventApi__Registration_Style__c =' Conference';
        evnt.EventApi__Event_Key__c = 'JSEVT14';
        insert evnt;
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'LastName';
        con.AccountId = acc.Id;
        insert con;
        
        EventApi__Attendee__c attendee = new EventApi__Attendee__c();
        attendee.EventApi__Event__c = evnt.Id;
        attendee.EventApi__Status__c = 'Invited';
        attendee.EventApi__Full_Name__c = 'Testing';
        attendee.EducationCreditEarned__c = True;
        attendee.EventApi__Contact__c = con.Id;
        insert attendee;
        
        EventApi__Venue__c venue = new EventApi__Venue__c();
        venue.Name='Hotel';
        venue.EventApi__Event__c = evnt.Id;
        venue.EventApi__City__c = 'Fairfax';
        venue.EventApi__State__c = 'VA';
        venue.EventApi__Country__c = 'USA';
        venue.EventApi__Postal_Code__c = '22030';
        venue.EventApi__Is_Primary_Venue__c = TRUE;
        insert venue;
     }
     public static testmethod void saverecord()
     {
          EventApi__Event__c  evnt = [Select id from EventApi__Event__c];
          Test.startTest();

          PageReference testPage = Page.AdminReporting;
          testPage.getParameters().put('id',evnt.Id);
          System.debug('evnt.Id::'+evnt.Id);
          Test.setCurrentPageReference(testPage);

                
        adminReporting admrp =new adminReporting();
        String testxml = admrp.xlsheader; 
        admrp.getAttendee();
        Test.stopTest();
    }
}