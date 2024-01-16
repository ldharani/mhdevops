/*Test Class On InvoiceSummaryActPDF
*/
@isTest(seeAllData = true)
public class InvoiceSummaryActPDFTest {
    
    static testmethod void run2condition_Nolo(){
        
         MDL_UtilClass_TestClass util= new MDL_UtilClass_TestClass();
        
        //creating account
        account acc = new account();
        acc = util.getAccount();
        
        //creating single contact
        contact con = new contact();
        con = util.getContact(acc.Id);
        
        //creating invoice
        invoiceit_s__Invoice__c singleInv = new invoiceit_s__Invoice__c();
        singleInv = util.getInvoice(acc.Id);
        singleInv.invoiceit_s__Billing_Contact__c = con.id;
        update singleInv;    
        
        //creating currency object
        invoiceit_s__Currency__c singcurr = new invoiceit_s__Currency__c();
        singcurr = util.getCurrencyObject();
        
        //creating payments
        Id noloinvpayRecId = Schema.SObjectType.invoiceit_s__Payment__c.RecordTypeInfosByName.get(RecordTypesFinalStringsClass.RecTypeName_MH_Payments).RecordTypeId;
        invoiceit_s__Payment__c singlepay = new invoiceit_s__Payment__c();
        singlepay.invoiceit_s__Account__c = acc.Id;
        singlepay.invoiceit_s__Currency__c = singcurr.id;
        singlepay.invoiceit_s__Amount__c = 200.00;
        singlepay.invoiceit_s__Payment_Date__c = Date.today().addDays(-45);
        singlepay.invoiceit_s__Payment_Type__c = 'Adjustment';
        singlepay.invoiceit_s__Status__c = 'Completed';
        singlepay.RecordTypeId = noloinvpayRecId;
        insert singlepay;
        
        //creating payment method
        invoiceit_s__Payment_Method__c singlepaymethod = new invoiceit_s__Payment_Method__c();
        singlepaymethod = util.getPaymentMethod(acc.Id);
        
        //creating order
        invoiceit_s__Job__c singlejob = new invoiceit_s__Job__c();
        singlejob = util.getOrder(acc.Id, singcurr.id);
        
        //creating product
        invoiceit_s__Product__c singleprod = new invoiceit_s__Product__c();
        singleprod = util.getProduct('true');
        
        //creating product rate plan
        invoiceit_s__Product_Rate_Plan__c singleprodrp = new invoiceit_s__Product_Rate_Plan__c();
        singleprodrp = util.getProductRatePlan(singleprod.id);
        
        //creating product rate plan charge
        invoiceit_s__Product_Rate_Plan_Charge__c singlerpc = new invoiceit_s__Product_Rate_Plan_Charge__c();
        singlerpc = util.getProductRatePlanCharge(singcurr.id, singleprodrp.id);
        singlerpc.Exclude_from_Invoices__c = false;
        insert singlerpc;
        
        //creating invoice line
        invoiceit_s__Invoice_Lines__c singleinvline = new invoiceit_s__Invoice_Lines__c();
        singleinvline.invoiceit_s__Invoice__c = singleInv.id;
        singleinvline.invoiceit_s__Job__c = singlejob.id;
        singleinvline.invoiceit_s__Unit_Price__c = 100.00;
        singleinvline.invoiceit_s__Line_Amount__c = 100.00;
        insert singleinvline;
       
         ApexPages.currentPage().getParameters().put('id',singleInv.id );
        InvoiceSummaryActPDF classcalling = new InvoiceSummaryActPDF();
        
        //calling all getter methods
        date stdate      = classcalling.StartDate; 
        date edate       = classcalling.EndDate;
        decimal totpay   = classcalling.dTotalPayment;
        decimal dcreditp = classcalling.dCreditPayment;
       // map<string,Integer> listInvLIst = classcalling.listInvLI;
        classcalling.send();
        classcalling.cancel();
        classcalling.showpdf();
    
    }
    
