public without sharing class TXWR_ProcessRC {

    public TXWR_ProcessRC(){

    }

    public static void updateConditions(List<OrderApi__Receipt__c> lstRecs, map<id,OrderApi__Receipt__c> mapOldRec){

        List<OrderApi__Receipt__c> lstRcptPosted = new List<OrderApi__Receipt__c>();
        List<OrderApi__Receipt_Line__c> lstRLs = new List<OrderApi__Receipt_Line__c>();
        Set<Id> setRLs = new Set<Id>();

        for(OrderApi__Receipt__c rc : lstRecs){
            if(rc.Taxware_RC__c == TRUE) {
                if (rc.OrderApi__Is_Posted__c == TRUE && mapOldRec.get(rc.Id).OrderApi__Is_Posted__c != rc.OrderApi__Is_Posted__c && rc.OrderApi__Type__c == 'Refund') {
                    lstRcptPosted.add(rc);
                }
            }
        }

        if(!lstRcptPosted.isEmpty()){
            lstRLs = [SELECT Id FROM OrderApi__Receipt_Line__c WHERE OrderApi__Item__r.Tax_With_Taxware__c = TRUE AND OrderApi__Is_Tax__c = FALSE AND OrderApi__Receipt__c IN: lstRcptPosted];
        }

        if(!lstRLs.isEmpty()){
            for(OrderApi__Receipt_Line__c rl : lstRLs){
                setRLs.add(rl.Id);
            }
        }

        TXWR_CalloutClass.receiptCallout(setRls, true);

    }

}