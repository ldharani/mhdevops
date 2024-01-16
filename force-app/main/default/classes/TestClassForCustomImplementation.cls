/*
Lister Changes : 
    On Method classForDefineChargesValidity Line 57
    Changed the name of the account1 as 'Test Account InvoiceIT' 
    This is changed because of a workflow on our side  'MDL_AccountDupeUpdate'
    which updates a unique field and ensures that the combination of Account Name and Address is not repeated 
*/
@isTest(seeAlldata = true)
private with sharing class TestClassForCustomImplementation {
    
    static testMethod void classForDefineChargesValidity(){
        
        Account account = new Account(name = 'Test Account', invoiceit_s__Preferred_Billing_Day__c = string.ValueOf(system.Today().Day()));
        insert account;
        
        invoiceit_s__Currency__c currencyObj = new invoiceit_s__Currency__c(Name = 'USD',
                                                                            invoiceit_s__Symbol__c = '$'
                                                                            );
        insert currencyObj;
        
        invoiceit_s__Job__c job = new invoiceit_s__Job__c(invoiceit_s__Account__c = account.id, invoiceit_s__Service_Activation_Date__c = system.today(),
                                                          invoiceit_s__Status__c = 'In Progress', invoiceit_s__CurrencyL__c = currencyObj.Id);
        insert job;
         
        invoiceit_s__Job_Product__c  jobProduct= new invoiceit_s__Job_Product__c(Name = 'jobProduct', invoiceit_s__Job__c = job.Id);
        insert jobProduct;

        invoiceit_s__Job_Rate_Plan__c jobRP = new invoiceit_s__Job_Rate_Plan__c(Name = 'JobRP', invoiceit_s__Job_Product__c =jobProduct.Id);
        insert jobRP;
        
        list<invoiceit_s__Job_Rate_Plan_Charge__c> listOfOrderCharges = new list<invoiceit_s__Job_Rate_Plan_Charge__c>();
        invoiceit_s__Job_Rate_Plan_Charge__c charge = new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC', invoiceit_s__Job_Rate_Plan__c =jobRP.Id,
                                                                                               invoiceit_s__Quantity__c = 12, invoiceit_s__Price_Type__c = 'One Time',
                                                                                               invoiceit_s__Unit_Price__c = 12,invoiceit_s__Service_Activation_Date__c = system.today(),
                                                                                               invoiceit_s__Service_End_Date__c = system.today().addMonths(5)
                                                                                               );
        
        invoiceit_s__Job_Rate_Plan_Charge__c charge1 = new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC', invoiceit_s__Job_Rate_Plan__c =jobRP.Id,
                                                                                               invoiceit_s__Quantity__c = 12, invoiceit_s__Price_Type__c = 'Monthly',
                                                                                               invoiceit_s__Unit_Price__c = 47,invoiceit_s__Service_Activation_Date__c = system.today(),
                                                                                               invoiceit_s__Service_End_Date__c = system.today().addMonths(5)
                                                                                               );
        listOfOrderCharges.add(charge);
        listOfOrderCharges.add(charge1);
        insert listOfOrderCharges;
        
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(job);
        system.currentPageReference().getParameters().put('id',job.id);
        ClassForDefineChargesValidity classForDefineChargesValidity = new ClassForDefineChargesValidity(stdController);
        classForDefineChargesValidity.getvalues();
        classForDefineChargesValidity.value = 'Extend';
        classForDefineChargesValidity.fetchORPC();
        classForDefineChargesValidity.save();
        classForDefineChargesValidity.cancel();
        classForDefineChargesValidity.changeValue();
        
        Account account1 = new Account(name = 'Test Account InvoiceIT', invoiceit_s__Preferred_Billing_Day__c = string.ValueOf(system.Today().Day()));
        insert account1;
        
        invoiceit_s__Job__c job1 = new invoiceit_s__Job__c(invoiceit_s__Account__c = account1.id, invoiceit_s__Service_Activation_Date__c = system.today(),
                                                          invoiceit_s__Status__c = 'In Progress', invoiceit_s__CurrencyL__c = currencyObj.Id);
        insert job1;
        ApexPages.Standardcontroller stdController1 = new ApexPages.Standardcontroller(job1);
        system.currentPageReference().getParameters().put('id',job1.id);
        ClassForDefineChargesValidity classForDefineChargesValidity1 = new ClassForDefineChargesValidity(stdController1);
        classForDefineChargesValidity1.getvalues();
        classForDefineChargesValidity1.value = 'Extend';
        classForDefineChargesValidity1.fetchORPC();
    }
    
    static testMethod void classOnOpportunity(){
        
            MDL_UtilClass_TestClass utilclass = new MDL_UtilClass_TestClass();
            Account account = new Account(name = 'Test Account', invoiceit_s__Preferred_Billing_Day__c = string.ValueOf(system.Today().Day()));
            insert account;
        
            contact con = utilclass.getContact(account.id);
            
            invoiceit_s__Currency__c currency1 = new invoiceit_s__Currency__c(Name = 'USD', invoiceit_s__Symbol__c = '$');
            insert currency1;
            
            Deactivate_Trigger_for_data_load__c trigLoad = Deactivate_Trigger_for_data_load__c.getInstance('Deactivate');            
            trigLoad.Deactivate_trigger__c = false;
            update trigLoad;
            String recordTypeId = [Select Id,DeveloperName From RecordType Where SobjectType = 'Opportunity' and DeveloperName = 'M_N_Opportunity'].Id;           
            Opportunity opportunity1 = new Opportunity(Name = 'Acertis Cloud Test Oppty 111', AccountId = account.id, Amount = 123.50, RecordTypeId=recordTypeId,                                                     
                                                       Auth_By_Contact__c= con.id,CloseDate = system.today(), StageName = 'Needs Analysis', invoiceit_crmx__Billing_Contact__c = con.id
                                                      );
            insert opportunity1;
        
             Opportunity opportunity2 = new Opportunity(Name = 'Acertis Cloud Test Oppty Mid-Term', AccountId = account.id, Amount = 123.50,                                                      
                                                       CloseDate = system.today(), StageName = 'Needs Analysis', invoiceit_crmx__Billing_Contact__c = con.id
                                                      );
            insert opportunity2;
        
            Opportunity opportunity3 = new Opportunity(Name = 'Nolo Prod Test', AccountId = account.id,                                                  
                                                       CloseDate = system.today(), StageName = 'Needs Analysis', invoiceit_crmx__Billing_Contact__c = con.id
                                                      );
            insert opportunity3;
            
            invoiceit_crmx__Opportunity_Product__c  oppProduct= new invoiceit_crmx__Opportunity_Product__c(Name = 'Opp Product', invoiceit_crmx__Opportunity__c = opportunity1.Id,invoiceit_crmx__Product_Bundle__c = null);
            insert oppProduct;
            
            invoiceit_s__Product__c prod = utilclass.getProduct('true');
            invoiceit_s__Product_Rate_Plan__c prodrateplan = utilclass.getProductRatePlan(prod.Id);
            invoiceit_s__Product_Rate_Plan_Charge__c prodrateplancharge = utilclass.getProductRatePlanCharge(currency1.Id,prodrateplan.Id);
            prodrateplancharge.Package_Component__c = true;
            insert prodrateplancharge;
            
            invoiceit_crmx__Opportunity_Rate_Plan__c oppProductRatePlan = utilclass.getOpportunityRatePlan(oppProduct.Id,prodrateplan.Id);
            //invoiceit_crmx__Opportunity_Rate_Plan__c oppProductRatePlan = new invoiceit_crmx__Opportunity_Rate_Plan__c(Name = 'Opp Product Rate Plan', invoiceit_crmx__Opportunity_Product__c = oppProduct.Id);
            //insert oppProductRatePlan;
            
            invoiceit_crmx__Opportunity_Rate_Plan_Charge__c OppCharge = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(invoiceit_crmx__Price_Type__c = 'One Time', 
                                                                                                                            invoiceit_crmx__Unit_Price__c = 100, 
                                                                                                                            invoiceit_crmx__Opportunity_Rate_Plan__c = oppProductRatePlan.id,
                                                                                                                            invoiceit_crmx__Accounting_Code__c = '01808',
                                                                                                                             invoiceit_crmx__Opportunity__c = opportunity1.Id);
            insert OppCharge;
            
            invoiceit_crmx__Opportunity_Product__c  oppProduct2= new invoiceit_crmx__Opportunity_Product__c(Name = 'Opp Product2', invoiceit_crmx__Opportunity__c = opportunity3.Id, invoiceit_crmx__Product_Code__c = '40020');
            insert oppProduct2;
        
            system.debug('@@@@ query check'+OppCharge.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Is_Chat_Option_Shown__c);
            system.debug('@@@@ query check opty'+OppCharge.invoiceit_crmx__Opportunity__c);
            system.debug('@@@@ query check opty'+OppCharge.invoiceit_crmx__Accounting_Code__c);
            
            Opportunity_Charge_Attribute__c accessRight1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppCharge.id, Attribute_Type__c = 'Text');
            insert accessRight1;            
                       
            MDL_trgHandlerforOppRenew_Rebase.recursionCheckforopty = true;
            
            try{
                opportunity1.StageName = 'Closed Won';
                opportunity1.Reason_Won_Lost__c = 'Administrative';
                update opportunity1;                
            }
         catch(Exception ex){

         }
                
            MDL_trgHandlerforOppRenew_Rebase.recursionCheckforopty = true;
            
           Test.starttest();
            try{
                accessRight1.Attribute_Type__c = 'Number';
                accessRight1.String_Value__c = 'Test';
                accessRight1.Attribute_Name__c='Country';
                update accessRight1;            
                opportunity1.StageName = 'Closed Won';
                opportunity1.Reason_Won_Lost__c = 'Administrative';
                update opportunity1;
            } catch(Exception ex){
                system.debug('--ex.getMessage()---'+ex.getMessage());

            }
        
             MDL_trgHandlerforOppRenew_Rebase.recursionCheckforopty = true;
            
            try{
                accessRight1.Attribute_Type__c = 'Boolean';
                accessRight1.Number_Value__c = 12;
                update accessRight1;                    
                opportunity1.StageName = 'Closed Won';
                opportunity1.Reason_Won_Lost__c = 'Administrative';
                update opportunity1;
            } catch(Exception ex){

            }
        
              MDL_trgHandlerforOppRenew_Rebase.recursionCheckforopty = true;
            
            try{
                accessRight1.Attribute_Type__c = 'Picklist';
                accessRight1.Boolean_Value__c = true;
                update accessRight1;                    
                opportunity1.StageName = 'Closed Won';
                opportunity1.Reason_Won_Lost__c = 'Administrative';
                update opportunity1;
            } catch(Exception ex){

            }
        
            MDL_trgHandlerforOppRenew_Rebase.recursionCheckforopty = true;
            
            try{
                accessRight1.Attribute_Type__c = 'Date';
                accessRight1.Picklist_Value__c = 'Test';
                update accessRight1;                    
                opportunity1.StageName = 'Closed Won';
                opportunity1.Reason_Won_Lost__c = 'Administrative';
                update opportunity1;
            } catch(Exception ex){

            }
            
            MDL_trgHandlerforOppRenew_Rebase.recursionCheckforopty = true;
            try{
                accessRight1.Attribute_Type__c = 'Phone';
                accessRight1.Date_Value__c = system.today();
                update accessRight1;                    
                opportunity1.StageName = 'Closed Won';
                opportunity1.Reason_Won_Lost__c = 'Administrative';
                update opportunity1; 
            } catch(Exception ex){

            }
        
            MDL_trgHandlerforOppRenew_Rebase.recursionCheckforopty = true;
            try{
                opportunity2.StageName = 'Closed Won';
                opportunity2.Reason_Won_Lost__c = 'Administrative';
                update opportunity2;
            
           }
        catch(Exception ex){
            
           }
            MDL_trgHandlerforOppRenew_Rebase.recursionCheckforopty = true;
            try{
                opportunity3.StageName = 'Closed Won';
                opportunity3.Reason_Won_Lost__c = 'Administrative';
                update opportunity3;
            }
        catch(Exception ex){

        }
        
        Test.stoptest();
    }
    
    static testMethod void ClassOnOpportunityRatePlanCharge(){
        
        Account account = new Account(name = 'Test Account for ClassOnOpportunityRatePlanCharge', invoiceit_s__Preferred_Billing_Day__c = string.ValueOf(system.Today().Day()),
                                         Phone ='1111111111',
                                        ShippingPostalCode = '256345', ShippingStreet = 'Kormangala'
                                        );
        insert account;
        
        invoiceit_s__Currency__c currencyObj = new invoiceit_s__Currency__c(Name = 'USD',
                                                                            invoiceit_s__Symbol__c = '$'
                                                                            );
        insert currencyObj; 
        
        invoiceit_s__Product__c product = new  invoiceit_s__Product__c(Name = 'Test Product for ClassOnOpportunityRatePlanCharge',
                                                                       invoiceit_s__Valid_From_Date__c = Date.today(),
                                                                       invoiceit_s__Valid_To_Date__c = Date.today()+90,
                                                                       invoiceit_s__Product_Family__c = 'Default',
                                                                       invoiceit_s__Product_Code__c = 'Code1',
                                                                       invoiceit_s__Description__c = 'Product'
                                                                       );
        insert product;
        
        invoiceit_s__Product_Rate_Plan__c productRatePlan = new  invoiceit_s__Product_Rate_Plan__c(Name = 'Test ProductRatePlan for ClassOnOpportunityRatePlanCharge',
                                                                                                   invoiceit_s__Product__c = product.Id,
                                                                                                   invoiceit_s__Valid_From_Date__c = Date.today(),
                                                                                                   invoiceit_s__Valid_To_Date__c = Date.today()+90
                                                                                                   );
        insert productRatePlan;
                                                                                                   
        list<invoiceit_s__Product_Rate_Plan_Charge__c> listProductRatePlanCharges = new list<invoiceit_s__Product_Rate_Plan_Charge__c>();       
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge1 = new invoiceit_s__Product_Rate_Plan_Charge__c(Name = 'Setup Charges',
                                                                                                                       invoiceit_s__CurrencyL__c = currencyObj.Id,
                                                                                                                       invoiceit_s__Product_Rate_Plan__c = productRatePlan.Id,
                                                                                                                       invoiceit_s__Unit_Price__c = 1000,
                                                                                                                       invoiceit_s__Cost_Price__c = 500,                                                                  
                                                                                                                       invoiceit_s__Price_Type__c = 'One Time'      
                                                                                                                       );
                                                                                                                       
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge2 = new invoiceit_s__Product_Rate_Plan_Charge__c(Name = 'Monthly Charges',
                                                                                                                       invoiceit_s__CurrencyL__c = currencyObj.Id,
                                                                                                                       invoiceit_s__Product_Rate_Plan__c = productRatePlan.Id,
                                                                                                                       invoiceit_s__Unit_Price__c = 1000,
                                                                                                                       invoiceit_s__Cost_Price__c = 500,                                                                  
                                                                                                                       invoiceit_s__Price_Type__c = 'Monthly'       
                                                                                                                       );
        listProductRatePlanCharges.add(productRatePlanCharge1);
        listProductRatePlanCharges.add(productRatePlanCharge2);
        insert listProductRatePlanCharges;
         
        list<Attribute_Config__c> listOfAttributeConfig = new list<Attribute_Config__c>();
        listOfAttributeConfig.add(new Attribute_Config__c(Name = 'Service Account Name' ,Attribute_Order__c = 12, Attribute_Picklist_Values__c = 'test Values', 
                                                                        Attribute_Type__c = 'Text', Maximum_No_Of_Characters_In_Text__c = 10,
                                                                        Minimum_No_Of_Characters_In_Text__c = 2 
                                                                      ));
        listOfAttributeConfig.add(new Attribute_Config__c(Name = 'Service Account Name', Attribute_Order__c = 12, Attribute_Picklist_Values__c = 'test Values', 
                                                                        Attribute_Type__c = 'Picklist', Maximum_No_Of_Characters_In_Text__c = 10,
                                                                        Minimum_No_Of_Characters_In_Text__c = 2 
                                                                      ));
        listOfAttributeConfig.add(new Attribute_Config__c(Name = 'Service Street Address', Attribute_Order__c = 12, Attribute_Picklist_Values__c = 'test Values', 
                                                                        Attribute_Type__c = 'Text', Maximum_No_Of_Characters_In_Text__c = 10,
                                                                        Minimum_No_Of_Characters_In_Text__c = 2 
                                                                      ));
        listOfAttributeConfig.add(new Attribute_Config__c(Name = 'Service Street Address', Attribute_Order__c = 12, Attribute_Picklist_Values__c = 'test Values', 
                                                                        Attribute_Type__c = 'Picklist', Maximum_No_Of_Characters_In_Text__c = 10,
                                                                        Minimum_No_Of_Characters_In_Text__c = 2 
                                                                      ));
        listOfAttributeConfig.add(new Attribute_Config__c(Name = 'Service City' ,Attribute_Order__c = 12, Attribute_Picklist_Values__c = 'test Values', 
                                                                        Attribute_Type__c = 'Text', Maximum_No_Of_Characters_In_Text__c = 10,
                                                                        Minimum_No_Of_Characters_In_Text__c = 2 
                                                                      ));
        listOfAttributeConfig.add(new Attribute_Config__c(Name = 'Service City', Attribute_Order__c = 12, Attribute_Picklist_Values__c = 'test Values', 
                                                                        Attribute_Type__c = 'Picklist', Maximum_No_Of_Characters_In_Text__c = 10,
                                                                        Minimum_No_Of_Characters_In_Text__c = 2 
                                                                      ));
        listOfAttributeConfig.add(new Attribute_Config__c(Name = 'Service State', Attribute_Order__c = 12, Attribute_Picklist_Values__c = 'test Values', 
                                                                        Attribute_Type__c = 'Text', Maximum_No_Of_Characters_In_Text__c = 10,
                                                                        Minimum_No_Of_Characters_In_Text__c = 2 
                                                                      ));
        listOfAttributeConfig.add(new Attribute_Config__c(Name = 'Service State', Attribute_Order__c = 12, Attribute_Picklist_Values__c = 'test Values', 
                                                                        Attribute_Type__c = 'Picklist', Maximum_No_Of_Characters_In_Text__c = 10,
                                                                        Minimum_No_Of_Characters_In_Text__c = 2 
                                                                      ));
        listOfAttributeConfig.add(new Attribute_Config__c(Name = 'Service Country' ,Attribute_Order__c = 12, Attribute_Picklist_Values__c = 'test Values', 
                                                                        Attribute_Type__c = 'Text', Maximum_No_Of_Characters_In_Text__c = 10,
                                                                        Minimum_No_Of_Characters_In_Text__c = 2 
                                                                      ));
        listOfAttributeConfig.add(new Attribute_Config__c(Name = 'Service Country', Attribute_Order__c = 12, Attribute_Picklist_Values__c = 'test Values', 
                                                                        Attribute_Type__c = 'Picklist', Maximum_No_Of_Characters_In_Text__c = 10,
                                                                        Minimum_No_Of_Characters_In_Text__c = 2 
                                                                      ));
        listOfAttributeConfig.add(new Attribute_Config__c(Name = 'Service Zip', Attribute_Order__c = 12, Attribute_Picklist_Values__c = 'test Values', 
                                                                        Attribute_Type__c = 'Text', Maximum_No_Of_Characters_In_Text__c = 10,
                                                                        Minimum_No_Of_Characters_In_Text__c = 2 
                                                                      ));
        listOfAttributeConfig.add(new Attribute_Config__c(Name = 'Service Zip', Attribute_Order__c = 12, Attribute_Picklist_Values__c = 'test Values', 
                                                                        Attribute_Type__c = 'Picklist', Maximum_No_Of_Characters_In_Text__c = 10,
                                                                        Minimum_No_Of_Characters_In_Text__c = 2 
                                                                      ));
        listOfAttributeConfig.add(new Attribute_Config__c(Name = 'Ring to Number', Attribute_Order__c = 12, Attribute_Picklist_Values__c = 'test Values', 
                                                                        Attribute_Type__c = 'Phone', Maximum_No_Of_Characters_In_Text__c = 10,
                                                                        Minimum_No_Of_Characters_In_Text__c = 2 
                                                                      ));
        insert listOfAttributeConfig;
        
        list<Product_Charge_Attribute__c> listOfProductChargeAttribute = new list<Product_Charge_Attribute__c>();
        listOfProductChargeAttribute.add(new Product_Charge_Attribute__c(Product_Rate_Plan_Charge__c = listProductRatePlanCharges.get(1).id, Attribute_Name__c = 'City', Attribute_Order__c = 1, Attribute_Type__c = 'String', AttributeName__c = listOfAttributeConfig.get(0).id));
        listOfProductChargeAttribute.add(new Product_Charge_Attribute__c(Product_Rate_Plan_Charge__c = listProductRatePlanCharges.get(1).id, Attribute_Name__c = 'City', Attribute_Order__c = 1, Attribute_Type__c = 'Number', AttributeName__c = listOfAttributeConfig.get(1).id));
        listOfProductChargeAttribute.add(new Product_Charge_Attribute__c(Product_Rate_Plan_Charge__c = listProductRatePlanCharges.get(1).id, Attribute_Name__c = 'City', Attribute_Order__c = 1, Attribute_Type__c = 'String', AttributeName__c = listOfAttributeConfig.get(2).id));
        listOfProductChargeAttribute.add(new Product_Charge_Attribute__c(Product_Rate_Plan_Charge__c = listProductRatePlanCharges.get(1).id, Attribute_Name__c = 'City', Attribute_Order__c = 1, Attribute_Type__c = 'Number', AttributeName__c = listOfAttributeConfig.get(3).id));
        listOfProductChargeAttribute.add(new Product_Charge_Attribute__c(Product_Rate_Plan_Charge__c = listProductRatePlanCharges.get(1).id, Attribute_Name__c = 'City', Attribute_Order__c = 1, Attribute_Type__c = 'String', AttributeName__c = listOfAttributeConfig.get(4).id));
        listOfProductChargeAttribute.add(new Product_Charge_Attribute__c(Product_Rate_Plan_Charge__c = listProductRatePlanCharges.get(1).id, Attribute_Name__c = 'City', Attribute_Order__c = 1, Attribute_Type__c = 'Number', AttributeName__c = listOfAttributeConfig.get(5).id));
        listOfProductChargeAttribute.add(new Product_Charge_Attribute__c(Product_Rate_Plan_Charge__c = listProductRatePlanCharges.get(1).id, Attribute_Name__c = 'City', Attribute_Order__c = 1, Attribute_Type__c = 'String', AttributeName__c = listOfAttributeConfig.get(6).id));
        listOfProductChargeAttribute.add(new Product_Charge_Attribute__c(Product_Rate_Plan_Charge__c = listProductRatePlanCharges.get(1).id, Attribute_Name__c = 'City', Attribute_Order__c = 1, Attribute_Type__c = 'Number', AttributeName__c = listOfAttributeConfig.get(7).id));
        listOfProductChargeAttribute.add(new Product_Charge_Attribute__c(Product_Rate_Plan_Charge__c = listProductRatePlanCharges.get(1).id, Attribute_Name__c = 'City', Attribute_Order__c = 1, Attribute_Type__c = 'String', AttributeName__c = listOfAttributeConfig.get(8).id));
        listOfProductChargeAttribute.add(new Product_Charge_Attribute__c(Product_Rate_Plan_Charge__c = listProductRatePlanCharges.get(1).id, Attribute_Name__c = 'City', Attribute_Order__c = 1, Attribute_Type__c = 'Number', AttributeName__c = listOfAttributeConfig.get(9).id));
        listOfProductChargeAttribute.add(new Product_Charge_Attribute__c(Product_Rate_Plan_Charge__c = listProductRatePlanCharges.get(1).id, Attribute_Name__c = 'City', Attribute_Order__c = 1, Attribute_Type__c = 'String', AttributeName__c = listOfAttributeConfig.get(10).id));
        listOfProductChargeAttribute.add(new Product_Charge_Attribute__c(Product_Rate_Plan_Charge__c = listProductRatePlanCharges.get(1).id, Attribute_Name__c = 'City', Attribute_Order__c = 1, Attribute_Type__c = 'Number', AttributeName__c = listOfAttributeConfig.get(11).id));
        listOfProductChargeAttribute.add(new Product_Charge_Attribute__c(Product_Rate_Plan_Charge__c = listProductRatePlanCharges.get(1).id, Attribute_Name__c = 'City', Attribute_Order__c = 1, Attribute_Type__c = 'Number', AttributeName__c = listOfAttributeConfig.get(12).id));
        insert listOfProductChargeAttribute;
        
        Opportunity opportunity1 = new Opportunity(Name = 'Acertis Cloud Test Oppty', AccountId = account.id, Amount = 123.50,                                                      
                                                       CloseDate = system.today(), StageName = 'Needs Analysis'
                                                      );
        insert opportunity1;
            
        invoiceit_crmx__Opportunity_Product__c  oppProduct= new invoiceit_crmx__Opportunity_Product__c(Name = 'Opp Product', invoiceit_crmx__Opportunity__c = opportunity1.Id, invoiceit_crmx__Product__c = product.id);
        insert oppProduct;

        invoiceit_crmx__Opportunity_Rate_Plan__c oppProductRatePlan = new invoiceit_crmx__Opportunity_Rate_Plan__c(Name = 'Opp Product Rate Plan', invoiceit_crmx__Opportunity_Product__c = oppProduct.Id, invoiceit_crmx__Product_Rate_Plan__c = productRatePlan.id);
        insert oppProductRatePlan;
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c OppCharge = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(invoiceit_crmx__Price_Type__c = 'One Time', invoiceit_crmx__Unit_Price__c = 100, invoiceit_crmx__Opportunity_Rate_Plan__c = oppProductRatePlan.id, invoiceit_crmx__Product_Rate_Plan_Charge__c = listProductRatePlanCharges.get(1).id, Quote_Type__c = 'New');          
        insert OppCharge;       
        
    }
    
    static testMethod void classOnOrder(){
        
        Account account = new Account(name = 'Test Account');
        insert account;
        
        invoiceit_s__Currency__c currencyObj = new invoiceit_s__Currency__c(Name = 'USD',
                                                                            invoiceit_s__Symbol__c = '$'
                                                                            );
        insert currencyObj;
        
        invoiceit_s__Job__c job = new invoiceit_s__Job__c(invoiceit_s__Account__c = account.id, invoiceit_s__Service_Activation_Date__c = system.today(),
                                                          invoiceit_s__Status__c = 'In Progress', invoiceit_s__CurrencyL__c = currencyObj.Id,
                                                          invoiceit_s__Service_End_Date__c = system.today().addMonths(5),
                                                          Quote_Type__c = 'Test');
        
        insert job;
        
        try{
            invoiceit_s__Job__c job1 = new invoiceit_s__Job__c(invoiceit_s__Account__c = account.id, invoiceit_s__Service_Activation_Date__c = system.today(),
                                                          invoiceit_s__Status__c = 'In Progress', invoiceit_s__CurrencyL__c = currencyObj.Id,
                                                          invoiceit_s__Service_End_Date__c = system.today().addMonths(5),
                                                          Quote_Type__c = 'Test');
        
            insert job1;
            
        } catch(Exception ex){
            
        }
        
        job.Quote_Type__c = 'Renew';
        job.Recalculate_Date__c = true;
        update job;
        
    } 
    
    static testMethod void classOnOrderRatePlanCharge(){
        MDL_UtilClass_TestClass utilclass = new MDL_UtilClass_TestClass();
        Account account = new Account(name = 'Test Account');
        insert account;
        
        invoiceit_s__Currency__c currencyObj = new invoiceit_s__Currency__c(Name = 'USD',
                                                                            invoiceit_s__Symbol__c = '$'
                                                                            );
        insert currencyObj;
        
        
        
        
        
        invoiceit_s__Product__c product = new  invoiceit_s__Product__c(Name = 'Test Product',
                                                                       invoiceit_s__Valid_From_Date__c = Date.today(),
                                                                       invoiceit_s__Valid_To_Date__c = Date.today()+90,
                                                                       invoiceit_s__Product_Family__c = 'Default',
                                                                       invoiceit_s__Product_Code__c = 'Code1',
                                                                       invoiceit_s__Description__c = 'Product'
                                                                       );
        insert product;
        
        invoiceit_s__Product_Rate_Plan__c productRatePlan = new  invoiceit_s__Product_Rate_Plan__c(Name = 'Test ProductRatePlan',
                                                                                                   invoiceit_s__Product__c = product.Id,
                                                                                                   invoiceit_s__Valid_From_Date__c = Date.today(),
                                                                                                   invoiceit_s__Valid_To_Date__c = Date.today()+90
                                                                                                   );
        insert productRatePlan;
                                                                                                   
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = new invoiceit_s__Product_Rate_Plan_Charge__c(Name = 'Setup Charges',
                                                                                                                       invoiceit_s__CurrencyL__c = currencyObj.Id,
                                                                                                                       invoiceit_s__Product_Rate_Plan__c = productRatePlan.Id,
                                                                                                                       invoiceit_s__Unit_Price__c = 1000,
                                                                                                                       invoiceit_s__Cost_Price__c = 500,                                                                  
                                                                                                                       invoiceit_s__Price_Type__c = 'One Time'      
                                                                                                                       );
       
        insert productRatePlanCharge;
        
        list<Product_Charge_Attribute__c> listOfProductChargeAttribute = new list<Product_Charge_Attribute__c>();
        listOfProductChargeAttribute.add(new Product_Charge_Attribute__c(Product_Rate_Plan_Charge__c = productRatePlanCharge.id, Attribute_Name__c = 'City', Attribute_Order__c = 1, Attribute_Type__c = 'String'));
        listOfProductChargeAttribute.add(new Product_Charge_Attribute__c(Product_Rate_Plan_Charge__c = productRatePlanCharge.id, Attribute_Name__c = 'City', Attribute_Order__c = 1, Attribute_Type__c = 'Number'));
        listOfProductChargeAttribute.add(new Product_Charge_Attribute__c(Product_Rate_Plan_Charge__c = productRatePlanCharge.id, Attribute_Name__c = 'City', Attribute_Order__c = 1, Attribute_Type__c = 'String'));
        listOfProductChargeAttribute.add(new Product_Charge_Attribute__c(Product_Rate_Plan_Charge__c = productRatePlanCharge.id, Attribute_Name__c = 'City', Attribute_Order__c = 1, Attribute_Type__c = 'Number'));
        insert listOfProductChargeAttribute;
        
        
        
        
         
        Opportunity opportunity1 = new Opportunity(Name = 'Acertis Cloud Test Oppty', AccountId = account.id, Amount = 123.50,                                                      
                                                       CloseDate = system.today(), StageName = 'Needs Analysis'
                                                      );
        insert opportunity1;
            
        invoiceit_crmx__Opportunity_Product__c  oppProduct= new invoiceit_crmx__Opportunity_Product__c(Name = 'Opp Product', invoiceit_crmx__Opportunity__c = opportunity1.Id, invoiceit_crmx__Product__c = product.id);
        insert oppProduct;

        invoiceit_s__Product__c prod = utilclass.getProduct('true');
        invoiceit_s__Product_Rate_Plan__c prodrateplan = utilclass.getProductRatePlan(prod.Id);    
        invoiceit_crmx__Opportunity_Rate_Plan__c oppProductRatePlan = utilclass.getOpportunityRatePlan(oppProduct.Id,prodrateplan.Id);
        //invoiceit_crmx__Opportunity_Rate_Plan__c oppProductRatePlan = new invoiceit_crmx__Opportunity_Rate_Plan__c(Name = 'Opp Product Rate Plan', invoiceit_crmx__Opportunity_Product__c = oppProduct.Id);
        //insert oppProductRatePlan;
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c OppCharge = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(invoiceit_crmx__Price_Type__c = 'One Time', invoiceit_crmx__Unit_Price__c = 100, invoiceit_crmx__Opportunity_Rate_Plan__c = oppProductRatePlan.id, Quote_Type__c = 'New');          
        insert OppCharge;
        
        list<Opportunity_Charge_Attribute__c> listOfOppChargeAttribute = new list<Opportunity_Charge_Attribute__c>();
        listOfOppChargeAttribute.add(new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppCharge.id, Attribute_Name__c = 'City', Attribute_Order__c = 1, Attribute_Type__c = 'String', Attribute_Picklist_Values__c = 'Test Test', Boolean_Value__c = true,
                                                                             Date_Value__c = system.today(), Maximum_No_Of_Characters_In_Text__c = 0, Minimum_No_Of_Characters_In_Text__c = 10, Number_Value__c = 10, Phone_Value__c = '1111111111', Picklist_Value__c = 'Text',
                                                                             String_Value__c = 'String'));
        listOfOppChargeAttribute.add(new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppCharge.id, Attribute_Name__c = 'City', Attribute_Order__c = 1, Attribute_Type__c = 'Number', Attribute_Picklist_Values__c = 'Test Test', Boolean_Value__c = true,
                                                                             Date_Value__c = system.today(), Maximum_No_Of_Characters_In_Text__c = 0, Minimum_No_Of_Characters_In_Text__c = 10, Number_Value__c = 10, Phone_Value__c = '1111111111', Picklist_Value__c = 'Text',
                                                                             String_Value__c = 'String'));          
        insert listOfOppChargeAttribute;
        
        
        
        
        invoiceit_s__Job__c job = new invoiceit_s__Job__c(invoiceit_s__Account__c = account.id, invoiceit_s__Service_Activation_Date__c = system.today(),
                                                          invoiceit_s__Status__c = 'In Progress', invoiceit_s__CurrencyL__c = currencyObj.Id,
                                                          invoiceit_s__Service_End_Date__c = system.today().addMonths(5),
                                                          Quote_Type__c = 'Test', invoiceit_s__Number_Of_Terms__c = 5);
        
        insert job;
        
        invoiceit_s__Job_Product__c  jobProduct= new invoiceit_s__Job_Product__c(Name = 'jobProduct', invoiceit_s__Job__c = job.Id);
        insert jobProduct;

        invoiceit_s__Job_Rate_Plan__c jobRP = new invoiceit_s__Job_Rate_Plan__c(Name = 'JobRP', invoiceit_s__Job_Product__c =jobProduct.Id);
        insert jobRP;
        
        invoiceit_s__Job_Rate_Plan_Charge__c charge = new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC', invoiceit_s__Job_Rate_Plan__c =jobRP.Id,
                                                                                               invoiceit_s__Quantity__c = 12, invoiceit_s__Price_Type__c = 'One Time',
                                                                                               invoiceit_s__Unit_Price__c = 12,invoiceit_s__Service_Activation_Date__c = system.today(),
                                                                                               invoiceit_s__Service_End_Date__c = system.today().addMonths(5)                                                                                               
                                                                                               );
        insert charge;
        
        list<invoiceit_s__Job_Rate_Plan_Charge__c> listOfOrderCharges = new list<invoiceit_s__Job_Rate_Plan_Charge__c>();
        listOfOrderCharges.add(new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC', invoiceit_s__Job_Rate_Plan__c =jobRP.Id,
                                                                                               invoiceit_s__Quantity__c = 12, invoiceit_s__Price_Type__c = 'One Time',
                                                                                               invoiceit_s__Unit_Price__c = 12,invoiceit_s__Service_Activation_Date__c = system.today(),
                                                                                               invoiceit_s__Service_End_Date__c = system.today().addMonths(5),
                                                                                               Quote_Type__c = 'Renew', Created_From_Charge__c = charge.id
                                                                                               ));
        
        listOfOrderCharges.add(new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC', invoiceit_s__Job_Rate_Plan__c =jobRP.Id,
                                                                                               invoiceit_s__Quantity__c = 12, invoiceit_s__Price_Type__c = 'Monthly',
                                                                                               invoiceit_s__Unit_Price__c = 47,invoiceit_s__Service_Activation_Date__c = system.today(),
                                                                                               invoiceit_s__Service_End_Date__c = system.today().addMonths(5),
                                                                                               Quote_Type__c = 'Modify', Created_From_Charge__c = charge.id
                                                                                               ));
        
        listOfOrderCharges.add(new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC', invoiceit_s__Job_Rate_Plan__c =jobRP.Id,
                                                                                               invoiceit_s__Quantity__c = 12, invoiceit_s__Price_Type__c = 'Yearly',
                                                                                               invoiceit_s__Unit_Price__c = 47,invoiceit_s__Service_Activation_Date__c = system.today(),
                                                                                               invoiceit_s__Service_End_Date__c = system.today().addMonths(5),                                                                                               
                                                                                               Opportunity_Rate_Plan_Charge__c = OppCharge.id
                                                                                               )); 
        listOfOrderCharges.add(new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC', invoiceit_s__Job_Rate_Plan__c =jobRP.Id,
                                                                                               invoiceit_s__Quantity__c = 12, invoiceit_s__Price_Type__c = 'Weekly',
                                                                                               invoiceit_s__Unit_Price__c = 47,invoiceit_s__Service_Activation_Date__c = system.today(),
                                                                                               invoiceit_s__Service_End_Date__c = system.today().addMonths(5),                                                                                               
                                                                                               invoiceit_s__Product_Rate_Plan_Charge__c = productRatePlanCharge.id
                                                                                               ));         
        insert listOfOrderCharges;
        
        
        //ApexPages.StandardController stdControllerOrderObj = new ApexPages.StandardController(charge);
        ClassOnOrderRatePlanCharge ClassOnOrderRatePlanChargeObj = new ClassOnOrderRatePlanCharge(); 
        
        ClassOnOrderRatePlanChargeObj.FkMethod();

        
        
    }
    
}