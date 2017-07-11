/**
 *
 * Test class for the BadgeType_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
public class Test_BadgeType_Trigger {

    static OrderApi__Business_Group__c[] businessGroups = new OrderApi__Business_Group__c[]{};
    static Group[] groups = new Group[]{};

    @testSetup
    static void setupTest() {
        //Data Setup
        TestDataFactory.testInstall();
        TestDataFactory.sharingSetup();
    }

    public static OrderApi__Badge_Type__c createRow() {
        OrderApi__Badge_Type__c bt = new OrderApi__Badge_Type__c();
        bt.Name = 'Test Badge Type';
        bt.OrderApi__Is_Active__c = true;
        bt.OrderApi__Is_Published__c = true;
        bt.OrderApi__Description__c = 'Sample Desc';
        bt.OrderApi__Engagement_Score__c = 10;
        return bt;
    }

    private static void buildData() {
        if(businessGroups.isEmpty()) {
            Map<String, SObject[]> testData = TestDataFactory.buildData();
            businessGroups = (OrderApi__Business_Group__c[])testData.get(TestDataFactory.BUSINESSGROUPLABEL);
            groups = (Group[])testData.get(TestDataFactory.PUBLICGROUPLABEL);
        }
    }

    @isTest
    static void testBadgeTypeShare () {

        buildData();

        OrderApi__Badge_Type__c bdgTyp = createRow();
        bdgTyp.BusinessGroup__c = businessGroups[0].Id;

        insert bdgTyp;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Badge_Type__Share WHERE ParentId = :bdgTyp.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

        bdgTyp.BusinessGroup__c = businessGroups[1].Id;

        update bdgTyp;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Badge_Type__Share WHERE ParentId = :bdgTyp.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

    }
}