/**
 *
 * Domain class for the OrderApi__Subscription__c SObjectType
 * @author Vishal Shah
 *
 **/

global class Subscription_Trigger extends Framework.Domain{

    static final String bgFieldName = SObjectType.OrderApi__Subscription__c.fields.OrderApi__Business_Group__c.getName();
    static final RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.OrderApi__Subscription__Share.getName(), 
            bgFieldName, 
            PackageUtils.SHARINGCAUSE);
    static final String className = Subscription_Trigger.class.getName();

    public Subscription_Trigger(OrderApi__Subscription__c[] sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(SObject[] sObjectList) {
            return new Subscription_Trigger(sObjectList);
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