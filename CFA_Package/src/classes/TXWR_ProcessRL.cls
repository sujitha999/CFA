public without sharing class TXWR_ProcessRL {
    
    public TXWR_ProcessRL(){
        
    }

    public static void insertConditions(SObject [] records){
        Set<Id> parentRecipt = new Set<Id>();
        List<OrderApi__Receipt_Line__c> lstRLs = new List<OrderApi__Receipt_Line__c>();
        Set<Id> setRLs = new Set<Id>();
        List<OrderApi__Receipt__c> lstRecs = new List<OrderApi__Receipt__c>();

        for(SObject temp : records){
            setRLs.add(temp.Id);
        }

        lstRLs = [SELECT Id, OrderApi__Receipt__c, OrderApi__Item__r.Tax_With_Taxware__c FROM OrderApi__Receipt_Line__c WHERE Id IN: setRLs];

        for(OrderApi__Receipt_Line__c rl : lstRLs){
            if(rl.OrderApi__Item__r.Tax_With_Taxware__c == TRUE){
                parentRecipt.add(rl.OrderApi__Receipt__c);
            }
        }

        for(OrderApi__Receipt__c r : [SELECT Id, Taxware_RC__c FROM OrderApi__Receipt__c WHERE Id IN: parentRecipt]){
            r.Taxware_RC__c = TRUE;
            lstRecs.add(r);
        }
        update lstRecs;
    }
    
    public static void updateConditions(Map<Id, OrderApi__Receipt_Line__c> oldMap, OrderApi__Receipt_Line__c[] records){
        
        List<OrderApi__Receipt_Line__c> rlDel = new List<OrderApi__Receipt_Line__c>();
        List<OrderApi__Receipt_Line__c> rlNTax = new List<OrderApi__Receipt_Line__c>();
        List<OrderApi__Receipt__c> lstRcs = new List<OrderApi__Receipt__c>();
        List<OrderApi__Receipt__c> lstRs = new List<OrderApi__Receipt__c>();
        Set<Id> setRec = new Set<Id>();
        Set<Id> setRLs = new Set<Id>();
        Set<Id> setItem = new Set<Id>();
        Set<Id> setRCs = new Set<Id>();
        Map<Id, Id> mapRLItem = new Map<Id, Id>();
        Map<Id, OrderApi__Item__c> itmMap = new Map<Id, OrderApi__Item__c>();
        Map<Id, OrderApi__Item__c> mapRLItemInfo = new Map<Id, OrderApi__Item__c>();

        for(OrderApi__Receipt_Line__c rl : records){
            mapRLItem.put(rl.Id, rl.OrderApi__Item__c);
            setItem.add(rl.OrderApi__Item__c);
        }

        for(OrderApi__Item__c itm : [SELECT Id, Tax_With_Taxware__c FROM OrderApi__Item__c WHERE Id IN: setItem]){
            itmMap.put(itm.Id, itm);
        }

        for(OrderApi__Receipt_Line__c rl : records){
            mapRLItemInfo.put(rl.Id, itmMap.get(mapRLItem.get(rl.Id)));
        }

        for(OrderApi__Receipt_Line__c rl : records){
            
            Decimal oldSalePrice = oldMap.get(rl.Id).OrderApi__Sale_Price__c;
            Decimal newSalePrice = rl.OrderApi__Sale_Price__c;
            Boolean isTaxware = mapRLItemInfo.get(rl.Id).Tax_With_Taxware__c;
            
            if(rl.OrderApi__Is_Refund__c == TRUE && rl.OrderApi__Is_Tax__c == FALSE && oldSalePrice != newSalePrice && isTaxware){
                setRec.add(rl.OrderApi__Receipt__c);
            }

            for(OrderApi__Receipt__c r : [SELECT Id, Taxware_RC__c FROM OrderApi__Receipt__c WHERE Id IN: setRec]){
                r.Taxware_RC__c = TRUE;
                lstRcs.add(r);
            }
            update lstRcs;

            rlDel = [SELECT Id 
                            FROM OrderApi__Receipt_Line__c 
                            WHERE OrderApi__Is_Tax__c = TRUE 
                            AND OrderApi__Receipt_Line__c != NULL 
                            AND OrderApi__Receipt__c IN: setRec];
            
            rlNtax = [SELECT Id,
                             OrderApi__Receipt__c
                             FROM OrderApi__Receipt_Line__c
                             WHERE OrderApi__Is_Tax__c = FALSE
                             AND OrderApi__Receipt_Line__c = NULL
                             AND OrderApi__Receipt__c IN: setRec];
            
            if(!rlDel.isEmpty()){
                delete rlDel;
            }
            
            if(!rlNtax.isEmpty()){
                for(OrderApi__Receipt_Line__c rls : rlNtax){
                    setRls.add(rls.Id);
                    setRCs.add(rls.OrderApi__Receipt__c);
                }
                for(OrderApi__Receipt__c rs : [SELECT Id, Processing_Changes__c FROM OrderApi__Receipt__c WHERE Id IN: setRCs]){
                    rs.Processing_Changes__c = TRUE;
                    lstRs.add(rs);
                }
                update lstRs;
                TXWR_CalloutClass.receiptCallout(setRls, false);
            }
        }
    }

}