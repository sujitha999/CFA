/**
 * @author Vishal Shah
 **/
 
global without sharing class RecordSharingService {

    String shrObjName;
    String objBusGrpField;
    String rowCause;

    String shareIdLabel;
    static String USRGRPIDLABEL = 'UserOrGroupId';
    String accLevelLabel;
    static String ROWCAUSELABEL = 'RowCause';
    String objShrIdField;

    
    static String ACCLEVEL = 'Edit';

    Map<String, String> stdAccLevel;

    Schema.SObjectType shareObjectType;
    Boolean fldIsName = false;

    // Custom Object Request 
    global RecordSharingService(String shrName, String busGrpField, String rowCause) {
        this.init(shrName, busGrpField, rowCause, 'ParentId', 'Id', 'AccessLevel', new Map<String, String>());
    }

    // Standard Object Request 
    global RecordSharingService(String shrName, String busGrpField, String rowCause, String shrId, String shrIdField, String shrAccLevel, Map<String, String> addAccLevel) {
        this.init(shrName, busGrpField, rowCause, shrId, shrIdField, shrAccLevel, addAccLevel);
    }

    private void init(String shrName, String busGrpField, String rowCause, String shrId, String shrIdField, String shrAccLevel, Map<String, String> addAccLevel) {
        this.shrObjName = shrName;
        this.objBusGrpField = busGrpField;
        this.rowCause = rowCause;
        this.shareIdLabel = shrId;
        this.objShrIdField = shrIdField;
        this.accLevelLabel = shrAccLevel;
        this.stdAccLevel = addAccLevel;
        this.shareObjectType = Schema.getGlobalDescribe().get(this.shrObjName);
        this.fldIsName = this.shrObjName.equals(SObjectType.OrderApi__Business_Group__Share.getName());
    }

    private void saveData(SObject[] data) {
        // Insert the sharing record and capture the save result. 
        // The false parameter allows for partial processing if multiple records passed 
        // into the operation.
        Database.SaveResult[] srList = Database.insert(data,false);

        // Process the save results.
        for (Database.SaveResult sr : srList) {
            
            // For any failures
            if(!sr.isSuccess()){
                // Get first save result error.
                Database.Error err = sr.getErrors()[0];

                // Check if the error is related to trival access level.
                // Access levels equal or more permissive than the object's default 
                // access level are not allowed. 
                // These sharing records are not required and thus an insert exception is acceptable. 
                if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
                    err.getMessage().contains(ACCLEVEL))){
                    
                    // Indicates failure.
                    System.debug(err.getMessage() + ' for ShareWithGroup -> SaveResult');
                }
            }
        }
    }

    private void deleteData(String qry, Set<Id> changeRecId, Id[] grpIds) {
        // Delete the sharing record and capture the delete result. 
        // The false parameter allows for partial processing if multiple records passed 
        // into the operation.
        
        Database.DeleteResult[] drList = Database.delete(Database.query(qry),false);

        // Process the Delete results.
        for (Database.DeleteResult dr : drList) {
            if(!dr.isSuccess()){
                // Get first delete result error.
                Database.Error err = dr.getErrors()[0];

                // Indicates failure.
                Framework.Log.debug(err.getMessage() + ' for ShareAndUnshareWithGroup -> DeleteResult');
                
            }
        }
    }

    global void ShareWithGroup (SObject[] records) {
        system.debug('**** We are inside the ShareWithGroup method');
        Framework.Log.push(RecordSharingService.class.getName(),'ShareWithGroup');

        SObject[] shareRecords = new SObject[]{};
        Map<Id, Id> bgMap = bGroup(records);

        /* 
         * The below loop uses the Share object to set Manual sharing
         * of each record that is created or updated with the relevant Group created
         * in the system. Refer to Salesforce Docs for Custom Object Share
         * record documentation, similar to ContactShare. A default entry for the 
         * record is created for the Owner with AccessLevel as All.
         *
         * @attr: ParentId => record.Id
         * @attr: UserOrGroupId => group.Id 
         * @attr: AccessLevel => 'Edit'
         */
         if(!bgMap.isEmpty()) {
         System.debug('*** Inside if statement');
            for(SObject s: records) {
                Id recordId = (Id)s.get(objShrIdField);
                Id groupId = (Id)s.get(fldIsName ? 'Id' : objBusGrpField);
                if(recordId != null && groupId != null) {
                    SObject shareObj = shareObjectType.newSObject();

                    shareObj.put(shareIdLabel, recordId);
                    shareObj.put(USRGRPIDLABEL, bgMap.get(groupId));
                    shareObj.put(accLevelLabel, ACCLEVEL);
                    shareObj.put(ROWCAUSELABEL, rowCause);                

                    if(!stdAccLevel.isEmpty()) {
                        for(String key: stdAccLevel.keySet()) {
                            shareObj.put(key, stdAccLevel.get(key));
                        }
                    }
                    shareRecords.add(shareObj);
                }
            }
            this.saveData(shareRecords);
        }

        Framework.Log.pop();
    }

    global void UnshareAndShareWithGroup (Map<Id, SObject> oldMap, SObject[] records, Boolean createNewShare) {
        Framework.Log.push(RecordSharingService.class.getName(),'UnshareAndShareWithGroup');

        Map<Id, SObject> chngMap = new Map<Id, SObject>();

        // For each record check for change in Name (if Business Group) or Business Groups Id
        for(SObject s: records){
            if(!(oldMap != null && s.get(objBusGrpField) != null && !oldMap.isEmpty() && ((String)s.get(objBusGrpField)).equals((String)(oldMap.get(s.Id)).get(objBusGrpField))) || !createNewShare) {  
                chngMap.put((Id)s.get(objShrIdField),s); 
            }
        }

        if(!chngMap.isEmpty()) {

            Map<Id, Id> bgMap = bGroup(oldMap.values());

            Id[] grpIds = bgMap.values();
            Set<Id> changeRecId = chngMap.keySet();
            // Retrieve Share records for objects that have changed
            String chgShr = String.format('SELECT Id, {0}, {1}, {2} FROM {3} WHERE {0} IN :changeRecId AND {1} IN :grpIds AND {2} = {4} AND RowCause = {5}', 
                new String[] {shareIdLabel, USRGRPIDLABEL, accLevelLabel, shrObjName, '\''+ACCLEVEL+'\'', '\''+rowCause+'\''});

            this.deleteData(chgShr, changeRecId, grpIds);

            if(createNewShare) {
                this.ShareWithGroup(chngMap.values());
            }
        }

        Framework.Log.pop();
    }

    /**
     * Return the Business Group Name to Id mapping for all the records
     * @param records SObject[]
     */
    private Map<Id, Id> bGroup(SObject[] records) {
        Id[] businessGroups = new Id[]{};
        Map<Id, Id> bgMap = new Map<Id, Id>();

        /* 
         * Collecting the owner id's. 
         * For Business Group object, set the Name to Id mapping,
         * else get the Object Business Group Id
         */
        for(SObject s: records) {
            if(fldIsName){
                bgMap.put(s.Id, (Id)s.get(SObjectType.OrderApi__Business_Group__c.fields.SystemPublicGroupId__c.getName()));
            } else if(s.get(objBusGrpField) != null) {
                businessGroups.add((Id)s.get(objBusGrpField));           
            }
        }

        // Retrieve the Business Group Name to Id mapping for all the records
        // if object is other than Business Group
        if(bgMap.isEmpty() && !businessGroups.isEmpty()) {
            for (OrderApi__Business_Group__c bg : [SELECT Id, SystemPublicGroupId__c FROM OrderApi__Business_Group__c WHERE Id in :businessGroups]) {
                bgMap.put(bg.Id, (Id)bg.SystemPublicGroupId__c);
            }
        }

        return bgMap;
    }
        
}