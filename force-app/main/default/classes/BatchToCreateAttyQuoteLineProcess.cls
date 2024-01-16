/***************
* Class Name: BatchToCreateAttyQuoteLineProcess
* Test Class: BatchToCreateAttyQuoteProcess_Test
* Description: MHMAC-14 : [Discovery] : Automating Quote/Quote line creation from Avvo subscription lines
* Developed By: Jeyamugundan
* Modification History : Created on Jan 13,2023* 
Change History 
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By     Tag     Description
MHBS-8983    Jey          15/05/2023    John            <T01>   Creation of CPQ Quote & Quote lines: including batch process
* ******/ 
global class BatchToCreateAttyQuoteLineProcess implements Database.Batchable<sObject>,Database.AllowsCallouts {
    global Set<Id> QuoteIds = new Set<Id>();
    global Static Id pricebookId = [SELECT Id, Name FROM Pricebook2 where Name like '%4. Martindale-Avvo Price Book%'].Id;
    global Static Pricebook2 pricebookIdAA = [SELECT Id, Name FROM Pricebook2 where Name like '%4. Martindale-Avvo Price Book%'];
    global Static PricebookEntry objPBEntry = [SELECT Id,Pricebook2Id FROM PricebookEntry WHERE Pricebook2Id =: pricebookId LIMIT 1];
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator( [SELECT Id,SBQQ__Opportunity2__c,QuoteLineCheck__c FROM SBQQ__Quote__c WHERE QuoteLineCheck__c = True] );
    }
    global void execute(Database.BatchableContext BC, List<SBQQ__Quote__c> newQuote){
        
        List<SBQQ__QuoteLine__c> QuoteLine = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__Quote__c> quoLists = new List<SBQQ__Quote__c>();
        List<String> inventoryTypes = System.Label.Subscription_Inventory_Types.Split(', ');
        //<T01>
        Set<Id> oppIds = new Set<Id>();
        Map<Id,Subscription__c> subMap = new Map<Id,Subscription__c>();
        for(SBQQ__Quote__c QuoA : newQuote){
            oppIds.add(QuoA.SBQQ__Opportunity2__c);
        }
        if(oppIds.Size() > 0){
            for(Subscription__c subc : [SELECT ID,Product_Code__c,Opportunity__c,Account__c,Contact__c,Inventory_Type__c FROM Subscription__c WHERE Inventory_Type__c IN: inventoryTypes AND Opportunity__c =: oppIds] ){
                subMap.put(subc.Id,subc);
            }
        }
        for(SBQQ__Quote__c Quo : newQuote){
            Quo.QuoteLineCheck__c = false;
            quoLists.add(Quo);
            
            if(subMap.Size() > 0){
                Map<String,Subscription__c> ProdMap = new Map<String,Subscription__c>();
                for(Subscription__c subA : subMap.values()){ //<T01>
                    ProdMap.put(subA.Product_Code__c,subA);
                }
                Map<String,Product2> ProdMapSs = new Map<String,Product2>();
                if(ProdMap.Size() > 0){
                    for(Product2 pro :[SELECT ID,ProductCode,LastModifiedById,CreatedById,SBQQ__SubscriptionPricing__c,SBQQ__SubscriptionBase__c,SBQQ__SubscriptionTerm__c,SBQQ__ChargeType__c FROM Product2 WHERE ProductCode IN: ProdMap.KeySet() ]){
                        ProdMapSs.put(pro.ProductCode, pro);
                    }
                }
                if(subMap.size() > 0){
                    for(Subscription__c sub : subMap.values()){
                        SBQQ__QuoteLine__c ObjQutLine = new SBQQ__QuoteLine__c();
                        ObjQutLine.SBQQ__Taxable__c = false;
                        ObjQutLine.SBQQ__Quote__c = Quo.Id;
                        ObjQutLine.SBQQ__ProductSubscriptionType__c ='Evergreen';
                        ObjQutLine.SBQQ__SubscriptionType__c = 'Evergreen';
                        ObjQutLine.SBQQ__SubscriptionTerm__c = 1;
                        ObjQutLine.SBQQ__SubscriptionPricing__c = ProdMapSs.get(sub.Product_Code__c).SBQQ__SubscriptionPricing__c;
                        ObjQutLine.SBQQ__SubscriptionBase__c = ProdMapSs.get(sub.Product_Code__c).SBQQ__SubscriptionBase__c;
                        ObjQutLine.SBQQ__DefaultSubscriptionTerm__c = ProdMapSs.get(sub.Product_Code__c).SBQQ__SubscriptionTerm__c;
                        ObjQutLine.SBQQ__ChargeType__c = ProdMapSs.get(sub.Product_Code__c).SBQQ__ChargeType__c;
                        ObjQutLine.SBQQ__Product__c = ProdMapSs.get(sub.Product_Code__c).Id;
                        ObjQutLine.SBQQ__Quantity__c = 1 ;
                        ObjQutLine.SBQQ__BillingFrequency__c ='Monthly';
                        If(sub.Inventory_Type__c == 'FirmOwnershipInventory'){
                            ObjQutLine.SBQQ__Number__c = 3;
                        }
                        ObjQutLine.SBQQ__BillingType__c = 'Advance';
                        ObjQutLine.CreatedById = ProdMapSs.get(sub.Product_Code__c).CreatedById;
                        ObjQutLine.recordtypeid= Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Quote Line').getRecordTypeId();
                        ObjQutLine.SBQQ__PricebookEntryId__c = objPBEntry.Id;               
                        ObjQutLine.Contact__c = sub.Contact__c;
                        ObjQutLine.IsInsertviaBatch__c = TRUE; //added to skip flow
                        ObjQutLine.skipFlows__c = true; //added to skip flow "Flow - QuoteLine TRG AfterCreate Updates"
                        QuoteLine.add(ObjQutLine);
                    }
                }
            }
        }
        
        try{
            if(QuoteLine.Size() > 0){
                insert QuoteLine;
            }
        }catch(Exception e){
            if(test.isRunningTest()){
                System.debug('Test');
            }else{
                Util.processException(e,true,'QuoteLine Insert Fail on BatchToCreateAttyQuoteLineProcess' + QuoteLine);  
            }
        }
        
        try{
            if(quoLists.Size() > 0){
                Update quoLists;
            }
        }catch(Exception e){
            if(test.isRunningTest()){
                System.debug('Test');
            }else{
                Util.processException(e,true,'Quote Update Fail on BatchToCreateAttyQuoteLineProcess' + quoLists); 
            }
        }
    }  
    global void finish(Database.BatchableContext bc){
    }    
}