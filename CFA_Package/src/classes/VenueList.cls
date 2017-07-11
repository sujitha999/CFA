public class VenueList {
    private List<EventApi__Venue__c> venue;
    public Id attendeeId {get; set;}

    public VenueList() {       
    }

    public List<EventApi__Venue__c> getVenues() {
    
        
        venue = [SELECT Name,
                        EventApi__Description__c
                        FROM EventApi__Venue__c 
                        WHERE EventApi__Event__c IN 
                        (SELECT EventApi__Event__c
                                FROM EventApi__Attendee__c
                                WHERE Id = :attendeeId)];
        
        return venue;
    } 
}