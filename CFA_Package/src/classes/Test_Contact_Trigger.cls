@isTest
private class Test_Contact_Trigger {
  
  @testSetup
    static void setupTest() {
        //Data Setup
        TestDataFactory.testInstall();
        TestDataFactory.sharingSetup();
        
        // Insert User
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'Admi', Email='Adminuser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='Adminuser@testorg.com');
        insert u;
    }

  @isTest 
  static void testContactLocalNameSet() {

    Test.startTest();
        Contact con = TestDataFactory.createContact();
    Test.stopTest();

    Contact c = [SELECT FirstNameLocal, MiddleNameLocal, LastNameLocal FROM Contact WHERE Id = :con.Id];
    
    // changing owner
    User u = [select id from User where UserName='Adminuser@testorg.com'];
    c.Ownerid = u.id;
    c.CIPMCandidateCode__c = '1C';
    update c;

    System.assertEquals('Vishal', c.FirstNameLocal);
    System.assertEquals(null, c.MiddleNameLocal);
    System.assertEquals('Shah', c.LastNameLocal);
  }
  
  
}