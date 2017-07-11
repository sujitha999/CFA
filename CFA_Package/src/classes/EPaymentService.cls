/**
 *
 * Service class for OrderApi__EPayment__c
 * @author Vishal Shah
 *
 **/

public class EPaymentService {
    /**
     * Default logic for SObject.
     *
     * @param records  =>  List of SObjects.
     */
    public static void removeTransactionDetails(OrderApi__EPayment__c[] records) {
        Framework.Log.push(OrderApi__EPayment__c.class.getName(),'removeTransactionDetails');
        
        for(OrderApi__EPayment__c epay : records) {
            epay.OrderApi__Bank_Account_Holder_Type__c = 
                epay.OrderApi__Bank_Account_Number__c =
                epay.OrderApi__Bank_Account_Type__c =
                epay.OrderApi__Bank_Name__c =
                epay.OrderApi__Bank_Routing_Number__c =
                epay.OrderApi__Card_Number__c =
                epay.OrderApi__Card_Type__c =
                epay.OrderApi__CVV_Code__c =
                epay.OrderApi__CVV_Message__c = 
                epay.OrderApi__First_Six_Digits__c = 
                epay.OrderApi__Last_4_Digits__c = 
                epay.OrderApi__Last_Four_Digits__c = 
                epay.OrderApi__Number__c = NULL;
            
            epay.OrderApi__Month__c = epay.OrderApi__Year__c = 0;

                System.debug('>>> epay: ' + epay);
        }

        Framework.Log.pop();
    }

}