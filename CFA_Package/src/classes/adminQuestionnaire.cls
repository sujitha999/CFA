public without sharing class adminQuestionnaire {

public EventApi__Event__c ev {get; set;}
public EventApi__Venue__c ve {get; set;}
List<PagesApi__Field_Response__c> resp = new List<PagesApi__Field_Response__c>();
public String xlsHeader {
        get {
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            
            return strHeader;
        }
    }

public adminQuestionnaire(){

    Id id = ApexPages.currentPage().getParameters().get('id');
    ev = [SELECT Id,
                 Name,
                 EducationCreditValue__c,
                 SER_Credit_Value__c
            FROM EventApi__Event__c
            WHERE Id =:id];
                    
}
    public List<FormResponseWrapper> getAttendeeResponses() {
    Id id = ApexPages.currentPage().getParameters().get('id');
    List<FormResponseWrapper> frw = new List<FormResponseWrapper>();
    list<PagesApi__Form_Response__c> lFR = [SELECT EventApi__Attendee__r.EventApi__Contact__r.CFAMN__PersonID__c,
                                                   EventApi__Attendee__r.EventApi__Contact__r.CFAMN__Employer__c,
                                                   EventApi__Attendee__r.EventApi__Full_Name__c,
                                                   (SELECT PagesApi__Response__c, 
                                                           PagesApi__Field_Label__c,
                                                           PagesApi__Field_Order__c,
                                                           PagesApi__Response_Group__c
                                                           FROM PagesApi__Field_Responses__r
                                                           ORDER BY PagesApi__Response_Group__c ASC, PagesApi__Field_Order__c ASC) 
                                                   FROM PagesApi__Form_Response__c 
                                                   WHERE EventApi__Attendee__r.EventApi__Event__r.Id =: id];
    if(lFR.size()> 0){
    for(PagesApi__Form_Response__c fr : lFR){
    frw.add(new FormResponseWrapper(fr));    
    }
    }
    return frw;
    }
    
    public List<String> getAttendeeQuestions() {
    Id id = ApexPages.currentPage().getParameters().get('id');
    List<String> fq = new List<String>();
    list<PagesApi__Form_Response__c> frL = [SELECT EventApi__Attendee__r.EventApi__Contact__r.CFAMN__PersonID__c,
                                                   EventApi__Attendee__r.EventApi__Contact__r.CFAMN__Employer__c,
                                                   EventApi__Attendee__r.EventApi__Full_Name__c,
                                                   (SELECT PagesApi__Response__c, 
                                                           PagesApi__Field_Label__c,
                                                           PagesApi__Field_Order__c,
                                                           PagesApi__Response_Group__c
                                                           FROM PagesApi__Field_Responses__r
                                                           ORDER BY PagesApi__Response_Group__c ASC, PagesApi__Field_Order__c ASC) 
                                                   FROM PagesApi__Form_Response__c 
                                                   WHERE EventApi__Attendee__r.EventApi__Event__r.Id =: id];
    if(frL.size()> 0){
    for(PagesApi__Form_Response__c rf : frL){
    FormResponseWrapper frw = new FormResponseWrapper(rf);    
    fq = frw.questions;
    }
    }
    return fq;
    }
    
}