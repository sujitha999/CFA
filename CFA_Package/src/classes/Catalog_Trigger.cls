/**
 *
 * Domain class for the OrderApi__Catalog__c SObjectType
 * @author Vishal Shah
 *
 **/

global class Catalog_Trigger extends Framework.Domain{

    static RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.OrderApi__Catalog__Share.getName(), 
            SObjectType.OrderApi__Catalog__c.fields.BusinessGroup__c.getName(), 
            PackageUtils.SHARINGCAUSE);
    String className = Catalog_Trigger.class.getName();

    public Catalog_Trigger(List<OrderApi__Catalog__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new Catalog_Trigger(sObjectList);
        }
    }

    public override void beforeInsert() {
        Framework.Log.push(className,'beforeInsert');
        MapParentChildFields.setDefaults(records, SObjectType.OrderApi__Catalog__c.fields.OrderApi__Store__c.getName(), SObjectType.OrderApi__Store__c.getName(), SObjectType.OrderApi__Store__c.fields.OrderApi__Business_Group__c.getName(), SObjectType.OrderApi__Catalog__c.fields.BusinessGroup__c.getName());
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