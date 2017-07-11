/**
 *
 * Domain class for the EventApi__Speaker__c SObjectType
 * @author Vishal Shah
 *
 **/

global class Speaker_Trigger extends Framework.Domain{

    static final String bgFieldName = SObjectType.EventApi__Speaker__c.fields.BusinessGroup__c.getName();
    static final RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.EventApi__Speaker__Share.getName(), 
            bgFieldName, 
            PackageUtils.SHARINGCAUSE);
    static final String className = Speaker_Trigger.class.getName();

    public Speaker_Trigger(EventApi__Speaker__c[] sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(SObject[] sObjectList) {
            return new Speaker_Trigger(sObjectList);
        }
    }

    public override void beforeInsert() {
        Framework.Log.push(className,'beforeInsert');
        MapParentChildFields.setDefaults(records, SObjectType.EventApi__Speaker__c.fields.EventApi__Event__c.getName(), SObjectType.EventApi__Event__c.getName(), SObjectType.EventApi__Event__c.fields.EventApi__Business_Group__c.getName(), bgFieldName);
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