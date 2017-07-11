global class ScheduleShareUnsharedRecords_transaction implements Schedulable {
   global void execute(SchedulableContext SC) {
   
    String bgFieldName = SObjectType.OrderApi__Transaction__c.fields.OrderApi__Business_Group__c.getName();
    RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.OrderApi__Transaction__share.getName(), 
            bgFieldName, 
            'Manual');
            
      // getting recrords which needs to be shared
      List<SObject> ListTR = new List<SObject>();
      for(OrderApi__Transaction__c TR : [Select id,OrderApi__Business_Group__c FROM OrderApi__Transaction__c where Recalculate_Sharing__c = true]){
        ListTR.add(TR);
      }
      rss.sharewithgroup(ListTR);
      
      for(OrderApi__Transaction__c TR : (List<OrderApi__Transaction__c>)ListTR){
        TR.Recalculate_Sharing__c = false;
      }
      update ListTR;
      
   }
}