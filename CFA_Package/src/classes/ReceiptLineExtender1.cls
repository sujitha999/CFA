@deprecated
global class ReceiptLineExtender1 extends Framework.Domain {
    
    //static final string ClassName = ReceiptLineExtender.class.getName();
    public ReceiptLineExtender1(List<OrderApi__Receipt_Line__c> sObjectList){
        super(sObjectList);
    }
    
    global class Constructor Implements Framework.Domain.DomainConstructor{
        global Framework.Domain construct(List<SObject> sobjectList){
            return new ReceiptLineExtender1(sobjectList);
        }
    }
    
    public override void afterUpdate(Map<Id,SObject> oldMap){
    }
    
    public override void afterinsert(){
    }
    
}