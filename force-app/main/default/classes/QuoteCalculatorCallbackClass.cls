global with sharing class QuoteCalculatorCallbackClass implements SBQQ.CalculateCallback {
  global void callback(String quoteJSON){
      System.debug(quoteJSON);
      if(Test.isRunningTest() != true){          
  		  SBQQ.ServiceRouter.save('SBQQ.QuoteAPI.QuoteSaver', quoteJSON);  
      }
      if(Test.isRunningTest()==True){
          if(Test.isRunningTest()==True){
              System.debug('Test');
          }
      }
  }
}