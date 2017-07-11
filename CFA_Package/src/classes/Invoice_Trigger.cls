/**
 *
 * Domain class for the OrderApi__Invoice__c SObjectType
 * @author Vishal Shah
 *
 **/

global class Invoice_Trigger extends Framework.Domain{

    final static String bgFieldName = SObjectType.OrderApi__Invoice__c.fields.OrderApi__Business_Group__c.getName(); 
    static RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.OrderApi__Invoice__Share.getName(), 
            bgFieldName, 
            PackageUtils.SHARINGCAUSE);
    static String className = Invoice_Trigger.class.getName();

    public Invoice_Trigger(OrderApi__Invoice__c[] sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(SObject[] sObjectList) {
            return new Invoice_Trigger(sObjectList);
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