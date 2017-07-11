/**
 *
 * Service class for PagesApi__Site__c
 * @author Vishal Shah
 *
 **/

public class SiteService {

	public static String className = SiteService.class.getName();

    public static void applyDefaults(PagesApi__Site__c[] records){
        Framework.Log.push(className,'applyDefaults');
            for (PagesApi__Site__c s: records) {
                 s.PagesApi__Login_Redirect_URL__c = s.PagesApi__User_Login_URL__c = s.PagesApi__Site_Url__c + '/' + PackageUtils.NSP + 'MNLogin?site=' + s.Id;
            }
        Framework.Log.pop();
    }

    /**
     * Default logic for SObject.
     *
     * @param oldMap  =>  Map<Id, PagesApi__Site__c> of old record data
     * @param records  =>  List of PagesApi__Site__c.
     */
    public static void setBusinessGroupOnTheme(Map<Id, PagesApi__Site__c> oldMap, PagesApi__Site__c[] records) {
        Framework.Log.push(className,'setBusinessGroupOnTheme');

        Map<Id, Id> themeBgMap = new Map<Id, Id>();
        Map<Id, Id> bgThemeMap = new Map<Id, Id>();

        for(PagesApi__Site__c site: records) {
        	PagesApi__Site__c oldVal = oldMap.get(site.Id);

        	if(site.PagesApi__Theme__c != null && site.OrderApi__Business_Group__c != null 
        		&& (oldVal.PagesApi__Theme__c != site.PagesApi__Theme__c || oldVal.OrderApi__Business_Group__c != site.OrderApi__Business_Group__c)) {
        		themeBgMap.put(site.PagesApi__Theme__c,site.OrderApi__Business_Group__c);
        		bgThemeMap.put(site.OrderApi__Business_Group__c,site.PagesApi__Theme__c);
        	}
        }

        if(themeBgMap.size() > 0) {
        	PagesApi__Theme__c[] themesToUpdate = [SELECT Id, BusinessGroup__c FROM PagesApi__Theme__c WHERE Id in: themeBgMap.keySet()];

        	PagesApi__Theme__c[] updateThemes = new PagesApi__Theme__c[]{};

        	for(PagesApi__Theme__c theme: themesToUpdate) {
        		theme.BusinessGroup__c = themeBgMap.get(theme.Id);
        		updateThemes.add(theme); 
        	}

        	Database.SaveResult[] thmList = Database.update(updateThemes, false);
        	for(Database.SaveResult sr: thmList) {
        		if(!sr.isSuccess()) {
        			for(Database.Error err : sr.getErrors()) {
			            System.debug('The following error has occurred.');                   
			            System.debug(err.getStatusCode() + ': ' + err.getMessage());
			            System.debug('Theme fields that affected this error: ' + err.getFields());
			        }
        		}
        	}

        } 

        if(bgThemeMap.size() > 0) {
        	OrderApi__Business_Group__c[] bgsToUpdate = [SELECT Id, OrderApi__Theme__c FROM OrderApi__Business_Group__c WHERE Id in: bgThemeMap.keySet()];

        	OrderApi__Business_Group__c[] updateBgs = new OrderApi__Business_Group__c[]{};

        	for(OrderApi__Business_Group__c bg: bgsToUpdate) {
        		bg.OrderApi__Theme__c = bgThemeMap.get(bg.Id);
        		updateBgs.add(bg); 
        	}

        	Database.SaveResult[] thmList = Database.update(updateBgs, false);
        	for(Database.SaveResult sr: thmList) {
        		if(!sr.isSuccess()) {
        			for(Database.Error err : sr.getErrors()) {
			            System.debug('The following error has occurred.');                   
			            System.debug(err.getStatusCode() + ': ' + err.getMessage());
			            System.debug('Business Group fields that affected this error: ' + err.getFields());
			        }
        		}
        	}

        }

        Framework.Log.pop();
    }

}