/**
 *
 * Domain class for the OrderApi__Batch__c SObjectType
 * @author Vishal Shah
 *
 **/

global class Batch_Trigger extends Framework.Domain{

    static final String bgFieldName = SObjectType.OrderApi__Batch__c.fields.OrderApi__Business_Group__c.getName();
    static final RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.OrderApi__Batch__Share.getName(), 
            bgFieldName, 
            PackageUtils.SHARINGCAUSE);
    static final String className = Batch_Trigger.class.getName();

    public Batch_Trigger(OrderApi__Batch__c[] sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(SObject[] sObjectList) {
            return new Batch_Trigger(sObjectList);
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