    static testmethod void run2condition_MH(){
        
         MDL_UtilClass_TestClass util= new MDL_UtilClass_TestClass();
        
        //creating account
        account acc = new account();
        acc = util.getAccount();
        
        //creating single contact
        contact con = new contact();
        con = util.getContact(acc.Id);
        
        //creating invoice
        invoiceit_s__Invoice__c singleInv = new invoiceit_s__Invoice__c();
        singleInv = util.getInvoice(acc.Id);
        singleInv.invoiceit_s__Billing_Contact__c = con.id;
        singleInv.invoiceit_s__Target_Date__c = date.today();
        update singleInv;    
        
        //creating currency object
        invoiceit_s__Currency__c singcurr = new invoiceit_s__Currency__c();
        singcurr = util.getCurrencyObject();
        
        //creating payments
        Id mhinvpayRecId = Schema.SObjectType.invoiceit_s__Payment__c.RecordTypeInfosByName.get(RecordTypesFinalStringsClass.RecTypeName_JV_Payments).RecordTypeId;
        invoiceit_s__Payment__c singlepay = new invoiceit_s__Payment__c();
        singlepay.invoiceit_s__Account__c = acc.Id;
        singlepay.invoiceit_s__Currency__c = singcurr.id;
        singlepay.invoiceit_s__Amount__c = 200.00;
        singlepay.invoiceit_s__Payment_Date__c = Date.today().addDays(-45);
        singlepay.invoiceit_s__Payment_Type__c = 'Adjustment';
        singlepay.invoiceit_s__Status__c = 'Completed';
        singlepay.Adjustment_Reason__c = 'Miscellaneous';
        singlepay.RecordTypeId = mhinvpayRecId;
        insert singlepay;
        
        //creating payment method
        invoiceit_s__Payment_Method__c singlepaymethod = new invoiceit_s__Payment_Method__c();
        singlepaymethod = util.getPaymentMethod(acc.Id);
        
        //creating order
        invoiceit_s__Job__c singlejob = new invoiceit_s__Job__c();
        singlejob = util.getOrder(acc.Id, singcurr.id);
        
        //creating product
        invoiceit_s__Product__c singleprod = new invoiceit_s__Product__c();
        singleprod = util.getProduct('true');
        
        //creating product rate plan
        invoiceit_s__Product_Rate_Plan__c singleprodrp = new invoiceit_s__Product_Rate_Plan__c();
        singleprodrp = util.getProductRatePlan(singleprod.id);
        
        //creating product rate plan charge
        invoiceit_s__Product_Rate_Plan_Charge__c singlerpc = new invoiceit_s__Product_Rate_Plan_Charge__c();
        singlerpc = util.getProductRatePlanCharge(singcurr.id, singleprodrp.id);
        singlerpc.Exclude_from_Invoices__c = false;
        insert singlerpc;
        
        //creating invoice line
        invoiceit_s__Invoice_Lines__c singleinvline = new invoiceit_s__Invoice_Lines__c();
        singleinvline.invoiceit_s__Invoice__c = singleInv.id;
        singleinvline.invoiceit_s__Job__c = singlejob.id;
        singleinvline.invoiceit_s__Unit_Price__c = 100.00;
        singleinvline.invoiceit_s__Line_Amount__c = 100.00;
        insert singleinvline;
       
         ApexPages.currentPage().getParameters().put('id',singleInv.id );
        InvoiceSummaryActPDF_MH classcalling = new InvoiceSummaryActPDF_MH(); 
        
        //calling all getter methods
        date stdate      = classcalling.StartDate; 
        date edate       = classcalling.EndDate;
        decimal totpay   = classcalling.dTotalPayment;
        decimal dcreditp = classcalling.dCreditPayment;
        //map<string,Integer> listInvLIst = classcalling.listInvLI;
        classcalling.send();
        classcalling.cancel();
        classcalling.showpdf();
    
    }
    
