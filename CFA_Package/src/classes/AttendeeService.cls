/**
 *
 * Service class for EventApi__Attendee__c
 * @author Vishal Shah
 *
 **/

public class AttendeeService {

    public static String className = AttendeeService.class.getName(); 

    /**
     * Default logic for SObject.
     *
     * @param oldMap  =>  Map<Id, EventApi__Attendee__c> of old record data
     * @param records  =>  List of EventApi__Attendee__c.
     */
    public static void processEduCredits(Map<Id, EventApi__Attendee__c> oldMap, EventApi__Attendee__c[] records) {
        Framework.Log.push(className,'processEduCredits');

        Set<Id> deleteEarnedCredits = new Set<Id>();
        Set<Id> eventCredits = new Set<Id>();
        EventApi__Attendee__c[] addEarnedCredits = new EventApi__Attendee__c[]{};

        for(EventApi__Attendee__c att: records) {
            Boolean oldVal = (Boolean)oldMap.get(att.Id).get(SObjectType.EventApi__Attendee__c.fields.EducationCreditEarned__c.getName());
            Boolean newVal = att.EducationCreditEarned__c;

            if(oldVal == true && newVal == false) {
                deleteEarnedCredits.add(att.Id);
            } else if(oldVal == false && newVal == true) {
                eventCredits.add(att.EventApi__Event__c);
                addEarnedCredits.add(att);
            }

        }

        if(deleteEarnedCredits.size() > 0) {
            Database.DeleteResult[] delList = Database.delete(Database.query('Select Id from ' + SObjectType.Education_Credit__c.getName() + ' where ' + SObjectType.Education_Credit__c.fields.Attendee__c.getName() + ' in :deleteEarnedCredits'), false);
            for(Database.DeleteResult dr: delList) {
                if(!dr.isSuccess()) {
                    for(Database.Error err : dr.getErrors()) {
                        System.debug('The following error has occurred.');                   
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }

        if(addEarnedCredits.size() > 0) {
            Map<Id, EventApi__Event__c> events = new Map<Id, EventApi__Event__c> ([SELECT Id, EducationCreditValue__c, SER_Credit_Value__c FROM EventApi__Event__c WHERE Id in :eventCredits]);
            Education_Credit__c[] ecs = new Education_Credit__c[]{};
            for(EventApi__Attendee__c att : addEarnedCredits) {
                ecs.add( new Education_Credit__c(
                    Attendee__c = att.Id, 
                    Contact__c = att.EventApi__Contact__c, 
                    EarnedCredits__c = (Decimal)events.get(att.EventApi__Event__c).get(SObjectType.EventApi__Event__c.fields.EducationCreditValue__c.getName()),
                    Earned_SER_Credit__c = (Decimal)events.get(att.EventApi__Event__c).get(SObjectType.EventApi__Event__c.fields.SER_Credit_Value__c.getName())
                    )
                );
            }

            if(ecs.size() > 0) {
                Database.SaveResult[] srList = Database.insert(ecs, false);
                for(Database.SaveResult sr: srList) {
                    if(!sr.isSuccess()) {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                   
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Attendee fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }

        }

        Framework.Log.pop();
    }
    
    /**
    public static void attendeeInsertService(List<EventApi__Attendee__c> lstAttendee){
       
        Set<id> setEvents = new Set<id>();                                                              //This set will save the related event Ids
        Set<id> setTtypes = new Set<id>();                                                              //This set will save the related ticket type Ids
        Set<id> setEventCapacity = new Set<id>();                                                       //This set will save the id of the event where capcaity is reached
        List<EventApi__Event__c> updateEvent = new List<EventApi__Event__c>();                          //This list will save all the updated events
        List<EventApi__Ticket_Type__c> updateTtype = new List<EventApi__Ticket_Type__c>();              //This list will save all the updated ticket types
        
        // this will save the map and number of attendees
        map<string,integer> mapEventAttendeeCount = new map<string,integer>();
        map<string,integer> mapEventTicketTypeCount = new map<string,integer>();
        
        // this will save event details
        set<id> setEveId = new set<id>();
        
        // code to get event details
        for(EventApi__Attendee__c at : lstAttendee) {
            setEveId.add(at.EventApi__Event__c);
        }
        
        // getting event details
        map<id,EventApi__Event__c> mapDetails = new map<id,EventApi__Event__c>([Select Id,
                                                                                       EventApi__Registration_Style__c
                                                                                       FROM EventApi__Event__c
                                                                                       WHERE ID IN:setEveId]);
        
        for(EventApi__Attendee__c at : lstAttendee) {
            if(at.EventApi__Status__c == 'Registered'){
            
                if(mapDetails.containsKey(at.EventApi__Event__c)
                    && mapDetails.get(at.EventApi__Event__c).EventApi__Registration_Style__c != 'Lightning Event'){
                         
                    setEvents.add(at.EventApi__Event__c);
                    setTtypes.add(at.EventApi__Ticket_Type__c);
                
                    if(!mapEventAttendeeCount.containsKey(at.EventApi__Event__c)){
                        mapEventAttendeeCount.put(at.EventApi__Event__c,1);
                    }
                    else{
                        Integer count = mapEventAttendeeCount.get(at.EventApi__Event__c);
                        mapEventAttendeeCount.put(at.EventApi__Event__c,(count+1));
                    }
                
                    // updating tickrt type
                    if(!mapEventTicketTypeCount.containsKey(at.EventApi__Ticket_Type__c)){
                        mapEventTicketTypeCount.put(at.EventApi__Ticket_Type__c,1);
                    }
                    else{
                        Integer count = mapEventTicketTypeCount.get(at.EventApi__Ticket_Type__c);
                        mapEventTicketTypeCount.put(at.EventApi__Ticket_Type__c,(count+1));
                    }
                }
            }
        }

        for(EventApi__Event__c ev : [SELECT Id,
                                            EventApi__Attendees__c,
                                            EventApi__Quantity_Sold__c,
                                            EventApi__Capacity__c
                                            FROM EventApi__Event__c
                                            WHERE Id IN: setEvents]) {
                                                
            ev.EventApi__Attendees__c += mapEventAttendeeCount.get(ev.id);
            ev.EventApi__Quantity_Sold__c += mapEventAttendeeCount.get(ev.id);
            updateEvent.add(ev);            
        }
                
        //check the updated event record for capacity
        for(EventApi__Event__c e : updateEvent){
            if(e.EventApi__Quantity_Sold__c >= e.EventApi__Capacity__c){
                e.EventApi__Sold_Out__c = TRUE;
            }
        }
        
        // update events
        for(EventApi__Ticket_Type__c t : [SELECT Id,
                                                 EventApi__Quantity_Available__c,
                                                 EventApi__Quantity_Sold__c,
                                                 CFAMN__Historical_ticket_quantity__c,
                                                 EventApi__Event__c
                                                 FROM EventApi__Ticket_Type__c
                                                 WHERE Id IN: setTtypes]){
                                                  
            t.EventApi__Quantity_Sold__c +=  mapEventTicketTypeCount.get(t.id);
            updateTtype.add(t);
        }
         
        Savepoint sp = Database.setSavepoint();          //creating save point       
        if(!updateTtype.isEmpty()){                      //check if list has records for updating
            try{
                update updateTtype;  
            }catch(Exception ex){
               Database.rollback(sp);                    //Rollback to the previous null value
            }
        }
        
        if(!updateEvent.isEmpty()){
            try{
                update updateEvent; 
            }catch (Exception e){
                Database.rollback(sp);                    //Rollback to the previous null value
            }
        }
    }
    
    public static void attendeeUpdateService(List<EventApi__Attendee__c> lstAttendee, map<id,EventApi__Attendee__c> oldMap){
        
        Set<id> setEvents = new Set<id>();                                                              //This set will save the related event Ids
        Set<id> setTtypes = new Set<id>();                                                              //This set will save the related ticket type Ids
        Set<id> setEventCapacity = new Set<id>();                                                       //This set will save the id of the event where capcaity is reached
        List<EventApi__Event__c> updateEvent = new List<EventApi__Event__c>();                          //This list will save all the updated events
        List<EventApi__Ticket_Type__c> updateTtype = new List<EventApi__Ticket_Type__c>();              //This list will save all the updated ticket types
        
        // this will save the mao and number of attandee
        map<string,integer> mapEventAttendeeCount = new map<string,integer>();
        map<string,integer> mapEventTicketTypeCount = new map<string,integer>();
        
        set<id> setEveId = new set<id>();
        
        // code to get event details
        for(EventApi__Attendee__c at : lstAttendee) {
            setEveId.add(at.EventApi__Event__c);
        }
        
        // getting event details
        map<id,EventApi__Event__c> mapDetails = new map<id,EventApi__Event__c>([Select Id,
                                                                                       EventApi__Registration_Style__c
                                                                                       FROM EventApi__Event__c
                                                                                       WHERE ID IN:setEveId]);
        
        for(EventApi__Attendee__c a : lstAttendee){
        
            if(mapDetails.containsKey(a.EventApi__Event__c)
                && mapDetails.get(a.EventApi__Event__c).EventApi__Registration_Style__c != 'Lightning Event'){
                
                EventApi__Attendee__c oldData = oldMap.get(a.Id);
                if(a.EventApi__Status__c != 'Registered' && oldData.EventApi__Status__c != a.EventApi__Status__c){
                
                    if(!mapEventAttendeeCount.containsKey(a.EventApi__Event__c)){
                        mapEventAttendeeCount.put(a.EventApi__Event__c,-1);
                    }
                    else{
                        Integer count = mapEventAttendeeCount.get(a.EventApi__Event__c);
                        mapEventAttendeeCount.put(a.EventApi__Event__c,(count-1));
                    }
                
                    // updating tickrt type
                    if(!mapEventTicketTypeCount.containsKey(a.EventApi__Ticket_Type__c)){
                        mapEventTicketTypeCount.put(a.EventApi__Ticket_Type__c,-1);
                    }
                    else{
                        Integer count = mapEventTicketTypeCount.get(a.EventApi__Ticket_Type__c);
                        mapEventTicketTypeCount.put(a.EventApi__Ticket_Type__c,(count-1));
                    }
                
                    setEvents.add(a.EventApi__Event__c);
                    setTtypes.add(a.EventApi__Ticket_Type__c);
                
                }
                if(a.EventApi__Status__c == 'Registered' && oldData.EventApi__Status__c != a.EventApi__Status__c){
                
                    setEvents.add(a.EventApi__Event__c);
                    setTtypes.add(a.EventApi__Ticket_Type__c);
                
                    if(!mapEventAttendeeCount.containsKey(a.EventApi__Event__c)){
                        mapEventAttendeeCount.put(a.EventApi__Event__c,1);
                    }
                    else{
                        Integer count = mapEventAttendeeCount.get(a.EventApi__Event__c);
                        mapEventAttendeeCount.put(a.EventApi__Event__c,(count+1));
                    }
                
                    // updating ticket type
                    if(!mapEventTicketTypeCount.containsKey(a.EventApi__Ticket_Type__c)){
                        mapEventTicketTypeCount.put(a.EventApi__Ticket_Type__c,1);
                    }
                    else{
                        Integer count = mapEventTicketTypeCount.get(a.EventApi__Ticket_Type__c);
                        mapEventTicketTypeCount.put(a.EventApi__Ticket_Type__c,(count-1));
                    }
                } 
            }
        }

        for(EventApi__Event__c ev : [SELECT Id,
                                            EventApi__Attendees__c,
                                            EventApi__Quantity_Sold__c,
                                            EventApi__Capacity__c
                                            FROM EventApi__Event__c
                                            WHERE Id IN: setEvents]) {
                                                
            ev.EventApi__Attendees__c += mapEventAttendeeCount.get(ev.id);
            ev.EventApi__Quantity_Sold__c += mapEventAttendeeCount.get(ev.id);
            updateEvent.add(ev);            
        }
                
        //check the updated event record for capacity
        for(EventApi__Event__c e : updateEvent){
            if(e.EventApi__Quantity_Sold__c >= e.EventApi__Capacity__c){
                e.EventApi__Sold_Out__c = TRUE;
            }
        }
        
        // update events
        for(EventApi__Ticket_Type__c t : [SELECT Id,
                                                 EventApi__Quantity_Available__c,
                                                 EventApi__Quantity_Sold__c,
                                                 CFAMN__Historical_ticket_quantity__c,
                                                 EventApi__Event__c
                                                 FROM EventApi__Ticket_Type__c
                                                 WHERE Id IN: setTtypes]){
                                                  
            t.EventApi__Quantity_Sold__c +=  mapEventTicketTypeCount.get(t.id);
            updateTtype.add(t);
        }
         
        Savepoint sp = Database.setSavepoint();          //creating save point       
        if(!updateTtype.isEmpty()){                      //check if list has records for updating
            try{
                update updateTtype;  
            }catch(Exception ex){
               Database.rollback(sp);                    //Rollback to the previous null value
            }
        }
        
        if(!updateEvent.isEmpty()){
            try{
                update updateEvent;
            }catch (Exception e){
                Database.rollback(sp);                    //Rollback to the previous null value
            }
        }
    }
    **/
}