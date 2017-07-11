/**
 *
 * Domain class for the OrderApi__Badge__c SObjectType
 * @author Vishal Shah
 *
 **/

global class Badge_Trigger extends Framework.Domain{

    // Badges control record sharing for Contact records
    public static RecordSharingService rss 
        = new RecordSharingService(
            SObjectType.ContactShare.getName(), 
            SObjectType.OrderApi__Badge__c.fields.BusinessGroup__c.getName(), 
            Schema.ContactShare.RowCause.Manual, 
            SObjectType.ContactShare.fields.ContactId.getName(), 
            SObjectType.OrderApi__Badge__c.fields.OrderApi__Contact__c.getName(), 
            SObjectType.ContactShare.fields.ContactAccessLevel.getName(), 
            new Map<String,String>());
    String className = Badge_Trigger.class.getName();
    
    static final String bgFieldName = SObjectType.OrderApi__Badge__c.fields.BusinessGroup__c.getName();
    static final RecordSharingService rss2 = 
        new RecordSharingService(
            SObjectType.OrderApi__Badge__Share.getName(), 
            bgFieldName, 
            PackageUtils.SHARINGCAUSE);

    public Badge_Trigger(List<OrderApi__Badge__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new Badge_Trigger(sObjectList);
        }
    }
    
    public override void beforeInsert() {
        Framework.Log.push(className,'beforeInsert');
        addCASLbadge.preventDuplicates((OrderApi__Badge__c[])records);
        Framework.Log.pop();
    }

    public override void afterInsert(){
        Framework.Log.push(className,'afterInsert');
        rss.ShareWithGroup(records);
        rss2.ShareWithGroup(records);
        UserGroupMemberService.addContactUserToGroupByBadge((new Map<Id, SObject>(records)).keySet());
        Framework.Log.pop();
    }

    public override void beforeUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(className,'beforeUpdate');
        rss.UnshareAndshareWithGroup(oldMap, records, true);
        rss2.UnshareAndshareWithGroup(oldMap, records, true);
        UserGroupMemberService.changeUserToGroupByBadge((Map<Id, OrderApi__Badge__c>) oldMap, (OrderApi__Badge__c[]) records);
        Framework.Log.pop();
    }

    public override void afterDelete(){
        Framework.Log.push(className,'afterDelete');
        OrderApi__Badge__c[] processedRecords = BadgeService.processRecordsToDelete((OrderApi__Badge__c[]) records);
        if(!processedRecords.isEmpty()){
            rss.UnshareAndshareWithGroup(new Map<Id, SObject>(records), processedRecords, false);
            UserGroupMemberService.delUserFromGroupByBadge((OrderApi__Badge__c[])processedRecords);
        }
        Framework.Log.pop();
    }
    
    public override void beforeDelete(){
        Framework.Log.push(className,'beforeDelete');
        addCASLbadge.preventDeletion((OrderApi__Badge__c[]) records);
        Framework.Log.pop();
    }

}