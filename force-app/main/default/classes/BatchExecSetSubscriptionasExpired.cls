/**@@
#Batch CLASS NAME  : BatchExecSetSubscriptionasExpired
#DESCRIPTION       : This is Batch class used to Set Order Product Status as Expired for Last Month
#CREATED BY        : Serge Kandukuri
@@**/
public class BatchExecSetSubscriptionasExpired implements Database.Batchable<sObject>{
     String query;
    // Constructor
    public BatchExecSetSubscriptionasExpired(String queryParam){
        query = queryParam;
    }
    /**@@
    #DESCRIPTION     : This is start method which return the user records.
    #Paramaters      : (Database.BatchableContext bc) It is a reference to the Database.BatchableContext object 
    @@**/
    public Database.QueryLocator start(Database.BatchableContext bc){
        integer previousMonth = system.today().addMonths(-1).month();
        return Database.getQueryLocator(query);
    }//End of start method
    
    /**@@
    #DESCRIPTION     : This is execute method, which is used to Set Order Product Status as Expired for Last Month
    #Paramaters      :  1)BC (Database.BatchableContext) : It is a reference to the Database.BatchableContext object.
                        2)List<Orderitem> orderItemList: List of Orderitem.
    @@**/
    public void execute(Database.BatchableContext bc, List<SBQQ__Subscription__c> subscriptionList){      
        //try{
            set<Id> contractIdSet = new set<Id>();
            // Update Subscription Status to Expired -- START
            List<SBQQ__Subscription__c> subListUpdate = new List<SBQQ__Subscription__c>();
            for(SBQQ__Subscription__c oi: subscriptionList){
               SBQQ__Subscription__c objSub = new SBQQ__Subscription__c(Id=oi.Id);
               objSub.Status__c = 'Expired';
               objSub.SBQQ__TerminatedDate__c = system.today();
               subListUpdate.add(objSub);
               
               contractIdSet.add(oi.SBQQ__Contract__c);
            }
            if(!subListUpdate.isEmpty()){
               update subListUpdate;
            }
            // Update Subscription Status to Expired -- END
            
            // Update Contract Status to Expired -- START
            List<Contract> conUpdate = new List<Contract>();
            for(Id conId: contractIdSet){
                Contract objCon = new Contract(Id=conId);
                objCon.Status__c = 'Expired';
                conUpdate.add(objCon);
            }
            if(!conUpdate.isEmpty()){
               update conUpdate;
            }
            // Update Contract Status to Expired -- END
            
            // "Close lost" any open quotes which are associated to the contracts that have been marked as Expired -- START
            List<Contract> contractList = [SELECT Id, SBQQ__Quote__c FROM Contract WHERE Id IN: conUpdate AND SBQQ__Quote__c != null AND SBQQ__Quote__r.SBQQ__Status__c != 'Closed Lost'];
            List<SBQQ__Quote__c> quoteUpdateList = new List<SBQQ__Quote__c>();
            for(Contract con: contractList){
                SBQQ__Quote__c quote = new SBQQ__Quote__c(id=con.SBQQ__Quote__c);
                quote.SBQQ__Status__c = 'Closed Lost';
                quote.Reason_Won_Lost__c = 'Order Expired';
                quoteUpdateList.add(quote);
            }
            if(!quoteUpdateList.isEmpty()){
                update quoteUpdateList;
            }
            // "Close lost" any open quotes which are associated to the contracts that have been marked as Expired -- END
        /*} //End of try block
        catch(Exception e){
            system.debug('Exception is===>'+e.getMessage());
        }//End of catch
        */
    }//End of Execute() method
    
    /**@@
    #DESCRIPTION     :  It is a finish method of batch class. used for None purpose but its required in batch class.
    #Paramaters      :  BC (Database.BatchableContext) : It is a reference to the Database.BatchableContext object 
    @@**/
    public void Finish(Database.BatchableContext bc)
    {
        
    }//End of finish method
    
    /*
    String query = 'SELECT Id, SBQQ__Contract__c FROM SBQQ__Subscription__c WHERE CALENDAR_MONTH(SBQQ__EndDate__c) =: previousMonth AND Status__c = \'Active\'';
    BatchExecSetSubscriptionasExpired objBatchExec = new BatchExecSetSubscriptionasExpired(query);
    database.executeBatch(objBatchExec, 200);        
    */
}//End of BatchExecSetOrderProductasExpired class