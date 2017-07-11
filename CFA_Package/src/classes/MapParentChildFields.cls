/**
 *
 * Service class for Mapping the Parent Fields to Child Fields
 * @author Vishal Shah
 *
 **/

public class MapParentChildFields {

    public static String className = MapParentChildFields.class.getName();

    /**
     * Return a map of Child object name to field name
     * @param List of Schema.ChildRelationship
     * @return Map<String, String>
     */
    public static Map<String, String> getRelationships(Schema.ChildRelationship[] childRelationships) {
        Map<String, String> childObjectFieldMap = new Map<String, String>();

        for(Schema.ChildRelationship chld : childRelationships) {
            Schema.DescribeSObjectResult childS = chld.getChildSObject().getDescribe();
            if(childS.isCustom()){
                childObjectFieldMap.put(childS.getName(),chld.getField().getDescribe().getName());
            }
        }
        return childObjectFieldMap;
    }

    /**
     * Default logic for SObject.
     *
     * @param records  =>  List of SObjects.
     * @param parentFieldId  =>  Field name containing the parent SObject Id in the records SObject
     * @param parentObjName  =>  parent SObject name 
     * @param parentObjFldNm  =>  Field name to copy from the parent SObject
     * @param objFldNm  =>  Field name to copy to in the child SObject
     */
    public static void setDefaults(SObject[] records, String parentFieldId, String parentObjName, String parentObjFldNm, String objFldNm) {
        Framework.Log.push(className,'setDefaults');
        Set<Id> recIds = new Set<Id>();
        for (SObject sobj : records) {
            recIds.add((Id)sobj.get(parentFieldId));
        }
        
        Map<Id,SObject> parentObjs = new Map<Id,SObject>(
            new Framework.Selector(Schema.getGlobalDescribe().get(parentObjName)).selectById(recIds)
        );
        
        for (SObject sobj : records) {
            if (parentObjs.containsKey((Id)sobj.get(parentFieldId))) {
            	sobj.put(objFldNm, parentObjs.get((Id)sobj.get(parentFieldId)).get(parentObjFldNm));
            }
        }

        Framework.Log.pop();
    }

    /**
     * Default logic for SObject.
     *
     * @param records  =>  List of SObjects.
     * @param referenceToParentId  =>  Field name containing the parent SObject Id in the records SObject
     * @param fieldMap  =>  Map of parentFieldName to childFieldName
     */
    public static void setDefaults(SObject[] records, String referenceToParentId, Map<String, String[]> fieldMap) {
        Framework.Log.push(className,'setDefaults');
        Id[] recIds = new Id[]{};
        for (SObject sobj : records) {
            recIds.add((Id)sobj.get(referenceToParentId));
        }

        Map<Id,SObject> parentRecords = new Map<Id,SObject>(
            new Framework.Selector(Framework.SchemaService.getSObjectType(recIds[0].getSObjectType().getDescribe().getName())).selectById(new Set<Id>(recIds))
        );

        for (SObject sobj : records) {
            Id fieldId = (Id)sobj.get(referenceToParentId);
            if (parentRecords.containsKey(fieldId)) {
                SObject parentObj = parentRecords.get(fieldId);
                for(String parentObjFieldName : fieldMap.keySet()) {
                    Object value = parentObj.get(parentObjFieldName);
                    for(String field : fieldMap.get(parentObjFieldName)) {
                        sobj.put(field, value);
                    }
                }
            }
        }

        Framework.Log.pop();
    }

    /**
     * Updates related items every time the SObject look-up is updated,
     * @event afterUpdate
     * @param oldMap Map<Id,SObject> 
     * @param records SObject[]
     * @param lookupFieldName of the parent object
     * 
     */
    public static void updateRelaltedItems(Map<Id,SObject> oldMap, SObject[] records, String lookupFieldName) {
        Framework.Log.push(className,'updateRelaltedItems');

        Map<Id, SObject> recordSobjMap = new Map<Id,SObject>();

        for(SObject sobj: records) {
            if(sobj.get(lookupFieldName) != oldMap.get(sobj.Id).get(lookupFieldName)) {
                recordSobjMap.put(sobj.Id, sobj);
            }
        }

        if(!recordSobjMap.isEmpty()) {

            Map<String, String> recordsChildObjectFieldMap = getRelationships((records[0].Id).getSObjectType().getDescribe().getChildRelationships());
            Map<String, String> parentChildObjectFieldMap = getRelationships(((Id)records[0].get(lookupFieldName)).getSObjectType().getDescribe().getChildRelationships());

            String[] objs = new String [] {};
            for(String key: parentChildObjectFieldMap.keySet()){
                if(recordsChildObjectFieldMap.containsKey(key)){
                    objs.add(key);
                }
            }

            SObject[] upds = new SObject[]{};

            for(String s: objs) {
                Schema.SObjectType sObjTyp = Schema.getGlobalDescribe().get(s);

                Set<Id> keyset = recordSobjMap.keySet();

                for(SObject sObj : Database.query('SELECT Id, ' + parentChildObjectFieldMap.get(s) + ', ' + recordsChildObjectFieldMap.get(s) + ' FROM ' + s + ' WHERE ' + recordsChildObjectFieldMap.get(s) + ' = :keyset')) {
                    sObj.put(parentChildObjectFieldMap.get(s),  recordSobjMap.get((Id)sObj.get(recordsChildObjectFieldMap.get(s))).get(lookupFieldName));
                    upds.add(sObj);
                }
            }

            if(upds.size() > 0) {
                Database.SaveResult[] srList = Database.update(upds, false);

                // Process the save results.
                for (Database.SaveResult sr : srList) {
                    
                    // For any failures
                    if(!sr.isSuccess()){
                        // Get first save result error.
                        Database.Error err = sr.getErrors()[0];    
                            
                        System.Debug(err.getMessage());
                    
                        Framework.Log.debug(err.getMessage() + ' for upds -> SaveResult');
                        
                    }
                }
            }
        }

        Framework.Log.pop();
    }

}