/*******************************************
 * Description    : this class covers two classes
 *                  MDL_BatchAutomateEvergreenProcess,MDL_BatchSendXMLAutomateEvergreenProcess
 * ***************************************************************/

@isTest(seealldata = true)
public with sharing class MDL_Test_BatchAutomateEvergreenProcess {
    static testMethod void testAutomateProcess(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        
        RecordType r = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.SobjectType = 'Case' and r.Name = 'MDL Oppty Renew' LIMIT 1];
        
        Account acc = util.getAccount();
        acc.Credit_Status__c = 'Good Standing';
        acc.Sub_Type__c = 'Small Law';
        update acc; 
                
        invoiceit_s__Currency__c cur = util.getCurrencyObject();
        
        contact con = util.getContact(acc.Id);
        
        invoiceit_s__Product__c prod = util.getProduct('false'); 
        prod.Product_Provisioning__c = 'Manual Fulfillment';
        update prod;               
        invoiceit_s__Product_Rate_Plan__c pRP = util.getProductRatePlan(prod.Id);       
        invoiceit_s__Product_Rate_Plan_Charge__c pRPC = util.getProductRatePlanCharge(cur.Id, pRP.Id);
        pRPC.Renewable__c = true;
        insert pRPC;
        
        invoiceit_s__Job__c order = new invoiceit_s__Job__c();
        order.Name = 'Test Order for Auto Evergreen';
        order.invoiceit_s__Account__c   = acc.Id;
        order.invoiceit_s__CurrencyL__c = cur.Id;
        order.invoiceit_s__Status__c = 'Active';
        order.invoiceit_s__Number_Of_Terms__c = 1;
        order.invoiceit_s__Discount_Percent__c = 0.0; 
        order.invoiceit_s__Billing_Contact__c  = con.id;
        insert order;
        
        
        invoiceit_s__Job_Product__c oProd = util.getOrderProduct(order.Id ,prod.Id);
        invoiceit_s__Job_Rate_Plan__c oRP = util.getOrderRatePlan(oProd.Id , pRP.Id);
        
        invoiceit_s__Job_Rate_Plan_Charge__c jobRPC = new invoiceit_s__Job_Rate_Plan_Charge__c();
        jobRPC.Name = 'Test RPC for Auto Evergreen';
        jobRPC.invoiceit_s__Job_Rate_Plan__c = oRP.Id;
        jobRPC.invoiceit_s__Product_Rate_Plan_Charge__c = pRPC.Id;
        jobRPC.invoiceit_s__Quantity__c = 1;
        jobRPC.invoiceit_s__Status__c = 'Active';
        jobRPC.invoiceit_s__Price_Type__c = 'Monthly';      
        insert jobRPC;    
        
        Order_Charge_Attribute__c oppCharges = util.getOrderCharges(jobRPC.Id, 'Text', 'AOP');
        Order_Charge_Attribute__c oppCharges1 = util.getOrderCharges(jobRPC.Id, 'Text', 'Service Account Name');
        Order_Charge_Attribute__c oppCharges2 = util.getOrderCharges(jobRPC.Id, 'Text', 'State');
        Order_Charge_Attribute__c oppCharges3 = util.getOrderCharges(jobRPC.Id, 'Text', 'City');
        Order_Charge_Attribute__c oppCharges4 = util.getOrderCharges(jobRPC.Id, 'Text', 'County');
        Order_Charge_Attribute__c oppCharges5 = util.getOrderCharges(jobRPC.Id, 'Text', 'Country');
        
        Case c = new Case();
        c.AccountId = acc.Id;
        c.RecordTypeId = r.Id;
        c.Subject = 'Subscription Renewal for '+acc.Name;
        c.Description = 'Account is due for renewal within 120 days';
        c.Priority = 'Medium';
        c.Area__c = 'Opportunity';
        c.Sub_Area__c = 'Renewal';
        c.Parent_Order__c = order.Id;  
        c.Status = 'Open';      
        insert c;
                       
        Test.startTest();
        MDL_BatchAutomateEvergreenProcess b = new MDL_BatchAutomateEvergreenProcess(); 
        Database.executeBatch(b,1);
        Test.stopTest(); 
    }
}