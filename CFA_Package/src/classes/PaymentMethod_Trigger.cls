/**
 *
 * Domain class for the OrderApi__Payment_Method__c SObjectType
 * @author Vishal Shah
 *
 **/

global class PaymentMethod_Trigger extends Framework.Domain{

    static RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.OrderApi__Payment_Method__Share.getName(), 
            SObjectType.OrderApi__Payment_Method__c.fields.BusinessGroup__c.getName(), 
            PackageUtils.SHARINGCAUSE);
    static String className = PaymentMethod_Trigger.class.getName();

    public PaymentMethod_Trigger(List<OrderApi__Payment_Method__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new PaymentMethod_Trigger(sObjectList);
        }
    }

    public override void afterInsert(){
        Framework.Log.push(className,'afterInsert');
        rss.ShareWithGroup(records);
        Framework.Log.pop();
    }

    public override void beforeUpdate(Map<Id, SObject> oldMap){
        Framework.Log.push(className,'beforeUpdate');
        rss.UnshareAndshareWithGroup(oldMap, records, true);
        Framework.Log.pop();
    }

}