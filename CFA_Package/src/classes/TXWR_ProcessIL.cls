/***
 * This class will be used to process Invoice with
 * taxware API
 */
public class TXWR_ProcessIL {

    
    /*****
     * This method will be called to pocess invoice line when 
     * new inclice lines are created and it has to be process with taxware
     */
    public static void insertConditions(SObject[] records){
        
        // will save set if record ids of order item
        set<string> setOI = new set<string>();
        
        // this will save records to be processed
        set<id> processIL = new set<id>();
        
        // getting record of each Invoice Line
        for(OrderApi__Invoice_Line__c il : (List<OrderApi__Invoice_Line__c>)records){
            if(il.OrderApi__Item__c != null){
                setOI.add(il.OrderApi__Item__c);
            }
        }
        
        map<string,OrderApi__Item__c> mapOrder = new map<string,OrderApi__Item__c>([SELECT Id,
                                                                                            Tax_With_Taxware__c
                                                                                        FROM OrderApi__Item__c
                                                                                        WHERE ID IN :setOI]);
        
        // getting record of each Invoice Line
        for(OrderApi__Invoice_Line__c il : (List<OrderApi__Invoice_Line__c>)records){
            
            if(mapOrder.containsKey(il.OrderApi__Item__c)){
                
                OrderApi__Item__c oi = mapOrder.get(il.OrderApi__Item__c);
                
                if(oi.Tax_With_Taxware__c == true 
                    && il.OrderApi__Is_Adjustment__c == true){
                    processIL.add(il.Id);
                }
            }
        }
        if(!processIL.isEmpty()){
            TXWR_CalloutClass.InvoiceLineCallout(processIL,false);
        }
    }
    
    
    
     /*****
     * This method will be called to pocess invoice line when 
     * new inclice lines are updated and it has to be process with taxware
     */
    public static void updateConditions(Map<Id, SObject> oldMap, SObject[] records){
        
        // will save set if record ids of order item
        set<string> setOI = new set<string>();
        
        // this will save records to be processed
        set<id> processIL = new set<id>();
        
        // this will save the ids of the Invoice related to invoice
        List<string> lstInv = new List<string>();
        
        // getting record of each Invoice Line
        for(OrderApi__Invoice_Line__c il : (List<OrderApi__Invoice_Line__c>)records){
            if(il.OrderApi__Item__c != null){
                setOI.add(il.OrderApi__Item__c);
                
                // saving invoice
                lstInv.add(il.OrderApi__Invoice__c);
            }
        }
        
        map<string,OrderApi__Item__c> mapOrder = new map<string,OrderApi__Item__c>([SELECT Id,
                                                                                            Tax_With_Taxware__c
                                                                                        FROM OrderApi__Item__c
                                                                                        WHERE ID IN :setOI]);
        
        // getting record of each Invoice Line
        for(OrderApi__Invoice_Line__c il : (List<OrderApi__Invoice_Line__c>)records){
            
            if(mapOrder.containsKey(il.OrderApi__Item__c )){
                
                OrderApi__Item__c oi = mapOrder.get(il.OrderApi__Item__c);
                OrderApi__Invoice_Line__c oldRec = (OrderApi__Invoice_Line__c) oldMap.get(il.Id);
                
        // getting the invoice lines whre order is taxware and adjust is true and salesforce price is changed
        if(oi.Tax_With_Taxware__c == true
          && il.OrderApi__Is_Adjustment__c == true
          && oldRec.OrderApi__Sale_Price__c != il.OrderApi__Sale_Price__c){
          
          processIL.add(il.Id);
        }
            }
        }
    
    // getting items to be deleted
    List<OrderApi__Invoice_Line__c> lstDel = [SELECT Id
                            FROM OrderApi__Invoice_Line__c
                            WHERE CFAMN__Parent_Invoice_Line__c IN :processIL];
        
        // checking if we have line to b eprocess with taxware then delete lines and make callout
        if(!processIL.isEmpty()){
      
      if(!lstDel.isEmpty()){
        delete lstDel;
      }
      
            // code to make callout
      TXWR_CalloutClass.InvoiceLineCallout(processIL,false);
        }
        
    }

}