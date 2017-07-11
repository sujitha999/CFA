/**
 * This will help in controller execution of the trigger multiple times
 * Every Trigger will have its own static varible to control execution
 * @author Nikilesh Kopparthi
 */
public without sharing class TXWR_TriggerHelper {

    public static boolean runSOLAfterInsert = True;
    public static boolean runSOLBeforeUpdate = True;

}