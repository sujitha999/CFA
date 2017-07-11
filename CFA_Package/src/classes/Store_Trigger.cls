/**
 *
 * Domain class for the OrderApi__Store__c SObjectType
 * @author Vishal Shah
 *
 **/

global class Store_Trigger extends Framework.Domain{

    static RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.OrderApi__Store__Share.getName(), 
            SObjectType.OrderApi__Store__c.fields.OrderApi__Business_Group__c.getName(), 
            PackageUtils.SHARINGCAUSE);
    static String className = Store_Trigger.class.getName();

    public Store_Trigger(List<OrderApi__Store__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new Store_Trigger(sObjectList);
        }
    }

    public override void beforeInsert() {
        Framework.Log.push(className,'beforeInsert');
        StoreService.setDefaults((OrderApi__Store__c[]) records);
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

    public override void afterUpdate(Map<Id, SObject> oldMap) {
        Framework.Log.push(className,'afterUpdate');
        MapParentChildFields.updateRelaltedItems(oldMap, records, SObjectType.OrderApi__Store__c.fields.OrderApi__Business_Group__c.getName());
        Framework.Log.pop(); 
    }

}