/*
Apex Class   : orderExtension
Created By   : Serge Kandukuri
Description  : This is Extension class for Visualforce page to change Order status to Active/Paused
*/
public class orderExtension {

    public orderExtension(ApexPages.StandardController controller) {

    }
    
    public pagereference activateOrderProductStatus(){
        string strOPId = apexpages.currentpage().getparameters().get('id');
        
        OrderItem objOIFetch = [SELECT Id, Status__c FROM OrderItem WHERE Id =: strOPId];
        OrderItem objOI = new OrderItem(id=strOPId);
        if(objOIFetch.Status__c == Constant.ORDER_STATUS_ACTIVE){
            objOI.Status__c = Constant.ORDER_STATUS_PAUSE;
        }else if(objOIFetch.Status__c == Constant.ORDER_STATUS_PAUSE){
            objOI.Status__c = Constant.ORDER_STATUS_ACTIVE;
        }
        update objOI;
        
        pagereference pr = new pagereference('/'+strOPId);
        return pr;
    }
    

}