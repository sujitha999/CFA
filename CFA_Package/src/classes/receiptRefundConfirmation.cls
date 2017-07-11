public class receiptRefundConfirmation{

    public static void attendeeWriteBack(List<OrderApi__Receipt__c> lstReceipt, Map<id,SObject> oldMap) {
        //List of records for which write back to attendee is needed.
        List<OrderApi__Receipt__c> recLst = new List<OrderApi__Receipt__c>();
        
        //Set of attendee ids to be updated
        Set<Id> attSet = new Set<Id>();
        
        
        for(OrderApi__Receipt__c rec : (OrderApi__Receipt__c[]) lstReceipt){ 
            
            OrderApi__Receipt__c oldObj = (OrderApi__Receipt__c) oldMap.get(rec.id);
            
            if(rec.Attendee__c != NULL && rec.OrderApi__Type__c == 'Refund' 
                    && rec.OrderApi__Is_Posted__c == TRUE && oldObj.OrderApi__Is_Posted__c == FALSE){
                recLst.add(rec);
                attSet.add(rec.Attendee__c);
            }        
        }
        
        Map<Id, EventApi__Attendee__c> attMap = new Map<Id, EventApi__Attendee__c>
                                                    ([select Id FROM EventApi__Attendee__c WHERE Id IN: attSet]);
        
        //Map of ePayment Id and Attendee Id
        Map<Id, Id> ePayAttMap = new Map<Id, Id>();
        for(OrderApi__Receipt__c r : recLst){
            ePayAttMap.put(r.OrderApi__EPayment__c, r.Attendee__c);
        }
        
        //Getting related epayment records
        List<OrderApi__EPayment__c> epay = [SELECT Id, 
                                                   OrderApi__Succeeded__c,
                                                   OrderApi__Status__c
                                                   FROM OrderApi__EPayment__c 
                                                   WHERE OrderApi__Refund_Receipt__c IN: recLst];
        
        
        if(epay.size() == 1){
            for(OrderApi__EPayment__c ep : epay){
                //Get the related attendee record to update
                EventApi__Attendee__c att = attMap.get(ePayAttMap.get(ep.Id));
                if(ep.OrderApi__Succeeded__c == TRUE && ep.OrderApi__Status__c == 'Success'){
                    att.Cancellation_Request_Status__c = 'Refunded';
                    att.ePayment__c = ep.Id;
                } else {
                    att.Cancellation_Request_Status__c = 'RFD: Payment Processor Declined Refund';
                    att.ePayment__c = ep.Id;
                }
                update att;
            }
            
        }
        
    }

    public static void receiptPostTXWR(List<OrderApi__Receipt__c> lstReceipt, Map<id,SObject> oldMap){
        for(OrderApi__Receipt__c rc : (OrderApi__Receipt__c[]) lstReceipt){

            OrderApi__Receipt__c oldObj = (OrderApi__Receipt__c) oldMap.get(rc.id);

            if(rc.Taxware_RC__c == TRUE && rc.Post_When_Ready__c == TRUE && oldObj.Processing_Changes__c != rc.Processing_Changes__c && rc.Processing_Changes__c == FALSE){
                rc.OrderApi__Process_Refund__c = TRUE;
            }
        }
    }

}