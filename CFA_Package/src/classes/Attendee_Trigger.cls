/**
 *
 * Domain class for the EventApi__Attendee__c SObjectType 
 * @author Vishal Shah
 *
 **/

global class Attendee_Trigger extends Framework.Domain{

    static final String className = Attendee_Trigger.class.getName();
    static final String refEventField = SObjectType.EventApi__Attendee__c.fields.EventApi__Event__c.getName();

    public Attendee_Trigger(EventApi__Attendee__c[] sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(SObject[] sObjectList) {
            return new Attendee_Trigger(sObjectList);
        }
    }

    public override void afterUpdate(Map<Id,SObject> oldMap){
        system.debug(LoggingLevel.INFO,'*****INSIDE AFTER UPDATE****');
        Framework.Log.push(className,'afterUpdate');
        AttendeeService.processEduCredits((Map<Id, EventApi__Attendee__c>) oldMap, (EventApi__Attendee__c[])records);
        attendeeCASLService.addCASLBadge((Map<Id, EventApi__Attendee__c>) oldMap, (EventApi__Attendee__c[])records);
        Framework.Log.pop();
    }
    
    public override void beforeUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(className,'beforeUpdate');
        attendeeCancellationAutomation.processCancellation((EventApi__Attendee__c[])records, (Map<Id, EventApi__Attendee__c>) oldMap);
        Framework.Log.pop();
    }
    
    public override void afterInsert(){
        Framework.Log.push(className,'afterInsert');
        Framework.Log.pop();
    }
    
    public override void beforedelete(){
        Framework.Log.push(className,'beforeDelete');
        Framework.Log.pop();
    }

}