global class ScheduleShareUnsharedRecords_ePayment implements Schedulable {
   global void execute(SchedulableContext SC) {
   
    String bgFieldName = SObjectType.OrderApi__EPayment__c.fields.OrderApi__Business_Group__c.getName();
    RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.OrderApi__EPayment__Share.getName(), 
            bgFieldName, 
            'Manual');
            
      // getting recrords which needs to be shared
      List<SObject> ListEP = new List<SObject>();
      for(OrderApi__EPayment__c EP : [Select id,OrderApi__Business_Group__c FROM OrderApi__EPayment__c where Recalculate_Sharing__c = true]){
        ListEP.add(EP);
      }
      rss.sharewithgroup(ListEP);
      
      for(OrderApi__EPayment__c EP : (List<OrderApi__EPayment__c>)ListEP){
        EP.Recalculate_Sharing__c = false;
      }
      update ListEP;
      
   }
}