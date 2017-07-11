global class ScheduleShareUnsharedRecords_receipt implements Schedulable {
   global void execute(SchedulableContext SC) {
   
    String bgFieldName = SObjectType.OrderApi__Receipt__c.fields.OrderApi__Business_Group__c.getName();
    RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.OrderApi__Receipt__share.getName(), 
            bgFieldName, 
            'Manual');
            
      // getting recrords which needs to be shared
      List<SObject> ListRC = new List<SObject>();
      for(OrderApi__Receipt__c RC : [Select id,OrderApi__Business_Group__c FROM OrderApi__Receipt__c where Recalculate_Sharing__c = true]){
        ListRC.add(RC);
      }
      rss.sharewithgroup(ListRC);
      
      for(OrderApi__Receipt__c RC : (List<OrderApi__Receipt__c>)ListRC){
        RC.Recalculate_Sharing__c = false;
      }
      update ListRC;
      
   }
}