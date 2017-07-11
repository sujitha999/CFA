/**
 *
 * Domain class for the OrderApi__Tax_Locale__c SObjectType
 * @author Vishal Shah
 *
 **/

global class TaxLocale_Trigger extends Framework.Domain{

    RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.OrderApi__Tax_Locale__Share.getName(), 
            SObjectType.OrderApi__Tax_Locale__c.fields.OrderApi__Business_Group__c.getName(),
            PackageUtils.SHARINGCAUSE
            );

    public TaxLocale_Trigger(List<OrderApi__Tax_Locale__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new TaxLocale_Trigger(sObjectList);
        }
    }

    public override void afterInsert(){
        Framework.Log.push(TaxLocale_Trigger.class.getName(),'afterInsert');
        rss.ShareWithGroup(records);
        Framework.Log.pop();
    }

    public override void beforeUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(TaxLocale_Trigger.class.getName(),'beforeUpdate');
        rss.UnshareAndshareWithGroup(oldMap, records, true);
        Framework.Log.pop();
    }

}