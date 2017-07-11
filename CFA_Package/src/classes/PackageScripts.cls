global class PackageScripts implements InstallHandler, UninstallHandler {
    
    /**
     * Required for UninstallHandler interface implementation
     * ID organizationId();
     * ID uninstallerId();
     * @param  {InstallContext} context Object providing methods to retrieve
     *                                  organization Id and uninstalling user Id.
     */
    global void onInstall(InstallContext context) {
        PackageScripts.install();
        String eventDescriptor = context.isPush() ? 'Push' : '';
        eventDescriptor += ' ';
        eventDescriptor += context.isUpgrade() ? 'Upgrade' : 'Install';
        String jsonData = '[{'+
            '"organization_id": "' + context.organizationId() + '",'+
            '"user_id": "' + context.installerId() + '",'+
            '"package":"'+ PackageUtils.NAMESPACE +'",'+
            '"major_version_number":' + String.valueOf(System.requestVersion().major()) + ','+
            '"minor_version_number":' + String.valueOf(System.requestVersion().minor()) + ','+
            '"patch_version_number":' + String.valueOf(System.requestVersion().patch()) + ','+
            '"event":"' + eventDescriptor + '"';
        if (!context.isPush()) {
            try {
                jsonData += ','; // adding comma to add more json fields
                // need to make sure we only do this on manual installs and upgrades
                // otherwise system query exception thrown (push upgrades spec.)
                User u = [Select Id, Username, FirstName, LastName, Title,
                    CompanyName, Phone, Email, Street, City, State,
                    PostalCode, Country from User where Id =: context.installerId()];
                jsonData += '"user_id": "' + context.installerId() + '",'+
                    '"username": "' + u.Username + '",'+
                    '"first_name": "' + u.Phone + '",'+
                    '"last_name": "' + u.LastName + '",'+
                    '"phone": "' + u.Phone + '",'+
                    '"email": "' + u.Email + '",'+
                    '"company": "' + u.CompanyName +'",'+
                    '"title": "' + u.Title + '"';
            } catch (QueryException qx) { /* Can't do DML :( */  }
        }
        jsonData += '}]';
        String[] toAddresses = new String[]{UserInfo.getUserEmail()};
        try {
            Messaging.SingleEmailMessage mail =
            new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setReplyTo('noreply@fonteva.com');
            mail.setSenderDisplayName('FONTEVA ' + PackageUtils.NAMESPACE);
            mail.setSubject(PackageUtils.NAMESPACE + 'PACKAGE CFAMN SERVICE');
            mail.setPlainTextBody(jsonData);
            Messaging.sendEmail(new Messaging.Email[] { mail });
        } catch (Exception ex) {
            Framework__System_Log__c log = new Framework__System_Log__c();
            log.Framework__Exception_Data__c = 'Exception Type: ' + ex.getTypeName() + '\nCaused By: ' + ex.getCause();
            log.Framework__Data__c = jsonData + '\n\n' + 'EXCEPTION: ' + ex.getMessage();
            log.Framework__Type__c = eventDescriptor.toUpperCase();
            insert log;
        }
    }

    /**
     * Required for UninstallHandler interface implementation
     * ID organizationId();
     * ID uninstallerId();
     * @param  {UninstallContext} context Object providing methods to retrieve
     *                                    organization Id and uninstalling user Id.
     */
    global void onUninstall(UninstallContext context) {
        User u = [Select Id, Username, FirstName, LastName, Title,
                    CompanyName, Phone, Email, Street, City, State,
                    PostalCode, Country from User where Id =: context.uninstallerId()];

        String eventDescriptor = 'Uninstall';
        String jsonData = '[{' +
           '"organization_id": "' + context.organizationId() + '",' +
           '"user_id": "' + context.uninstallerId() + '",' +
           '"username": "' + u.Username + '",' +
           '"first_name": "' + u.Phone + '",' +
           '"last_name": "' + u.LastName + '",' +
           '"phone": "' + u.Phone + '",' +
           '"email": "' + u.Email + '",' +
           '"company": "' + u.CompanyName +'",' +
           '"title": "' + u.Title + '",' +
           '"package": "' + PackageUtils.NAMESPACE + '",' +
           '"event": "' + eventDescriptor + '"' +
        '}]';

        String[] toAddresses = new String[]{UserInfo.getUserEmail()};
        Messaging.SingleEmailMessage mail =
            new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('noreply@fonteva.com');
        mail.setSenderDisplayName('FONTEVA ' + PackageUtils.NAMESPACE);
        mail.setSubject(PackageUtils.NAMESPACE + 'PACKAGE EVENT SERVICE');
        mail.setPlainTextBody(jsonData);
        Messaging.sendEmail(new Messaging.Email[] { mail });
    }

    /**
     * Execute the installation scripts for the EventApi managed package
     */
    global static void install() {
        new PackageScripts.Install().run();
    }

    global class Register implements Framework.Scriptable {
        global void run() {

            Framework.RegisteredApp CFAMNApp = new Framework.RegisteredApp();
            CFAMNApp.apexNamespace = '';
            CFAMNApp.namespace = PackageUtils.NAMESPACE;
            CFAMNApp.installClass = PackageScripts.Install.class.getName();
            CFAMNApp.isManaged = false;
            CFAMNApp.isEnabled = true;
            CFAMNApp.isPaid = false;
            CFAMNApp.developerEmail = 'implementations@fonteva.com';
            CFAMNApp.owner = PackageUtils.NAMESPACE;
            CFAMNApp.description = 'Customizations built by Fonteva to support the implementation of MemberNation for CFA.';
            CFAMNApp.Name = PackageUtils.NAMESPACE + ' Customizations';
            Framework.Config.push(CFAMNApp);


            // Routing Rules --- Alphabetically ---
            Framework.RoutingRule[] rules = new Framework.RoutingRule[]
            {
                // Contact
                createRule(
                    Contact_Trigger.class.getName(),
                    SObjectType.Contact.getName()
                ),

                // DonorApi__Gift_In_Kind__c
                createRule(
                    GiftInKind_Trigger.class.getName(),
                    SObjectType.DonorApi__Gift_In_Kind__c.getName()
                ),

                // EventApi__Attendee__c
                createRule(
                    Attendee_Trigger.class.getName(),
                    SObjectType.EventApi__Attendee__c.getName()
                ),

                // EventApi__Event__c
                createRule(
                    Event_Trigger.class.getName(),
                    SObjectType.EventApi__Event__c.getName()
                ),

                // EventApi__Event_Category__c
                createRule(
                    EventCategory_Trigger.class.getName(),
                    SObjectType.EventApi__Event_Category__c.getName()
                ),

                // EventApi__Schedule_Item__c
                createRule(
                    ScheduleItem_Trigger.class.getName(),
                    SObjectType.EventApi__Schedule_Item__c.getName()
                ), 

                // EventApi__Sponsor_Package__c
                createRule(
                    SponsorPackage_Trigger.class.getName(),
                    SObjectType.EventApi__Sponsor_Package__c.getName()
                ),

                // EventApi__Registration_Group__c
                createRule(
                    RegistrationGroup_Trigger.class.getName(),
                    SObjectType.EventApi__Registration_Group__c.getName()
                ),

                // EventApi__Speaker__c
                createRule(
                    Speaker_Trigger.class.getName(),
                    SObjectType.EventApi__Speaker__c.getName()
                ),
                
                // EventApi__Sponsor__c
                createRule(
                    Sponsor_Trigger.class.getName(),
                    SObjectType.EventApi__Sponsor__c.getName()
                ),

                // EventApi__Vendor__c
                createRule(
                    Vendor_Trigger.class.getName(),
                    SObjectType.EventApi__Vendor__c.getName()
                ),

                // EventApi__Venue__c
                createRule(
                    Venue_Trigger.class.getName(),
                    SObjectType.EventApi__Venue__c.getName()
                ),

                // EventApi__Ticket_Type__c
                createRule(
                    TicketType_Trigger.class.getName(),
                    SObjectType.EventApi__Ticket_Type__c.getName()
                ),

                // OrderApi__Badge__c
                createRule(
                    Badge_Trigger.class.getName(),
                    SObjectType.OrderApi__Badge__c.getName()
                ),

                // OrderApi__Badge_Type__c
                createRule(
                    BadgeType_Trigger.class.getName(),
                    SObjectType.OrderApi__Badge_Type__c.getName()
                ),

                // OrderApi__Batch__c
                createRule(
                    Batch_Trigger.class.getName(),
                    SObjectType.OrderApi__Batch__c.getName()
                ),                                               
                
                // OrderApi__Business_Group__c
                createRule(
                    BusinessGroup_Trigger.class.getName(),
                    SObjectType.OrderApi__Business_Group__c.getName()
                ),

                // OrderApi__Campaign_Page__c
                createRule(
                    CampaignPage_Trigger.class.getName(),
                    SObjectType.OrderApi__Campaign_Page__c.getName()
                ),

                // OrderApi__Catalog__c
                createRule(
                    Catalog_Trigger.class.getName(),
                    SObjectType.OrderApi__Catalog__c.getName()
                ),

                // OrderApi__EPayment__c            
                createRule(
                    EPayment_Trigger.class.getName(),
                    SObjectType.OrderApi__EPayment__c.getName()
                ),

                // OrderApi__Invoice__c
                createRule(
                    Invoice_Trigger.class.getName(),
                    SObjectType.OrderApi__Invoice__c.getName()
                ),

                // OrderApi__Item__c
                createRule(
                    Item_Trigger.class.getName(),
                    SObjectType.OrderApi__Item__c.getName()
                ),

                // OrderApi__Item_Class__c                            
                createRule(
                    ItemClass_Trigger.class.getName(),
                    SObjectType.OrderApi__Item_Class__c.getName()
                ),

                // OrderApi__Payment_Method__c
                createRule(
                    PaymentMethod_Trigger.class.getName(),
                    SObjectType.OrderApi__Payment_Method__c.getName()
                ),

                // OrderApi__Receipt__c
                createRule(
                    Receipt_Trigger.class.getName(),
                    SObjectType.OrderApi__Receipt__c.getName()
                ),

                // OrderApi__Sales_Order__c
                createRule(
                    SalesOrder_Trigger.class.getName(),
                    SObjectType.OrderApi__Sales_Order__c.getName()
                ),

                // OrderApi__Source_Code__c
                createRule(
                    SourceCode_Trigger.class.getName(),
                    SObjectType.OrderApi__Source_Code__c.getName()
                ),

                // OrderApi__Store__c                        
                createRule(
                    Store_Trigger.class.getName(),
                    SObjectType.OrderApi__Store__c.getName()
                ),

                // OrderApi__Subscription__c
                createRule(
                    Subscription_Trigger.class.getName(),
                    SObjectType.OrderApi__Subscription__c.getName()
                ),

                // OrderApi__Subscription_Plan__c
                createRule(
                    SubscriptionPlan_Trigger.class.getName(),
                    SObjectType.OrderApi__Subscription_Plan__c.getName()
                ),

                // OrderApi__Tax_Locale__c
                createRule(
                    TaxLocale_Trigger.class.getName(),
                    SObjectType.OrderApi__Tax_Locale__c.getName()
                ),

                // OrderApi__Transaction__c
                createRule(
                    Transaction_Trigger.class.getName(),
                    SObjectType.OrderApi__Transaction__c.getName()
                ),

                // PagesApi__Community_Group__c
                createRule(
                    CommunityGroup_Trigger.class.getName(),
                    SObjectType.PagesApi__Community_Group__c.getName()
                ),

                // PagesApi__Form__c
                createRule(
                    Form_Trigger.class.getName(),
                    SObjectType.PagesApi__Form__c.getName()
                ),

                // PagesApi__Media_Asset__c
                createRule(
                    MediaAsset_Trigger.class.getName(),
                    SObjectType.PagesApi__Media_Asset__c.getName()
                ),

                // PagesApi__Media_Asset_Collection__c
                createRule(
                    MediaAssetCollection_Trigger.class.getName(),
                    SObjectType.PagesApi__Media_Asset_Collection__c.getName()
                ),

                // PagesApi__Site__c
                createRule(
                    Site_Trigger.class.getName(),
                    SObjectType.PagesApi__Site__c.getName()
                ),

                // PagesApi__Theme__c
                createRule(
                    Theme_Trigger.class.getName(),
                    SObjectType.PagesApi__Theme__c.getName()
                ),

                // User
                createRule(
                    User_Trigger.class.getName(),
                    SObjectType.User.getName()
                ) 


            };
    	

            // pushing all routing rules
            Framework.Config.push(rules);

        }
    }

    public static Framework.RoutingRule createRule(String className, String objectName){
        return createRule(className, true, objectName, 1);
    }
    
    public static Framework.RoutingRule createRule(String className, Boolean enabled, String objectName, Integer order){
        
        Framework.RoutingRule template = new Framework.RoutingRule();
        template.apexClass = className;
        template.namespace = PackageUtils.NAMESPACE;
        template.isEnabled = enabled;
        template.sObjectName = objectName;
        template.executionOrder = order;

        return template;
    }
    
    global class Install implements Framework.Scriptable {
        public void run() {
            Framework.Log.push(PackageScripts.Install.class.getName(),'run');

            new Register().run();
            
            /*SparkLogCleanupSchedule clsCRON = new SparkLogCleanupSchedule();
            System.Schedule('Spark System Log Nightly Cleanup', '0 0 23 1-31 1-12 ? *', clsCRON);*/

            Framework.Log.pop();
        }
    }
}