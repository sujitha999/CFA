/**
 *
 * Test Data Service Class for all Test Classes
 * @author Vishal Shah
 *
 **/

@isTest
public class TestDataFactory {
    
        // Test Data Labels
    public final static String BUSINESSGROUPLABEL = 'Business Group',
        PUBLICGROUPLABEL = 'Groups';

    public static String[] names = new String[]{'Fonteva Society Arlington', 'Fonteva Society Boston'};

    private void printId(String label, Id value) {
        System.debug(label + ': ' + value);    
    }
    
    public static void testInstall() {
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs(thisUser) {
            Framework.Installer.install();
            new PagesApi.PackageScripts.Install().run();
            new OrderApi.PackageScripts.Install().run();
            new EventApi.PackageScripts.Install().run();
            new PackageScripts.Install().run();
        }
    }

    public static void sharingSetup() {
        Group[] groups = createGroups();

        User bostonU = createSocietyAdmin('vshah_test@fonteva.comtest');
        User arlingtonU = createSocietyAdmin('ktorres_test@fonteva.comtest');
        User bostonU2 = createSocietyVolunteer('wgriffith_test@fonteva.comtest');
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs(thisUser) {

            User[] UserList = new User[]{bostonU, arlingtonU, bostonU2};
            insert UserList;

            GroupMember[] GMlist = new GroupMember[]{};
            Set<Id> groupId = new Set<Id> {bostonU.Id, arlingtonU.Id, bostonU2.Id};

            Integer cnt = 0;
            for(Id gId: groupId) {
                GroupMember GM = new GroupMember();
                GM.GroupId = groups[cnt].Id;
                GM.UserOrGroupId = gId;    
                GMList.add(GM);
                cnt ++;
                if(cnt == groups.size()) cnt = 0;
            }

            insert GMList;
        }

        createBusinessGroups(names, groups);
    }

    public static Map<String,SObject[]> buildData() {
        return new Map<String, SObject[]> {'Business Group' => businessGroup(), 'Groups' => group()};
    }

    public static List<OrderApi__Business_Group__c> businessGroup() {
        return [SELECT Id, SystemPublicGroupId__c FROM OrderApi__Business_Group__c WHERE Name = :names ORDER BY Name];
    }

    public static List<Group> group() {
        return [SELECT Id, Name FROM Group WHERE Name = :names ORDER BY NAME];
    }

    public static Group[] createGroups() {
        
        Group[] grps = new Group[]{};

        for(String s: names) {
            grps.add(new Group( Name = s, DeveloperName = s.replace(' ', '_'), Type = 'Regular'));
        }
        
        insert grps;
        
        return grps;
    }

    public static void createBusinessGroups(String[] grpNames, Group[] groups) {
        
        OrderApi__Business_Group__c[] grps = new OrderApi__Business_Group__c[]{};

        Map<String, Id> grpNmId = new Map<String, Id>();
        for(Group grp: groups) {
            grpNmId.put(grp.Name, grp.Id);
        }

        for(String s: grpNames) {
            grps.add(new OrderApi__Business_Group__c(Name = s, SystemPublicGroupId__c = grpNmId.get(s)));
        }
        
        insert grps;
        
    }
    
    public static Account createAccount() {
        Account acc = new account(name = 'individual');
        insert acc;

        return acc;
    }
    
    public static Contact createContact() {
        Account acc = createAccount();
        
        Contact con = new Contact(FirstName = 'Vishal', LastName = 'Shah', AccountId = acc.id);
        insert con;

        return con;
    }


    public static Profile createProfile(String profileName) {
        return [select id, name from Profile where  name = :profileName];
    }

    public static User createSocietyAdmin(String userName) {
        UserRole ur = [SELECT id, name FROM UserRole WHERE name = 'MemberNation'];
        Profile p = createProfile('MemberNation Society Administrator');
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = ur.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName= userName);

        return u;
    }

    public static User createSocietyVolunteer(String userName) {
        UserRole ur = [SELECT id, name FROM UserRole WHERE name = 'MemberNation'];
        Profile p = createProfile('MemberNation Society Volunteer');
        User u = new User(Alias = 'volunt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = ur.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName=userName);

        return u;
    }

    public static void dbInsert(SObject obj, String message) {
        Database.SaveResult sr = Database.insert(obj,false);

        System.debug('>>> sr: ' + sr);

        if(!sr.isSuccess()){
        
            // Get first save result error.
            Database.Error err = sr.getErrors()[0];

            if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
            err.getMessage().contains('AccessLevel'))){
                
                System.assertEquals(message,err.getMessage());
            }
        }
    }

    public static void sharingAssert(SObject[] shareRecord) {
        //sharingAssert(shareRecord, 'AccessLevel');
    }

    public static void sharingAssert(SObject[] shareRecord, String accField) {
        if(shareRecord.size() == 0) {
            System.assert(false, 'No sharing record created');
        } else {
            System.assertEquals('Edit', shareRecord[0].get(accField));
        }
    }
    
}