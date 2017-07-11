global class SparkLogCleanupSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		SparkLogCleanup cleanupSparkLogs = new SparkLogCleanup();
		ID idBatch = Database.executeBatch(cleanupSparkLogs, 200);
	}
}