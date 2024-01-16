@isTest(seealldata=true)
public class Test_Milestone_Trigger_Utility{
    static testmethod void projectIsInactive(){
        
                MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
                Account account2 = util.getAccount();
                Contact contact2 = util.getContact(account2.Id);
                invoiceit_s__Currency__c currency2 = util.getCurrencyObject();
                invoiceit_s__Job__c order2 = util.getOrder(account2.Id , currency2.Id);
              
                invoiceit_s__Product__c product2 = util.getProduct('false');
                invoiceit_s__Product_Rate_Plan__c productrateplan2 = util.getProductRatePlan(product2.Id);
                invoiceit_s__Product_Rate_Plan_Charge__c productrateplancharge2 = util.getProductRatePlanCharge(currency2.Id ,productrateplan2.Id);
                invoiceit_s__Job_Product__c jobproduct2 = util.getOrderProduct(order2.Id,product2.Id);
                invoiceit_s__Job_Rate_Plan__c jobrateplan2 = util.getOrderRatePlan(jobproduct2.Id, productrateplan2.Id);
                invoiceit_s__Job_Rate_Plan_Charge__c jobrateplancharge2 = util.getOrderRatePlanCharge(jobrateplan2.Id , productrateplancharge2.Id);
               
                List<Milestone1_Project__c> listOfProj = new List<Milestone1_Project__c>();
                Milestone1_Project__c rec = new Milestone1_Project__c();
                rec.Name = 'Web Bronze Project';
                rec.Status__c = 'New';
                insert rec;
                
                Milestone1_Project__c rec2 = new Milestone1_Project__c();
                rec2.Name = 'Web Bronze Project';
                rec2.Status__c = 'In Progress';
                insert rec2;
        
                listOfProj.add(rec);
                listOfProj.add(rec2);
        
                // Create a milestone
                Milestone1_Milestone__c mstone = new Milestone1_Milestone__c();
                mstone.Name = 'Test Milestone';
                mstone.Status__c = 'Ready to Start';
                mstone.Project__c = rec2.id;
                insert mstone;
           
        
                Milestone1_Task__c stask = new Milestone1_Task__c();
                stask.Task_Stage__c = 'Not Started';
                stask.Project_Milestone__c = mstone.id;
                insert stask;
                System.debug('========stask Status'+stask.Task_Stage__c);
                stask.Task_Stage__c = 'Ready to Start';
               
                Update stask;
                try{
                    rec.Status__c = 'Cancelled';
                    rec.Order_Rate_Plan_Charge__c = jobrateplancharge2.id;
                    rec.Order__c = order2.id;
                    update rec;
                    
                    rec2.Status__c = 'On Hold';
                    update rec2;
                }
                catch(Exception e){
                    Boolean expectedExceptionThrown =  e.getMessage().contains('Project cannot be cancelled as the associated charge is still active')? true : false;
                     System.AssertEquals(expectedExceptionThrown, false);
                }
                Milestone1_Project_Trigger_Utility.handleProjectValidations(listOfProj);
                
    }
    
    static testmethod void chargeCancellation(){
            MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
            
            Account a = testData.getAccount();
        
        Contact c = testData.getContact(a.Id);  
        
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
        
        invoiceit_s__Product__c product = testData.getProduct('false');
        product.Product_Provisioning__c = 'Manual Fulfillment';
        update product;
        
        invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);
        
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);
        
        Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);
        
         
        
        invoiceit_s__Job__c order = testData.getOrder(a.Id, CurrencyObj.Id);
        
        invoiceit_s__Job_Product__c orderProduct = testdata.getOrderProduct(order.Id, product.Id);
        invoiceit_s__Job_Rate_Plan__c orderRatePlan = testdata.getOrderRatePlan(OrderProduct.Id, productRatePlan.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge =  new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC', invoiceit_s__Job_Rate_Plan__c =orderRatePlan.Id,
                                                                                                   invoiceit_s__Quantity__c = 12, invoiceit_s__Price_Type__c = 'One Time',
                                                                                                   invoiceit_s__Unit_Price__c = 12,invoiceit_s__Service_Activation_Date__c = system.today(),
                                                                                                   invoiceit_s__Service_End_Date__c = system.today().addMonths(5),invoiceit_s__Status__c = 'Active', 
                                                                                                   Quote_Type__c = 'Renew', invoiceit_s__Accounting_Code__c='01808',
                                                                                                   invoiceit_s__Price__c=10);
            
            Test.startTest();
            insert orderRatePlanCharge;
           
            MDL_RecursionHandler.milestonecheck = True;
            
            orderRatePlanCharge.invoiceit_s__Status__c = 'Cancelled';
            orderRatePlanCharge.Loss_Reasons__c = 'Price too High';
            update orderRatePlanCharge;
            
            Test.stopTest();
            
            
        }
    
}