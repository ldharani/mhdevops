/**@@
#APEX CLASS NAME       :   OrderJSONParseTest
#CREATED BY            :   Serge Kandukuri
#DESCRIPTION           :   This is test class for OrderJSONParse (Apex Class).
@@**/
@IsTest
public class OrderJSONParseTest{
     /**@@
    #DESCRIPTION     : This is a test method used to Parse JSON
    #Paramaters      : None
    @@**/
    public static testMethod void testUnitMethod1(){
        OrderJSONParse OJ = new OrderJSONParse();
        OrderJSONParse.cls_items ocls_items = new OrderJSONParse.cls_items();
        ocls_items.Id = '5596601';
        
        OrderJSONParse.cls_account cls_account = new OrderJSONParse.cls_account();
        
        
        OrderJSONParse.cls_data o = new OrderJSONParse.cls_data();
        o.items = ocls_items;
        
        string strBody = '{"data":{"items":{"id":"5598471","account":{"id":"1001502354","partnerId":null,"brandId":"nolo","name":"Test_int_1","url":"null","origin":"nolo.com","leadCap":null,"leadCapFrequency":null,"rankingMultiplier":null,"status":"active","salesId":null,"externalId":null,"pauseStart":null,"pauseEnd":null,"inactiveDate":null,"encodedExtendInfo":null,"updated":null,"created":"2020-12-29 09:35:31","client_guid":null,"proposals":null,"verticalId":11,"type":{"id":"1","name":null,"descriptions":null,"proposals":null,"proposalTypes":null,"waitlists":null,"__className":"Campaign_Dto_Proposal_Type","__isCache":false},"updatedBy":"555","__className":"Campaign_Dto_Account","__isCache":false},"parentIds":null,"name":"null","firmName":"Test_int_1","firmUrl":"null","contactFirstName":"Nama","contactLastName":"Testint","contactEmail":"nama@testint.com","contactPhone1":"null","contactPhone2":null,"contactFax":null,"contactAddress1":"St","contactAddress2":null,"contactCity":"New York","contactProvince":{"id":"33","code":"NY","name":"New York","urlEncodedName":"new-york","country":"US","created":"2009-12-12 00:00:00","updated":"2009-12-12 00:00:00","contactProvinces":null,"__className":"Common_Dto_Province","__isCache":false},"contactPostalCode":"31311","urlKey":"NOLO_11x5feb68e377f6bx42997084","urlKeyExpiration":"2021-02-27 09:35:31","verticalId":"11","type":{"id":"1","name":"Lawfirms","descriptions":null,"proposals":null,"proposalTypes":null,"waitlists":null,"__className":"Campaign_Dto_Proposal_Type","__isCache":false},"paymentType":{"id":"2","name":"Pay Per Lead","descriptions":null,"proposals":null,"__className":"Campaign_Dto_PaymentType","__isCache":false},"programType":"lead","fromProgramType":null,"initCharge":"0.00","flatFeeCredit":null,"pplCredit":null,"fixFeeCredit":null,"adminCredit":null,"recurringCharge":"0.00","recurringFrequency":"3","lastChargeDate":null,"nextChargeDate":null,"potentialRevenue":null,"contractTerm":"1 Year","renewalType":"auto-renew","state":"contract-activated","status":"active","salesId":"555","salesName":"rep1","saleType":"new","sendConfirmEmail":null,"sendWelcomeEmail":null,"profileOrigin":"nolo.com","leadCap":"0.00","leadCapFrequency":"Monthly","rankingMultiplier":null,"clientSiteId":null,"subscriptionDataType":null,"amendmentType":"cm","clientLastVisited":null,"salesLastVisited":null,"lastAdvertiserLimitCheck":null,"contractStart":"2020-12-29 09:35:31","contractEnd":null,"activated":"2020-12-29 09:35:31","lastSuspended":null,"updated":"2020-12-29 09:35:31","created":"2020-12-29 09:35:31","bypasses":null,"extraDatas":null,"subscriptions":[{"id":"18160181","proposal":{"id":"5598471"},"parentSubscription":null,"start":"2020-12-29 09:35:31","end":null,"discountAmt":"0.00","price":"90.00","elp":null,"termLength":null,"subscriptionCount":"1","pplDeposit":"0.00","leadCap":"1050.00","leadCapFrequency":null,"rankingMultiplier":null,"tier":null,"subscriptionType":{"id":"9"},"siteTid":null,"startLeadVolume":null,"endLeadVolume":null,"leadVolumeUpdated":null,"cancellationRequestDate":null,"cancellationReason":null,"status":"active","bypassLimitCheck":"0","updated":null,"created":"2020-12-29 09:35:31","elpUpdated":null,"childrenSubscriptions":null,"dataType1s":null,"dataType2s":null,"extraInfo":{"term1":{"id":125,"category":null,"parentTerm":null,"name":"Auto Accident","descriptions":null,"level":null,"childrenTerms":[],"externalId":"125","updated":null,"created":null,"primary":null,"stateCode":null,"__className":"Campaign_Dto_Term","__isCache":false},"term2Parents":[{"id":80371,"name":"Alaska","externalId":"80371","selectedChildren":33,"totalChildren":"33"}],"coverages":{"min":0,"max":0},"targetPrice":90},"revShare":null,"revShareFixed":null,"groupSelectionAmountType":null,"docuTemplateId":null,"sfSinId":"1001502354.70010.80203000000D84mAAC","docuPrefillFields":null,"__className":"Campaign_Dto_Proposal_Subscription","__isCache":false}],"termsConditions":null,"revShare":null,"revShareFixed":null,"groupSelectionAmountType":null,"brandId":"nolo","smbGuid":null,"externalId":null,"providerId":null,"taxType":"0","taxRate":null,"taxAmount":null,"totalAmount":null,"taxPreIncluded":null,"__className":"Campaign_Dto_Proposal","__isCache":false}}}';
        OrderJSONParse objResponse = (OrderJSONParse) JSON.deserialize(strBody, OrderJSONParse.class);
        
        OrderJSONParse.parse(strBody);
        
    }
}