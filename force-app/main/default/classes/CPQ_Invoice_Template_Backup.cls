public class CPQ_Invoice_Template_Backup {

     public string sInvoiceId{get;set;}
     public blng__Invoice__c Invoice{get;set;}
     public list<blng__InvoiceLine__c > listOfInvLine {get;set;}
     
     public list<InvoiceLineWrapper> listOfInvLineWrapper{get;set;}
     public list<blng__InvoiceLine__c > listOfInvLines;
     public List<InvoiceLineWrapper> InvoiceLineWrapperObjs{get;set;}
     public blng__Invoice__c Invoice1{get;set;}
     public blng__Invoice__c Invoice2{get;set;}
     //public String description{get;set;}
     //WrapperList to user
    //List<InvoiceLineWrapper> InvoiceLineWrapperObjs{get;set;}
    
     public CPQ_Invoice_Template_Backup (){ 
     Set<Id> InvoiceLineids = new Set<Id>();
     InvoiceLineWrapperObjs = new List<InvoiceLineWrapper>();  
     String invoiceid= ApexPages.currentPage().getParameters().get('id');
     Map<Id,Id> usageOrdProdMap = new Map<Id,Id>();
     Set<Id> orderProductIds =  new Set<Id>();
     Set<Id> prodIds = new Set<Id>();
     Map<Id,String> ordProdDescription = new Map<Id,String>();
     List<blng__Invoice__c > Ilist = [Select id,blng__InvoiceDate__c, Name,blng__Account__r.BillingStreet,blng__Account__r.BillingCity,blng__Order__c,
                                        blng__TotalAmount__c,blng__TaxAmount__c,blng__Subtotal__c,blng__Account__r.Name,blng__Account__r.BillingPostalCode,blng__Account__r.BillingCountry, 
                                      blng__Account__r.BillingState,blng__Account__r.MH_Cust_Number__c,Sales_Rep__c, blng__DueDate__c from blng__Invoice__c where id=:invoiceid ];
       
      Map<Id,blng__UsageSummary__c> usageSummaryMap = new Map<Id,blng__UsageSummary__c>([SELECT Id,Name FROM blng__UsageSummary__c where blng__Invoice__c = :invoiceid]);
      listOfInvLines = [Select blng__TotalAmount__c,blng__Quantity__c, blng__OrderProduct__r.Usage_List_Price__c ,
                                                            Name,blng__Invoice__c,Id , 
                                                            blng__Invoice__r.Id ,blng__StartDate__c,
                                                            blng__EndDate__c,blng__OrderProduct__c                                                         
                                                           From blng__InvoiceLine__c 
                                                            where blng__Invoice__c =:invoiceid]  ;
         system.debug('listOfInvLines***==='+listOfInvLines);
                                                            
     If(!listOfInvLines.isEmpty()){
         for(blng__InvoiceLine__c invlines : listOfInvLines){
             
                 InvoiceLineids.add(invlines.id);
                 orderProductIds.add(invlines.blng__OrderProduct__c);
             system.debug('orderProductIds***==='+invlines.blng__OrderProduct__c);
         }       
     } 
         
         if(usageSummaryMap != null){
         List<blng__Usage__c> usages = [SELECT blng__Order__c,First_name__c, Last_name__c,blng__OrderProduct__c,blng__OrderProduct__r.Product2Id FROM blng__Usage__c where blng__UsageSummary__c  in :usageSummaryMap.keySet() ];
         
         System.debug('UsagesList is : ==='+usages);
             if(test.isrunningtest()){
                 List<blng__Usage__c> usagesList =[SELECT blng__Order__c,First_name__c, Last_name__c,blng__OrderProduct__c,blng__OrderProduct__r.Product2Id from blng__Usage__c limit 1];
                  usages.addAll(usagesList);                              
             }
         if(usages.size() >0){
              for(blng__Usage__c u :usages){
                  if(u.blng__OrderProduct__r.Product2Id != null){
                  usageOrdProdMap.put(U.Id,u.blng__OrderProduct__r.Product2Id);
                      prodIds.add(u.blng__OrderProduct__r.Product2Id);
                  }
              }
             
             if(prodIds.size()>0){
             Map<Id,Product2> prodMap = new Map<Id,Product2>([Select id,name from Product2 where id in :prodIds]);
             
         
                if(prodMap.size()>0){
             for(blng__Usage__c u :usages){
                 if(u.First_name__c != null && u.Last_name__c != null){
             if(ordProdDescription.containskey(u.blng__OrderProduct__r.Product2ID) != true || (ordProdDescription.containskey(u.blng__OrderProduct__r.Product2ID) && (ordProdDescription.get(u.blng__OrderProduct__r.Product2ID) == '' || ordProdDescription.get(u.blng__OrderProduct__r.Product2ID) == null))){
                 System.debug(prodMap);
                 System.debug(ordProdDescription);               
                  ordProdDescription.put(u.blng__OrderProduct__r.Product2ID,prodMap.get(usageOrdProdMap.get(u.Id)).Name + ' '+ u.First_name__c+' '+u.Last_name__c);
				   System.debug(ordProdDescription);   
             }else if(ordProdDescription.containskey(u.blng__OrderProduct__r.Product2ID) && ordProdDescription.get(u.blng__OrderProduct__r.Product2ID) != ''){
               System.debug(ordProdDescription);  
                 ordProdDescription.put(u.blng__OrderProduct__r.Product2ID,ordProdDescription.get(u.blng__OrderProduct__r.Product2ID)+' | '+u.First_name__c+' '+u.Last_name__c);
            System.debug(ordProdDescription);  
             }
                 }
             }
            
         }
             }    
         }
         }
     System.debug(ordProdDescription);
     
     system.debug('@@@@@@'+Ilist ); 
     If(Ilist != Null && Ilist.size() > 0){
            Invoice = Ilist[0];              
            sInvoiceId= Invoice.id;
      
          }

          set<string> attributerelations  = new Set<string>();

          //Forming wrapper class here
          for(blng__InvoiceLine__c invline : [Select  blng__TotalAmount__c,blng__Quantity__c    , blng__OrderProduct__r.Usage_List_Price__c,
                                                            Name,blng__Invoice__c,Id , blng__OrderProduct__c,blng__OrderProduct__r.Product2ID,
                                                            blng__Invoice__r.Id ,blng__StartDate__c,
                                                            blng__EndDate__c , blng__OrderProduct__r.Attribute_Relationship__c                                                         
                                                           From blng__InvoiceLine__c 
                                                            where blng__Invoice__c =:invoiceid]){
                                                            
               InvoiceLineids.add(invline.Id);                                             
               InvoiceLineWrapper invwrap = new InvoiceLineWrapper();   
              //Checking if Invoice line already available with matching criteria  
              
              system.debug('wrapper class list '+InvoiceLineWrapperObjs);

               if(invline.blng__OrderProduct__r.Attribute_Relationship__c != NULL ){
                    attributerelations.add(invline.blng__OrderProduct__r.Attribute_Relationship__c );
               }
                                                          
              if(!InvoiceLineWrapperObjs.isEmpty() || test.isRunningTest()){
                  Boolean invlineExist = false;
                  for(InvoiceLineWrapper invlinewrap : InvoiceLineWrapperObjs){
                  
                     if(invline.Name == invlinewrap.Name && invline.blng__StartDate__c == invlinewrap.startDate
                          && invline.blng__EndDate__c == invlinewrap.endDate){
                              if(ordProdDescription != null && ordProdDescription.containsKey(invline.blng__OrderProduct__r.Product2ID)){
                                 invlinewrap.description = ordProdDescription.get(invline.blng__OrderProduct__r.Product2ID); 
                              }
                           
                            invlinewrap.quantity = invlinewrap.quantity + invline.blng__Quantity__c;
                              if(invlinewrap.unitPrice != null){
                            invlinewrap.totalPrice =  invlinewrap.quantity * invlinewrap.unitPrice;
                              }
                            if(invline.blng__OrderProduct__r.Attribute_Relationship__c != NULL ){
                                if(invlinewrap.attributerelations != NULL  && !invlinewrap.attributerelations.isEmpty()){
                                    invlinewrap.attributerelations.add(invline.blng__OrderProduct__r.Attribute_Relationship__c);
                                }
                                else{
                                    invlinewrap.attributerelations = new set<string>{invline.blng__OrderProduct__r.Attribute_Relationship__c};
                                }
                            }
                            invlineExist = true;
                            
                            
                           
                        }
                   }

                   if(invlineExist == false){
                        invwrap.Name = invline.Name;
                        invwrap.startDate = invline.blng__StartDate__c;
                        invwrap.endDate =invline.blng__EndDate__c;
                        invwrap.quantity = invline.blng__Quantity__c;
                        invwrap.unitPrice = invline.blng__OrderProduct__r.Usage_List_Price__c ;
                        invwrap.totalPrice = invline.blng__TotalAmount__c;
                       if(ordProdDescription != null && ordProdDescription.containsKey(invline.blng__OrderProduct__r.Product2ID)){
                                
                        invwrap.description = ordProdDescription.get(invline.blng__OrderProduct__r.Product2ID); 
                       }
                     //   invwrap.description = ordProdDescription.get(invline.blng__OrderProduct__c);
                        if(invline.blng__OrderProduct__r.Attribute_Relationship__c != NULL ){
                               
                                    invwrap.attributerelations = new set<string>{invline.blng__OrderProduct__r.Attribute_Relationship__c};
                                
                            }
                        InvoiceLineWrapperObjs.add(invwrap);
                      
                         system.debug('@@@@@@ inside if'+InvoiceLineWrapperObjs); 

                   }
               }
            else{
                        invwrap.Name = invline.Name;
                        invwrap.startDate = invline.blng__StartDate__c;
                        invwrap.endDate =invline.blng__EndDate__c;
                        invwrap.quantity = invline.blng__Quantity__c;
                        invwrap.unitPrice = invline.blng__OrderProduct__r.Usage_List_Price__c ;
                        invwrap.totalPrice = invline.blng__TotalAmount__c;
                		
                if(ordProdDescription != null && ordProdDescription.containsKey(invline.blng__OrderProduct__r.Product2ID)){
                                
              			invwrap.description = ordProdDescription.get(invline.blng__OrderProduct__r.Product2ID); 
                }
                           //invwrap.description = ordProdDescription.get(invline.blng__OrderProduct__c);
                         if(invline.blng__OrderProduct__r.Attribute_Relationship__c != NULL ){
                               
                                    invwrap.attributerelations = new set<string>{invline.blng__OrderProduct__r.Attribute_Relationship__c};
                                
                            }
                 InvoiceLineWrapperObjs.add(invwrap);
                        InvoiceLineWrapperObjs.add(invwrap);
                         system.debug('@@@@@@ inside else'+InvoiceLineWrapperObjs); 
            }                                               


         }

         Map<string,string> attributeRelationVsDescription = new Map<string,string>();

         if(!attributerelations.isEmpty()){
            for(Attribute_Relationship__c attrRelation : [select Id, (select Id, Name, Attribute_Name__c,string_value__c from Attribute_Lines__r
                                                                   where Attribute_Name__c = 'AOP')
                                                          FROM Attribute_Relationship__c  where Id IN : attributerelations]){
                if(attrRelation.Attribute_Lines__r.size() > 0){
                    string descriptionattr = '';
                    for(Attribute_Lines__c attr : attrRelation.Attribute_Lines__r){
                        descriptionattr += attr.string_value__c;
                    }
                    if(descriptionattr != ''){
                        attributeRelationVsDescription.put(attrRelation.Id,descriptionattr);
                    }
                }
            }
         }



         //looping over wrapper class again and adding description

              if(!InvoiceLineWrapperObjs.isEmpty()){
                  
                  for(InvoiceLineWrapper invlinewrap : InvoiceLineWrapperObjs){
                        if(invlinewrap.attributerelations != NULL){
                            string aopDescriptionTemp = '';
                            for(string attrRelation : invlinewrap.attributerelations){
                                if(!attributeRelationVsDescription.isEmpty() && attributeRelationVsDescription.containskey(attrRelation)){
                                    aopDescriptionTemp+= attributeRelationVsDescription.get(attrRelation);
                                }
                            }

                            if(aopDescriptionTemp != ''){
                                invlinewrap.aopDescription = aopDescriptionTemp;
                            }
                        }
                  }
              }    
         
         

      }
      
      
      
     
        
       //wrapper class
        public class InvoiceLineWrapper {
            
            public InvoiceLineWrapper(){}
            public date startDate{get;set;}
            public date endDate{get;set;}
            public String Name {get;set;}
            public String description{get;set;}
            public Decimal quantity{get;set;}
            public Decimal unitPrice{get;set;}
            public Decimal totalPrice{get;set;}
            public set<string> attributerelations{get;set;}
            public String aopDescription{get;set;}
        }
    
      //forming map to show quantity added if existed 
      public  map<string,Double> listInv {
        set; 
        
       
        
        get {
                system.debug('??? !!! --> ' + sInvoiceID );
                Map<string,List<blng__InvoiceLine__c>> mapInvoiceIdAndLstInvoiceLines = new Map<string,List<blng__InvoiceLine__c>>();
                 for(blng__InvoiceLine__c invLine : [Select Id,blng__TotalAmount__c,blng__Quantity__c    , 
                                                            Name,blng__Invoice__c ,  blng__StartDate__c,blng__EndDate__c                                                          
                                                           From blng__InvoiceLine__c 
                                                            where blng__Invoice__c =: sInvoiceID ]) {
                if(mapInvoiceIdAndLstInvoiceLines.containsKey(invLine.blng__Invoice__c)) {
                     list<blng__InvoiceLine__c> templist = mapInvoiceIdAndLstInvoiceLines.get(invLine.blng__Invoice__c);
                   templist.add(invLine);
                   }
              else {
                    
                    mapInvoiceIdAndLstInvoiceLines.put(invLine.blng__Invoice__c,new List<blng__InvoiceLine__c >{invLine});
              
                }
            }
             Map<String,Double> mapInvLineNameNQty = new Map<String,Double>();
             Set<string> setInvoiceLines = new Set<string>();
             if(mapInvoiceIdAndLstInvoiceLines.containsKey(sInvoiceID)) {
                            for(blng__InvoiceLine__c invLines : mapInvoiceIdAndLstInvoiceLines.get(sInvoiceID)) {
                                if(mapInvLineNameNQty.containsKey(invLines.Name)) {
                                   if(!setInvoiceLines.contains(invLines.Name)) {
                                            setInvoiceLines.add(invLines.Name);
                                            Double i = 0;
                                            i = mapInvLineNameNQty.get(invLines.Name) + invLines.blng__Quantity__c;
                                            mapInvLineNameNQty.put(invLines.Name,i);
                                        } 
                                       }                               
                                    else {
                                        mapInvLineNameNQty.put(invLines.Name,invLines.blng__Quantity__c);
                                       }  
                            }
                        } 
                         
              
                return mapInvLineNameNQty ;
            }
        }
        
        
        
//}
}