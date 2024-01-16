/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=true)
private class MDL_Test_UpdateFulfillmentDate {

    static testMethod void myUnitTest() {
                        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

    	MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
    	//RecordType rt = [Select id from RecordType where DeveloperName = 'MDL_Order_Rate_Plan_Charge'];
    	Account acc = testData.getAccount();
    	acc.MH_Cust_Number__c = '12334';
    	update acc;
    	invoiceit_s__Currency__c cur = testData.getCurrencyObject();
    	invoiceit_s__Product__c prod = testData.getProduct('false');
        prod.Shippable__c = 'Yes';
        update prod;
    	invoiceit_s__Product_Rate_Plan__c prodRP = testData.getProductRatePlan(prod.Id);
    	invoiceit_s__Product_Rate_Plan_Charge__c pRPC = testData.getProductRatePlanCharge(Cur.Id, prodRP.Id);
    	invoiceit_s__Job__c ord = testData.getOrder(acc.Id, Cur.Id);
        ord                     = [select id, Name,invoiceit_s__Account__c,
                                            invoiceit_s__CurrencyL__c,invoiceit_s__Status__c,
                                            OrderNumber__c
                                            From invoiceit_s__Job__c
                                            Where id=: ord.id];
    	invoiceit_s__Job_Product__c ordProd = testData.getOrderProduct(ord.Id, prod.Id);
    	invoiceit_s__Job_Rate_Plan__c orderRP = testData.getOrderRatePlan(OrdProd.Id, prodRP.Id);
    	invoiceit_s__Job_Rate_Plan_Charge__c orderRPC = testData.getOrderRatePlanCharge(OrderRP.Id, PRPC.Id); 
    	orderRPC.SIN__c = '1000000502.01121.a0Fc0000003MYKqEAO';
       update orderRPC;
    	System.debug('%%%'+String.valueOf(Date.today()));
		String[] ss = String.valueOf(Date.today()).split('-');
		String tDate = ss[1]+'/'+ss[2]+'/'+ss[0];
		System.debug('today date is :::'+tDate);                                                 
        String resp = MDL_UpdateFulfillmentDate.updateFulfillmentDate('<FulfillmentMessageRequest><RequestId>0f8fad5b-d9cb-469f-a165-70867728950e</RequestId><CustomerNumber>005004163800</CustomerNumber><OrderNumber>12345</OrderNumber><LineItem><LineItemId>unique id</LineItemId><SubscriptionIdentificationNumber>1000000502.01120.a0Fc0000003MYKqEAO</SubscriptionIdentificationNumber><FulfillmentDate>01/01/2014</FulfillmentDate><Messages/></LineItem></FulfillmentMessageRequest>');
        String fulXML = '<FulfillmentMessageRequest><RequestId>0f8fad5b-d9cb-469f-a165-70867728950e</RequestId><CustomerNumber>005004163800</CustomerNumber><OrderNumber>12345</OrderNumber><LineItem><LineItemId>unique id</LineItemId><SubscriptionIdentificationNumber>' + orderRPC.SIN__c + '</SubscriptionIdentificationNumber><FulfillmentDate>'+tDate+'</FulfillmentDate><Messages/></LineItem></FulfillmentMessageRequest>';
   		String resp1 = MDL_UpdateFulfillmentDate.updateFulfillmentDate(fulXML);
   		String fulXML1 = '<FulfillmentMessageRequest><RequestId>0f8fad5b-d9cb-469f-a165-70867728950e</RequestId><CustomerNumber>'+acc.MH_Cust_Number__c+'</CustomerNumber><OrderNumber>'+ord.OrderNumber__c+'</OrderNumber><LineItem><LineItemId>unique id</LineItemId><SubscriptionIdentificationNumber></SubscriptionIdentificationNumber><FulfillmentDate></FulfillmentDate><Messages><Message><QueueName>TBD</QueueName><Code>HTTP 500 Internal Server Error</Code><Text>VIM is currently unavailable</Text><CaseOrigin>Email</CaseOrigin><Area>area</Area><SubArea>SubArea</SubArea></Message></Messages></LineItem></FulfillmentMessageRequest>';
   		String resp2 = MDL_UpdateFulfillmentDate.updateFulfillmentDate(fulXML1);
        String fulXML2 = '<FulfillmentMessageRequest><RequestId>0f8fad5b-d9cb-469f-a165-70867728950e</RequestId><CustomerNumber>'+acc.MH_Cust_Number__c+'</CustomerNumber><OrderNumber>'+ord.OrderNumber__c+'</OrderNumber><LineItem><LineItemId>unique id</LineItemId><SubscriptionIdentificationNumber></SubscriptionIdentificationNumber><FulfillmentDate></FulfillmentDate><Messages><Message><QueueName>TBD</QueueName><Code>HTTP 500 Internal Server Error</Code><Text>VIM is currently unavailable</Text><Area>area</Area><SubArea>SubArea</SubArea></Message></Messages></LineItem></FulfillmentMessageRequest>';
   		String resp3 = MDL_UpdateFulfillmentDate.updateFulfillmentDate(fulXML2);
    }
    
    
    //Sai   : 14/10/2016
    static testmethod void run2condition(){
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        
        //creating account
        Account acc             = testData.getAccount_withoutInsert();
        acc.MH_Cust_Number__c   =  '0123456789';
        insert acc;
        
        //creating currency
        invoiceit_s__Currency__c singlecurrency = testData.getCurrencyObject();
        
        //creating product
        invoiceit_s__Product__c prod = testData.getProduct('false');
        
        //creating product rate plan
        invoiceit_s__Product_Rate_Plan__c prodRP = testData.getProductRatePlan(prod.Id);
        
        //creating product rateplan charge
        invoiceit_s__Product_Rate_Plan_Charge__c pRPC = testData.getProductRatePlanCharge(singlecurrency.Id, prodRP.Id);
        
        
        //creating order
        invoiceit_s__Job__c order = testData.getOrder(acc.Id, singlecurrency.id);
        order                     = [select id, Name,invoiceit_s__Account__c,
                                            invoiceit_s__CurrencyL__c,invoiceit_s__Status__c,
                                            OrderNumber__c
                                            From invoiceit_s__Job__c
                                            Where id=: order.id];
        system.debug('@@@order number'+ order.OrderNumber__c);
        system.debug('@@@order number'+ order.Name);
        
        //creating orderProduct
        invoiceit_s__Job_Product__c orderProduct = testData.getOrderProduct(order.Id, prod.Id);
        
       
        //creating order rate plan
        invoiceit_s__Job_Rate_Plan__c orderRP = testData.getOrderRatePlan(orderProduct.Id, prodRP.Id);
        
        invoiceit_s__Job_Rate_Plan_Charge__c orderRPC     = new invoiceit_s__Job_Rate_Plan_Charge__c();
        orderRPC.Name                                     = 'Test RPC ' + '1234';
        orderRPC.invoiceit_s__Job_Rate_Plan__c            = orderRP.id;
        orderRPC.invoiceit_s__Product_Rate_Plan_Charge__c = pRPC.id  ; 
        orderRPC.invoiceit_s__Quantity__c                 = 1;
        orderRPC.invoiceit_s__Status__c                   = 'In Progress';
        orderRPC.invoiceit_s__Accounting_Code__c          = '1111';
        insert orderRPC;
        //orderRPC.SIN__c                                   = orderRPC.invoiceit_s__Accounting_Code__c + orderRPC.id;
       // update orderRPC;
        
       orderRPC = [select id, Name,
                          invoiceit_s__Job_Rate_Plan__c,invoiceit_s__Product_Rate_Plan_Charge__c,
                          invoiceit_s__Quantity__c,invoiceit_s__Status__c,
                          invoiceit_s__Accounting_Code__c, SIN__c
                          From invoiceit_s__Job_Rate_Plan_Charge__c
                          where id=:orderRPC.id];
        
        String ss = String.valueOf(Date.today());
		//String tDate = ss[1]+'/'+ss[2]+'/'+ss[0];
        
        system.debug('@@@acc mh customer number'+ acc.MH_Cust_Number__c);
         acc = [Select Id,Name,MH_Cust_Number__c from Account where id=:acc.id]; 
         system.debug('@@@@@@@@@@@@@@accc1'+acc);       
        String reqXML = '<FulfillmentMessageRequest>'+
						'<RequestId>0f8fad5b-d9cb-469f-a165-70867728950e</RequestId>'+
						'<CustomerNumber>'+acc.MH_Cust_Number__c+'</CustomerNumber>'+
						'<OrderNumber>'+order.OrderNumber__c+'</OrderNumber>'+
						'<LineItem>'+
                        	'<LineItemId>unique id</LineItemId>'+
							'<SubscriptionIdentificationNumber>' + orderRPC.SIN__c + '</SubscriptionIdentificationNumber>'+
							'<FulfillmentDate>'+ss+'</FulfillmentDate>'+
							'<Messages>'+
      							'<Message>'+
        							'<Code>Chat_Err_100</Code>'+
        							'<Text>Org ID is not provisioned yet. Hence cannot fulfill Chat Id : 67345</Text>'+
                                     '<CaseOrigin>Email</CaseOrigin>'+
                                     '<Area>area</Area>'+
                                     '<SubArea>SubArea</SubArea>'+
      							'</Message>'+
    						'</Messages>'+
						'</LineItem>'+
					'</FulfillmentMessageRequest>';
        
        
           Test.startTest();
   
   			//As Per Best Practice it is important to instantiate the Rest Context 
   			RestRequest req = new RestRequest(); 
   			RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/FulfillmentMessage';  //Request URL
            req.httpMethod = 'POST'; //HTTP Request Type
            req.requestBody = Blob.valueof(reqXML);
            RestContext.request = req;
            RestContext.response= res;
        
           MDL_UpdateFulfillmentDate.doPost();
        
         Test.stopTest();
        
    }
    
    
    
    
    
    
}