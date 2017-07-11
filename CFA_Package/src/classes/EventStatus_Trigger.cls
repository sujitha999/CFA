/**
 *
 * Domain class for the EventApi__Event_Status__c SObjectType
 * @author Nikilesh Kopparthi
 *
 **/

global class EventStatus_Trigger extends Framework.Domain{

    static RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.EventApi__Event_Status__Share.getName(), 
            SObjectType.EventApi__Event_Status__c.fields.Business_Group__c.getName(), 
            PackageUtils.SHARINGCAUSE);
    static String className = EventStatus_Trigger.class.getName();

    public EventStatus_Trigger(List<EventApi__Event_Status__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new EventStatus_Trigger(sObjectList);
        }
    }

    public override void beforeInsert() {
        Framework.Log.push(className,'beforeInsert');
        MapParentChildFields.setDefaults(records, SObjectType.EventApi__Event_Status__c.fields.EventApi__Event__c.getName(), SObjectType.EventApi__Event__c.getName(), SObjectType.EventApi__Event__c.fields.EventApi__Business_Group__c.getName(), SObjectType.EventApi__Event_Status__c.fields.Business_Group__c.getName());
        Framework.Log.pop();
    }

    public override void afterInsert(){
        Framework.Log.push(className,'afterInsert');
        rss.ShareWithGroup(records);
        Framework.Log.pop();
    }

    public override void beforeUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(className,'beforeUpdate');
        rss.UnshareAndshareWithGroup(oldMap, records, true);
        Framework.Log.pop();
    }

}