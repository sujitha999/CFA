/**
 *
 * Domain class for the OrderApi__Receipt__c SObjectType
 * @author Vishal Shah
 *
 **/

global class Receipt_Trigger extends Framework.Domain{

    static final String bgFieldName = SObjectType.OrderApi__Receipt__c.fields.OrderApi__Business_Group__c.getName();
    static final RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.OrderApi__Receipt__Share.getName(), 
            bgFieldName, 
            PackageUtils.SHARINGCAUSE);
    static final String className = Receipt_Trigger.class.getName();

    public Receipt_Trigger(OrderApi__Receipt__c[] sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(SObject[] sObjectList) {
            return new Receipt_Trigger(sObjectList);
        }
    }

    public override void afterInsert(){
        Framework.Log.push(className,'afterInsert');
        rss.ShareWithGroup(records);
        Framework.Log.pop();
    }

    public override void beforeUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(className,'beforeUpdate');
        receiptRefundConfirmation.receiptPostTXWR((OrderApi__Receipt__c[]) records, oldMap);
        rss.UnshareAndshareWithGroup(oldMap, records, true);
        Framework.Log.pop();
    }
    
    public override void afterUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(className,'afterUpdate');
        receiptRefundConfirmation.attendeeWriteBack((OrderApi__Receipt__c[]) records, oldMap);
        TXWR_ProcessRC.updateConditions((OrderApi__Receipt__c[])records, (map<id,OrderApi__Receipt__c>)oldMap);
        Framework.Log.pop();
    }
}