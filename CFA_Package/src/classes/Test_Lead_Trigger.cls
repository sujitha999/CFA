/**
 *
 * Test class for the Lead_Trigger Class
 * @author Nikilesh Kopparthi
 *
 **/

@isTest 
private class Test_Lead_Trigger {
        static Boolean isInstalled = false;
        static OrderApi__Business_Group__c[] businessGroups = new OrderApi__Business_Group__c[]{};
        static Group[] groups = new Group[]{};
        
        private static void install() {
           if (!isInstalled) {           
               
               Framework.Installer.install();
               PagesApi.PackageScripts.install();
               OrderApi.PackageScripts.install();               
               EventApi.PackageScripts.install();
               
               // Create a routing rule for Contact
               Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
               Framework.RoutingRule cons = new Framework.RoutingRule();
               cons.apexClass = Lead_Trigger.class.getName();
               cons.namespace = '';
               cons.isEnabled = true;
               cons.sObjectName = 'Lead';
               cons.executionOrder = 0;
               rules.add(cons);
               Framework.Config.push(rules);               
               isInstalled = true;
    
    
           }
       }
       
       private static void buildData() {
        if(businessGroups.isEmpty()) {
            Map<String, SObject[]> testData = TestDataFactory.buildData();
            businessGroups = (OrderApi__Business_Group__c[])testData.get(TestDataFactory.BUSINESSGROUPLABEL);
            groups = (Group[])testData.get(TestDataFactory.PUBLICGROUPLABEL);
        }
       }
    
       static testMethod void TestMethod1() {
            
            install();
            buildData();      
            
            // creating lead data
            Lead ld = new Lead();
            ld.LastName = 'Test';
            ld.Company = 'Test';
            //ld.Business_Group__c = businessGroups[0].Id;
            insert ld;
            
            // updating lead data
            ld.Company = 'Fonteva';
            update ld;
            
        
       }
}