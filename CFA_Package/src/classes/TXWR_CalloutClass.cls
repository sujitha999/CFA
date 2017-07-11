public without sharing class TXWR_CalloutClass {
    
    public TXWR_CalloutClass(){                                                                         //constructor
        
    }

    public static void salesOrderCallout(set<Id> SOLIds, boolean aud){
        
        string logId = '';                                                                              //This will store the ID of the 
                                                                                                        //Integration log throut the process
        string currenyCodeSO = ''; 
        
        if(!SOLIds.isEmpty()){
            
            Map<Id, Id> mapSOLSO = new Map<Id, Id>();                                                   //Map of SOL Ids and SO Ids
            Map<Id, Id> mapSOLEvent = new Map<Id, Id>();                                                //Map of Event Ids and SOL Ids
            Map<Id, EventApi__Venue__c> mapSOLVenue = new Map<id,EventApi__Venue__c>();                 //Map of SOL Ids and Venue details
            List<OrderApi__Sales_Order_Line__c> setSOLs = new List<OrderApi__Sales_Order_Line__c>();    //List of SOLs being processed
            Set<Id> listofEvents = new Set<Id>();
            
            setSOLs = [SELECT Id, OrderApi__Sales_Order__c, EventApi__Event__c FROM OrderApi__Sales_Order_Line__c WHERE Id IN: SOLIds];  //Querying the SOLs
            
            for(OrderApi__Sales_Order_Line__c sol : setSOLs){
                mapSOLSO.put(sol.Id, sol.OrderApi__Sales_Order__c);                                     //Adding SOL Id and SO Id to the map
                mapSOLEvent.put(sol.Id, sol.EventApi__Event__c);                                        //Adding Event Id and SOL Id to the map
            }
            
            for(OrderApi__Sales_Order_Line__c sol : setSOLs){
                listofEvents.add(mapSOLEvent.get(sol.Id));
            }
            
            for(EventApi__Venue__c ev : [SELECT Id,                                                     //Querying for the venue address details
                                                EventApi__Event__c,
                                                EventApi__Street__c,
                                                EventApi__City__c,
                                                EventApi__State__c,
                                                EventApi__Country__c,
                                                EventApi__Postal_Code__c
                                                FROM EventApi__Venue__c
                                                WHERE EventApi__Event__c IN: listofEvents
                                                AND EventApi__Is_Primary_Venue__c = TRUE]){
            
                 mapSOLVenue.put(ev.EventApi__Event__c,ev);                                            //Adding the SOL Id and the Venue details to the map                
            }
            
            List<TXWR_IntegrationWrapperClass.SOLDetailWrapper> lstSOL = new List<TXWR_IntegrationWrapperClass.SOLDetailWrapper>();  //Initializing a List of Taxware Line Wrapper Classes
            
            List<Id> lstSId = new List<Id>();
            for(Id i : mapSOLSO.KeySet()){
                lstSId.add(mapSOLSO.get(i));
            }
            Id SId = lstSId[0];
            logId = insertApexLogs('Taxware Sales Order Process Started', 'SalesOrderCallout','','','','',SId,NULL,NULL);     //Creating the integration log and storing log Id
            
            if(!mapSOLVenue.isEmpty()){                                                                 //Checking if Venue details are present
                
                for(OrderApi__Sales_Order_Line__c sol : [SELECT Id,                                     //Querying for all required addresses
                                                                OrderApi__Total__c,
                                                                CurrencyIsoCode,
                                                                OrderApi__Sales_Order__r.CurrencyIsoCode,
                                                                OrderApi__Sales_Order__r.OrderApi__Billing_Street__c,
                                                                OrderApi__Sales_Order__r.OrderApi__Billing_City__c,
                                                                OrderApi__Sales_Order__r.OrderApi__Billing_State__c,
                                                                OrderApi__Sales_Order__r.OrderApi__Billing_Postal_Code__c,
                                                                OrderApi__Sales_Order__r.OrderApi__Billing_Country__c,
                                                                OrderApi__Sales_Order__r.Name,
                                                                OrderApi__Sales_Order__r.OrderApi__Posted_Date__c,
                                                                OrderApi__Business_Group__r.Mailing_Street__c,
                                                                OrderApi__Business_Group__r.Mailing_City__c,
                                                                OrderApi__Business_Group__r.Mailing_State__c,
                                                                OrderApi__Business_Group__r.Mailing_Zip_Code__c,
                                                                OrderApi__Business_Group__r.Mailing_Country__c,
                                                                OrderApi__Business_Group__r.Org_Code__c,
                                                                OrderApi__Item__r.Good_Srv_Code__c
                                                                FROM OrderApi__Sales_Order_Line__c 
                                                                WHERE Id IN: setSOLs]){
                                                                    
                    
                    TXWR_IntegrationWrapperClass.SOLDetailWrapper objSol = new TXWR_IntegrationWrapperClass.SOLDetailWrapper(); //Initializing a Taxware Line Wrapper Class
                                                                                                                                //and setting all the required attributes
                    //Top Attributes                                                                                            
                    objSol.grossAmt = sol.OrderApi__Total__c;
                    objSol.discnts = NULL;
                    objSol.orgCd = sol.OrderApi__Business_Group__r.Org_Code__c;
                    objSol.lnItmId = sol.Id;
                    objSol.goodSrvCd = sol.OrderApi__Item__r.Good_Srv_Code__c;
                    
                    // setting currency
                    currenyCodeSO = sol.OrderApi__Sales_Order__r.CurrencyIsoCode;
                
                    //Bill To Address - Billing Address from SO
                    objSol.bTStNameNum = sol.OrderApi__Sales_Order__r.OrderApi__Billing_Street__c;
                    objSol.bTCity = sol.OrderApi__Sales_Order__r.OrderApi__Billing_City__c;
                    objSol.bTStateProv = sol.OrderApi__Sales_Order__r.OrderApi__Billing_State__c;
                    objSol.bTPstlCd = sol.OrderApi__Sales_Order__r.OrderApi__Billing_Postal_Code__c;
                    objSol.bTCountry = sol.OrderApi__Sales_Order__r.OrderApi__Billing_Country__c;
                
                    //Location of Accounts - Address form Business Group
                    objSol.lOAStNameNum = sol.OrderApi__Business_Group__r.Mailing_Street__c;
                    objSol.lOACity = sol.OrderApi__Business_Group__r.Mailing_City__c;
                    objSol.lOAStateProv = sol.OrderApi__Business_Group__r.Mailing_State__c;
                    objSol.lOAPstlCd = sol.OrderApi__Business_Group__r.Mailing_Zip_Code__c;
                    objSol.lOACountry = sol.OrderApi__Business_Group__r.Mailing_Country__c;
                
                    //Location of Recording - Address from Business Group
                    objSol.lORStNameNum = sol.OrderApi__Business_Group__r.Mailing_Street__c;
                    objSol.lORCity = sol.OrderApi__Business_Group__r.Mailing_City__c;
                    objSol.lORStateProv = sol.OrderApi__Business_Group__r.Mailing_State__c;
                    objSol.lORPstlCd = sol.OrderApi__Business_Group__r.Mailing_Zip_Code__c;
                    objSol.lORCountry = sol.OrderApi__Business_Group__r.Mailing_Country__c;
                
                    //Location of Services Performed - Address from the Event's primary Venue 
                    objSol.lSPStNameNum = mapSOLVenue.get(mapSOLEvent.get(sol.Id)).EventApi__Street__c;
                    objSol.lSPCity = mapSOLVenue.get(mapSOLEvent.get(sol.Id)).EventApi__City__c;
                    objSol.lSPStateProv = mapSOLVenue.get(mapSOLEvent.get(sol.Id)).EventApi__State__c;
                    objSol.lSPPstlCd = mapSOLVenue.get(mapSOLEvent.get(sol.Id)).EventApi__Postal_Code__c;
                    objSol.lSPCountry = mapSOLVenue.get(mapSOLEvent.get(sol.Id)).EventApi__Country__c;
                
                    //Location of Use -  Billing Address from SO
                    objSol.lUStNameNum = sol.OrderApi__Sales_Order__r.OrderApi__Billing_Street__c;
                    objSol.lUCity = sol.OrderApi__Sales_Order__r.OrderApi__Billing_City__c;
                    objSol.lUStateProv = sol.OrderApi__Sales_Order__r.OrderApi__Billing_State__c;
                    objSol.lUPstlCd = sol.OrderApi__Sales_Order__r.OrderApi__Billing_Postal_Code__c;
                    objSol.lUCountry = sol.OrderApi__Sales_Order__r.OrderApi__Billing_Country__c;
                
                    //Ship From - Address from Business Group
                    objSol.sFStNameNum = sol.OrderApi__Business_Group__r.Mailing_Street__c;
                    objSol.sFCity = sol.OrderApi__Business_Group__r.Mailing_City__c;
                    objSol.sFStateProv = sol.OrderApi__Business_Group__r.Mailing_State__c;
                    objSol.sFPstlCd = sol.OrderApi__Business_Group__r.Mailing_Zip_Code__c;
                    objSol.sFCountry = sol.OrderApi__Business_Group__r.Mailing_Country__c;
                
                    //Ship To - Mailing Address from SOL
                    objSol.sTStNameNum = sol.OrderApi__Sales_Order__r.OrderApi__Billing_Street__c;
                    objSol.sTCity = sol.OrderApi__Sales_Order__r.OrderApi__Billing_City__c;
                    objSol.sTStateProv = sol.OrderApi__Sales_Order__r.OrderApi__Billing_State__c;
                    objSol.sTPstlCd = sol.OrderApi__Sales_Order__r.OrderApi__Billing_Postal_Code__c;
                    objSol.sTCountry = sol.OrderApi__Sales_Order__r.OrderApi__Billing_Country__c;
                    
                    //Custom Attributes
                    TXWR_IntegrationWrapperClass.CustomAttributesWrapper cusObj = new TXWR_IntegrationWrapperClass.CustomAttributesWrapper();
                    cusObj.ORDERNUMBER = sol.OrderApi__Sales_Order__r.Name;
                    if(string.valueOf(sol.OrderApi__Sales_Order__r.OrderApi__Posted_Date__c) != NULL){
                        cusObj.TAXACCOUNTINGDATE = string.valueOf(sol.OrderApi__Sales_Order__r.OrderApi__Posted_Date__c);
                    } else {
                        Date myDate = Date.Today();
                        String sDate = String.valueOf(myDate);
                        cusObj.TAXACCOUNTINGDATE = sDate;
                    }    
                    objSol.custAttrbs = cusObj;
                    
                
                    lstSOL.add(objSol);                                                                  //Adding to list of wrapper classes
                    
                } 
                
            } 
            else {
                logId = insertApexLogs('Event does not have a primary venue', 'SalesOrderCallout','',logId,'','',NULL,NULL,NULL); //Updating the log if no venue is found
            }
                
            if(!lstSOL.isEmpty()) {
                logId = insertApexLogs('SOLs data processed', 'SalesOrderCallout', '', logId, '', '', NULL, NULL, NULL); //Updating log

                // final body for request
                TXWR_IntegrationWrapperClass.TaxwareRequestWrapper objReqBody = new TXWR_IntegrationWrapperClass.TaxwareRequestWrapper();   //Initialing a new Taxware
                //final body wrapper class
                Taxware_Configuration__c objCS = Taxware_Configuration__c.getValues('Main');                                                //Setting UId and Pwd details
                objReqBody.usrname = objCS.Username__c;
                objReqBody.pswrd = objCS.Password__c;
                objReqBody.isAudit = String.valueOf(aud);                                                                                   //Setting the aud atttribute

                objReqBody.lines.addAll(lstSOL);
                objReqBody.currn = currenyCodeSO;                                                                                            //Adding all the line wrappers

                string finalBody = Json.serialize(objReqBody);                                                                              //This is the final request body

                logId = insertApexLogs('Taxware request built - Sending to TXWR_SOIntQueueable Class', 'SalesOrderCallout', '', logId, '', '', NULL, NULL, NULL);

                TXWR_SOIntQueueable queueObj = new TXWR_SOIntQueueable(mapSOLSO, finalBody, aud, logId);                                       //Call the Queueable class to send the request
                ID jobID = System.enqueueJob(queueObj);                                                                                     //Fetch the job Id

                logId = insertApexLogs('Queuebale InterFace started and job id is: '+jobID, 'SalesOrderCallout','',logId,'','',NULL,NULL,NULL);   //Update the log
            }
        }
    }
    
    public static void receiptCallout(set<Id> rlIds, boolean aud){
        
        String logId = '';
        string currentCodeRec = '';
        
        if(!rlIds.isEmpty()) {
            Map<Id, Id> mapRLR = new Map<Id, Id>();                                         //Map to store the RL Ids and parent Receipt Id
            Map <Id, Id> mapRSO = new Map<Id, Id>();                                        //Map to store the receipt Ids and SO Ids
            Map<Id, Id> mapRLEvent = new Map<Id, Id>();                                     //Map to store the RL Ids and Event Id
            Map<Id, Id> mapRLItm = new Map<Id, Id>();                                       //Map to stpre the RL Ids and Item Ids
            Map<Id, EventApi__Venue__c> mapRLvenue = new Map<Id, EventApi__Venue__c>();     //Map to store the RL Ids and Venue details
            List<OrderApi__Receipt_Line__c> lstRL = new List<OrderApi__Receipt_Line__c>();  //List to store the RL records
            Set<Id> listOfEvents = new Set<Id>();

            lstRL = [
                    SELECT Id,
                            OrderApi__Receipt__c,
                            OrderApi__Total__c,
                            OrderApi__Item__c,
                            OrderApi__Item__r.Tax_With_Taxware__c,
                            OrderApi__Item__r.EventApi__Event__c,
                            OrderApi__Receipt__r.OrderApi__Sales_Order__c,
                            OrderApi__Receipt__r.OrderApi__Sales_Order__r.OrderApi__Billing_Street__c,
                            OrderApi__Receipt__r.OrderApi__Sales_Order__r.OrderApi__Billing_City__c,
                            OrderApi__Receipt__r.OrderApi__Sales_Order__r.OrderApi__Billing_State__c,
                            OrderApi__Receipt__r.OrderApi__Sales_Order__r.OrderApi__Billing_Postal_Code__c,
                            OrderApi__Receipt__r.OrderApi__Sales_Order__r.OrderApi__Billing_Country__c,
                            OrderApi__Business_Group__r.Mailing_Street__c,
                            OrderApi__Business_Group__r.Mailing_City__c,
                            OrderApi__Business_Group__r.Mailing_State__c,
                            OrderApi__Business_Group__r.Mailing_Zip_Code__c,
                            OrderApi__Business_Group__r.Mailing_Country__c,
                            OrderApi__Business_Group__r.Org_Code__c,
                            OrderApi__Item__r.Good_Srv_Code__c,
                            OrderApi__Receipt__r.CurrencyIsoCode
                    FROM OrderApi__Receipt_Line__c
                    WHERE Id IN:rlIds
            ];


            for (OrderApi__Receipt_Line__c rl : lstRL) {
                mapRLR.put(rl.Id, rl.OrderApi__Receipt__c);
                //mapRLItm.put(rl.Id, rl.OrderApi__Item__c);
                //mapRSO.put(rl.OrderApi__Receipt__c, rl.OrderApi__Receipt__r.OrderApi__Sales_Order__c);
                mapRLEvent.put(rl.Id, rl.OrderApi__Item__r.EventApi__Event__c);
            }
            
            for(OrderApi__Receipt_Line__c rl : lstRL){
                listOfEvents.add(mapRLEvent.get(rl.Id));
            }

            for (EventApi__Venue__c v : [
                    SELECT Id,
                            EventApi__Event__c,
                            EventApi__Street__c,
                            EventApi__City__c,
                            EventApi__State__c,
                            EventApi__Country__c,
                            EventApi__Postal_Code__c
                    FROM EventApi__Venue__c
                    WHERE EventApi__Event__c IN: listOfEvents
                    AND EventApi__Is_Primary_Venue__c = TRUE
            ]) {
                mapRLVenue.put(v.EventApi__Event__c, v);
            }

            List<TXWR_IntegrationWrapperClass.SOLDetailWrapper> lstRLwrp = new List<TXWR_IntegrationWrapperClass.SOLDetailWrapper>();

            List<Id> lstR = new List<Id>();
            for (Id i : mapRLR.keySet()) {
                lstR.add(mapRLR.get(i));
            }

            Id RId = lstR[0];
            logId = insertApexLogs('Taxware Receipt Process Started', 'ReceiptCallout', '', '', '', '', null, RId, NULL);                        //Creating the integration log and storing log Id
            for (OrderApi__Receipt_Line__c rl : lstRL) {

                TXWR_IntegrationWrapperClass.SOLDetailWrapper objRL = new TXWR_IntegrationWrapperClass.SOLDetailWrapper();     //Initializing a Taxware Line Wrapper Class
                //and setting all the required attributes
                //Top Attributes
                if (!aud) {
                    objRL.grossAmt = rl.OrderApi__Total__c;
                } else {
                    objRL.grossAmt = -rl.OrderApi__Total__c;
                }
                objRL.discnts = NULL;
                objRL.orgCd = rl.OrderApi__Business_Group__r.Org_Code__c;
                objRL.lnItmId = rl.Id;
                objRL.goodSrvCd = rl.OrderApi__Item__r.Good_Srv_Code__c;
                
                // setting currency
                currentCodeRec = rl.OrderApi__Receipt__r.CurrencyIsoCode;

                //Bill To Address - Billing Address from SO
                objRL.bTStNameNum = rl.OrderApi__Receipt__r.OrderApi__Sales_Order__r.OrderApi__Billing_Street__c;
                objRL.bTCity = rl.OrderApi__Receipt__r.OrderApi__Sales_Order__r.OrderApi__Billing_City__c;
                objRL.bTStateProv = rl.OrderApi__Receipt__r.OrderApi__Sales_Order__r.OrderApi__Billing_State__c;
                objRL.bTPstlCd = rl.OrderApi__Receipt__r.OrderApi__Sales_Order__r.OrderApi__Billing_Postal_Code__c;
                objRL.bTCountry = rl.OrderApi__Receipt__r.OrderApi__Sales_Order__r.OrderApi__Billing_Country__c;

                //Location of Accounts - Address form Business Group
                objRL.lOAStNameNum = rl.OrderApi__Business_Group__r.Mailing_Street__c;
                objRL.lOACity = rl.OrderApi__Business_Group__r.Mailing_City__c;
                objRL.lOAStateProv = rl.OrderApi__Business_Group__r.Mailing_State__c;
                objRL.lOAPstlCd = rl.OrderApi__Business_Group__r.Mailing_Zip_Code__c;
                objRL.lOACountry = rl.OrderApi__Business_Group__r.Mailing_Country__c;

                //Location of Recording - Address from Business Group
                objRL.lORStNameNum = rl.OrderApi__Business_Group__r.Mailing_Street__c;
                objRL.lORCity = rl.OrderApi__Business_Group__r.Mailing_City__c;
                objRL.lORStateProv = rl.OrderApi__Business_Group__r.Mailing_State__c;
                objRL.lORPstlCd = rl.OrderApi__Business_Group__r.Mailing_Zip_Code__c;
                objRL.lORCountry = rl.OrderApi__Business_Group__r.Mailing_Country__c;

                //Location of Services Performed - Address from the Event's primary Venue 
                objRL.lSPStNameNum = mapRLVenue.get(mapRLEvent.get(rl.Id)).EventApi__Street__c ;
                objRL.lSPCity = mapRLVenue.get(mapRLEvent.get(rl.Id)).EventApi__City__c;
                objRL.lSPStateProv = mapRLVenue.get(mapRLEvent.get(rl.Id)).EventApi__State__c;
                objRL.lSPPstlCd = mapRLVenue.get(mapRLEvent.get(rl.Id)).EventApi__Postal_Code__c;
                objRL.lSPCountry = mapRLVenue.get(mapRLEvent.get(rl.Id)).EventApi__Country__c;

                //Location of Use -  Billing Address from SO
                objRL.lUStNameNum = rl.OrderApi__Receipt__r.OrderApi__Sales_Order__r.OrderApi__Billing_Street__c;
                objRL.lUCity = rl.OrderApi__Receipt__r.OrderApi__Sales_Order__r.OrderApi__Billing_City__c;
                objRL.lUStateProv = rl.OrderApi__Receipt__r.OrderApi__Sales_Order__r.OrderApi__Billing_State__c;
                objRL.lUPstlCd = rl.OrderApi__Receipt__r.OrderApi__Sales_Order__r.OrderApi__Billing_Postal_Code__c;
                objRL.lUCountry = rl.OrderApi__Receipt__r.OrderApi__Sales_Order__r.OrderApi__Billing_Country__c;

                //Ship From - Address from Business Group
                objRL.sFStNameNum = rl.OrderApi__Business_Group__r.Mailing_Street__c;
                objRL.sFCity = rl.OrderApi__Business_Group__r.Mailing_City__c;
                objRL.sFStateProv = rl.OrderApi__Business_Group__r.Mailing_State__c;
                objRL.sFPstlCd = rl.OrderApi__Business_Group__r.Mailing_Zip_Code__c;
                objRL.sFCountry = rl.OrderApi__Business_Group__r.Mailing_Country__c;

                //Ship To - Mailing Address from SO
                objRL.sTStNameNum = rl.OrderApi__Receipt__r.OrderApi__Sales_Order__r.OrderApi__Billing_Street__c;
                objRL.sTCity = rl.OrderApi__Receipt__r.OrderApi__Sales_Order__r.OrderApi__Billing_City__c;
                objRL.sTStateProv = rl.OrderApi__Receipt__r.OrderApi__Sales_Order__r.OrderApi__Billing_State__c;
                objRL.sTPstlCd = rl.OrderApi__Receipt__r.OrderApi__Sales_Order__r.OrderApi__Billing_Postal_Code__c;
                objRL.sTCountry = rl.OrderApi__Receipt__r.OrderApi__Sales_Order__r.OrderApi__Billing_Country__c;

                lstRLwrp.add(objRL);                                                                  //Adding to list of wrapper classes
            }

            if (!lstRLwrp.isEmpty()) {
                logId = insertApexLogs('RLs data processed', 'ReceiptCallout', '', logId, '', '', NULL, NULL, NULL); //Updating log

                // final body for request
                TXWR_IntegrationWrapperClass.TaxwareRequestWrapper objReqBody = new TXWR_IntegrationWrapperClass.TaxwareRequestWrapper();        //Initialing a new Taxware
                //final body wrapper class
                Taxware_Configuration__c objCS = Taxware_Configuration__c.getValues('Main');                                                     //Setting UId and Pwd details
                objReqBody.usrname = objCS.Username__c;
                objReqBody.pswrd = objCS.Password__c;
                objReqBody.isAudit = String.valueOf(aud);                                                                                        //Setting the aud atttribute

                objReqBody.lines.addAll(lstRLwrp); 
                objReqBody.currn = currentCodeRec;                                                                                               //Adding all the line wrappers

                string finalBody = Json.serialize(objReqBody);                                                                                   //This is the final request body

                logId = insertApexLogs('Taxware request built - Sending to TXWR_RCIntQueueable Class', 'ReceiptCallout', '', logId, '', '', NULL, NULL, NULL);

                TXWR_RCIntQueueable queueObj = new TXWR_RCIntQueueable(mapRLR, finalBody, aud, logId);                                              //Call the Queueable class to send the request
                ID jobID = System.enqueueJob(queueObj);                                                                                          //Fetch the job Id

                logId = insertApexLogs('Queuebale InterFace started and job id is: '+jobID, 'ReceiptCallout','',logId,'','',NULL,NULL,NULL);   //Update the log

            }
        }
    }
    
    /**
     * This method insert Log object record when any apex error is there
     * or the callout not done due to some data not present
     **/

    public static string insertApexLogs(string descrip, string MethodName, string MethodLine, string recId, string requestBody, string responseBody, Id SId, Id RId, id ILId){
        
        //Id devRecordTypeId = Schema.SObjectType.Integration_Log__c.getRecordTypeInfosByName().get('Apex').getRecordTypeId();
        Taxware_Configuration__c objCS = Taxware_Configuration__c.getValues('Main');
        
        // instance of logs object
        Integration_Log__c log = new Integration_Log__c();
        if(SId != NULL){
            log.Sales_Order__c = SId;
        }
        if(RId != NULL){
            log.Receipt__c = RId;
        }
        if(ILId != NULL){
            log.CFAMN__Invoice_Line__c = ILId;
        }

        List<String> details = new List<String>();

        // getting record details
        if(!string.isEmpty(recId)){
            log = [SELECT ID,
                          Logs_Details__c,
                          Request_Body__c,
                          Response__c,
                          Method_Line__c,
                          Method_Name__c,
                          Apex_Error_Description__c
                          FROM Integration_Log__c
                          WHERE ID = :recId];
        }
        if(!string.isBlank(log.Logs_Details__c)){
            log.Logs_Details__c += '\n---Starts---\n' +descrip ;

        }
        else{
            log.Logs_Details__c = '---Starts---\n' +descrip ;
        }
       
        log.Logs_Details__c += (MethodName != null && MethodName != '') ? ('\n Method Name : '+MethodName) : '';
        log.Logs_Details__c += (MethodLine != null && MethodLine != '') ? ('\n Line No. incase of Error : ' +MethodLine ) : '';
        log.Logs_Details__c +='  \n---ends---';
        // if request body is not blank
        if(!string.isEmpty(requestBody)){
            requestBody = requestBody.replace(objCS.Username__c, '#######');
            requestBody = requestBody.replace(objCS.Password__c, '*******');
            log.Request_Body__c = requestBody;
        }
       
        // if response body is not blank
        if(!string.isEmpty(requestBody)){
            log.Response__c = responseBody;
        }
        
        upsert log;      
        return log.id;
    }

    /**
      * This will insert the SOL
      * based upon the information from Response
     **/
     public static void insertSOL(TXWR_IntegrationWrapperClass.SOLResponseDetails response, Map<Id,Id> mapSOLInformation,string SFLogId){
         
         try{
             insertApexLogs('Attempting to build tax SOLs', 'insertSOL','',SFLogId,'','',NULL,NULL,NULL);
             List<Id> setSOLs = new List<Id>();
             Set<Id> setSO = new Set<Id>();
             List<OrderApi__Sales_Order__c> lstSO = new List<OrderApi__Sales_Order__c>();
             
             for(TXWR_IntegrationWrapperClass.linesDetails tempSOL : response.lnRslts){
                 if(mapSOLInformation.containsKey(tempSOL.lnId)){
                     setSOLs.add(mapSOLInformation.get(tempSOL.lnId));
                 }
             }

             if(!setSOLs.isEmpty()){
                 insertApexLogs('Tax SOLs found in response', 'insertSOL','',SFLogId,'','',NULL,NULL,NULL);
             }
             Id bGroup = [Select OrderApi__Business_Group__c FROM OrderApi__Sales_Order__c WHERE ID in: setSOLs].OrderApi__Business_Group__c;
             Id taxClass = [Select Item_Class__c FROM OrderApi__Business_Group__c WHERE ID =: bGroup].Item_Class__c;
             Id taxLocale = [Select Tax_Locale__c FROM OrderApi__Business_Group__c WHERE ID =: bGroup].Tax_Locale__c;
             
             set<string> setName = new set<string>();
             
             List<OrderApi__Sales_Order_Line__c> lstSOL = new List<OrderApi__Sales_Order_Line__c>();
             
             for(TXWR_IntegrationWrapperClass.linesDetails tempSOL : response.lnRslts){
                 if(mapSOLInformation.containsKey(tempSOL.lnId)){
                     string SoID = mapSOLInformation.get(tempSOL.lnId);
                     string parentSOLId = tempSOL.lnId;
                     if(tempSOL.jurRslts != null){
                         for(TXWR_IntegrationWrapperClass.SOLDetails tempRes : tempSOL.jurRslts){
                             setName.add(tempRes.txName);
                         }
                     }
                 }
             }
             
             Map<String,OrderApi__Item__c> mapItemDetails = new Map<String,OrderApi__Item__c>();
             
             for(OrderApi__Item__c item : [SELECT Id,Name FROM OrderApi__Item__c where Name IN :setName AND OrderApi__Business_Group__c =: bGroup] ){  
                 mapItemDetails.put(item.Name,item);
             }
             
             List<OrderApi__Item__c> lstinsert = new List<OrderApi__Item__c>();
             for(string item : setName){
                 if(!mapItemDetails.containsKey(item)){
                     insertApexLogs('Tax Item not found - Creating new Item: '+item, 'insertSOL','',SFLogId,'','',NULL,NULL,NULL);
                     OrderApi__Item__c ite = new OrderApi__Item__c();
                     ite.Name = item;
                     ite.OrderApi__Price__c = 0;
                     ite.OrderApi__Item_Class__c = taxClass; 
                     ite.OrderApi__Is_Tax__c  = true;
                     ite.OrderApi__Tax_Locale__c = taxLocale; 
                     
                     lstinsert.add(ite);
                 } else {
                     insertApexLogs('Tax Item Found: '+item, 'insertSOL','',SFLogId,'','',NULL,NULL,NULL);
                 }
             }
             
             if(!lstinsert.isEmpty()){
                 insert lstinsert;
                 insertApexLogs('Inserted new tax Items', 'insertSOL','',SFLogId,'','',NULL,NULL,NULL);
             }
             
             for(OrderApi__Item__c item : lstinsert){
                 mapItemDetails.put(item.Name,item);
             }
             
             for(TXWR_IntegrationWrapperClass.linesDetails tempSOL : response.lnRslts){
                 if(mapSOLInformation.containsKey(tempSOL.lnId)){
                     string SoID = mapSOLInformation.get(tempSOL.lnId);
                     string parentSolId = tempSOL.lnId;
                     
                     if(tempSOL.jurRslts != null){
                         for(TXWR_IntegrationWrapperClass.SOLDetails tempRes : tempSOL.jurRslts){
                             OrderApi__Sales_Order_Line__c objSOL = new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c = SoID,
                                                                                                      OrderApi__Item__c = mapItemDetails.get(tempRes.txName).Id,
                                                                                                      OrderApi__System_Override__c = TRUE,
                                                                                                      OrderApi__Is_Tax__c = TRUE,
                                                                                                      OrderApi__Is_Valid__c = TRUE,
                                                                                                      OrderApi__Sale_Price__c = decimal.valueOf(tempRes.txAmt),
                                                                                                      OrderApi__Sales_Order_Line__c = parentSolId,
                                                                                                      OrderApi__Line_Description__c = tempRes.txName,
                                                                                                      OrderApi__Price_Override__c = TRUE);
                         
                             lstSOL.add(objSOL);
                         }
                     }
                 }
             }
             
             if(!lstSOL.isEmpty()){
                 insert lstSOL;
                 insertApexLogs('New tax SOLs inserted', 'insertSOL','',SFLogId,'','',NULL,NULL,NULL);
                 for(OrderApi__Sales_Order_Line__c sol : lstSOL){
                     setSO.add(sol.OrderApi__Sales_Order__c);
                 }
                 for(OrderApi__Sales_Order__c so : [SELECT Id, 
                                                           OrderApi__Processing_Changes__c
                                                           FROM OrderApi__Sales_Order__c
                                                           WHERE Id IN: setSO]){
                    so.OrderApi__Processing_Changes__c = FALSE;
                    lstSO.add(so);
                }
                update lstSO;
             }
         }
         catch(Exception ex){
             insertApexLogs(string.valueOf(ex), 'insertSOL',String.valueOf(ex.getLineNumber()),SFLogId,'','',NULL,NULL,NULL);
         }
     }

    /**
      * This will insert the RL
      * based upon the information from Response
     **/
    public static void insertRL(TXWR_IntegrationWrapperClass.SOLResponseDetails response, Map<Id,Id> mapRLInformation,string SFLogId){

        try{
            insertApexLogs('Attempting to build tax RLs', 'insertRL','',SFLogId,'','',NULL,NULL,NULL);
            //getting the tax class and tax locale from the business group
            list<ID> setRLs = new list<ID>();
            Set<Id> setRC = new Set<Id>();
            List<OrderApi__Receipt__c> lstR = new List<OrderApi__Receipt__c>();
            for(TXWR_IntegrationWrapperClass.linesDetails tempRL : response.lnRslts){
                if(mapRLInformation.containsKey(tempRL.lnId)){
                    setRLs.add(mapRLInformation.get(tempRL.lnId));
                }
            }

            if(!setRLs.isEmpty()){
                insertApexLogs('Tax RLs found in response', 'insertRL','',SFLogId,'','',NULL,NULL,NULL);
            }

            Id bGroup = [Select OrderApi__Business_Group__c FROM OrderApi__Receipt__c WHERE ID in: setRLs].OrderApi__Business_Group__c;

            Id taxClass = [Select Item_Class__c FROM OrderApi__Business_Group__c WHERE ID =: bGroup].Item_Class__c;

            Id taxLocale = [Select Tax_Locale__c FROM OrderApi__Business_Group__c WHERE ID =: bGroup].Tax_Locale__c;

            // will save txname
            set<string> setName = new set<string>();

            // will save list of RL to be inserted
            List<OrderApi__Receipt_Line__c> lstRL = new List<OrderApi__Receipt_Line__c>();

            // iterating the lines from response
            for(TXWR_IntegrationWrapperClass.linesDetails tempRL : response.lnRslts) {

                if (mapRLInformation.containsKey(tempRL.lnId)) {

                    if (tempRL.jurRslts != null) {

                        for (TXWR_IntegrationWrapperClass.SOLDetails tempRes : tempRL.jurRslts) {

                            setName.add(tempRes.txName);

                        }
                    }
                }
            }

            map<string,OrderApi__Item__c> mapItemDetails = new map<string,OrderApi__Item__c>();

            // getting items
            for(OrderApi__Item__c item : [SELECT Id,Name FROM OrderApi__Item__c where Name IN :setName AND OrderApi__Business_Group__c =: bGroup] ){ //added bgrpup condition by Nik March 17th
                mapItemDetails.put(item.Name,item);
            }

            // iterating the lines from response
            for(TXWR_IntegrationWrapperClass.linesDetails tempRL : response.lnRslts){

                if(mapRLInformation.containsKey(tempRL.lnId)){

                    string RLID = mapRLInformation.get(tempRL.lnId);

                    string parentRLId = tempRL.lnId;

                    if(tempRL.jurRslts != null){

                        for(TXWR_IntegrationWrapperClass.SOLDetails tempRes : tempRL.jurRslts){

                            OrderApi__Receipt_Line__c objRL = new OrderApi__Receipt_Line__c(OrderApi__Receipt__c = RLID,
                                    OrderApi__Item__c = mapItemDetails.get(tempRes.txName).Id,
                                    OrderApi__Tax_Override__c = TRUE,
                                    OrderApi__Is_Tax__c = TRUE,
                                    OrderApi__Sale_Price__c = math.abs(decimal.valueOf(tempRes.txAmt)),
                                    OrderApi__Receipt_Line__c = parentRLId,
                                    OrderApi__Price_Override__c = true
                            );
                            lstRL.add(objRL);

                        }
                    }
                }
            }

            if(!lstRL.isEmpty()){
                insert lstRL;
                insertApexLogs('New tax RLs inserted', 'insertRL','',SFLogId,'','',NULL,NULL,NULL);
                for(OrderApi__Receipt_Line__c rl : lstRL){
                    setRC.add(rl.OrderApi__Receipt__c);
                }
                for(OrderApi__Receipt__c r : [SELECT Id, Processing_Changes__c FROM OrderApi__Receipt__c WHERE Id IN: setRC]){
                    r.Processing_Changes__c = FALSE;
                    lstR.add(r);
                }
                update lstR;
            }
        }
        catch(Exception ex){
            insertApexLogs(string.valueOf(ex), 'insertRL',String.valueOf(ex.getLineNumber()),SFLogId,'','',NULL,NULL,NULL);
        }
    }
    
    /***** 
     * This methdod will be used to make callout for the Invoice Lines 
     */
     public static void InvoiceLineCallout(set<Id> invoiceLines, boolean aud){
        
        String logId = '';
        
        // saving the curreny code
        string currentCodeRec = '';
        
        if(!invoiceLines.isEmpty()) {
            Map<Id, Id> mapILI = new Map<Id, Id>();                                         //Map to store the IL Ids and parent Invoice Id
            Map <Id, Id> mapILSO = new Map<Id, Id>();                                        //Map to store the receipt Ids and SO Ids
            Map<Id, Id> mapILEvent = new Map<Id, Id>();                                     //Map to store the RL Ids and Event Id
            Map<Id, Id> mapILItm = new Map<Id, Id>();                                       //Map to stpre the RL Ids and Item Ids
            Map<Id, EventApi__Venue__c> mapILvenue = new Map<Id, EventApi__Venue__c>();     //Map to store the RL Ids and Venue details
            List<OrderApi__Invoice_Line__c> lstIL = new List<OrderApi__Invoice_Line__c>();  //List to store the RL records
            Set<Id> listOfEvents = new Set<Id>();

            lstIL = [
                    SELECT Id,
                            OrderApi__Invoice__c,
                            OrderApi__Total__c,
                            OrderApi__Item__c,
                            OrderApi__Item__r.Tax_With_Taxware__c,
                            OrderApi__Item__r.EventApi__Event__c,
                            OrderApi__Invoice__r.OrderApi__Sales_Order__c,
                            OrderApi__Invoice__r.OrderApi__Sales_Order__r.OrderApi__Billing_Street__c,
                            OrderApi__Invoice__r.OrderApi__Sales_Order__r.OrderApi__Billing_City__c,
                            OrderApi__Invoice__r.OrderApi__Sales_Order__r.OrderApi__Billing_State__c,
                            OrderApi__Invoice__r.OrderApi__Sales_Order__r.OrderApi__Billing_Postal_Code__c,
                            OrderApi__Invoice__r.OrderApi__Sales_Order__r.OrderApi__Billing_Country__c,
                            OrderApi__Business_Group__r.Mailing_Street__c,
                            OrderApi__Business_Group__r.Mailing_City__c,
                            OrderApi__Business_Group__r.Mailing_State__c,
                            OrderApi__Business_Group__r.Mailing_Zip_Code__c,
                            OrderApi__Business_Group__r.Mailing_Country__c,
                            OrderApi__Business_Group__r.Org_Code__c,
                            OrderApi__Item__r.Good_Srv_Code__c,
                            OrderApi__Invoice__r.CurrencyIsoCode
                    FROM OrderApi__Invoice_Line__c
                    WHERE Id IN:invoiceLines];


            for (OrderApi__Invoice_Line__c il : lstIL) {
                mapILI.put(il.Id, il.OrderApi__Invoice__c);
                mapILEvent.put(il.Id, il.OrderApi__Item__r.EventApi__Event__c);
            }

            for(OrderApi__Invoice_Line__c il : lstIL){
                listOfEvents.add(mapILEvent.get(il.Id));
            }

            for (EventApi__Venue__c v : [
                    SELECT Id,
                            EventApi__Event__c,
                            EventApi__Street__c,
                            EventApi__City__c,
                            EventApi__State__c,
                            EventApi__Country__c,
                            EventApi__Postal_Code__c
                    FROM EventApi__Venue__c
                    WHERE EventApi__Event__c IN: listOfEvents
                    AND EventApi__Is_Primary_Venue__c = TRUE
            ]) {
                mapILvenue.put(v.EventApi__Event__c, v);
            }        
            
            List<TXWR_IntegrationWrapperClass.SOLDetailWrapper> lstILwrp = new List<TXWR_IntegrationWrapperClass.SOLDetailWrapper>();

            List<Id> lstI = new List<Id>();
            for (Id i : mapILI.keySet()) {
                lstI.add(mapILI.get(i));
            }

            Id ILId = lstI[0];
            logId = insertApexLogs('Taxware Invoice Line Process Started', 'InvoiceCallout', '', '', '', '', NULL,NULL,lstIL[0].Id);                        //Creating the integration log and storing log Id
            
            
            for (OrderApi__Invoice_Line__c il : lstIL) {

                TXWR_IntegrationWrapperClass.SOLDetailWrapper objIL = new TXWR_IntegrationWrapperClass.SOLDetailWrapper();     //Initializing a Taxware Line Wrapper Class
                //and setting all the required attributes
                //Top Attributes
                if (!aud) {
                    objIL.grossAmt = il.OrderApi__Total__c;
                } else {
                    objIL.grossAmt = -il.OrderApi__Total__c;
                }
                objIL.discnts = NULL;
                objIL.orgCd = il.OrderApi__Business_Group__r.Org_Code__c;
                objIL.lnItmId = il.Id;
                objIL.goodSrvCd = il.OrderApi__Item__r.Good_Srv_Code__c;
        
                // setting current
                currentCodeRec = il.OrderApi__Invoice__r.CurrencyIsoCode;
        
                //Bill To Address - Billing Address from SO
                objIL.bTStNameNum = il.OrderApi__Invoice__r.OrderApi__Sales_Order__r.OrderApi__Billing_Street__c;
                objIL.bTCity = il.OrderApi__Invoice__r.OrderApi__Sales_Order__r.OrderApi__Billing_City__c;
                objIL.bTStateProv = il.OrderApi__Invoice__r.OrderApi__Sales_Order__r.OrderApi__Billing_State__c;
                objIL.bTPstlCd = il.OrderApi__Invoice__r.OrderApi__Sales_Order__r.OrderApi__Billing_Postal_Code__c;
                objIL.bTCountry = il.OrderApi__Invoice__r.OrderApi__Sales_Order__r.OrderApi__Billing_Country__c;

                //Location of Accounts - Address form Business Group
                objIL.lOAStNameNum = il.OrderApi__Business_Group__r.Mailing_Street__c;
                objIL.lOACity = il.OrderApi__Business_Group__r.Mailing_City__c;
                objIL.lOAStateProv = il.OrderApi__Business_Group__r.Mailing_State__c;
                objIL.lOAPstlCd = il.OrderApi__Business_Group__r.Mailing_Zip_Code__c;
                objIL.lOACountry = il.OrderApi__Business_Group__r.Mailing_Country__c;

                //Location of Recording - Address from Business Group
                objIL.lORStNameNum = il.OrderApi__Business_Group__r.Mailing_Street__c;
                objIL.lORCity = il.OrderApi__Business_Group__r.Mailing_City__c;
                objIL.lORStateProv = il.OrderApi__Business_Group__r.Mailing_State__c;
                objIL.lORPstlCd = il.OrderApi__Business_Group__r.Mailing_Zip_Code__c;
                objIL.lORCountry = il.OrderApi__Business_Group__r.Mailing_Country__c;

                //Location of Services Performed - Address from the Event's primary Venue 
                objIL.lSPStNameNum = mapILvenue.get(mapILEvent.get(il.Id)).EventApi__Street__c ;
                objIL.lSPCity = mapILvenue.get(mapILEvent.get(il.Id)).EventApi__City__c;
                objIL.lSPStateProv = mapILvenue.get(mapILEvent.get(il.Id)).EventApi__State__c;
                objIL.lSPPstlCd = mapILvenue.get(mapILEvent.get(il.Id)).EventApi__Postal_Code__c;
                objIL.lSPCountry = mapILvenue.get(mapILEvent.get(il.Id)).EventApi__Country__c;

                //Location of Use -  Billing Address from SO
                objIL.lUStNameNum = il.OrderApi__Invoice__r.OrderApi__Sales_Order__r.OrderApi__Billing_Street__c;
                objIL.lUCity = il.OrderApi__Invoice__r.OrderApi__Sales_Order__r.OrderApi__Billing_City__c;
                objIL.lUStateProv = il.OrderApi__Invoice__r.OrderApi__Sales_Order__r.OrderApi__Billing_State__c;
                objIL.lUPstlCd = il.OrderApi__Invoice__r.OrderApi__Sales_Order__r.OrderApi__Billing_Postal_Code__c;
                objIL.lUCountry = il.OrderApi__Invoice__r.OrderApi__Sales_Order__r.OrderApi__Billing_Country__c;

                //Ship From - Address from Business Group
                objIL.sFStNameNum = il.OrderApi__Business_Group__r.Mailing_Street__c;
                objIL.sFCity = il.OrderApi__Business_Group__r.Mailing_City__c;
                objIL.sFStateProv = il.OrderApi__Business_Group__r.Mailing_State__c;
                objIL.sFPstlCd = il.OrderApi__Business_Group__r.Mailing_Zip_Code__c;
                objIL.sFCountry = il.OrderApi__Business_Group__r.Mailing_Country__c;

                //Ship To - Mailing Address from SO
                objIL.sTStNameNum = il.OrderApi__Invoice__r.OrderApi__Sales_Order__r.OrderApi__Billing_Street__c;
                objIL.sTCity = il.OrderApi__Invoice__r.OrderApi__Sales_Order__r.OrderApi__Billing_City__c;
                objIL.sTStateProv = il.OrderApi__Invoice__r.OrderApi__Sales_Order__r.OrderApi__Billing_State__c;
                objIL.sTPstlCd = il.OrderApi__Invoice__r.OrderApi__Sales_Order__r.OrderApi__Billing_Postal_Code__c;
                objIL.sTCountry = il.OrderApi__Invoice__r.OrderApi__Sales_Order__r.OrderApi__Billing_Country__c;

                lstILwrp.add(objIL);                                                                  //Adding to list of wrapper classes
            }

            if (!lstILwrp.isEmpty()) {
                logId = insertApexLogs('ILs data processed', 'InvoiceCallout', '', logId, '', '', NULL, NULL, NULL); //Updating log

                // final body for request
                TXWR_IntegrationWrapperClass.TaxwareRequestWrapper objReqBody = new TXWR_IntegrationWrapperClass.TaxwareRequestWrapper();        //Initialing a new Taxware
                //final body wrapper class
                Taxware_Configuration__c objCS = Taxware_Configuration__c.getValues('Main');                                                     //Setting UId and Pwd details
                objReqBody.usrname = objCS.Username__c;
                objReqBody.pswrd = objCS.Password__c;
                objReqBody.isAudit = String.valueOf(aud);                                                                                        //Setting the aud atttribute

                objReqBody.lines.addAll(lstILwrp);                                                                                               //Adding all the line wrappers
                
                objReqBody.currn = currentCodeRec;                                                                                           // setting currency

                string finalBody = Json.serialize(objReqBody);                                                                                   //This is the final request body

                logId = insertApexLogs('Taxware request built - Sending to TXWR_ILIntQueueable Class', 'InvoiceCallout', '', logId, '', '', NULL, NULL, NULL);

                TXWR_ILIntQueueable queueObj = new TXWR_ILIntQueueable(mapILI, finalBody, aud, logId);                                              //Call the Queueable class to send the request
                ID jobID = System.enqueueJob(queueObj);                                                                                          //Fetch the job Id

                logId = insertApexLogs('Queuebale InterFace started and job id is: '+jobID, 'InvoiceCallout','',logId,'','',NULL,NULL,NULL);   //Update the log

            }
            
        }
    }
    
    /**
      * This will insert the IL
      * based upon the information from Response
     **/
    public static void insertIL(TXWR_IntegrationWrapperClass.SOLResponseDetails response, Map<Id,Id> mapILInformation,string SFLogId){

        try{
            insertApexLogs('Attempting to build tax ILs', 'insertIL','',SFLogId,'','',NULL,NULL,NULL);
            //getting the tax class and tax locale from the business group
            list<ID> setILs = new list<ID>();
            Set<Id> setRC = new Set<Id>();
            List<OrderApi__Receipt__c> lstR = new List<OrderApi__Receipt__c>();
            for(TXWR_IntegrationWrapperClass.linesDetails tempIL : response.lnRslts){
                if(mapILInformation.containsKey(tempIL.lnId)){
                    setILs.add(mapILInformation.get(tempIL.lnId));
                }
            }

            if(!setILs.isEmpty()){
                insertApexLogs('Tax ILs found in response', 'insertIL','',SFLogId,'','',NULL,NULL,NULL);
            }

            Id bGroup = [Select OrderApi__Business_Group__c FROM OrderApi__Invoice__c WHERE ID in: setILs].OrderApi__Business_Group__c;

            Id taxClass = [Select CFAMN__Item_Class__c FROM OrderApi__Business_Group__c WHERE ID =: bGroup].CFAMN__Item_Class__c;

            Id taxLocale = [Select CFAMN__Tax_Locale__c FROM OrderApi__Business_Group__c WHERE ID =: bGroup].CFAMN__Tax_Locale__c;

            // will save txname
            set<string> setName = new set<string>();

            // will save list of RL to be inserted
            List<OrderApi__Invoice_Line__c> lstIL = new List<OrderApi__Invoice_Line__c>();

            // iterating the lines from response
            for(TXWR_IntegrationWrapperClass.linesDetails tempIL : response.lnRslts) {

                if (mapILInformation.containsKey(tempIL.lnId)) {
                    
                    if (tempIL.jurRslts != null) {
                        for (TXWR_IntegrationWrapperClass.SOLDetails tempRes : tempIL.jurRslts) {
                            setName.add(tempRes.txName);

                        }
                    }
                }
            }

            map<string,OrderApi__Item__c> mapItemDetails = new map<string,OrderApi__Item__c>();

            // getting items
            for(OrderApi__Item__c item : [SELECT Id,Name FROM OrderApi__Item__c where Name IN :setName AND OrderApi__Business_Group__c =: bGroup] ){ //added bgrpup condition by Nik March 17th
                mapItemDetails.put(item.Name,item);
            }

            // iterating the lines from response
            for(TXWR_IntegrationWrapperClass.linesDetails tempIL : response.lnRslts){

                if(mapILInformation.containsKey(tempIL.lnId)){

                    string ILID = mapILInformation.get(tempIL.lnId);

                    string parentILID = tempIL.lnId;

                    if(tempIL.jurRslts != null){
                        
                        for(TXWR_IntegrationWrapperClass.SOLDetails tempRes : tempIL.jurRslts){
                            OrderApi__Invoice_Line__c objRL = new OrderApi__Invoice_Line__c(OrderApi__Invoice__c = ILID,
                                    OrderApi__Item__c = mapItemDetails.get(tempRes.txName).Id,
                                    OrderApi__Tax_Override__c = TRUE,
                                    OrderApi__Is_Tax__c = TRUE,
                                    OrderApi__Sale_Price__c = math.abs(decimal.valueOf(tempRes.txAmt)),
                                    CFAMN__Parent_Invoice_Line__c = parentILID,
                                    OrderApi__Price_Override__c = true,
                                    OrderApi__Is_Adjustment__c = true
                            );
                            lstIL.add(objRL);

                        }
                    }
                }
            }

            if(!lstIL.isEmpty()){
                insert lstIL;
                insertApexLogs('New tax ILs inserted', 'insertIL','',SFLogId,'','',NULL,NULL,NULL);
                for(OrderApi__Invoice_Line__c rl : lstIL){
                    setRC.add(rl.OrderApi__Invoice__c);
                }
                /***
                for(OrderApi__Invoice__c r : [SELECT Id, Processing_Changes__c FROM OrderApi__Invoice__c WHERE Id IN: setRC]){
                    r.Processing_Changes__c = FALSE;
                    lstR.add(r);
                }
                update lstR;
                **/
            }
        }
        catch(Exception ex){
            insertApexLogs(string.valueOf(ex), 'insertIL',String.valueOf(ex.getLineNumber()),SFLogId,'','',NULL,NULL,NULL);
        }
    }
    
}