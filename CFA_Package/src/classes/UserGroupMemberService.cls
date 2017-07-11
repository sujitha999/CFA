/**
 * Service class for User
 * @author Vishal Shah
 **/

public without sharing class UserGroupMemberService {
	
	/**
	 * Method that adds a user to the group based on the badge 
	 * @param: Set<Id> of OrderApi__Badge__c
	 **/
	@future
	public static void addContactUserToGroupByBadge (Set<Id> recIds) {

		// Map of Contact ID to list of Business Group Id's
		Map<Id, Id[]> conBg = contactToBusinessGroupMap([SELECT BusinessGroup__c, OrderApi__Contact__c FROM OrderApi__Badge__c WHERE Id in : recIds]);

		// Map of Business Group to Public Group Id
		Map<Id, Id> bgGrp = businessPublicGroupMap(conBg.values());
		
		// Map of Contact ID to list of Public Group Id's
		Map<Id, Id[]> conGrps = mapBetweenMaps(conBg, bgGrp);
		
		Set<Id> conIds = conBg.keySet();
		User[] usrs = [SELECT Id, ContactID FROM User WHERE ContactID in :conIds];

		// Map of users to list of Public Group IDs
		Map<Id, Id[]> usrGrps = new Map<Id, Id[]>();
		for(User u : usrs) {
			if(conGrps.containsKey(u.ContactId)) {
				usrGrps.put(u.Id, conGrps.get(u.ContactId));
			}
		}

		createGroupMembers(usrGrps, 'for UserGroupMemberService.addContactUserToGroupByBadge() -> SaveResult');
	}

	/**
	 * Method that adds a user to the group based on create 
	 * @param: User[] records
	 **/
	public static void addUserToGroupOnCreate (User[] records) {

		// Map of contact to user ID
		Map<Id, Id> conUsr = new Map<Id, Id>();
		for(User u : records) {
			if(u.ContactID != null && u.Id != null) {
				conUsr.put(u.ContactID, u.Id);
			}
		}

		if(!conUsr.isEmpty()) {
			addUserToGroupOnCreateService(conUsr);
		}
	}

	/**
	 * Service Method that adds a user to the group based on create 
	 * @param: Map<Id, Id> of contact to user
	 **/
	@future
	public static void addUserToGroupOnCreateService(Map<Id, Id> conUsr) {

		Set<Id> cons = conUsr.keySet();

		// Map of contact to list of Business Group IDs
		Map<Id, Id[]> conBg = contactToBusinessGroupMap([SELECT BusinessGroup__c, OrderApi__Contact__c FROM OrderApi__Badge__c WHERE OrderApi__Contact__c in : cons]);

		if(!conBg.isEmpty()) {

			Map<Id, Id> bgGrp = businessPublicGroupMap(conBg.values());

			Map<Id, Id[]> conGrps = mapBetweenMaps(conBg, bgGrp);

			Map<Id, Id[]> usrGrps = new Map<Id, Id[]>();
			for(Id u : conUsr.keySet()) {
				if(conGrps.containsKey(u)) {
					usrGrps.put(conUsr.get(u), conGrps.get(u));
				}
			}

			createGroupMembers(usrGrps, 'for UserGroupMemberService.addUserToGroupOnCreate() -> SaveResult');
		}

	}

	public static void changeUserToGroupByBadge (Map<Id, OrderApi__Badge__c> oldMap, OrderApi__Badge__c[] records) {

		String[] changedBadges = new String[]{};

		for(OrderApi__Badge__c bdg : records) {
			Id oldCon = oldMap.get(bdg.Id).OrderApi__Contact__c;
			Id newCon = bdg.OrderApi__Contact__c;

			if(newCon != oldCon) {
				changedBadges.add(
					JSON.serialize(
						new HelperClass.Badge(bdg.Id, newCon, oldCon, (Id)bdg.BusinessGroup__c)
					)
				);
			}
		}

		addAndDeleteGroupMembers(changedBadges);
	}

	@future
	private static void addAndDeleteGroupMembers(String[] changedBadges) {
		
		Map<Id, Id[]> addBgCon = new Map<Id, Id[]>();
		Map<Id, Id[]> delBgCon = new Map<Id, Id[]>();
		HelperClass.Badge lclBdg = null;
		for(String strBdg : changedBadges) {
			lclBdg = (HelperClass.Badge) JSON.deserialize(strBdg, HelperClass.Badge.class);

			if(lclBdg.businessGroup != null) {

				if(lclBdg.contact != null ) {
					if(addBgCon.containsKey(lclBdg.businessGroup)) {
						addBgCon.get(lclBdg.businessGroup).add(lclBdg.contact);
					} else {
						addBgCon.put(lclBdg.businessGroup, new Id[] {lclBdg.contact});
					}
				}

				if(lclBdg.oldContact != null) {
					if(delBgCon.containsKey(lclBdg.businessGroup)) {
						delBgCon.get(lclBdg.businessGroup).add(lclBdg.oldContact);
					} else {
						delBgCon.put(lclBdg.businessGroup, new Id[] {lclBdg.oldContact});
					}
				}
			}
		}

		Set<Id> bgrps = new Set<Id>();
		bgrps.addAll(addBgCon.keySet());
		bgrps.addAll(delBgCon.keySet());

		Map<Id, Id> bgGrp = new Map<Id, Id>();
		for(OrderApi__Business_Group__c bg : [Select Id, SystemPublicGroupId__c FROM OrderApi__Business_Group__c WHERE Id in :bgrps]) {
			bgGrp.put(bg.Id, bg.SystemPublicGroupId__c);
		}

		Id[] contacts = new Id[]{};
		List<Id[]> conVals = addBgCon.values();
		conVals.addAll(delBgCon.values());
		for(Id[] cons : conVals){
			contacts.addAll(cons);
		}

		Map<Id, Id> conUsr = new Map<Id, Id>();
		for(User usr : [SELECT Id, ContactID FROM User WHERE ContactID in :contacts]) {
			conUsr.put(usr.ContactID, usr.Id);
		}

		GroupMember[] addGms = new GroupMember[]{};
		//HelperClass.GroupMember[] delGrCon = null;
		Map<String, Id> delGrCon = new Map<String, Id>();
		Id[] delGrpIds = new Id[]{};
		Id[] delUsrIds = new Id[]{};
		for(Id bg : bgGrp.keySet()) {
			Id grpId = bgGrp.get(bg);
			if(addBgCon.containsKey(bg)) {
				for(Id con: addBgCon.get(bg)) {
					addGms.add(new GroupMember(GroupId = grpId, UserOrGroupId = conUsr.get(con)));
				}
			}

			if(delBgCon.containsKey(bg)) {
				for(Id con: delBgCon.get(bg)) {
					Id usrId = conUsr.get(con);
					delGrCon.put((String)grpId + usrId, usrId);
					delGrpIds.add(grpId);
					delUsrIds.add(usrId);
				}
			}
		}

		GroupMember[] delGms = new GroupMember[]{};
		for(GroupMember gm : [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId in : delGrpIds or UserOrGroupId in : delUsrIds]) {
			if(delGrCon.containsKey((String)gm.GroupId + gm.UserOrGroupId)) {
				delGms.add(gm);
			}
		}

		if(addGms.size() > 0) {
			Database.SaveResult[] srList = Database.insert(addGms, false);
			for(Database.SaveResult sr : srList) {
				if(!sr.isSuccess()) {
					Database.Error err = sr.getErrors()[0];
					System.Debug(err.getMessage() + ' for UserGroupMemberService.addAndDeleteGroupMembers() -> SaveResult');
					Framework.Log.debug(err.getMessage() + ' for UserGroupMemberService.addAndDeleteGroupMembers() -> SaveResult');
				}
			}
		}

		if(delGms.size() > 0) {
			Database.DeleteResult[] drList = Database.delete(delGms, false);
			for(Database.DeleteResult dr : drList) {
				if(!dr.isSuccess()) {
					Database.Error err = dr.getErrors()[0];
					System.Debug(err.getMessage() + ' for UserGroupMemberService.addAndDeleteGroupMembers() -> DeleteResult');
					Framework.Log.debug(err.getMessage() + ' for UserGroupMemberService.addAndDeleteGroupMembers() -> DeleteResult');
				}
			}
		}

	}

	public static void delUserFromGroupByBadge (OrderApi__Badge__c[] records) {
		String[] deletedBadges = new String[]{};

		for(OrderApi__Badge__c bdg : records) {
			deletedBadges.add(
					JSON.serialize(
						new HelperClass.Badge(bdg.Id, bdg.OrderApi__Contact__c, null, (Id)bdg.BusinessGroup__c)
					)
				);
		}

		delUserFromGroupByBadgeService(deletedBadges);

	}

	@future
	public static void delUserFromGroupByBadgeService (String[] deletedBadges) {

		Map<Id, Id[]> delBgCon = new Map<Id, Id[]>();
		HelperClass.Badge lclBdg = null;
		for(String strBdg : deletedBadges) {
			lclBdg = (HelperClass.Badge) JSON.deserialize(strBdg, HelperClass.Badge.class);

			if(lclBdg.businessGroup != null) {

				if(lclBdg.contact != null) {
					if(delBgCon.containsKey(lclBdg.businessGroup)) {
						delBgCon.get(lclBdg.businessGroup).add(lclBdg.contact);
					} else {
						delBgCon.put(lclBdg.businessGroup, new Id[] {lclBdg.contact});
					}
				}
			}
		}

		Set<Id> bgrps = delBgCon.keySet();

		Map<Id, Id> bgGrp = new Map<Id, Id>();
		for(OrderApi__Business_Group__c bg : [Select Id, SystemPublicGroupId__c FROM OrderApi__Business_Group__c WHERE Id in :bgrps]) {
			bgGrp.put(bg.Id, bg.SystemPublicGroupId__c);
		}

		Id[] contacts = new Id[]{};
		for(Id[] cons : delBgCon.values()){
			contacts.addAll(cons);
		}

		Map<Id, Id> conUsr = new Map<Id, Id>();
		for(User usr : [SELECT Id, ContactID FROM User WHERE ContactID in :contacts]) {
			conUsr.put(usr.ContactID, usr.Id);
		}

		Map<String, Id> delGrCon = new Map<String, Id>();
		Id[] delGrpIds = new Id[]{};
		Id[] delUsrIds = new Id[]{};
		for(Id bg : bgGrp.keySet()) {
			Id grpId = bgGrp.get(bg);

			if(delBgCon.containsKey(bg)) {
				for(Id con: delBgCon.get(bg)) {
					Id usrId = conUsr.get(con);
					delGrCon.put((String)grpId + usrId, usrId);
					delGrpIds.add(grpId);
					delUsrIds.add(usrId);
				}
			}
		}

		GroupMember[] delGms = new GroupMember[]{};
		for(GroupMember gm : [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId in : delGrpIds or UserOrGroupId in : delUsrIds]) {
			if(delGrCon.containsKey((String)gm.GroupId + gm.UserOrGroupId)) {
				delGms.add(gm);
			}
		}

		if(delGms.size() > 0) {
			Database.DeleteResult[] drList = Database.delete(delGms, false);
			for(Database.DeleteResult dr : drList) {
				if(!dr.isSuccess()) {
					Database.Error err = dr.getErrors()[0];
					System.Debug(err.getMessage() + ' for UserGroupMemberService.addAndDeleteGroupMembers() -> DeleteResult');
					Framework.Log.debug(err.getMessage() + ' for UserGroupMemberService.addAndDeleteGroupMembers() -> DeleteResult');
				}
			}
		}
	}

	public static Map<Id, Id[]> contactToBusinessGroupMap(OrderApi__Badge__c[] badges) {

		Map<Id, Id[]> conBg = new Map<Id, Id[]>();
		for(OrderApi__Badge__c bdg : badges) {
			Id bg = (Id)bdg.BusinessGroup__c,
			  con = bdg.OrderApi__Contact__c;

			if(con != null && bg != null) {
				if(conBg.containsKey(con)) {
					conBg.get(con).add(bg);
				} else {
					conBg.put(con, new Id[] {bg});
				}
			}
		}

		return conBg;
	}

	public static Map<Id,Id> businessPublicGroupMap(List<Id[]> arrOfArrId) {
		Id[] idarray = new Id[]{};
		for(Id[] ids : arrOfArrId) {
			idarray.addall(ids);
		}

		Map<Id, Id> bgGrp = new Map<Id, Id>();
		for(OrderApi__Business_Group__c bg : [Select Id, SystemPublicGroupId__c FROM OrderApi__Business_Group__c WHERE Id in :idarray]) {
			bgGrp.put(bg.Id, bg.SystemPublicGroupId__c);
		}

		return bgGrp;
	}

	public static Map<Id, Id[]> mapBetweenMaps(Map<Id, Id[]> conBg, Map<Id, Id> bgGrp) {
		Map<Id, Id[]> conGrps = new Map<Id, Id[]>();

		for(Id con : conBg.keySet()) {
			Id[] grps = new Id[]{};
			for(Id bg : conBg.get(con)) {
				grps.add(bgGrp.get(bg));	
			}
			conGrps.put(con, grps);
		}

		return conGrps;
	}

	public static void createGroupMembers(Map<Id, Id[]> usrGrps, String msg) {
		GroupMember[] gms = new GroupMember[]{};
		for(Id usr : usrGrps.keySet()) {
			for(Id gr : usrGrps.get(usr)) {
				gms.add(new GroupMember(GroupId = gr, UserOrGroupId = usr));
			}
		}

		if(gms.size() > 0) {
			Database.SaveResult[] srList = Database.insert(gms, false);
			for(Database.SaveResult sr : srList) {
				if(!sr.isSuccess()) {
					Database.Error err = sr.getErrors()[0];
					System.Debug(err.getMessage() + ' ' + msg);
					Framework.Log.debug(err.getMessage() + ' ' + msg);
				}
			}
		}
	}

}