/**
 *
 * Domain class for the User SObjectType
 * @author Vishal Shah
 *
 **/

@isTest
private class Test_User_Trigger {

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
	
	@isTest static void testOnBadgeCreationUserAddedToGroup() {

		OrderApi__Badge_Type__c bt1 = new OrderApi__Badge_Type__c();
		Contact con = new Contact();

        Id admin = [select id from profile where name='System Administrator'].id;
        
        User adminUser = new User(
        	alias = 'admin123', 
        	email='admin123@noemail.com',
            emailencodingkey='UTF-8', 
            lastname='Testing', 
            languagelocalekey='en_US',
            localesidkey='en_US', 
            profileid = admin, 
            country='United States',
            IsActive =true,
            timezonesidkey='America/Los_Angeles', 
            username='admin@noemail.com');
        insert adminUser;

        UserRole r = new UserRole(name = 'TEST ROLE');
        System.runAs(adminUser) {
        	Database.insert(r);

        	adminUser.userroleid = r.id;
        	update adminUser;
        }


        System.runAs(adminUser) {

        	buildData();

			bt1 = Test_BadgeType_Trigger.createRow();
	        bt1.BusinessGroup__c = businessGroups[0].Id;
	        insert bt1;

	        con = TestDataFactory.createContact();

        }

        Id partner = [select id from profile where name='Partner Community User'].id;
        User partnerUser = new User(
        	alias = 'test123', 
        	email='test123@noemail.com',
            emailencodingkey='UTF-8', 
            lastname='Testing', 
            languagelocalekey='en_US',
            localesidkey='en_US', 
            profileid = partner, 
            country='United States',
            IsActive =true,
            ContactId = con.Id,
            timezonesidkey='America/Los_Angeles', 
            username='tester@noemail.com');

        insert partnerUser;

        System.runAs(adminUser) {
        	Test.startTest();
        	OrderApi__Badge__c badge = new OrderApi__Badge__c( 
        	OrderApi__Badge_Type__c = bt1.Id,
        	OrderApi__Is_Active__c = true,
        	OrderApi__Contact__c = con.Id);
        	insert badge;
            Test.stopTest();    

            System.assertEquals(1, [SELECT Id FROM GroupMember WHERE GroupId = :groups[0].Id AND UserOrGroupId = :partnerUser.Id].size());
        	
        }
    }

    @isTest static void testOnBadgeContactChange() {

        OrderApi__Badge_Type__c bt1 = new OrderApi__Badge_Type__c();
        Contact con = new Contact();
        Contact con2 = new Contact();

        Id admin = [select id from profile where name='System Administrator'].id;
        
        User adminUser = new User(
            alias = 'admin123', 
            email='admin123@noemail.com',
            emailencodingkey='UTF-8', 
            lastname='Testing', 
            languagelocalekey='en_US',
            localesidkey='en_US', 
            profileid = admin, 
            country='United States',
            IsActive =true,
            timezonesidkey='America/Los_Angeles', 
            username='admin@noemail.com');
        insert adminUser;

        UserRole r = new UserRole(name = 'TEST ROLE');
        System.runAs(adminUser) {
            Database.insert(r);

            adminUser.userroleid = r.id;
            update adminUser;
        }


        System.runAs(adminUser) {

            buildData();

            bt1 = Test_BadgeType_Trigger.createRow();
            bt1.BusinessGroup__c = businessGroups[0].Id;
            insert bt1;

            con = TestDataFactory.createContact();
            con2 = TestDataFactory.createContact();

            OrderApi__Badge__c bdg1 = new OrderApi__Badge__c( 
            OrderApi__Badge_Type__c = bt1.Id,
            OrderApi__Is_Active__c = true,
            OrderApi__Contact__c = con.Id);
            insert bdg1;

        }

        Id partner = [select id from profile where name='Partner Community User'].id;
        User partnerUser = new User(
            alias = 'test123', 
            email='test123@noemail.com',
            emailencodingkey='UTF-8', 
            lastname='Testing', 
            languagelocalekey='en_US',
            localesidkey='en_US', 
            profileid = partner, 
            country='United States',
            IsActive =true,
            ContactId = con.Id,
            timezonesidkey='America/Los_Angeles', 
            username='tester@noemail.com');

        User partnerUser2 = new User(
            alias = 'par123', 
            email='test123@noemail.com',
            emailencodingkey='UTF-8', 
            lastname='Testing', 
            languagelocalekey='en_US',
            localesidkey='en_US', 
            profileid = partner, 
            country='United States',
            IsActive =true,
            ContactId = con2.Id,
            timezonesidkey='America/Los_Angeles', 
            username='partnerUser2@noemail.com');


        insert new User[] {partnerUser, partnerUser2};

        System.runAs(adminUser) {
            Test.startTest();
            OrderApi__Badge__c bdg2 = [SELECT OrderApi__Contact__c FROM OrderApi__Badge__c WHERE OrderApi__Contact__c = :con.Id AND OrderApi__Badge_Type__c = :bt1.Id];
            bdg2.OrderApi__Contact__c = con2.Id;
            update bdg2;

            Test.stopTest();    
            
            System.assertEquals(0, [SELECT Id FROM GroupMember WHERE GroupId = :groups[0].Id AND UserOrGroupId = :partnerUser.Id].size());
            System.assertEquals(1, [SELECT Id FROM GroupMember WHERE GroupId = :groups[0].Id AND UserOrGroupId = :partnerUser2.Id].size());
            

        }
    }

