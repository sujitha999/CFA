public with sharing class attendeeCASLService {

    public static void addCASLBadge(Map<Id, EventApi__Attendee__c> oldMap, EventApi__Attendee__c[] records) {

        try {

            Map<Id, Id> mapConBT = new Map<Id, Id>();
            Map<Id, Id> mapConSO = new Map<Id, Id>();
            Map<Id, Date> mapConSODt = new Map<Id, Date>();
            Map<Id, Id> mapBgBT = new Map<Id, Id>();
            List<OrderApi__Badge__c> asgndBadges = new List<OrderApi__Badge__c>();                  //List of assigned badges
            List<OrderApi__Badge__c> updBadges = new List<OrderApi__Badge__c>();                    //List of badges to update
            List<OrderApi__Badge__c> insBadges = new List<OrderApi__Badge__c>();

            for(OrderApi__Badge_Type__c bt : [SELECT Id,
                                                      BusinessGroup__c
                                                      FROM OrderApi__Badge_Type__c
                                                      WHERE TypeId__c = 'CASLImp']) {
                mapBgBT.put(bt.BusinessGroup__c, bt.Id);
            }

            for (EventApi__Attendee__c att : [SELECT Id,
                                                     EventApi__Contact__c,
                                                     EventApi__Contact__r.MailingCountry,
                                                     EventApi__Sales_Order__c,
                                                     EventApi__Sales_Order__r.OrderApi__Posted_Date__c,
                                                     EventApi__Ticket_Type__r.BusinessGroup__c
                                                     FROM EventApi__Attendee__c
                                                     WHERE Id IN: records]) {

                if (att.EventApi__Contact__c != NULL && att.EventApi__Contact__c != oldMap.get(att.Id).EventApi__Contact__c
                        && (att.EventApi__Contact__r.MailingCountry == 'CANADA' || att.EventApi__Contact__r.MailingCountry == 'CAN')
                        && mapBgBT.ContainsKey(att.EventApi__Ticket_Type__r.BusinessGroup__c)) {

                    mapConBT.put(att.EventApi__Contact__c, mapBgBT.get(att.EventApi__Ticket_Type__r.BusinessGroup__c));
                    mapConSO.put(att.EventApi__Contact__c, att.EventApi__Sales_Order__c);
                    mapConSODt.put(att.EventApi__Contact__c, att.EventApi__Sales_Order__r.OrderApi__Posted_Date__c);
                }
            }

            for (Contact c : [SELECT Id,
                                     (SELECT Id,
                                             OrderApi__Badge_Type__c,
                                             OrderApi__Badge_Type__r.TypeId__c,
                                             Created_By_Trigger__c
                                             FROM OrderApi__Badges__r)
                                     FROM Contact
                                     WHERE Id IN:mapConBT.keySet()]) {

                asgndBadges = new List<OrderApi__Badge__c>();
                asgndBadges.addAll(c.OrderApi__Badges__r);
                Boolean caslFound = FALSE;

                for (OrderApi__Badge__c bd : asgndBadges) {

                    if (bd.OrderApi__Badge_Type__c == mapConBT.get(c.Id)) {
                        caslFound = TRUE;
                        if(bd.Created_By_Trigger__c == TRUE){
                            bd.Created_By_Trigger__c = FALSE;
                        } else {
                            bd.Created_By_Trigger__c = TRUE;
                        }
                        bd.OrderApi__Awarded_Date__c = mapConSODt.get(c.Id);
                        bd.OrderApi__Expired_Date__c = mapConSODt.get(c.Id).addYears(2);
                        bd.Sales_Order__c = mapConSO.get(c.Id);
                        updBadges.add(bd);
                    }
                }

                if (caslFound != TRUE) {
                    OrderApi__Badge__c bdg = new OrderApi__Badge__c();
                    bdg.Created_By_Trigger__c = TRUE;
                    bdg.OrderApi__Contact__c = c.Id;
                    bdg.OrderApi__Badge_Type__c = mapConBT.get(c.Id);
                    bdg.OrderApi__Awarded_Date__c = mapConSODt.get(c.Id);
                    bdg.OrderApi__Expired_Date__c = mapConSODt.get(c.Id).addYears(2);
                    bdg.Sales_Order__c = mapConSO.get(c.Id);
                    insBadges.add(bdg);
                }

            }

            if (!updBadges.isEmpty()) {
                update updBadges;
            }

            if (!insBadges.isEmpty()) {
                insert insBadges;
            }
        } catch (Exception ex) {
            system.debug('\n--ex--' + ex);
        }
    }
}