    public static testmethod void run2condition_MH_calculation(){
        
         MDL_UtilClass_TestClass util= new MDL_UtilClass_TestClass();
		List<invoiceit_s__Invoice__c> invList = new List<invoiceit_s__Invoice__c>();
        //creating account
        account acc = new account();
        acc = util.getAccount();
        
        //creating single contact
        contact con = new contact();
        con = util.getContact(acc.Id);
        
        //creating invoice
        Id mhinvRecId = Schema.SObjectType.invoiceit_s__Invoice__c.RecordTypeInfosByName.get(RecordTypesFinalStringsClass.RecTypeName_MH_Invoice).RecordTypeId;
        invoiceit_s__Invoice__c singleInv = new invoiceit_s__Invoice__c();
        singleInv = util.getInvoice(acc.Id);
        singleInv.invoiceit_s__Billing_Contact__c = con.id;
        singleInv.invoiceit_s__Target_Date__c = date.today();
        singleInv.invoiceit_s__Invoice_Status__c = 'Posted';
        singleInv.RecordTypeId = mhinvRecId;
        singleinv.Previous_Balance__c = 15;
        singleinv.Total_Amount_Due__c = 250;
        singleinv.Prev_Balance_Check__c = TRUE;
        update singleInv;    
        
        invoiceit_s__Invoice__c singleInv2 = new invoiceit_s__Invoice__c();
        singleInv2 = util.getInvoice(acc.Id);
        singleInv2.invoiceit_s__Billing_Contact__c = con.id;
        singleInv2.invoiceit_s__Target_Date__c = date.today();
        singleInv2.invoiceit_s__Invoice_Status__c = 'Draft';
        singleInv2.RecordTypeId = mhinvRecId;
        singleinv2.Previous_Balance__c = 15;
        singleinv2.Total_Amount_Due__c = 250;
        singleInv.NOLO_Credits_Previous_Month__c = 10.0;
        singleInv.NOLO_Payments_Previous_Month__c = 50.0;
        update singleInv2;
        
        //creating currency object
        invoiceit_s__Currency__c singcurr = new invoiceit_s__Currency__c();
        singcurr = util.getCurrencyObject();
        
        //creating payments
        Id mhinvpayRecId = Schema.SObjectType.invoiceit_s__Payment__c.RecordTypeInfosByName.get(RecordTypesFinalStringsClass.RecTypeName_JV_Payments).RecordTypeId;
        invoiceit_s__Payment__c singlepay = new invoiceit_s__Payment__c();
        singlepay.invoiceit_s__Account__c = acc.Id;
        singlepay.invoiceit_s__Currency__c = singcurr.id;
        singlepay.invoiceit_s__Amount__c = 200.00;
        singlepay.invoiceit_s__Payment_Date__c = Date.today().addDays(-45);
        singlepay.invoiceit_s__Payment_Type__c = 'Adjustment';
        singlepay.invoiceit_s__Status__c = 'Completed';
        singlepay.Adjustment_Reason__c = 'Miscellaneous';
        singlepay.RecordTypeId = mhinvpayRecId;
        insert singlepay;
        
        invoiceit_s__Payment__c singlepay2 = new invoiceit_s__Payment__c();
        singlepay2.invoiceit_s__Account__c = acc.Id;
        singlepay2.invoiceit_s__Currency__c = singcurr.id;
        singlepay2.invoiceit_s__Amount__c = 400.00;
        singlepay2.CreatedDate = Date.today().addDays(-45);
        singlepay2.invoiceit_s__Payment_Type__c = 'Credit Card';
        singlepay2.invoiceit_s__Status__c = 'Completed';
        singlepay2.Adjustment_Reason__c = 'Miscellaneous';
        singlepay2.RecordTypeId = mhinvpayRecId;
        insert singlepay2;
        
        invoiceit_s__Payment__c singlepay3 = new invoiceit_s__Payment__c();
        singlepay3.invoiceit_s__Account__c = acc.Id;
        singlepay3.invoiceit_s__Currency__c = singcurr.id;
        singlepay3.invoiceit_s__Amount__c = 4000.00;
        singlepay3.invoiceit_s__Payment_Date__c = Date.today().addDays(-85);
        singlepay3.invoiceit_s__Payment_Type__c = 'Adjustment';
        singlepay3.invoiceit_s__Status__c = 'Completed';
        singlepay3.Adjustment_Reason__c = 'Miscellaneous';
        singlepay3.RecordTypeId = mhinvpayRecId;
        insert singlepay3;
        
        invoiceit_s__Payment__c singlepay4 = new invoiceit_s__Payment__c();
        singlepay4.invoiceit_s__Account__c = acc.Id;
        singlepay4.invoiceit_s__Currency__c = singcurr.id;
        singlepay4.invoiceit_s__Amount__c = 3000.00;
        singlepay4.invoiceit_s__Payment_Date__c = Date.today().addDays(-85);
        singlepay4.invoiceit_s__Payment_Type__c = 'Cheque';
        singlepay4.invoiceit_s__Cheque_Number__c = '121112';
        singlepay4.invoiceit_s__Cheque_Date__c = Date.today().addDays(-85);
        singlepay4.invoiceit_s__Bank_Name__c = 'Bank Of America';    
        singlepay4.invoiceit_s__Status__c = 'Completed';
        singlepay4.Adjustment_Reason__c = 'Miscellaneous';
        singlepay4.RecordTypeId = mhinvpayRecId;
        insert singlepay4;
        
        //creating payment method
        invoiceit_s__Payment_Method__c singlepaymethod = new invoiceit_s__Payment_Method__c();
        singlepaymethod = util.getPaymentMethod(acc.Id);
        
        //creating order
        invoiceit_s__Job__c singlejob = new invoiceit_s__Job__c();
        singlejob = util.getOrder(acc.Id, singcurr.id);
        
        //creating product
        invoiceit_s__Product__c singleprod = new invoiceit_s__Product__c();
        singleprod = util.getProduct('true');
        
        //creating product rate plan
        invoiceit_s__Product_Rate_Plan__c singleprodrp = new invoiceit_s__Product_Rate_Plan__c();
        singleprodrp = util.getProductRatePlan(singleprod.id);
        
        //creating product rate plan charge
        invoiceit_s__Product_Rate_Plan_Charge__c singlerpc = new invoiceit_s__Product_Rate_Plan_Charge__c();
        singlerpc = util.getProductRatePlanCharge(singcurr.id, singleprodrp.id);
        singlerpc.Exclude_from_Invoices__c = false;
        insert singlerpc;
        
        //creating invoice line
        invoiceit_s__Invoice_Lines__c singleinvline = new invoiceit_s__Invoice_Lines__c();
        singleinvline.invoiceit_s__Invoice__c = singleInv.id;
        singleinvline.invoiceit_s__Job__c = singlejob.id;
        singleinvline.invoiceit_s__Unit_Price__c = 100.00;
        singleinvline.invoiceit_s__Line_Amount__c = 100.00;
        insert singleinvline;
        
        invList.add(singleInv);
         ApexPages.currentPage().getParameters().put('id',singleInv.id );
        mdl_invoicepdfnolo.getnoloinvoicefileds(invList);
    	
    }
}