global class ScheduleShareUnsharedRecords implements Schedulable {
   global void execute(SchedulableContext SC) {
   
    String bgFieldName = SObjectType.OrderApi__Sales_Order__c.fields.OrderApi__Business_Group__c.getName();
    RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.OrderApi__Sales_Order__Share.getName(), 
            bgFieldName, 
            'Manual');
            
      // getting recrords which needs to be shared
      List<SObject> ListSO = new List<SObject>();
      for(OrderApi__Sales_Order__c SO : [Select id,OrderApi__Business_Group__c FROM OrderApi__Sales_Order__c where Recalculate_Sharing__c = true]){
        ListSO.add(SO);
      }
      rss.sharewithgroup(ListSO);
      
      for(OrderApi__Sales_Order__c SO : (List<OrderApi__Sales_Order__c>)ListSO){
        SO.Recalculate_Sharing__c = false;
      }
      update ListSo;
      
   }
}