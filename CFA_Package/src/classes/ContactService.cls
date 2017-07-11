/**
 *
 * Service class for Contact
 * @author Vishal Shah
 *
 **/

public with sharing class ContactService {
    
    public static void setLocalNames(Contact[] records) {
        Framework.Log.push(ContactService.class.getName(),'setLocalNames');
        for(Contact c: records) {
            if(String.isEmpty(c.FirstNameLocal)) {
                c.FirstNameLocal = c.FirstName;
            }
            if(String.isEmpty(c.MiddleNameLocal)) {
                c.MiddleNameLocal = c.MiddleName;
            }
            if(String.isEmpty(c.LastNameLocal)) {
                c.LastNameLocal = c.LastName;
            }
        }
        Framework.Log.pop();
    }
    
    public static void setDiscountEligibility(Contact[] records) {
        Framework.Log.push(ContactService.class.getName(),'setDiscountEligibility');
        for(Contact c : records)  {
            if(c.CFAMemberCode__c == 'CR' || c.CFAMemberCode__c == 'CRR' ||
               c.CFAMemberCode__c == 'CN' || c.CFAMemberCode__c == 'CNR' ||
               c.CFAMemberCode__c == 'SR' || c.CFAMemberCode__c == 'SRR' ||
               c.CFAMemberCode__c == 'AOR' || c.CFAMemberCode__c == 'AORR' ||
               c.CFAMemberCode__c == 'SA' || c.CFAMemberCode__c == 'SAR' ||
               c.CFAMemberCode__c == 'AOA' || c.CFAMemberCode__c == 'AOAR' ||
               c.CIPMMemberCode__c == 'MB' || c.CFACandidateCode__c == '1C' ||
               c.CFACandidateCode__c == '2C' || c.CFACandidateCode__c == '3C' ||
               c.CIPMCandidateCode__c == '1C' || c.CIPMCandidateCode__c == '2C' ||
               c.ClaritasCandidateCode__c == '1C' || c.ClaritasCandidateCode__c == 'GRAD') {
               
                   c.CFAI_Conference_Discount_Eligibility__c = 'True';
                   
               
            } else {
            
                c.CFAI_Conference_Discount_Eligibility__c = 'False';
            
            }
        
        }
        Framework.Log.pop();
    
    }

}