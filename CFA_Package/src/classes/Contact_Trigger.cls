/**
 *
 * Domain class for the Contact SObjectType
 * @author Vishal Shah
 *
 **/

global class Contact_Trigger extends Framework.Domain{

    public Contact_Trigger(List<Contact> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new Contact_Trigger(sObjectList);
        }
    }

    public override void beforeInsert(){
        Framework.Log.push(Contact_Trigger.class.getName(),'beforeInsert');
        ContactService.setLocalNames((Contact[])records);
        ContactService.setDiscountEligibility((Contact[])records);
        Framework.Log.pop();
    }
    
    public override void afterUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(Contact_Trigger.class.getName(),'afterUpdate'); 
        ContactRetainSharing.retainSharing(oldMap, records);
        Framework.Log.pop();
    }
    
    public override void beforeUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(Contact_Trigger.class.getName(),'beforeInsert');
        ContactService.setDiscountEligibility((Contact[])records);
        Framework.Log.pop();
    }
}