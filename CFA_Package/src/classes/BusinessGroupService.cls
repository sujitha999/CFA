/**
 *
 * Service class for OrderApi__Business_Group__c
 * @author Vishal Shah
 *
 **/

public class BusinessGroupService {
    /**
     * Default logic for SObject.
     *
     * @param records  =>  List of SObjects.
     */
    public static void setDefaults(OrderApi__Business_Group__c[] records) {
        Framework.Log.push(BusinessGroupService.class.getName(),'setDefaults');
        
        for (OrderApi__Business_Group__c bg : records) {
            Boolean error = false;
            Id idValue;
			try {
			 idValue = Id.valueOf(bg.SystemPublicGroupId__c);
			}
			catch (Exception e) {
				error = true;
			}

			if (error || idValue.getSObjectType() != Group.SObjectType) {
				bg.SystemPublicGroupId__c.addError('Public Group Id is invalid');
			}
        }

        Framework.Log.pop();
    }

}