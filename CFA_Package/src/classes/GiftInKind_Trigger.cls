/**
 *
 * Domain class for the DonorApi__Gift_In_Kind__c SObjectType
 * @author Vishal Shah
 * 
 **/

global class GiftInKind_Trigger extends Framework.Domain{

    static final String bgFieldName = SObjectType.DonorApi__Gift_In_Kind__c.fields.DonorApi__Business_Group__c.getName();
    static final RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.DonorApi__Gift_In_Kind__Share.getName(), 
            bgFieldName, 
            PackageUtils.SHARINGCAUSE);
    static final String className = GiftInKind_Trigger.class.getName();
    
    public GiftInKind_Trigger(DonorApi__Gift_In_Kind__c[] sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(SObject[] sObjectList) {
            return new GiftInKind_Trigger(sObjectList);
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