/**
 *
 * Domain class for the EventApi__Schedule_Item__c SObjectType
 * @author Vishal Shah
 *
 **/

global class ScheduleItem_Trigger extends Framework.Domain{

    static final String bgFieldName = SObjectType.EventApi__Schedule_Item__c.fields.EventApi__Business_Group__c.getName();
    static final RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.EventApi__Schedule_Item__Share.getName(), 
            bgFieldName, 
            PackageUtils.SHARINGCAUSE);
    static final String className = ScheduleItem_Trigger.class.getName();

    public ScheduleItem_Trigger(EventApi__Schedule_Item__c[] sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(SObject[] sObjectList) {
            return new ScheduleItem_Trigger(sObjectList);
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