/**
 *
 * Controller class for the society onboarding automation page for CFAI
 * @author Nikilesh Kopparthi
 *
 **/

public class SocietyOnboardingController {

    /* comment on 29 Dec -2015
    public string societyName     {get; set;}
    public string currencyCode    {get; set;}
    public string cfaId           {get; set;}
    public string socId           {get; set;}
    public string socUrl          {get; set;}
    public string socEmail        {get; set;}
    public string socPhone        {get; set;}
    public string socAddr         {get; set;}
    public string glDescrp        {get; set;}
    public string glRepCat        {get; set;}
    public string glType          {get; set;}
    public string glDetail        {get; set;}
    public id glSocOnb            {get; set;}
    */
    
    /* comment on 29 Dec -2015
    public Society_Onboarding__c socOnb                     {get; set;}
    public Onboarding_GL_Accounts__c glAcc                  {get; set;}
    public Onboarding_Payment_Terms__c payTerm              {get; set;}
    */
    
    public boolean displayPopup   {get; set;}
    public list<Onboarding_GL_Accounts__c> listglAcc        {get; set;}
    public List<Onboarding_Payment_Terms__c> lstPaymentTerm {get; set;}
    
    private string socOnbId = '';
    
    public list<Onboarding_GL_Accounts__c> lstglAcc {get; set;}
    public Society_Onboarding__c socOnb_obj         {get; set;}
    
    public SocietyOnboardingController(ApexPages.StandardController Controller) {
    
    socOnb_obj = (Society_Onboarding__c)Controller.getRecord();   //code to retrieve record
        system.debug('\n--socOnb_obj--'+socOnb_obj);
        if(socOnb_obj.id != null || socOnb_obj.id =='')
        {
            List<Society_Onboarding__c> tempRec = [SELECT Id,
                             Name,
                             CurrencyIsoCode,
                             CFA_Org_ID__c,
                             CFA_Society_Id__c,
                             Email__c,
                             Mailing_Addess__c,
                             Phone__c,
                             Society_Homepage_URL__c,
                             Canadian_Society__c
                      FROM Society_Onboarding__c
                      WHERE Id = :socOnb_obj.id];
              if(!tempRec.isEmpty())
              {
                  socOnb_obj = tempRec[0];
              }
              else
              {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'This record is invalid or has already been submitted');
                    ApexPages.addMessage(msg);
              }
        }
        
