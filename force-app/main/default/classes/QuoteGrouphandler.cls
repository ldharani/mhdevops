public class QuoteGrouphandler{

 public static void UpdateQuotegroup(List<SBQQ__QuoteLineGroup__c> Qgrouplist){
   system.debug('@@@In UpdateQuotegroup');
   List<SBQQ__QuoteLineGroup__c>  grouplist = new List<SBQQ__QuoteLineGroup__c>();

     
  for(SBQQ__QuoteLineGroup__c qlg : Qgrouplist){
            
            //if(qlg.isClone()){
                
            //    qlg.Name = 'Cloned version of Products'; 
                
                //grouplist .add(qlg);
              //  system.debug(' Cloned version of products'+qlg.Name);            
                
           // }
            
             system.debug('@@@Before If UpdateQuotegroup');
            if(qlg.SBQQ__Quote__c != null){
                system.debug('@@@After If UpdateQuotegroup');
                qlg.Name = 'Original Contract Products'; 
                
                //grouplist .add(qlg);
                system.debug('qlg.Name'+qlg.Name);            
                
            }
        }
        
       /* system.debug('@@@ grouplist  @@'+grouplist );
      
            if(!grouplist.isEmpty()){
            
                update grouplist ;
            }*/
 }

}