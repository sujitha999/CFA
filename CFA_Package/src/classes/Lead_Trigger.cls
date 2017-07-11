/**
 *
 * Domain class for the Lead SObjectType
 * @author Nikilesh Kopparthi
 *
 **/

global class Lead_Trigger extends Framework.Domain{

    static final String bgFieldName = SObjectType.Lead.fields.CFAMN__Business_Group__c.getName();
    static final RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.LeadShare.getName(), 
            bgFieldName, 
            Schema.LeadShare.RowCause.Manual,
            SObjectType.LeadShare.fields.LeadId.getName(),
            SObjectType.Lead.fields.Id.getName(),
            SObjectType.LeadShare.fields.LeadAccessLevel.getName(),
            new Map<String,String>());
    static final String className = Lead_Trigger.class.getName();

    public Lead_Trigger(Lead[] sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(SObject[] sObjectList) {
            return new Lead_Trigger(sObjectList);
        }
    }

    public override void beforeInsert(){
        Framework.Log.push(className,'beforeInsert');
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

    public override void afterUpdate(Map<Id,SObject> oldMap) {
        Framework.Log.push(className,'afterUpdate');
        Framework.Log.pop();
    }

}