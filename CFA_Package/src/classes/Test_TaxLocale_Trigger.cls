/**
 *
 * Test class for the TaxLocale_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
private class Test_TaxLocale_Trigger {

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
    static void testTaxLocaleShare () {

        buildData();

        OrderApi__Tax_Locale__c txl = new OrderApi__Tax_Locale__c(
                OrderApi__Tax_Locale_Field__c = 'OrderApi__Shipping_Country__c',
                OrderApi__Locale_Values_CSV__c = 'VA',
                OrderApi__Business_Group__c = businessGroups[0].Id
            );
        // Fields

        insert txl;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Tax_Locale__Share WHERE ParentId = :txl.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

        txl.OrderApi__Business_Group__c = businessGroups[1].Id;
        update txl;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM OrderApi__Tax_Locale__Share WHERE ParentId = :txl.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

    }
}