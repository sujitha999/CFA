/**
 *
 * Service class for OrderApi__Badge__c
 * @author Vishal Shah
 *
 **/

public without sharing class BadgeService {
	
	public static String className = BadgeService.class.getName();

	/**
	 * Identify records for which User access has to be deleted
	 * @param records => OrderApi__Badge__c[]
	 */
	public static OrderApi__Badge__c[] processRecordsToDelete(OrderApi__Badge__c[] records) {
		Framework.Log.push(className,'processRecordsToDelete');

		Set<Id> contacts = new Set<Id>();
		String[] busgrps = new String[]{};

		for(OrderApi__Badge__c bdg : records) {
			contacts.add(bdg.OrderApi__Contact__c);
			busgrps.add(bdg.BusinessGroup__c);
		}

		Map<Id, OrderApi__Badge__c> flaggedBadges = new Map<Id, OrderApi__Badge__c>(records);
		for(OrderApi__Badge__c existingBdg : [SELECT OrderApi__Contact__c, BusinessGroup__c FROM OrderApi__Badge__c WHERE OrderApi__Contact__c IN :contacts AND BusinessGroup__c IN :busgrps AND IsDeleted = FALSE]) {
			Id keyToRemove;
			for(OrderApi__Badge__c deletedBdg : flaggedBadges.values()) {
				if(deletedBdg.OrderApi__Contact__c == existingBdg.OrderApi__Contact__c && deletedBdg.BusinessGroup__c == existingBdg.BusinessGroup__c) {
					keyToRemove = deletedBdg.Id;
					break;
				}
			}
			flaggedBadges.remove(keyToRemove);
		}

		Framework.Log.pop();
		return flaggedBadges.values();
	}
}