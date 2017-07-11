/**
 *
 * Domain class for the PagesApi__Site__c SObjectType
 * @author Vishal Shah
 *
 **/

global class Site_Trigger extends Framework.Domain{

    static RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.PagesApi__Site__Share.getName(), 
            SObjectType.PagesApi__Site__c.fields.OrderApi__Business_Group__c.getName(), 
            PackageUtils.SHARINGCAUSE);
    static String className = Site_Trigger.class.getName();

    public Site_Trigger(List<PagesApi__Site__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new Site_Trigger(sObjectList);
        }
    }

    public override void afterInsert(){
        Framework.Log.push(className,'afterInsert');
        rss.ShareWithGroup(records);
        Framework.Log.pop();
    }

    public override void beforeUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(className,'beforeUpdate');
        SiteService.applyDefaults((PagesApi__Site__c[]) records);
        rss.UnshareAndshareWithGroup(oldMap, records, true);
        Framework.Log.pop();
    }

    public override void afterUpdate(Map<Id,SObject> oldMap) {
        Framework.Log.push(className,'afterUpdate');
        SiteService.setBusinessGroupOnTheme((Map<Id, PagesApi__Site__c>) oldMap, (PagesApi__Site__c[]) records);
        Framework.Log.pop();

    }

}