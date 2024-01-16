/**@@
#Batch CLASS NAME  : BatchExecSetOrderProductasExpired
#DESCRIPTION       : This is Batch class used to Set Order Product Status as Expired for Last Month
#CREATED BY        : Serge Kandukuri
@@**/
public class BatchExecSetOrderProductasExpired implements Database.Batchable<sObject>{
     String query;
    // Constructor
    public BatchExecSetOrderProductasExpired(String queryParam){
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
    public void execute(Database.BatchableContext bc, List<Orderitem> orderItemList){      
        try{
            set<Id> orderIdSet = new set<Id>();
            // Update Order Product Status to Expired -- START
            List<Orderitem> oiListUpdate = new List<Orderitem>();
            for(Orderitem oi: orderItemList){
               Orderitem objOI = new Orderitem(Id=oi.Id);
               objOI.Status__c = 'Expired';
               oiListUpdate.add(objOI);
               
               orderIdSet.add(oi.OrderId);
            }
            if(!oiListUpdate.isEmpty()){
               update oiListUpdate;
            }
            // Update Order Product Status to Expired -- END
            
            // Update Order Status to Expired -- START
            List<Order> ordUpdate = new List<Order>();
            for(Id ordId: orderIdSet){
                Order objOrder = new Order(Id=ordId);
                objOrder.Status__c = 'Expired';
                ordUpdate.add(objOrder);
            }
            if(!ordUpdate.isEmpty()){
               update ordUpdate;
            }
            // Update Order Status to Expired -- END
        } //End of try block
        catch(Exception e){
            system.debug('Exception is===>'+e.getMessage());
        }//End of catch
        
    }//End of Execute() method
    
    /**@@
    #DESCRIPTION     :  It is a finish method of batch class. used for None purpose but its required in batch class.
    #Paramaters      :  BC (Database.BatchableContext) : It is a reference to the Database.BatchableContext object 
    @@**/
    public void Finish(Database.BatchableContext bc)
    {
        
    }//End of finish method
    
    /*
    String query = 'SELECT Id, OrderId FROM Orderitem WHERE CALENDAR_MONTH(EndDate) =: previousMonth AND Status__c = \'Active\'';
    BatchExecSetOrderProductasExpired objBatchExec = new BatchExecSetOrderProductasExpired(query);
    database.executeBatch(objBatchExec, 200);        
    */
}//End of BatchExecSetOrderProductasExpired class