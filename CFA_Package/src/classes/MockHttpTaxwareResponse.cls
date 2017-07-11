@isTest
global class MockHttpTaxwareResponse implements HttpCalloutMock {
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"txwTrnDocId":"0","txAmt":"0.0","lnRslts":[{"lnNm":"1","lnId":"a1D61000005CAcBEAW","txAmt":"0.0","grossAmt":"100.0","jurRslts":[{"txAmt":"0.0","txRate":"0.0","txableAmt":"0.0","xmptAmt":"100.0","txName":"VA State Tax","txTp":"1","txPaidToDt":"0.0","txablePaidToDt":"0.0","leasePmtTp":"S","txJurUIDCntry":"UNITED STATES","txJurUIDStatePrv":"VIRGINIA","txJurUIDJurTp":"2","txJurUIDStatePrvISO":"VA","txJurUIDCntryISO":"United States"},{"txAmt":"0.0","txRate":"0.0","txableAmt":"0.0","xmptAmt":"100.0","txName":"VA County Tax","txTp":"1","txPaidToDt":"0.0","txablePaidToDt":"0.0","leasePmtTp":"S","txJurUIDCntry":"UNITED STATES","txJurUIDStatePrv":"VIRGINIA","txJurUIDCityCntyDist":"FAIRFAX","txJurUIDJurTp":"3","txJurUIDStatePrvISO":"VA","txJurUIDCntryISO":"United States"},{"txAmt":"0.0","txRate":"0.0","txableAmt":"0.0","xmptAmt":"100.0","txName":"Northern Virginia Region Tax","txTp":"1","txPaidToDt":"0.0","txablePaidToDt":"0.0","leasePmtTp":"S","txJurUIDCntry":"UNITED STATES","txJurUIDStatePrv":"VIRGINIA","txJurUIDCityCntyDist":"NORTHERN VIRGINIA REGION","txJurUIDJurTp":"5","txJurUIDStatePrvISO":"VA","txJurUIDCntryISO":"United States"}],"mergedResult":"false"}]}');
        res.setStatusCode(200);
        return res;
    }
}