/**
 *
 * Domain class for the EventApi__Event_Category__c SObjectType
 * @author Vishal Shah
 * 
 **/

global class EventCategory_Trigger extends Framework.Domain{

    static RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.EventApi__Event_Category__Share.getName(), 
            SObjectType.EventApi__Event_Category__c.fields.EventApi__Business_Group__c.getName(), 
            PackageUtils.SHARINGCAUSE);
    static String className = EventCategory_Trigger.class.getName();
    
    public EventCategory_Trigger(List<EventApi__Event_Category__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new EventCategory_Trigger(sObjectList);
        }
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