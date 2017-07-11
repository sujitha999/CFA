/**
 *
 * Domain class for the EventApi__Ticket_Type__c SObjectType
 * @author Vishal Shah
 *
 **/

global without sharing class TicketType_Trigger extends Framework.Domain{

    static final String bgFieldName = SObjectType.EventApi__Ticket_Type__c.fields.BusinessGroup__c.getName();
    static final RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.EventApi__Ticket_Type__Share.getName(), 
            bgFieldName, 
            PackageUtils.SHARINGCAUSE);
    static final String className = TicketType_Trigger.class.getName();

    public TicketType_Trigger(EventApi__Ticket_Type__c[] sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(SObject[] sObjectList) {
            return new TicketType_Trigger(sObjectList);
        }
    }

    public override void beforeInsert() {
        Framework.Log.push(className,'beforeInsert');
        MapParentChildFields.setDefaults(records, SObjectType.EventApi__Ticket_Type__c.fields.EventApi__Event__c.getName(), SObjectType.EventApi__Event__c.getName(), SObjectType.EventApi__Event__c.fields.EventApi__Business_Group__c.getName(), bgFieldName);
        Framework.Log.pop();
    }

    public override void afterInsert(){
        Framework.Log.push(className,'afterInsert');
        rss.ShareWithGroup(records);
        Framework.Log.pop();
    }

    public override void beforeUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(className,'beforeUpdate');
        rss.UnshareAndshareWithGroup(oldMap, records, true);       
        // code added on 25-Aug-2016
        // This Method will update Ticket Quantity to sold quantity 
        //condition when Historical_ticket_quantity is changed
        //TicketType_TriggerHelper.updateTicketQuantity((List<EventApi__Ticket_Type__c>) records, oldMap);
        Framework.Log.pop();
    }

}