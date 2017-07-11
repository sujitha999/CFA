@isTest 
private class ReceiptLineExtender1_test {
        static Boolean isInstalled = false;
        
        private static void install() {
           if (!isInstalled) {           
               
               Framework.Installer.install();
               PagesApi.PackageScripts.install();
               OrderApi.PackageScripts.install();               
               EventApi.PackageScripts.install();
               
               // Create a routing rule for Contact
               Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
               Framework.RoutingRule cons = new Framework.RoutingRule();
               cons.apexClass = ReceiptLine_Trigger.class.getName();
               cons.namespace = '';
               cons.isEnabled = true;
               cons.sObjectName = 'OrderApi__Receipt_Line__c';
               cons.executionOrder = 0;
               rules.add(cons);
               Framework.Config.push(rules);               
               isInstalled = true;
    
    
           }
       }
        static testMethod void TestMethod1() {
            
             install();
            
            // creating receipt data
            OrderApi__Receipt__c receipt = new OrderApi__Receipt__c();
            insert receipt;
            
            // invoice inserting
            OrderApi__Invoice__c invoice = new OrderApi__Invoice__c();
            insert invoice;
            
            // insert receipt line
            OrderApi__Receipt_Line__c rlines = new OrderApi__Receipt_Line__c();
            rlines.OrderApi__Receipt__c = receipt.id;
            rlines.OrderApi__Invoice__c = invoice.id;
            insert rlines;
            
            update rlines;
        
        }

        
    
    

}