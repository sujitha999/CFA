@isTest
private class ScheduleShareUnsharedRecordsePymnts_test {

    static OrderApi__Business_Group__c[] businessGroups = new OrderApi__Business_Group__c[]{};
    static Group[] groups = new Group[]{};
    
    @testSetup 
    static void setupTest() {
        //Data Setup
        TestDataFactory.testInstall();
        TestDataFactory.sharingSetup();
        
    }
    
  private static void buildData() {
        if(businessGroups.isEmpty()) {
            Map<String, SObject[]> testData = TestDataFactory.buildData();
            businessGroups = (OrderApi__Business_Group__c[])testData.get(TestDataFactory.BUSINESSGROUPLABEL);
            groups = (Group[])testData.get(TestDataFactory.PUBLICGROUPLABEL);
        }
    }
    
     @isTest
    static void testSalesOrderShare () {
        buildData();
        OrderApi__ePayment__c ep = new OrderApi__ePayment__c();
        ep.OrderApi__Business_Group__c = businessGroups[0].Id;
        ep.Recalculate_Sharing__c = true;
        insert ep;
        
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP,
                        new ScheduleShareUnsharedRecords_ePayment());

    }

}