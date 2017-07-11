@isTest
private class Test_SocietyOnboardingController {

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
	    
	    Onboarding_GL_Accounts__c objGLAcc =  new Onboarding_GL_Accounts__c();
        objGLAcc.Name = 'test';
        objGLAcc.Report_Category__c = 'Balance Sheet';
        objGLAcc.Detail__c = 'Accounts Receivable (A/R)';
        objGLAcc.Type__c = 'Capital';
        objGLAcc.Society_Onboarding__c = obj.id;
	    insert objGLAcc;
	    
	    Onboarding_Payment_Terms__c Paymentobj = new Onboarding_Payment_Terms__c();
        Paymentobj.Name = 'test';
        Paymentobj.Payment_Term_Name__c = 'test';
        Paymentobj.Payment_Period__c = 'test';
        Paymentobj.Display_Name__c = 'NET 30';
        Paymentobj.Display_Message__c = 'Due in 30';
        Paymentobj.Variable__c = 30;
        Paymentobj.Society_Onboarding__c = obj.id;
        insert Paymentobj;
        
        Contact con = new contact();
        con.lastname = 'test';
        insert con;
        
        Soc_Onb__c custom1 = new Soc_Onb__c(Name = 'Default Contact Id' , Value__c = con.id);
        insert custom1;
        
        Account acc = new Account();
        acc.name = 'test';
        insert acc;
        
        custom1 = new Soc_Onb__c(Name = 'Default Account Id' , Value__c = acc.id);
        insert custom1;
        
        custom1 = new Soc_Onb__c(Name = 'Connected User Id' , Value__c = UserInfo.getUserId());
        insert custom1;

        /*
        //Create Role
        userRole role = new userRole();
        role.name = 'MemberNation';
        insert role;

        custom4 = new Soc_Onb__c(Name = 'MemberNation Role Id' , Value__c = role.id);
        insert custom4;
        */

        custom1 = new Soc_Onb__c(Name = 'CFA Partner Community Site User Id' , Value__c = UserInfo.getUserId());
        insert custom1;

        custom1 = new Soc_Onb__c(Name = 'CFA Site Guest User' , Value__c = UserInfo.getUserId());
        insert custom1;
        
        custom1 = new Soc_Onb__c(Name = 'MediaLookupId' , Value__c = '00N61000009LoJV');
        insert custom1;

        custom1 = new Soc_Onb__c(Name = 'MediaLookupId' , Value__c = '00N61000009LoJV');
        insert custom1;

        //create business group
        OrderApi__Business_Group__c bg = new OrderApi__Business_Group__c();
        bg.name = 'Test Group';
        bg.currencyIsoCode = 'USD';
        insert bg;

        custom1 = new Soc_Onb__c(Name = 'Default Business Group Id' , Value__c = bg.id);
        insert custom1;


        Profile p = [select Id,name from Profile where Name = 'System Administrator' limit 1];

        user newUser = new User(
        profileId = p.id,
        username = 'test_so_newUser@yahoo.com',
        email = 'test_so_pb@ff.com',
        emailencodingkey = 'UTF-8',
        localesidkey = 'en_US',
        languagelocalekey = 'en_US',
        timezonesidkey = 'America/Los_Angeles',
        alias='t_so_ns',
        lastname='test_so_newUserl'
        );
        
        insert newUser;
        
        System.runAs (newUser) {
            
            Userrole role = new Userrole();
            role.Name = 'test_data_role';
            insert role;
            
            custom1 = new Soc_Onb__c(Name = 'MemberNation Role Id' , Value__c = role.id);
            insert custom1;
        }
    }
    
	private static testMethod void test() {
        
        Society_Onboarding__c obj = [select id from Society_Onboarding__c limit 1];
        
        PageReference pageRef = Page.OnboardSocietyDetail;
        pageRef.getParameters().put('id', obj.id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(obj);
        SocietyOnboardingController testobj = new SocietyOnboardingController(sc);
        
        testobj.saveOnly();
        testobj.listglAcc = new list<Onboarding_GL_Accounts__c>();
        testobj.closePopup();
        testobj.showPopup();
        testobj.SaveRec();
        testobj.addAccount();
        testobj.addPayments();
	}
	
	
	// covrage when no onboarding record exist
	private static testMethod void test_1() {
        
        Society_Onboarding__c obj = [select id,Phone__c,CFA_Society_Id__c,Society_Homepage_URL__c,Email__c,Mailing_Addess__c,CFA_Org_ID__c from Society_Onboarding__c limit 1];
		obj.Phone__c = '';
		update obj;

		PageReference pageRef = Page.OnboardSocietyDetail;
        pageRef.getParameters().put('id', obj.id);
		ApexPages.StandardController sc = new ApexPages.StandardController(obj);        		
			
        SocietyOnboardingController testobj = new SocietyOnboardingController(sc);
		testobj.SaveRec();
		
		obj.Phone__c = '1234';
		obj.CFA_Society_Id__c = '';
		update obj;
		testobj = new SocietyOnboardingController(sc);
		testobj.SaveRec();
		
		obj.Society_Homepage_URL__c = '';
		obj.CFA_Society_Id__c = '12345';
		update obj;
		testobj = new SocietyOnboardingController(sc);
		testobj.SaveRec();
		
		obj.Society_Homepage_URL__c = 'www.google.com';
		obj.Email__c = '';
		update obj;
		testobj = new SocietyOnboardingController(sc);
		testobj.SaveRec();
		
		obj.Mailing_Addess__c = '';
		obj.Email__c = 'abc@gmail.com';
		update obj;
		testobj = new SocietyOnboardingController(sc);
		testobj.SaveRec();
		
		obj.Mailing_Addess__c = 'test';
		obj.CFA_Org_ID__c = '';
		update obj;
		testobj = new SocietyOnboardingController(sc);
		testobj.SaveRec();
	}

}