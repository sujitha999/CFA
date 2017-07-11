public class VenueEventReminderCntrl {
    private List<EventApi__Venue__c> venue;
    public Id attendeeId {get; set;}

    public VenueEventReminderCntrl() {       
    }

    public List<EventApi__Venue__c> getVenues() {
    
        
        venue = [SELECT Name,
                        EventApi__Description__c,
                        EventApi__Street__c,
                        EventApi__City__c,
                        EventApi__State__c,
                        EventApi__Country__c,
                        EventApi__Postal_Code__c
                        FROM EventApi__Venue__c 
                        WHERE EventApi__Is_Primary_Venue__c = True AND
                              EventApi__Event__c IN 
                        (SELECT EventApi__Event__c
                                FROM EventApi__Attendee__c
                                WHERE Id = :attendeeId)];
        
        return venue;
    } 
}