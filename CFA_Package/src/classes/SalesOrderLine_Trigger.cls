/**
 *
 * Domain class for the OrderApi__Sales_Order_Line__c SObjectType
 * @author Nikilesh Kopparthi
 *
 **/

global without Sharing class SalesOrderLine_Trigger extends Framework.Domain{

    public SalesOrderLine_Trigger(OrderApi__Sales_Order_Line__c[] sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(SObject[] sObjectList) {
            return new SalesOrderLine_Trigger(sObjectList);
        }
    }

    public override void afterInsert(){
        Framework.Log.push(SalesOrderLine_Trigger.class.getName(),'afterInsert');    
        if(TXWR_TriggerHelper.runSOLAfterInsert){
            TXWR_TriggerHelper.runSOLAfterInsert = false;
            TXWR_ProcessSOL.insertConditions(records);
            Framework.Log.pop();           
        }
    }
    
    public override void AfterUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(SalesOrderLine_Trigger.class.getName(),'beforeUpdate');
        if(TXWR_TriggerHelper.runSOLBeforeUpdate){
            TXWR_TriggerHelper.runSOLBeforeUpdate = false;
            TXWR_ProcessSOL.updateConditions(oldMap, records);
            Framework.Log.pop();
        }
    }

    public override void beforeUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(SalesOrderLine_Trigger.class.getName(),'beforeUpdate');
        Framework.Log.pop();
    }
    
    public override void beforeInsert(){
        Framework.Log.push(SalesOrderLine_Trigger.class.getName(),'beforeInsert');
        Framework.Log.pop();
    }
    
    public override void afterDelete(){
        Framework.Log.push(SalesOrderLine_Trigger.class.getName(),'afterDelete');
        Framework.Log.pop();
    }

}