global class ScheduleShareUnsharedRecords_badges implements Schedulable {
    global void execute(SchedulableContext SC) {

        String bgFieldName = SObjectType.OrderApi__Badge__c.fields.BusinessGroup__c.getName();
        RecordSharingService rss =
                new RecordSharingService(
                        SObjectType.OrderApi__Badge__Share.getName(),
                        bgFieldName,
                        'Manual');

        // getting records which needs to be shared
        List<SObject> ListBdg = new List<SObject>();
        for(OrderApi__Badge__c bdg : [Select id,BusinessGroup__c, Created_By_Trigger__c FROM OrderApi__Badge__c where Recalculate_Sharing__c = true]){
            ListBdg.add(bdg);
        }
        rss.sharewithgroup(ListBdg);

        for(OrderApi__Badge__c BD : (List<OrderApi__Badge__c>)ListBdg){
            BD.Recalculate_Sharing__c = false;
            if(BD.Created_By_Trigger__c == false){
                BD.Created_By_Trigger__c = true;
            } else {
                BD.Created_By_Trigger__c = false;
            } 
        }
        update ListBdg;

    }
}