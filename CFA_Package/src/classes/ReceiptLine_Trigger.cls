global class ReceiptLine_Trigger extends Framework.Domain {
    
    //static final string ClassName = ReceiptLineExtender.class.getName();
    public ReceiptLine_Trigger(List<OrderApi__Receipt_Line__c> sObjectList){
        super(sObjectList);
    }
    
    global class Constructor Implements Framework.Domain.DomainConstructor{
        global Framework.Domain construct(List<SObject> sobjectList){
            return new ReceiptLine_Trigger(sobjectList);
        }
    }
    
    public override void afterUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(ReceiptLine_Trigger.class.getName(), 'afterUpdate');
        TXWR_ProcessRL.updateConditions((Map<Id, OrderApi__Receipt_Line__c>) oldMap, (OrderApi__Receipt_Line__c[]) records);
        Framework.Log.pop();
    }
    
    public override void afterinsert(){
        Framework.Log.push(ReceiptLine_Trigger.class.getName(), 'afterInsert');
        TXWR_ProcessRL.insertConditions(records);
        Framework.Log.pop();
    }
    
}