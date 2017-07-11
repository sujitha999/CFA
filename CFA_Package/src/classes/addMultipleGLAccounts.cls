public class addMultipleGLAccounts {
    
    Onboarding_GL_Accounts__c glAcc = new Onboarding_GL_Accounts__c();
    public list<Onboarding_GL_Accounts__c> listglAcc {get; set;}
    public string Parentid {get; set;}

    public addMultipleGLAccounts() {
        /*
        listglAcc = new list<Onboarding_GL_Accounts__c>();
        listglAcc.add(glAcc);
        */
    }

    Public void addAccount() {
        Onboarding_GL_Accounts__c gl = new Onboarding_GL_Accounts__c(Society_Onboarding__c = Parentid);
        listglAcc.add(gl);
    }
    /*
    public PageReference saveAccount() {
        for(Integer i=0; i<listglAcc.size(); i++) {
        insert listglAcc;
        }
        return Page.Allaccountssaved;
    } */
}