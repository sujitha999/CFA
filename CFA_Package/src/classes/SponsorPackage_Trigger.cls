/**
 *
 * Domain class for the EventApi__Sponsor_Package__c SObjectType
 * @author Vishal Shah
 *
 **/

global class SponsorPackage_Trigger extends Framework.Domain{

    static final String bgFieldName = SObjectType.EventApi__Sponsor_Package__c.fields.EventApi__Business_Group__c.getName();
    static final RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.EventApi__Sponsor_Package__Share.getName(), 
            bgFieldName, 
            PackageUtils.SHARINGCAUSE);
    static final String className = SponsorPackage_Trigger.class.getName();

    public SponsorPackage_Trigger(EventApi__Sponsor_Package__c[] sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(SObject[] sObjectList) {
            return new SponsorPackage_Trigger(sObjectList);
        }
    }

    public override void beforeInsert() {
        Framework.Log.push(className,'beforeInsert');
        MapParentChildFields.setDefaults(records, SObjectType.EventApi__Sponsor_Package__c.fields.EventApi__Event__c.getName(), SObjectType.EventApi__Event__c.getName(), SObjectType.EventApi__Event__c.fields.EventApi__Business_Group__c.getName(), bgFieldName);
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