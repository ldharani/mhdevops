/**
Last modified by Ieswarya on Sep 9,2020 for MHBS-4006
*/public class generatePDFController{
    //public Account account{get;set;}
    /*public actionStatusImage(){
        account = new Account();
    }*/
    public Id oppid {get;set;}
    public opportunity opp{get;set;}
    public boolean error{get;set;}
    
    public generatePDFController(ApexPages.StandardController controller) {
        oppid = ApexPages.currentPage().getParameters().get('id');
    }
    
    public pagereference quotePDF(){
        
        error = false;
        string errorString = '';
        //String upsellOpptyId;
          Map<id,String> oppProductVsOppName = new Map<id,String>();
        
        Set<Id> childNParentOpptyIds = new Set<Id>();
        list<Opportunity_Charge_Attribute__c> listOfOpptAttributes = new list<Opportunity_Charge_Attribute__c>();
        list<invoiceit_crmx__Opportunity_Product__c> listofOppProducts = new list<invoiceit_crmx__Opportunity_Product__c>();
        list<invoiceit_crmx__Opportunity_Product__c> listofInvOppProducts = new list<invoiceit_crmx__Opportunity_Product__c>();
        list<invoiceit_crmx__Opportunity_Product__c> listofOrgOppProducts = new list<invoiceit_crmx__Opportunity_Product__c>();
        list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> listopportRPC = new list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        Boolean middleRepBoost = False;
        Boolean upperRepBoost = False;
        Set<String> ListInventoryIds = new Set<String>();
        Set<String> duplicateInvIds = new Set<String>(); 
  
        Set<id> repBoostSet = new Set<Id>();
        
        Opportunity opport = [Select id, name,Lock_Record__c,IsUpsellOppty__c,Auth_By_Contact_Email__c,invoiceit_crmx__Discount_Percent__c,Ngage_Source__c, StageName,Discoint_Approved__c, RecordType.Name, Parent_Opportunity__c,Parent_Opportunity__r.Id,(Select id, name,Parent_Opportunity__r.Id,RecordType.Name,Parent_Opportunity__c From Child_Opportunities__r ORDER BY CreatedDate LIMIT 1) From Opportunity Where id=: oppid];
        
        childNParentOpptyIds.add(opport.id);
        if(!opport.Child_Opportunities__r.isempty()){
            childNParentOpptyIds.add(opport.Child_Opportunities__r[0].Id);
        }
        System.debug('======childNParentOpptyIds===='+childNParentOpptyIds);
        listOfOpptAttributes = [SELECT Attribute_Order__c,Opportunity_Rate_Plan_Charge__r.Name,Picklist_Value__c,Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c,Attribute_Picklist_Values__c,Phone_Value__c, Name,
                                    Attribute_Name__c,Attribute_Type__c,Boolean_Value__c,Date_Value__c,Number_Value__c,Opportunity_Rate_Plan_Charge__c,String_Value__c,Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Name,Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c,Required__c,Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c
                                    FROM Opportunity_Charge_Attribute__c
                                    WHERE Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c  in: childNParentOpptyIds];
        
        
        
        if(opport.Parent_Opportunity__c!= NULL){
            error = true;
            errorString = 'PDF cannot be generated for this Opportunity as it is a child opportunity.';
                            
        }
        
        System.debug('listOfOpptAttributes==================='+listOfOpptAttributes );
         map<Id,list<Opportunity_Charge_Attribute__c>> mapofOppToAttributes = new map<Id,list<Opportunity_Charge_Attribute__c>>();
         map<string,list<Opportunity_Charge_Attribute__c>> mapofURLToAttributes = new map<string,list<Opportunity_Charge_Attribute__c>>();
         
 if(!listOfOpptAttributes.isEmpty()){
                             
        for(Opportunity_Charge_Attribute__c ObjAtt: listOfOpptAttributes){
        if(ObjAtt.Attribute_Name__c == 'URL' && (ObjAtt.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Name == 'Web Bronze' || ObjAtt.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Name == 'Web Silver' )){
        String OppId = ObjAtt.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c;
        if(ObjAtt.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c != '01980'){
            
          
            
            //to check if more than one product has same url
            if(mapofURLToAttributes.containskey(ObjAtt.String_Value__c)){
              list<Opportunity_Charge_Attribute__c> templist = mapofURLToAttributes.get(ObjAtt.String_Value__c);
              templist.add(ObjAtt);
              mapofURLToAttributes.put(ObjAtt.String_Value__c,templist);
            }else{
               mapofURLToAttributes.put(ObjAtt.String_Value__c, new list<Opportunity_Charge_Attribute__c> {ObjAtt});
            }
          }
       }
    }
        
         for(Opportunity_Charge_Attribute__c ObjAtt: listOfOpptAttributes){
            if(ObjAtt.Attribute_Name__c == 'URL'){
        
        String OppId = ObjAtt.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c;
             
          if(ObjAtt.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c == '01980'){
             
           
          
          //to verify if same url applies to more product
            if(mapofURLToAttributes.containskey(ObjAtt.String_Value__c)){
               if(mapofURLToAttributes.get(ObjAtt.String_Value__c).size()>1){
                   error=true;
                  errorstring = 'Two Web products cannot contain the same URL. Please review';
              
               }
            }else{
             error=true;
             errorstring = 'Review Page Plus product can only be added along with Web Bronze or Web Silver product';
              
           }
        }
    }
  }
}

        if(!listOfOpptAttributes.isEmpty()){
            
            for(Opportunity_Charge_Attribute__c attribute : listOfOpptAttributes){
                if(attribute.Attribute_Type__c == 'Text'){
                    
                    if(attribute.String_Value__c == '' || attribute.String_Value__c == null){
                        if(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c!=Null){
                            error = true;
                            errorString = 'You can not generate the PDF since Child Ngage Opportunity attributes are blank';
                            
                        }else{
                            error = true;
                            errorString = 'You can not generate the PDF since few attributes are blank';
                        }
                        
                        
                    }

                } 
                
                else if(attribute.Attribute_Type__c == 'Number'){

                    if(attribute.Number_Value__c == null){
                        if(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c!=Null){
                            error = true;
                            errorString = 'You can not generate the PDF since Child Ngage Opportunity attributes are blank';
                            
                        }else{
                            error = true;
                            errorString = 'You can not generate the PDF since few attributes are blank';
                        }
                    }

                }

                else if(attribute.Attribute_Type__c == 'Boolean'){

                    if(attribute.Boolean_Value__c != true){
                        if(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c!=Null){
                            error = true;
                            errorString = 'You can not generate the PDF since Child Ngage Opportunity attributes are blank';
                            
                        }else{
                            error = true;
                            errorString = 'You can not generate the PDF since few attributes are blank';
                        }
                    }

                }
                else if(attribute.Attribute_Type__c == 'Picklist'){

                    if(attribute.Picklist_Value__c == '' || attribute.Picklist_Value__c == null){
                        if(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c!=Null){
                            error = true;
                            errorString = 'You can not generate the PDF since Child Ngage Opportunity attributes are blank';
                            
                        }else{
                            error = true;
                            errorString = 'You can not generate the PDF since few attributes are blank';
                        }
                    }

                }
                else if(attribute.Attribute_Type__c == 'Date'){

                    if(attribute.Date_Value__c == null){
                        if(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c!=Null){
                            error = true;
                            errorString = 'You can not generate the PDF since Child Ngage Opportunity attributes are blank';
                            
                        }else{
                            error = true;
                            errorString = 'You can not generate the PDF since few attributes are blank';
                        }
                    }

                }
                else if(attribute.Attribute_Type__c == 'Phone'){

                    if(attribute.Phone_Value__c == null){
                        if(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c!=Null){
                            error = true;
                            errorString = 'You can not generate the PDF since Child Ngage Opportunity attributes are blank';
                            
                        }else{
                            error = true;
                            errorString = 'You can not generate the PDF since few attributes are blank';
                        }
                    }

                }
                else{
                
                }
            
            
            }
        }
         
        set<String> productName =  new set<String>();
        
        for (Chat_Products__c c: Chat_Products__c.getall().values()){
            
            if (c.ConversationProduct__c == false)
            productName.add(c.Product_Name__c);
        }
                
        for (invoiceit_crmx__Opportunity_Rate_Plan_Charge__c o:[select id, name, Recordtype.name,
                                                                      invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, 
                                                                      invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name, 
                                                                
                                                                     invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Family__c,
                                                                      invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Is_Chat_Option_Shown__c, 
                                                                      invoiceit_crmx__Opportunity__c, invoiceit_crmx__Opportunity__r.Name
                                                                      from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c 
                                                                      where invoiceit_crmx__Accounting_Code__c in :productName
                                                                            and invoiceit_crmx__Opportunity__c =:oppid
                                                                            and invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Is_Chat_Option_Shown__c = null]){
                                                                            
                
                listofOppProducts.add(new invoiceit_crmx__Opportunity_Product__c(id = o.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, 
                                                                                 name = o.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name, 
                                                                                 Is_Chat_Option_Shown__c = o.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Is_Chat_Option_Shown__c, 
                                                                                 invoiceit_crmx__Opportunity__c = o.invoiceit_crmx__Opportunity__c, invoiceit_crmx__Product_Family__c = o.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Family__c)) ;
            
               oppProductVsOppName.put(o.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, o.invoiceit_crmx__Opportunity__r.Name);
              } 
        
        if(!listofOppProducts.isempty()){
            for (invoiceit_crmx__Opportunity_Product__c o: listofOppProducts){
                system.debug('@@ Opportunity prod'+listofOppProducts);
                system.debug('@@ Opportunity Name'+o.invoiceit_crmx__Opportunity__r.Name);
                if(oppProductVsOppName.containsKey(o.id)){
                    String name = oppProductVsOppName.get(o.id);
                    if(!name.contains('Renew') && !name.contains('Evergreen') && !name.contains('Auto Evergreen') && !name.contains('Migration')){                   
                        error = true;
                        errorString = 'You can not generate the PDF since Chat options have not been selected.';                
                    } 
                }
                
            }
        }
        
        listofOrgOppProducts = [Select id,InventoryId__c,invoiceit_crmx__Product_Code__c, Name, IsInventoried__c,invoiceit_crmx__Product_Family__c
                                                       from invoiceit_crmx__Opportunity_Product__c
                                                         where invoiceit_crmx__Opportunity__c =:oppid];
        System.debug('@@@@@@@@@@@@@@listofOrgOppProducts '+listofOrgOppProducts );
        
        for(invoiceit_crmx__Opportunity_Product__c oppProd: listofOrgOppProducts){
            if(oppProd.IsInventoried__c == 'TRUE'){
                 listofInvOppProducts.add(oppProd);
            }
        }
        
        if(listofOrgOppProducts.isempty()){
            System.debug('===============@@@@@@@@@@@@listofOrgOppProducts'+listofOrgOppProducts);
            error = true;
            errorString = 'You can not genrate the PDF since no product has been added to the opportunity.';
        }
        
        if(!listofInvOppProducts.isempty()){
             System.debug('=================@@@@@@@@@@@@@@listofInvOppProducts'+listofInvOppProducts);
            for (invoiceit_crmx__Opportunity_Product__c oppProd: listofInvOppProducts){
                System.debug('Inside the for loop'+oppProd.InventoryId__c);
                if(oppProd.InventoryId__c == Null || oppProd.InventoryId__c == ''){
                    System.debug('@@@@@@@@Checking inventory');
                    error = true;
                    errorString = 'You can not generate the PDF since few Inventoried Products dont have Inventory Id.';
                }
            }
        }
        
        if(opport.StageName != '' || opport.StageName != Null){
            if(opport.StageName == 'Closed Won' || opport.StageName == 'QA Review'){
                error = true;
                errorString = 'You can not generate PDF since the opportuntiy is in QA Review or Closed Won Stage.';
            }
        }
        
        if((opport.Ngage_Source__c == '' || opport.Ngage_Source__c == Null) && opport.RecordType.Name == 'M-NG Opportunity'){
                error = true;
                errorString = 'You can not generate PDF since the Ngage Source field is not selected.';
        }
        
        
        if(opport.Lock_Record__c == True){
            error = true;
            errorString = 'You can not generate PDF since the opportuntiy is Locked.';
        }
        
        
        if(opport.Parent_Opportunity__c!=Null){
            error = true;
            errorString = 'You can not generate PDF since it is a child opportunity.';
        }
        
        if(opport.Auth_By_Contact_Email__c == Null || opport.Auth_By_Contact_Email__c == ''){
            error = true;
            errorString = 'Please fill the contact field - Auth By Contact with valid email address.';
        }
        
        if(opport.recordType.name =='M-H Opportunity'){
            for(invoiceit_crmx__Opportunity_Product__c icp : listofOrgOppProducts){
                if(icp.invoiceit_crmx__Product_Code__c =='01910'
                   || icp.invoiceit_crmx__Product_Code__c =='01912'){
                    if(ListInventoryIds.contains(icp.InventoryId__c)){
                        duplicateInvIds.add(icp.InventoryId__c);
                    } else{
                        ListInventoryIds.add(icp.InventoryId__c);
                    }  
                }
                
                System.debug('@@@@@@@@@duplicateInvIds------>'+duplicateInvIds);
                if(duplicateInvIds.size()>0){
                    error = true;
                    errorString = 'Please remove the duplicate Banner Placement from the opportunity.';
                }
            }
        }
        
        if(opport.recordType.name =='M-N Opportunity'){
            for(invoiceit_crmx__Opportunity_Product__c icp : listofOrgOppProducts){
                if(icp.invoiceit_crmx__Product_Family__c !='Nolo'){
                //if(icp.invoiceit_crmx__Product_Code__c !='40020' && icp.invoiceit_crmx__Product_Code__c !='40010'){
                    error = true;
                    errorString = 'You can not add Martindale Hubbell or Ngage Products for this Opportunity.'; 
                }
            }
        }
        
        else if(opport.recordType.name =='M-H Opportunity' || opport.recordType.name =='JV Opportunity'){
            for(invoiceit_crmx__Opportunity_Product__c icp : listofOrgOppProducts){
                if(icp.invoiceit_crmx__Product_Family__c =='Nolo' || icp.invoiceit_crmx__Product_Family__c =='Ngage' ){
               // if(icp.invoiceit_crmx__Product_Code__c =='40020' || icp.invoiceit_crmx__Product_Code__c =='40010' || icp.invoiceit_crmx__Product_Code__c =='60010' || icp.invoiceit_crmx__Product_Code__c =='60020'){
                    error = true;
                    errorString = 'You can not add Nolo or Ngage Products for this Opportunity.';
                }
            }
        }
        
        else{
            for(invoiceit_crmx__Opportunity_Product__c icp : listofOrgOppProducts){
                if(icp.invoiceit_crmx__Product_Family__c !='Ngage'){
                //if(icp.invoiceit_crmx__Product_Code__c !='60020' && icp.invoiceit_crmx__Product_Code__c !='60010'){
                    error = true;
                    errorString = 'You can not add Martindale Hubbell or Nolo Products for this Opportnity.';
                }
            }
        }
        
        listopportRPC = [Select id,RecordType.Name, invoiceit_crmx__Price_Type__c,invoiceit_crmx__Accounting_Code__c, name From invoiceit_crmx__Opportunity_Rate_Plan_Charge__c Where invoiceit_crmx__Opportunity__c=: oppid];
        
        if(!listopportRPC.isempty()){
            for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRPC : listopportRPC){
                if(oppRPC.invoiceit_crmx__Price_Type__c == 'Annual'){
                    error = true;
                    errorString = 'Please remove Annual products to generate the PDF.';
                }
                
                if(oppRPC.invoiceit_crmx__Accounting_Code__c == '12002'){
                    middleRepBoost = True;
                    repBoostSet.add(oppRPC.Id);
                }
                if(oppRPC.invoiceit_crmx__Accounting_Code__c == '12003'){
                    upperRepBoost = True;
                    repBoostSet.add(oppRPC.Id);
                }
                if(oppRPC.invoiceit_crmx__Accounting_Code__c == '12001'){
                    repBoostSet.add(oppRPC.Id);
                }
             } 
            System.debug('@@@@@middleRepBoost'+middleRepBoost);
            System.debug('@@@@@upperRepBoost'+upperRepBoost);
            
            System.debug('@@@@@@@@repBoostSet'+repBoostSet.size());
            
            if(repBoostSet.size()>1){
                error = true;
                errorString = 'Only one repuation boost is allowed on an opportunity.';
            }
            
            for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRPC2 : listopportRPC){
                System.debug('@@@@@@@oppRPC2.invoiceit_crmx__Accounting_Code__c'+oppRPC2.invoiceit_crmx__Accounting_Code__c);
                
                if(repBoostSet.size()==0 && (oppRPC2.invoiceit_crmx__Accounting_Code__c == '12011' || oppRPC2.invoiceit_crmx__Accounting_Code__c == '12012')){
                        error = true;
                        errorString = 'Repuation Boost Additional office is not in the same tier as Rep Boost product.';
                    
                }
                if(oppRPC2.invoiceit_crmx__Accounting_Code__c == '12011' && repBoostSet.size()!=0){
                    if(middleRepBoost == False){
                        error = true;
                        errorString = 'Repuation Boost Additional office is not in the same tier as Rep Boost product.';
                    }
                }
                
                if(oppRPC2.invoiceit_crmx__Accounting_Code__c == '12012' && repBoostSet.size()!=0){
                    if(upperRepBoost == False){
                        error = true;
                        errorString = 'Repuation Boost Additional office is not in the same tier as Rep Boost product.';
                    }
                }
            }
        }
        
        //Checking if the 
        System.debug('Record Tyep name'+opport.RecordType.Name);
        if(opport.RecordType.Name == 'M-NG Opportunity'){
            
            System.debug('Discount Percent'+opport.invoiceit_crmx__Discount_Percent__c);
            System.debug('Discount Approved or not'+opport.Discoint_Approved__c);
            System.debug('Stage Name'+opport.StageName);
            
            if((opport.invoiceit_crmx__Discount_Percent__c!=0 && opport.invoiceit_crmx__Discount_Percent__c!=NULL) && opport.Discoint_Approved__c!= 'Discount Approved' && opport.Discoint_Approved__c!='' && opport.StageName!='Closed Won' && opport.StageName!='Closed Lost' && opport.StageName!='Declined'){
                error = true;
                errorString = 'You cannot generate the PDF since the opportunity is not submitted for approval.';
            }
        }
        /*else if(opport.RecordType.Name == 'M-H Opportunity' || opport.RecordType.Name == 'JV Opportunity'){
            
            System.debug('Discount Percent'+opport.invoiceit_crmx__Discount_Percent__c);
            System.debug('Discount Approved or not'+opport.Discoint_Approved__c);
            System.debug('Stage Name'+opport.StageName);
            
            if((opport.invoiceit_crmx__Discount_Percent__c!=0 && opport.invoiceit_crmx__Discount_Percent__c>=20 && opport.invoiceit_crmx__Discount_Percent__c!=NULL) && opport.Discoint_Approved__c!= 'Discount Approved' && opport.Discoint_Approved__c!='' && opport.StageName!='Closed Won' && opport.StageName!='Closed Lost' && opport.StageName!='Declined'){
                error = true;
                errorString = 'You cannot generate the PDF since the opportunity is not submitted for approval.';
            }
        }
        */
        
        /*if(opport.Parent_Opportunity__c!=Null){
            upsellOpptyId = opport.Parent_Opportunity__r.Id;
        }*/
        
        
         
        if(error){
            System.debug('@@@@@@@@@@@errorString'+errorString);
            //return errorString;
            
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, +errorString);
            ApexPages.addMessage(msg);                                                                                                    
            return null;
        
        }
       
        else{
        
            pagereference Pg = Page.CreateQuoteApprovalPagePDF;
            pg.getParameters().put('id',oppid);
            System.debug('oppid'+oppid);
            Blob pdf1;
            if(!test.isRunningTest()){
                pdf1 = pg.getcontentAsPdf();
            }
             else{
                 pdf1 = blob.valueof('TEST');
             }
      
            attachment pdf = new attachment();        
            pdf.ParentId = oppid;
            System.debug('Checking if the attachment has id in it'+pdf.ParentId);
            pdf.Body = Pdf1;
            
        Opportunity oppty = [Select Id,Account_MH_Customer_No__c,RecordType.Name, Name From Opportunity Where id =: oppid];
            datetime tt=system.now();
            string ss=tt.format();
            ss = ss.replace('/','-');
            pdf.Name = oppty.Account_MH_Customer_No__c +'-ORD-'+ss+'.pdf';             
            pdf.ContentType = 'application/pdf';        
            insert pdf ;
            //return 'no Errors';
           // return null;
            // return new pageReference('/'+oppid);
             /*PageReference pageRef = new pageReference('/'+oppid);
             pageRef.setRedirect(false);
             return pageRef;*/
             //return new PageReference('javascript:window.close()');
             return new PageReference('javascript:window.opener.location.href='+'\'/'+oppid+'\';window.close();');
            
             // return null;
            }
            
        }
}