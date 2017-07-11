Public Class AttendeeEnhancedListController{
    public List<EventApi__Attendee__c> listAtt {get; set;}
    public List<EAWrapper> listEAW {get; set;}
    String EventId;

    public AttendeeEnhancedListController(){
        EventId = Apexpages.currentPage().getparameters().get('eId');
        listAtt = new List<EventApi__Attendee__c>();
        listEAW = new List<EAWrapper>();
      
        if(EventId != Null && EventId != '')
            getEAs(EventId);
    }

    public void getEAs(String EventId){
        listEAW.clear();
        //Add conditions and change queires based on them for the list views. 
        string soqlString = 'Select Name, EventApi__Full_Name__c,   EventApi__Contact__c, EventApi__Event__c, BusinessGroupName__c, EducationCreditEarned__c, EventApi__Status__c, EventApi__Ticket_Type__c From EventApi__Attendee__c WHERE EventApi__Event__c =:EventId';
        //soqlString = soqlString + 'Nulls Last Limit 5000';
        for(EventApi__Attendee__c e : database.query(soqlString)){
            listEAW.add(new EAWrapper(e));
        }
    }
    public class EAWrapper{
        public EventApi__Attendee__c EA {get; set;}
        public boolean isSelected {get; set;}
        public EAWrapper(EventApi__Attendee__c tempEA){
            isSelected = false;
            EA = tempEA;
        }
    }

    public void save(){
        Set<EventApi__Attendee__c> setEA = new Set<EventApi__Attendee__c>();
        for(EAWrapper eaw : listEAW){
            if(eaw.isSelected){
            setEA.add(eaw.EA);
            }
        }
        if(setEA.size() > 0){       
            update new List<EventApi__Attendee__c>(setEA);
            getEAS(eventId);
        }
         else
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select atleast one record to save'));
    }
    
   
    public string fieldToUpdate {get;set;}
    public string selectedId {get; set;}
    public string fieldValue{
        get{
            system.debug('*********'+selectedId);
            //grab the value from the selected object
            for(EAWrapper o : listEAW){
            if(o.EA.Id == selectedId){
                
                if(fieldToUpdate == 'EducationCreditEarned'){
                    if(o.EA.EducationCreditEarned__c == true)
                    {
                    return 'true';
                    } else {
                    return 'false';
                    }
                }
                if(fieldToUpdate == 'Status'){
                    return o.EA.EventApi__Status__c;
                }
            }
        }
        return '';
    } set;
    }

    public PageReference sync(){
            system.debug('@@@@@@@@'+fieldToUpdate+selectedId);
           
        for(EAWrapper o : listEAW){
            //update all selected objects with that value
            
            if(o.isSelected){
                if(fieldToUpdate == 'EducationCreditEarned'){
                    if(fieldValue == 'true')
                    {
                    o.EA.EducationCreditEarned__c = true;
                    } else {
                    o.EA.EducationCreditEarned__c = false;
                    }
                }
                if(fieldToUpdate == 'Status'){
                    o.EA.EventApi__Status__c = fieldValue;
                }
                //Populate all Fields
            }
           
        }
        return null;
    }   
    
    public pagereference back(){
        Pagereference pg =  new Pagereference('/'+EventId); 
        pg.setRedirect(true);
        return pg;
    }

}