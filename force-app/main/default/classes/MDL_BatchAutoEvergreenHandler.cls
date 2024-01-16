public class MDL_BatchAutoEvergreenHandler {
    
     public static void  OppsClosedLostWhenOppIsClosedWon(List<invoiceit_s__Job__c> lstOrders) {
        Set<Id> setRelatedOrderIds = new Set<Id>();
        List<Opportunity> lstOppToUpdate = new List<Opportunity>();
        Set<Id> oppIds        = new Set<Id>();
        for(invoiceit_s__Job__c order : lstOrders){
            if(order.Name != null){
                setRelatedOrderIds.add(order.id);
            }
        }
        for(Opportunity opp : [Select Id, StageName, Reason_Won_Lost__c,CloseDate,Ngage_Upsell_Order__c
                               from Opportunity 
                               where Created_From_Order__c in : setRelatedOrderIds 
                                and StageName!='QA Review'and StageName!='Closed Lost' and StageName!='Declined']) {
            if(opp.StageName!='Closed Won'){
                opp.StageName = 'Closed Lost';
                opp.Reason_Won_Lost__c = 'Duplicate';
                opp.CloseDate = system.Today();
                opp.Parent_Stage_Change__c = system.now(); // akash:26/03
                oppIds.add(opp.id);
                lstOppToUpdate.add(opp);
            }               
        }
        
        for(Opportunity ngageopp : [Select Id, StageName, Reason_Won_Lost__c,CloseDate ,Ngage_Upsell_Order__c,Closed_lost_from_code__c,
                                            Parent_Opportunity__r.Created_From_Order__c,Parent_Opportunity__r.StageName,
                                            Parent_Opportunity__c
                                    from Opportunity 
                                    where (Ngage_Upsell_Order__c in : setRelatedOrderIds 
                                           OR Parent_Opportunity__r.Created_From_Order__c in : setRelatedOrderIds)
                                    //and Parent_Opportunity__c = NULL
                                    and StageName!='QA Review'and StageName!='Closed Lost' and StageName!='Declined']) {
            if ( ( ngageopp.Parent_Opportunity__c ==NULL && ngageopp.Ngage_Upsell_Order__c != NULL && setRelatedOrderIds.contains(ngageopp.Ngage_Upsell_Order__c))
                   || (ngageopp.Parent_Opportunity__c != NULL && ngageopp.Parent_Opportunity__r.StageName!='QA Review'&& ngageopp.Parent_Opportunity__r.StageName != 'Closed won' && ngageopp.Parent_Opportunity__r.Created_From_Order__c != NULL 
                          && setRelatedOrderIds.contains(ngageopp.Parent_Opportunity__r.Created_From_Order__c)) ){
                     if(ngageopp.StageName!='Closed Won' ){
                        ngageopp.StageName = 'Closed Lost';
                        ngageopp.Closed_lost_from_code__c = True;
                        ngageopp.Reason_Won_Lost__c = 'Duplicate';
                        ngageopp.CloseDate = system.Today();
                        //  opp.Parent_Stage_Change__c = system.now(); // akash:26/03
                        oppIds.add(ngageopp.id);
                        lstOppToUpdate.add(ngageopp);
                    }                       
              }                         
                       
        }
        
      
        System.debug('lstOppToUpdate::'+lstOppToUpdate);
        if(lstOppToUpdate.size()>0){
             MDL_trgHandlerforOppRenew_Rebase.voidingenvelopefrombatch(oppIds);
            releaseOrderProductInventoriesBatch(oppIds);
            Database.update(lstOppToUpdate);
            System.debug('===== calling void docusign method on opty update'+oppIds);
            //voidenvelopefromevergreenbatch(oppIds);
           // MDL_trgHandlerforOppRenew_Rebase.voidingenvelopefrombatch(oppIds); 
            system.debug('$$$$$$From ORder release inventory calling');
            //releaseOrderProductInventoriesBatch(oppIds);
        }
    }
    
     public static void releaseOrderProductInventoriesBatch(Set<Id> oppIds){
        Set<Id> setOppProdIds                 = new Set<Id>();
        Map<Id,String> mapOppProdNInventoryId = new Map<Id,String>();
        List<invoiceit_crmx__Opportunity_Product__c > listOppProdsToUpdate = new List<invoiceit_crmx__Opportunity_Product__c >();
        
        User u = [select Id, username from User where Id = :UserInfo.getUserId()];
         for(invoiceit_crmx__Opportunity_Product__c oppProd :[select Id,InventoryId__c,Product_SIN__c,invoiceit_crmx__Opportunity__r.Closed_lost_from_Order__c from invoiceit_crmx__Opportunity_Product__c where invoiceit_crmx__Opportunity__c in :oppIds and IsInventoried__c='true']){
                  system.debug('$$$$$$ From oppProd '+oppIds );   
                if((oppProd.Product_SIN__c==null || oppProd.Product_SIN__c=='') || oppProd.invoiceit_crmx__Opportunity__r.Closed_lost_from_Order__c ){
                    if(oppProd.InventoryId__c!=null && oppProd.InventoryId__c!=''){
                    
                    
                        mapOppProdNInventoryId.put(oppProd.Id,oppProd.InventoryId__c);
                        //setOppProdIds.add(oppProd.Id);
                        oppProd.InventoryId__c = '';
                        listOppProdsToUpdate.add(oppProd);
                        if((oppProd.Product_SIN__c==null || oppProd.Product_SIN__c=='') || (oppProd.invoiceit_crmx__Opportunity__r.Closed_lost_from_Order__c && (oppProd.Product_SIN__c==null || oppProd.Product_SIN__c==''))){
                            setOppProdIds.add(oppProd.Id);
                        }
                    }
                }       
            }
        
        if(setOppProdIds.size()>0  ){ 
            //if(!Test.isRunningTest() ){
               // MDL_Integration_Vim_Efs.releaseInventoryRequest(setOppProdIds,u.Username,mapOppProdNInventoryId);
               // 
               // added by sai: 18/5
                ReleaseInventoryCallout(oppIds,setOppProdIds,u.Username,mapOppProdNInventoryId);
           // }
           
        }

        if(listOppProdsToUpdate.size()>0){
            Database.update(listOppProdsToUpdate);
        }
        
        /*if(oppIds.size()>0){
            
            System.debug('===== calling void docusign method on opty update'+oppIds);
            //voidenvelopefromevergreenbatch(oppIds);
            MDL_trgHandlerforOppRenew_Rebase.voidingenvelopefrombatch(oppIds); 
            
        }*/
    }
    
    // added for Docsign Void process from Autoevergreen batch job
    /* public static void voidenvelopefromevergreenbatch(Set<Id> OppIds){
        System.debug('===========Inside voidenvelopefromevergreenbatch Method==============');
        for(dsfs__DocuSign_Status__c docustat : [Select id, name,dsfs__DocuSign_Envelope_ID__c,dsfs__Envelope_Status__c From dsfs__DocuSign_Status__c where dsfs__Envelope_Status__c!= 'Completed' AND dsfs__Envelope_Status__c!= 'Voided' AND dsfs__Opportunity__c in :OppIds]){
                DocusignVoidApi voi = new DocusignVoidApi();
                voi.voidEnvelope(docustat.dsfs__DocuSign_Envelope_ID__c,'Void APIs');
            }
     }
    
    */
    
     public static void ReleaseInventoryCallout(Set<Id> oppIdsque,Set<Id> setOppProdIdsque, String userNameque,Map<Id,String> mapOpptyProdNInventoryIdque) {
       String reqXML ='';
        String uName;
        uName = userNameque;
        List<String> lstResponseBody = new List<String>();
        List<Error_Log__c> lstErrLogs = new List<Error_Log__c>();
        //end points is stored in a custom setting - get values from there and use it here
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('ReleaseInventory');
        String endPoint = String.valueOf(endPts.Endpoint_URL__c);
        System.debug('**'+endPoint);
        String methodType = endPts.MethodType__c;
        System.debug('@@@@@set passed is %% : '+setOppProdIdsque);
        //get custom setting value for restricting Integration calls //if true , do not send in calls // if false send in calls normally
        
        Restrict_Integration_Calls__c rCalls = Restrict_Integration_Calls__c.getValues('Restrict');
        System.debug('**'+rCalls);
        Boolean restrictCalls = Boolean.valueOf(rCalls.Restrict_Callouts__c);
        System.debug('a values is **'+restrictCalls);
        
        //code for authentication
        String timeDifferenceInSeconds = String.valueOf((DateTime.now().getTime()/1000));   //returns milliseconds from Jan 1st 1970(Hence we divide by 1000 to get seconds)
        
        String endPoint1 = endPts.Endpoint_URL_for_authentication__c ;
        String privateKey = endPts.Private_Key__c;
        String publicKey  = endPts.Public_Key__c;
        String apiKey = endPts.API_key__c;
       
        //end of authentication
               
        for(invoiceit_crmx__Opportunity_Product__c oppProd : [Select i.invoiceit_crmx__Product__c, i.invoiceit_crmx__Product_Code__c, 
                                                                     i.invoiceit_crmx__Opportunity__c, i.Name, i.IsInventoried__c, 
                                                                     i.InventoryId__c, i.customerNumber__c, i.Id From invoiceit_crmx__Opportunity_Product__c i
                                                               where i.Id in : setOppProdIdsque 
                                                               and (RecordType.DeveloperName = 'MDL_Opportunity_Product' or RecordType.DeveloperName = 'Nolo_Opportunity_Product') ALL ROWS]) {
            reqXML = MDL_Integration_Vim_Efs.constructXML_ReleaseInventory(oppProd,uName,mapOpptyProdNInventoryIdque.get(oppProd.Id));  //get request XML from the static method
            //reqxml='xml='+ reqXML;
            system.debug('Reponse XML value '+reqxml);
             string ipayload   = 'publicKey='+ publicKey + '&' + 'timestamp=' + timeDifferenceInSeconds + '&' + 'xml=' + reqXML;
               // string ipayload   = 'Hello';
                System.debug ('ipayload'+ipayload);
                Blob textToBeHashedInBytes = Blob.valueOf(ipayload);
                Blob mac = Crypto.generateMac('HmacSHA256',Blob.valueOf(ipayload), Blob.valueOf(privateKey));
                String encodedText  = EncodingUtil.base64Encode(mac);
                String Header      =  encodedText + '|'+  timeDifferenceInSeconds;
                System.Debug('encodedText'+encodedText);
                String givenEndpoint   = endPts.Endpoint_URL__c;
                String encodedurl = EncodingUtil.urlEncode(givenEndpoint, 'UTF-8');
                system.debug(reqxml);
            try {
                if(restrictCalls == false) {    
                   Http http = new Http(); //global class which is used in both request & response
                            HttpRequest req = new HttpRequest(); //initiate HTTP request
                            req.setEndpoint(givenEndpoint);
                            req.setMethod(methodType);
                            req.setTimeout(20000);
                            //req.setBody(reqXML); 
                            req.setBody(ipayload);
                            req.setHeader('Accept', 'application/xml');
                            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                            req.setHeader('Authorization', Header);
                            HTTPResponse res = http.send(req);
                    System.debug('Response Body in releaseinventory is : '+res.getBody());
                    if(res.getStatusCode() == 200){
                        Error_Log__c temp_error = MDL_Integration_Vim_Efs.checkForSuccessResponseWithError(res.getBody() , reqXML);
                        if(temp_error != null){
                            temp_error.XML_Mesaage_Type__c = 'ReleaseInventory';
                            lstErrLogs.add(temp_error);
                        }   
                    }
                    if(res.getStatusCode() == 400 || res.getStatusCode() == 401){
                        MDL_Integration_Vim_Efs.parseResponse400Error(res.getBody(),'ReleaseInventory',reqXML,oppProd.Id,'');
                    } 
                    else{  
                        if(res.getStatusCode() != 500 && res.getStatusCode() != 502 && res.getStatusCode() != 404) { 
                            lstResponseBody.add(res.getBody());
                        }
                        else {
                            Error_Log__c err = new Error_Log__c();
                            err.XML_Mesaage_Type__c = 'ReleaseInventory';
                            err.XML_Body__c = reqXML;
                            err.Release_inventory_id__c = oppProd.Id;
                            err.Error_Reason__c = res.getStatusCode()+' : '+res.getStatus();
                            lstErrLogs.add(err);    
                        } 
                    }
                }
                else if(restrictCalls == true){
                    System.debug('No calls will be sent since custom setting is activated');
                }                   
            }catch(System.CalloutException ce) {
                Error_Log__c err = new Error_Log__c();
                err.XML_Mesaage_Type__c = 'ReleaseInventory';
                err.XML_Body__c = reqXML;
                err.Release_inventory_id__c = oppProd.Id;
                err.Error_Reason__c = 'Problem with web service operation. Failed to make a callout to an external system.';
                lstErrLogs.add(err);    
            }
            catch(System.Exception e) {
                MDL_Integration_Vim_Efs.sendEmailInCaseOfException('Release Inventory',oppProd.Id,e.getMessage()); 
            }                                                            
        }
        if(lstErrLogs.size() > 0) {
            Database.insert(lstErrLogs);
        }
        MDL_Integration_Vim_Efs.parseResponseXML_ReleaseInventoryResponse(lstResponseBody);
        
        
         
        // Sai : 8th July 2018 to Handle Closed Lost of child Records
        // This functionality Moved here From Process builder class ChatOpportunitiesStatusUpdates to avoid too many queueable jobs
        Integer  count= database.countQuery('select count() From opportunity where Parent_Opportunity__c IN: oppIdsque AND stageName != \'Closed Lost\' AND stageName != \'QA Review\'');
    
       List<Id> oppIdsList = new List<Id>();
        oppIdsList.addAll(oppIdsque);
        //System.debug('===== before calling void docusign method');
         //MDL_trgHandlerforOppRenew_Rebase.voidingenvelopefrombatch(oppIdsque); 
       if(count > 0){
           System.debug('===== calling void docusign method');
            //MDL_trgHandlerforOppRenew_Rebase.voidingenvelopefrombatch(oppIdsque);
             ChatOpportunitiesStatusUpdates.updatechildopps(oppIdsList);
       }  
        
      
        
        
    }

}