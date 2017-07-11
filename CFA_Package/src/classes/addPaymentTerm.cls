public class addPaymentTerm {
    
    Onboarding_Payment_Terms__c glPaymentTerm = new Onboarding_Payment_Terms__c();
    public list<Onboarding_Payment_Terms__c> listPaymentTerm {get; set;}
    public string Parentid {get; set;}

    public addPaymentTerm() {
        
    }

    Public void addPayments() {
        Onboarding_Payment_Terms__c gl = new Onboarding_Payment_Terms__c(Society_Onboarding__c = Parentid);
        listPaymentTerm.add(gl);
    }
    /*
    public PageReference saveAccount() {
        for(Integer i=0; i<listglAcc.size(); i++) {
        insert listglAcc;
        }
        return Page.Allaccountssaved;
    } */
}