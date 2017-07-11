/**
 *
 * Domain class for the OrderApi__Invoice_Line__c SObjectType
 * @author Nikilesh Kopparthi
 *
 **/

global class Invoice_Line_Trigger extends Framework.Domain{

    final static String bgFieldName = SObjectType.OrderApi__Invoice_Line__c.fields.OrderApi__Business_Group__c.getName(); 
    static String className = Invoice_Line_Trigger.class.getName();

    public Invoice_Line_Trigger(OrderApi__Invoice_Line__c[] sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(SObject[] sObjectList) {
            return new Invoice_Line_Trigger(sObjectList);
        }
    }

    public override void afterInsert(){
        Framework.Log.push(className,'afterInsert');
        TXWR_ProcessIL.insertConditions(records);
        Framework.Log.pop();
    }

    public override void beforeUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(className,'beforeUpdate');
        TXWR_ProcessIL.updateConditions(oldMap,records);
        Framework.Log.pop();
    }

}