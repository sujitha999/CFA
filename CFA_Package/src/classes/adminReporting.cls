public without sharing class adminReporting {

public EventApi__Event__c ev {get; set;}
public EventApi__Venue__c ve {get; set;}
List<EventApi__Attendee__c> att = new List<EventApi__Attendee__c>();
public String xlsHeader {
        get {
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            
            return strHeader;
        }
    }

public adminReporting(){

    Id id = ApexPages.currentPage().getParameters().get('id');
    ev = [SELECT Id,
                 Name,
                 EducationCreditValue__c,
                 SER_Credit_Value__c
            FROM EventApi__Event__c
            WHERE Id =:id];
            
    ve = [SELECT Id,
                 EventApi__City__c,
                 EventApi__State__c,
                 EventApi__Country__c
            FROM EventApi__Venue__c
            WHERE EventApi__Event__c =:id
                  AND EventApi__Is_Primary_Venue__c = TRUE];
                    
}
    public List<EventApi__Attendee__c> getAttendee() {
    Id id = ApexPages.currentPage().getParameters().get('id');
    att = [SELECT EventApi__Contact__r.PersonID__c, 
                EventApi__Contact__r.FirstName,
                EventApi__Contact__r.LastName
           FROM EventApi__Attendee__c
           WHERE EventApi__Event__c =:id
                 AND EducationCreditEarned__c = true];
        return att;
    }
}