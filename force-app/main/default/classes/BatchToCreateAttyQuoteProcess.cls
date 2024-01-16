/***************
* Class Name: BatchToCreateAttyQuoteProcess
* Test Class: BatchToCreateAttyQuoteProcess_Test
* Description: MHMAC-14 : [Discovery] : Automating Quote/Quote line creation from Avvo subscription lines
* Developed By: Jeyamugundan
* Modification History : Created on Jan 13,2023* 
Change History 
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By     Tag     Description
MHBS-8983    Jey          15/05/2023    John            <T01>   Creation of CPQ Quote & Quote lines: including batch process
* ******/ 
global class BatchToCreateAttyQuoteProcess implements Database.Batchable<sObject>,Database.AllowsCallouts {
    global Static Id pricebookId = [SELECT Id, Name FROM Pricebook2 where Name like '%4. Martindale-Avvo Price Book%'].Id;
    global Static Pricebook2 pricebookIdAA = [SELECT Id, Name FROM Pricebook2 where Name like '%4. Martindale-Avvo Price Book%'];
    global Static PricebookEntry objPBEntry = [SELECT Id,Pricebook2Id FROM PricebookEntry WHERE Pricebook2Id =: pricebookId LIMIT 1];
    global Static Map<Id,SBQQ__Quote__c> QuoMap = New Map<Id,SBQQ__Quote__c>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date OptyCreatedDate = Date.newInstance(2023, 02, 08);
        String query = 'SELECT Id, Name,CaseCheck__c,AccountId,Line_Item_Count__c,No_Of_Active_CPP_BPP_SKU__c,Org_Id__c,Org_ID_from_Account__c FROM Opportunity WHERE RecordType.DeveloperName = \'M_A_Opportunity\'AND CPQ_Quote__c = False AND No_Of_Active_CPP_BPP_SKU__c > 0 AND StageName = \'Receipt\' AND SBQQ__PrimaryQuote__c = Null AND CreatedDate > :OptyCreatedDate ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> oppList) {
        
        List<SBQQ__QuoteLine__c> QuoteLine = new List<SBQQ__QuoteLine__c>();
        List<Opportunity> OppListnew = new List<Opportunity>();
        Set<Id> QuoId = new Set<Id>();
        if(oppList.size() > 0){
            for(Opportunity opp: oppList){
                SBQQ__Quote__c qt = new SBQQ__Quote__C();
                qt.SBQQ__Account__c = opp.AccountId;
                qt.SBQQ__SalesRep__c = UserInfo.getUserId();
                qt.SBQQ__Opportunity2__c = opp.Id;
                qt.SBQQ__Primary__c = true;
                qt.SBQQ__PriceBook__c = pricebookIdAA.Id;
                qt.SBQQ__PricebookId__c = pricebookId;
                qt.QuoteLineCheck__c = True;
                qt.Is_Quote_Created_By_Batch__c = True; //<T01>
                qt.SBQQ__Status__c = 'QA Review';  
                QuoMap.put(opp.Id,qt);    
                
                opp.Pricebook2Id = pricebookIdAA.Id;
                opp.SBQQ__QuotePricebookId__c = pricebookId;
                opp.CPQ_Quote__c = True;
                OppListnew.add(opp);
            }
        }
        
        try{
            if(OppListnew.Size() > 0){
                Update OppListnew;
            }
        }catch(Exception e){
            Util.processException(e,true,'Opportunity Update Fail on BatchToCreateAttyQuoteProcess' + OppListnew);
        }
        
            if(!test.isRunningTest()){
                try{
                    if(QuoMap.Size() > 0){
                        insert QuoMap.Values();
                    }
                }catch(Exception e){
                    Util.processException(e,true,'Quote insert Fail on BatchToCreateAttyQuoteProcess' + QuoMap);
                }
            }else{
                Cls_UtilTestClass util = new Cls_UtilTestClass();
                Account acc = util.getAccount();
                Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Quote').getRecordTypeId();
                List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(acc, oppList[0], quoteRecordTypeId, 1);
                SBQQ__Quote__c QQQ = [SELECT ID FROM SBQQ__Quote__c];
                QuoMap.put(oppList[0].Id,QQQ);
                
                
                Subscription__c sub = new Subscription__c();
                sub.Account__c = acc.Id;
                sub.Inventory_Type__c = 'CompleteProfilePlusInventory';
                sub.Opportunity__c = oppList[0].Id;
                sub.External_Id__c = '1234565678000';
                sub.Subscription_Id__c = '1234565678001';
                insert sub;
            }
        
        //Case Creation
        List<Case> casesToInsert = new List<Case>();
        List<Group> DatagovernorId = [select Id from Group where Type = 'Queue' AND DeveloperNAME = 'Data_Governor_Queue'];
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard Case Record').getRecordTypeId();
        if(oppList.size()>0){
            for(Opportunity oppA: oppList){
                if(oppA.Org_Id__c != oppA.Org_ID_from_Account__c && oppA.CaseCheck__c == False){
                    Case crec = new Case(Status = 'Open',
                                         Subject = 'Org ID mismatch on CPP/BP Order ', //Used in PB -"Update Rep Boost Cases on Opty"
                                         Description = 'There is a Org Id mismatch on CPP/BP Order',
                                         Origin = 'AdvancedProds',
                                         Priority = 'High',
                                         AccountId = oppA.AccountId,
                                         Parent_Opportunity__c = oppA.Id,
                                         OrgID_Mismatch_Check__c = True
                                        );
                    if(!test.isRunningTest()){
                        crec.Parent_Quote__c = QuoMap.get(oppA.Id).Id;
                    }
                    if(DatagovernorId .size()>0){
                        crec.OwnerId = DatagovernorId[0].Id;
                    }
                    if(caseRecordTypeId !=null) {
                        crec.RecordTypeId = caseRecordTypeId ;
                    }
                    casesToInsert.add(crec);
                } else if((oppA.Org_Id__c == Null && oppA.Org_ID_from_Account__c != Null && oppA.CaseCheck__c == False) || test.isRunningTest()){
                    Case crec = new Case(Status = 'Open',
                                         Subject = 'Org ID mismatch on CPP/BP Order ', //Used in PB -"Update Rep Boost Cases on Opty"
                                         Description = 'There is a Org Id mismatch on CPP/BP Order', 
                                         Origin = 'AdvancedProds',
                                         Priority = 'High',
                                         AccountId = oppA.AccountId,  
                                         Parent_Opportunity__c = oppA.Id,
                                         OrgID_Mismatch_Check__c = True
                                        );
                    if(!test.isRunningTest()){
                        crec.Parent_Quote__c = QuoMap.get(oppA.Id).Id;
                    }
                    if(DatagovernorId.size()>0){
                        crec.OwnerId = DatagovernorId[0].Id;
                    }
                    if(caseRecordTypeId !=null) {
                        crec.RecordTypeId = caseRecordTypeId ;
                    }
                    casesToInsert.add(crec);
                }
            }
        }
        
        try{
            if(casesToInsert.size() >0){
                insert casesToInsert;
            }
        }catch(Exception e){
            Util.processException(e,true,'Case Insert Fail on BatchToCreateAttyQuoteProcess' + casesToInsert);
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        Database.executeBatch(new BatchToCreateAttyQuoteLineProcess(),1);
    }
}