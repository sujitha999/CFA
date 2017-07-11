public class FormResponseWrapper{
        public string pId  {get; set;}
        public string emp  {get; set;}
        public string name {get; set;}
        public List<String> questions {get; set;}
        public List<String> answers {get; set;}
        public FormResponseWrapper(){
        }
        public FormResponseWrapper(PagesApi__Form_Response__c fr){
            this.pid = fr.EventApi__Attendee__r.EventApi__Contact__r.CFAMN__PersonID__c;
            this.emp = fr.EventApi__Attendee__r.EventApi__Contact__r.CFAMN__Employer__c;
            this.name = fr.EventApi__Attendee__r.EventApi__Full_Name__c;

            questions = new List<String>();
            answers = new List<String>();

            if(fr.PagesApi__Field_Responses__r != Null && fr.PagesApi__Field_Responses__r.size() >0){
                // this will used to check duplicate records
                Set<String> setCheckDuplicate = new Set<String>();
                for(PagesApi__Field_Response__c r : fr.PagesApi__Field_Responses__r){
                
                    /**
                     * Code conditions to check duplicate records
                     * if PagesApi__Field_Order__c & PagesApiResponse_Group__c is present in set
                     * do not add records to list
                     */
                    if(!setCheckDuplicate.contains(r.PagesApi__Field_Order__c+r.PagesApi__Response_Group__c)){
                        if(String.ISNOTBLANK(r.PagesApi__Field_Label__c)){
                        this.questions.add(r.PagesApi__Field_Label__c);
                        //this.questions.add('WWWW');
                        } else {
                            this.questions.add('');
                        }

                        if(String.ISNOTBLANK(r.PagesApi__Response__c)){
                        this.answers.add(r.PagesApi__Response__c);
                        //this.answers.add('WWWW');
                        } else {
                            this.answers.add('');
                        }
                        
                        // adding fields to set which will used to check duplicate records
                        setCheckDuplicate.add(r.PagesApi__Field_Order__c+r.PagesApi__Response_Group__c);
                    }      

                }
            }
        }

    }