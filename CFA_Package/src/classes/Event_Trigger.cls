/**
 *
 * Domain class for the EventApi__Event__c SObjectType
 * @author Vishal Shah
 *
 **/

global without sharing class Event_Trigger extends Framework.Domain{

    static final String bgFieldName = SObjectType.EventApi__Event__c.fields.EventApi__Business_Group__c.getName();
    static final RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.EventApi__Event__Share.getName(), 
            bgFieldName, 
            PackageUtils.SHARINGCAUSE);
    static final String className = Event_Trigger.class.getName();

    public Event_Trigger(EventApi__Event__c[] sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(SObject[] sObjectList) {
            return new Event_Trigger(sObjectList);
        }
    }

    public override void beforeInsert(){
        Framework.Log.push(className,'beforeInsert');
        EventService.setDefaults((EventApi__Event__c[]) records);
        Framework.Log.pop();
    }
    
    public override void afterInsert(){
        Framework.Log.push(className,'afterInsert');
        rss.ShareWithGroup(records);
        Framework.Log.pop();
    }

    public override void beforeUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(className,'beforeUpdate');
        EventService.setDefaults((EventApi__Event__c[]) records);
        rss.UnshareAndshareWithGroup(oldMap, records, true);
        Framework.Log.pop();
    }

    public override void afterUpdate(Map<Id,SObject> oldMap) {
        Framework.Log.push(className,'afterUpdate');   
        if(!HelperVariables.isEventAfterUpdateExecuted){
            HelperVariables.isEventAfterUpdateExecuted = true;
            MapParentChildFields.updateRelaltedItems(oldMap, records, SObjectType.EventApi__Event__c.fields.EventApi__Business_Group__c.getName());
        }
        Framework.Log.pop();
    }

}