    @isTest static void testOnBadgeDeletionUserDeletedFromGroup() {

        OrderApi__Badge_Type__c bt1 = new OrderApi__Badge_Type__c();
        Contact con = new Contact();
        OrderApi__Badge__c badge = null;

        Id admin = [select id from profile where name='System Administrator'].id;
        
        User adminUser = new User(
            alias = 'admin123', 
            email='admin123@noemail.com',
            emailencodingkey='UTF-8', 
            lastname='Testing', 
            languagelocalekey='en_US',
            localesidkey='en_US', 
            profileid = admin, 
            country='United States',
            IsActive =true,
            timezonesidkey='America/Los_Angeles', 
            username='admin@noemail.com');
        insert adminUser;

        UserRole r = new UserRole(name = 'TEST ROLE');
        System.runAs(adminUser) {
            Database.insert(r);

            adminUser.userroleid = r.id;
            update adminUser;
        }


        System.runAs(adminUser) {

            buildData();

            bt1 = Test_BadgeType_Trigger.createRow();
            bt1.BusinessGroup__c = businessGroups[0].Id;
            insert bt1;

            con = TestDataFactory.createContact();

            badge = new OrderApi__Badge__c( 
            OrderApi__Badge_Type__c = bt1.Id,
            OrderApi__Is_Active__c = true,
            OrderApi__Contact__c = con.Id);
            insert badge;
        }

        Id partner = [select id from profile where name='Partner Community User'].id;
        User partnerUser = new User(
            alias = 'test123', 
            email='test123@noemail.com',
            emailencodingkey='UTF-8', 
            lastname='Testing', 
            languagelocalekey='en_US',
            localesidkey='en_US', 
            profileid = partner, 
            country='United States',
            IsActive =true,
            ContactId = con.Id,
            timezonesidkey='America/Los_Angeles', 
            username='tester@noemail.com');

        insert partnerUser;

        System.runAs(adminUser) {
            Test.startTest();
            delete badge;
            Test.stopTest();    

            System.assertEquals(0, [SELECT Id FROM GroupMember WHERE GroupId = :groups[0].Id AND UserOrGroupId = :partnerUser.Id].size());
            
        }
    }

    @isTest static void testOnUserCreationAddToGroup() {

		OrderApi__Badge_Type__c bt1 = new OrderApi__Badge_Type__c();
		Contact con = new Contact();

        Id admin = [select id from profile where name='System Administrator'].id;
        
        User adminUser = new User(
        	alias = 'admin123', 
        	email='admin123@noemail.com',
            emailencodingkey='UTF-8', 
            lastname='Testing', 
            languagelocalekey='en_US',
            localesidkey='en_US', 
            profileid = admin, 
            country='United States',
            IsActive =true,
            timezonesidkey='America/Los_Angeles', 
            username='admin@noemail.com');
        insert adminUser;

        UserRole r = new UserRole(name = 'TEST ROLE');
        System.runAs(adminUser) {
        	Database.insert(r);

        	adminUser.userroleid = r.id;
        	update adminUser;
        }


        System.runAs(adminUser) {

        	buildData();

			bt1 = Test_BadgeType_Trigger.createRow();
	        bt1.BusinessGroup__c = businessGroups[0].Id;
	        insert bt1;

	        con = TestDataFactory.createContact();

	        OrderApi__Badge__c badge = new OrderApi__Badge__c( 
	        	OrderApi__Badge_Type__c = bt1.Id,
	        	OrderApi__Is_Active__c = true,
	        	OrderApi__Contact__c = con.Id);
        	insert badge;

        }

        System.runAs(adminUser) {
        	Test.startTest();
        	Id partner = [select id from profile where name='Partner Community User'].id;
	        User partnerUser = new User(
	        	alias = 'test123', 
	        	email='test123@noemail.com',
	            emailencodingkey='UTF-8', 
	            lastname='Testing', 
	            languagelocalekey='en_US',
	            localesidkey='en_US', 
	            profileid = partner, 
	            country='United States',
	            IsActive =true,
	            ContactId = con.Id,
	            timezonesidkey='America/Los_Angeles', 
	            username='tester@noemail.com');
	        insert partnerUser;
        	
        	Test.stopTest();	

	        System.assertEquals(1, [SELECT Id FROM GroupMember WHERE GroupId = :groups[0].Id AND UserOrGroupId = :partnerUser.Id].size());
        }
	}
	
}