/**
 *
 * Test class for the LoginController Class
 * @author Vishal Shah
 *
 **/

@isTest
private class Test_LoginController
{
	@isTest
	static void returnDefaultUrl()
	{
		/*LoginController ctrl = new LoginController();

		Id p = [select id from profile where name='Partner Community User'].id;
       
        Account ac = new Account(name ='Grazitti') ;
        insert ac; 
       
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;  

        Contact con1 = new Contact(LastName = 'peddireddy', Email = 'peddireddy.sandeep1989@gmail.com', AccountId = ac.Id);
        insert con1;
                  
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con.Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        system.runAs(user) {
            OrderApi__Item_Class__c itmc = Test_ItemClass_Trigger.createRow();
	        insert itmc;

	        OrderApi__Item__c itm = new OrderApi__Item__c(
	        	Name = 'test',
	        	OrderApi__Price__c = 9191,
	        	OrderApi__Display_Name__c = 'Test Item',
	        	OrderApi__Line_Description__c = 'Test Line Description',
	        	OrderApi__Item_Class__c =itmc.Id);

	        OrderApi__Item__c itm2 = new OrderApi__Item__c(
	        	Name = 'test 2',
	        	OrderApi__Price__c = 1999,
	        	OrderApi__Display_Name__c = 'Test Item 2',
	        	OrderApi__Line_Description__c = 'Test Line Description 2',
	        	OrderApi__Item_Class__c =itmc.Id);
	        insert new OrderApi__Item__c[]{itm,itm2};

	        OrderApi__Sales_Order__c testSO1 = new OrderApi__Sales_Order__c(
	        	OrderApi__Account__c = ac.Id,
	        	OrderApi__Contact__c = con.Id,
	        	OrderApi__Entity__c = 'Contact');
	        insert testSO1;

	        OrderApi__Sales_Order_Line__c sol = new OrderApi__Sales_Order_Line__c(
	        	OrderApi__Item__c = itm.Id,
	        	OrderApi__Sales_Order__c = testSO1.Id,
	        	OrderApi__Quantity__c = 3);

	        OrderApi__Sales_Order_Line__c sol2 = new OrderApi__Sales_Order_Line__c(
	        	OrderApi__Item__c = itm2.Id,
	        	OrderApi__Sales_Order__c = testSO1.Id,
	        	OrderApi__Quantity__c = 2);
	        insert new OrderApi__Sales_Order_Line__c[]{sol,sol2};

	        Test.startTest();

	        PageReference testPage = Page.OrderApi__checkout;
	        testPage.getParameters().put('contact',con1.Id);*/
	        /*Test.setCurrentPageReference(testPage);

	        CheckoutController testCon = new CheckoutController();
	        testCon.updateContact(con.Id,con1.Id);
	        testCon.updateSalesOrders(con.Id,con1.Id);
	        con1 = (Contact)new Framework.Selector(Contact.SObjectType).selectById(con1.Id);
	        System.assertEquals(con1.Email,'speddireddy@fonteva.com');
	        Sales_Order__c salesOrder = (Sales_Order__c) new Framework.Selector(Sales_Order__c.SObjectType, Sales_Order_Line__c.Sales_Order__c).selectById(testSO1.Id);
	        System.assertEquals(salesOrder.Contact__c,con1.Id);
	        for (Sales_Order_Line__c salesorderline : salesOrder.sales_Order_Lines__r)
	            System.assertEquals(salesorderline.Contact__c,con1.Id);*/
	        //Test.stopTest();
        //}

	}
}