public without sharing class TXWR_ProcessSOL {

    public TXWR_ProcessSOL(){
        
    }
    
    public static void insertConditions(SObject[] records){
        
        Set<Id> ids = new Set<Id>();     //Set of Ids to send to taxware request testMethod
        Id defConId = [SELECT Id FROM Contact WHERE FirstName = 'Fonteva' AND LastName = 'Default Contact' LIMIT 1].Id;   //querying default contact
        List<OrderApi__Sales_Order_Line__c> lstSOL = new List<OrderApi__Sales_Order_Line__c>();   //initializing a list of SOLs
        Set<Id> setSO = new Set<Id>();
        List<OrderApi__Sales_Order__c> lstSO = new List<OrderApi__Sales_Order__c>();
        Boolean isBillingAddressEmpty = false;
        
        lstSOL = [SELECT Id, OrderApi__Contact__c, OrderApi__Sales_Order__r.Taxware_SO__c, OrderApi__Item__r.Tax_With_Taxware__c FROM OrderApi__Sales_Order_Line__c WHERE Id IN: records];
        
        for(OrderApi__Sales_Order_Line__c sol : lstSOL){
            if(sol.OrderApi__Contact__c != NULL && sol.OrderApi__Contact__c != defConId){   //checking if contact is not defaul contact
                if(sol.OrderApi__Item__r.Tax_With_Taxware__c == TRUE){                      //checking if item is taxable by taxware
                    setSO.add(sol.OrderApi__Sales_Order__c);
                    ids.add(sol.Id);
                }
            }
        }
        for(OrderApi__Sales_Order__c so : [SELECT Id, 
                                                  Taxware_SO__c,
                                                  OrderApi__Billing_Country__c
                                                  FROM OrderApi__Sales_Order__c
                                                  WHERE Id IN: setSO]){
            so.Taxware_SO__c = TRUE;
            lstSO.add(so);
            
            if(string.isEmpty(so.OrderApi__Billing_Country__c)){
                isBillingAddressEmpty = TRUE;
            }
        }
        update lstSO;
        if(!ids.isEmpty() && !isBillingAddressEmpty) {    
            TXWR_CalloutClass.salesOrderCallout(ids, false);
        }
    }
    
    public static void updateConditions(Map<Id, SObject> oldMap, SObject[] records){
        
        Set<Id> ids = new Set<Id>();                                                                //Set of Ids to send to taxware request testMethod
        Id defConId = [SELECT Id FROM Contact WHERE FirstName = 'Fonteva' AND LastName = 'Default Contact' LIMIT 1].Id;   //querying default contact
        List<OrderApi__Sales_Order_Line__c> lstSOL = new List<OrderApi__Sales_Order_Line__c>();   //initializing a list of SOLs updated
        List<OrderApi__Sales_Order_Line__c> solLst = new List<OrderApi__Sales_Order_Line__c>();   //initializing a list of sibling SOLs 
        List<OrderApi__Sales_Order_Line__c> lstSOLdel = new List<OrderApi__Sales_Order_Line__c>();  //initializing a list of SOLs to be deleted
        Set<Id> SOIds = new Set<Id>();                                                              //initializing a set of parent SOs
        Set<Id> setSOIds = new Set<Id>();
        List<OrderApi__Sales_Order__c> lstSO = new List<OrderApi__Sales_Order__c>();
        Boolean isBillingAddressEmpty = false;
        
        lstSOL = [SELECT Id, OrderApi__Sales_Order__c, OrderApi__Contact__c, OrderApi__Item__r.Tax_With_Taxware__c FROM OrderApi__Sales_Order_Line__c WHERE Id IN: records];
        
        for(OrderApi__Sales_Order_Line__c sol : lstSOL){
            SOIds.add(sol.OrderApi__Sales_Order__c);
        }
        
        for(OrderApi__Sales_Order_Line__c sol : [SELECT Id,                                     //getting all child SOLs
                                                        OrderApi__Sale_Price__c,
                                                        OrderApi__Contact__c,
                                                        OrderApi__Item__r.Tax_With_Taxware__c,
                                                        OrderApi__Is_Tax__c,
                                                        OrderApi__Sales_Order__c
                                                        FROM OrderApi__Sales_Order_Line__c
                                                        WHERE OrderApi__Sales_Order__c IN: SOIds]){
            if(sol.OrderApi__Is_Tax__c == TRUE){
                lstSOLdel.add(sol);                                 //adding tax SOLs to be deleted
            } else {
                solLst.add(sol);                                   //adding non-tax SOLs 
            }                                                  
        }
        
        for(OrderApi__Sales_Order_Line__c sol : solLst){
            if(sol.OrderApi__Sale_Price__c != oldMap.get(string.valueOf(sol.get('Id'))).get('OrderApi__Sale_Price__c')){
                if(sol.OrderApi__Contact__c != NULL && sol.OrderApi__Contact__c != defConId){
                    if(sol.OrderApi__Item__r.Tax_With_Taxware__c == TRUE){
                        ids.add(sol.Id);                                       //adding non-tax SOLs to be sent to taxware 
                        setSOIds.add(sol.OrderApi__Sales_Order__c);
                    }
                }
            }
        }
        
        if(!setSOIds.isEmpty()){
            for(OrderApi__Sales_Order__c so : [SELECT Id,
                                                      OrderApi__Processing_Changes__c,
                                                      OrderApi__Billing_Country__c
                                                      FROM OrderApi__Sales_Order__c
                                                      WHERE Id IN: setSOIds]){
                so.OrderApi__Processing_Changes__c = TRUE;
                lstSO.add(so);
                
                if(string.isEmpty(so.OrderApi__Billing_Country__c)){
                    isBillingAddressEmpty = TRUE;
                }                                                    
            }
            update lstSO;
        }
        if(!lstSOLdel.isEmpty() && !ids.isEmpty()){
            delete lstSOLdel;               //deleting all child SOLs which are tax
        }
        
        if(!ids.isEmpty() && !isBillingAddressEmpty) {    
            TXWR_CalloutClass.salesOrderCallout(ids, false);
        }
    }
}