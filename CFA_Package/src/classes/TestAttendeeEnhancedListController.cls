@isTest 
public class TestAttendeeEnhancedListController
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
        
        EventApi__Attendee__c attendee = new EventApi__Attendee__c();
        attendee.EventApi__Event__c = evnt.Id;
        attendee.EventApi__Status__c = 'Invited';
        attendee.EventApi__Full_Name__c = 'Testing';
        attendee.EducationCreditEarned__c = True;
        insert attendee;
     }
     public static testmethod void saverecord()
     {
          EventApi__Event__c  evnt = [Select id from EventApi__Event__c];
          Test.startTest();

          PageReference testPage = Page.AttendeeList;
          testPage.getParameters().put('eid',evnt.Id);
          System.debug('evnt.Id::'+evnt.Id);
          Test.setCurrentPageReference(testPage);

          /*CheckoutController testCon = new CheckoutController();*/
        
        AttendeeEnhancedListController aecon =new AttendeeEnhancedListController();
        aecon.save();
        aecon.back();
        Test.stopTest();
    }
    public static testmethod void selectedAttendees()
    {
         EventApi__Event__c  evnt = [Select id from EventApi__Event__c];
         EventApi__Attendee__c attendee = [Select id from EventApi__Attendee__c];
        
        Test.startTest();

          PageReference testPage = Page.AttendeeList;
          testPage.getParameters().put('eid',evnt.Id);
          System.debug('evnt.Id::'+evnt.Id);
          Test.setCurrentPageReference(testPage);

          /*CheckoutController testCon = new CheckoutController();*/
        AttendeeEnhancedListController acon =new AttendeeEnhancedListController();
        AttendeeEnhancedListController.EAWrapper aecon =new AttendeeEnhancedListController.EAWrapper(attendee);
        String check = acon.fieldValue;
        acon.fieldValue = 'true';
        System.debug(' acon.fieldValue::'+ acon.fieldValue);
        
        System.debug(' acon.fieldToUpdate::'+ acon.fieldToUpdate);
        System.assert(check!=null,'not null string');
       
        acon.listEAW.get(0).isSelected=true;
        aecon.isSelected =true;
        acon.fieldToUpdate ='EducationCreditEarned__c';
        acon.selectedId = aecon.EA.Id;
        aecon.EA.EducationCreditEarned__c = false;
        aecon.EA = attendee;       
        PageReference testPage2 = acon.sync();
        acon.save();
        acon.back();
        Test.stopTest();
   }
        
}