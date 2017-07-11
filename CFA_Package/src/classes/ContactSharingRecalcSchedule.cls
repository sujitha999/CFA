global class ContactSharingRecalcSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		ContactSharingRecalc contactRecalc = new ContactSharingRecalc();
		ID idBatch = Database.executeBatch(contactRecalc, 200);
	}
}