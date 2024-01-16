public with sharing class MDL_Ctrl_EmailQuotePDF{
    public decimal monthlyFees;
    //public Opportunity opportunity;
    //public invoiceit_s__Quote__c quote;
    public List<String> listOfOneTimeProd = new list<string>();
    public List<String> listOfSubscriptionProd = new list<string>();
    //public List<Id> oneTimeProduct;  
    //public List<Id> subscriptionProduct;
    public Decimal totalOneTimeSubscription;
    public Decimal totalMonthlySubscription;
    public String SenderName;
    public String SenderTitle;
    public String SenderEmail;
    public String SenderPhone;
    public String SenderFax;
    public Boolean success;
    public String invquoteId ;
    public String AccName;
    public String toAdd;
    public String emailMsg;
    public String subject;
    public String prodNames;
    public Document d;
     public MDL_Ctrl_EmailQuotePDF(ApexPages.StandardController controller){
     }
     public Pagereference sendEmail(){
         toAdd = '';
         if(ApexPages.currentPage().getParameters().get('id')  != null){
             
             invquoteId = ApexPages.currentPage().getParameters().get('id');
             system.debug('@@@@invoice quote id'+ invquoteId);
             
             //Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
             
             //PageReference pdf = Page.GenerateQuote;
             //pdf.getParameters().put('id',invquoteId);
             //pdf.setRedirect(true);
             //Opportunity opportunity = [Select invoiceit_crmx__Shipping_Contact__r.Email from Opportunity where Id =: OppId];
             invoiceit_s__Quote__c quote = [Select i.invoiceit_s__Shipping_Contact__r.Email, i.invoiceit_s__Shipping_Contact__c, i.invoiceit_s__Account__c ,
                                                   i.invoiceit_s__Account__r.Name , i.Id ,(Select Name From invoiceit_s__Quote_Product__r) , i.invoiceit_crmx__Opportunity__c ,
                                                   i.invoiceit_s__Shipping_Contact__r.Name , i.Owner.Name , i.Owner.Email , i.Owner.Phone
                                            From invoiceit_s__Quote__c i
                                            WHERE i.Id = : invquoteId and RecordType.DeveloperName = 'MH_Quotes'];
             system.debug('@@@quote' + quote);
             
             Opportunity opportunity = [Select invoiceit_crmx__Sub_Total__c ,  invoiceit_crmx__Shipping_Contact__r.Name,
                                            Account.Owner.Name , Account.Owner.Title , Account.Owner.Email,
                                            Account.Owner.Phone , Account.Owner.Fax ,   invoiceit_crmx__Number_Of_Terms__c,
                                            (Select Name from invoiceit_crmx__Opportunity_Products__r)  
                                        from Opportunity 
                                        where Id =: quote.invoiceit_crmx__Opportunity__c];
             system.debug('@@@opportunity' + opportunity);
             
             if(opportunity.Account.Owner.Name != null)
                SenderName = opportunity.Account.Owner.Name;
            if(opportunity.Account.Owner.Title != null)    
                SenderTitle = opportunity.Account.Owner.Title;
            if(opportunity.Account.Owner.Email != null)    
                SenderEmail = opportunity.Account.Owner.Email;
            if(opportunity.Account.Owner.Phone != null)    
                SenderPhone = opportunity.Account.Owner.Phone;
            if(opportunity.Account.Owner.Fax != null)    
                SenderFax = opportunity.Account.Owner.Fax;
             
             
            List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> OppRPC = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
            
            OppRPC = [Select id , Name, invoiceit_crmx__Product_Rate_Plan_Charge__c,    invoiceit_crmx__Net_Total__c, 
                            invoiceit_crmx__Product_Rate_Plan_Charge__r.invoiceit_s__Price_Type__c,
                            invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c,
                            invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Name,
                            Terms_Months__c                     
                        from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c 
                        where   invoiceit_crmx__Opportunity__c =:  quote.invoiceit_crmx__Opportunity__c];
             
            totalOneTimeSubscription = 0;
            totalMonthlySubscription = 0;
            for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c  oRPC : oppRPC){
                if(oRPC.invoiceit_crmx__Product_Rate_Plan_Charge__r.invoiceit_s__Price_Type__c != null){
                    if(oRPC.invoiceit_crmx__Product_Rate_Plan_Charge__r.invoiceit_s__Price_Type__c == 'One Time'){
                        //oneTimeProduct.add(oRPC.invoiceit_s__Quote_Rate_Plan__r.invoiceit_s__Quote_Product__c); 
                        if(oRPC.Terms_Months__c != 1)
                            listOfOneTimeProd.add(oRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Name                                             
                                                +' - '
                                                +oRPC.Terms_Months__c + ' months');
                        
                        else
                            listOfOneTimeProd.add(oRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Name
                                                    + ' - '                                                 
                                                    +oRPC.Terms_Months__c
                                                    +' month');                     
                        system.debug('what is the decimal ' + oRPC.invoiceit_crmx__Net_Total__c);
                        totalOneTimeSubscription += oRPC.invoiceit_crmx__Net_Total__c.setScale(2);
                        system.debug('what is the decimal2 ' + totalOneTimeSubscription);
                    }
                    
                    else{
                        //subscriptionProduct.add(oRPC.invoiceit_s__Quote_Rate_Plan__r.invoiceit_s__Quote_Product__c);
                        system.debug('@@@Terms_Months__c' + oRPC.Terms_Months__c);
                        system.debug('@@@invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Name' + oRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Name);
                        if(oRPC.Terms_Months__c != 1)
                            listOfSubscriptionProd.add(oRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Name
                                                    + ' - '                                                 
                                                    +oRPC.Terms_Months__c
                                                    +' months');
                        else
                            listOfSubscriptionProd.add(oRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Name
                                                    + ' - '                                                 
                                                    +oRPC.Terms_Months__c
                                                    +' month');
                        if(oRPC.invoiceit_crmx__Product_Rate_Plan_Charge__r.invoiceit_s__Price_Type__c == 'Monthly')
                            totalMonthlySubscription += oRPC.invoiceit_crmx__Net_Total__c.setScale(2);
                        if(oRPC.invoiceit_crmx__Product_Rate_Plan_Charge__r.invoiceit_s__Price_Type__c == 'Quarterly')
                            totalMonthlySubscription += (oRPC.invoiceit_crmx__Net_Total__c)/3; 
                        if(oRPC.invoiceit_crmx__Product_Rate_Plan_Charge__r.invoiceit_s__Price_Type__c == 'Half Yearly')
                            totalMonthlySubscription += (oRPC.invoiceit_crmx__Net_Total__c)/6;
                        if(oRPC.invoiceit_crmx__Product_Rate_Plan_Charge__r.invoiceit_s__Price_Type__c == 'Annual')
                            totalMonthlySubscription += (oRPC.invoiceit_crmx__Net_Total__c)/12;
                            
                    }
                }
            }
                                           
             //Blob b;
             //if(!test.isRunningTest())
              //  b = pdf.getContent();
             //else 
             //   b = Blob.valueOf('UNIT.TEST');
                
             //to get the body of the email from Email Template of Quote Sample 
             emailMsg = 'Dear ' + quote.invoiceit_s__Shipping_Contact__r.Name+' ,\r\n\r\n';
             emailMsg += 'Please respond to this email with "I Approve" within 24 hours and I will move ';
             emailMsg += 'forward with the fulfillment of your order for Martindale-Hubbell® products and services (the "Order" for "MH Products"). \r\n\r\n ';
             emailMsg += 'Based on our recent conversation regarding your business needs, I would like to confirm your Order for MH Products which includes: \r\n\r\n';
                
             //get Product names from Quote Products
             
             /*prodNames = 'MARTINDALE-HUBBELL PRODUCT SUMMARY :'+'\r\n \r\n' ;
             if(listOfSubscriptionProd !=null && !listOfSubscriptionProd.isEmpty()){
                 prodNames += +'Subscription Product Summary:' +'\r\n';
                 for(string singleItem : listOfSubscriptionProd){
                    prodNames += '\u2022'+singleItem + '\r\n';
                 }
                 prodNames += '\r\n';
             }
             
             if(listOfOneTimeProd !=null && !listOfOneTimeProd.isEmpty()){
                 prodNames += 'Transactional Product Summary:' +'\r\n';
                 for(string singleItem : listOfOneTimeProd){
                    prodNames += '\u2022'+singleItem + '\r\n';
                 }
             }
             */
             
             prodNames = 'MARTINDALE-HUBBELL PRODUCT SUMMARY :'+'\r\n \r\n' ;
             for(invoiceit_s__Quote_Product__c qProd : quote.invoiceit_s__Quote_Product__r) {
                System.debug('qProds::'+qProd);
                prodNames += '\u2022'+qProd.Name + '\r\n';
             }
             System.debug('ProdNames'+prodNames);
             
             emailMsg += prodNames;
             emailMsg += '\r\n\r\n';
             emailMsg += 'For your Order, you have an Initial Term of 12 - months. After the expiration of the Initial Term, ';
             emailMsg +='your Order will be extended on a month-to-month basis under the terms of this Agreement, until either party terminates ';
             emailMsg += 'upon 30 days\' prior written notice to the other party. Each monthly extension of this Agreement shall be deemed a Renewal Term. ';
             emailMsg += 'Those products that consist solely of one-time development are excluded from the Renewal Term. In addition, ';
             emailMsg += 'transactional products will only be invoiced if the product is shipped during the Renewal Term. \r\n\r\n';
             
             emailMsg += 'FEES : \r\n';
             emailMsg += 'Your "Fees" for the first months of your order for the products listed above under "MARTINDALE-HUBBELL PRODUCT SUMMARY" are : \r\n\r\n';
             emailMsg += 'Monthly Subscription Fees: $' + totalMonthlySubscription + ' \r\nTransactional Product Fees: $'+ totalOneTimeSubscription +'\r\n\r\n';
             emailMsg += '_________________________________________________________________________________________________________________________\r\n';
             emailMsg += 'While Fees are invoiced on a monthly basis, a deposit of $0 is required for your order and can be made via credit card or check.'; 
             emailMsg += 'The deposit will be credited toward your monthly invoice. Included in the Subscription Fees are fees you pay once, such as set up fees.';
             emailMsg += ' Transactional Fees are for specific products which will be billed in full when delivered. The invoice will include shipping and ';
             emailMsg += 'handling charges and taxes as applicable to the MH Products ordered. \r\n\r\n '; 
             emailMsg += 'After the Initial Term expires, we may raise your fees for the Renewal Term. We would notify you of an increase.';
             emailMsg += 'The MH Products ordered are governed by Terms and Conditions of Use for MH Products (the "MH';
             emailMsg += 'Terms"). The MH Terms may be viewed and printed at: http://www.martindale.com/Products_and_Services/Product_Terms_of_Use.aspx and ';
             emailMsg += 'include our notice address. By responding "I approve" you accept the MH Terms and the Order outlined above as the complete agreement. \r\n\r\n';
             emailMsg += 'If you have any questions, please contact me immediately. We look forward to working with you as your marketing partner ';
             emailMsg += 'and we are committed to delivering the best solution for your firm\'s needs. \r\n\r\n';
             emailMsg += 'Regards, \r\n';
             emailMsg += SenderName+'\r\n';
             emailMsg += SenderTitle+'\r\n';
             emailMsg += SenderEmail+'\r\n';
             emailMsg += SenderPhone+'\r\n';
             emailMsg += SenderFax+'\r\n';
             //if(quote.Owner.Phone != null)
             //   emailMsg += quote.Owner.Phone+'\r\n\r\n';
             emailMsg+= 'Martindale, LLC, dba Martindale-Hubbell, LLC';
             
             
             subject = 'Martindale Hubbell - ' + quote.invoiceit_s__Account__r.Name + '- quote' + quote.Id;
             subject = EncodingUtil.urlEncode(subject, 'UTF-8');
             
             //AccName = quote.invoiceit_s__Account__c;
             
             AccName = quote.invoiceit_crmx__Opportunity__c;
                        
             //Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
             //efa.setFileName('Quote.pdf');
             //efa.setBody(b);
             List<String> toAddress = new List<String>();
             if(quote.invoiceit_s__Shipping_Contact__r.Email != null) {
                toAddress.add(quote.invoiceit_s__Shipping_Contact__r.Email);
                toAdd = quote.invoiceit_s__Shipping_Contact__r.Email;
             }
             System.debug('toAdd value is'+toAdd);
             if(toAdd == '') {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please verify Email Address of Primary Contact before sending the mail ');
                ApexPages.addMessage(myMsg); 
             } 
             else {
                
            //PageReference p1 = new PageReference('/'+invquoteId);
             //return p1;
             //Document creation
             //Folder f = [Select f.Type, f.Name, f.Id From Folder f where f.Name = 'Quote PDFs'];
             //d = new Document();
             //d.FolderId = f.Id;
             //d.Body = b;
             //d.Name = invquoteId;
             //d.ContentType = 'application/pdf';
             //insert d;
             System.debug('###Subject:'+subject+'##emailMsg:'+emailMsg+'##toAdd:'+toAdd+'##AccName:'+AccName+'##invquoteId:'+invquoteId);
            //PageReference p = new PageReference('/_ui/core/email/author/EmailAuthor?p6=Quote Attachment&p7='+emailMsg+'&p24='+toAdd+'&doc_id='+d.Id+'&p3_lkid='+OppId+'&retURL=/'+OppId+'&cancelURL=/'+OppId+'&p5=');
            PageReference p = new PageReference('/_ui/core/email/author/EmailAuthor?p6='+subject+'&p7='+emailMsg+'&p24='+toAdd+'&p3_lkid='+AccName+'&retURL=/'+invquoteId+'&cancelURL=/'+invquoteId);
            //PageReference p = new PageReference('/_ui/core/email/author/EmailAuthor?rtype=001&p6='+subject+'&cancelURL=/'+OppId);
            system.debug('url returned --> ' + p.getUrl());
            p.setRedirect(true);
            return p;
             }
         }
         return null;
             
     }
     
     
     public PageReference returnToOpp(){
        if(invquoteId != null){
            PageReference p = new PageReference('/'+invquoteId);
            return p;
        }
        else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'NO quote Found ');//Same old drama 
            ApexPages.addMessage(myMsg);
            return null;
        }   
     }
}