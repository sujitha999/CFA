/**
 *
 * Domain class for the OrderApi__Item_Class__c SObjectType
 * @author Vishal Shah
 *
 **/

global class ItemClass_Trigger extends Framework.Domain{

    static RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.OrderApi__Item_Class__Share.getName(), 
            SObjectType.OrderApi__Item_Class__c.fields.OrderApi__Business_Group__c.getName(), 
            PackageUtils.SHARINGCAUSE);
    static String className = ItemClass_Trigger.class.getName();

    public ItemClass_Trigger(List<OrderApi__Item_Class__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new ItemClass_Trigger(sObjectList);
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