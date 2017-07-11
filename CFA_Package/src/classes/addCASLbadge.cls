public without sharing class addCASLbadge {

    public static void insertCASLbadge(List<OrderApi__Sales_Order__c> lstRecs, map<id,OrderApi__Sales_Order__c> mapOldRec){
        
        try{
            
            Map<Id, Id> mapBgBT = new Map<Id, Id>();                                                //Map BG Id and BT Id
            Map<Id, Id> mapConBT = new Map<Id, Id>();                                               //Map Con Id and BT Id
            Map<Id, Id> mapConSO = new Map<Id, Id>();                                               //Map of Con Id and SO Id
            Set<OrderApi__Sales_Order__c> pstdSO = new Set<OrderApi__Sales_Order__c>();             //Set of posted SOs with CASL Bg
            List<OrderApi__Badge__c> asgndBadges = new List<OrderApi__Badge__c>();                  //List of assigned badges
            List<OrderApi__Badge__c> updBadges = new List<OrderApi__Badge__c>();                    //List of badges to update
            List<OrderApi__Badge__c> insBadges = new List<OrderApi__Badge__c>();                    //List of badges to insert
            Id defConId = [SELECT Id                                                                //Id of default contact
                                  FROM Contact
                                  WHERE firstName = 'Fonteva'
                                  AND lastName = 'Default Contact' Limit 1].Id;
    
            for(OrderApi__Badge_Type__c bt : [SELECT Id,
                                                     BusinessGroup__c
                                                     FROM OrderApi__Badge_Type__c
                                                     WHERE TypeId__c = 'CASLImp']){
                mapBgBT.put(bt.BusinessGroup__c, bt.Id);
            }
    
            for(OrderApi__Sales_Order__c so : lstRecs){
    
                if(so.OrderApi__Posting_Status__c == 'Posted'
                        && mapOldRec.get(so.Id).OrderApi__Posting_Status__c != so.OrderApi__Posting_Status__c){
    
                    if(so.OrderApi__Contact__c != defConId && mapBgBT.containsKey(so.OrderApi__Business_Group__c) ){
                        pstdSO.add(so);
    
                    }
                }
            }
    
            for(OrderApi__Sales_Order__c so : [SELECT Id,
                                                      OrderApi__Contact__c,
                                                      OrderApi__Contact__r.MailingCountry,
                                                      OrderApi__Has_Subscription__c,
                                                      (SELECT Id,
                                                              OrderApi__Is_Tax__c,
                                                              OrderApi__Sales_Order__c,
                                                              OrderApi__Contact__c,
                                                              OrderApi__Contact__r.MailingCountry
                                                              FROM OrderApi__Sales_Order_Lines__r),
                                                      (SELECT Id,
                                                                EventApi__Sales_Order__c,
                                                                EventApi__Contact__c,
                                                                EventApi__Contact__r.MailingCountry
                                                                FROM EventApi__Attendees__r),
                                                      OrderApi__Business_Group__c
                                                      FROM OrderApi__Sales_Order__c
                                                      WHERE Id IN: pstdSO]){
    
                if(so.OrderApi__Contact__r.MailingCountry == 'Canada' || so.OrderApi__Contact__r.MailingCountry == 'CAN'){
                    mapConBT.put(so.OrderApi__Contact__c, mapBgBT.get(so.OrderApi__Business_Group__c));
                    mapConSO.put(so.OrderApi__Contact__c, so.Id);
                }
                
                if(so.OrderApi__Has_Subscription__c == TRUE){
                    for(OrderApi__Sales_Order_Line__c sol : so.OrderApi__Sales_Order_Lines__r){
        
                        if(sol.OrderApi__Is_Tax__c != TRUE && (sol.OrderApi__Contact__r.MailingCountry == 'Canada' || sol.OrderApi__Contact__r.MailingCountry == 'CAN')){
                            mapConBT.put(sol.OrderApi__Contact__c, mapBgBT.get(so.OrderApi__Business_Group__c));
                            mapConSO.put(sol.OrderApi__Contact__c, sol.OrderApi__Sales_Order__c);
                        }
                    }
                } else {
                    for (EventApi__Attendee__c att : so.EventApi__Attendees__r) {

                        if (att.EventApi__Contact__r.MailingCountry == 'Canada' || att.EventApi__Contact__r.MailingCountry == 'CAN') {
                            mapConBT.put(att.EventApi__Contact__c, mapBgBT.get(so.OrderApi__Business_Group__c));
                            mapConSO.put(att.EventApi__Contact__c, att.EventApi__Sales_Order__c);
                        }
                    }
                }
            }
    
            for(Contact c : [SELECT Id,
                                    (SELECT Id,
                                            OrderApi__Badge_Type__c,
                                            OrderApi__Badge_Type__r.TypeId__c,
                                            Created_By_Trigger__c
                                            FROM OrderApi__Badges__r)
                                    FROM Contact
                                    WHERE Id IN: mapConBT.keySet()]){
                
                asgndBadges = new List<OrderApi__Badge__c>();
                asgndBadges.addAll(c.OrderApi__Badges__r);
                Boolean caslFound = FALSE;
    
                for(OrderApi__Badge__c bd : asgndBadges){
    
                    if(bd.OrderApi__Badge_Type__c == mapConBT.get(c.Id)){
    
                        caslFound = TRUE;
                        if(bd.Created_By_Trigger__c == TRUE){
                            bd.Created_By_Trigger__c = FALSE;
                        } else {
                            bd.Created_By_Trigger__c = TRUE;
                        }
                        bd.OrderApi__Awarded_Date__c = system.today();
                        bd.OrderApi__Expired_Date__c = system.today().addYears(2);
                        bd.Sales_Order__c = mapConSO.get(c.Id);
                        updBadges.add(bd);
                    }
                }
    
                if(caslFound != TRUE){
                    OrderApi__Badge__c bdg = new OrderApi__Badge__c();
                    bdg.Created_By_Trigger__c = TRUE;
                    bdg.OrderApi__Contact__c = c.Id;
                    bdg.OrderApi__Badge_Type__c = mapConBT.get(c.Id);
                    bdg.OrderApi__Awarded_Date__c = system.today();
                    bdg.OrderApi__Expired_Date__c = system.today().addYears(2);
                    bdg.Sales_Order__c = mapConSO.get(c.Id);
                    insBadges.add(bdg);
                }
            }
    
            if(!updBadges.isEmpty()){
                update updBadges;
            }
    
            if(!insBadges.isEmpty()){
                insert insBadges;
            }
        }
        catch(Exception ex){
            system.debug('\n--ex--'+ex);
        }
    }

    public static void preventDeletion(List<OrderApi__Badge__c> lstRecs){

        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String MyProfileName = PROFILE[0].Name;

        Map<Id, String> mapBdgBtt = new Map<Id, String>();

        for(OrderApi__Badge__c bd : [SELECT Id, OrderApi__Badge_Type__r.TypeId__c FROM OrderApi__Badge__c WHERE Id IN: lstRecs]){
            mapBdgBtt.put(bd.Id, bd.OrderApi__Badge_Type__r.TypeId__c);
        }

        for(OrderApi__Badge__c bdg : lstRecs){

            String typeId = mapBdgBtt.get(bdg.Id);

            if(typeId == 'CASLImp' && MyProfileName != 'System Administrator'){
                bdg.adderror('Cannot delete CASL Badges.');
            }
        }

    }
    
    /** 
     * this will run to prevent duplicay in case of insertion
     */
    public static void preventDuplicates(OrderApi__Badge__c[] lstRecs){
        
        set<string> setBadgeType = new set<string>();               // thsi will save the badge type records
        set<string> setContact = new set<string>();                 // this will save the contact ids
        set<string> srtCom = new set<string>();                     // thsi save the combination which eill be used check the duplcay
        
        for(OrderApi__Badge__c bdg : lstRecs){
            setBadgeType.add(bdg.OrderApi__Badge_Type__c);
        }
        
        map<id,OrderApi__Badge_Type__c> mapBadgeType = new map<id,OrderApi__Badge_Type__c>([SELECT Id
                                                                                                   FROM OrderApi__Badge_Type__c
                                                                                                   WHERE Id IN: setBadgeType
                                                                                                   AND ( TypeId__c = 'CASLImp'
                                                                                                   OR TypeId__c = 'CASLExp')]);
        
        setBadgeType = new set<string>();
        
        for(OrderApi__Badge__c bdg : lstRecs){
            
            if(mapBadgeType.containsKey(bdg.OrderApi__Badge_Type__c)){   
                setBadgeType.add(bdg.OrderApi__Badge_Type__c);
                setContact.add(bdg.OrderApi__Contact__c);
            }
        }
        
        for(OrderApi__Badge__c bdg : [SELECT Id,
                                             OrderApi__Badge_Type__c,
                                             OrderApi__Contact__c
                                             FROM OrderApi__Badge__c
                                             WHERE OrderApi__Badge_Type__c IN :setBadgeType
                                             AND OrderApi__Contact__c IN :setContact]){
                                                
               string combnation = bdg.OrderApi__Badge_Type__c+''+bdg.OrderApi__Contact__c;
               srtCom.add(combnation);
        }

        for(OrderApi__Badge__c bdg : lstRecs){
            
            string combnation = bdg.OrderApi__Badge_Type__c+''+bdg.OrderApi__Contact__c;
            if(srtCom.contains(combnation)){
                bdg.addError('A duplicate badge was found in the system. Please make changes to the existing badge');
            }
        }
    }

}