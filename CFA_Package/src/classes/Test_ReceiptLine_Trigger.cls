/**
 *
 * Test class for the ReceiptLine_Trigger Class
 * @author Nikilesh
 *
 **/

@isTest
private class Test_ReceiptLine_Trigger {

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
    static void testReceiptShare () {

        buildData();

        OrderApi__Receipt__c rpt = new OrderApi__Receipt__c();
        rpt.OrderApi__Business_Group__c = businessGroups[0].Id;

        insert rpt;
        
        // invoice inserting
        OrderApi__Invoice__c invoice = new OrderApi__Invoice__c();
        insert invoice;
            
        // insert receipt line
        OrderApi__Receipt_Line__c rlines = new OrderApi__Receipt_Line__c();
        rlines.OrderApi__Receipt__c = rpt.id;
        rlines.OrderApi__Invoice__c = invoice.id;
        insert rlines;
            
        update rlines;

    }
}