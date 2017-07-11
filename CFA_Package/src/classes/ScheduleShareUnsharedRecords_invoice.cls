global class ScheduleShareUnsharedRecords_invoice implements Schedulable {
   global void execute(SchedulableContext SC) {
   
    String bgFieldName = SObjectType.OrderApi__Invoice__c.fields.OrderApi__Business_Group__c.getName();
    RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.OrderApi__Invoice__share.getName(), 
            bgFieldName, 
            'Manual');
            
      // getting recrords which needs to be shared
      List<SObject> ListIV = new List<SObject>();
      for(OrderApi__Invoice__c IV : [Select id,OrderApi__Business_Group__c FROM OrderApi__Invoice__c where Recalculate_Sharing__c = true]){
        ListIV.add(IV);
      }
      rss.sharewithgroup(ListIV);
      
      for(OrderApi__Invoice__c IV : (List<OrderApi__Invoice__c>)ListIV){
        IV.Recalculate_Sharing__c = false;
      }
      update ListIV;
      
   }
}