/**
 *
 * Domain class for the OrderApi__Business_Group__c SObjectType
 * @author Vishal Shah
 * 
 **/

global class BusinessGroup_Trigger extends Framework.Domain{

    static RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.OrderApi__Business_Group__Share.getName(), 
            SObjectType.OrderApi__Business_Group__c.fields.SystemPublicGroupId__c.getName(), 
            PackageUtils.SHARINGCAUSE);
        
    static String className = BusinessGroup_Trigger.class.getName();
    
    public BusinessGroup_Trigger(List<OrderApi__Business_Group__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new BusinessGroup_Trigger(sObjectList);
        }
    }
    
    public override void beforeInsert(){
        Framework.Log.push(className,'beforeInsert');
        BusinessGroupService.setDefaults((OrderApi__Business_Group__c[]) records);
        Framework.Log.pop();
    }

    public override void afterInsert(){
        Framework.Log.push(className,'afterInsert');
        rss.ShareWithGroup(records);
        Framework.Log.pop();
    }

    public override void beforeUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(className,'beforeUpdate');
        rss.UnshareAndShareWithGroup(oldMap, records, true);
        Framework.Log.pop();
    }
    
}