/**
 *
 * Domain class for the EventApi__Event_Page_Component__c SObjectType
 * @author Nikilesh Kopparthi
 *
 **/

global class EventPageComponent_Trigger extends Framework.Domain{

    static RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.EventApi__Event_Page_Component__Share.getName(), 
            SObjectType.EventApi__Event_Page_Component__c.fields.Business_Group__c.getName(), 
            PackageUtils.SHARINGCAUSE);
    static String className = EventPageComponent_Trigger.class.getName();

    public EventPageComponent_Trigger(List<EventApi__Event_Page_Component__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new EventPageComponent_Trigger(sObjectList);
        }
    }

    public override void beforeInsert() {
        Framework.Log.push(className,'beforeInsert');
        MapParentChildFields.setDefaults(records, SObjectType.EventApi__Event_Page_Component__c.fields.EventApi__Event_Page__c.getName(), SObjectType.EventApi__Event_Page__c.getName(), SObjectType.EventApi__Event_Page__c.fields.Business_Group__c.getName(), SObjectType.EventApi__Event_Page_Component__c.fields.Business_Group__c.getName());
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