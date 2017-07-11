global class deleteCASLBadges implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        string query = 'select ID'
                                +' ,OrderApi__Is_Active__c'
                                +' ,Created_By_Trigger__c'
                            +' FROM OrderApi__Badge__c'
                            +' WHERE OrderApi__Expired_Date__c < TODAY'
                            +' AND OrderApi__Expired_Date__c != null'
                            +' AND OrderApi__Is_Active__c = true';
        system.debug('\n--query--'+query);
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC,List <sobject> scope){
        List <OrderApi__Badge__c> lstBadge = new list<OrderApi__Badge__c>();
        for(Sobject s : scope)
        {
            OrderApi__Badge__c b = (OrderApi__Badge__c) s;
            
            // making record to inactive
            b.OrderApi__Is_Active__c = false;
            
            // changing the value for Created_By_Trigger field
            if(b.Created_By_Trigger__c){
                b.Created_By_Trigger__c = false;
            }
            else{
                b.Created_By_Trigger__c = true;
            }
            
            lstBadge.add(b);
        }
        update lstBadge;
    }
 
    global void finish(Database.BatchableContext BC)
    {
                
    }
}