/**
 *
 * Domain class for the OrderApi__Sales_Order__c SObjectType
 * @author Vishal Shah
 *
 **/

global without sharing class SalesOrder_Trigger extends Framework.Domain{

    static final String bgFieldName = SObjectType.OrderApi__Sales_Order__c.fields.OrderApi__Business_Group__c.getName();
    static final RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.OrderApi__Sales_Order__Share.getName(), 
            bgFieldName, 
            PackageUtils.SHARINGCAUSE);
    static final String className = SalesOrder_Trigger.class.getName();

    public SalesOrder_Trigger(OrderApi__Sales_Order__c[] sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(SObject[] sObjectList) {
            return new SalesOrder_Trigger(sObjectList);
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
        TXWR_ProcessSO.beforeupdateConditions((OrderApi__Sales_Order__c[])records, (map<id,OrderApi__Sales_Order__c>)oldMap);
        Framework.Log.pop();
    }
    
    public override void AfterUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(className,'beforeUpdate');
        addCASLbadge.insertCASLbadge((OrderApi__Sales_Order__c[])records, (map<id,OrderApi__Sales_Order__c>)oldMap);
        TXWR_ProcessSO.updateConditions((OrderApi__Sales_Order__c[])records, (map<id,OrderApi__Sales_Order__c>)oldMap);
        Framework.Log.pop();
    }

}