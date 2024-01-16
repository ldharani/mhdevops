@isTest(seeAlldata = true)
public class Test_PackageSelectionPageCtrl{
    static testmethod void testPackage(){
        
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc = util.getAccount();
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        Contact con = util.getContact(acc.Id);
        
        invoiceit_s__Product__c prod1 = util.getProduct('false');
        invoiceit_s__Product__c prod2 = util.getProduct('true');
        invoiceit_s__Product__c prod3 = util.getProduct('false');
         invoiceit_s__Product__c prod4 = util.getProduct('false');
        
        invoiceit_s__Product_Rate_Plan__c prp = util.getProductRatePlan(prod1.Id);
        invoiceit_s__Product_Rate_Plan__c prp2 = util.getProductRatePlan(prod2.Id);
        invoiceit_s__Product_Rate_Plan__c prp3 = util.getProductRatePlan(prod3.Id);
        invoiceit_s__Product_Rate_Plan__c prp4 = util.getProductRatePlan(prod4.Id);
        
        invoiceit_s__Product_Rate_Plan_Charge__c prpc = util.getProductRatePlanCharge(curr.Id , prp.Id);
        prpc.Package_Wrapper__c = true;
        insert prpc;
        
        invoiceit_s__Product_Rate_Plan_Charge__c prpc2 = util.getProductRatePlanCharge(curr.Id , prp2.Id);
        prpc2.Package_Component__c = true;
        insert prpc2;
        
        invoiceit_s__Product_Rate_Plan_Charge__c prpc3 = util.getProductRatePlanCharge(curr.Id , prp3.Id);
        prpc3.Package_Component__c = True;
        insert prpc3;
        
        invoiceit_s__Product_Rate_Plan_Charge__c prpc4 = util.getProductRatePlanCharge(curr.Id , prp4.Id);
        prpc4.Package_Component__c = False;
        insert prpc4;
        
        Opportunity opp = util.getOpportunity(acc.Id , con.Id ,curr.Id ); 
        opp.Name = 'Test test';
        update opp;
        
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod1.Id,opp.Id);
        oppprod1.invoiceit_crmx__Product_Family__c = 'Package';
        oppprod1.invoiceit_crmx__SequenceNumber__c=1;
        update oppprod1;
        
        invoiceit_crmx__Opportunity_Product__c oppprod2 = util.getOpportunityProduct(prod2.Id,opp.Id);
        oppprod2.invoiceit_crmx__SequenceNumber__c=2;
        update oppprod2;
        
        invoiceit_crmx__Opportunity_Product__c oppprod3 = util.getOpportunityProduct(prod3.Id,opp.Id);
        oppprod3.invoiceit_crmx__SequenceNumber__c=3;
        update oppprod3;
        
