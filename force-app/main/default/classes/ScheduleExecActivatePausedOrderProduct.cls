/**@@
#APEX CLASS NAME     :    ScheduleExecActivatePausedOrderProduct
#TEST CLASS          :    ScheduleExecActivatePausedOrderProductTest
#CREATED BY          :    Serge Kandukuri
#DESCRIPTION         :    This Schedular Class is used to set Order Product to Active after the Resume date has passed.
@@**/
global class ScheduleExecActivatePausedOrderProduct implements schedulable{
    /**@@
        #DESCRIPTION   : This Schedular Class is used to set Order Product to Active after the Resume date has passed.
        #Paramaters    : SchedulableContext sc
    @@**/
    global void execute(SchedulableContext sc){
        Date dtToday = system.today();
        List<OrderItem> lstOI = [SELECT Id FROM OrderItem WHERE Status__c =: Constant.ORDER_STATUS_PAUSE AND Resume_Date__c <=: dtToday];
        List<OrderItem> lstOIUpdate = new List<OrderItem>();
        OrderItem objOI;
        for(OrderItem oi: lstOI){
            objOI = new OrderItem(id=oi.id);
            objOI.Status__c = Constant.ORDER_STATUS_ACTIVE;
            lstOIUpdate.add(objOI);
        }
        if(!lstOIUpdate.isEmpty() && Test.isRunningTest() == false){
            update lstOIUpdate;
        }
    }
}