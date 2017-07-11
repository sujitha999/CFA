/**
 *
 * Test class for the CommunityGroup_Trigger Class
 * @author Vishal Shah
 *
 **/

@isTest
public class Test_CommunityGroup_Trigger {

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

    public static PagesApi__Community_Group__c createRow() {
        PagesApi__Theme__c theme = new PagesApi__Theme__c();
        theme.Name = 'TEST';
        insert theme;

        PagesApi__Site__c site = new PagesApi__Site__c();
        site.Name = 'TEST';
        site.PagesApi__Theme__c = theme.Id;
        site.PagesApi__Community_Network_ID__c = '';

        insert site;

        PagesApi__Community_Group__c cg = new PagesApi__Community_Group__c();
        cg.PagesApi__Site__c = site.Id;
        return cg;
    }

    @isTest
    static void testCommunityGroupShare () {

        buildData();

        PagesApi__Community_Group__c commGrp = createRow();
        commGrp.BusinessGroup__c = businessGroups[0].Id;

        insert commGrp;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM PagesApi__Community_Group__Share WHERE ParentId = :commGrp.Id AND UserOrGroupId = :groups[0].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

        commGrp.BusinessGroup__c = businessGroups[1].Id;

        update commGrp;

        TestDataFactory.sharingAssert([SELECT ParentId, UserOrGroupId, AccessLevel FROM PagesApi__Community_Group__Share WHERE ParentId = :commGrp.Id AND UserOrGroupId = :groups[1].Id AND RowCause = :PackageUtils.SHARINGCAUSE]);

    }
}