        invoiceit_crmx__Opportunity_Product__c oppprod4 = util.getOpportunityProduct(prod4.Id,opp.Id);
        oppprod1.invoiceit_crmx__SequenceNumber__c=4;
        update oppprod4;
        
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp = util.getOpportunityRatePlan(oppprod1.Id , prp.Id);
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp2 = util.getOpportunityRatePlan(oppprod2.Id , prp2.Id);
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp3 = util.getOpportunityRatePlan(oppprod3.Id , prp3.Id);
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp4 = util.getOpportunityRatePlan(oppprod4.Id , prp4.Id);
        
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> selectedChargeList = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> alacarteChargeList = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prpc.Id);
        opprpc.invoiceit_crmx__Accounting_Code__c = '50010';
        opprpc.Quote_Type__c = 'New';
        update opprpc;
        selectedChargeList.add(opprpc);
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc2 = util.getOppRatePlanCharge(opprp2.Id , prpc2.Id);
        opprpc2.invoiceit_crmx__Accounting_Code__c = '11006';
        opprpc2.name = 'Professional Profile - Pkg Component';
        opprpc2.Quote_Type__c = 'New';
        update opprpc2;
        selectedChargeList.add(opprpc2);
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc3 = util.getOppRatePlanCharge(opprp3.Id , prpc3.Id);
        opprpc3.invoiceit_crmx__Accounting_Code__c = '01808';
        opprpc3.name = 'Web Bronze - Pkg';
        opprpc3.Quote_Type__c = 'New';
        update opprpc3;
        //selectedChargeList.add(opprpc3);
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc4 = util.getOppRatePlanCharge(opprp4.Id , prpc4.Id);
        opprpc4.invoiceit_crmx__Accounting_Code__c = '01811';
        opprpc4.name = 'Professional Profile';
        opprpc4.Quote_Type__c = 'New';
        update opprpc4;
        //alacarteChargeList.add(opprpc4);
        
        Map<Id, List<invoiceit_s__Product_Rate_Plan_Charge__c>> rpcIdVsProdRPCMap = new Map<Id, List<invoiceit_s__Product_Rate_Plan_Charge__c>>();
        
        List<invoiceit_s__Product_Rate_Plan_Charge__c> prodRPCList = [Select id, name From invoiceit_s__Product_Rate_Plan_Charge__c where invoiceit_s__Accounting_Code__c='01808'];
        
        //rpcIdVsProdRPCMap.put(opprpc3.id, prodRPCList);
        rpcIdVsProdRPCMap.put(opprpc4.id, prodRPCList);
        
        prpc3.Package_Component__c = False;
        update prpc3;
        
        opprpc3.invoiceit_crmx__Product_Rate_Plan_Charge__c = null; //rpcIdVsProdRPCMap.get(opprpc3.id)[0].id;
        update opprpc3;
         alacarteChargeList.add(opprpc3);
        
        Opportunity_Charge_Attribute__c oppChargeAttr1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc.id, Attribute_Type__c = 'Text',String_Value__c='ABC');
        insert oppChargeAttr1; 
        
        Opportunity_Charge_Attribute__c oppChargeAttr2 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc2.id, Attribute_Type__c = 'Text',String_Value__c='DEF');
        insert oppChargeAttr2; 
        
        Opportunity_Charge_Attribute__c oppChargeAttr3 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc3.id, Attribute_Type__c = 'Text',String_Value__c='GHI');
        insert oppChargeAttr3; 
        
        Opportunity_Charge_Attribute__c oppChargeAttr4 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc4.id, Attribute_Type__c = 'Text',String_Value__c='JKL');
        insert oppChargeAttr4; 
        
        //String testString = '{silver'+':'+'[{id:'+opprpc2.id+',name:Professional Profile - Pkg Component}'+','+'{id:'+opprpc3.id+',name:Web Bronze - Pkg}]}'+','+'bronze:[]'+','+'aLaCarte:[]';
        
        
        
        packageWrapper wrapper = new packageWrapper();
        wrapper.silver = selectedChargeList;
        wrapper.gold = null;
        wrapper.platinum = null;
        wrapper.alacarte = alacarteChargeList;
        wrapper.bronze = null;
        wrapper.oppRPCIdVsProdRPCId = null;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id',opp.id);
        ApexPages.currentPage().getParameters().put('acCode',opprpc4.invoiceit_crmx__Accounting_Code__c);
        ApexPages.currentPage().getParameters().put('oppRPCId',opprpc.Id);
        ApexPages.currentPage().getParameters().put('prpcId',prpc2.id);
        
        PackageSelectionPageCtrl contollr= new PackageSelectionPageCtrl();
        contollr.submit();
        contollr.cancelPage2();
        contollr.showPopUp();
        contollr.cancel();
        contollr.save();
        contollr.getRecords();
        System.debug('@@@@@@@@@@rpcIdVsProdRPCMap details------------->'+JSON.serialize(rpcIdVsProdRPCMap));
        
        
        
        
        PackageSelectionPageCtrl.saveData(JSON.serialize(wrapper), 'silver', opp.id, JSON.serialize(rpcIdVsProdRPCMap), 'test');
        //saveData(String packageWrapperJSON,String selectedPackage,String opportunityId,String rpcIdVsProdRPCMap,String oppRPCIdVsProdRPCMap)
        Test.stopTest();
        
    }
    
    static testmethod void goldPackage(){
        
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc = util.getAccount();
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        Contact con = util.getContact(acc.Id);
        
        invoiceit_s__Product__c prod1 = util.getProduct('false');
        invoiceit_s__Product__c prod2 = util.getProduct('true');
        invoiceit_s__Product__c prod3 = util.getProduct('false');
         invoiceit_s__Product__c prod4 = util.getProduct('false');
        
        invoiceit_s__Product_Rate_Plan__c prp = util.getProductRatePlan(prod1.Id);
        invoiceit_s__Product_Rate_Plan__c prp2 = util.getProductRatePlan(prod2.Id);
        invoiceit_s__Product_Rate_Plan__c prp3 = util.getProductRatePlan(prod3.Id);
        invoiceit_s__Product_Rate_Plan__c prp4 = util.getProductRatePlan(prod4.Id);
        
        invoiceit_s__Product_Rate_Plan_Charge__c prpc = util.getProductRatePlanCharge(curr.Id , prp.Id);
        prpc.Package_Wrapper__c = true;
        insert prpc;
        
        invoiceit_s__Product_Rate_Plan_Charge__c prpc2 = util.getProductRatePlanCharge(curr.Id , prp2.Id);
        prpc2.Package_Component__c = true;
        insert prpc2;
        
        invoiceit_s__Product_Rate_Plan_Charge__c prpc3 = util.getProductRatePlanCharge(curr.Id , prp3.Id);
        prpc3.Package_Component__c = True;
        insert prpc3;
        
        invoiceit_s__Product_Rate_Plan_Charge__c prpc4 = util.getProductRatePlanCharge(curr.Id , prp4.Id);
        prpc4.Package_Component__c = False;
        insert prpc4;
        
        Opportunity opp = util.getOpportunity(acc.Id , con.Id ,curr.Id ); 
        opp.Name = 'Test test';
        update opp;
        
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod1.Id,opp.Id);
        oppprod1.invoiceit_crmx__Product_Family__c = 'Package';
        oppprod1.invoiceit_crmx__SequenceNumber__c=1;
        update oppprod1;
        
        invoiceit_crmx__Opportunity_Product__c oppprod2 = util.getOpportunityProduct(prod2.Id,opp.Id);
        oppprod2.invoiceit_crmx__SequenceNumber__c=2;
        update oppprod2;
        
        invoiceit_crmx__Opportunity_Product__c oppprod3 = util.getOpportunityProduct(prod3.Id,opp.Id);
        oppprod3.invoiceit_crmx__SequenceNumber__c=3;
        update oppprod3;
        
        invoiceit_crmx__Opportunity_Product__c oppprod4 = util.getOpportunityProduct(prod4.Id,opp.Id);
        oppprod1.invoiceit_crmx__SequenceNumber__c=4;
        update oppprod4;
        
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp = util.getOpportunityRatePlan(oppprod1.Id , prp.Id);
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp2 = util.getOpportunityRatePlan(oppprod2.Id , prp2.Id);
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp3 = util.getOpportunityRatePlan(oppprod3.Id , prp3.Id);
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp4 = util.getOpportunityRatePlan(oppprod4.Id , prp4.Id);
        
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> selectedChargeList = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> alacarteChargeList = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prpc.Id);
        opprpc.invoiceit_crmx__Accounting_Code__c = '50030';
        opprpc.Quote_Type__c = 'New';
        update opprpc;
        selectedChargeList.add(opprpc);
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc2 = util.getOppRatePlanCharge(opprp2.Id , prpc2.Id);
        opprpc2.invoiceit_crmx__Accounting_Code__c = '11006';
        opprpc2.name = 'Professional Profile - Pkg Component';
        opprpc2.Quote_Type__c = 'New';
        update opprpc2;
        selectedChargeList.add(opprpc2);
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc3 = util.getOppRatePlanCharge(opprp3.Id , prpc3.Id);
        opprpc3.invoiceit_crmx__Accounting_Code__c = '01972';
        opprpc3.name = 'Web Bronze - Pkg';
        opprpc3.Quote_Type__c = 'New';
        update opprpc3;
        //selectedChargeList.add(opprpc3);
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc4 = util.getOppRatePlanCharge(opprp4.Id , prpc4.Id);
        opprpc4.invoiceit_crmx__Accounting_Code__c = '01811';
        opprpc4.name = 'Professional Profile';
        opprpc4.Quote_Type__c = 'New';
        update opprpc4;
        //alacarteChargeList.add(opprpc4);
        
        Map<Id, List<invoiceit_s__Product_Rate_Plan_Charge__c>> rpcIdVsProdRPCMap = new Map<Id, List<invoiceit_s__Product_Rate_Plan_Charge__c>>();
        
        List<invoiceit_s__Product_Rate_Plan_Charge__c> prodRPCList = [Select id, name From invoiceit_s__Product_Rate_Plan_Charge__c where invoiceit_s__Accounting_Code__c='01811'];
        
        //rpcIdVsProdRPCMap.put(opprpc3.id, prodRPCList);
        rpcIdVsProdRPCMap.put(opprpc4.id, prodRPCList);
        
        prpc3.Package_Component__c = False;
        update prpc3;
        
        opprpc3.invoiceit_crmx__Product_Rate_Plan_Charge__c = null;//rpcIdVsProdRPCMap.get(opprpc3.id)[0].id;
        update opprpc3;
         alacarteChargeList.add(opprpc3);
        
        Opportunity_Charge_Attribute__c oppChargeAttr1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc.id, Attribute_Type__c = 'Text',String_Value__c='ABC');
        insert oppChargeAttr1; 
        
        Opportunity_Charge_Attribute__c oppChargeAttr2 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc2.id, Attribute_Type__c = 'Text',String_Value__c='DEF');
        insert oppChargeAttr2; 
        
        Opportunity_Charge_Attribute__c oppChargeAttr3 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc3.id, Attribute_Type__c = 'Text',String_Value__c='GHI');
        insert oppChargeAttr3; 
        
        Opportunity_Charge_Attribute__c oppChargeAttr4 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc4.id, Attribute_Type__c = 'Text',String_Value__c='JKL');
        insert oppChargeAttr4; 
        
        //String testString = '{silver'+':'+'[{id:'+opprpc2.id+',name:Professional Profile - Pkg Component}'+','+'{id:'+opprpc3.id+',name:Web Bronze - Pkg}]}'+','+'bronze:[]'+','+'aLaCarte:[]';
        
        
        
        packageWrapper wrapper = new packageWrapper();
        wrapper.silver = null;
        wrapper.gold = selectedChargeList;
        wrapper.platinum = null;
        wrapper.alacarte = alacarteChargeList;
        wrapper.bronze = null;
        wrapper.oppRPCIdVsProdRPCId = null;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id',opp.id);
        ApexPages.currentPage().getParameters().put('acCode',opprpc4.invoiceit_crmx__Accounting_Code__c);
        ApexPages.currentPage().getParameters().put('oppRPCId',opprpc.Id);
        ApexPages.currentPage().getParameters().put('prpcId',prpc2.id);
        
        PackageSelectionPageCtrl contollr= new PackageSelectionPageCtrl();
        contollr.submit();
        contollr.cancelPage2();
        contollr.showPopUp();
        contollr.cancel();
        contollr.save();
        contollr.getRecords();
        System.debug('@@@@@@@@@@rpcIdVsProdRPCMap details------------->'+JSON.serialize(rpcIdVsProdRPCMap));
        
        
        
        
        PackageSelectionPageCtrl.saveData(JSON.serialize(wrapper), 'gold', opp.id, JSON.serialize(rpcIdVsProdRPCMap), 'test');
        //saveData(String packageWrapperJSON,String selectedPackage,String opportunityId,String rpcIdVsProdRPCMap,String oppRPCIdVsProdRPCMap)
        Test.stopTest();
        
    }
    
    static testmethod void platinumPackage(){
        
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc = util.getAccount();
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        Contact con = util.getContact(acc.Id);
        
        invoiceit_s__Product__c prod1 = util.getProduct('false');
        invoiceit_s__Product__c prod2 = util.getProduct('true');
        invoiceit_s__Product__c prod3 = util.getProduct('false');
         invoiceit_s__Product__c prod4 = util.getProduct('false');
        
        invoiceit_s__Product_Rate_Plan__c prp = util.getProductRatePlan(prod1.Id);
        invoiceit_s__Product_Rate_Plan__c prp2 = util.getProductRatePlan(prod2.Id);
        invoiceit_s__Product_Rate_Plan__c prp3 = util.getProductRatePlan(prod3.Id);
        invoiceit_s__Product_Rate_Plan__c prp4 = util.getProductRatePlan(prod4.Id);
        
        invoiceit_s__Product_Rate_Plan_Charge__c prpc = util.getProductRatePlanCharge(curr.Id , prp.Id);
        prpc.Package_Wrapper__c = true;
        insert prpc;
        
        invoiceit_s__Product_Rate_Plan_Charge__c prpc2 = util.getProductRatePlanCharge(curr.Id , prp2.Id);
        prpc2.Package_Component__c = true;
        insert prpc2;
        
        invoiceit_s__Product_Rate_Plan_Charge__c prpc3 = util.getProductRatePlanCharge(curr.Id , prp3.Id);
        prpc3.Package_Component__c = True;
        insert prpc3;
        
        invoiceit_s__Product_Rate_Plan_Charge__c prpc4 = util.getProductRatePlanCharge(curr.Id , prp4.Id);
        prpc4.Package_Component__c = False;
        insert prpc4;
        
        Opportunity opp = util.getOpportunity(acc.Id , con.Id ,curr.Id ); 
        opp.Name = 'Test test';
        update opp;
        
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod1.Id,opp.Id);
        oppprod1.invoiceit_crmx__Product_Family__c = 'Package';
        oppprod1.invoiceit_crmx__SequenceNumber__c=1;
        update oppprod1;
        
        invoiceit_crmx__Opportunity_Product__c oppprod2 = util.getOpportunityProduct(prod2.Id,opp.Id);
        oppprod2.invoiceit_crmx__SequenceNumber__c=2;
        update oppprod2;
        
        invoiceit_crmx__Opportunity_Product__c oppprod3 = util.getOpportunityProduct(prod3.Id,opp.Id);
        oppprod3.invoiceit_crmx__SequenceNumber__c=3;
        update oppprod3;
        
        invoiceit_crmx__Opportunity_Product__c oppprod4 = util.getOpportunityProduct(prod4.Id,opp.Id);
        oppprod1.invoiceit_crmx__SequenceNumber__c=4;
        update oppprod4;
        
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp = util.getOpportunityRatePlan(oppprod1.Id , prp.Id);
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp2 = util.getOpportunityRatePlan(oppprod2.Id , prp2.Id);
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp3 = util.getOpportunityRatePlan(oppprod3.Id , prp3.Id);
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp4 = util.getOpportunityRatePlan(oppprod4.Id , prp4.Id);
        
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> selectedChargeList = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> alacarteChargeList = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prpc.Id);
        opprpc.invoiceit_crmx__Accounting_Code__c = '50040';
        opprpc.Quote_Type__c = 'New';
        update opprpc;
        selectedChargeList.add(opprpc);
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc2 = util.getOppRatePlanCharge(opprp2.Id , prpc2.Id);
        opprpc2.invoiceit_crmx__Accounting_Code__c = '11006';
        opprpc2.name = 'Professional Profile - Pkg Component';
        opprpc2.Quote_Type__c = 'New';
        update opprpc2;
        selectedChargeList.add(opprpc2);
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc3 = util.getOppRatePlanCharge(opprp3.Id , prpc3.Id);
        opprpc3.invoiceit_crmx__Accounting_Code__c = '01809';
        opprpc3.name = 'Web Bronze - Pkg';
        opprpc3.Quote_Type__c = 'New';
        update opprpc3;
        //selectedChargeList.add(opprpc3);
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc4 = util.getOppRatePlanCharge(opprp4.Id , prpc4.Id);
        opprpc4.invoiceit_crmx__Accounting_Code__c = '01811';
        opprpc4.name = 'Professional Profile';
        opprpc4.Quote_Type__c = 'New';
        update opprpc4;
        //alacarteChargeList.add(opprpc4);
        
        Map<Id, List<invoiceit_s__Product_Rate_Plan_Charge__c>> rpcIdVsProdRPCMap = new Map<Id, List<invoiceit_s__Product_Rate_Plan_Charge__c>>();
        
        List<invoiceit_s__Product_Rate_Plan_Charge__c> prodRPCList = [Select id, name From invoiceit_s__Product_Rate_Plan_Charge__c where invoiceit_s__Accounting_Code__c='01811'];
        
        //rpcIdVsProdRPCMap.put(opprpc3.id, prodRPCList);
        rpcIdVsProdRPCMap.put(opprpc4.id, prodRPCList);
        
        prpc3.Package_Component__c = False;
        update prpc3;
        
        opprpc3.invoiceit_crmx__Product_Rate_Plan_Charge__c = null;//rpcIdVsProdRPCMap.get(opprpc3.id)[0].id;
        update opprpc3;
         alacarteChargeList.add(opprpc3);
        
        Opportunity_Charge_Attribute__c oppChargeAttr1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc.id, Attribute_Type__c = 'Text',String_Value__c='ABC');
        insert oppChargeAttr1; 
        
        Opportunity_Charge_Attribute__c oppChargeAttr2 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc2.id, Attribute_Type__c = 'Text',String_Value__c='DEF');
        insert oppChargeAttr2; 
        
        Opportunity_Charge_Attribute__c oppChargeAttr3 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc3.id, Attribute_Type__c = 'Text',String_Value__c='GHI');
        insert oppChargeAttr3; 
        
        Opportunity_Charge_Attribute__c oppChargeAttr4 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc4.id, Attribute_Type__c = 'Text',String_Value__c='JKL');
        insert oppChargeAttr4; 
        
        //String testString = '{silver'+':'+'[{id:'+opprpc2.id+',name:Professional Profile - Pkg Component}'+','+'{id:'+opprpc3.id+',name:Web Bronze - Pkg}]}'+','+'bronze:[]'+','+'aLaCarte:[]';
        
        
        
        packageWrapper wrapper = new packageWrapper();
        wrapper.silver = null;
        wrapper.gold = null;
        wrapper.platinum = selectedChargeList;
        wrapper.alacarte = alacarteChargeList;
        wrapper.bronze = null;
        wrapper.oppRPCIdVsProdRPCId = null;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id',opp.id);
        ApexPages.currentPage().getParameters().put('acCode',opprpc4.invoiceit_crmx__Accounting_Code__c);
        ApexPages.currentPage().getParameters().put('oppRPCId',opprpc.Id);
        ApexPages.currentPage().getParameters().put('prpcId',prpc2.id);
        
        PackageSelectionPageCtrl contollr= new PackageSelectionPageCtrl();
        contollr.submit();
        contollr.cancelPage2();
        contollr.showPopUp();
        contollr.cancel();
        contollr.save();
        contollr.getRecords();
        System.debug('@@@@@@@@@@rpcIdVsProdRPCMap details------------->'+JSON.serialize(rpcIdVsProdRPCMap));
        
        
        
        
        PackageSelectionPageCtrl.saveData(JSON.serialize(wrapper), 'platinum', opp.id, JSON.serialize(rpcIdVsProdRPCMap), 'test');
        //saveData(String packageWrapperJSON,String selectedPackage,String opportunityId,String rpcIdVsProdRPCMap,String oppRPCIdVsProdRPCMap)
        Test.stopTest();
        
    }
    
     static testmethod void bronzePackage(){
        
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc = util.getAccount();
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        Contact con = util.getContact(acc.Id);
        
        invoiceit_s__Product__c prod1 = util.getProduct('false');
        invoiceit_s__Product__c prod2 = util.getProduct('true');
        invoiceit_s__Product__c prod3 = util.getProduct('false');
         invoiceit_s__Product__c prod4 = util.getProduct('false');
        
        invoiceit_s__Product_Rate_Plan__c prp = util.getProductRatePlan(prod1.Id);
        invoiceit_s__Product_Rate_Plan__c prp2 = util.getProductRatePlan(prod2.Id);
        invoiceit_s__Product_Rate_Plan__c prp3 = util.getProductRatePlan(prod3.Id);
        invoiceit_s__Product_Rate_Plan__c prp4 = util.getProductRatePlan(prod4.Id);
        
        invoiceit_s__Product_Rate_Plan_Charge__c prpc = util.getProductRatePlanCharge(curr.Id , prp.Id);
        prpc.Package_Wrapper__c = true;
        insert prpc;
        
        invoiceit_s__Product_Rate_Plan_Charge__c prpc2 = util.getProductRatePlanCharge(curr.Id , prp2.Id);
        prpc2.Package_Component__c = true;
        insert prpc2;
        
        invoiceit_s__Product_Rate_Plan_Charge__c prpc3 = util.getProductRatePlanCharge(curr.Id , prp3.Id);
        prpc3.Package_Component__c = True;
        insert prpc3;
        
        invoiceit_s__Product_Rate_Plan_Charge__c prpc4 = util.getProductRatePlanCharge(curr.Id , prp4.Id);
        prpc4.Package_Component__c = False;
        insert prpc4;
        
        Opportunity opp = util.getOpportunity(acc.Id , con.Id ,curr.Id ); 
        opp.Name = 'Test test';
        update opp;
        
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod1.Id,opp.Id);
        oppprod1.invoiceit_crmx__Product_Family__c = 'Package';
        oppprod1.invoiceit_crmx__SequenceNumber__c=1;
        update oppprod1;
        
        invoiceit_crmx__Opportunity_Product__c oppprod2 = util.getOpportunityProduct(prod2.Id,opp.Id);
        oppprod2.invoiceit_crmx__SequenceNumber__c=2;
        update oppprod2;
        
        invoiceit_crmx__Opportunity_Product__c oppprod3 = util.getOpportunityProduct(prod3.Id,opp.Id);
        oppprod3.invoiceit_crmx__SequenceNumber__c=3;
        update oppprod3;
        
        invoiceit_crmx__Opportunity_Product__c oppprod4 = util.getOpportunityProduct(prod4.Id,opp.Id);
        oppprod1.invoiceit_crmx__SequenceNumber__c=4;
        update oppprod4;
        
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp = util.getOpportunityRatePlan(oppprod1.Id , prp.Id);
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp2 = util.getOpportunityRatePlan(oppprod2.Id , prp2.Id);
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp3 = util.getOpportunityRatePlan(oppprod3.Id , prp3.Id);
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp4 = util.getOpportunityRatePlan(oppprod4.Id , prp4.Id);
        
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> selectedChargeList = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> alacarteChargeList = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prpc.Id);
        opprpc.invoiceit_crmx__Accounting_Code__c = '50010';
        opprpc.Quote_Type__c = 'New';
        update opprpc;
        selectedChargeList.add(opprpc);
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc2 = util.getOppRatePlanCharge(opprp2.Id , prpc2.Id);
        opprpc2.invoiceit_crmx__Accounting_Code__c = '11006';
        opprpc2.name = 'Professional Profile - Pkg Component';
        opprpc2.Quote_Type__c = 'New';
        update opprpc2;
        selectedChargeList.add(opprpc2);
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc3 = util.getOppRatePlanCharge(opprp3.Id , prpc3.Id);
        opprpc3.invoiceit_crmx__Accounting_Code__c = '01809';
        opprpc3.name = 'Web Bronze - Pkg';
        opprpc3.Quote_Type__c = 'New';
        update opprpc3;
        //selectedChargeList.add(opprpc3);
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc4 = util.getOppRatePlanCharge(opprp4.Id , prpc4.Id);
        opprpc4.invoiceit_crmx__Accounting_Code__c = '01811';
        opprpc4.name = 'Web Bronze - Pkg';
        opprpc4.Quote_Type__c = 'New';
        update opprpc4;
        selectedChargeList.add(opprpc4);
        
        Map<Id, List<invoiceit_s__Product_Rate_Plan_Charge__c>> rpcIdVsProdRPCMap = new Map<Id, List<invoiceit_s__Product_Rate_Plan_Charge__c>>();
        
        List<invoiceit_s__Product_Rate_Plan_Charge__c> prodRPCList = [Select id, name From invoiceit_s__Product_Rate_Plan_Charge__c where invoiceit_s__Accounting_Code__c='01809'];
        
        //rpcIdVsProdRPCMap.put(opprpc3.id, prodRPCList);
        rpcIdVsProdRPCMap.put(opprpc4.id, prodRPCList);
        
        prpc3.Package_Component__c = False;
        update prpc3;
        
        opprpc3.invoiceit_crmx__Product_Rate_Plan_Charge__c = null;//rpcIdVsProdRPCMap.get(opprpc3.id)[0].id;
        update opprpc3;
         alacarteChargeList.add(opprpc3);
        
        Opportunity_Charge_Attribute__c oppChargeAttr1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc.id, Attribute_Type__c = 'Text',String_Value__c='ABC');
        insert oppChargeAttr1; 
        
        Opportunity_Charge_Attribute__c oppChargeAttr2 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc2.id, Attribute_Type__c = 'Text',String_Value__c='DEF');
        insert oppChargeAttr2; 
        
        Opportunity_Charge_Attribute__c oppChargeAttr3 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc3.id, Attribute_Type__c = 'Text',String_Value__c='GHI');
        insert oppChargeAttr3; 
        
        Opportunity_Charge_Attribute__c oppChargeAttr4 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc4.id, Attribute_Type__c = 'Text',String_Value__c='JKL');
        insert oppChargeAttr4; 
        
        packageWrapper wrapper = new packageWrapper();
        wrapper.silver = null;
        wrapper.gold = null;
        wrapper.platinum = null;
        wrapper.alacarte = alacarteChargeList;
        wrapper.bronze = selectedChargeList;
        wrapper.oppRPCIdVsProdRPCId = null;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id',opp.id);
        ApexPages.currentPage().getParameters().put('acCode',opprpc3.invoiceit_crmx__Accounting_Code__c);
        ApexPages.currentPage().getParameters().put('oppRPCId',opprpc.Id);
        ApexPages.currentPage().getParameters().put('prpcId',prpc2.id);
        
        PackageSelectionPageCtrl contollr= new PackageSelectionPageCtrl();
        contollr.submit();
        contollr.cancelPage2();
        contollr.showPopUp();
        contollr.cancel();
        contollr.save();
        contollr.getRecords();
        System.debug('@@@@@@@@@@rpcIdVsProdRPCMap details------------->'+JSON.serialize(rpcIdVsProdRPCMap));
        
        
        
        
        PackageSelectionPageCtrl.saveData(JSON.serialize(wrapper), 'bronze', opp.id, JSON.serialize(rpcIdVsProdRPCMap), 'test');
        //saveData(String packageWrapperJSON,String selectedPackage,String opportunityId,String rpcIdVsProdRPCMap,String oppRPCIdVsProdRPCMap)
        Test.stopTest();
        
    }
    
    static testmethod void packageToAlacarte(){
        
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc = util.getAccount();
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        Contact con = util.getContact(acc.Id);
        
        invoiceit_s__Product__c prod1 = util.getProduct('false');
        invoiceit_s__Product__c prod2 = util.getProduct('true');
        //invoiceit_s__Product__c prod3 = util.getProduct('false');
         //invoiceit_s__Product__c prod4 = util.getProduct('false');
        
        invoiceit_s__Product_Rate_Plan__c prp = util.getProductRatePlan(prod1.Id);
        invoiceit_s__Product_Rate_Plan__c prp2 = util.getProductRatePlan(prod2.Id);
       // invoiceit_s__Product_Rate_Plan__c prp3 = util.getProductRatePlan(prod3.Id);
       // invoiceit_s__Product_Rate_Plan__c prp4 = util.getProductRatePlan(prod4.Id);
        
        invoiceit_s__Product_Rate_Plan_Charge__c prpc = util.getProductRatePlanCharge(curr.Id , prp.Id);
        prpc.Package_Wrapper__c = true;
        insert prpc;
        
        invoiceit_s__Product_Rate_Plan_Charge__c prpc2 = util.getProductRatePlanCharge(curr.Id , prp2.Id);
        prpc2.Package_Component__c = true;
        insert prpc2;
        
       /* invoiceit_s__Product_Rate_Plan_Charge__c prpc3 = util.getProductRatePlanCharge(curr.Id , prp3.Id);
        prpc3.Package_Component__c = True;
        insert prpc3;
        
        invoiceit_s__Product_Rate_Plan_Charge__c prpc4 = util.getProductRatePlanCharge(curr.Id , prp4.Id);
        prpc4.Package_Component__c = False;
        insert prpc4;*/
        
        Opportunity opp = util.getOpportunity(acc.Id , con.Id ,curr.Id ); 
        opp.Name = 'Test test';
        update opp;
        
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod1.Id,opp.Id);
        oppprod1.invoiceit_crmx__Product_Family__c = 'Package';
        oppprod1.invoiceit_crmx__SequenceNumber__c=1;
        update oppprod1;
        
        invoiceit_crmx__Opportunity_Product__c oppprod2 = util.getOpportunityProduct(prod2.Id,opp.Id);
        oppprod2.invoiceit_crmx__SequenceNumber__c=2;
        update oppprod2;
        
       /* invoiceit_crmx__Opportunity_Product__c oppprod3 = util.getOpportunityProduct(prod3.Id,opp.Id);
        oppprod3.invoiceit_crmx__SequenceNumber__c=3;
        update oppprod3;
        
        invoiceit_crmx__Opportunity_Product__c oppprod4 = util.getOpportunityProduct(prod4.Id,opp.Id);
        oppprod1.invoiceit_crmx__SequenceNumber__c=4;
        update oppprod4;*/
        
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp = util.getOpportunityRatePlan(oppprod1.Id , prp.Id);
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp2 = util.getOpportunityRatePlan(oppprod2.Id , prp2.Id);
       // invoiceit_crmx__Opportunity_Rate_Plan__c opprp3 = util.getOpportunityRatePlan(oppprod3.Id , prp3.Id);
       // invoiceit_crmx__Opportunity_Rate_Plan__c opprp4 = util.getOpportunityRatePlan(oppprod4.Id , prp4.Id);
        
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> selectedChargeList = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> alacarteChargeList = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prpc.Id);
        opprpc.invoiceit_crmx__Accounting_Code__c = '50010';
        opprpc.Quote_Type__c = 'New';
        update opprpc;
        selectedChargeList.add(opprpc);
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc2 = util.getOppRatePlanCharge(opprp2.Id , prpc2.Id);
        opprpc2.invoiceit_crmx__Accounting_Code__c = '11006';
        opprpc2.name = 'Professional Profile - Pkg Component';
        opprpc2.Quote_Type__c = 'New';
        update opprpc2;
        //alacarteChargeList.add(opprpc2);
        
     /*   invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc3 = util.getOppRatePlanCharge(opprp3.Id , prpc3.Id);
        opprpc3.invoiceit_crmx__Accounting_Code__c = '01809';
        opprpc3.name = 'Web Bronze - Pkg';
        opprpc3.Quote_Type__c = 'New';
        update opprpc3;
        alacarteChargeList.add(opprpc3);
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc4 = util.getOppRatePlanCharge(opprp4.Id , prpc4.Id);
        opprpc4.invoiceit_crmx__Accounting_Code__c = '01811';
        opprpc4.name = 'Professional Profile';
        opprpc4.Quote_Type__c = 'New';
        update opprpc4;
        alacarteChargeList.add(opprpc4);*/
        
        Map<Id, List<invoiceit_s__Product_Rate_Plan_Charge__c>> rpcIdVsProdRPCMap = new Map<Id, List<invoiceit_s__Product_Rate_Plan_Charge__c>>();
        
        List<invoiceit_s__Product_Rate_Plan_Charge__c> prodRPCList = [Select id, name From invoiceit_s__Product_Rate_Plan_Charge__c where invoiceit_s__Accounting_Code__c='11006'];
        
        //rpcIdVsProdRPCMap.put(opprpc3.id, prodRPCList);
        rpcIdVsProdRPCMap.put(opprpc.id, prodRPCList);
        
        prpc2.Package_Component__c = False;
        update prpc2;
        
        opprpc2.invoiceit_crmx__Product_Rate_Plan_Charge__c = null; //rpcIdVsProdRPCMap.get(opprpc2.id)[0].id;
        update opprpc2;
         alacarteChargeList.add(opprpc2);
        
        Opportunity_Charge_Attribute__c oppChargeAttr1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc.id, Attribute_Type__c = 'Text',String_Value__c='ABC');
        insert oppChargeAttr1; 
        
        Opportunity_Charge_Attribute__c oppChargeAttr2 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc2.id, Attribute_Type__c = 'Text',String_Value__c='DEF');
        insert oppChargeAttr2; 
        
        /*Opportunity_Charge_Attribute__c oppChargeAttr3 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc3.id, Attribute_Type__c = 'Text',String_Value__c='GHI');
        insert oppChargeAttr3; 
        
        Opportunity_Charge_Attribute__c oppChargeAttr4 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc4.id, Attribute_Type__c = 'Text',String_Value__c='JKL');
        insert oppChargeAttr4; */
        
        packageWrapper wrapper = new packageWrapper();
        wrapper.silver = null;
        wrapper.gold = selectedChargeList;
        wrapper.platinum = null;
        wrapper.alacarte = alacarteChargeList;
        wrapper.bronze = null;
        wrapper.oppRPCIdVsProdRPCId = null;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id',opp.id);
        ApexPages.currentPage().getParameters().put('acCode',opprpc2.invoiceit_crmx__Accounting_Code__c);
        ApexPages.currentPage().getParameters().put('oppRPCId',opprpc.Id);
        ApexPages.currentPage().getParameters().put('prpcId',prpc2.id);
        
        PackageSelectionPageCtrl contollr= new PackageSelectionPageCtrl();
        contollr.submit();
        contollr.cancelPage2();
        contollr.showPopUp();
        contollr.cancel();
        contollr.save();
        contollr.getRecords();
        System.debug('@@@@@@@@@@rpcIdVsProdRPCMap details------------->'+JSON.serialize(rpcIdVsProdRPCMap));
        
        
        
        
        PackageSelectionPageCtrl.saveData(JSON.serialize(wrapper), 'alacarte', opp.id, JSON.serialize(rpcIdVsProdRPCMap), 'test');
        //saveData(String packageWrapperJSON,String selectedPackage,String opportunityId,String rpcIdVsProdRPCMap,String oppRPCIdVsProdRPCMap)
        Test.stopTest();
        
    }
    
    public class packageWrapper{
        public List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> gold;
        public List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> silver;
        public List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> bronze;
        public List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> platinum;
        public List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> aLaCarte;
        public Map<String, String> oppRPCIdVsProdRPCId;
    }
    
    /*static testmethod void test2(){ 
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();    
        Account account12 = new Account(Name = 'Test Account');
        insert account12;
        
        Contact contact12 =  new Contact(LastName = 'Laxman', AccountId = account12.Id);                                 
        insert contact12;
        Date validtodate12 = Date.today();
        invoiceit_s__Currency__c currencyObj12 = new invoiceit_s__Currency__c(invoiceit_s__Currency_Symbol__c='USD');
        insert currencyObj12;
        
        invoiceit_s__Product__c product12 = new invoiceit_s__Product__c(Name = 'Test Product for tiers',invoiceit_s__Valid_From_Date__c = validtodate12,invoiceit_s__Valid_To_Date__c = validtodate12.addMonths(2),invoiceit_s__Product_Family__c = 'Default',invoiceit_s__Product_Code__c = 'Code1',invoiceit_s__Description__c = 'Product');
        insert product12;
        
        list<invoiceit_s__Product_Rate_Plan__c> listProductRatePlans12 = new list<invoiceit_s__Product_Rate_Plan__c>();
        invoiceit_s__Product_Rate_Plan__c productRatePlan12;
        for(Integer x = 0;x< 2;x++){
            productRatePlan12 = new  invoiceit_s__Product_Rate_Plan__c(  Name = 'Test ProductRatePlan' + x,invoiceit_s__Product__c = product12.Id,invoiceit_s__Valid_From_Date__c = validtodate12,invoiceit_s__Valid_To_Date__c = validtodate12.addMonths(2));
            listProductRatePlans12.add(productRatePlan12);
        }
        insert listProductRatePlans12;
        
        list<invoiceit_s__Product_Rate_Plan_Charge__c> listProductRatePlanCharges12 = new list<invoiceit_s__Product_Rate_Plan_Charge__c>();
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge_SetUp12 = new invoiceit_s__Product_Rate_Plan_Charge__c(Name = 'Setup Charges',
                                                              invoiceit_s__CurrencyL__c = currencyObj12.Id,
                                                              invoiceit_s__Product_Rate_Plan__c = listProductRatePlans12[0].Id,
                                                              invoiceit_s__Unit_price__c = 1000,
                                                              invoiceit_s__Cost_Price__c = 500,
                                                              invoiceit_s__Product_Charge_Category__c = 'Taxable',
                                                              invoiceit_s__Price_Type__c = 'One Time',
                                                              Package_Wrapper__c = true
                                                              );
        listProductRatePlanCharges12.add(productRatePlanCharge_SetUp12);
        
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge_Monthly12 = new invoiceit_s__Product_Rate_Plan_Charge__c(Name = 'Monthly Charges',
                                                              invoiceit_s__CurrencyL__c = currencyObj12.ID,
                                                              invoiceit_s__Product_Rate_Plan__c = listProductRatePlans12[0].Id,
                                                              invoiceit_s__Unit_price__c = 500,
                                                              invoiceit_s__Cost_Price__c = 250,
                                                              invoiceit_s__Product_Charge_Category__c = 'Taxable',
                                                              invoiceit_s__Price_Type__c = 'Monthly',
                                                              Package_Component__c = false,
                                                              Package_Wrapper__c = false                                                                  
                                                              );                                                       
        listProductRatePlanCharges12.add(productRatePlanCharge_Monthly12);

        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge_Monthly123 = new invoiceit_s__Product_Rate_Plan_Charge__c(Name = 'Monthly Charges',
                                                              invoiceit_s__CurrencyL__c = currencyObj12.ID,
                                                              invoiceit_s__Product_Rate_Plan__c = listProductRatePlans12[1].Id,
                                                              invoiceit_s__Unit_price__c = 500,
                                                              invoiceit_s__Cost_Price__c = 250,
                                                              invoiceit_s__Product_Charge_Category__c = 'Taxable',
                                                              invoiceit_s__Price_Type__c = 'Monthly',
                                                              Package_Component__c = TRUE
                                                              );                                                       
        listProductRatePlanCharges12.add(productRatePlanCharge_Monthly123);
        insert listProductRatePlanCharges12;
        
        list<Attribute_Config__c> listofAttributeConfig2 = new list<Attribute_Config__c> ();
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Service Account Name',Attribute_Type__c ='Text' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Xref Service Account Name',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Service Street Address',Attribute_Type__c ='Text' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Service Street Address',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Service City',Attribute_Type__c ='Text' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Service City',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Service State',Attribute_Type__c ='Text' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Service State',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Service Country',Attribute_Type__c ='Text' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Service Country',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Service Zip',Attribute_Type__c ='Text' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Service Zip',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Date',Attribute_Type__c ='Date' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Boolean',Attribute_Type__c ='Boolean' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Date',Attribute_Type__c ='Date' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Number',Attribute_Type__c ='Number' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Currency',Attribute_Type__c ='Currency' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Language',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Call Tracking',Attribute_Type__c ='Text' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Call Tracking',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Phone Number Type',Attribute_Type__c ='Text' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Phone Number Type',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Primary Website',Attribute_Type__c ='Text' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Primary Website',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Call Firm Now',Attribute_Type__c ='Text' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Call Firm Now',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Direct Website Link',Attribute_Type__c ='Text' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Direct Website Link',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Starter Kit',Attribute_Type__c ='Text' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Starter Kit',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Country',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='City',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Country',Attribute_Type__c ='Picklist' ));
        
        
        
        
        insert listofAttributeConfig2 ; 
        
           
        list<Product_Charge_Attribute__c> listofproductAttribute12 = new list<Product_Charge_Attribute__c>();
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[0].Id, Attribute_Name__c = 'Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Text',Default_Boolean__c = false , Default_Date__c = system.today(),Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[1].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[2].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[3].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));     
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[4].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[5].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[6].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[7].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[8].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[9].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id)); 
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[10].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[11].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id)); 
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[12].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[13].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[14].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[15].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[16].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[17].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[18].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[19].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[20].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[21].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[22].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[23].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[24].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[25].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[26].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[27].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[28].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[29].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[30].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));         
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[31].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[2].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[32].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[2].id));
        insert listofproductAttribute12;
        
        invoiceit_s__Job__c jobNew2 = new invoiceit_s__Job__c(invoiceit_s__Account__c = account12.id,invoiceit_s__Billing_Contact__c = contact12.Id,
                invoiceit_s__Shipping_Contact__c = contact12.Id,
                invoiceit_s__Number_Of_Terms__c = 24,
                invoiceit_s__CurrencyL__c = currencyObj12.Id,
                invoiceit_s__Start_Date__c = system.today(), 
                invoiceit_s__Service_Activation_Date__c = system.today(), 
                invoiceit_s__Service_End_Date__c = system.today().addMonths(10),
                invoiceit_s__Preferred_Billing_Day__c = '1',invoiceit_s__Status__c = 'Active');
        insert jobNew2;
        invoiceit_s__Job_Product__c jobProduct12 = new invoiceit_s__Job_Product__c (invoiceit_s__Product__c=product12.id,invoiceit_s__Job__c = jobNew2.id);
        insert jobProduct12; 
        invoiceit_s__Job_Rate_Plan__c jobRP12 = new invoiceit_s__Job_Rate_Plan__c(Name = 'JobRP',invoiceit_s__Job_Product__c =jobProduct12.Id);
        insert jobRP12;
        invoiceit_s__Job_Rate_Plan_Charge__c charge212 = new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC',invoiceit_s__Job_Rate_Plan__c =jobRP12.Id,invoiceit_s__Quantity__c = 12,invoiceit_s__Price_Type__c = 'One Time',invoiceit_s__Accounting_Code__c = '12345',invoiceit_s__Unit_Price__c = 12,invoiceit_s__Profit__c = 10,invoiceit_s__Cost__c = 100,invoiceit_s__Cost_Price__c = 150,invoiceit_s__Tax__c = 20,invoiceit_s__VAT__c = 10,invoiceit_s__Discount_Value__c = 1,invoiceit_s__Net_Total__c = 50,invoiceit_s__Price__c = 100,Quote_Type__c = 'Modify' ,invoiceit_s__Service_Activation_Date__c = validtodate12,invoiceit_s__Order__c =jobNew2.id,Billing_Milestones__c = '30,40,50');
        //insert charge21;
        invoiceit_s__Job_Rate_Plan_Charge__c charge22 = new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC',invoiceit_s__Job_Rate_Plan__c =jobRP12.Id,invoiceit_s__Quantity__c = 12,invoiceit_s__Price_Type__c = 'One Time',invoiceit_s__Accounting_Code__c = '12345',invoiceit_s__Unit_Price__c = 12,invoiceit_s__Profit__c = 10,invoiceit_s__Cost__c = 100,invoiceit_s__Cost_Price__c = 150,invoiceit_s__Tax__c = 20,invoiceit_s__VAT__c = 10,invoiceit_s__Discount_Value__c = 1,invoiceit_s__Net_Total__c = 50,invoiceit_s__Price__c = 100,Quote_Type__c = 'Modify' ,invoiceit_s__Service_Activation_Date__c = validtodate12,invoiceit_s__Order__c =jobNew2.id ,invoiceit_s__Product_Rate_Plan_Charge__c =listProductRatePlanCharges12[0].id);
        //insert charge2;
        
        list<invoiceit_s__Job_Rate_Plan_Charge__c> listofCharge2 = new list<invoiceit_s__Job_Rate_Plan_Charge__c>();
        listofCharge2.add(charge212);
        listofCharge2.add(charge22);
        insert listofCharge2;  
        
        //Product Bundle Creation
        invoiceit_s__Product_Bundle__c prdbundle = MDL_UtilClass_TestClass.createProductBundle('12345',currencyObj12.id);
        insert prdbundle;
        
         //Product Bundle Line Creation
        invoiceit_s__Product_Bundle_Line__c prdbundleline = MDL_UtilClass_TestClass.createproductbundleline(prdbundle.id);
        insert prdbundleline;
        
        
        //Oppt
        
        Opportunity Opportunityobj12 = new Opportunity(AccountId = account12.id , Name ='testoopty',
                                                       StageName ='Declined', CloseDate =system.today(),
                                                       Type='New Business',invoiceit_crmx__Shipping_Contact__c=contact12.Id ,
                                                       invoiceit_crmx__Billing_Contact__c=contact12.Id,
                                                       Auth_By_Contact__c=contact12.Id,
                                                      Created_From_Order__c=jobNew2.id);
        insert Opportunityobj12;
        
        //invoiceit_crmx__Opportunity_Product__c opportunityproductobj12 = util.getOpportunityProduct(product12.Id, Opportunityobj12.Id);
        invoiceit_crmx__Opportunity_Product__c  opportunityproductobj12= new invoiceit_crmx__Opportunity_Product__c(Name = 'Opp Product',invoiceit_crmx__Product_Code__c = '1234', 
                                                                                                                    invoiceit_crmx__SequenceNumber__c =1, invoiceit_crmx__Product__c = product12.Id ,
                                                                                                                    invoiceit_crmx__Opportunity__c = Opportunityobj12.Id,
                                                                                                                   invoiceit_crmx__Product_Bundle__c =prdbundle.id);
        insert opportunityproductobj12;
        //invoiceit_crmx__Opportunity_Product__c opportunityproductobj12= new invoiceit_crmx__Opportunity_Product__c(Name='Product', invoiceit_crmx__SequenceNumber__c=1,invoiceit_crmx__Opportunity__c=Opportunityobj12.Id ,invoiceit_crmx__Product__c = product12.Id);
        //insert opportunityproductobj12;
        
        invoiceit_s__Product_Rate_Plan__c singleprdrpl = util.getProductRatePlan(product12.id);
        
        invoiceit_crmx__Opportunity_Rate_Plan__c opportunityproductrateplanobj12= util.getOpportunityRatePlan(opportunityproductobj12.id, singleprdrpl.Id);
        //invoiceit_crmx__Opportunity_Rate_Plan__c opportunityproductrateplanobj12=new invoiceit_crmx__Opportunity_Rate_Plan__c(Name='Rate plan',invoiceit_crmx__Opportunity_Product__c=opportunityproductobj12.Id );
        //insert opportunityproductrateplanobj12;
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c Opportunityrateplanchargeobj12= new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(Quote_Type__c = 'New', Name='charge',invoiceit_crmx__Opportunity_Rate_Plan__c=opportunityproductrateplanobj12.Id ,
                                                                                                                                            invoiceit_crmx__Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id,
                                                                                                                                            invoiceit_crmx__Opportunity__c = Opportunityobj12.id,
                                                                                                                                           invoiceit_crmx__Product_Bundle_Line__c = prdbundleline.id,invoiceit_crmx__Accounting_Code__c='50010'
                                                                                                                                          );
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c Opportunityrateplanchargeobj121= new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(Quote_Type__c = 'New', Name='charge',invoiceit_crmx__Opportunity_Rate_Plan__c=opportunityproductrateplanobj12.Id ,invoiceit_crmx__Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[2].id,invoiceit_crmx__Opportunity__c = Opportunityobj12.id);
        list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> listofoppCharge2 = new list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        listofoppCharge2.add(Opportunityrateplanchargeobj12);
        //listofoppCharge2.add(Opportunityrateplanchargeobj121);
        
        insert listofoppCharge2;
        
        packageWrapper wrapper = new packageWrapper();
        wrapper.silver = listofoppCharge2;
        wrapper.gold = null;
        wrapper.platinum = null;
        wrapper.alacarte = null;
        wrapper.bronze = null;
        wrapper.oppRPCIdVsProdRPCId = null;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id',Opportunityobj12.id);
        PackageSelectionPageCtrl.saveData(JSON.serialize(wrapper), 'silver', Opportunityobj12.id, Null, 'test');
        ApexPages.StandardController stdobj1 =new ApexPages.StandardController(Opportunityobj12);
        Test.stopTest();
    }*/

}