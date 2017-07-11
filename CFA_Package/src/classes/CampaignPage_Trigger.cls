/**
 *
 * Domain class for the OrderApi__Campaign_Page__c SObjectType
 * @author Vishal Shah
 *
 **/

global class CampaignPage_Trigger extends Framework.Domain{

    static final String bgFieldName = SObjectType.OrderApi__Campaign_Page__c.fields.OrderApi__Business_Group__c.getName();
    static final RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.OrderApi__Campaign_Page__Share.getName(), 
            bgFieldName, 
            PackageUtils.SHARINGCAUSE);
    static final String className = CampaignPage_Trigger.class.getName();

    public CampaignPage_Trigger(OrderApi__Campaign_Page__c[] sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(SObject[] sObjectList) {
            return new CampaignPage_Trigger(sObjectList);
        }
    }

    public override void afterInsert(){
        Framework.Log.push(className,'afterInsert');
        rss.ShareWithGroup(records);
        Framework.Log.pop();
    }

    public override void beforeUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(className,'beforeUpdate');
        rss.UnshareAndshareWithGroup(oldMap, records, true);
        Framework.Log.pop();
    }

}