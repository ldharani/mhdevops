//Adding LogiaclDoc URL Functionality
    global with sharing class Portal_createInvoiceFolderPath {
       
    //@future(callout=true)
     webservice static string createInvoiceFolderPath(Id invIds) {
        
        String username = 'mhd-logicaldoc';
        String pwd      = 'kxmbbk3e';
        boolean checkforsessionID;
        Long rootFolderID;
        list<string> lstUrl = new list<string>();
        List<LogicalDoc_Session__c> existingsession = new List<LogicalDoc_Session__c>();
        
        //List<Account> lstAccRecords = [select id, name,MH_Cust_Number__c from Account where Id IN :accIds];
        blng__Invoice__c singleinv = [select id, blng__Account__r.Logical_Doc__c,
                                                  Name, blng__Account__r.MH_Cust_Number__c
                                               
                                                 from blng__Invoice__c
                                                   where id =: invIds];
        
        string folderURL = '';
        
        authWebserviceLogicaldocCom.AuthServiceImplPort logwebservices = new authWebserviceLogicaldocCom.AuthServiceImplPort();
        string sid = '';
        if(singleinv !=null){
            
            
             //getting sessionid
              existingsession = [select id, User_Name__c,
                                        sid__c 
                                        from LogicalDoc_Session__c
                                        where User_Name__c =: username
                                        LIMIT 1];
            system.debug('@@@ existingsession' +existingsession);
            
            //logic for session pooling
            if(!existingsession.isEmpty() && existingsession !=null && !test.isRunningTest()){
                checkforsessionID = logwebservices.valid(existingsession[0].sid__c);
               
            }
            
            system.debug('@@@checkforsessionID'+ checkforsessionID);
             if(checkforsessionID == true){
                    sid = existingsession[0].sid__c;
                    
                }
                else{
                    if(!test.isRunningTest()){
                        sid = logwebservices.login('mhd-logicaldoc','kxmbbk3e');
                        
                    }
                    checkforsessionID = false;
                    
                }
            
             
            if(singleINv.blng__Account__r.Logical_Doc__c != null){
                
                system.debug('@@@@sid'+  sid ); 
                
                string url = singleINv.blng__Account__r.Logical_Doc__c;
                system.debug('@@@@url'+ url);
                lstUrl.addAll(url.split('='));
                rootFolderID = Long.valueOf(lstUrl[1]);
                system.debug('@@@@rootFolderID'+ rootFolderID);
                
        
        
                long folderid= 0;
                //long Customer Number = 0;
                NewfolderWebserviceLogicaldocCom.wsFolder rootFolder = new NewfolderWebserviceLogicaldocCom.wsFolder();
                NewdocumentWebserviceLogicaldocCom.wsDocument document = new  NewdocumentWebserviceLogicaldocCom.wsDocument();
                List<NewdocumentWebserviceLogicaldocCom.wsDocument> lstDocuments = new List<NewdocumentWebserviceLogicaldocCom.wsDocument>();
                NewdocumentWebserviceLogicaldocCom.DocumentServiceImplPort documentLogicalService =new NewdocumentWebserviceLogicaldocCom.DocumentServiceImplPort();
                List<NewfolderWebserviceLogicaldocCom.wsFolder> lstChildFolders = new List<NewfolderWebserviceLogicaldocCom.wsFolder>();
                
                system.debug('@@@@SId=='+  sid ); 
                NewfolderWebserviceLogicaldocCom.FolderServiceImplPort folderLogicalService =new NewfolderWebserviceLogicaldocCom.FolderServiceImplPort();
                
                //rootFolder =  folderLogicalService.findByPath(sid,'/MH_LIBRARY/'+singleinv.invoiceit_s__Account__r.MH_Cust_Number__c);
                //system.debug('@@@@rootfolder=='+  rootFolder );
                if(!test.isRunningTest()){
                    lstChildFolders =  folderLogicalService.listChildren(sid, rootFolderID); 
                }
                
                system.debug('@@@@@lstChildFolders ==='+  lstChildFolders );
                if(lstChildFolders != null){
                    for(NewfolderWebserviceLogicaldocCom.wsFolder folder : lstChildFolders )
                    {
                        if(folder.Name == 'INV')
                        {
                            folderid = folder.id;
                            system.debug('@@@@FolderName==='+  folder.Name );
                            system.debug('@@@@@Saichand=========FoldeID==='+  folder.id); 
                            break;
                        }
                        system.debug('Saichand=========FolderName==='+  folder.Name );
                        system.debug('Saichand=========FoldeID==='+  folder.id); 
                    }
               }
               
                string fileName      = singleinv.blng__Account__r.MH_Cust_Number__c+ singleinv.Name+'.pdf';
                string fileName_new  = singleinv.blng__Account__r.MH_Cust_Number__c+ singleinv.Name+'.pdf_DNM.pdf';
                 
                system.debug('@@@folderId'+ folderid);
                system.debug('@@@@@lstChildFolders ==='+  lstChildFolders );
                system.debug('@@@@File Name ==='+  fileName );
                system.debug('@@@@filename_new'+ fileName_new);
                if(folderid != 0){
                    lstDocuments = documentLogicalService.listDocuments(sid,folderid,fileName );
                    if(lstDocuments == null){
                        lstDocuments = documentLogicalService.listDocuments(sid,folderid,fileName_new);
                    }
                }
                
                
                system.debug('Saichand=========lstDocuments ==='+  lstDocuments );
                if(lstDocuments !=null && !lstDocuments.isEmpty()){
                    folderURL = 'http://mhlogicdoc.martindale.com/download?sid=' + sid + '&docId=' +lstDocuments[0].customId;
                    system.debug('@@@@@folderURL'+folderURL);
                }
                
            }     
       }
        
        try{
            if(checkforsessionID == false){
                if(!existingsession.isEmpty() && existingsession !=null){
                    existingsession[0].sid__c = sid;
                    update existingsession;
                }
                else{
                    LogicalDoc_Session__c logicalDocSession = new LogicalDoc_Session__c();
                    logicalDocSession.User_Name__c = username;
                    logicalDocSession.sid__c       = sid;
                    insert logicalDocSession;
                }
            
            }   
        }
        catch(exception e){
            system.debug('@@@@exception'+ e);
        }
        
       //MDL_RecursionHandler.stopAccRecursion = false; 
       //update lstInvRecords;
       return folderURL;
    }   
}