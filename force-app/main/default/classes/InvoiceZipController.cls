/**
 * 
 */
public class InvoiceZipController {
 
    public transient String zipFileName {get; set;}
    public transient String zipContent  {get; set;}
    public transient id invoicerunId    {get;set;}
    public transient integer totalRecs  {get;set;}
    private integer OffsetSize = 0;
    private integer LimitSize  = 100;
    public transient List<invoiceit_s__Invoice__c> invoicelist;
    public transient set<String> invoiceIds;
    private String rectype = '%';
    
    public InvoiceZipController(){
        
        invoicerunId   = ApexPages.currentPage().getParameters().get('Id');
        invoicelist = new List<invoiceit_s__Invoice__c>();
        invoiceIds  = new set<String>();
        totalRecs = 0;
        if(invoicerunId != null){
             invoicelist = [select id, invoiceit_s__Account__r.Logical_Doc__c,
                                                              Name, invoiceit_s__Account__r.MH_Cust_Number__c,
                                                              invoiceit_s__Invoice_Date__c
                                                               from invoiceit_s__Invoice__c
                                                               where invoiceit_s__Invoice_Status__c = 'Posted'
                                                                and (invoiceit_s__Delivery_Type__c = 'Email & Print'
//                                                                   OR invoiceit_s__Delivery_Type__c = 'Email'
                                                                     OR invoiceit_s__Delivery_Type__c = 'Print')
                                                                and recordtype.developerName = 'Nolo_Invoice'
                                                                and invoiceit_s__Invoice_Run_Created_By__c =: invoicerunId
                                                         ];
            invoiceIds = genericUtilityClass.formingsetIDsfromList(invoicelist, 'Id');

        }
               
        
        List<Attachments_History__c> ZippedAttachments = new List<Attachments_History__c>();
        set<String> attIds = new Set<String>();
        ZippedAttachments = [select id, Name,
                                    Attachment_ID__c
                                    From Attachments_History__c LIMIT 1000];
        
        if(ZippedAttachments != null && !ZippedAttachments.isEmpty()){
            attIds = genericUtilityClass.formingsetIDsfromList(ZippedAttachments, 'Attachment_ID__c');
        }
        system.debug('@@@attIds'+ attIds);
        String query = 'select count() '+
                          ' from attachment '+
                          ' where Parent.Type = \'invoiceit_s__Invoice__c\''+
                          ' and Id not IN :attIds LIMIT 1000';
        if(invoicelist != null && invoicelist.size() > 0){
            query += ' and Parent.id IN :invoiceIds ';
        }
       
         system.debug('@@@@ query controller'+ query);
      
        totalRecs             = database.countQuery(query);
        system.debug('Total Recs: ' + totalRecs + ' LimitSize: '  + LimitSize + ' OffSetSize: ' + OffsetSize);
        
        if(invoicerunId != null && invoicelist.size() == 0){
            totalRecs = 0;
        }
        
        if(totalRecs == 0){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info,'Attachment are not available'));
             
        }
        
        //totalRecs = [select count()
        //                    from Attachment
        //                    where Parent.Type = 'invoiceit_s__Invoice__c'
        //                          and Id not IN: attIds
        //                          ];
        
    }
    public PageReference uploadZip() {
        
        //system.debug('@@@in enter upload'+ ZippingAttachments);
        if (String.isEmpty(zipFileName) ||
            String.isBlank(zipFileName)) {
            zipFileName = 'my_zip.zip';
        }
        else {
            zipFileName.replace('.', '');
            zipFileName += '.zip';
        }
        
        id folderId = [select id 
                              From Folder
                              where Name='Zipped Invoices PDF'
                              LIMIT 1].id;
        
        Document doc = new Document();
        doc.Name = zipFileName;
        doc.ContentType = 'application/zip';
        //doc.FolderId = UserInfo.getUserId();
        doc.FolderId = folderId;
        if(!test.isRunningTest()){
            doc.Body = EncodingUtil.base64Decode(zipContent);
        }
        
         
        insert doc;
        
//Added by Rama 2/25/16   
        if (invoicerunId != null)
        {
        invoiceit_s__Invoice_Run__c invrun = [select id, Invoice_Zip_Attachment_List__c from invoiceit_s__Invoice_Run__c where id = :invoicerunId];
//      invoiceit_s__Invoice_Run__c invrun = [select id from invoiceit_s__Invoice_Run__c where id = :invoicerunId];
        if (invrun.Invoice_Zip_Attachment_List__c == null) 
           invrun.Invoice_Zip_Attachment_List__c = doc.id;
        else
           invrun.Invoice_Zip_Attachment_List__c = invrun.Invoice_Zip_Attachment_List__c + ', ' + doc.id;

        if (invrun.Invoice_Zip_Attachment_List__c != null)  
            update invrun;  

        }

        
        this.zipFileName = null;
        this.zipContent = null;
 
        PageReference pageRef = new PageReference('/' + doc.Id);
        pageRef.setRedirect(true);
         
        return pageRef;
    }
 
    public List<SelectOption> getInvoicetypes()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--Select Record Type --'));
        options.add(new SelectOption('All','All'));
        for(RecordType rt:[select id,name from RecordType where sobjecttype='invoiceit_s__Invoice__c']){
            options.add(new SelectOption(rt.name,rt.name));    
        }
        
        return options;
    }

    public String getRecordType() {
        return recType;
    }
    
    public void setRecordType(String recType) {
        this.recType= recType;
        string qryrectype = rectype;
        set<String> attIds = new Set<String>();
        List<Attachments_History__c> ZippedAttachments = new List<Attachments_History__c>();
        ZippedAttachments = [select id, Name,
                                    Attachment_ID__c
                                    From Attachments_History__c ];
        
        if(ZippedAttachments != null && !ZippedAttachments.isEmpty()){
            attIds = genericUtilityClass.formingsetIDsfromList(ZippedAttachments, 'Attachment_ID__c');
        }
        if (rectype == 'All' || rectype =='') 
            qryrectype = '%';   
        
        String query = 'select count() '+
                          ' from attachment '+
                          ' where Parent.Type = \'invoiceit_s__Invoice__c\''+
                          ' and parent.recordtype.name like :qryrectype ' +
                          ' and Id not IN :attIds';
        if(invoicelist != null && invoicelist.size() > 0){
            query += ' and Parent.id IN :invoiceIds ';
        }
       
        system.debug('@@@@ query controller'+ query);      
        totalRecs             = database.countQuery(query); 
        offsetsize = 0;
    }
    
    public List<Attachment> getAttachments() {
        List<Attachments_History__c> ZippedAttachments = new List<Attachments_History__c>();
        string qryrectype;
        ZippedAttachments = [select id, Name,
                                    Attachment_ID__c
                                    From Attachments_History__c];
        set<String> attIds = new Set<String>();
        if(ZippedAttachments != null && !ZippedAttachments.isEmpty()){
            attIds = genericUtilityClass.formingsetIDsfromList(ZippedAttachments, 'Attachment_ID__c');
        }
        
        qryrectype = rectype;
        if (rectype == 'All' || rectype ==null) 
            qryrectype = '%';
        
        system.debug('rectype: ' + rectype);
        
        string query = 'select Id, ParentId, Name, parent.recordtype.name,'+
                              ' ContentType, BodyLength'+
                              ' from Attachment'+
                              ' where Parent.Type = \'invoiceit_s__Invoice__c\''+
                              ' and parent.recordtype.name like :qryrectype ' +
                              ' and Id not IN :attIds';
                              
        
        system.debug('@@ invoice list'+ invoicelist);
        if(invoicelist != null && invoicelist.size() > 0){
            query += ' and Parent.id IN :invoiceIds ';
        }
        
        system.debug('Total Recs: ' + totalRecs + ' LimitSize: '  + LimitSize + ' OffSetSize: ' + OffsetSize);
        query += ' LIMIT :LimitSize'+
                 ' OFFSET :OffsetSize';
        
         system.debug('@@ query list'+ query);
        //List<attachment> attachmentList = [select Id, ParentId, Name, 
       //                                           ContentType, BodyLength
        //                                          from Attachment
        //                                          where Parent.Type = 'invoiceit_s__Invoice__c'
       //                                              and Id not IN:(attIds)
        //                                             LIMIT :LimitSize 
       //
       //                                                     OFFSET :OffsetSize];
       List<attachment> attachmentList = database.query(query);

       if(invoicerunId != null && invoicelist.size() == 0){
            attachmentList.clear();
        }  
       system.debug('@@@@attachmentList size'+ attachmentList.size()); 
        
        return attachmentList;
    }
     
    @RemoteAction
    public static List<AttachmentWrapper> getAttachment(String attId) {
        
        List<Attachments_History__c> ZippingAttachments = new List<Attachments_History__c>();
        List<String> attachmentIds = attId.split(',');
        List<attachment> attlist = new List<attachment>([SELECT Id,Name,
                                                                Body 
                                                                FROM Attachment 
         
                                                         WHERE Id IN:attachmentIds]);
         Attachments_History__c attachmenthistory;
        for(attachment singleattachment : attlist){
            attachmenthistory = new Attachments_History__c();
            attachmenthistory.Name = singleattachment.Name;
            attachmenthistory.Zipped__c = true;
            attachmenthistory.Attachment_ID__c = singleattachment.id;
            ZippingAttachments.add(attachmenthistory);
        }
        insert ZippingAttachments;
        
        return wrapAttachments(attlist);
         
       /* Attachment att = [select Id, Name, ContentType, Body
                          from Attachment
                          where Id = :attId];
         
        AttachmentWrapper attWrapper = new AttachmentWrapper();
        attWrapper.attEncodedBody = EncodingUtil.base64Encode(att.body);
        attWrapper.attName = att.Name;
        Attachments_History__c attachmenthistory = new Attachments_History__c();
        attachmenthistory.Name = att.Name;
        attachmenthistory.Zipped__c = true;
        ZippingAttachments.add(attachmenthistory);
        system.debug('@@@@zipping'+ ZippingAttachments);
        return attWrapper;*/
    }
     
    
    private static List<AttachmentWrapper> wrapAttachments(List<Attachment> attachments){
        List<AttachmentWrapper> wrappers = new List<AttachmentWrapper>();
        for(Attachment att : attachments){
            wrappers.add(new AttachmentWrapper(att));
        }
        
        return wrappers;
    }
    public class AttachmentWrapper {
        
        public String attEncodedBody {get; set;}
        public String attName {get; set;}
         public AttachmentWrapper(Attachment AttachmentObj){
            this.attEncodedBody = EncodingUtil.base64Encode(AttachmentObj.Body); 
            this.attName        =  AttachmentObj.Name;
           
        }
    }
    
    
    
    public void FirstPage()
     {
        OffsetSize = 0;
     }
     public void previous()
     {
        if (offsetsize > 0 )
            OffsetSize = OffsetSize - LimitSize;
        system.debug('Total Recs: ' + totalRecs + ' LimitSize: '  + LimitSize + ' OffSetSize: ' + OffsetSize);
     }
     public void next()
     {
        OffsetSize = OffsetSize + LimitSize;
        system.debug('Total Recs: ' + totalRecs + ' LimitSize: '  + LimitSize + ' OffSetSize: ' + OffsetSize);
     }
     public void LastPage()
     {
        OffsetSize = totalrecs - LimitSize;
//         if (offsetsize > 2000) offsetsize = 2000;
        system.debug('Total Recs: ' + totalRecs + ' LimitSize: '  + LimitSize + ' OffSetSize: ' + OffsetSize);
     }
     public boolean getprev()
     {
         if(OffsetSize == 0)
         return true;
         else
         return false;
     }
     public boolean getnxt()
     {
         if((OffsetSize + LimitSize) > totalRecs)
         return true;
         else
         return false;
     }
}