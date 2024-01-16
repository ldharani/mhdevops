@isTest(seeAlldata = true)
public class mdl_contactEmailupdatectrlrTest {
    
    public static testmethod void run2condition(){
        //creating util class instance
    MDL_UtilClass_TestClass utilclass = new MDL_UtilClass_TestClass();
    
    
    //creating single account 
    account acc = utilclass.getAccount();
    
    //creating single currency
    invoiceit_s__Currency__c singlecurrency = utilclass.getCurrencyObject();
        
    //creating contact
    contact con = utilclass.getContact(acc.Id);    
    
    //creating single order 
    invoiceit_s__Job__c order = utilclass.getOrder(acc.Id, singlecurrency.id);
     order.Name = '12345';   
    order.invoiceit_s__Billing_Contact__c = con.id;
     update order;  
     system.debug('@@@order name '+ order.Name);   
    
    mdl_contactEmailupdateController mdlctrlr = new mdl_contactEmailupdateController();
   
    mdlctrlr.getorderDetails();
    mdlctrlr.updatEmail();
        
       
    
     mdl_contactEmailupdateController mdlctrlr1 = new mdl_contactEmailupdateController(); 
     mdlctrlr1.orderNumber = order.Name;
     system.debug('@@@mdlctrlr1.orderNumber'+ mdlctrlr1.orderNumber);   
     mdlctrlr1.getorderDetails();
     mdlctrlr1.updatEmail(); 
        mdlctrlr1.ok();
        
    }
    
    

}