/**
 *
 * Service class for OrderApi__Store__c
 * @author Vishal Shah
 *
 **/

public class StoreService {

    public static String className = StoreService.class.getName();

    /**
     * Default logic for SObject.
     *
     * @param records  =>  List of SObjects.
     */
    public static void setDefaults(OrderApi__Store__c[] records) {
        Framework.Log.push(className,'setDefaults');
        
        for (OrderApi__Store__c str : records) {
            str.OrderApi__Enable_Guest_Save_Payment__c = false;
        }

        Framework.Log.pop();
    }

}