@isTest(seealldata=true)
public class Test_socialStarterExt {

    static testmethod void socialMethd(){
    
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc = util.getAccount();
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        Contact con = util.getContact(acc.Id);
        
        
        invoiceit_s__Product__c prod1 = util.getProduct('true');
        invoiceit_s__Product_Rate_Plan__c prp = util.getProductRatePlan(prod1.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c prpc = util.getProductRatePlanCharge(curr.Id , prp.Id);

        Opportunity opp = util.getOpportunity(acc.Id , con.Id ,curr.Id );
        
        /*Opportunity opp = new Opportunity(Name = 'TestOpp', AccountId = acc.Id, Amount = 123,                                                      
                CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,
                ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = con.Id ,
                invoiceit_crmx__CurrencyL__c = curr.Id, invoiceit_crmx__Shipping_Contact__c = con.Id,
                invoiceit_crmx__Recalculate__c = false , invoiceit_crmx__Number_Of_Terms__c = 12 ,
                invoiceit_crmx__Do_Not_Create_Automatic_Order__c = false ,
                Type = 'New Business'
        );
        
        insert opp;*/
        opp.AOPs__c = 'Test1, Divorce, Administrative Law';
        update opp;
        
        invoiceit_crmx__Opportunity_Product__c  oppprod1 = new invoiceit_crmx__Opportunity_Product__c(Name = 'Reputation Boost',invoiceit_crmx__Product_Code__c = '12000',InventoryId__c ='1233213', invoiceit_crmx__Product__c = prod1.Id ,invoiceit_crmx__Opportunity__c = opp.Id);
        insert oppProd1;
        
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp = util.getOpportunityRatePlan(oppprod1.Id , prp.Id);
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(Name='Reputation Boost- Basic',invoiceit_crmx__Price_Type__c = 'Monthly', invoiceit_crmx__Accounting_Code__c = '12001',invoiceit_crmx__Unit_Price__c = 100, invoiceit_crmx__Opportunity_Rate_Plan__c = opprp.Id, invoiceit_crmx__Product_Rate_Plan_Charge__c = prpc.Id);          
        insert opprpc ;
        
        Opportunity_Charge_Attribute__c oppCharge1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc.Id, Attribute_Type__c = 'URL', Attribute_Name__c='Social Starter URL',Boolean_Value__c= true);
        insert oppCharge1;
        
        ApexPages.currentPage().getParameters().put('id',opp.id);
        ApexPages.currentPage().getParameters().put('attrId',oppCharge1.id);
        
        socialStartedExten socialEx = new socialStartedExten();
        
        test.startTest();
       
        
        //socialStartedExten.socialStartedExten();
        socialEx.bankruptcy = true;
        socialEx.conName = 'Test Name';
        socialEx.conPhone = '12332133';
        socialEx.conEmail = 'abcd@gmail.com';
        socialEx.criminal = true;
        socialEx.estate = true;
        socialEx.divorce = true;
        socialEx.immigration = true;
        socialEx.labor = true;
        socialEx.business = true;
        socialEx.family = true;
        socialEx.civilright = true;
        socialEx.resid = true;
        socialEx.personalinj = true;
        socialEx.persInjMV = true;
        socialEx.persInPl = true;
        socialEx.persInjMM = true;
        socialEx.eldrLaw = true;
        socialEx.intProp = true;
        socialEx.websiteURL = 'Test Website';
        socialEx.facebookURL= 'Test Facebook';
        socialEx.LinkedInURL= 'Test LinkedIn';
        //socialEx.googleURL = 'Test Google';
        socialEx.noToGooglProf= True;
        socialEx.Notes= 'Test Notes';
        socialEx.doesNtwanProf= 'Client Does Not Want a Facebook Profile Created<br/>';
        socialEx.noToFbProf = True;
        socialEx.workerscomp = False;
        socialEx.noToLnProf = False;
        socialEx.none = False;
        socialEx.aops = 'Bankruptcy (2/week)<br/>, Criminal Defense (2/week)<br/>';
        socialEx.advArea = 'Testing Area';

        socialEx.Submit();
        socialEx.createCase('Test Area','Test Sub area','Test Subject','Test Description','Test Case Origin', acc.id );
        
        socialEx.createCase1('Test Area','Test Sub Area','Test subject','Test description','Test Case origin',acc.id);
          
        test.stopTest();
        
    }
}