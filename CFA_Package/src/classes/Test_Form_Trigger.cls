/**
 *
 * Test class for the Form_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
private class Test_Form_Trigger {

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
    static void testFormShare () {

        buildData();

        PagesApi__Form__c f = new PagesApi__Form__c();
        f.Name = 'Test Form';
        f.BusinessGroup__c = businessGroups[0].Id;

        insert f;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM PagesApi__Form__Share WHERE ParentId = :f.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

        f.BusinessGroup__c = businessGroups[1].Id;

        update f;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM PagesApi__Form__Share WHERE ParentId = :f.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

    }
}