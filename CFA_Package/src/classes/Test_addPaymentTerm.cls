@isTest
private class Test_addPaymentTerm {
    
    @testSetup static void insertData()
    {
        Society_Onboarding__c obj = new Society_Onboarding__c();
	    obj.Name = 'test_data';
	    obj.CFA_Org_ID__c = '1234';
	    obj.CFA_Society_Id__c = '12345';
	    obj.Email__c = 'abc@yail.com';
	    obj.Mailing_Addess__c = 'test';
	    obj.Phone__c = '1234';
	    obj.Society_Homepage_URL__c = 'www.gmail.com' ;
	    insert obj;
    }

	private static testMethod void addPaymentTerm() {
            
            Society_Onboarding__c testrec = [select id from Society_Onboarding__c limit 1];
            addPaymentTerm obj = new addPaymentTerm();
            obj.listPaymentTerm = new list<Onboarding_Payment_Terms__c>();
            obj.Parentid = testrec.id;
            obj.addPayments();
	}

}