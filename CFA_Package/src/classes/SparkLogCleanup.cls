/**
 *
 * Class for deleting Spark System Logs
 * @author Vishal Shah
 *
 **/

global class SparkLogCleanup implements Database.Batchable<sObject> {
	
	String query;
	
	global SparkLogCleanup() {
		query = 'SELECT Id FROM Framework__System_Log__c WHERE CreatedDate < LAST_MONTH';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		Database.DeleteResult[] drList = Database.delete(scope, false);
	}
	
	global void finish(Database.BatchableContext BC) {
		AsyncApexJob aaJob = [SELECT NumberOfErrors, TotalJobItems FROM AsyncApexJob WHERE Id = :BC.getJobId()];
		if(aaJob.NumberOfErrors > 0) {
			/*Messaging.SingleEmailMessage semResult = new Messaging.SingleEmailMessage();
			semResult.setToAddresses(new String[] {strResultEmail};
			semResult.setSubject('Error in Scheduled APEX');
			semResult.setPlainTextBody('Processed ' + aaJob.TotalJobItems + ' batches with ' + aaJob.NumberOfErrors + ' failures.');
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
		}
	}
	
}