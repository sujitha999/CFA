/**
 *
 * Domain class for the OrderApi__Badge_Type__c SObjectType
 * @author Vishal Shah
 *
 **/

global class BadgeType_Trigger extends Framework.Domain{

    static RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.OrderApi__Badge_Type__Share.getName(), 
            SObjectType.OrderApi__Badge_Type__c.fields.BusinessGroup__c.getName(), 
            PackageUtils.SHARINGCAUSE);

    public BadgeType_Trigger(OrderApi__Badge_Type__c[] sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(SObject[] sObjectList) {
            return new BadgeType_Trigger(sObjectList);
        }
    }

    public override void afterInsert(){
        Framework.Log.push(BadgeType_Trigger.class.getName(),'afterInsert');
        rss.ShareWithGroup(records);
        Framework.Log.pop();
    }

    public override void beforeUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(BadgeType_Trigger.class.getName(),'beforeUpdate');
        rss.UnshareAndShareWithGroup(oldMap, records, true);
        Framework.Log.pop();
    }

}