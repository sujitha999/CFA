public class taxwareConfigController {

    public Taxware_Configuration__c txConfig {get; set;}
    public List<Taxware_Configuration__c> lstTxConfig {get; set;}
    
    public taxwareConfigController(){
    
    lstTxConfig = [SELECT Id,
                       Name,
                       Endpoint__c,
                       Password__c,
                       Secret_Key__c,
                       Username__c
                       FROM Taxware_Configuration__c
                       WHERE Name = 'Main'
                       LIMIT 1];
                       
    if(lstTxConfig.size() > 0){
        txConfig = lstTxConfig[0];
    } else {
        txConfig = new Taxware_Configuration__c();
    }
    
    }
    
    public PageReference save(){
    txconfig.Name = 'Main';
    upsert txConfig;
    PageReference Page = new PageReference('/home/home.jsp');
    //Page.setRedirect(true);
    return Page;
    
    }

}