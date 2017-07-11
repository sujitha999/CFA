public without sharing class TXWR_SOIntQueueable implements Queueable,Database.AllowsCallouts{
    
    //FINAL static string ENDPOINT = 'https://sstwsuat.taxware.net/Twe/api/rest/calcTax/doc'; 
    FINAL static Integer STATUSCODE = 200;
    
    public HttpRequest req;
    public map<Id, Id> mapSOLInformation {get;set;}
    public string body                   {get;set;}
    public boolean aud                   {get;set;}
    public string logId                  {get;set;}
    
    public TXWR_SOIntQueueable(){
         
    }
    
    public TXWR_SOIntQueueable(Map<Id, Id> mapSOLInformation, string body, boolean aud, string logId){    //Creating the Queueable job
        this.mapSOLInformation = mapSOLInformation;
        this.body = body;
        this.aud = aud;
        this.logId = logId;
    }
    
     public void execute(QueueableContext context){
         req = new HttpRequest();
         Taxware_Configuration__c objCS = Taxware_Configuration__c.getValues('Main');                   //Fetching the taxware config custom settings 
         
         string DateTimeFormat = datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
         string DateTimeFormat1 = DateTimeFormat.substring(0, DateTimeFormat.length()-2);
         string DateTimeFormat2 = DateTimeFormat.substring(DateTimeFormat.length()-2, DateTimeFormat.length());
         DateTimeFormat = DateTimeFormat1 + ':' + DateTimeFormat2;                                      //Building datetime parameter in the required format
         
         string message = 'POSTapplication/json'+DateTimeFormat+'/Twe/api/rest/calcTax/doc'+objCS.Username__c+objCS.Password__c;
         string secretKey = objCS.Secret_Key__c;
         Blob hash = crypto.generateMac('hmacSHA1',Blob.valueOf(message), Blob.valueOf(secretKey));     //Performing required encryption
         
         String auth = 'TAX '+objCS.Username__c+':'+EncodingUtil.base64Encode(hash);                    //Builiding the authorization header
                                                                                                        //and setting the auth parameters
         req.setEndpoint(objCS.Endpoint__c);                                
         req.setMethod('POST');
         req.setHeader('Content-Type','application/json');
         req.setHeader('Date',DateTimeFormat);
         req.setHeader('Authorization', auth);
         req.setBody(body);
         
         Http h = new Http();
         HttpResponse res = h.send(req);                                                               //Send request and get response
         string strBody = res.getBody().trim();                                                        //store response and status codes
         Integer intStatusCode =  res.getStatusCode();
         
         TXWR_CalloutClass.insertApexLogs('Taxware response recieved','TXWR_SOIntQueueable', '',logId,body,strBody,NULL,NULL,NULL);  //Updating log
         
         if(!string.isEmpty(strBody)){                                                                  //checking response and status code
             if(intStatusCode == STATUSCODE){                                                           //and parsing the response
                 TXWR_IntegrationWrapperClass.SOLResponseDetails objResponseBody = (TXWR_IntegrationWrapperClass.SOLResponseDetails)System.JSON.deserialize(res.getBody().trim(), TXWR_IntegrationWrapperClass.SOLResponseDetails.class);
                 if(!aud){                                                                 //checking if calculation or commit
                    TXWR_CalloutClass.insertSOL(objResponseBody,mapSOLInformation,logId);  //Calling the method to insert SOLs based on the parsed response
                 }
             }
         }
     }

}