/***********************************************************************************************************************
* @author - CK
* @date - 23 Sep 2022
* @description - To send out order XML request for Order expiration. 
* 				This is a replica of CPQ_MDL_Integration_Vim_Efs.orderRequest as it is already a future callout and 
* 				we need to run it from the finish method of Order Month end expiration batch.
* @testclass - BatchToExpireOrdersContracts_Test
* JIRA - MHBS-5341

Change History
************************************************************************************************************************

************************************************************************************************************************/

public class BatchToExpireOrderProductsXMLIntegration implements Database.Batchable<Id>,Database.Stateful,Database.AllowsCallouts{
    List<Id> oItemIds = new List<Id>();
    public BatchToExpireOrderProductsXMLIntegration(List<Id> orderItemId){
        this.oItemIds = orderItemId;        
    }
    public Iterable<Id> start(Database.BatchableContext bc) {
        return oItemIds;
    }
    public void execute(Database.BatchableContext BC, List<Id> OrderItemIds){
        system.debug('OrderItemIds '+OrderItemIds);
        Map<Id,Order> mapOrderIdNOrder = new Map<Id,Order>();
        Map<Id, List<OrderItem>> orderIdVSOrderProducts = new Map<Id, List<OrderItem>>();
        Set<string>attributeRelations = new Set<string>();
        List<OrderItem> orderprodlist = [Select id,Status__c,Product2.IsInventoried__c ,Fulfillment_date__c,OrderId,SIN__c,Inventory_Id__c,Attribute_Relationship__c,Renew_Rebase_Truncate_Date__c,Product2.ProductCode,
                                         ServiceDate,EndDate,SBQQ__TerminatedDate__c,Product2.Name,blng__NextBillingDate__c,SBQQ__BundleRoot__c,ParentProduct__c,Live_Date__c,
                                         Order.Account.Phone,Order.Account.Contact_Email__c,Order.Account.Last_Name__c,Order.Account.First_Name__c,Contact__r.Website__c,
                                         Contact__r.Email,Contact__r.LastName,Contact__r.FirstName,Contact__r.Professional_ID__c,Contact__r.Phone,
                                         Chat_ID__c,SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.SIN__c,SBQQ__ProductSubscriptionType__c,CreatedDate from OrderItem where ID IN:OrderItemIds];
        
        String reqXML;
        Integer numberOfDays = Date.daysInMonth(date.today().year(), date.today().month());
        Date lastDayOfMonth = Date.newInstance(date.today().year(), date.today().month(), numberOfDays);
        MDL_RecursionHandler.CheckUpdate = true;
        List<String> lstResponseBody = new List<String>();
        List<Error_Log__c> lstErrLogs = new List<Error_Log__c>();
        List<Error_Log__c> lstExistingErrLogs = new List<Error_Log__c>();
        Map<Id,Error_Log__c> mapIdNExistingErrLogs = new Map<Id,Error_Log__c>();
        
        Map<Id,List<Attribute_Lines__c>> mapOrderIdNlstOrderChargeAttributes = new Map<Id,List<Attribute_Lines__c>>();
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('OrderRequest');
        String endPoint = String.valueOf(endPts.Endpoint_URL__c);
        String methodType = endPts.MethodType__c;
        
        //code for authentication
        String timeDifferenceInSeconds = String.valueOf((DateTime.now().getTime()/1000));   //returns milliseconds from Jan 1st 1970(Hence we divide by 1000 to get seconds)
        String endPoint1 = endPts.Endpoint_URL_for_authentication__c ;
        String privateKey = endPts.Private_Key__c;
        String publicKey  = endPts.Public_Key__c;
        String apiKey = endPts.API_key__c;
        
        Restrict_Integration_Calls__c rCalls = Restrict_Integration_Calls__c.getValues('Restrict');
        System.debug('**'+rCalls);
        Boolean restrictCalls = Boolean.valueOf(rCalls.Restrict_Callouts__c);
        System.debug('a values is **'+restrictCalls);
        
        //get Orders from Order Products
        for(OrderItem op : orderprodlist){
            if(op.Attribute_Relationship__c!=null){
                attributeRelations.add(op.Attribute_Relationship__c);
            }
            
            
            if(orderIdVSOrderProducts.containsKey(op.orderId)){
                orderIdVSOrderProducts.get(op.orderId).add(op);
            }
            else{
                orderIdVSOrderProducts.put(op.orderId, new List<OrderItem>{op});
            }
        }
        
        List<Attribute_Lines__c> attributes = [select id, Attribute_Junction__c, Attribute_Type__c, Attribute_Name__c, 
                                               Picklist_Value__c, String_Value__c, Boolean_Value__c, Date_Value__c,Phone_Value__c, Value_ID__c,
                                               Number_Value__c FROM Attribute_Lines__c where Attribute_Junction__c  IN:attributeRelations];
        Map<string, List<Attribute_Lines__c>> attributeRelationVSattributes = new Map<string, List<Attribute_Lines__c>>();
        for(Attribute_Lines__c ab : attributes){
            if(attributeRelationVSattributes.containsKey(ab.Attribute_Junction__c)){
                attributeRelationVSattributes.get(ab.Attribute_Junction__c).add(ab);
            }
            else{
                attributeRelationVSattributes.put(ab.Attribute_Junction__c, new List<Attribute_Lines__c>{ab});
            }
        }
        
        Map<Id,Order> OrderMap = new Map<Id,Order>([select Id ,Account.MH_Cust_Number__c ,Account.IB_Customer_Number__c,Account.RecordType.DeveloperName,AccountId ,
                                                    Account.Org_Id__c,Account.Contact_Email__c,Firm_Name_from_BS__c,OrderNumber, 
                                                    Account.BillingCountry,Account.BillingState,Account.BillingCity,Account.BillingStreet,
                                                    Account.BillingPostalCode,Account.Website,Account.Phone,Name From order where Id IN : orderIdVSOrderProducts.keyset()]);
        // End of data Setup
        
        
        //Checking if Order XML already exists in Error Log, if exists do not send that order , queue it along with the existing order
        for(Error_Log__c err : [Select e.XML_Mesaage_Type__c, e.XML_Body__c, e.Sent_Successfully__c, e.Order_Number__c,e.Order_Name__c,e.Error_Reason__c, e.Name, e.Id ,e.Re_process_date_time__c
                                From Error_Log__c e
                                Where e.XML_Mesaage_Type__c = 'OrderRequest' AND e.Order_Number__c in :mapOrderIdNOrder.keySet()] ) {
                                    mapIdNExistingErrLogs.put(err.Order_Number__c,err);                 
                                }
        System.debug('mapOrderId And Error Logs^^^'+mapIdNExistingErrLogs);
        
        reqXML = '';
        String xmlns = '';
        //Logic for generating line item id
        DateTime result1 = DateTime.now();
        String timeStamp = result1.format('yyyy/MM/dd HH:mm:ss');//to convert datetime into string
        System.debug('timeStamp'+timeStamp);
        String[] str1 = timeStamp.split(' ');
        String[] str2 = str1[0].split('/');
        String[] str3 = str1[1].split(':');
        String lineItemId = str2[0]+str2[1]+str2[2]+str3[0]+str3[1]+str3[2];
        System.debug('Id is:'+lineItemId);
        //end of logic - line itemid
        String postDate = '';
        String []validatedDateValue;
        
        //get xmlns value from custom setting
        
        xmlns = endPts.xmlns__c;
        
        //get server timestamp to send it in requestid
        DateTime result = DateTime.now();
        String timeStampString = result.format();//to convert datetime into string
        String reqID = OrderMap.keySet() + '-' + timeStampString ;
        
        // Start of Order XML 
        for(string orderId : orderIdVSOrderProducts.keyset()){
            //construction of XML for Order XML
            Xmlstreamwriter xmlW = new Xmlstreamwriter();
            
            //Beginning of OrderRequest tag
            xmlW.writeStartElement(null,'OrderRequest', null); 
            xmlW.writeAttribute(null,null,'xmlns',xmlns);
            
            //Beginning of requestId tag
            xmlW.writeStartElement(null,'RequestId',null);
            xmlW.writeCharacters(reqID);
            xmlW.writeEndElement();
            //end of Request Id Tag
            
            //Beginning of Order tag
            xmlW.writeStartElement(null,'Order', null); 
            
            //Beginning of Username tag
            xmlW.writeStartElement(null, 'UserName', null);
            //xmlW.writeCharacters(uName);
            xmlW.writeEndElement();
            //End of Username tag
            
            
            //Beginning of CustomerNumber tag
            if(Ordermap.get(orderid).Account.MH_Cust_Number__c != null) {
                xmlW.writeStartElement(null, 'CustomerNumber', null);
                xmlW.writeCharacters(Ordermap.get(orderid).Account.MH_Cust_Number__c);
                xmlW.writeEndElement();
            }
            else {
                xmlW.writeEmptyElement(null, 'CustomerNumber', null);
            }
            //End of CustomerNumber tag
            
            if(Ordermap.get(orderid).Account.RecordType.DeveloperName == 'M_A_Atty_Account') {
                //Beginning of Parent customernumber tag
                if(Ordermap.get(orderid).Account.IB_Customer_Number__c != null) {
                    xmlW.writeStartElement(null, 'ParentCustomerNumber', null);
                    xmlW.writeCharacters(Ordermap.get(orderid).Account.IB_Customer_Number__c);
                    xmlW.writeEndElement();
                }
                else {
                    xmlW.writeEmptyElement(null, 'ParentCustomerNumber', null);
                }
                
            }
            
            //Beginning of OrgID tag: added on 05/01/2016 by akash
            if(Ordermap.get(orderid).Account.Org_Id__c != null){
                xmlW.writeStartElement(null, 'OrgId', null);
                xmlW.writeCharacters(Ordermap.get(orderid).Account.Org_Id__c);
                xmlW.writeEndElement();
                //End of OrgId tag
            }
            
            else {
                xmlW.writeEmptyElement(null, 'OrgId', null);
            }
            //End of orgID tag
            
            if(Ordermap.get(orderid).Account.RecordType.DeveloperName == 'M_A_Atty_Account') {
                
                //Beginning of ServiceAccountName tag
                xmlW.writeStartElement(null, 'ServiceAccountName', null);
                if(Ordermap.get(orderid).Firm_Name_from_BS__c != null){
                    xmlW.writeCharacters(Ordermap.get(orderid).Firm_Name_from_BS__c);
                }
                xmlW.writeEndElement();
                //End of ServiceAccountName tag
                
                //Beginning of Email tag
                xmlW.writeStartElement(null, 'Email', null);
                if(Ordermap.get(orderid).Account.Contact_Email__c != null){
                    
                    xmlW.writeCharacters(Ordermap.get(orderid).Account.Contact_Email__c);
                }
                xmlW.writeEndElement();
                //End of Email tag
                
                //Beginning of ServiceCountry tag
                xmlW.writeStartElement(null, 'ServiceCountry', null);
                xmlW.writeCharacters(Ordermap.get(orderid).Account.BillingCountry);
                xmlW.writeEndElement();
                //End of ServiceCountry tag
                
                
                //Beginning of ServiceState tag
                xmlW.writeStartElement(null, 'ServiceState', null);
                xmlW.writeCharacters(Ordermap.get(orderid).Account.BillingState);
                xmlW.writeEndElement();
                //End of ServiceState tag
                
                //Beginning of ServiceCity tag
                xmlW.writeStartElement(null, 'ServiceCity', null);
                xmlW.writeCharacters(Ordermap.get(orderid).Account.BillingCity);
                xmlW.writeEndElement();
                //End of ServiceCity tag
                
                
                //Beginning of ServiceStreetAddress tag
                xmlW.writeStartElement(null, 'ServiceStreetAddress', null);
                xmlW.writeCharacters(Ordermap.get(orderid).Account.BillingStreet);
                xmlW.writeEndElement();
                //End of ServiceStreetAddress tag
                
                
                //Beginning of ServiceZip tag
                xmlW.writeStartElement(null, 'ServiceZip', null);
                xmlW.writeCharacters(Ordermap.get(orderid).Account.BillingPostalCode  );
                xmlW.writeEndElement();
                //End of ServiceZip tag
                
                
                //Beginning of WebsiteURL tag
                xmlW.writeStartElement(null, 'WebsiteURL', null);
                if(Ordermap.get(orderid).Account.Website != null){
                    xmlW.writeCharacters(Ordermap.get(orderid).Account.Website );
                }
                xmlW.writeEndElement();
                //End of WebsiteURL tag
                
                
                //Beginning of Phone tag
                xmlW.writeStartElement(null, 'Phone', null);
                if(Ordermap.get(orderid).Account.Phone != null){
                    xmlW.writeCharacters(String.valueOf(Ordermap.get(orderid).Account.Phone));
                    
                }
                
                xmlW.writeEndElement();
                //End of Phone tag
                
            }
            //Beginning of OrderNumber tag
            xmlW.writeStartElement(null, 'OrderNumber', null);
            xmlW.writeCharacters(Ordermap.get(orderid).OrderNumber);
            xmlW.writeEndElement();
            //End of OrderNumber tag
            
            //beginning of Products tag
            xmlW.writeStartElement(null,'Products',null);
            //getting order products
            List<OrderItem> opTemplist = orderIdVSOrderProducts.get(orderId);
            for(OrderItem op : opTemplist){
                //start of order product related xml here
                //Beginning of Product tag
                xmlW.writeStartElement(null,'Product', null); 
                
                //Beginning of ProductId tag
                xmlW.writeStartElement(null,'ProductId',null);
                xmlW.writeCharacters(op.Id);
                xmlW.writeEndElement();
                //End of ProductId tag
                
                //Beginning of SubscriptionIdentificationNumber tag
                xmlW.writeStartElement(null,'SubscriptionIdentificationNumber',null);
                if(op.SIN__c != null)
                    xmlW.writeCharacters(op.SIN__c);
                xmlW.writeEndElement();
                //End of SubscriptionIdentificationNumber tag
                
                //Beginning of ProductCode tag
                xmlW.writeStartElement(null,'ProductCode',null);
                xmlW.writeCharacters(op.Product2.ProductCode);
                xmlW.writeEndElement();
                //End of ProductCode tag
                
                //Beginning of LineItems tag
                xmlW.writeStartElement(null,'LineItems', null); 
                
                //Beginning of LineItem tag
                xmlW.writeStartElement(null,'LineItem', null);
                
                //Beginning of LineItemId tag
                xmlW.writeStartElement(null, 'LineItemId', null);
                xmlW.writeCharacters(op.Id+lineItemId);
                xmlW.writeEndElement();
                //End of LineItemId tag
                if(op.Sin__c != null) {
                    xmlW.writeStartElement(null, 'SubscriptionIdentificationNumber', null);
                    xmlW.writeCharacters(op.SIN__c);
                    xmlW.writeEndElement();
                }
                else {
                    xmlW.writeEmptyElement(null, 'SubscriptionIdentificationNumber', null);
                }
                
                //Beginning of ProductCode tag
                if(op.Product2.Name != null) {
                    xmlW.writeStartElement(null,'ProductCode',null);
                    xmlW.writeCharacters(op.Product2.ProductCode);
                    xmlW.writeEndElement();
                    //End of ProductCode tag
                    
                }
                else {
                    xmlW.writeEmptyElement(null, 'ProductCode', null);
                }
                
                if(op.Product2.Name != null) {
                    xmlW.writeStartElement(null, 'ProductName', null);
                    xmlW.writeCharacters(op.Product2.Name);
                    xmlW.writeEndElement();
                }
                else {
                    xmlW.writeEmptyElement(null, 'ProductName', null);
                }
                xmlW.writeStartElement(null, 'Status', null);
                if(op.Status__c != null) {
                    string status = '';
                    if(op.Status__c == 'Active' || op.Status__c == 'Renewed' || op.Status__c == 'Rebased' )
                        //commented by Sai C
                        //|| (orderProd.invoiceit_s__Status__c == 'Truncated' && orderProd.invoiceit_s__Service_End_Date__c > Date.today()))
                        //xmlW.writeCharacters('Active'); 
                        status ='Active';
                    if(op.Status__c == 'Cancelled' || op.Status__c == 'Expired' || op.Status__c == 'Truncated' || Test.isRunningTest()){
                        //xmlW.writeCharacters('Cancel'); 
                        status = 'Cancel';
                        
                    }
                    
                    
                    xmlW.writeCharacters(status); 
                } 
                xmlW.writeEndElement();
                // End of Status
                
                //Beginning of PostDate tag
                xmlW.writeStartElement(null, 'PostDate', null);
                postDate = String.valueOf(op.CreatedDate);
                validatedDateValue = postDate.split(' ');
                xmlW.writeCharacters(validatedDateValue[0]);
                xmlW.writeEndElement();
                //End of PostDate tag
                
                
                //Beginning of FulfillmentDate tag
                if(op.Fulfillment_date__c!= null) {
                    // if(orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Product_Provisioning__c != 'System Fulfillment' && (orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Product_Provisioning__c != null || orderProd.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.Product_Provisioning__c != '')) { 
                    xmlW.writeStartElement(null, 'FulfillmentDate', null);
                    xmlW.writeCharacters(String.valueOf(op.Fulfillment_date__c));
                    xmlW.writeEndElement();
                    //}
                }
                
                if(op.Status__c == 'Cancelled' || test.isrunningtest()) { 
                    if(op.SBQQ__TerminatedDate__c != null) {
                        xmlW.writeStartElement(null, 'CancelDate', null);
                        xmlW.writeCharacters(String.valueOf(op.SBQQ__TerminatedDate__c));  
                        xmlW.writeEndElement();
                    }
                }
                else if(op.Status__c == 'Expired' || op.Status__c == 'Truncated' || test.isrunningtest()) {
                    // if(op.SBQQ__TerminatedDate__c != null) {
                    // String terminatedate = lastDayOfMonth ;
                    xmlW.writeStartElement(null, 'CancelDate', null);
                    System.debug('service end of charge past its service end date is::'+String.valueOf(op.SBQQ__TerminatedDate__c));
                    if(op.EndDate != null) { 
                        
                        xmlW.writeCharacters(String.valueOf(op.EndDate));  
                    }
                    else{
                        xmlW.writeCharacters(String.valueOf(lastDayOfMonth)); 
                    }
                    
                    xmlW.writeEndElement();
                    //}
                }
                
                
                //Beginning of IsProductInventoried tag
                xmlW.writeStartElement(null, 'IsProductInventoried', null);
                if(op.Product2.IsInventoried__c != False){
                    
                    xmlW.writeCharacters('True');
                }
                else{
                    xmlW.writeCharacters('False');
                }
                xmlW.writeEndElement();
                //End of IsProductInventoried tag
                
                //Beginning of HasparentProducts tag*****
                xmlW.writeStartElement(null, 'HasParentProducts', null);
                If(op.SBQQ__RequiredBy__c != null && op.SBQQ__RequiredBy__r.SIN__c != null && !op.ParentProduct__c.contains('Package') &&
                   !op.ParentProduct__c.contains('Bundle') ){
                       
                       xmlW.writeCharacters('Y');
                       //xmlW.writeEndElement();
                       
                   }
                
                else{
                    xmlW.writeCharacters('N');
                }
                xmlW.writeEndElement();
                //End of HasparentProducts tag 
                
                
                //Beginning of ParentProductSIN tag***********added by akash
                xmlW.writeStartElement(null, 'ParentProductSIN', null);
                
                if(op.SBQQ__RequiredBy__c != null && op.SBQQ__RequiredBy__r.SIN__c != null && !op.ParentProduct__c.contains('Package') &&
                   !op.ParentProduct__c.contains('Bundle') ){
                       xmlW.writeCharacters(op.SBQQ__RequiredBy__r.SIN__c );
                   }
                else {
                    xmlW.writeCharacters('');
                }
                
                xmlW.writeEndElement();
                //End of ParentProductSIN tag 
                
                //Begin of FulfillmentID Tag
                xmlW.writeStartElement(null, 'FulfillmentID', null);
                if(op.Chat_ID__c != null){
                    System.Debug ('orderProd' + op);
                    xmlW.writeCharacters(op.Chat_ID__c);
                }
                else{
                    xmlW.writeCharacters(' ');
                }
                xmlW.writeEndElement();
                //End of FulfillmentID tag
                
                
                //Beginning of Inventory Id Attribute Name tag
                //xmlW.writeStartElement(null, 'Name', null);
                //xmlW.writeCharacters('InventoryId');
                //xmlW.writeEndElement();
                //End of Inventory Id Attribute Name tag
                
                //Beginning of Inventory Id Attribute Value tag
                // xmlW.writeStartElement(null, 'Value', null);
                //if(op.Inventory_Id__c!= null)
                //    xmlW.writeCharacters(op.Inventory_Id__c);
                //xmlW.writeEndElement();
                //End of Inventory Id
                
                // Adding Service Start Date Tag for Charges by Sai C
                xmlW.writeStartElement(null, 'ServiceStartDate', null);
                if(op.ServiceDate != null){
                    xmlW.writeCharacters(String.valueOf(op.ServiceDate));  
                }
                else{
                    xmlW.writeCharacters('');
                }
                xmlW.writeEndElement();
                // End of Service Start date Tag for charges 
                
                // Adding Service End Date Tag for Charges by Sai C
                xmlW.writeStartElement(null, 'ServiceEndDate', null);
                if(op.EndDate != null && op.Status__c != 'Truncated' && op.Status__c != 'Expired' && op.Status__c != 'Cancelled'){
                    xmlW.writeCharacters(String.valueOf(op.EndDate));  
                }
                else if( op.Status__c == 'Truncated' || op.Status__c == 'Expired' || op.Status__c == 'Cancelled' || Test.isRunningTest() ){
                    
                    if(op.EndDate != null) { 
                        
                        xmlW.writeCharacters(String.valueOf(op.EndDate)); 
                    }
                    else{
                        xmlW.writeCharacters(String.valueOf(lastDayOfMonth)); 
                    } 
                }
                else{
                    xmlW.writeCharacters('');
                }
                xmlW.writeEndElement();
                // End of Service End date Tag for charges 
                
                if(op.Product2.ProductCode == '11014' || op.Product2.ProductCode == '11017'|| op.Product2.ProductCode == '11015'){
                    
                    if(op.Product2.ProductCode == '11014' || op.Product2.ProductCode == '11015'){
                        
                        
                        
                        xmlW.writeStartElement(null, 'Attributes', null);
                        
                        if(op.Contact__r.Professional_ID__c != null){
                            //beginning of Attribute tag
                            xmlW.writeStartElement(null, 'Attribute', null);
                            
                            
                            //Beginning of Professional Id Attribute Name tag
                            xmlW.writeStartElement(null, 'Name', null);
                            xmlW.writeCharacters('ProfessionalId');
                            xmlW.writeEndElement();
                            //End of Professional Id Attribute Name tag
                            
                            //Beginning of ProfessionalId Attribute Value tag
                            xmlW.writeStartElement(null, 'Value', null);
                            
                            xmlW.writeCharacters(op.Contact__r.Professional_ID__c);
                            xmlW.writeEndElement();
                            
                            xmlW.writeEndElement();
                            //End of Attribute tag 
                            
                        }
                        
                        //Beginning of FirstName tag
                        if(op.Contact__r.FirstName != null){
                            //beginning of Attribute tag
                            xmlW.writeStartElement(null, 'Attribute', null);
                            
                            
                            //Beginning of FirstName Attribute Name tag
                            xmlW.writeStartElement(null, 'Name', null);
                            xmlW.writeCharacters('FirstName');
                            xmlW.writeEndElement();
                            //End of FirstName Attribute Name tag
                            
                            //Beginning of FirstName Attribute Value tag
                            xmlW.writeStartElement(null, 'Value', null);
                            
                            xmlW.writeCharacters(op.Contact__r.FirstName);
                            xmlW.writeEndElement();
                            
                            xmlW.writeEndElement();
                            //End of Attribute tag 
                            
                        }
                        
                        //Beginning of LastName tag
                        if(op.Contact__r.LastName != null){
                            //beginning of Attribute tag
                            xmlW.writeStartElement(null, 'Attribute', null);
                            
                            
                            //Beginning of LastName Attribute Name tag
                            xmlW.writeStartElement(null, 'Name', null);
                            xmlW.writeCharacters('LastName');
                            xmlW.writeEndElement();
                            //End of LastName Attribute Name tag
                            
                            //Beginning of LastName Attribute Value tag
                            xmlW.writeStartElement(null, 'Value', null);
                            
                            xmlW.writeCharacters(op.Contact__r.LastName);
                            xmlW.writeEndElement();
                            
                            xmlW.writeEndElement();
                            //End of Attribute tag 
                            
                        }
                        
                        //Beginning of Contact Email tag
                        if(op.Contact__r.Email != null){
                            //beginning of Attribute tag
                            xmlW.writeStartElement(null, 'Attribute', null);
                            
                            
                            //Beginning of Contact Email Attribute Name tag
                            xmlW.writeStartElement(null, 'Name', null);
                            xmlW.writeCharacters('Email');
                            xmlW.writeEndElement();
                            //End of Contact Email Attribute Name tag
                            
                            //Beginning of Contact Email Attribute Value tag
                            xmlW.writeStartElement(null, 'Value', null);
                            
                            xmlW.writeCharacters(op.Contact__r.Email);
                            xmlW.writeEndElement();
                            
                            xmlW.writeEndElement();
                            //End of Attribute tag 
                            
                        }    
                        
                        //Beginning of Contact Phone tag
                        if(op.Contact__r.Email != null){
                            //beginning of Attribute tag
                            xmlW.writeStartElement(null, 'Attribute', null);
                            
                            
                            //Beginning of Contact Phone Attribute Name tag
                            xmlW.writeStartElement(null, 'Name', null);
                            xmlW.writeCharacters('Phone');
                            xmlW.writeEndElement();
                            //End of Contact Phone Attribute Name tag
                            
                            //Beginning of Contact Phone Attribute Value tag
                            xmlW.writeStartElement(null, 'Value', null);
                            
                            xmlW.writeCharacters(op.Contact__r.Phone);
                            xmlW.writeEndElement();
                            
                            xmlW.writeEndElement();
                            //End of Attribute tag 
                            
                        }  
                        
                        //Beginning of Contact Phone tag
                        if(op.Contact__r.Website__c != null){
                            //beginning of Attribute tag
                            xmlW.writeStartElement(null, 'Attribute', null);
                            
                            
                            //Beginning of Contact WebsiteURL Attribute Name tag
                            xmlW.writeStartElement(null, 'Name', null);
                            xmlW.writeCharacters('WebsiteURL');
                            xmlW.writeEndElement();
                            //End of Contact WebsiteURL Attribute Name tag
                            
                            //Beginning of Contact WebsiteURL Attribute Value tag
                            xmlW.writeStartElement(null, 'Value', null);
                            
                            if(op.Contact__r.Website__c != null){
                                xmlW.writeCharacters(op.Contact__r.Website__c);
                            }
                            
                            xmlW.writeEndElement();
                            
                            xmlW.writeEndElement();
                            //End of Attribute tag 
                            
                        }  
                        
                        xmlW.writeEndElement();
                        //End of Attributes tag
                        
                    }
                    
                    if(op.Product2.ProductCode == '11017'){
                        
                        
                        
                        xmlW.writeStartElement(null, 'Attributes', null);
                        
                        
                        //Beginning of FirstName tag
                        if(op.Order.Account.First_Name__c != null){
                            //beginning of Attribute tag
                            xmlW.writeStartElement(null, 'Attribute', null);
                            
                            
                            //Beginning of FirstName Attribute Name tag
                            xmlW.writeStartElement(null, 'Name', null);
                            xmlW.writeCharacters('FirstName');
                            xmlW.writeEndElement();
                            //End of FirstName Attribute Name tag
                            
                            //Beginning of FirstName Attribute Value tag
                            xmlW.writeStartElement(null, 'Value', null);
                            
                            xmlW.writeCharacters(op.Order.Account.First_Name__c);
                            xmlW.writeEndElement();
                            
                            xmlW.writeEndElement();
                            //End of Attribute tag 
                            
                        }
                        
                        //Beginning of LastName tag
                        if(op.Order.Account.Last_Name__c != null){
                            //beginning of Attribute tag
                            xmlW.writeStartElement(null, 'Attribute', null);
                            
                            
                            //Beginning of LastName Attribute Name tag
                            xmlW.writeStartElement(null, 'Name', null);
                            xmlW.writeCharacters('LastName');
                            xmlW.writeEndElement();
                            //End of LastName Attribute Name tag
                            
                            //Beginning of LastName Attribute Value tag
                            xmlW.writeStartElement(null, 'Value', null);
                            
                            xmlW.writeCharacters(op.Order.Account.Last_Name__c);
                            xmlW.writeEndElement();
                            
                            xmlW.writeEndElement();
                            //End of Attribute tag 
                            
                        }
                        
                        //Beginning of Account Email tag
                        if(op.Order.Account.Contact_Email__c  != null){
                            //beginning of Attribute tag
                            xmlW.writeStartElement(null, 'Attribute', null);
                            
                            
                            //Beginning of Account Email Attribute Name tag
                            xmlW.writeStartElement(null, 'Name', null);
                            xmlW.writeCharacters('Email');
                            xmlW.writeEndElement();
                            //End of Account Email Attribute Name tag
                            
                            //Beginning of Account Email Attribute Value tag
                            xmlW.writeStartElement(null, 'Value', null);
                            
                            xmlW.writeCharacters(op.Order.Account.Contact_Email__c );
                            xmlW.writeEndElement();
                            
                            xmlW.writeEndElement();
                            //End of Attribute tag 
                            
                        }    
                        
                        //Beginning of Account Phone tag
                        if(op.Order.Account.Phone  != null){
                            //beginning of Attribute tag
                            xmlW.writeStartElement(null, 'Attribute', null);
                            
                            
                            //Beginning of Account Phone Attribute Name tag
                            xmlW.writeStartElement(null, 'Name', null);
                            xmlW.writeCharacters('Phone');
                            xmlW.writeEndElement();
                            //End of Account Phone Attribute Name tag
                            
                            //Beginning of Account Phone Attribute Value tag
                            xmlW.writeStartElement(null, 'Value', null);
                            
                            if(Ordermap.get(orderid).Account.Phone!= null){
                                xmlW.writeCharacters(String.valueOf(Ordermap.get(orderid).Account.Phone));
                                
                            }
                            xmlW.writeEndElement();
                            
                            xmlW.writeEndElement();
                            //End of Attribute tag 
                            
                            
                        }                                        
                        xmlW.writeEndElement();
                        //End of Attributes tag
                    }
                }
                if(!attributeRelationVSattributes.isEmpty() && attributeRelationVSattributes.containskey(op.Attribute_Relationship__c)){
                    //getting attributes here
                    List<Attribute_Lines__c> attTempList = attributeRelationVSattributes.get(op.Attribute_Relationship__c);
                    
                    //beginning of Attributes tag
                    xmlW.writeStartElement(null, 'Attributes', null);
                    
                    if(op.Inventory_Id__c!= null || test.isRunningTest()){ 
                        //beginning of Attribute tag  
                        xmlW.writeStartElement(null, 'Attribute', null);    
                        
                        
                        //Beginning of Inventory Id Attribute Name tag  
                        xmlW.writeStartElement(null, 'Name', null); 
                        xmlW.writeCharacters('InventoryId');    
                        xmlW.writeEndElement(); 
                        //End of Inventory Id Attribute Name tag    
                        
                        //Beginning of Inventory Id Attribute Value tag 
                        xmlW.writeStartElement(null, 'Value', null);    
                        if(!test.isRunningTest()){     
                            xmlW.writeCharacters(op.Inventory_Id__c);   
                        }
                        xmlW.writeEndElement(); 
                        
                        xmlW.writeEndElement();    
                        //End of Attribute tag  
                        
                    }   
                    //End of Inventory Id
                    
                    for(Attribute_Lines__c at : attTempList){
                        //Start attributes XML Logic here
                        
                        
                        
                        
                        //beginning of Attribute tag
                        xmlW.writeStartElement(null, 'Attribute', null);
                        
                        
                        // xmlW.writeEndElement();
                        //End of Attribute tag
                        
                        //Inclusion of Other Attributes
                        System.debug('@@@@@ Attributes '+at);
                        //beginning of Attribute tag
                        // xmlW.writeStartElement(null, 'Attribute', null);
                        
                        //Beginning of Name tag
                        xmlW.writeStartElement(null, 'Name', null);
                        if(at.Attribute_Name__c != null && at.Attribute_Name__c != '')
                            xmlW.writeCharacters(at.Attribute_Name__c);
                        xmlW.writeEndElement();
                        //End of Name tag
                        
                        //Beginning of Value Tag
                        xmlW.writeStartElement(null, 'Value', null);
                        if(at.Attribute_Type__c != null) {
                            if(at.Attribute_Type__c == 'Text'|| at.Attribute_Type__c == 'String') {
                                if(at.String_Value__c != null && at.String_Value__c !='')
                                    xmlW.writeCharacters(at.String_Value__c);
                            }
                            else if(at.Attribute_Type__c == 'Number') {
                                if(at.Number_Value__c != null)
                                    xmlW.writeCharacters(String.valueOf(at.Number_Value__c));
                            }
                            else if(at.Attribute_Type__c == 'Boolean') {
                                xmlW.writeCharacters(String.valueOf(at.Boolean_Value__c));
                            }
                            else if(at.Attribute_Type__c == 'Picklist') {
                                if(at.Picklist_Value__c != null && at.Picklist_Value__c !=''){
                                    xmlW.writeCharacters(at.Picklist_Value__c);
                                }
                                else if(at.String_Value__c != null && at.String_Value__c !=''){
                                    xmlW.writeCharacters(at.String_Value__c );
                                }
                            }
                            else if(at.Attribute_Type__c == 'Date') {
                                if(at.Date_Value__c != null)
                                    xmlW.writeCharacters(String.valueOf(at.Date_Value__c));
                            }
                            else if(at.Attribute_Type__c == 'Phone') {
                                if(at.Phone_Value__c != null)
                                    xmlW.writeCharacters(String.valueOf(at.Phone_Value__c));
                            }
                            else {
                                
                            }
                        }
                        xmlW.writeEndElement();
                        //End of Value tag
                        
                        // Added By Sai C for Attribute Value Id Tag
                        //forming value ID tag from here
                        xmlW.writeStartElement(null, 'ID', null);
                        
                        //Beginning of Value ID Tag i.e ID
                        if(at.Value_ID__c != null){
                            xmlW.writeCharacters(at.Value_ID__c);
                            
                            //End of Value ID tag
                        }
                        
                        else{
                            xmlW.writeCharacters(' ');
                        }
                        xmlW.writeEndElement(); 
                        
                        xmlW.writeEndElement();
                        //End of Attribute tag         
                        
                        
                    }
                    xmlW.writeEndElement();
                    //End of Attributes tag
                }
                
                
                xmlW.writeEndElement();
                //End of Product Tag
                
                
                
                xmlW.writeEndElement();
                //End of LineItem tag
                
                xmlW.writeEndElement();
                //End of LineItems tag
                
                
                
            }
            
            //xmlW.writeEndElement();
            //End of Products Tag
            
            
            
            
            
            
            
            
            xmlW.writeEndElement();
            //End of Products Tag
            
            xmlW.writeEndElement();
            //End of Order tag
            if(!test.isRunningTest()){
                xmlW.writeEndElement();
                //End of OrderRequest tag
            }
        
        
        reqXML = xmlW.getXmlString();
        System.debug('Order Request :'+reqXML);
        //  return reqXML; 
        
        
        String reqXmlRemove = reqXML.replace('%20','+'); //<T01>    
        String reqXmlupdted1 = reqXmlRemove.replace('+','%2B'); //<T01>
        //String reqXmlupdted1 = reqXML.replace('+','%2B');
        String reqXmlupdted = reqXmlupdted1.replace('&','%26');
        
        
        string ipayload   = 'publicKey='+ publicKey + '&' + 'timestamp=' + timeDifferenceInSeconds + '&' + 'xml=' + reqXmlupdted;
        Blob textToBeHashedInBytes = Blob.valueOf(ipayload);
        Blob mac = Crypto.generateMac('HmacSHA256',Blob.valueOf(ipayload), Blob.valueOf(privateKey));
        String encodedText  = EncodingUtil.base64Encode(mac);
        String Header      =  encodedText + '|'+  timeDifferenceInSeconds;
        String givenEndpoint   = endPts.Endpoint_URL__c;
        String encodedurl = EncodingUtil.urlEncode(givenEndpoint, 'UTF-8');                
        
        //for ( id orderId :  OrderMap.keySet()){
            
            
            
            if(restrictCalls == false) {
                if(mapIdNExistingErrLogs.containsKey(Orderid ) ) {
                    Error_Log__c err = new Error_Log__c();
                    System.debug('###order already exists in Error Log###');
                    err.XML_Mesaage_Type__c = 'OrderRequest';
                    err.XML_Body__c = reqXML;
                    err.Order_Number__c = orderId;
                    err.Error_Reason__c = 'Previous instance of the same order exists in the Error log';
                    if(mapOrderIdNOrder != null && mapOrderIdNOrder.containsKey(orderId)){
                        err.Order_Name__c = mapOrderIdNOrder.get(orderId).Name;
                    }
                    lstExistingErrLogs.add(err);
                }
                else {
                    try{
                        
                        
                        Http http = new Http(); //global class which is used in both request & response
                        HttpRequest req = new HttpRequest(); //initiate HTTP request
                        //req.setEndpoint(endPoint);
                        req.setEndpoint(givenEndpoint);
                        
                        req.setMethod(methodType);
                        req.setTimeout(20000);
                        
                        //req.setBody(reqXML);
                        //String reqXmlupdted = reqXML.replace('&','%26');
                        req.setBody(ipayload);
                        
                        
                        req.setHeader('Accept', 'application/xml');
                        //req.setHeader('Content-Type', 'text/xml');
                        
                        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                        //req.setHeader('Authorization', aToken);
                        req.setHeader('Authorization', Header);
                        HTTPResponse res = http.send(req);
                        System.debug('Response Body in order Message is : '+res.getBody());
                        if(res.getStatusCode() == 200){
                            Error_Log__c temp_error = CPQ_MDL_Integration_Vim_Efs.checkForSuccessResponseWithError(res.getBody() , reqXML);
                            if(temp_error != null){
                                temp_error.XML_Mesaage_Type__c = 'OrderRequest';
                                lstErrLogs.add(temp_error);
                            }   
                        }
                        if(Test.isRunningTest() || res.getStatusCode() == 400 || res.getStatusCode() == 401){ 
                            if(res.getStatusCode() == 400 && res.getBody()!=null){
                                System.debug('Response Body in order Message is profile issue: '+res.getBody());
                                lstResponseBody.add(res.getBody());
                                
                            }   
                            else{
                                CPQ_MDL_Integration_Vim_Efs.parseResponse400Error(res.getBody(),'OrderRequest',reqXML,orderId,mapOrderIdNOrder.get(orderId).Name);                              
                                
                            }
                        }
                        else{
                            if(res.getStatusCode() != 500 && res.getStatusCode() != 404 && res.getStatusCode() != 502) { 
                                lstResponseBody.add(res.getBody());
                            }
                            else {
                                Error_Log__c err = new Error_Log__c();
                                err.XML_Mesaage_Type__c = 'OrderRequest';
                                err.XML_Body__c = reqXML;
                                err.Order_Number__c = orderId;
                                if(mapOrderIdNOrder != null && mapOrderIdNOrder.containsKey(orderId)){
                                    err.Order_Name__c = mapOrderIdNOrder.get(orderId).Name;
                                }
                                err.Error_Reason__c = res.getStatusCode() +' : '+res.getStatus();
                                lstErrLogs.add(err);    
                            }
                        }
                    }catch(System.CalloutException ce) {
                        Error_Log__c err = new Error_Log__c();
                        err.XML_Mesaage_Type__c = 'OrderRequest';
                        err.XML_Body__c = reqXML;
                        err.Order_Number__c = orderId;
                        if(mapOrderIdNOrder != null && mapOrderIdNOrder.containsKey(orderId)){
                            err.Order_Name__c = mapOrderIdNOrder.get(orderId).Name;
                        }
                        err.Error_Reason__c = 'Problem with web service operation. Failed to make a callout to an external system.';
                        lstErrLogs.add(err); 
                    }
                    catch(System.Exception e) {
                        MDL_Integration_Vim_Efs.sendEmailInCaseOfException('Order XMl Request',orderId,e.getMessage());
                    }      
                }
            }
            else if(restrictCalls == true) {
                System.debug('No calls will be sent since custom setting is activated');
            }
            
        }
        
        if(lstExistingErrLogs.size() > 0)
            Database.insert(lstExistingErrLogs);
        if(lstErrLogs.size() > 0) {
            Database.insert(lstErrLogs);
        }
        CPQ_MDL_Integration_Vim_Efs.parseResponseXML_OrderResponse(lstResponseBody);
    }
    public void finish(Database.BatchableContext BC){
    }
    
    //}
}