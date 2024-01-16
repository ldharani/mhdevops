public class testingwrapperinvoice {
   
    
     //wrapper class
        public class InvoiceLineWrapper {
            
            public date startDate{get;set;}
            public date endDate{get;set;}
            public String Name {get;set;}
            public Decimal quantity{get;set;}
            public Decimal unitPrice{get;set;}
            public Decimal totalPrice{get;set;}
            public set<string> attributerelations{get;set;}
            public String aopDescription{get;set;}
            public set<string> usageSummaries{get;set;}
        }
    
    public static List<InvoiceLineWrapper> testinginvoicewrap(string invoiceid){
      
        List<InvoiceLineWrapper> InvoiceLineWrapperObjs = new List<InvoiceLineWrapper>(); 
         Set<Id> InvoiceLineids = new Set<Id>();
         set<string> attributerelations  = new Set<string>();
           set<string> usageSummaries  = new Set<string>();
       
         //Forming wrapper class here
          for(blng__InvoiceLine__c invline : [Select  blng__TotalAmount__c,blng__Quantity__c    , blng__OrderProduct__r.Usage_List_Price__c,
                                                            Name,blng__Invoice__c,Id , 
                                                            blng__Invoice__r.Id ,blng__StartDate__c,
                                                            blng__EndDate__c , blng__OrderProduct__r.Attribute_Relationship__c,
                                                            blng__UsageSummary__c,blng__OrderProduct__r.Order.Name                                                         
                                                           From blng__InvoiceLine__c 
                                                            where blng__Invoice__c =:invoiceid]){
                                                                
                                                                                                          
               system.debug('@@ invoice name '+ invline.Name); 
               system.debug('@@ invoice start Date '+ invline.blng__StartDate__c); 
               InvoiceLineids.add(invline.Id);                                             
               InvoiceLineWrapper invwrap = new InvoiceLineWrapper();                                             
              //Checking if Invoice line already available with matching criteria  
              
              system.debug('wrapper class list '+InvoiceLineWrapperObjs);

               if(invline.blng__OrderProduct__r.Attribute_Relationship__c != NULL ){
                    attributerelations.add(invline.blng__OrderProduct__r.Attribute_Relationship__c );
               }

                if(invline.blng__UsageSummary__c!= NULL ){
                    usageSummaries.add(invline.blng__UsageSummary__c );
               }
                                                          
              if(!InvoiceLineWrapperObjs.isEmpty()){
                  Boolean invlineExist = false;
                  for(InvoiceLineWrapper invlinewrap : InvoiceLineWrapperObjs){
                  
                     if(invline.Name == invlinewrap.Name && invline.blng__StartDate__c == invlinewrap.startDate
                          && invline.blng__EndDate__c == invlinewrap.endDate){
                          
                          
                            invlinewrap.quantity = invlinewrap.quantity + invline.blng__Quantity__c;
                              if(invlinewrap.unitPrice != Null){
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

                            if(invline.blng__UsageSummary__c != NULL ){
                                if(invlinewrap.usageSummaries != NULL  && !invlinewrap.usageSummaries.isEmpty()){
                                    invlinewrap.usageSummaries.add(invline.blng__UsageSummary__c);
                                }
                                else{
                                    invlinewrap.usageSummaries = new set<string>{invline.blng__UsageSummary__c};
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
                        invwrap.totalPrice = invline.blng__TotalAmount__c;
                        if(invline.blng__OrderProduct__r.Attribute_Relationship__c != NULL ){
                               
                                    invwrap.attributerelations = new set<string>{invline.blng__OrderProduct__r.Attribute_Relationship__c};
                                
                            }
                        if(invline.blng__UsageSummary__c!= NULL ){
                               
                                    invwrap.usageSummaries = new set<string>{invline.blng__UsageSummary__c};
                                
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
                        if(invline.blng__OrderProduct__r.Attribute_Relationship__c != NULL ){
                               
                                    invwrap.attributerelations = new set<string>{invline.blng__OrderProduct__r.Attribute_Relationship__c};
                                
                            }
                         if(invline.blng__UsageSummary__c != NULL ){
                               
                                    invwrap.usageSummaries = new set<string>{invline.blng__UsageSummary__c};
                                
                            }
                        InvoiceLineWrapperObjs.add(invwrap);
                         system.debug('@@@@@@ inside else'+InvoiceLineWrapperObjs); 
            }                                               


         }
        
        
        
         Map<string,string> attributeRelationVsDescription = new Map<string,string>();

         if(!attributerelations.isEmpty()){
            for(Attribute_Relationship__c attrRelation : [select Id, (select Id, Name, Attribute_Name__c,string_value__c from Attribute_Lines__r
                                                                   where Attribute_Name__c = 'Practice Area' and string_value__c != NULL)
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
        
        system.debug('@@@@attributeRelationVsDescription'+attributeRelationVsDescription);
         
         Map<string,string> usageSummaryVsDescription = new Map<string,string>();
          //string description = '';
          
         system.debug('@@@@usageSummaries'+usageSummaries);
          
         if(!usageSummaries.isEmpty()){
            for(blng__Usage__c us : [select Id, First_name__c, Last_name__c, blng__UsageSummary__c
                                         FROM blng__Usage__c where blng__UsageSummary__c IN : usageSummaries
                                       AND First_name__c != NULL and Last_name__c != NULL and blng__UsageSummary__c != NULL]){
                if(usageSummaryVsDescription.containskey(us.blng__UsageSummary__c)){
                
                    string description  = usageSummaryVsDescription.get(us.blng__UsageSummary__c) + ',' + us.First_name__c+ ' '+ us.Last_name__c;
                    usageSummaryVsDescription.put(us.blng__UsageSummary__c, description);
                }
                else{
                    usageSummaryVsDescription.put(us.blng__UsageSummary__c, us.First_name__c + ' '+ us.Last_name__c);
                }
            }
         }
        
        System.debug('@@@usageSummaryVsDescription'+usageSummaryVsDescription);
        
        
         //looping over wrapper class again and adding description

              if(!InvoiceLineWrapperObjs.isEmpty()){
                  
                  for(InvoiceLineWrapper invlinewrap : InvoiceLineWrapperObjs){
                       string aopDescriptionTemp = '';
                        if(invlinewrap.attributerelations != NULL){
                           
                            for(string attrRelation : invlinewrap.attributerelations){
                                if(!attributeRelationVsDescription.isEmpty() && attributeRelationVsDescription.containskey(attrRelation)){
                                    aopDescriptionTemp+= attributeRelationVsDescription.get(attrRelation);
                                }
                            }

                           
                        }


                        //Logic for adding names
                         if(invlinewrap.usageSummaries != NULL){
                           system.debug('@@@@@@ inside else'+invlinewrap.usageSummaries); 
                            for(string usId : invlinewrap.usageSummaries){
                                
                                system.debug('@@@@@@ usId '+usId ); 
                                if(!usageSummaryVsDescription.isEmpty() && usageSummaryVsDescription.containskey(usId)){
                                
                                
                                    aopDescriptionTemp+=  ''+ '  -  '+usageSummaryVsDescription.get(usId);
                                }
                            }
                         }
                      
                       if(aopDescriptionTemp != ''){
                                invlinewrap.aopDescription = aopDescriptionTemp;
                        }
                  }
              }
        
        system.debug('@@@InvoiceLineWrapperObjs'+InvoiceLineWrapperObjs);
        
        return InvoiceLineWrapperObjs;
    }
  /*
      public  void FkMethod(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }*/
    
}