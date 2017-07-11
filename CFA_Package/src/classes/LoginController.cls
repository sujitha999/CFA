/**
 *
 * Controller class for the custom login for CFA
 * @author Vishal Shah
 *
 **/

public class LoginController {

    private final String SO_COOKIE_NAME = UserInfo.getOrganizationId() + '-fonteva-shopping-cart';
    private final String RET_COOKIE_NAME = 'return-url';
    
    public class SOData {
        public Id salesOrderId;
        public Id userId;
    }

    public PageReference LoginUser()
    {
        
        Cookie retUrl = ApexPages.currentPage().getCookies().get(RET_COOKIE_NAME);
        String redirectTo = '';
        Boolean addParam = false;
    
        if (retUrl == null) {
            redirectTo = '/login?so=' + UserInfo.getOrganizationId();
            String referUrl = ApexPages.currentPage().getheaders().get('Referer');
            if(String.isEmpty(referUrl)) {
                referUrl = '/CPBase__events?site=' + ApexPages.currentPage().getParameters().get('site');
            }
            retUrl = new Cookie(RET_COOKIE_NAME,referUrl,null,-1,false);

        } else {
            Cookie soCookie = ApexPages.currentPage().getCookies().get(SO_COOKIE_NAME);
            if(soCookie != NULL){
                SOData cookieObj = (SOData) JSON.deserialize(String.valueOf(soCookie.getValue()), SOData.class);
                cookieObj.userId = Userinfo.getUserId();
                updateContacts(cookieObj);
                String cookieValue = JSON.serialize(cookieObj);
                Cookie sfdcCookie = new Cookie(SO_COOKIE_NAME,cookieValue,null,-1, true);
                ApexPages.CurrentPage().setCookies(new Cookie[]{ sfdcCookie });
            }
            redirectTo = String.valueOf(retUrl.getValue());
            retUrl = new Cookie(RET_COOKIE_NAME, '',null,0,false);
        }
        ApexPages.currentPage().setCookies(new Cookie[]{retUrl});
        return pageredirect(redirectTo, addParam);
    }

    private PageReference pageredirect(String url, Boolean addParam){
        PageReference loginPage = new PageReference(url);
        loginPage.setRedirect(true);
        if(addParam) {
            loginPage.getParameters().put('retUrl', url);
        }
        return loginPage;
    }
    
    private void updateContacts(SOData sodata) {
        Id contactId = [SELECT ContactId FROM User WHERE Id = :sodata.userId].ContactId;
        Id accountId = [SELECT AccountId FROM Contact WHERE Id = :contactId].AccountId;
        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c(Id = sodata.salesOrderId, OrderApi__Contact__c = contactId);
        so.OrderApi__Calculate_Billing_Details__c = true;
        so.OrderApi__Calculate_Shipping_Details__c = true;
        
        OrderApi__Sales_Order_Line__c[] sols = new OrderApi__Sales_Order_Line__c[]{};
        for(OrderApi__Sales_Order_Line__c sol : [SELECT OrderApi__Account__c, OrderApi__Contact__c,OrderApi__Is_Tax__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c = :sodata.salesOrderId]) {
            if (!sol.OrderApi__Is_Tax__c) {
                sol.OrderApi__Account__c = accountId;
                sol.OrderApi__Contact__c = contactId;
                sols.add(sol);
            }
        }

        update so;
        System.enqueueJob(new UpdateSalesOrderLines(sols));
    }
    
    public class UpdateSalesOrderLines implements Queueable {
    
        private List<OrderApi__Sales_Order_Line__c> lines;
        
        public UpdateSalesOrderLines(List<OrderApi__Sales_Order_Line__c> lines) {
            this.lines = lines;
        }
    
        public void execute(QueueableContext context) {
            update this.lines;
        }
    }
}