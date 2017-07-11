/**
 * Created by Nikilesh Kopparthi on 4/14/17.
 */

public with sharing class TXWR_ILIntQueueable implements Queueable,Database.AllowsCallouts{

    FINAL static Integer STATUSCODE = 200;

    public HttpRequest req;
    public map<Id, Id> mapILInformation  {get;set;}
    public string body                   {get;set;}
    public boolean aud                   {get;set;}
    public string logId                  {get;set;}

    public TXWR_ILIntQueueable(){

    }

    public TXWR_ILIntQueueable(Map<Id,Id> mapILInformation, String body, boolean aud, String logId){
        this.mapILInformation = mapILInformation;
        this.body = body;
        this.aud = aud;
        this.logId = logId;
    }

    public void execute(QueueableContext context){
        req = new HttpRequest();
        Taxware_Configuration__c objCS = Taxware_Configuration__c.getValues('Main');

        string DateTimeFormat = datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        string DateTimeFormat1 = DateTimeFormat.substring(0, DateTimeFormat.length()-2);
        string DateTimeFormat2 = DateTimeFormat.substring(DateTimeFormat.length()-2, DateTimeFormat.length());
        DateTimeFormat = DateTimeFormat1 + ':' + DateTimeFormat2;

        string message = 'POSTapplication/json'+DateTimeFormat+'/Twe/api/rest/calcTax/doc'+objCS.Username__c+objCS.Password__c;
        string secretKey = objCS.Secret_Key__c;
        Blob hash = crypto.generateMac('hmacSHA1',Blob.valueOf(message), Blob.valueOf(secretKey));

        String auth = 'TAX '+objCS.Username__c+':'+EncodingUtil.base64Encode(hash);

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

        TXWR_CalloutClass.insertApexLogs('Taxware response recieved','TXWR_ILIntQueueable', '',logId,body,strBody,NULL,NULL,NULL);  //Updating log

        if(!string.isEmpty(strBody)){
            TXWR_IntegrationWrapperClass.SOLResponseDetails objResponseBody = (TXWR_IntegrationWrapperClass.SOLResponseDetails)System.JSON.deserialize(res.getBody().trim(), TXWR_IntegrationWrapperClass.SOLResponseDetails.class);
            if(!aud){
                TXWR_CalloutClass.insertIL(objResponseBody,mapILInformation,logId);
            }
        }
    }
}