/*****
Class Name: BatchUpdateQuoteStartDate 
Created by: SS
* @testclass - BatchUpdateQuoteStartDateTest

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-7447	 SS			   08/07/2023	John Mattheson	<T01>	Proration - New Sales
************************************************************************************************************************/
global class BatchUpdateQuoteStartDate implements Database.Batchable<SObject>, Database.Stateful {
    
     global String query;
     global List<SBQQ__QuoteLine__c> qliToUpdate = new List<SBQQ__QuoteLine__c>();

	
       global Database.QueryLocator start(Database.BatchableContext BC) {   
         List<String> qStatus = new List<String>{'Accepted','Closed Won','Closed Lost'};
         query = 'SELECT Id,SBQQ__StartDate__c,SBQQ__EndDate__c,(Select Id,SBQQ__StartDate__c,SBQQ__EndDate__c from SBQQ__LineItems__r) from SBQQ__Quote__c where RecordType.DeveloperName = \'M_A_Quote\' and SBQQ__Status__c NOT IN :qStatus';
           if(Test.isRunningtest()){
               query = 'SELECT Id,SBQQ__StartDate__c,SBQQ__EndDate__c,(Select Id,SBQQ__StartDate__c,SBQQ__EndDate__c from SBQQ__LineItems__r) from SBQQ__Quote__c where RecordType.DeveloperName = \'M_A_Quote\' and SBQQ__Status__c NOT IN :qStatus limit 1';
			}
         System.debug(query);
        return Database.getQueryLocator(query);
      }
      
      
      global void execute(Database.BatchableContext BC, List<SBQQ__Quote__c> qList) {
          List<SBQQ__Quote__c> quotesToUpdate =  new List<SBQQ__Quote__c>();
          //List<SBQQ__QuoteLine__c> qliList = new List<SBQQ__QuoteLine__c>();
          
          for(SBQQ__Quote__c q : qList)
            {
                QuoteReader qreader = new QuoteReader();
                QuoteModel quoteModel = qreader.read(q.id); //QuoteReader.read returns the Quote in QuoteModel format
                System.debug(quoteModel.record);
                quoteModel.record.SBQQ__StartDate__c= Date.today();
                quoteModel.record.SBQQ__EndDate__c= null;
                quoteModel.record.End_date__c= null;
               // System.debug(quoteModel.record.EndDate__c);
                for(QuoteLineModel qli : quoteModel.lineItems){
                    System.debug(qli.record);
                    if(qli.record.SBQQ__ProductCode__c != 'PROMOFEE-MA' || (qli.record.SBQQ__ProductCode__c == 'PROMOFEE-MA' && qli.record.UpdateNetTotal__c == false)){
                        qli.record.SBQQ__StartDate__c= Date.today();
                        qli.record.SBQQ__EndDate__c= null;
                    }
                    
                    if(qli.record.SBQQ__ProductCode__c == 'PROMOFEE-MA' && qli.record.UpdateNetTotal__c == true && qli.record.IsIncludedinProrate__c == true && qli.record.SBQQ__StartDate__c == Date.today()){
                        qli.record.IsIncludedinProrate__c = false;
                    }
                }

                QuoteSaver saver = new QuoteSaver();
                if(Test.isRunningTest() != true){
                QuoteModel savedQuote = saver.save(quoteModel);
                }
                System.debug('Final'+quoteModel);
                
                //QuoteCalculator calculator = new QuoteCalculator();
				//calculator.calculate(quoteModel, 'QuoteCalculatorCallbackClass');

            }

          /* for(SBQQ__Quote__c q:qList){
              qliList.addAll(q.SBQQ__LineItems__r);
              if(q.SBQQ__StartDate__c ==  null || q.SBQQ__StartDate__c != Date.Today() || q.SBQQ__EndDate__c == null || q.End_date__c == null){
                   q.SBQQ__StartDate__c = Date.Today();
                   q.SBQQ__EndDate__c = null;
              	   q.End_date__c = null;
                   quotesToUpdate.add(q);
              } 
          }
          Database.update(quotesToUpdate);
          System.debug(qliList);
          for(SBQQ__QuoteLine__c qli:qliList){
              System.debug(qli.SBQQ__StartDate__c);
              if(qli.SBQQ__StartDate__c ==  null || qli.SBQQ__StartDate__c != Date.Today() || qli.SBQQ__EndDate__c != null){
              qli.SBQQ__StartDate__c = Date.Today();
              qli.SBQQ__EndDate__c = null;
              qliToUpdate.add(qli);
              }
          } 
         System.debug('qliToUpdate'+qliToUpdate);*/
      }
      
        global void finish(Database.BatchableContext BC) {
            System.debug('qliToUpdate'+qliToUpdate);
           Database.update(qliToUpdate);
        }
    }