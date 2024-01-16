// Author       : Sai
// Date         : 18/5/2016
// Descritption : to work release Inventory concept both in trigger as well as batch class

public class ReleaseInventroyQueueable implements Queueable, Database.AllowsCallouts {
    
    public Set<Id> oppIdsque {get;set;}
    public Set<Id> setOppProdIdsque{get;set;}
    public String userNameque{get;set;}
    public Map<Id,String> mapOpptyProdNInventoryIdque{get;set;}
        
    //constructor
    public ReleaseInventroyQueueable(Set<Id>oppIds, Set<Id> setOppProdIds,String userName,Map<Id,String> mapOpptyProdNInventoryId){
        
        this.oppIdsque                   = oppIds; 
        this.setOppProdIdsque            = setOppProdIds;
        this.userNameque                 = userName;
        this.mapOpptyProdNInventoryIdque = mapOpptyProdNInventoryId;
        
    }
    
    public void execute(QueueableContext context) {
        
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
        /*String endPoint1 = 'cert3-svcs.martindale.com/mhintegration/inventory/release';
        String privateKey = 'F2DCA2AD71561755E0433454B60AF99D';
        String apiKey = '76F1CF765AA41A8E695F66A815B7D345';*/
        
        String endPoint1 = endPts.Endpoint_URL_for_authentication__c ;
        String privateKey = endPts.Private_Key__c;
        String publicKey  = endPts.Public_Key__c;
        String apiKey = endPts.API_key__c;
        /*
        String httpVerb = 'POST';
        string textToBeHashed = timeDifferenceInSeconds + ':' + endPoint1 + ':' + httpVerb + ':' + privateKey;
        System.debug('textToBeHashed'+textToBeHashed);
        Blob textToBeHashedInBytes = Blob.valueOf(textToBeHashed);
        System.debug('text to be hashed to blob'+textToBeHashedInBytes);
        String algorithmName = 'SHA-256';
        Blob mac = Crypto.generateDigest(algorithmName, textToBeHashedInBytes);
        System.debug('SHA256 algo'+mac);
        String encodedText  = EncodingUtil.base64Encode(mac);
        System.debug('Base 64 string'+encodedText);
        String aToken = timeDifferenceInSeconds + ':' + apikey + ':' + encodedText;
        //aToken will be added in HTTP Request Header as Authorization
        System.debug('authorization token is '+aToken);
        */
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
        Integer  count= database.countQuery('select count() From opportunity where Parent_Opportunity__c IN: oppIdsque AND stageName != \'Closed Lost\'');
    
       List<Id> oppIdsList = new List<Id>();
        oppIdsList.addAll(oppIdsque);
       if(count > 0){
            system.enqueueJob(new chatOpportunitiesQueueable(oppIdsList));
       }  
        
        
        
        
    }

}