        lstPaymentTerm = new List<Onboarding_Payment_Terms__c>();  //code to retrieve child records
        lstglAcc = new list<Onboarding_GL_Accounts__c>();
        if(socOnb_obj.id != null || socOnb_obj.id =='')
        {
            lstglAcc = [SELECT Id,
                             Name,
                             Report_Category__c,
                             Detail__c,
                             Type__c,
                             Society_Onboarding__c
                             FROM Onboarding_GL_Accounts__c
                             WHERE Society_Onboarding__c = :socOnb_obj.id];
                   
            if(lstglAcc.isEmpty()) {            // code to add dummy line incase no child record is present
                Onboarding_GL_Accounts__c glAcc = new Onboarding_GL_Accounts__c(Society_Onboarding__c = socOnb_obj.id);
                lstglAcc.add(glAcc);
            }
            
            if(lstPaymentTerm.isEmpty()) {        // code to add dummy line incase no child record is present
                Onboarding_Payment_Terms__c payTerm = new Onboarding_Payment_Terms__c(Society_Onboarding__c = socOnb_obj.id);
                lstPaymentTerm.add(payTerm);
            }
            
            lstPaymentTerm = [SELECT Society_Onboarding__c,
                                     Name,
                                     Payment_Term_Name__c,
                                     Payment_Period__c,
                                     Display_Name__c,
                                     Display_Message__c,
                                     Variable__c 
                                     FROM Onboarding_Payment_Terms__c 
                                     WHERE Society_Onboarding__c = :socOnb_obj.id];
            
        }
    
    }
    
    public pageReference saveOnly() {
            system.debug('\n--lstglAcc--'+lstglAcc);        
            saveTemp();           
            return returnToOrigination();                                                       // code for returning to Object detail Page
    }
    
    private void saveTemp() {
    upsert socOnb_obj;                                                                          // update parent Object  
        List<Onboarding_GL_Accounts__c> TempglAcc = new List<Onboarding_GL_Accounts__c>();
        for(Onboarding_GL_Accounts__c temp : lstglAcc){                                         // upsert GL Accounts
            // condition to check if none of the value is added
            if(string.isBlank(Temp.Name) && (Temp.Detail__c == null) && (Temp.Report_Category__c == null) && (Temp.Type__c == null))
            {
                // do not do anything
            }
            else if(temp.Society_Onboarding__c == null){
                temp.Society_Onboarding__c = socOnb_obj.id;
                TempglAcc.add(temp);
            }
            else
            {
                TempglAcc.add(temp);
            }
        }
        system.debug('\n--lstglAcc--'+lstglAcc+'\n--TempglAcc--'+TempglAcc);
        upsert TempglAcc;
        
        List<Onboarding_Payment_Terms__c> TempPayment = new List<Onboarding_Payment_Terms__c>();
        for(Onboarding_Payment_Terms__c temp : lstPaymentTerm) {     // upsert Payment Terms    
            if(string.isBlank(Temp.Name) && string.isBlank(Temp.Display_Message__c) && string.isBlank(Temp.Display_Name__c) && (Temp.Variable__c == null))
            {
                // don't do any thing
            }
            else if(temp.Society_Onboarding__c == null) {
                temp.Society_Onboarding__c = socOnb_obj.id;
                TempPayment.add(temp);
            }
            else
            {
                TempPayment.add(temp);
            }
        } 
        upsert TempPayment;
    }
    
    public PageReference SaveRec() {
    
    displayPopup = false;
    
    if(socOnb_obj.Name == NULL || socOnb_obj.Name == '') {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Society Name is not defined'));
        return null;
    } else if(socOnb_obj.CurrencyIsoCode == NULL || socOnb_obj.CurrencyIsoCode == '') {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Society Currency is not defined'));
        return null;
    } else if(socOnb_obj.CFA_Org_ID__c == NULL || socOnb_obj.CFA_Org_ID__c == '') {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'CFA Org ID is not defined'));
        return null;
    } else if(socOnb_obj.CFA_Society_Id__c == NULL || socOnb_obj.CFA_Society_Id__c == '') {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'CFA Society ID is not defined'));
        return null;
    } else if(socOnb_obj.Society_Homepage_URL__c == NULL || socOnb_obj.Society_Homepage_URL__c == '') {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Society Homepage URL is not defined'));
        return null;
    } else if(socOnb_obj.Email__c == NULL || socOnb_obj.Email__c == '') {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Society Email is not defined'));
        return null;
    } else if(socOnb_obj.Phone__c == NULL || socOnb_obj.Phone__c == '') {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Society Phone is not defined'));
        return null;
    } else if(socOnb_obj.Mailing_Addess__c == NULL || socOnb_obj.Mailing_Addess__c == '') {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Society Mailing Address is not defined'));
        return null;
    } else {
        
        saveTemp();
        
        /************ Step 2 *********************/
        /* code for creating group and searching group*/
        Group GroupObj = new Group();
        List<Group> lstgrp = [select id from group where name =: socOnb_obj.Name limit 1];
        system.debug('\n--lstgrp--'+lstgrp);
        if(!lstgrp.isEmpty()) {
            GroupObj = lstgrp[0];
        }else {
            GroupObj.Name = socOnb_obj.Name; 
            GroupObj.DoesIncludeBosses = false;       
            insert GroupObj;
        }
        system.debug('\n--GroupObj--'+GroupObj);
        /************ Step 2 Ends *********************/
        
        /************ Step 4  *********************/
        /*code to share Fonteva Default Contact*/
        ContactShare sharecon = new ContactShare();
        sharecon.ContactAccessLevel = 'Edit';     
        Soc_Onb__c custSet = Soc_Onb__c.getInstance('Default Contact Id');
        String custSetInst = custSet.Value__c;
        sharecon.ContactID = custSetInst;
        sharecon.RowCause = Schema.ContactShare.RowCause.Manual;
        sharecon.UserOrGroupId = GroupObj.id;
        insert sharecon;
        system.debug('\n--sharecon--'+sharecon);
        /************ Step 4 Ends *********************/
        
        /************ Step 5  *********************/
        /*creaing Business group*/
        OrderApi__Business_Group__c BusinessGroup = new OrderApi__Business_Group__c();
        BusinessGroup.Name = socOnb_obj.Name;
        BusinessGroup.OrderApi__Homepage_URL__c = socOnb_obj.Society_Homepage_URL__c;
        BusinessGroup.OrderApi__Phone__c = socOnb_obj.Phone__c;
        BusinessGroup.OrderApi__Email__c = socOnb_obj.Email__c;
        BusinessGroup.OrderApi__Mailing_Address__c = socOnb_obj.Mailing_Addess__c;
        BusinessGroup.OrderApi__Is_Master__c = true;
        BusinessGroup.SystemPublicGroupId__c = GroupObj.id;
        BusinessGroup.CurrencyIsoCode = socOnb_obj.CurrencyIsoCode;     
        insert BusinessGroup;
        system.debug('\n--BusinessGroup--'+BusinessGroup);
        /************ Step 5  Ends*********************/
        
        /************ Step 6 *********************/
        /**/
        List<OrderApi__GL_Account__c> lstInsertAccount = new List<OrderApi__GL_Account__c>();
        system.debug('\n--lstglAcc--'+lstglAcc);
        for(Onboarding_GL_Accounts__c obj : lstglAcc) {
            if(obj.Name != NULL){                                                 //Added on 04/05/16
            OrderApi__GL_Account__c temp = new OrderApi__GL_Account__c();
            temp.Name = obj.Name;
            temp.OrderApi__Detail__c = obj.Detail__c;
            temp.OrderApi__Report_Category__c = obj.Report_Category__c;
            temp.OrderApi__Type__c = obj.Type__c;
            temp.OrderApi__Business_Group__c = BusinessGroup.id;
            lstInsertAccount.add(temp);
            }
        }
        if(!lstInsertAccount.isEmpty()) {
            insert lstInsertAccount;
        }
        system.debug('\n--lstInsertAccount--'+lstInsertAccount);
        /************ Step 6  Ends*********************/
        
        /************ Step 7  *********************/
        /**/
        List<OrderApi__Payment_Terms__c> lstPaymentTerms = new List<OrderApi__Payment_Terms__c>();
        system.debug('\n--lstPaymentTerm--'+lstPaymentTerm);
        for(Onboarding_Payment_Terms__c obj : lstPaymentTerm) {
            if(obj.Name != NULL) {                                                //Added on 04/05/16
            OrderApi__Payment_Terms__c temp = new OrderApi__Payment_Terms__c();
            temp.Name = obj.Name;
            temp.OrderApi__Business_Group__c = BusinessGroup.id;
            temp.CurrencyIsoCode = socOnb_obj.CurrencyIsoCode;
            temp.OrderApi__Display_Name__c = obj.Display_Name__c;
            temp.OrderApi__Display_Message__c = obj.Display_Message__c;
            temp.OrderApi__Variable__c = obj.Variable__c;
            lstPaymentTerms.add(temp);
            }
        }
        if(!lstPaymentTerms.isEmpty()) {
            insert lstPaymentTerms;
        }     
        /************ Step 7  Ends*********************/
        
        /************ Step 8  *********************/
        /*share BusinessGroup with Public Group. Childs will also be shared as they are master-detail related*/
        OrderApi__Business_Group__Share BGShare = new OrderApi__Business_Group__Share();
        BGShare.AccessLevel = 'Read';
        Soc_Onb__c custSet7 = Soc_Onb__c.getInstance('Default Business Group Id');
        String custSetInst7 = custSet7.Value__c;
        BGShare.ParentId = custSetInst7;
        BGShare.UserOrGroupId = GroupObj.id;
        BGShare.RowCause=Schema.ContactShare.RowCause.Manual;
        insert BGShare;
        system.debug('\n--BGShare--'+BGShare);
        /************ Step 8  Ends*********************/
        
        /************ Step 9  *********************/
        /*code to share Fonteva Default Account*/
        AccountShare shareAccount = new AccountShare();
        shareAccount.AccountAccessLevel = 'Read';
        Soc_Onb__c custSet2 = Soc_Onb__c.getInstance('Default Account Id');
        String custSetInst2 = custSet2.Value__c;
        shareAccount.AccountID = custSetInst2;
        shareAccount.RowCause = Schema.AccountShare.RowCause.Manual;
        shareAccount.UserOrGroupId = GroupObj.id;
        shareAccount.ContactAccessLevel = 'None';
        shareAccount.OpportunityAccessLevel = 'None';
        insert shareAccount;
        system.debug('\n--shareAccount--'+shareAccount);
        /************ Step 9  Ends*****************/
        
        /************ Step 10  *********************/
        /*Ask CFA*/
        /************ Step 10  Ends*********************/
        
        /************* step 11 *************************/
        /*code to cerate 3 OrderApi__Badge_Type record*/
        List<OrderApi__Badge_Type__c> lstBadgeType = new List<OrderApi__Badge_Type__c>();
        for(integer i=0; i<6;i++) {
            OrderApi__Badge_Type__c BadgeType = new OrderApi__Badge_Type__c (); 
            if(i == 0) {
                BadgeType.Name = System.Label.Society_Onboarding_Badge_Name_Public+' - '+socOnb_obj.Name;
                BadgeType.TypeId__c = 'Public';
                Soc_Onb__c custSet9 = Soc_Onb__c.getInstance('Connected User Id');
                String custSetInst9 = custSet9.Value__c;
                BadgeType.OwnerId = custSetInst9;

                if(socOnb_obj.CFA_Society_Id__c.length() > 10) {
                    BadgeType.SocietyId__c = socOnb_obj.CFA_Society_Id__c.substring(0, 9);
                } else {
                    BadgeType.SocietyId__c = socOnb_obj.CFA_Society_Id__c;
                }

                if(socOnb_obj.CFA_Org_ID__c.length() > 10) {
                    BadgeType.OrgId__c = socOnb_obj.CFA_Org_ID__c.substring(0, 9);
                } else {
                    BadgeType.OrgId__c = socOnb_obj.CFA_Org_ID__c;
                }

                BadgeType.OrderApi__Is_Active__c = true;
                BadgeType.OrderApi__Is_Published__c = true;
                BadgeType.BusinessGroup__c = BusinessGroup.id;
                lstBadgeType.add(BadgeType);
            } else if(i == 1) {
                BadgeType.Name = System.Label.Society_Onboarding_Badge_Name_Candidate+' - '+socOnb_obj.Name;
                BadgeType.TypeId__c = 'Candidate';
                Soc_Onb__c custSet10 = Soc_Onb__c.getInstance('Connected User Id');
                String custSetInst10 = custSet10.Value__c;
                BadgeType.OwnerId = custSetInst10;

                if(socOnb_obj.CFA_Society_Id__c.length() > 10) {
                    BadgeType.SocietyId__c = socOnb_obj.CFA_Society_Id__c.substring(0, 9);
                } else {
                    BadgeType.SocietyId__c = socOnb_obj.CFA_Society_Id__c;
                }

                if(socOnb_obj.CFA_Org_ID__c.length() > 10) {
                    BadgeType.OrgId__c = socOnb_obj.CFA_Org_ID__c.substring(0, 9);
                } else {
                    BadgeType.OrgId__c = socOnb_obj.CFA_Org_ID__c;
                }

                BadgeType.OrderApi__Is_Active__c = true;
                BadgeType.OrderApi__Is_Published__c = true;
                BadgeType.BusinessGroup__c = BusinessGroup.id;
                lstBadgeType.add(BadgeType);
            } else if(i == 2){
                BadgeType.Name = System.Label.Society_Onboarding_Badge_Name_Member+' - '+socOnb_obj.Name;
                BadgeType.TypeId__c = 'Member';
                Soc_Onb__c custSet11 = Soc_Onb__c.getInstance('Connected User Id');
                String custSetInst11 = custSet11.Value__c;
                BadgeType.OwnerId = custSetInst11;

                if(socOnb_obj.CFA_Society_Id__c.length() > 10) {
                    BadgeType.SocietyId__c = socOnb_obj.CFA_Society_Id__c.substring(0, 9);
                } else {
                    BadgeType.SocietyId__c = socOnb_obj.CFA_Society_Id__c;
                }

                if(socOnb_obj.CFA_Org_ID__c.length() > 10) {
                    BadgeType.OrgId__c = socOnb_obj.CFA_Org_ID__c.substring(0, 9);
                } else {
                    BadgeType.OrgId__c = socOnb_obj.CFA_Org_ID__c;
                }

                BadgeType.OrderApi__Is_Active__c = true;
                BadgeType.OrderApi__Is_Published__c = true;
                BadgeType.BusinessGroup__c = BusinessGroup.id;
                lstBadgeType.add(BadgeType);
            } else if(i==3){
                BadgeType.Name = System.Label.Society_Onboarding_Badge_Name_Local+' - '+socOnb_obj.Name;
                BadgeType.TypeId__c = 'Local';
                Soc_Onb__c custSet12 = Soc_Onb__c.getInstance('Connected User Id');
                String custSetInst12 = custSet12.Value__c;
                BadgeType.OwnerId = custSetInst12;

                if(socOnb_obj.CFA_Society_Id__c.length() > 10) {
                    BadgeType.SocietyId__c = socOnb_obj.CFA_Society_Id__c.substring(0, 9);
                } else {
                    BadgeType.SocietyId__c = socOnb_obj.CFA_Society_Id__c;
                }

                if(socOnb_obj.CFA_Org_ID__c.length() > 10) {
                    BadgeType.OrgId__c = socOnb_obj.CFA_Org_ID__c.substring(0, 9);
                } else {
                    BadgeType.OrgId__c = socOnb_obj.CFA_Org_ID__c;
                }

                BadgeType.OrderApi__Is_Active__c = true;
                BadgeType.OrderApi__Is_Published__c = true;
                BadgeType.BusinessGroup__c = BusinessGroup.id;
                lstBadgeType.add(BadgeType);
            } else if(i==4 && socOnb_obj.Canadian_Society__c == TRUE){
                BadgeType.Name = System.Label.Society_Onboarding_Badge_Name_CASL1+' '+socOnb_obj.Name;
                BadgeType.TypeId__c = 'CASLImp';
                BadgeType.OrderApi__Short_Description__c = 'This badge identifies the most recent posting date of the contact’s last purchase.';
                Soc_Onb__c custSet13 = Soc_Onb__c.getInstance('Connected User Id');
                String custSetInst13 = custSet13.Value__c;
                BadgeType.OwnerId = custSetInst13;

                if(socOnb_obj.CFA_Society_Id__c.length() > 10) {
                    BadgeType.SocietyId__c = socOnb_obj.CFA_Society_Id__c.substring(0, 9);
                } else {
                    BadgeType.SocietyId__c = socOnb_obj.CFA_Society_Id__c;
                }

                if(socOnb_obj.CFA_Org_ID__c.length() > 10) {
                    BadgeType.OrgId__c = socOnb_obj.CFA_Org_ID__c.substring(0, 9);
                } else {
                    BadgeType.OrgId__c = socOnb_obj.CFA_Org_ID__c;
                }

                BadgeType.OrderApi__Is_Active__c = true;
                BadgeType.OrderApi__Is_Published__c = false;
                BadgeType.BusinessGroup__c = BusinessGroup.id;
                lstBadgeType.add(BadgeType);
            } else if(i==5 && socOnb_obj.Canadian_Society__c == TRUE) {
                BadgeType.Name = System.Label.Society_Onboarding_Badge_Name_CASL2+' '+socOnb_obj.Name;
                BadgeType.TypeId__c = 'CASLExp';
                BadgeType.OrderApi__Short_Description__c = 'This badge identifies the most recent interaction that this Society has had with the contact where expressed consent was given.';
                Soc_Onb__c custSet14 = Soc_Onb__c.getInstance('Connected User Id');
                String custSetInst14 = custSet14.Value__c;
                BadgeType.OwnerId = custSetInst14;

                if(socOnb_obj.CFA_Society_Id__c.length() > 10) {
                    BadgeType.SocietyId__c = socOnb_obj.CFA_Society_Id__c.substring(0, 9);
                } else {
                    BadgeType.SocietyId__c = socOnb_obj.CFA_Society_Id__c;
                }

                if(socOnb_obj.CFA_Org_ID__c.length() > 10) {
                    BadgeType.OrgId__c = socOnb_obj.CFA_Org_ID__c.substring(0, 9);
                } else {
                    BadgeType.OrgId__c = socOnb_obj.CFA_Org_ID__c;
                }

                BadgeType.OrderApi__Is_Active__c = true;
                BadgeType.OrderApi__Is_Published__c = false;
                BadgeType.BusinessGroup__c = BusinessGroup.id;
                lstBadgeType.add(BadgeType);
            }

            /**
            if(socOnb_obj.CFA_Society_Id__c.length() > 10) {
                BadgeType.SocietyId__c = socOnb_obj.CFA_Society_Id__c.substring(0, 9);
            } else {
                BadgeType.SocietyId__c = socOnb_obj.CFA_Society_Id__c;
            }
            
            if(socOnb_obj.CFA_Org_ID__c.length() > 10) {
                BadgeType.OrgId__c = socOnb_obj.CFA_Org_ID__c.substring(0, 9);
            } else {
                BadgeType.OrgId__c = socOnb_obj.CFA_Org_ID__c;    
            }
            
            BadgeType.OrderApi__Is_Active__c = true;
            BadgeType.OrderApi__Is_Published__c = true;
            BadgeType.BusinessGroup__c = BusinessGroup.id;
            lstBadgeType.add(BadgeType);
            **/
        }
        insert lstBadgeType;
        system.debug('\n--lstBadgeType--'+lstBadgeType);
        
        /*
        List<OrderApi__Badge__c> lstBadge = new List<OrderApi__Badge__c>();
        for(OrderApi__Badge_Type__c temp : lstBadgeType) {
            OrderApi__Badge__c objBadge = new OrderApi__Badge__c();
            objBadge.OrderApi__Badge_Type__c = temp.id;
            Soc_Onb__c custSet3 = Soc_Onb__c.getInstance('Connected User Id');
            String custSetInst3 = custSet3.Value__c;
            objBadge.ownerid = custSetInst3;                               
            lstBadge.add(objBadge);
        }
        insert lstBadge;
        system.debug('\n--lstBadge--'+lstBadge);
        */
        /************* step 11 Ends*************************/
        
        /************ steps 12 ****************************/
        PagesApi__Media_Asset_Collection__c MediaCollection = new PagesApi__Media_Asset_Collection__c();
        MediaCollection.Name = socOnb_obj.Name+' ' +System.Label.Society_Onboarding_Media_Collection_Suffix;
        MediaCollection.BusinessGroup__c = BusinessGroup.id;
        MediaCollection.CurrencyIsoCode = socOnb_obj.CurrencyIsoCode;
        insert MediaCollection;
        system.debug('\n--MediaCollection--'+MediaCollection);
        /************ steps 12 Ends ****************************/
        
        myFutureMethod(GroupObj.id,socOnb_obj.Name);
        PageReference logoPage = new PageReference('/apex/'+System.Label.Society_Onboarding_Redirect_Page);
        logoPage.setRedirect(true);
        Soc_Onb__c custSet13 = Soc_Onb__c.getInstance('MediaLookupId');
        String custSetInst13 = custSet13.Value__c;
        logoPage.getParameters().put(custSetInst13, MediaCollection.Name);
        logoPage.getParameters().put(custSetInst13+'_lkid', MediaCollection.id);
        logoPage.getParameters().put('scontrolCaching','1');
        logoPage.getParameters().put('retURL',MediaCOllection.id);
        logoPage.getParameters().put('sfdc.override','1');
        return logoPage;
      }
    }
    
    @future
    public static void myFutureMethod(id GroupObj,string Name){
        
        try
        {
            /************ Step 1  *********************/
            /*create userRole*/
            UserRole role = new UserRole();
            List<UserRole> lstRole = [select id from UserRole where name = :Name AND ParentRoleId = '00E61000000YK11'];
            if(!lstRole.isEmpty()) {
                role = lstRole[0];
            } else {
                role.Name = Name;
                Soc_Onb__c custSet4 = Soc_Onb__c.getInstance('MemberNation Role Id');
                String custSetInst4 = custSet4.Value__c;
                role.ParentRoleId = custSetInst4;
                role.OpportunityAccessForAccountOwner = 'none';
                insert role;
            }
            system.debug('\n--role--'+role);
            /************ Step 1 Ends*********************/
            
            /************ Step 3  *********************/
            /*code to add group members*/
            List<GroupMember> NewGroupMember = new List<GroupMember>();     
            GroupMember gm = new GroupMember();
            
            /* CFA Site Guest User */
            gm.GroupId = GroupObj;
            Soc_Onb__c custSet6 = Soc_Onb__c.getInstance('CFA Site Guest User');
            String custSetInst6 = custSet6.Value__c;
            gm.UserOrGroupId = custSetInst6;
            NewGroupMember.add(gm);
            
            /*CFA Partner Community Site Guest User*/
            gm = new GroupMember();
            gm.GroupId = GroupObj;
            Soc_Onb__c custSet5 = Soc_Onb__c.getInstance('CFA Partner Community Site User Id');
            String custSetInst5 = custSet5.Value__c;
            gm.UserOrGroupId = custSetInst5;        
            NewGroupMember.add(gm);
            
            /*add role to group*/
            List<Group> lstRole_grp = [SELECT id 
                                              FROM group 
                                              WHERE RelatedId = :role.id AND 
                                                    Type = 'Role' LIMIT 1];
            if(!lstRole_grp.isEmpty()) {
                gm = new GroupMember();
                gm.GroupId = GroupObj;
                gm.UserOrGroupId = lstRole_grp[0].id;
                NewGroupMember.add(gm);
            }
            
            /*CFA_Institue_Public_Group*/
            /*List<Group> lstCFA_inst_grp = [SELECT id 
                                                  FROM group 
                                                  WHERE name = 'CFA_Institue_Public_Group' LIMIT 1];
            if(!lstCFA_inst_grp.isEmpty()) {
                gm = new GroupMember();
                gm.GroupId = GroupObj;
                gm.UserOrGroupId = lstCFA_inst_grp[0].id;
                NewGroupMember.add(gm);
            }*/
            
            gm = new GroupMember();
            gm.GroupId = GroupObj;
            Soc_Onb__c custSet8 = Soc_Onb__c.getInstance('CFA Institute Public Group');
            String custSetInst8 = custSet8.Value__c;
            gm.UserOrGroupId = custSetInst8;        
            NewGroupMember.add(gm);
            
            gm = new GroupMember();
            gm.GroupId = GroupObj;
            Soc_Onb__c custSet14 = Soc_Onb__c.getInstance('Generic Public Group');
            String custSetInst14 = custSet14.Value__c;
            gm.UserOrGroupId = custSetInst14;        
            NewGroupMember.add(gm);
            
            system.debug('\n--NewGroupMember--'+NewGroupMember);      
            if(!NewGroupMember.isEmpty()){
                insert NewGroupMember;                                  //add group members
            }
            system.debug('\n-Insert-NewGroupMember--'+NewGroupMember);
            /************ Step 3 Ends *********************/
        }
        
        catch(exception ex)
        {
            
        }
    
    }
    
    public void addAccount() {
        Onboarding_GL_Accounts__c gl = new Onboarding_GL_Accounts__c();
        listglAcc.add(gl);
    }
    
    public void addPayments() { 
        Onboarding_Payment_Terms__c Payment = new Onboarding_Payment_Terms__c();
        lstPaymentTerm.add(Payment);
    }
    
    private pageReference returnToOrigination() {
         pageReference page = new pageReference('/'+socOnb_obj.id);
         page.setRedirect(true);
         return page;
         
     }
     
     public void closePopup() {        
         displayPopup = false;    
     }     
    public void showPopup() {        
         displayPopup = true;    
     } 
}