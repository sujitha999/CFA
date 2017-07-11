public without sharing class TXWR_ProcessSO {
    
    public TXWR_ProcessSO(){
        
    }
    
    public static void beforeUpdateConditions(List<OrderApi__Sales_Order__c> lstRecs, map<id,OrderApi__Sales_Order__c> mapOldRec){
        
        for(OrderApi__Sales_Order__c so : lstRecs){
            String newBillingStreet;
            if(so.OrderApi__Billing_Street__c != NULL) {
                newBillingStreet = so.OrderApi__Billing_Street__c.replaceAll('\r\n', ' ');
            } else {
                newBillingStreet = NULL;
            }
            String newBillingCity = so.OrderApi__Billing_City__c;
            String newBillingState = so.OrderApi__Billing_State__c;
            String newBillingCountry = so.OrderApi__Billing_Country__c;
            String newBillingZip = so.OrderApi__Billing_Postal_Code__c;
            
            String oldBillingStreet;
            if(mapOldRec.get(so.Id).OrderApi__Billing_Street__c != NULL) {
                oldBillingStreet = mapOldRec.get(so.Id).OrderApi__Billing_Street__c.replaceAll('\r\n', ' ');
            } else {
                oldBillingStreet = NULL;
            }
            String oldBillingCity = mapOldRec.get(so.Id).OrderApi__Billing_City__c;
            String oldBillingState = mapOldRec.get(so.Id).OrderApi__Billing_State__c;
            String oldBillingCountry = mapOldRec.get(so.Id).OrderApi__Billing_Country__c;
            String oldBillingZip = mapOldRec.get(so.Id).OrderApi__Billing_Postal_Code__c;
            
            if(so.Taxware_SO__c == TRUE){
                if(newBillingStreet != oldBillingStreet || newBillingCity != oldBillingCity || newBillingState != oldBillingState || newBillingZip != oldBillingZip || newBillingCountry != oldBillingCountry){
                    so.OrderApi__Processing_Changes__c = TRUE;
                }
            }
        }
    }

    public static void updateConditions(List<OrderApi__Sales_Order__c> lstRecs, map<id,OrderApi__Sales_Order__c> mapOldRec){
        
        List<OrderApi__Sales_Order__c> lstSOaddChange = new List<OrderApi__Sales_Order__c>();               //List of SOLs when SO.Address changed
        List<OrderApi__Sales_Order__c> lstSOposted = new List<OrderApi__Sales_Order__c>();                  //List of SOLs when SO.Posted = true
        List<OrderApi__Sales_Order_Line__c> lstSOLparent = new List<OrderApi__Sales_Order_Line__c>();       //List of parent SOLS when SO.Address changed
        List<OrderApi__Sales_Order_Line__c> lstSOLtax = new List<OrderApi__Sales_Order_Line__c>();          //List of tax SOLs when SO.Address changed
        List<OrderApi__Sales_Order_Line__c> lstSOLpar = new List<OrderApi__Sales_Order_Line__c>();          //List of parent SOLs when SO.Posted = true
        List<OrderApi__Sales_Order__c> lstPrcsng = new List<OrderApi__Sales_Order__c>();                    //List of SOs to flag as processing
        Set<Id> idsaddChange = new Set<Id>();
        Set<Id> idsPosted = new Set<Id>();
        Boolean isBillingAddressEmpty = false;
        
        for(OrderApi__Sales_Order__c so : lstRecs){
            String newBillingStreet;
            if(so.OrderApi__Billing_Street__c != NULL) {
                newBillingStreet = so.OrderApi__Billing_Street__c.replaceAll('\r\n', ' ');
            } else {
                newBillingStreet = NULL;
            }
            String newBillingCity = so.OrderApi__Billing_City__c;
            String newBillingState = so.OrderApi__Billing_State__c;
            String newBillingCountry = so.OrderApi__Billing_Country__c;
            String newBillingZip = so.OrderApi__Billing_Postal_Code__c;
            Boolean newPostedStatus = so.OrderApi__Is_Posted__c;
            
            String oldBillingStreet;
            if(mapOldRec.get(so.Id).OrderApi__Billing_Street__c != NULL) {
                oldBillingStreet = mapOldRec.get(so.Id).OrderApi__Billing_Street__c.replaceAll('\r\n', ' ');
            } else {
                oldBillingStreet = NULL;
            }
            String oldBillingCity = mapOldRec.get(so.Id).OrderApi__Billing_City__c;
            String oldBillingState = mapOldRec.get(so.Id).OrderApi__Billing_State__c;
            String oldBillingCountry = mapOldRec.get(so.Id).OrderApi__Billing_Country__c;
            String oldBillingZip = mapOldRec.get(so.Id).OrderApi__Billing_Postal_Code__c;
            Boolean oldPostedStaus = mapOldRec.get(so.Id).OrderApi__Is_Posted__c;
            
            if(so.Taxware_SO__c == TRUE){
                //Checking for change in Sales Order's billing address
                if(newBillingStreet != oldBillingStreet || newBillingCity != oldBillingCity || newBillingState != oldBillingState || newBillingZip != oldBillingZip || newBillingCountry != oldBillingCountry){
                    lstSOaddChange.add(so);
                }
                //Checking if the Sales Order posted
                if(newPostedStatus != oldPostedStaus && newPostedStatus == TRUE){
                    lstSOposted.add(so);
                }
                
                if(string.isEmpty(so.OrderApi__Billing_Country__c)){
                    isBillingAddressEmpty = TRUE;
                }
            }
        }
        
        //For address change scenario, getting the parent and tax SOLs
        if(!lstSOaddChange.isEmpty()){
            lstSOLparent = [SELECT Id FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Is_Tax__c = FALSE AND OrderApi__Item__r.Tax_With_Taxware__c = TRUE AND OrderApi__Sales_Order__c IN: lstSOaddChange];
            lstSOLtax = [SELECT ID FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Is_Tax__c = TRUE AND OrderApi__Sales_Order_Line__c != NULL AND OrderApi__Sales_Order__c IN: lstSOaddChange];
        }
        
        //In the address change scenario checking if tax SOLs exist, and if they do deleting them
        if(!lstSOLtax.isEmpty()){
            delete lstSOLtax;
        }
        
        //In the address change scenario checking if parent non-tax SOLs exist and adding them to the set to sent to taxware
        if(!lstSOLparent.isEmpty()){
            for(OrderApi__Sales_Order_Line__c sol : lstSOLparent){
                idsaddChange.add(sol.Id);
            }
        }
        
        //If the SO gets posted, getting all parent non-tax SOLs
        if(!lstSOPosted.isEmpty()){
            lstSOLpar = [SELECT Id FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Is_Tax__c = FALSE AND OrderApi__Item__r.Tax_With_Taxware__c = TRUE AND OrderApi__Sales_Order__c IN: lstSOposted];
        }
        
        //If parent non-tax SOLs with a taxware Item exist for the posted SO
        if(!lstSOLpar.isEmpty()){
            for(OrderApi__Sales_Order_Line__c sol : lstSOLPar){
                idsPosted.add(sol.Id);
            }
        }
        
        //Making the appropriate taxware callout
        if(!idsaddChange.isEmpty() && !isBillingAddressEmpty){
            TXWR_CalloutClass.salesOrderCallout(idsaddChange, false);
        } else if(!idsPosted.isEmpty() && !isBillingAddressEmpty){
            TXWR_CalloutClass.salesOrderCallout(idsPosted, true);
        }
    }
}