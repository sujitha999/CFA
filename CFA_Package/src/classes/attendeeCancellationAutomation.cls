public class attendeeCancellationAutomation{

    public static String className = attendeeCancellationAutomation.class.getName();
    public static String statusCode;
    public static Id receiptId;

    public static void processCancellation(List<EventApi__Attendee__c> lstAttendee, map<id,EventApi__Attendee__c> oldMap) {
        Framework.Log.push(className,'processCancellation');
        
        //List of records for which cancellation was requested.
        List<EventApi__Attendee__c> cnclReq = new List<EventApi__Attendee__c>();
              
        //Map of attendee id and event id
        Map<Id, Id> attEvtId = new Map<Id, Id>();
        
        //Map of event id and related event information
        Map<Id, EventApi__Event__c> mapEvt = new Map<Id, EventApi__Event__c>();
        
        //Map of attendee id and related event information
        Map<Id, EventApi__Event__c> attEvt = new Map<Id, EventApi__Event__c>();
        
        //Map of attendee id and related sales orders
        Map<Id, Id> attSO = new Map<Id, Id>();
        
        //Map of attendee id and related sales order contact id
        Map<Id, Id> attSOCon = new Map<Id, Id>();
        
        //Map of attendee if and related sales order line quantity
        Map<Id, Decimal> attSOLquant = new Map<Id, Decimal>();
        
        //Map of attendee id and related sales order lines on the sales order
        Map<Id, List<OrderApi__Sales_Order_Line__c>> mapAttSOL = new Map<Id, List<OrderApi__Sales_Order_Line__c>>();
        
        //Set of Sales Orders for each attendee
        Set<Id> setSO = new Set<Id>();
        
        //Set of Events for each attendee
        Set<Id> setEv = new Set<Id>();
        
        //Map of sales order id and relate sales order lines
        Map<Id, List<OrderApi__Sales_Order_Line__c>> soSOL = new Map<Id, List<OrderApi__Sales_Order_Line__c>>();
        
        //Map or receipts and related receipt lines
        Map<Id, List<OrderApi__Receipt_Line__c>> mapRL = new Map<Id, List<OrderApi__Receipt_Line__c>>();
        
        //Map of sales order id and related receipts
        Map<Id, List<OrderApi__Receipt__c>> soRec = new Map<Id, List<OrderApi__Receipt__c>>();
        
        //Map of attendee id and related receipts on the Sales Order
        Map<Id, List<OrderApi__Receipt__c>> mapAttRec = new Map<Id, List<OrderApi__Receipt__c>>();
        
        //Map of attendee records and error msg
        Map<EventApi__Attendee__c, String> errorMap = new Map<EventApi__Attendee__c, String>();     
        
        //List of attedee records which pass all error conditions
        List<EventApi__Attendee__c> noError = new List<EventApi__Attendee__c>();
       
        //List of refunded receipts
        List<OrderApi__Receipt__c> refRec = new List<OrderApi__Receipt__c>();
        
        //Map of attendee id and legit receipts Ids that can be refunded
        Map<Id, Id> legitRec = new Map<Id, Id>();
        
        //Set of refund receipts created
        Set<Id> createdRefunds = new Set<Id>();
        
        //List of refund receipts to be processed
        List<OrderApi__Receipt__c> processRefund = new List<OrderApi__Receipt__c>();

        //List of refund receipts to be processed later
        List<OrderApi__Receipt__c> processLaterRefund = new List<OrderApi__Receipt__c>();
        
        for(EventApi__Attendee__c att: lstAttendee) {
        
            Boolean oldVal = (Boolean)oldMap.get(att.Id).get(SObjectType.EventApi__Attendee__c.fields.EventApi__Refund_Requested__c.getName());
            Boolean newVal = att.EventApi__Refund_Requested__c;
            
            if(oldVal == FALSE && newVal == TRUE){
                cnclReq.add(att);                                    
            }      
        }
        
        for(EventApi__Attendee__c att : [SELECT Id,
                                                EventApi__Sales_Order__c,
                                                EventApi__Event__c,
                                                EventApi__Sales_Order__r.OrderApi__Contact__c,
                                                EventApi__Sales_Order_Line__r.OrderApi__Quantity__c
                                                FROM EventApi__Attendee__c 
                                                WHERE Id IN: cnclReq]){

            attSO.put(att.Id, att.EventApi__Sales_Order__c);
            attSOCon.put(att.Id, att.EventApi__Sales_Order__r.OrderApi__Contact__c);
            attSOLquant.put(att.Id, att.EventApi__Sales_Order_Line__r.OrderApi__Quantity__c);
            setSO.add(att.EventApi__Sales_Order__c);
            attEvtId.put(att.Id, att.EventApi__Event__c);
            setEv.add(att.EventApi__Event__c);
        } 
        
        for(OrderApi__Sales_Order__c so : [SELECT Id,
                                                  (SELECT Id, OrderApi__Is_Tax__c, OrderApi__Quantity__c FROM OrderApi__Sales_Order_Lines__r WHERE OrderApi__Is_Tax__c = FALSE),
                                                  (SELECT Id, OrderApi__Contact__c, OrderApi__Type__c FROM OrderApi__Receipts__r)
                                                  FROM OrderApi__Sales_Order__c WHERE Id IN: setSO]){
            soSOL.put(so.Id, so.OrderApi__Sales_Order_Lines__r);
            soRec.put(so.Id, so.OrderApi__Receipts__r);
        }

        /** Combined above
        for(OrderApi__Sales_Order__c so : [SELECT Id,
                                                  (SELECT Id, OrderApi__Contact__c, OrderApi__Type__c FROM OrderApi__Receipts__r)
                                                  FROM OrderApi__Sales_Order__c WHERE Id IN: setSO]){
            soRec.put(so.Id, so.OrderApi__Receipts__r);
            
        }
        **/

        for(OrderApi__Receipt__c rpt : [SELECT Id,
                                               (Select Id, OrderApi__Is_Tax__c FROM OrderApi__Receipt_Lines__r)
                                               FROM OrderApi__Receipt__c
                                               WHERE OrderApi__Sales_Order__c IN: setSO]){
            mapRL.put(rpt.Id, rpt.OrderApi__Receipt_Lines__r);                            
        }
        
        for(EventApi__Event__c ev : [SELECT Id,
                                            Cancellation_Fee_Start_Date__c,
                                            Cancellation_Fee_End_Date__c,
                                            Cancellation_Fee_Amount__c
                                            FROM EventApi__Event__c
                                            WHERE Id IN: setEv]){
            mapEvt.put(ev.Id, ev);                                    
        }
        
        for(EventApi__Attendee__c att : cnclReq){
            mapAttRec.put(att.Id, soRec.get(att.EventApi__Sales_Order__c));
            mapAttSOL.put(att.Id, soSOL.get(att.EventApi__Sales_Order__c));
            attEvt.put(att.Id, mapEvt.get(attEvtId.get(att.Id)));
        }
        
        for(EventApi__Attendee__c att : cnclReq){
        
            Date cancelEnd = attEvt.get(att.Id).Cancellation_Fee_End_Date__c;          
            
            if(cancelEnd != NULL && cancelEnd < system.today()){
                errorMap.put(att,'err0');
                continue;
            }
            /** Removed
            if(att.EventApi__Contact__c != attSOCon.get(att.Id)){
                //error1.add(att);
                errorMap.put(att,'err1');
                continue;
            }
            **/
            List<OrderApi__Sales_Order_Line__c> lstSOL = mapAttSOL.get(att.Id);
            if(lstSOL.size() > 1){
                //error2.add(att);
                errorMap.put(att,'err2');
                continue;
            }
            if(attSOLquant.get(att.Id) > 1){
                //error3.add(att);
                errorMap.put(att,'err3');
                continue;
            }
            List<OrderApi__Receipt__c> lstRec = mapAttRec.get(att.Id);
            if(lstRec.size() > 1){
                for(OrderApi__Receipt__c rec : lstRec){
                    if(rec.OrderApi__Type__c == 'Refund'){   
                        refRec.add(rec);
                    }
                }
                if(!refRec.isEmpty()){
                    //error6.add(att);
                    errorMap.put(att,'err6');
                    continue;
                } else {
                    //error5.add(att);
                    errorMap.put(att,'err5');
                    continue;
                }
            } 
            if(lstRec.size() == 1){
                //Id recCon = lstRec[0].OrderApi__Contact__c;
                Id recId = lstRec[0].Id;
                legitRec.put(att.Id, recId);
                noError.add(att);
                //List<OrderApi__Receipt_Line__c> lstRLs = mapRL.get(recId);
                /** removed
                if(att.EventApi__Contact__c != recCon){
                    //error4.add(att);
                    errorMap.put(att,'err4');
                    continue;
                }
                if(att.EventApi__Contact__c == recCon){
                    List<Id> taxRLs = new List<Id>();
                    for(OrderApi__Receipt_Line__c rcptls : lstRLs){
                        if(rcptls.OrderApi__Is_Tax__c == TRUE){
                            taxRLs.add(rcptls.Id);
                        }
                    }
                    if(!taxRLs.isEmpty()){
                        //tax lines exist
                        errorMap.put(att,'err7');
                    } else {
                        legitRec.put(att.Id, recId);
                        noError.add(att);
                    }
                }
                **/
            }
            
        }
        
        
        if(!errorMap.isEmpty()){
            for(EventApi__Attendee__c att : errorMap.keyset()){
                if(errorMap.get(att) == 'err0'){
                    att.Cancellation_Request_Status__c = 'RFD: Refunds no longer issued (Cxl end date hit)';
                    att.EventApi__Status__c = 'Cancelled';
                    att.Request_Date__c = system.today();
                }
                /**
                if(errorMap.get(att) == 'err1'){
                    att.Cancellation_Request_Status__c = 'CXL: Attendee Contact is not SO Contact'; //remove
                    att.Request_Date__c = system.today();
                }
                **/
                if(errorMap.get(att) == 'err2'){
                    att.Cancellation_Request_Status__c = 'CXL: Multiple Ticket SOLs exist on SO';
                    att.Request_Date__c = system.today();
                }
                if(errorMap.get(att) == 'err3'){
                    att.Cancellation_Request_Status__c = 'CXL: Quantity > 1 on the Ticket SOL';
                    att.Request_Date__c = system.today();
                }
                /**
                if(errorMap.get(att) == 'err4'){
                    att.Cancellation_Request_Status__c = 'CXL: Receipt Contact is not Attendee Contact'; //remove
                    att.Request_Date__c = system.today();
                }
                **/
                if(errorMap.get(att) == 'err5'){
                    att.EventApi__Status__c = 'Cancelled';
                    att.Cancellation_Request_Status__c = 'RFD: Multiple receipts on SO or Invoice';
                    att.Request_Date__c = system.today();
                }
                if(errorMap.get(att) == 'err6'){
                    att.EventApi__Status__c = 'Cancelled';
                    att.Cancellation_Request_Status__c = 'RFD: Refund already exists';
                    att.Request_Date__c = system.today();
                }
                /**
                if(errorMap.get(att) == 'err7'){
                    att.EventApi__Status__c = 'Cancelled';
                    att.Cancellation_Request_Status__c = 'RFD: Partial refund with tax requires manual processing';
                    att.Request_Date__c = system.today();
                }
                **/
            }
        }
        
        if(!noError.isEmpty()){
            for(EventApi__Attendee__c att : noError){
                Date cancelStart = attEvt.get(att.Id).Cancellation_Fee_Start_Date__c;
                Decimal cancelAmount;
                if(cancelStart != NULL && cancelStart <= system.today()){
                    cancelAmount = attEvt.get(att.Id).Cancellation_Fee_Amount__c;
                } else {
                    cancelAmount = 0;
                }
                
                att.EventApi__Status__c = 'Cancelled';
                att.Cancellation_Request_Status__c = 'In Process';
                att.Request_Date__c = system.today();
                receiptId = legitRec.get(att.Id);
                Id refundId;
                if(cancelAmount != 0){
                    refundId = createRefund(receiptId, att.Id, cancelAmount);
                } else {
                    refundId = createRefund(receiptId, att.Id, 0);
                }
                createdRefunds.add(refundId);
            }
        }
        
        /**Code to process the refunds**/
        
        for(OrderApi__Receipt__c refId : [SELECT Id, Taxware_RC__c, OrderApi__Process_Refund__c, Post_When_Ready__c FROM OrderApi__Receipt__c WHERE OrderApi__Type__c =: 'Refund' AND Id IN: createdRefunds]){
            if(refId.Taxware_RC__c != TRUE){
                refId.OrderApi__Process_Refund__c = TRUE;
                processRefund.add(refId);
            }
            if(refId.Taxware_RC__c == TRUE){
                refId.Post_When_Ready__c = TRUE;
                processLaterRefund.add(refId);
            }
        }
        if(!processRefund.isEmpty()) {
            update processRefund;
        }
        if(!processLaterRefund.isEmpty()){
            update processLaterRefund;
        }
        
    }
    
    public static Id createRefund(Id recId, Id attId, Decimal canAmnt){
        OrderApi__Receipt__c receipt = (OrderApi__Receipt__c) new Framework.Selector(OrderApi__Receipt__c.SObjectType).selectById(recId);
        if (receipt != null && recId != null && receipt.OrderApi__Is_Payment__c) {
            try {
                receipt.OrderApi__Refund__c = true;
                update receipt;
                receipt.OrderApi__Refund__c = false;
                update receipt;
            }
            catch (Exception e) {
                Framework.Log.debugException(e);
            }
        }
        
        String refundQuery = 'SELECT Id, OrderApi__Receipt__c, OrderApi__Is_Refund__c, Attendee__c, CreatedDate FROM OrderApi__Receipt__c WHERE OrderApi__Receipt__c.OrderApi__Receipt__c = :recId ORDER BY CreatedDate DESC NULLS LAST LIMIT 1';
        List<OrderApi__Receipt__c> refunds = (List<OrderApi__Receipt__c>) Database.query(refundQuery);
        List<Id> refrecId = new List<Id>();
        List<OrderApi__Receipt_Line__c> recLine = new List<OrderApi__Receipt_Line__c>();
        if (refunds.size() > 0) {
            for(OrderApi__Receipt__c r : refunds){
                r.Attendee__c = attId;
                update r;
                refrecId.add(r.Id);
            }
            for(OrderApi__Receipt_Line__c rl : [SELECT Id, OrderApi__Sale_Price__c FROM OrderApi__Receipt_Line__c WHERE OrderApi__Receipt__c IN: refrecId AND OrderApi__Is_Tax__c != TRUE]){
                recLine.add(rl);
            }
            if(recLine.size() > 0){
                for(OrderApi__Receipt_Line__c rls : recLine){
                    rls.OrderApi__Sale_Price__c = rls.OrderApi__Sale_Price__c - canAmnt;
                    update rls;
                    break;
                }
            }
            recId = refunds[0].Id;
        }
        return recId;
    }

}