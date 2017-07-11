/**
 *
 * Test class for the SubscriptionPlan_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
public class Test_SubscriptionPlan_Trigger {

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

    public static OrderApi__Subscription_Plan__c createRow() {
        OrderApi__Subscription_Plan__c subPln = new OrderApi__Subscription_Plan__c();
        subPln.Name = 'test subscription plan';
        subPln.OrderApi__Type__c = 'Termed';
        subPln.OrderApi__Initial_Term_Months__c = 12;
        subPln.OrderApi__Renewal_Term_Months__c = 12;
        subPln.OrderApi__Bill_Cycle__c = 'AUTO';
        subPln.OrderApi__Enable_Payment_Schedule__c = false;
        subPln.OrderApi__Auto_Renew_Option__c = 'Enabled';
        subPln.OrderApi__Enable_Proration__c = false;
        subPln.OrderApi__Is_Active__c = true;

        return subPln;
    }

    @isTest
    static void testSubscriptionPlanShare () {

        buildData();

        OrderApi__Subscription_Plan__c subPln = createRow();
        subPln.OrderApi__Business_Group__c = businessGroups[0].Id;

        insert subPln;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Subscription_Plan__Share WHERE ParentId = :subPln.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);
        
        // updates
        subPln.OrderApi__Business_Group__c = businessGroups[1].Id;
        update subPln;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Subscription_Plan__Share WHERE ParentId = :subPln.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);
    }
}