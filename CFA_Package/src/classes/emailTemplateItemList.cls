public class emailTemplateItemList {
    private List<OrderApi__Invoice_Line__c> invoiceLines;
    private List<OrderApi__Invoice__c> invoice;
    private List<OrderApi__Sales_Order__c> salesOrder;
    public Id SalesorderId {get; set;}
    
    // will save receipt ID
    public string receiptId {get; set;}

    public emailTemplateItemList() {
        
    }

    
    public List<displayReceiptLines> getItems(){
        
        List<displayReceiptLines> lstWrapper = new List<displayReceiptLines>();
        
        // saving invoice ids as its will be used to get invoice lines
        set<id> invoiceIDs = new set<id>();
        
        // get receipt items
        if(!string.isEmpty(receiptId)){
            for(OrderApi__Receipt_Line__c recLine : [SELECT Id,
                                                                OrderApi__Item__r.Name,
                                                                OrderApi__Sale_Price__c,
                                                                OrderApi__Quantity__c,
                                                                OrderApi__Invoice__c  
                                                            FROM OrderApi__Receipt_Line__c
                                                            WHERE OrderApi__Receipt__c =: receiptId]){
                
                // saving if the line is not of invoice type
                if(recLine.OrderApi__Invoice__c == null){
                    displayReceiptLines obj = new displayReceiptLines();
                    obj.isInvoice = false;
                    obj.receiptLine = recLine;
                    
                    // adding to main list
                    lstWrapper.add(obj);
                }
                else{
                    invoiceIDs.add(recLine.OrderApi__Invoice__c);
                }
            }
            
            // code to get invoice details
            for(OrderApi__Invoice_Line__c invLine : [SELECT Id,
                                                                OrderApi__Item__r.Name,
                                                                OrderApi__Sale_Price__c,
                                                                OrderApi__Quantity__c
                                                            FROM OrderApi__Invoice_Line__c
                                                            WHERE OrderApi__Invoice__c IN: invoiceIDs]){
                
                displayReceiptLines obj = new displayReceiptLines();
                obj.isInvoice = true;
                obj.invoiceLines = invLine;
                
                // adding to main list
                lstWrapper.add(obj);
            }
        }
        return lstWrapper;
        
    }
    
    /**
    public List<OrderApi__Invoice_Line__c> getinvoiceLines() {
    
        invoice = [SELECT Id 
                          FROM OrderApi__Invoice__c 
                          WHERE OrderApi__Sales_Order__c =: SalesorderId 
                          LIMIT 1];
        
        invoiceLines = [SELECT OrderApi__Item__r.Name,
                               OrderApi__Quantity__c,
                               OrderApi__Sale_Price__c
                               FROM OrderApi__Invoice_Line__c
                               WHERE OrderApi__Invoice__r.id IN :invoice];
        return invoiceLines;
    }
    **/
    
    public class displayReceiptLines{
        public OrderApi__Receipt_Line__c receiptLine {get;set;}
        public OrderApi__Invoice_Line__c invoiceLines {get;set;}
        public boolean isInvoice {get;set;}
        
        public displayReceiptLines(){
            this.receiptLine = new OrderApi__Receipt_Line__c();
            this.invoiceLines = new OrderApi__Invoice_Line__c();
            this.isInvoice = false;
        }
    }
}