/**
 *
 * Test class for the emailTemplateItemList Class
 * @author Nikilesh Kopparthi
 *
 **/

@isTest
public class Test_emailTemplateItemList {

    static testmethod void insertData() {

        OrderApi__Item_Class__c ic = new OrderApi__Item_Class__c();
        ic.Name = 'test_item_class';
        ic.OrderApi__Is_Active__c = true;
        insert ic;

        OrderApi__Item__c it = new OrderApi__Item__c();
        it.Name = 'test_item';
        it.OrderApi__Is_Active__c = true;
        it.OrderApi__Item_Class__c = ic.id;
        it.OrderApi__Price__c = 100.00;
        it.OrderApi__Cost__c = 100.00;
        insert it;

        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c();
        so.OrderApi__Posting_Entity__c = 'Invoice';
        insert so;

        OrderApi__Sales_Order_Line__c sol = new OrderApi__Sales_Order_Line__c();
        sol.OrderApi__Item__c = it.id;
        sol.OrderApi__Sales_Order__c = so.id;
        insert sol;

        OrderApi__Sales_Order__c so_1 = new OrderApi__Sales_Order__c(id=so.id);
        so_1.OrderApi__Status__c = 'Closed';
        update so_1;

        OrderApi__Sales_Order__c so_2 = new OrderApi__Sales_Order__c(id=so.id);
        so_1.OrderApi__Posting_Status__c = 'Posted';
        update so_2;

        OrderApi__Invoice__c inv = new OrderApi__Invoice__c();
        inv.OrderApi__Sales_Order__c = so.id;
        insert inv;
        
        OrderApi__Invoice_Line__c invl = new OrderApi__Invoice_Line__c();
        invl.OrderApi__Invoice__c = inv.id;
        invl.OrderApi__Item__c = it.id;
        insert invl;


        OrderApi__Receipt__c rt = new OrderApi__Receipt__c();
        insert rt;

        OrderApi__Receipt_Line__c rl = new OrderApi__Receipt_Line__c();
        rl.OrderApi__Receipt__c = rt.id;
        rl.OrderApi__Invoice__c = inv.id;
        rl.OrderApi__Sale_Price__c = 100.00;
        rl.OrderApi__Calculate_Shipping_Details__c = true;
        insert rl;

        OrderApi__Receipt__c rt_1 = new OrderApi__Receipt__c(id=rt.id);
        rt_1.OrderApi__Is_Posted__c = true;
        update rt_1;
        
        // making instance of emailTemplateItemList
        emailTemplateItemList obj = new emailTemplateItemList();
        obj.receiptId = rt.Id;
        obj.getItems();

    }
}