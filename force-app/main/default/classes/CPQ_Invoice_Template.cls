public with sharing class CPQ_Invoice_Template {

     public string sInvoiceId{get;set;}
     public blng__Invoice__c Invoice{get;set;}
     public list<blng__InvoiceLine__c > listOfInvLine {get;set;}
     
     public list<InvoiceLineWrapper> listOfInvLineWrapper{get;set;}
     public list<blng__InvoiceLine__c > listOfInvLines;
     public List<InvoiceLineWrapper> InvoiceLineWrapperObjs{get;set;}
     public blng__Invoice__c Invoice1{get;set;}
     public blng__Invoice__c Invoice2{get;set;}
    public  List<OrderItem> Orders = new List<OrderItem>();
    public Integer usageWithCreditCount {get;set;}
    public Decimal totalCreditAmount {get;set;}
    public Decimal usageUnitPrice {get;set;}
    public Integer usageCount {get;set;}
    public static Double subtotal {get;set;}
    public Map<Id,String> InvoiceLineDescByUsage = new Map<Id,String>();
    public Map<Id,String> InvoiceLineDescByUsageCredited = new Map<Id,String>();
   
     //public String description{get;set;}
     //WrapperList to user
    //List<InvoiceLineWrapper> InvoiceLineWrapperObjs{get;set;}
    
     public CPQ_Invoice_Template (){ 
         usageWithCreditCount=0;
         usageCount=0;
         subtotal=0;
     Set<Id> InvoiceLineids = new Set<Id>();
     InvoiceLineWrapperObjs = new List<InvoiceLineWrapper>(); 
     
     String invoiceid= ApexPages.currentPage().getParameters().get('id');
     Map<Id,Id> usageOrdProdMap = new Map<Id,Id>();
     Set<Id> orderProductIds =  new Set<Id>();
     Set<Id> prodIds = new Set<Id>();
     Map<Id,String> ordProdDescription = new Map<Id,String>();
     Map<Id,String> ordProdDescriptionWithCredit = new Map<Id,String>();
           System.debug('invoice template');
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
         system.debug('listOfInvLines***==='+listOfInvLines.size());
     Map<blng__InvoiceLine__c,List<blng__Usage__c>> InvLineUsageMap = new  Map<blng__InvoiceLine__c,List<blng__Usage__c>>();
     Map<Id,List<blng__Usage__c>> InvLineUsagePdfMap = new  Map<Id,List<blng__Usage__c>>();
     Map<Id,List<blng__Usage__c>> InvLineUsageCreditedPdfMap = new  Map<Id,List<blng__Usage__c>>();
         
         Map<blng__InvoiceLine__c,List<ID>> InvLineOrderProdIDMap = new  Map<blng__InvoiceLine__c,List<ID>>();   
         List<Id> SelectedInvlineIds = new List<Id>();
         Map<Id,List<ID>> OrderProdOrderIDMap = new  Map<Id,List<ID>>();   
        
     If(!listOfInvLines.isEmpty()){
         for(blng__InvoiceLine__c invlines : listOfInvLines){
                 InvoiceLineids.add(invlines.id);
                 orderProductIds.add(invlines.blng__OrderProduct__c);
             	if(InvLineOrderProdIDMap.get(invlines)==null)
                    InvLineOrderProdIDMap.put(invlines,new List<ID>{invlines.blng__OrderProduct__c});
                else
                {
                    InvLineOrderProdIDMap.get(invlines).add(invlines.blng__OrderProduct__c);
                    InvLineOrderProdIDMap.put(invlines,InvLineOrderProdIDMap.get(invlines));
                } 
             //map->id,obj
             system.debug('orderProductIds***==='+invlines.blng__OrderProduct__c);
         }       
     } 
         System.debug('InvLineOrderProdIDMapVVVVVV'+InvLineOrderProdIDMap);
         
     Orders = [select id,Order_id__c from OrderItem where id in :orderProductIds];
         List<Id> OrderIds = new List<Id>();
         for(OrderItem ord :Orders)
         {
             OrderIds.add(ord.Order_id__c);
			 
                if(OrderProdOrderIDMap.get(ord.id)==null)
                    OrderProdOrderIDMap.put(ord.id,new List<ID>{ord.Order_id__c});
                else
                {
                    OrderProdOrderIDMap.get(ord.id).add(ord.Order_id__c);
                    OrderProdOrderIDMap.put(ord.id,OrderProdOrderIDMap.get(ord.id));
                } 
         }
         
        // if(usageSummaryMap != null)
         {
       // List<blng__Usage__c> usages = [SELECT blng__Order__c,First_name__c, Last_name__c,blng__OrderProduct__c,blng__OrderProduct__r.Product2Id FROM blng__Usage__c where blng__UsageSummary__c  in :usageSummaryMap.keySet() ];
        List<blng__Usage__c> usagesObjs = [SELECT name,blng__Order__c,First_name__c, Last_name__c,blng__OrderProduct__c,blng__OrderProduct__r.Product2Id,Credit_Amount__c,Credit_Status__c,blng__StartDateTime__c,blng__EndDateTime__c,Date_of_credit__c,blng__UnitPrice__c FROM blng__Usage__c where blng__Order__c  in :OrderIds ];
         for(blng__Usage__c usg:usagesObjs)
         {
            // InvLineUsageMap
            
             for(Id OpId:OrderProdOrderIDMap.keySet())
				{
					if(OrderProdOrderIDMap.get(OpId).contains(usg.blng__Order__c))
					{
						for(blng__InvoiceLine__c InvLine:InvLineOrderProdIDMap.keySet())
						{
                            Date firstDayOfMonth = InvLine.blng__StartDate__c.toStartOfMonth();
                            Date lastDayOfMonth = InvLine.blng__EndDate__c.addDays(Date.daysInMonth(InvLine.blng__EndDate__c.year(), InvLine.blng__EndDate__c.month()) - 1);
							if(InvLineOrderProdIDMap.get(InvLine).contains(OpId) && firstDayOfMonth!=InvLine.blng__StartDate__c && lastDayOfMonth!=InvLine.blng__EndDate__c)
							{
                                System.debug('InvLineUsageMap'+InvLine.Id);
                              if(usg.blng__StartDateTime__c>=InvLine.blng__StartDate__c && usg.blng__EndDateTime__c<=InvLine.blng__EndDate__c )
                                {
						 		if(InvLineUsageMap.get(InvLine)==null)
									{	
										InvLineUsageMap.put(InvLine,new List<blng__Usage__c>{usg});
                                        InvLineUsagePdfMap.put(InvLine.Id,new List<blng__Usage__c>{usg});
										System.debug('InvLineUsageMap'+usg.name+' '+usg.blng__StartDateTime__c+' '+InvLine.blng__StartDate__c);
									}
                				else
                				{
                    				InvLineUsageMap.get(InvLine).add(usg);
                    				InvLineUsageMap.put(InvLine,InvLineUsageMap.get(InvLine));
                                    InvLineUsagePdfMap.put(InvLine.Id,InvLineUsageMap.get(InvLine));
									System.debug('InvLineUsageMap'+usg.name+' '+usg.blng__StartDateTime__c+' '+InvLine.blng__StartDate__c);
                				} 
                                    SelectedInvlineIds.add(InvLine.Id);
                                }
							}
						}
					}
				}
            
			
         }
             System.debug('InvLineUsageMap'+InvLineUsageMap.size());
		for(List<blng__Usage__c> usgList:InvLineUsageMap.values())
        {
            System.debug('usgList'+usgList.size());
             for(blng__Usage__c u :usgList){
                  if(u.blng__OrderProduct__r.Product2Id != null){
                  		usageOrdProdMap.put(U.Id,u.blng__OrderProduct__r.Product2Id);
                      	prodIds.add(u.blng__OrderProduct__r.Product2Id);
                  }
              }
        }
        
        if(prodIds.size()>0){
             Map<Id,Product2> prodMap = new Map<Id,Product2>([Select id,name from Product2 where id in :prodIds]);
             for(blng__InvoiceLine__c InvLine:InvLineUsageMap.keySet())
                 {
                     System.debug(InvLine.Name+' - '+InvLine.id);
                      for(blng__Usage__c usg:InvLineUsageMap.get(InvLine))
                      {
                          if(InvoiceLineDescByUsage.get(InvLine.Id)==null)
                          {
                              InvoiceLineDescByUsage.put(InvLine.Id,prodMap.get(usageOrdProdMap.get(usg.Id)).Name);
                              String descr = InvoiceLineDescByUsage.get(InvLine.Id) + +' - '+usg.First_name__c+' '+usg.Last_name__c;
                              InvoiceLineDescByUsage.put(InvLine.Id,descr);
                              System.debug('InvoiceLineDescByUsage'+InvoiceLineDescByUsage.get(InvLine.Id));
                          }
                          else
                          {
                              String descr = InvoiceLineDescByUsage.get(InvLine.Id) + +' | '+usg.First_name__c+' '+usg.Last_name__c;
                              InvoiceLineDescByUsage.put(InvLine.Id,descr);
                              System.debug('InvoiceLineDescByUsage'+InvoiceLineDescByUsage.get(InvLine.Id));
                          }
                          
                           if(usg.Credit_Amount__c>=0 && usg.Credit_Status__c =='Posted'  )
                           {
								if(InvoiceLineDescByUsageCredited.get(InvLine.Id)==null)
                          		{
                              		InvoiceLineDescByUsageCredited.put(InvLine.Id,prodMap.get(usageOrdProdMap.get(usg.Id)).Name);
                              		String descr = InvoiceLineDescByUsageCredited.get(InvLine.Id) + +' - '+usg.First_name__c+' '+usg.Last_name__c;
                              		InvoiceLineDescByUsageCredited.put(InvLine.Id,descr);
                                    
                              		System.debug('InvoiceLineDescByUsageCredited'+InvoiceLineDescByUsageCredited.get(InvLine.Id));
                          		}
                          		else
                          		{
                              		String descr = InvoiceLineDescByUsageCredited.get(InvLine.Id) + +' | '+usg.First_name__c+' '+usg.Last_name__c;
                              		InvoiceLineDescByUsageCredited.put(InvLine.Id,descr);
                              		System.debug('InvoiceLineDescByUsageCredited'+InvoiceLineDescByUsageCredited.get(InvLine.Id));
                          		} 
                               
                               if(InvLineUsageCreditedPdfMap.get(InvLine.Id)==null)
									{	
                                        InvLineUsageCreditedPdfMap.put(InvLine.Id,new List<blng__Usage__c>{usg});
									}
                				else
                				{
                    				InvLineUsageCreditedPdfMap.get(InvLine.Id).add(usg);
                                    InvLineUsageCreditedPdfMap.put(InvLine.Id,InvLineUsageCreditedPdfMap.get(InvLine.Id));
								} 
                           }
                          
                      }
                 }
        }
             System.debug('InvoiceLineDescByUsage'+InvoiceLineDescByUsage);
        List<blng__Usage__c> usages = new  List<blng__Usage__c>();
        for(blng__InvoiceLine__c invline : listOfInvLines)
        {
            for(blng__Usage__c usg:usagesObjs)
            {
                if(usg.blng__StartDateTime__c>=invline.blng__StartDate__c && usg.blng__EndDateTime__c<=invline.blng__EndDate__c )
                {
                    usages.add(usg);
                }
            }
        }
             
             // List<blng__Usage__c> usagesWithCredit = new List<blng__Usage__c>();
             system.debug('usagesFromOrdervvv***==='+usages); 
         System.debug('UsagesList is : ==='+usages);
             if(test.isrunningtest()){
                 List<blng__Usage__c> usagesList =[SELECT blng__Order__c,First_name__c, Last_name__c,blng__OrderProduct__c, Credit_Amount__c,Credit_Status__c,blng__OrderProduct__r.Product2Id,blng__UnitPrice__c from blng__Usage__c limit 1];
                  usages.addAll(usagesList);                              
             }
       
         }
 
     
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
                                                            where blng__Invoice__c =:invoiceid])
              
          {
              if(SelectedInvlineIds.contains(invline.id))
          {                                               
               InvoiceLineids.add(invline.Id);                                             
               InvoiceLineWrapper invwrap = new InvoiceLineWrapper();  
               InvoiceLineWrapper invwrapwithcredit = new InvoiceLineWrapper();  
              //Checking if Invoice line already available with matching criteria  
              
              system.debug('wrapper class list '+InvoiceLineWrapperObjs);

               if(invline.blng__OrderProduct__r.Attribute_Relationship__c != NULL ){
                    attributerelations.add(invline.blng__OrderProduct__r.Attribute_Relationship__c );
               }
            
            {
                System.debug('Entered calc part-wwwwwwwwwwwwwwwwwwwwwww');
                //wwwwwwwwwwwwwwwwwwwwwww
                        invwrap.Name = invline.Name;
                        invwrap.startDate = invline.blng__StartDate__c;
                        invwrap.endDate =invline.blng__EndDate__c;
                        invwrap.quantity = InvLineUsagePdfMap.get(invline.Id).size();
                        invwrap.unitPrice = invline.blng__OrderProduct__r.Usage_List_Price__c;
                        //invwrap.totalPrice = invline.blng__TotalAmount__c;
                        invwrap.totalPrice = invline.blng__OrderProduct__r.Usage_List_Price__c * InvLineUsagePdfMap.get(invline.Id).size();
                subtotal=subtotal+invwrap.totalPrice;
                
                        invwrapwithcredit.Name = invline.Name;
                        invwrapwithcredit.startDate = invline.blng__StartDate__c;
                        invwrapwithcredit.endDate =invline.blng__EndDate__c;
                        //invwrapwithcredit.quantity = invline.blng__Quantity__c;
                        if(InvLineUsageCreditedPdfMap.isEmpty())
                        {
                            invwrapwithcredit.quantity = 0;
                            invwrapwithcredit.totalPrice = 0;
                        }
                		else
                        {
                            System.debug('pdfmapinvid'+InvLineUsageCreditedPdfMap.get(invline.Id));
                            if(InvLineUsageCreditedPdfMap.get(invline.Id)==null)
                            {
                                
                            }
                            else{
                            invwrapwithcredit.quantity = InvLineUsageCreditedPdfMap.get(invline.Id).size();
                            invwrapwithcredit.totalPrice = 0-invline.blng__OrderProduct__r.Usage_List_Price__c * InvLineUsageCreditedPdfMap.get(invline.Id).size();
                            subtotal=subtotal+invwrapwithcredit.totalPrice;
                            }
                        }
                        
                        invwrapwithcredit.unitPrice = 0-Integer.valueOf(invline.blng__OrderProduct__r.Usage_List_Price__c);
                        
           
                // invwrapwithcredit.totalPrice = invline.blng__TotalAmount__c;
                System.debug('invwrapwithcredit'+invwrapwithcredit);
         //      subtotal=subtotal+invwrapwithcredit.totalPrice;
                //(invline.blng__OrderProduct__r.Usage_List_Price__c*usageCount) - (invline.blng__OrderProduct__r.Usage_List_Price__c*usageWithCreditCount)  ;
                //InvoiceLineDescByUsage    
              
                invwrap.description = InvoiceLineDescByUsage.get(invline.id);  
                invwrapwithcredit.description = InvoiceLineDescByUsageCredited.get(invline.id);
                        System.debug('usageWithCreditCount : '+usageWithCreditCount+' - '+usageCount);
                if(ordProdDescription != null && ordProdDescription.containsKey(invline.blng__OrderProduct__r.Product2ID)){
                                
                     //   invwrap.description = ordProdDescription.get(invline.blng__OrderProduct__r.Product2ID); 
                }
                if(ordProdDescriptionWithCredit != null && ordProdDescriptionWithCredit.containsKey(invline.blng__OrderProduct__r.Product2ID)){
                                
                      //  invwrapwithcredit.description = ordProdDescriptionWithCredit.get(invline.blng__OrderProduct__r.Product2ID); 
                 //   System.debug('');
                }
                //
                         //  invwrap.description = ordProdDescription.get(invline.blng__OrderProduct__c);
                         if(invline.blng__OrderProduct__r.Attribute_Relationship__c != NULL ){
                               
                                    invwrap.attributerelations = new set<string>{invline.blng__OrderProduct__r.Attribute_Relationship__c};
                                invwrapwithcredit.attributerelations = new set<string>{invline.blng__OrderProduct__r.Attribute_Relationship__c};
                            }
                 InvoiceLineWrapperObjs.add(invwrapwithcredit);
                 InvoiceLineWrapperObjs.add(invwrap);
                         system.debug('@@@@@@ inside else'+InvoiceLineWrapperObjs); 
            }                                               


          }}

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
        
        
        }
//}