public with sharing class MDL_Ctrl_SendEmail {

    public static Messaging.EmailFileAttachment generateAttachment(Id accId , Integer oldestInvoice){
             List<SiteBaseURL__c> SiteBaseURL = SiteBaseURL__c.getall().values(); 
             //String base_URL = ;
             /*String dunningURL1 = 'http://rainbow-rainbow.cs8.force.com/?Id=' + accId;
             String dunningURL2 = 'http://rainbow-rainbow.cs8.force.com/MDL_DunningLetter3?Id=' + accId;
             String dunningURL3 = 'http://rainbow-rainbow.cs8.force.com/MDL_DunningLetter4?Id=' + accId;*/
             
             String dunningURL1 = SiteBaseURL[0].Base_URL__c + '?Id='+ accId;
             String dunningURL2 = SiteBaseURL[0].Base_URL__c + 'MDL_DunningLetter3?Id='+accId;
             String dunningURL3 = SiteBaseURL[0].Base_URL__c + 'MDL_DunningLetter4?Id='+accId;
             
             system.debug('--->1 ' + dunningURL1);
             system.debug('--->2 ' + dunningURL2);
             system.debug('--->3 ' + dunningURL3);
             
             HttpRequest request = new HttpRequest();
             request.SetMethod('GET');
             
             
             if(oldestInvoice >= 30 && oldestInvoice < 90){
                request.SetEndPoint(dunningURL1);
             }   
             else if(oldestInvoice >= 90 && oldestInvoice < 120){
                request.SetEndPoint(dunningURL2);
             }   
             else if(oldestInvoice > 120){
                request.SetEndPoint(dunningURL3);
             }
             
             request.setHeader('Content-Type', 'application/pdf');
             HttpResponse httpResponse;
             Blob pdf;
             if(!Test.isRunningTest()){
                httpResponse = new Http().Send(request);
                pdf = httpResponse.GetBodyAsBlob();
             }
             else{
                pdf = Blob.valueof('Test String');  
             }
             //Creating an Attachment
             Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
             efa.setFileName('DunningLetter.pdf');
             efa.setBody(pdf);
             
             
             return efa; 
    }   
    
    
      
        public static List<Messaging.EmailFileAttachment> generateAttachment(List<Id> listAccId , String OldestInvoiceRange){
            List<SiteBaseURL__c> SiteBaseURL = SiteBaseURL__c.getall().values(); 
            List<Blob> fullPDF = new List<Blob>();
            List<Messaging.EmailFileAttachment> toreturn=new List<Messaging.EmailFileAttachment>();            
            for(Id accid : listAccId){  
                    String dunningURL = SiteBaseURL[0].Base_URL__c; 
                    if(OldestInvoiceRange == '30-60' || OldestInvoiceRange == '60-90')
                            dunningURL += '?Id='+ accId;                                                
                    else if(OldestInvoiceRange == '90-120')dunningURL += 'MDL_DunningLetter3?Id='+accId;
                    else if(OldestInvoiceRange == '>120') dunningURL += 'MDL_DunningLetter4?Id='+accId;  
                    HttpRequest request = new HttpRequest();
                    request.SetMethod('GET');       
                    request.SetEndPoint(dunningURL);    
                    request.setHeader('Content-Type', 'application/pdf');
                    
                    HttpResponse httpResponse;              
					Blob pdf;                                                                                                       
                if(!Test.isRunningTest()){
                httpResponse = new Http().Send(request);
                     pdf = httpResponse.GetBodyAsBlob(); 
                    fullPDF.add(pdf);   
             		}
            	 else{
              			  pdf = Blob.valueof('Test String');  
                     	  fullPDF.add(pdf);   
             		}
            }
            
            system.debug('size of full pdf ' + fullPDF.size());
            String mergePDF;  Blob attach_mergedPDF;
            for(Blob pdf : fullPDF){ 
                 Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName('DunningLetter.pdf'); efa.setBody(pdf); toreturn.add(efa);
                system.debug('merged pdf ' + mergePDF);
            }
           
           // attach_mergedPDF = EncodingUtil.base64Decode(mergePDF);
          
            /*if(OldestInvoiceRange == '>120'){
                Document d = new Document(Name = OldestInvoiceRange);            
                d.FolderId = '00lL0000000INqs';
                d.Body  = attach_mergedPDF;             
                insert d;
            }
            return null;
            */
            
            return toreturn;
             
    }
}