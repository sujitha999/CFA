/**
 *
 * Test class for the Item_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
public class Test_Item_Trigger {

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

    public static OrderApi__Item__c createRow(Id bg) {
        
        OrderApi__GL_Account__c gl = new OrderApi__GL_Account__c(
            Name = 'GL Account',
            OrderApi__Business_Group__c = bg);
        insert gl;
        OrderApi__Item_Class__c itmClass = Test_ItemClass_Trigger.createRow();
        insert itmClass;
        return new OrderApi__Item__c(
            Name = 'test item',
            OrderApi__Price__c = 100.00,
            OrderApi__Cost__c = 50.00,
            OrderApi__Is_Active__c = true,
            OrderApi__Item_Class__c = itmClass.Id,
            OrderApi__Business_Group__c = bg,
            OrderApi__Income_Account__c = gl.Id,
            OrderApi__Adjustment_Account__c = gl.Id,
            OrderApi__Discount_Account__c = gl.Id,
            OrderApi__Refund_Account__c = gl.Id);
    }

    @isTest
    static void testItemShare () {

        buildData();

        OrderApi__Item__c itm = createRow(businessGroups[0].Id);
        insert itm;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Item__Share WHERE ParentId = :itm.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

        itm.OrderApi__Business_Group__c = businessGroups[1].Id;

        update itm;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Item__Share WHERE ParentId = :itm.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

    }
}