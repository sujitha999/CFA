/**
 *
 * Test class for the ItemClass_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
public class Test_ItemClass_Trigger {

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

    public static OrderApi__Item_Class__c createRow() {
        return new OrderApi__Item_Class__c(
            Name = 'Test Class',
            OrderApi__Is_Active__c = true);
    }

    @isTest
    static void testItemClassShare () {

        buildData();

        OrderApi__Item_Class__c itmcls = createRow();
        itmcls.OrderApi__Business_Group__c = businessGroups[0].Id;
        insert itmcls;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Item_Class__Share WHERE ParentId = :itmcls.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

        itmcls.OrderApi__Business_Group__c = businessGroups[1].Id;
        update itmcls;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Item_Class__Share WHERE ParentId = :itmcls.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

    }
}