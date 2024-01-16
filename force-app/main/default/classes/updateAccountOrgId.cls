// author         : akash
// description    : this class builts with rest api xml
//                  when other systems hits this url it updates account records with orgId when request body 
//                   httpresponsecode contains 200
//                   else creates a case


@RestResource(urlMapping='/updateAccountwithOrgId/*') 
global class updateAccountOrgId{
    
    @HttpPatch
    global static void doPatch(){  
 
        //Returns the RestRequest object for our Apex REST method.  
        RestRequest request = RestContext.request;  
        //Returns the RestResponse for our Apex REST method.  
        RestResponse response = RestContext.response;  
        //Access the request body with input data coming in the XML format  
        String XMLRequestBody = request.requestBody.toString().trim();
        
        system.debug('@@@@XMLRequestBody'+ XMLRequestBody);
        
        Dom.Document responsedom = new Dom.Document();
        responsedom.load(XMLRequestBody);
        dom.Xmlnode res       = responsedom.getRootElement();
        String respCode       = res.getChildElement('HttpResponseCode', null).getText();
        String requestId       = res.getChildElement('RequestId', null).getText();
        String customerNumber = res.getChildElement('CustomerNumber', null).getText();
        String code           = res.getChildElement('Message',null).getChildElement('Code', null).getText();
        //String Text           = res.getChildElement('Code', null).getText();
        
        List<account> acc = new List<account>();
        acc = [select id, Name,
                          Org_Id__c,MH_Cust_Number__c
                          from account 
                           where MH_Cust_Number__c =: customerNumber 
                           LIMIT 1];
      
        if((respCode == '200') ) {
            case cs;
             account acc1 = new account();
            if(acc != null && acc.size() > 0){
               
                acc1 = acc[0];
                //String orgidfromExtract = res.getChildElement('OrgId', null).getText();
                //system.debug('@@@@orgid'+orgidfromExtract);
                if(acc1.Org_Id__c == null || acc1.Org_Id__c == ''){
                    if(res.getChildElement('OrgId', null) != null){
                        system.debug('@@@@orgId'+ res.getChildElement('OrgId', null).getText());
                        acc1.Org_Id__c = res.getChildElement('OrgId', null).getText();
                    }
                    

                }
                If (Code != '200'){
                    cs = new case();
                    cs= createCase(acc,res);
                    
                }
                
            }
            
            try{
                
                update acc1;
                if(cs!= null)   
                {
                    cs.RequestId__c = requestId;
                    insert cs;
                }
                
            }
            catch(exception e){
                system.debug('exception'+ e);
            }
        }
        
        
        else{
            boolean caseCreated = false;
            //checking case for this account already created or not
            List<case> existingcase = new List<case>();
            if(acc != null && !acc.isEmpty()){
                // existingcase   =    [select id, AccountId,  
                //                        Subject,Priority
                //                        from case 
                //                        where  AccountId = : acc[0].Id 
                //                              and Subject = 'Generate OrgId error'
                //                               LIMIT 1];
                 // create a case
                case cs = new case();
                //if(existingcase.isEmpty()){
               
                //    cs.Subject  = 'Generate OrgId error';
                //    cs.Priority = 'High';
                //    cs.OwnerId  = system.Label.OrgId_failed_case_queue;
                //    cs.Description = 'Can not Update OrgId on Account';
                //     cs.Status = 'Closed';
                //    cs.AccountId = acc[0].id;
                //    insert cs;
                //}
            
                if(respCode == '502'){
                    List<Error_Log__c> existingerrorLog = new List<Error_Log__c>();
                    //querying to check existing error log
                    //if error log is present don't create any case
                    caseCreated = true;
                    existingerrorLog = [select id,Account_Name__c,Case__c,
                                               XML_Mesaage_Type__c,XML_Body__c
                                               From Error_Log__c
                                               where Account_Name__c =:acc[0].id];
                
                    if(!existingerrorLog.isEmpty() && existingerrorLog.size() > 0){
                        existingerrorLog[0].Re_process_date_time__c = system.now();
                    }
                    else{
                      
                        cs= createCase(acc,res);
                        insert cs;
                        
                         //creating error log
                        Error_Log__c err = new Error_Log__c();
                        err.Account_Name__c = acc[0].id;
                        err.XML_Mesaage_Type__c = 'Update OrgId';
                        err.XML_Body__c = XMLRequestBody;
                        err.Case__c     = cs.id;
                        String errorReason = res.getChildElement('Message',null).getChildElement('Code', null).getText() + ':'+
                                                   res.getChildElement('Message',null).getChildElement('Text', null).getText();
                        err.Error_Reason__c = errorReason;
                        existingerrorLog.add(err);
                    }
                    
                    upsert existingerrorLog;
                }
                
                if(!caseCreated){
                     cs= createCase(acc,res);
                     insert cs;
                    system.debug('@@@@case created'+cs);
                }
                
                
                //if(existingcase != null && !existingcase.isEmpty()){
                //    err.Case__c     = existingcase[0].id;
                   
               // }
               // else{
                    // err.Case__c     = cs.id;
               // }
                
               
                //insert err;
                }
           
        }

    }
 
    public static case createCase(List<account> acc,dom.Xmlnode res){
        
       /* Map<String,Id> queNameVsId = new Map<String,Id>();
        List<Group> queuesList     = [select id, Name
                                             from Group
                                             where Type='Queue'];
        for(Group gr : queuesList){
             queNameVsId.put(gr.Name,gr.id);   
        }*/
        
        String errorReason = res.getChildElement('Message',null).getChildElement('Code', null).getText() + ':'+
                                                   res.getChildElement('Message',null).getChildElement('Text', null).getText();
        String requestId       = res.getChildElement('RequestId', null).getText();
        string orderName       = res.getChildElement('OrderNumber', null).getText();
        case cs = new case();
        
        
        if(errorReason.contains('STUB_ERR_001')){ 
            //cs.OwnerId  = queNameVsId.get('Fulfillment Operations'); 
            cs.Subject  = 'NES Stub Creation Error';
            cs.Status = 'New';
            cs.Priority = 'Medium';
            cs.origin = 'OrderUpdate';
            cs.Area__c = 'Order Update';
            cs.Sub_Area__c = 'Account Error';
        }
        //else if(errorReason.contains('STUB_ERR_001')){
        //    cs.OwnerId  = queNameVsId.get('Data Governor Queue');
        else if(errorReason.contains('STUB_ERR_002') || errorReason.contains('STUB_ERR_003') ){
                //cs.OwnerId  = queNameVsId.get('MH System Admin');
                cs.Subject  = 'NES Stub Creation Error';
                cs.status = 'Close';
                cs.Priority = 'Medium';
                cs.origin = 'OrderUpdate';
                cs.Area__c = 'Order Update';
                cs.Sub_Area__c = 'Account Error';
        }
        else if(errorReason.contains('STUB_ERR_004')){
                //cs.OwnerId  = queNameVsId.get('Data Governor Queue');
                cs.Subject  = 'NES Stub Creation Error';
                cs.Status = 'New';
                cs.Priority = 'Medium';
                cs.origin = 'OrderUpdate';
                cs.Area__c = 'Order Update';
                cs.Sub_Area__c = 'Account Error';
        }
        else if(errorReason.contains('400')){
             //cs.OwnerId  = queNameVsId.get('IT Queue');
             cs.Subject  = '400 : Bad Request';
             cs.status = 'New';
             cs.Priority = 'High';
        }
        else if(errorReason.contains('500')){
             //cs.OwnerId  = queNameVsId.get('IT Queue');
             cs.Subject  = 'Order Request Error';
             cs.Status = 'New';
             cs.Priority = 'Medium';
             cs.origin = 'OrderUpdate';
             cs.Area__c = 'Order Update';
             cs.Sub_Area__c = 'Account Error';
        }

        else{
            //cs.OwnerId  = queNameVsId.get('Fulfillment Operations');
            cs.Subject  = 'NES Stub Creation Error';
            cs.Status = 'New';
            cs.Priority = 'Medium';
            cs.origin = 'OrderUpdate';
            cs.Area__c = 'Order Update';
            cs.Sub_Area__c = 'Account Error';
        } 
        
        cs.Description__c = errorReason;
        //cs.Description   = errorReason;
        cs.AccountId = acc[0].id;
        cs.RequestId__c = requestId;
        cs.Order_Name__c = orderName;
        cs.origin = 'OrderUpdate';
        

        return cs;

    }
}