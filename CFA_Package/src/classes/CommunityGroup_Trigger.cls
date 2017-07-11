/**
 *
 * Domain class for the PagesApi__Community_Group__c SObjectType
 * @author Vishal Shah
 *
 **/

global class CommunityGroup_Trigger extends Framework.Domain{

    static RecordSharingService rss = 
        new RecordSharingService(
            SObjectType.PagesApi__Community_Group__Share.getName(), 
            SObjectType.PagesApi__Community_Group__c.fields.BusinessGroup__c.getName(), 
            PackageUtils.SHARINGCAUSE);
    static String className = CommunityGroup_Trigger.class.getName();

    public CommunityGroup_Trigger(List<PagesApi__Community_Group__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new CommunityGroup_Trigger(sObjectList);
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