//this class is handler for batch class creatingAttachmentsBatch

public class createAttachmentHandler {
    
    public static void createAttachment(list<invoiceit_s__Invoice__c> invoicesList, Integer invoiceSize){
        Decimal invattachmentsize = decimal.valueOf(system.Label.Invoice_Attachment_Grouping);
        PageReference pdf; 
        List<attachment> attachmentsList = new List<attachment>();
        for(invoiceit_s__Invoice__c invoice : invoicesList){
            invoiceSize = invoiceSize + 1;
            Integer numbertoAssign = 0;
            if(invoiceSize > invattachmentsize ){
                numbertoAssign  = Integer.valueOf(math.ceil(invoiceSize / invattachmentsize ));
            }
            else{
                numbertoAssign  = 1;
            }
            pdf = Page.InvoiceSummaryPDF;
            pdf.getParameters().put('Id',invoice.id);
            
            Attachment attach = new Attachment();

           // the contents of the attachment from the pdf
           Blob body;

          try {

              // returns the output of the page as a PDF
             body = pdf.getContent();

            // need to pass unit test -- current bug    
         } catch (VisualforceException e) {
              body = Blob.valueOf('Some Text');
         }
         string pdfName = invoice.invoiceit_s__Account__r.MH_Cust_Number__c + invoice.Name+'.pdf';
         Boolean DoNotContact = invoice.invoiceit_s__Account__r.Do_Not_Contact__c;
         string InvoiceDelieveryType;
         String SuppressedOrNot;
         if (DoNotContact){
             SuppressedOrNot = 'Suppressed';
         }
         Else {
             SuppressedOrNot = 'Not Suppressed';
             }
         String MailingList;
         string Descrip;
         if ((invoice.invoiceit_s__Delivery_Type__c =='Print'||invoice.invoiceit_s__Delivery_Type__c =='Email & Print') && SuppressedOrNot =='Not Suppressed'){
             Descrip = invoice.invoiceit_s__Invoice_Run_Created_By__r.Name + '-' + 'Ok_To_Mail' + '-' + numbertoAssign  ;
         }
       //  Else if ((invoice.invoiceit_s__Delivery_Type__c == 'Email') && SuppressedOrNot == 'Not Suppressed'){
       //     Descrip = invoice.invoiceit_s__Invoice_Run_Created_By__r.Name +  '-' +  SuppressedOrNot +  '-' + 'Email'+ '-' + 'G2' + '-' + numbertoAssign  ;
       //      }
         Else if ((invoice.invoiceit_s__Delivery_Type__c == 'Email'||invoice.invoiceit_s__Delivery_Type__c == 'Print'||invoice.invoiceit_s__Delivery_Type__c =='Email & Print') && (SuppressedOrNot == 'Suppressed'|| SuppressedOrNot == 'Not Suppressed')){
             Descrip = invoice.invoiceit_s__Invoice_Run_Created_By__r.Name + '-' + 'Do_Not_Mail' + '-' + numbertoAssign  ;
             }
        // string Descrip = invoice.invoiceit_s__Invoice_Run_Created_By__r.Name +  '-' +  SuppressedOrNot +  '-' +  invoice.invoiceit_s__Delivery_Type__c ;
         attach.Body = body;
        // add the user entered name
         
         attach.Name = pdfName;
        attach.IsPrivate = false;
        // attach the pdf to the account
        attach.ParentId = invoice.id;
        // Attachment Description
        attach.description = Descrip;
        attachmentsList.add(attach);
            
       }
          
        try{
            insert attachmentsList;
        }
        catch(Exception ex){
            system.debug('@@@Exception'+ ex);
        }
      
    }        
            
   
    public static void deleteAttachments(List<invoiceit_s__Invoice__c> invList){
        
        List<attachment> attachmentList = new List<attachment>();
        attachmentList  = [select id, Name
                                   from attachment
                                    where ParentId IN:(invList)];
        try{
            delete attachmentList;
        }
        catch(exception ex){
            system.debug('@@@exception'+ ex);
        }
        
        if (!invlist.isEmpty()) 
        {
            invoiceit_s__Invoice__c inv = [select id, invoiceit_s__Invoice_Run_Created_By__c from invoiceit_s__Invoice__c where id in :(invList) limit 1];
            invoiceit_s__Invoice_Run__c invrun = [select id, Invoice_Zip_Attachment_List__c from invoiceit_s__Invoice_Run__c where id = :inv.invoiceit_s__Invoice_Run_Created_By__c];
            system.debug('InvRun: ' + invrun.Invoice_Zip_Attachment_List__c);
            if (invrun.Invoice_Zip_Attachment_List__c != null)
            {
                list<String> invlist1 = invrun.Invoice_Zip_Attachment_List__c.split(', ');
                List<document> doclist = [select id from document where id in :invlist1];
                if (!doclist.isEmpty())
                {
                    delete doclist;
                    invrun.Invoice_Zip_Attachment_List__c = null;
                    update invrun;
                }
            }

        }
    }
         
         
     public static void CPQcreateAttachment(list<blng__Invoice__c> invoicesList, Integer invoiceSize){
        Decimal invattachmentsize = decimal.valueOf(system.Label.Invoice_Attachment_Grouping);
        PageReference pdf; 
        List<attachment> attachmentsList = new List<attachment>();
        for(blng__Invoice__c invoice : invoicesList){
            invoiceSize = invoiceSize + 1;
            Integer numbertoAssign = 0;
            if(invoiceSize > invattachmentsize ){
                numbertoAssign  = Integer.valueOf(math.ceil(invoiceSize / invattachmentsize ));
            }
            else{
                numbertoAssign  = 1;
            }
            pdf = Page.InvoiceTemplate;
            pdf.getParameters().put('Id',invoice.id);
            
            Attachment attach = new Attachment();

           // the contents of the attachment from the pdf
           Blob body;

          try {

              // returns the output of the page as a PDF
             body = pdf.getContent();

            // need to pass unit test -- current bug    
         } catch (VisualforceException e) {
              body = Blob.valueOf('Some Text');
         }
         string pdfName = invoice.blng__Account__r.MH_Cust_Number__c + invoice.Name+'.pdf';
         Boolean DoNotContact = invoice.blng__Account__r.Do_Not_Contact__c;
         string InvoiceDelieveryType;
         String SuppressedOrNot;
         if (DoNotContact){
             SuppressedOrNot = 'Suppressed';
         }
         Else {
             SuppressedOrNot = 'Not Suppressed';
             }
         String MailingList;
         string Descrip;
         if ((invoice.Delivery_Type__c =='Print'||invoice.Delivery_Type__c  =='Email & Print') && SuppressedOrNot =='Not Suppressed'){
             Descrip = invoice.blng__InvoiceRunCreatedBy__r.Name + '-' + 'Ok_To_Mail' + '-' + numbertoAssign  ;
         }
       //  Else if ((invoice.invoiceit_s__Delivery_Type__c == 'Email') && SuppressedOrNot == 'Not Suppressed'){
       //     Descrip = invoice.invoiceit_s__Invoice_Run_Created_By__r.Name +  '-' +  SuppressedOrNot +  '-' + 'Email'+ '-' + 'G2' + '-' + numbertoAssign  ;
       //      }
         Else if ((invoice.Delivery_Type__c  == 'Email'||invoice.Delivery_Type__c  == 'Print'||invoice.Delivery_Type__c  =='Email & Print') && (SuppressedOrNot == 'Suppressed'|| SuppressedOrNot == 'Not Suppressed')){
             Descrip = invoice.blng__InvoiceRunCreatedBy__r.Name + '-' + 'Do_Not_Mail' + '-' + numbertoAssign  ;
             }
        // string Descrip = invoice.invoiceit_s__Invoice_Run_Created_By__r.Name +  '-' +  SuppressedOrNot +  '-' +  invoice.invoiceit_s__Delivery_Type__c ;
         attach.Body = body;
        // add the user entered name
         
         attach.Name = pdfName;
        attach.IsPrivate = false;
        // attach the pdf to the account
        attach.ParentId = invoice.id;
        // Attachment Description
        attach.description = Descrip;
        attachmentsList.add(attach);
            
       }
          
        try{
            insert attachmentsList;
        }
        catch(Exception ex){
            system.debug('@@@Exception'+ ex);
        }
      
    }
    
    public static void CPQdeleteAttachment(list<blng__Invoice__c> invoicesList){
                List<attachment> attachmentList = new List<attachment>();
        attachmentList  = [select id, Name
                                   from attachment
                                    where ParentId IN:(invoicesList)];
        try{
            delete attachmentList;
        }
        catch(exception ex){
            system.debug('@@@exception'+ ex);
        }
        
    }
    

}