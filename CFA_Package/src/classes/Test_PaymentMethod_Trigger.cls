/**
 *
 * Test class for the PaymentMethod_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
public class Test_PaymentMethod_Trigger {

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

    public static OrderApi__Payment_Method__c createRow() {
        OrderApi__Payment_Method__c pm = new OrderApi__Payment_Method__c();

        pm.OrderApi__Payment_Method_Token__c = 'XXXXXXXXTOKENXXXXXXXX';
        pm.OrderApi__Payment_Method_Type__c = 'credit_card';
        pm.OrderApi__Entity__c = 'Contact';
        pm.OrderApi__Year__c = 2099;
        pm.OrderApi__Month__c = 12;
        pm.OrderApi__Is_Active__c = true;
        pm.OrderApi__Is_Valid__c = true;
        pm.OrderApi__Is_Expired__c = false;
        pm.OrderApi__Is_Declined__c = false;
        pm.OrderApi__Card_Type__c = 'visa';
        pm.OrderApi__Number__c = 'XXXX-XXXX-XXXX-1234';
        return pm;
    }


    @isTest
    static void testPaymentMethodShare () {

        buildData();

        OrderApi__Payment_Method__c payMthd = createRow();
        payMthd.BusinessGroup__c = businessGroups[0].Id;

        insert payMthd;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Payment_Method__Share WHERE ParentId = :payMthd.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

        payMthd.BusinessGroup__c = businessGroups[1].Id;

        update payMthd;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Payment_Method__Share WHERE ParentId = :payMthd.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

    }
}