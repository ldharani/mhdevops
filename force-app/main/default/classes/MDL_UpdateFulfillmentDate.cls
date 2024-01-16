/* 
* Class Name: quoteHandler    
* Test Class:  
* Description: This class is responsible to create and Activate Order and create Contract
* Developed By:  Lister
* Modification History : Created on Sep 15,2020
*  
Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
               SC          09/10/2023   John Mattheson  <T01>   Professional Id change

************************************************************************************************************************

*/ 
 
@RestResource(urlMapping='/FulfillmentMessage/*') 
    global with sharing class MDL_UpdateFulfillmentDate{
        
        @HttpPost
           global static String doPost() {
                
                RestRequest req     = RestContext.request;
                String retResp ;
                String xmlString;
                system.debug('---- > ' + req.headers);
                system.debug('---- > ' + req.requestBody.toString());
                system.debug('@@@@ req params'+ req.params);
                if (req.params.containsKey('FulfillmentMessageRequest')){ 
                   system.debug('---- > if');
                  xmlString = req.params.get('FulfillmentMessageRequest');
                   system.debug('---- > if'+xmlString );
                   retResp = updateFulfillmentDate(xmlString);
                }else {
                    system.debug('---- > else ');
                    xmlString = req.requestBody.toString().trim(); 
                    system.debug('@@@@@ request Body ' + xmlString);
                    retResp = updateFulfillmentDate(xmlString);
                    //system.debug('---- > ' + xmlString);
               }
                return retResp;                     
          }
          
          public static String updateFulfillmentDate(String xmlString) {
                
                system.debug(' ??? ' + xmlString);
                String reqId;                
                String OrderNumber ; 
                String LineItemId ; 
                String SIN; 
                Dom.Document response = new Dom.Document();
                String OrderProductID; 
                String returnResp;
                String errormsg;
                String custNo ;
                Date fdate;
                String errortext;
                String caseOrigin = ' ';
                String area      =' ';
                string subArea   = ' ';
                string code;
                String ProfessionalId; //<T01>
                List<String> listofErrorText = new List<String>();
                response.load(xmlString);
                system.debug ('@@@@@@updateFulfillmentDate'+ xmlString);
                dom.Xmlnode res = response.getRootElement();
                //system.debug ('updateFulfillmentDate'+ res );
                
                if(xmlString.contains('CustomerNumber')){
                    //system.debug('    ' + res.getChildElement('CustomerNumber', null) );
                    system.debug('@@@@@ customer Number'+ res.getChildElement('CustomerNumber', null).getText());
                    custNo = res.getChildElement('CustomerNumber', null).getText();
                }
                
                if(xmlString.contains('OrderNumber')){
                    OrderNumber = res.getChildElement('OrderNumber', null).getText();
                }
                system.debug(' xxx  ' + res.getChildElement('RequestId', null) );
                if(xmlString.contains('LineItem') && xmlString.contains('LineItemId')){
                    try{
                    /*if(res.getChildElement('LineItem', null).getChildElement('FulfillmentDate',null).getText() != null && 
                        res.getChildElement('LineItem', null).getChildElement('FulfillmentDate',null).getText() != ''){*/
                        system.debug('date present ' + res.getChildElement('LineItem', null).getText());
                        
                            List<String> splitOrderProductId = new List<String>();
                            List<String> splitSIN = new List<String>();
                            String MHCustNo ;
                            String OrderPrCode;    
                            String OrderRPCId;
                            String fulfillmentId;
                            OrderProductID = res.getChildElement('LineItem', null).getChildElement('LineItemId',null).getText();
                            
                            if(xmlString.contains('SubscriptionIdentificationNumber')){
                                system.debug('has sin');
                                SIN = res.getChildElement('LineItem', null).getChildElement('SubscriptionIdentificationNumber', null).getText();
                                system.debug('this is sin --  ' + SIN);
                                /*if(SIN.contains('.')){
                                    String tempSIN = SIN.replace('.', ' ');
                                    system.debug('this is sin replaced--  ' + SIN);
                                    splitSIN = tempSIN.split(' ');
                                    system.debug('this is after split ' + splitSIN);
                                    system.debug('how ??/ ' + SIN.split('.'));
                                    if(splitSIN.size() == 3){
                                        MHCustNo = splitSIN[0];
                                        OrderPrCode = splitSIN[1];
                                        OrderRPCId = splitSIN[2];
                                    }
                                }*/ 
                            }
                            if(xmlString.contains('RequestId')){
                                reqId = res.getChildElement('RequestId', null).getText();
                            }
                            if(xmlString.contains('CustomerNumber')){
                            system.debug(' Customer Number  ' + res.getChildElement('CustomerNumber', null) );
                                custNo = res.getChildElement('CustomerNumber', null).getText();
                            }
                        
                            if(xmlString.contains('ProfessionalId')){  //<T01>
                                                                

                                ProfessionalId = res.getChildElement('LineItem', null).getChildElement('ProfessionalId', null).getText();
                                
                                system.debug ('Professional id '+ ProfessionalId );
                            }
                             //<T01>
                             
                            if(xmlString.contains('OrderNumber')){
                                OrderNumber = res.getChildElement('OrderNumber', null).getText();
                            }
                            if(xmlString.contains('FulfillmentID')){
                                system.debug('@@@ in if FulfillmentID');
                                fulfillmentId = res.getChildElement('LineItem', null).getChildElement('FulfillmentID',null).getText();
                                //fulfillmentId = res.getChildElement('FulfillmentID', null).getText();
                                system.debug('@@@FulfillmentID'+fulfillmentId);
                            }
                            //system.debug(MHCustNo + '--- '  + OrderPrCode + ' ---- ' + SeqCode);
                            /*if(OrderProductID.contains('-')){
                                splitOrderProductId = OrderProductID.split('-');
                            }*/
                            String FulfillmentDate = res.getChildElement('LineItem', null).getChildElement('FulfillmentDate',null).getText();
                            System.debug('CAME');   
                            if((FulfillmentDate != null && FulfillmentDate != '') || (ProfessionalId != null && ProfessionalId != '') ){
                               
                               System.debug('In Professional Id Update ');
                               
                               if(FulfillmentDate != null && FulfillmentDate != '') {  //<T01>
                                    
                                    fdate = date.parse(FulfillmentDate);    
                                }
                                
                                 //<T01>
                                 
                                List<OrderItem> listorderRPCWithSH = new List<OrderItem>(); 
                                 
                                List<OrderItem> listorderProd = new List<OrderItem>(); 
                                
                                List<Contact> ContactIds = new List<Contact>(); 
                                
                                OrderItem orderRPC = new OrderItem();
                                
                                listorderProd = [Select Id , Fulfillment_date__c,
                                                                     Order.Account.MH_Cust_Number__c ,Status__c,Renew_Rebase_Truncate_Date__c,
                                                                     ServiceDate,Contact__c, Chat_ID__c,EndDate
                                                                     from OrderItem
                                                                     where SIN__c = : SIN 
                                                                     //and ( Order.RecordTypeId  = 0124D0000000iL6' or RecordTypeid.DeveloperName = '0124D0000000iL7')                                                                    
                                                                     ];
                                If(ProfessionalId != null && ProfessionalId != ''){  //<T01>
                                    
                                    ContactIds = [Select Id ,Professional_ID__c From Contact Where Professional_ID__c = : ProfessionalId  
                                                                         
                                             ];
                                             
                                   System.debug('In Contact Ids '+ContactIds );           
                                } 
                                 //<T01>
                                              
                                System.debug('YYYYYY'+listorderProd );                                 
                                
                                                                                              
                                if(listorderProd .size()>0){
                                    if(listorderProd .size()>1){
                                        for(OrderItem orpc : listorderProd ){
                                            if(orpc.Status__c == 'Cancelled' && orpc.ServiceDate == null && orpc.EndDate== null) {
                                                errormsg = constructErrorResponse( reqId , 'Requested charge has been cancelled before its service began','233');       
                                                return errormsg;
                                            }
                                            else {
                                                System.debug('--------------'+orpc.Renew_Rebase_Truncate_Date__c );
                                                if(orpc.Renew_Rebase_Truncate_Date__c != null){
                                                    if(orpc.Fulfillment_date__c== null) {
                                                        orderRPC = orpc;
                                                        System.debug('%%%%%%%%%%%%'+orpc.Renew_Rebase_Truncate_Date__c + orderRPC.Status__c  + orderRPC);
                                                    }
                                                    else {
                                                        errormsg = constructErrorResponse(reqId, 'Requested SIN has already been fulfilled','231');
                                                        return errormsg;
                                                    }
                                                }
                                            }
                                        }                                       
                                    }
                                    else if(listorderProd .size()==1){
                                        if(listorderProd [0].Status__c == 'Cancelled' && listorderProd [0].ServiceDate == null && listorderProd [0].EndDate== null) {
                                                errormsg = constructErrorResponse( reqId , 'Requested charge has been cancelled before its service began','233');       
                                                return errormsg;
                                            }
                                        system.debug('Fulfillment_date__c :::' + listorderProd [0].Fulfillment_date__c);
                                        if(listorderProd [0].Fulfillment_date__c== null){                                       
                                            orderRPC = listorderProd [0];                          
                                        }
                                        
                                        if(listorderProd [0].Contact__c == null){                                       
                                            listorderProd [0].Contact__c = ContactIds [0].id ;  
                                            System.debug('Contact Update'+listorderProd [0].Contact__c );                        
                                        } 
                                        else {
                                            errormsg = constructErrorResponse(reqId, 'Requested SIN has already been fulfilled','231');
                                            return errormsg;
                                        }  
                                        
                                    }   
                                }
                                else{
                                    errormsg = constructErrorResponse( reqId , 'Requested SIN doesn\'t exist','230');
                                    return errormsg;
                                }
                                system.debug('orderRPC.Status__c ::' + orderRPC.Status__c  + orderRPC);
                                if(orderRPC.Status__c == 'Cancelled' && orderRPC.EndDate< Date.today()) {
                                     errormsg = constructErrorResponse( reqId , 'Requested SIN has been cancelled','232');       
                                     return errormsg;
                                } 
                                else if(orderRPC.Status__c == 'Truncated' && orderRPC.EndDate< Date.today()) {
                                     errormsg = constructErrorResponse( reqId , 'Requested SIN has been truncated','232');       
                                     return errormsg;
                                } 
                                else if(orderRPC.Status__c == 'Expired') {
                                     errormsg = constructErrorResponse( reqId , 'Requested SIN has been expired','232');       
                                     return errormsg;
                                }                                            
                                
                                
                                
                               
                                
                                 if(orderRPC != null){
                                    orderRPC.Fulfillment_date__c= fdate;
                                    orderRPC.Chat_ID__c = fulfillmentId;
                                    system.debug('@@@ in final update'+orderRPC.Chat_ID__c);
                                    
                                    Datetime now = Datetime.now();
                                    Datetime futureTime = now.addSeconds(3); // Add 3 seconds
                                    
                                    while (Datetime.now() < futureTime) {
                                          update orderRPC;
                                           
                                           
                                            }  
                                                    
                                     
                                    }   
                            
                                    
                            }
                         
                            /*if(xmlString.contains('LineItemId')){
                                LineItemId = res.getChildElement('LineItemId', null).getText();
                            }*/
                            
                            returnResp = constructSuccessResponse( reqId ,  custNo ,  OrderNumber ,  OrderProductID ,  SIN);
                            
                            
                                            
                    //}
                        if(xmlString.contains('Messages') && xmlString.contains('Message') && xmlString.contains('Text')){
                            DOM.xmlNode messages = res.getChildElement('LineItem', null).getChildElement('Messages',null);
                            System.debug('<<>>'+messages.getChildElements());                           
                            for(Dom.XMLNode text : messages.getChildElements()){
                                errortext ='';                              
                                system.debug(' @@@@@--- > test1 '  + text.getChildElement('Code',null));
                                system.debug(' @@@@--- > test2 '  + text.getChildElement('Message',null));
                                system.debug('@@@@@ --- > test3 '  + text.getChildElement('Text',null));
                                if(xmlString.contains('Code')){
                                    if(text.getChildElement('Code',null).getText()!= null && text.getChildElement('Code',null).getText()!= ''){
                                        errortext += text.getChildElement('Code',null).getText() + ' - '; 
                                    }
                                }
                                if(text.getChildElement('Text',null).getText()!= null && text.getChildElement('Text',null).getText()!= ''){                                
                                    errortext += text.getChildElement('Text',null).getText();                                                                 
                                }
                                if(text.getChildElement('CaseOrigin',null).getText()!= null && text.getChildElement('CaseOrigin',null).getText()!= ''){                                
                                    caseOrigin = text.getChildElement('CaseOrigin',null).getText();                                                                 
                                }
                                if(text.getChildElement('Area',null).getText()!= null && text.getChildElement('Area',null).getText()!= ''){                                
                                    area = text.getChildElement('Area',null).getText();                                                                 
                                }
                                if(text.getChildElement('SubArea',null).getText()!= null && text.getChildElement('SubArea',null).getText()!= ''){                                
                                    subArea = text.getChildElement('SubArea',null).getText();                                                                 
                                }
                                if(errorText!='' && errorText!=null){
                                    listofErrorText.add(errorText);   
                                    system.debug('@@@@listofErrorText'+listofErrorText);
                                }                            
                                                                  
                            }
                        }
                    }
                    catch(Exception e){
                      system.debug('@@@@@exception'+ e);
                        if(xmlString.contains('RequestId')){
                            reqId = res.getChildElement('RequestId', null).getText();
                            // added by Sai C
                            //code = res.getChildElement('code', null).getText();
                        }
                        
                        /*if(xmlString.contains('code')){
                           
                            code = res.getChildElement('code', null).getText();
                        }*/
                        
                        Integer startOfError;
                        Integer endOfError;
                        String errormessage;
                        String error;
                        if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                            startOfError = e.getMessage().indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION')+35;
                            endOfError = e.getMessage().indexOf(':',startOfError);
                            errormessage = e.getMessage().substring(startOfError,endOfError);
                            error = constructErrorResponse( reqId ,errormessage,'233');
                        }
                        else{
                            error = constructErrorResponse( reqId ,e.getMessage(),'233');
                        }                        
                        return error;
                    } 
                }
                   System.debug('aaaaaaa ' + listofErrorText.size() + ' ' + custNo );
                if(listofErrorText.size() > 0 && custNo != null && custNo != '') {
                    try{
                        createCase(listofErrorText , custNo, OrderNumber, SIN, reqId, caseOrigin, area, subArea);
                    }
                    catch(System.Exception se) {
                        returnResp = constructErrorResponse( reqId , 'Related Account/Order does not exist','233');
                    }       
                }        
                system.debug(' ????? ' + fdate);
                system.debug(' ?/ 123 ' + returnResp);
                return returnResp;
          } 
           
          
          public static String constructSuccessResponse(String reqId , String custNo , String OrderNumber , String LineItemId , String SIN){
            String ffResponse = '<FulfillmentMessageResponse>' +
            // request id which generated this response 
                                '<RequestId>' + reqId + '</RequestId>' +
            //<!-- 200 Ok  ... if all line items succeeded -->
                                '<HttpResponseCode>200</HttpResponseCode>' +                                   
                                '<CustomerNumber>'+ custNo +'</CustomerNumber>' + 
                                '<OrderNumber>'+ OrderNumber +'</OrderNumber>' + 
                                '<LineItem>' +                 
                                '<LineItemId>'+LineItemId+'</LineItemId>'+
                                '<SubscriptionIdentificationNumber>'+SIN+'</SubscriptionIdentificationNumber>'+         
            //<!-- messages is empty when no errors occurred for this line item -->
                                '<Messages>'+
                                    '<Message>'+
                                        '<QueueName>TBD</QueueName>'+
                                        '<Code>200</Code>' + 
                                        '<Text>SUCCESS</Text>'+
                                    '</Message> '+
                                '</Messages>'+
                                '</LineItem>'+
                                '</FulfillmentMessageResponse>';
            
            return ffResponse;                  
          }
          
          private static String constructErrorResponse(String reqId , String errorMsg,String respCode){
                String Code;
                
                /*if(errorMsg.contains('Requested SIN doesn\'t exist or SIN is already been fulfilled') ) {
                    Code = '<Code>Requested SIN doesn\'t exist or SIN is already been fulfilled</Code>';                    
                }
                else if(errorMsg.contains('Requested SIN has been cancelled (or) expired (or) truncated') ){
                    Code = '<Code>Requested SIN has been cancelled (or) expired (or) truncated</Code>'; 
                }
                else{
                    Code = '<Code>'+respCode+'</Code>';
                }*/
                Code = '<Code>'+respCode+'</Code>';
                
                
                String error = '<FulfillmentMessageResponse>'+
                                //<!-- request id which generated this response -->
                                '<RequestId>'+ reqId +'</RequestId>'+
                                '<HttpResponseCode>'+respCode+'</HttpResponseCode>'+
                                '<Messages>'+
                                    '<Message>'+
                                        '<QueueName>TBD</QueueName>'+
                                        Code + 
                                        '<Text>'+errorMsg+'</Text>'+
                                    '</Message> '+
                                '</Messages>'+
                            '</FulfillmentMessageResponse>';
                return error;           
          }
          
        public static void createCase(List<String>listofErrorText , String custNo, String OrderNumber, String SIN, string reqId, string caseOrigin, string area, string subArea){
            List<Case> lstCases = new List<Case>();
            system.debug('1111111111111 '+ custNo );
            Account acc = [Select Id,Name from Account where MH_Cust_Number__c =: custNo and (RecordType.DeveloperName = 'MH_Accounts' or RecordType.DeveloperName = 'Nolo_Account'or RecordType.DeveloperName = 'M_A_Atty_Account')];
            system.debug('2222222222222 '+ acc.Id + ' ' + OrderNumber);
            String filterorder = OrderNumber.leftPad(8, '0');
            //String filterorder  = OrderNumber.replaceFirst('^0+','');
            system.debug('3333333333333  ' + filterorder);
            
            Order order = [Select Id from order  where OrderNumber = :filterorder  and (RecordType.DeveloperName = 'MH_Order' or RecordType.DeveloperName = 'Nolo_Order' or RecordType.DeveloperName = 'M_A_Order') LIMIT 1];
            system.debug('4444444444444' + order);
            AssignmentRule AR;
            system.debug('5555555555555' + AR);
            Database.DMLOptions dmlOpts;
            system.debug('6666666666666' + order.Id + ' ' + AR);
            
            //Fetching the assignment rules on case
            for(AssignmentRule assignRule : [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1]){
                System.debug('7777777777777 ' + assignRule);
                AR = assignRule;
            }
            System.debug('8888888888888 ' + AR);
            
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            dmlOpts = new Database.DMLOptions();
            
            System.debug('99999999999999 ' + AR);
            if(AR!=null)
                System.debug('1010101010101 ' + AR);
            dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
            //Group queue = [select Id from Group where Type='Queue' and DeveloperName ='Editorial' LIMIT 1];
            System.debug('11010110110101 ' + listofErrorText);
            for(String errtxt : listofErrorText) {
                System.debug('1212121212121 ' + errtxt);
                Case c = new Case();
                c.Status = 'New';
                c.Priority = 'High';
                system.debug('13131313131313 ' + reqId.contains('E_OrdUpdtMail_Err') + ' ' + reqId);
                if(reqId.contains('E_OrdUpdtMail_Err')){
                    system.debug('1414141414141 ');
                    c.Subject = 'View Website Error';
                }
                else{
                    system.debug('1515151515151 ');
                    c.Subject = 'Fulfillment Request Error';
                }
                //c.Area__c = 'Editorial';
                //c.Sub_Area__c = 'Listing Inquiry';
                //c.OwnerId = queue.Id;
                system.debug('16161616161616 ');
                c.Origin      = caseOrigin; 
                c.Area__c     = area;
                c.Sub_Area__c = subArea;
                
                c.Description = errtxt + '\r\n';
                c.Description += 'SIN Number : ' + SIN;
                c.AccountId = acc.Id;
                c.Order_Name__c = OrderNumber;
                system.debug('171717171717171  ' + order);
                if(order!=null)
                    system.debug('1818181818181  ');
                c.Order__c= order.Id;
                c.setOptions(dmlOpts);
                //c.Requested_SIN__c = SIN;
                lstCases.add(c);
            }
            system.debug('19191919191  ' + lstCases.size() + ' ' + lstCases);
            if(lstCases.size() > 0)
                system.debug('2020202020220  ' );
                
                    Datetime now = Datetime.now();
                    Datetime futureTime = now.addSeconds(60); // Add 60 seconds
                    
                   // while (Datetime.now() < futureTime) { removing this while loop as discussion with Sai C since the test class is failing
                        system.debug('-- lstCases ---' + lstCases);
                           Database.insert(lstCases); 
                            //}       
        }
    }