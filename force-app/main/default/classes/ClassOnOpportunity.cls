/* this class is for to check if any oppt attribute is missing then
 * It will not allow to convert into order
 */
global with sharing class ClassOnOpportunity {
    // if there is no attribute defined for Opportunity then Oppt can not be converted to Order
    // akash :07/03/2018 if parent opportunity present closed won should be done from parent
    // so bypassing child ngage opportunity and adding it to parent level
    map<id, opportunity> idvsnewopp;
    
    public void handlebeforeOnOpportunity (list<Opportunity> listOfOpportunity, map<Id,Opportunity> oldMap){
        List<opportunity> opptywihtqaAndwon = new list<opportunity>();
        list<Opportunity_Charge_Attribute__c> listOfOpptAttributes = new list<Opportunity_Charge_Attribute__c>();
        set<id> setOfOpptids = new set<id>();
        list<invoiceit_crmx__Opportunity_Product__c> listofOppProducts = new list<invoiceit_crmx__Opportunity_Product__c>();
        Map<id,String> oppProductVsOppName           = new Map<id,String>();
        Map<id, RecordType> rtObject = new Map<id, RecordType>();
        List<Opportunity> listOfChildOppts = new List<Opportunity>();
        
        list<Id> closedownIdsList = new List<Id>();
        Map<Id,opportunity> newMap = new Map<Id,opportunity>(listOfOpportunity);
        
        List<dsfs__DocuSign_Status__c> listOfDocuSignStatus = new List<dsfs__DocuSign_Status__c >();
        List<dsfs__DocuSign_Status__c> latestDocuSignRec = new List<dsfs__DocuSign_Status__c>();
        Map<id,dsfs__DocuSign_Status__c> opptyIdVSDocuSignRec = new Map<Id, dsfs__DocuSign_Status__c>();
        
        list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> listopportRPC = new list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        Boolean middleRepBoost = False;
        Boolean upperRepBoost = False;
        Set<id> repBoostSet = new Set<Id>();
        
        Set<String> ListInventoryIds = new Set<String>();
        Set<String> duplicateInvIds = new Set<String>(); 
        List<invoiceit_crmx__Opportunity_Product__c> listOfBannerPlacements = new List<invoiceit_crmx__Opportunity_Product__c>();
        
        for(Opportunity oppt : listOfOpportunity){
            system.debug('@@@opt name'+ oppt.Name);
            system.debug('@@@@ oppt stagename'+ oppt.StageName);
            //if(oppt.StageName != oldMap.get(oppt.Id).StageName && oppt.StageName == 'Closed Won') {
            if( ((oppt.StageName != oldMap.get(oppt.Id).StageName && oppt.StageName == 'QA Review')
                    || (oppt.StageName != oldMap.get(oppt.Id).StageName && oppt.StageName == 'Closed Won'))){
                    setOfOpptids.add(oppt.id);
                        /*System.debug('=======oppt.Child_Opportunities__r========'+oppt.Child_Opportunities__r);
                        System.debug('=========setOfOpptids1========'+setOfOpptids);
                        if(!oppt.Child_Opportunities__r.isempty()){
                            setOfOpptids.add(oppt.Child_Opportunities__r[0].id);
                        }
                        System.debug('=========setOfOpptids2========'+setOfOpptids);*/
                    opptywihtqaAndwon.add(oppt);
                } 
            if((oppt.StageName != oldMap.get(oppt.Id).StageName && oppt.StageName == 'Closed Won') || (oppt.StageName != oldMap.get(oppt.Id).StageName && oppt.StageName == 'QA Review')){
                if(oppt.Parent_Opportunity__c == NULL){
                     closedownIdsList.add(oppt.id);
                }
               
            }
            system.debug('@@@ setofopps' + closedownIdsList);
            
        }
        
      
        Map<Id,Id>parentOptyVsChild = new Map<Id,Id>();

        idvsnewopp = new map<id,opportunity>(opptywihtqaAndwon);
        set<String> productName =  new set<String>();
         for (Chat_Products__c c: Chat_Products__c.getall().values())
         {
            if (c.ConversationProduct__c == false)
                productName.add(c.Product_Name__c);
         }//by saiv start
         
          //Map<Id,Opportunity>parentIdVsChildopty = new Map<Id,Opportunity>();
         if(!closedownIdsList.isEmpty()){
             
             for(opportunity opp : [select id,Name,Parent_Opportunity__c
                                     
                                                       from Opportunity where 
                                                            Parent_Opportunity__c IN:closedownIdsList
                                                            AND Parent_Opportunity__c != NULL]){
                 
                 //as we have only child adding directly
                 parentOptyVsChild.put(opp.Parent_Opportunity__c, opp.id);
                
                 closedownIdsList.add(opp.id);
                 system.debug('=====closedownn:'+closedownIdsList);
                 
             }
             
            Map<Id,Opportunity> idVsOpportunity = new Map<Id,Opportunity>([select id,Stagename,recordType.name,Parent_Opportunity__c,Parent_Opportunity__r.Stagename,Auth_By_Contact__c,invoiceit_crmx__Billing_Contact__c,Marketing_Contact__c,
                                                                            Marketing_Contact__r.Email,invoiceit_crmx__Billing_Contact__r.Email,(select id,invoiceit_crmx__Product_Code__c, 
                                                                                 invoiceit_crmx__Product_Family__c,InventoryId__c  
                                                                                  from invoiceit_crmx__Opportunity_Products__r)  
                                                                            from Opportunity where id in:closedownIdsList]); 
             system.debug('=========idVsOpportunity======'+idVsOpportunity);
             
            for(Id opId : idVsOpportunity.keySet()){
                opportunity op = idVsOpportunity.get(opId);
                if(op.Parent_Opportunity__c != NULL){
                    
                    
                    
                    continue;
                }
                If(!parentOptyVsChild.isEmpty() &&  parentOptyVsChild.containsKey(opId)){
                    Opportunity childOpp = idVsOpportunity.get(parentOptyVsChild.get(opId));
                    if(childOpp.invoiceit_crmx__Opportunity_Products__r.size() == 0){
                         trigger.newMap.get(op.id).addError('You cannot QA Review or Closed Won this opportunity because child opporunity has no Products');
                    }
                    //added for MHBS-3345
                    system.debug('3345.........');
                    if((childOpp.Auth_By_Contact__c == Null || childOpp.invoiceit_crmx__Billing_Contact__c == Null || childOpp.Marketing_Contact__c == Null || childOpp.Marketing_Contact__r.Email == Null) && childOpp.StageName != 'Closed Lost'){
                         system.debug('3345.....2....');
                         trigger.newMap.get(op.id).addError('You cannot QA Review or Closed Won this opportunity because contacts/Email of Marketing Contact on child opporunity are missing');
                    }
                    //end
                    for(invoiceit_crmx__Opportunity_Product__c icp : childOpp.invoiceit_crmx__Opportunity_Products__r){
                        if(icp.invoiceit_crmx__Product_Family__c !='Ngage'){
                             trigger.newMap.get(op.id).addError('You cannot add Nolo or Martindale Hubbell Products for the Child Opportunity');
                        }
                    }
                    
                }
                
                if(op.recordType.name =='M-N Opportunity'){
                    for(invoiceit_crmx__Opportunity_Product__c icp : op.invoiceit_crmx__Opportunity_Products__r){
                        if(icp.invoiceit_crmx__Product_Family__c !='Nolo'){
                        //if(icp.invoiceit_crmx__Product_Code__c !='40020' && icp.invoiceit_crmx__Product_Code__c !='40010' ){
                            trigger.newMap.get(op.id).addError('You cannot add Martindale Hubbbell or Ngage Products for this Opportunity');
                        
                        }
                    }
                }
                else if(op.recordType.name =='M-H Opportunity' || op.recordType.name =='JV Opportunity'){
                     for(invoiceit_crmx__Opportunity_Product__c icp : op.invoiceit_crmx__Opportunity_Products__r){
                       // if(icp.invoiceit_crmx__Product_Code__c =='40020' || icp.invoiceit_crmx__Product_Code__c =='40010' || icp.invoiceit_crmx__Product_Code__c =='60010' || icp.invoiceit_crmx__Product_Code__c =='60020'){
                         if(icp.invoiceit_crmx__Product_Family__c =='Nolo' || icp.invoiceit_crmx__Product_Family__c =='Ngage' ){
                            trigger.newMap.get(op.id).addError('You cannot add Nolo or Ngage Products for this Opportunity');
                        }
                        
                        if(icp.invoiceit_crmx__Product_Code__c =='01910' || icp.invoiceit_crmx__Product_Code__c =='01912'){
                            if(ListInventoryIds.contains(icp.InventoryId__c)){
                                duplicateInvIds.add(icp.InventoryId__c);
                            } else{
                                ListInventoryIds.add(icp.InventoryId__c);
                            }  
                        }
                        //Commented by Ronak on 02/06/2020 as part of CPU time limit issue
                        //System.debug('@@@@@@@@@duplicateInvIds------>'+duplicateInvIds);
                        if(duplicateInvIds.size()>0){
                            trigger.newMap.get(op.id).addError('Please remove the duplicate Banner Placement from the opportunity.');
                        }
                    }
                }
                else{
                    for(invoiceit_crmx__Opportunity_Product__c icp : op.invoiceit_crmx__Opportunity_Products__r){
                        if(icp.invoiceit_crmx__Product_Family__c !='Ngage'){
                        //if(icp.invoiceit_crmx__Product_Code__c !='60020' && icp.invoiceit_crmx__Product_Code__c !='60010'
                        //      && icp.invoiceit_crmx__Product_Code__c !='01510'){
                            trigger.newMap.get(op.id).addError('You cannot add Nolo or Martindale Hubbell Products for this Opportunity');
                        
                        }
                    }
                }
            } //by saiv -end       
         
         }
        

        //query all attribute records of particular oppt. 
        if(!setOfOpptids.isEmpty() && setOfOpptids!=NULL) {
            
            listOfChildOppts = [SELECT id, name, Parent_Opportunity__c FROM Opportunity where Parent_Opportunity__c in:setOfOpptids];
            
            System.debug('========listOfChildOppts====='+listOfChildOppts);
            if(!listOfChildOppts.isEmpty()){
                for(Opportunity o : listOfChildOppts){
                    setOfOpptids.add(o.id);
                }
            }
            System.debug('=======newsetOfOpptids====='+setOfOpptids);
            
            
            listOfOpptAttributes = [SELECT Attribute_Order__c,Picklist_Value__c,Long_text_value__c,
                                    Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c,
                                    Attribute_Picklist_Values__c,Phone_Value__c, Name,
                                    Attribute_Name__c,Attribute_Type__c,Boolean_Value__c,Date_Value__c,Number_Value__c,Opportunity_Rate_Plan_Charge__c,String_Value__c,Required__c,Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c
                                    
                                    FROM Opportunity_Charge_Attribute__c
                                    WHERE Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c IN : setOfOpptids ];

        // Added By Ronak for DocuSign    
        // Validation to prevent user from marking the Oppty closed won or QA review when the latest DocuSign Status shows Declined
        
        listOfDocuSignStatus = [Select Id, Name, dsfs__Envelope_Status__c,dsfs__Opportunity__c, dsfs__Opportunity__r.StageName From dsfs__DocuSign_Status__c Where dsfs__Opportunity__c in: setOfOpptids Order By dsfs__Opportunity__c DESC, dsfs__Sent_Date_Time__c DESC];                        
        System.debug('Check what DocuSign records are avaulable listOfDocuSignStatus'+listOfDocuSignStatus);         
 
        id currentOppId;
        
        for(dsfs__DocuSign_Status__c docuSign : listOfDocuSignStatus ){
            
            if(docuSign.dsfs__Opportunity__c != currentOppId){
                currentOppId = docuSign.dsfs__Opportunity__c;
                latestDocuSignRec.add(docuSign);
                System.debug('===================Envelope Status================='+docuSign.dsfs__Envelope_Status__c);
                System.debug('===================Stage Name================='+docuSign.dsfs__Opportunity__r.StageName);
                if(docuSign.dsfs__Envelope_Status__c == 'Sent' || docuSign.dsfs__Envelope_Status__c == 'Delivered' || docuSign.dsfs__Envelope_Status__c == 'Declined'){
                    opptyIdVSDocuSignRec.put(docuSign.dsfs__Opportunity__c, docuSign);
                } 
                
            }
        }
        
        System.debug('===============currentOppId '+currentOppId );
        System.debug('===============latestDocuSignRec'+latestDocuSignRec);     
        System.debug('===============opptyIdVSDocuSignRec'+opptyIdVSDocuSignRec);
        
        String statusofopp = '';
        
        for(Opportunity opp : opptywihtqaAndwon){
            if(opptyIdVSDocuSignRec.containskey(opp.id)){
                if(idvsnewopp.containsKey(opp.Id)){
                    statusofopp = idvsnewopp.get(opp.Id).StageName;
                }
                trigger.newMap.get(opp.id).addError('You can not ' +statusofopp+ ' the opportunity since the DocuSign Status is not Completed.');

            }
        }
        // Ronak code end
        
        for (invoiceit_crmx__Opportunity_Rate_Plan_Charge__c o:[select id, name, 
                                                                      invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, 
                                                                      invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name, 
                                                                      invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Is_Chat_Option_Shown__c, 
                                                                      invoiceit_crmx__Opportunity__c, invoiceit_crmx__Opportunity__r.Name, invoiceit_crmx__Opportunity__r.recordtype.DeveloperName
                                                                      from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c 
                                                                      where invoiceit_crmx__Accounting_Code__c in :productName 
                                                                            and invoiceit_crmx__Opportunity__c in :setOfOpptids 
                                                                            and invoiceit_crmx__Opportunity__r.recordtype.DeveloperName != 'M_NG_Opportunity'
                                                                            and invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Is_Chat_Option_Shown__c = null]){
                                                                            
                
                listofOppProducts.add(new invoiceit_crmx__Opportunity_Product__c(id = o.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, 
                                                                                 name = o.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name, 
                                                                                 Is_Chat_Option_Shown__c = o.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Is_Chat_Option_Shown__c, 
                                                                                 invoiceit_crmx__Opportunity__c = o.invoiceit_crmx__Opportunity__c)) ;
            
               oppProductVsOppName.put(o.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, o.invoiceit_crmx__Opportunity__r.Name);
               rtObject.put(o.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, o.invoiceit_crmx__Opportunity__r.recordType); 
              } 
        }
        
        // Rep Boost Validations -- Added by Ronak
        if(!setOfOpptids.isEmpty()) {
            listopportRPC = [Select id, invoiceit_crmx__Price_Type__c,invoiceit_crmx__Opportunity__r.id,invoiceit_crmx__Accounting_Code__c, name From invoiceit_crmx__Opportunity_Rate_Plan_Charge__c Where invoiceit_crmx__Opportunity__c in: setOfOpptids];
        
            if(!listopportRPC.isempty()){
                for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRPC : listopportRPC){
                    
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
                    
                    if(repBoostSet.size()>1){
                        //error = true;
                        //errorString = 'Only one repuation boost is allowed on an opportunity.';
                        trigger.newMap.get(oppRPC.invoiceit_crmx__Opportunity__r.id).addError('Repuation Boost Additional office is not in the same tier as Rep Boost product.');

                    }
                 } 
                System.debug('@@@@@middleRepBoost'+middleRepBoost);
                System.debug('@@@@@upperRepBoost'+upperRepBoost);
                
                System.debug('@@@@@@@@repBoostSet'+repBoostSet.size());
                
                
                
                for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRPC2 : listopportRPC){
                    //Commented by Ronak on 02/06/2020 as part of CPU time limit issue
                    //System.debug('@@@@@@@oppRPC2.invoiceit_crmx__Accounting_Code__c'+oppRPC2.invoiceit_crmx__Accounting_Code__c);
                    
                    if(repBoostSet.size()==0 && (oppRPC2.invoiceit_crmx__Accounting_Code__c == '12011' || oppRPC2.invoiceit_crmx__Accounting_Code__c == '12012')){
                           // error = true;
                          //errorString = 'Repuation Boost Additional office is not in the same tier as Rep Boost product.';
                        
                        trigger.newMap.get(oppRPC2.invoiceit_crmx__Opportunity__r.id).addError('Repuation Boost Additional office is not in the same tier as Rep Boost product.');

                    }
                    if(oppRPC2.invoiceit_crmx__Accounting_Code__c == '12011' && repBoostSet.size()!=0){
                        if(middleRepBoost == False){
                            //error = true;
                          //errorString = 'Repuation Boost Additional office is not in the same tier as Rep Boost product.';
                            trigger.newMap.get(oppRPC2.invoiceit_crmx__Opportunity__r.id).addError('Repuation Boost Additional office is not in the same tier as Rep Boost product.');
                        }
                    }
                    
                    if(oppRPC2.invoiceit_crmx__Accounting_Code__c == '12012' && repBoostSet.size()!=0){
                        if(upperRepBoost == False){
                           // error = true;
                          //errorString = 'Repuation Boost Additional office is not in the same tier as Rep Boost product.';
                            trigger.newMap.get(oppRPC2.invoiceit_crmx__Opportunity__r.id).addError('Repuation Boost Additional office is not in the same tier as Rep Boost product.');
                        }
                    }
                }
            }
        }
        // Rep Boost Validation END ------------------------------------------------------

        checkIfMidTerm(opptywihtqaAndwon);

        list<Opportunity_Charge_Attribute__c> attributListnew = new list<Opportunity_Charge_Attribute__c>();    
        //checking each attribute filed which is empty          
        if(!listOfOpptAttributes.isEmpty()){
            
            for(Opportunity_Charge_Attribute__c attribute : listOfOpptAttributes){
                String statusofopp = '';
                String childStatusOfOpp= '';
                if(idvsnewopp.containsKey(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c)){                                      
                    statusofopp = idvsnewopp.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c).StageName;
                    
                }else if(idvsnewopp.containsKey(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c)){
                    statusofopp = idvsnewopp.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c).StageName;
                }
                
                if(attribute.Attribute_Type__c == 'Text'){
                    
                    if(attribute.String_Value__c == '' || attribute.String_Value__c == null){
                        if(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c==NULL){
                            trigger.newMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c).addError('You can not ' +statusofopp+ ' the opportunity since few attributes are blank');
                        }else{
                            system.debug('@@@@@attribut parent check'+ attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c);
                            opportunity opty = (Opportunity)trigger.newMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c);
                            if(opty == NULL ||
                                (opty!=NULL && opty.Parent_Stage_Change__c != oldMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c).Parent_Stage_Change__c)){
                                 trigger.newMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c).addError('You can not ' +statusofopp+ ' the opportunity since few attributes are blank on child Ngage opportunity'); 
                            }
                                                              
                        
                               
                           }
                    }

                }
                else if(attribute.Attribute_Type__c == 'Number'){

                    if(attribute.Number_Value__c == null){
                        if(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c==NULL){
                            trigger.newMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c).addError('You can not ' +statusofopp+ ' the opportunity since few attributes are blank');
                        }else{
                            opportunity opty = (Opportunity)trigger.newMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c);
                                if(opty == NULL ||
                                (opty!=NULL && opty.Parent_Stage_Change__c != oldMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c).Parent_Stage_Change__c)){
                                  
                                    trigger.newMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c).addError('You can not ' +statusofopp+ ' the opportunity since few attributes are blank on child Ngage opportunity');                            
                                }
                                }
                    }

                }

                else if(attribute.Attribute_Type__c == 'Boolean'){

                    if(attribute.Boolean_Value__c != true){
                        if(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c==NULL){
                            trigger.newMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c).addError('You can not ' +statusofopp+ ' the opportunity since few attributes are blank');
                        }else{
                            opportunity opty = (Opportunity)trigger.newMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c);
                                if(opty == NULL ||
                                (opty!=NULL && opty.Parent_Stage_Change__c != oldMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c).Parent_Stage_Change__c)){
                                  
                                    trigger.newMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c).addError('You can not ' +statusofopp+ ' the opportunity since few attributes are blank on child Ngage opportunity');                            
                                }
                              }
                    }

                }
                else if(attribute.Attribute_Type__c == 'Picklist' && (attribute.Attribute_Name__c != 'State' && attribute.Attribute_Name__c != 'Service State' && attribute.Attribute_Name__c != 'Xref State' && attribute.Attribute_Name__c != 'Xref City'&& attribute.Attribute_Name__c != 'City' && attribute.Attribute_Name__c != 'Xref County')){

                    if(attribute.Picklist_Value__c == '' || attribute.Picklist_Value__c == null){
                        if(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c==NULL){
                            trigger.newMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c).addError('You can not ' +statusofopp+ ' the opportunity since few attributes are blank');
                        }else{
                            system.debug('@@@opty id'+ attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c);
                             opportunity opty = newMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c);
                            
                            if(opty == NULL ||
                                (opty!=NULL && opty.Parent_Stage_Change__c != oldMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c).Parent_Stage_Change__c)){
                                    trigger.newMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c).addError('You can not ' +statusofopp+ ' the opportunity since few attributes are blank on child Ngage opportunity');                            
                                }
                            }
                    }

                }
                else if(attribute.Attribute_Type__c == 'Date'){

                    if(attribute.Date_Value__c == null){
                        if(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c==NULL){
                            trigger.newMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c).addError('You can not ' +statusofopp+ ' the opportunity since few attributes are blank');
                        }else{
                            opportunity opty = (Opportunity)trigger.newMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c);
                                if(opty.Parent_Stage_Change__c != oldMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c).Parent_Stage_Change__c){
                                  
                                    trigger.newMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c).addError('You can not ' +statusofopp+ ' the opportunity since few attributes are blank on child Ngage opportunity');                            
                                }
                         }
                    }

                }
                else if(attribute.Attribute_Type__c == 'Phone'){

                    if(attribute.Phone_Value__c == null){
                        if(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c==NULL){
                            trigger.newMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c).addError('You can not ' +statusofopp+ ' the opportunity since few attributes are blank');
                        }else{
                            opportunity opty = (Opportunity)trigger.newMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c);
                                if(opty.Parent_Stage_Change__c != oldMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c).Parent_Stage_Change__c){
                                  
                                    trigger.newMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c).addError('You can not ' +statusofopp+ ' the opportunity since few attributes are blank on child Ngage opportunity');                            
                        
                                  }
                            }
                    }

                }
                else if(attribute.Attribute_Type__c == 'Text Area'){
                    
                    if(attribute.Long_text_value__c == '' || attribute.Long_text_value__c == null){
                        if(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c==NULL){
                            trigger.newMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c).addError('You can not ' +statusofopp+ ' the opportunity since few attributes are blank');
                        }else{
                            system.debug('@@@@@attribut parent check'+ attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c);
                            opportunity opty = (Opportunity)trigger.newMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c);
                            if(opty == NULL ||
                                (opty!=NULL && opty.Parent_Stage_Change__c != oldMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c).Parent_Stage_Change__c)){
                                 trigger.newMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c).addError('You can not ' +statusofopp+ ' the opportunity since few attributes are blank on child Ngage opportunity'); 
                            }
                                                              
                        
                               
                           }
                    }

                }
                else if(attribute.Attribute_Type__c == 'URL'){
                    
                    if(attribute.String_Value__c == '' || attribute.String_Value__c == null){
                        if(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c==NULL){
                            trigger.newMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c).addError('You can not ' +statusofopp+ ' the opportunity since few attributes are blank');
                        }else{
                            system.debug('@@@@@attribut parent check'+ attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c);
                            opportunity opty = (Opportunity)trigger.newMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c);
                            if(opty == NULL ||
                                (opty!=NULL && opty.Parent_Stage_Change__c != oldMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c).Parent_Stage_Change__c)){
                                 trigger.newMap.get(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c).addError('You can not ' +statusofopp+ ' the opportunity since few attributes are blank on child Ngage opportunity'); 
                            }
                                                              
                        
                               
                           }
                    }

                }
                else{

                }
            }

        }       

//Added by Rama 05/07/16 the below if condition for checking if chat was shown
        if(!listofOppProducts.isempty())
        {
            for (invoiceit_crmx__Opportunity_Product__c o: listofOppProducts)
   
            {
                system.debug('@@ Opportunity prod'+listofOppProducts);
                system.debug('@@ Opportunity Name'+o.invoiceit_crmx__Opportunity__r.Name);
                if(oppProductVsOppName.containsKey(o.id)){
                    String name = oppProductVsOppName.get(o.id);
                    RecordType recordtype = rtObject.get(o.id);
                    system.debug('@@ Opportunity recordtype '+recordtype ); 
                    if(!name.contains('Renew') && !name.contains('Evergreen') && !name.contains('Auto Evergreen') && !name.contains('Migration')){                   
                        String statusofopp = '';
                        if(idvsnewopp.containsKey(o.invoiceit_crmx__Opportunity__c)){
                            statusofopp = idvsnewopp.get(o.invoiceit_crmx__Opportunity__c).StageName;
                        }
                        trigger.newMap.get(o.invoiceit_crmx__Opportunity__c).addError('You can not ' +statusofopp+ ' the opportunity since Chat options have not been selected');             
           
                    
                    } 
                }
                
            }
        }

    }
    //added by sai ravulapati - start
    public static void createContactRole(List<Opportunity> opplist){
        List<OpportunityContactRole> opContactRoleList = new List<OpportunityContactRole>();
        for(Opportunity opp : opplist){
            if(Opp.Auth_By_Contact__c != null){
                OpportunityContactRole opConRole= new OpportunityContactRole(ContactId=opp.Auth_By_Contact__c,OpportunityId=opp.Id,Role='Decision Maker',IsPrimary=true);
                opContactRoleList.add(opConRole);
            }

        }
        try{
            insert opContactRoleList;
        }catch(exception e){
            system.debug('@@@exception '+e);
        }
    }
    
    
     public static void updateContactRole(List<Opportunity> opplist, Map<id,Opportunity> oldOppMap){
        List<OpportunityContactRole> opContactRoleList = new List<OpportunityContactRole>();
        for(Opportunity opp : opplist){
            if(Opp.Auth_By_Contact__c != null && oldOppMap.get(Opp.id).Auth_By_Contact__c != Opp.Auth_By_Contact__c){
                OpportunityContactRole opConRole= new OpportunityContactRole(ContactId=opp.Auth_By_Contact__c,OpportunityId=opp.Id,Role='Decision Maker',IsPrimary=true);
                opContactRoleList.add(opConRole);
            }

        }
        try{
            if(!opContactRoleList.isEmpty()){
                insert opContactRoleList;
            }
        }catch(exception e){
            system.debug('@@@exception '+e);
        }
    } 
    // MHBS-3455 - Ronak Jain
    // Deleting the chat and MH product relationship on opportunity closed lost
    public static void deleteJuncOnOpptyClosedLost(List<Opportunity> opplist, map<id, opportunity> newmap, map<id, opportunity> oldmap){
        
        system.debug('@@@@ in deleteJuncOnOpptyClosedLost');
        
        Set<Id> closedLostOpptyIds = new Set<Id>();
        List<Chat_Product_Opportunity_Charge__c> deleteJunctionList = new List<Chat_Product_Opportunity_Charge__c>();
        
        Id RecordTypeId_ngageOppty = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-NG Opportunity').getRecordTypeId(); 
        
        System.debug('Ngage Record Type Name------->'+RecordTypeId_ngageOppty );
        
        for(Opportunity o: opplist){
            System.debug('@@@@@@Record Type Name------->'+o.recordtypeId);
            System.debug('Stage Name------->'+newmap.get(o.id).stageName);
            System.debug('@Nageg Upsell Order Id ---------->'+o.Ngage_Upsell_Order__c);
            
            if(newmap.get(o.id).stageName != oldmap.get(o.id).stageName && newmap.get(o.id).stageName == 'Closed Lost' && (o.Ngage_Upsell_Order__c!=NULL || o.Parent_Opportunity__c!=NULL) && o.RecordtypeId == RecordTypeId_ngageOppty ){
                System.debug('@@@@Testiong----'+newmap.get(o.id).stageName);
                closedLostOpptyIds.add(o.id);
            }
        }
        System.debug('@@@@@@@Closed Lost Oppty Ids----->'+closedLostOpptyIds);
        
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> oppRPCList = [Select Id, name,(Select id, name From Chat_Product_Opportunity_Charges1__r) From invoiceit_crmx__Opportunity_Rate_Plan_Charge__c Where invoiceit_crmx__Opportunity__c in : closedLostOpptyIds];
        
        //for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opp: oppRPCList )
        if(!oppRPCList.isempty()){
            System.debug('Junction obejct list-0------------>'+oppRPCList[0].Chat_Product_Opportunity_Charges1__r);
        
            for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRPC: oppRPCList ){
                
                if(!oppRPC.Chat_Product_Opportunity_Charges1__r.isempty()){
                    for(Chat_Product_Opportunity_Charge__c chatProdCharge: oppRPC.Chat_Product_Opportunity_Charges1__r){
                        deleteJunctionList.add(chatProdCharge); 
                    }
                }
            }
        }
        System.debug('@@@@@deleteJunctionList--------------->'+deleteJunctionList);
        if(!deleteJunctionList.isempty()){
            delete deleteJunctionList;
        }
        
    }
    
    
    //added by sai ravulapati - end
    //method for settig prospect status on account based on opportunity stage
    public static void automateProspectonAccount(List<Opportunity> opplist, map<id, opportunity> newmap, map<id, opportunity> oldmap){
        
        system.debug('@@@@ in automateProspectonAccount');
        
        set<Id> accids = new set<Id>();
        list<account> acclist = new list<account>();
        
        //creating list of of account Ids
        for(opportunity opp : opplist){
            if(trigger.isInsert || (trigger.isUpdate && newmap.get(opp.id).RecordType.DeveloperName != 'M_A_Opportunity' && (newmap.get(opp.id).stageName != oldmap.get(opp.id).stageName))){
                system.debug('@@@@ in ids condition');
                 accids.add(opp.AccountId);
            }
                
        }
        
        system.debug('@@@accids'+accids);
        //querying on account for orders and opportunity
        acclist = [select id, Name, Customer_Status__c,
                           (select id, Name 
                               from invoiceit_s__Job__r),
                            (select id, Name, stageName 
                               from opportunities 
                               where stageName != 'Closed Lost')
                           from account where Id IN:(accids)];
        
        system.debug('@@@@acclist'+ acclist);
       
        for(account acc: acclist){
             system.debug('@@@accl.opportunities'+ acc.opportunities);
            //checking that there are no orders in account
            if(acc.invoiceit_s__Job__r.size() == 0){
                //checking that there are opportunities other than closed lost stage
                if(acc.opportunities.size() > 0){
                    acc.Customer_Status__c = 'PROSPECT';
                }
                else{
                    acc.Customer_Status__c = '';
                }
            }
        }
        
        try{
            update acclist;
        }
        catch(exception e){
            system.debug('@@@exception '+e);
        }
    }

    public void createPaymentMethod(List<Opportunity> opplist, map<id, opportunity> newmap, map<id, opportunity> oldmap){
        
        set<Id> accids = new set<Id>();
        list<account> acclist = new list<account>();
        set<id> oppId = new set<Id>();
        List<Opportunity> newOpptyList = new List<Opportunity>();
        List<Opportunity> parentNChildOppty = new List<Opportunity>();
        Map<String,String> parentOppCardNoMap = new Map<String,String>();
        Map<String,String> parentOppNameOnCardMap = new Map<String,String>();
        Map<String,String> parentOppCardTypeMap = new Map<String,String>();
        Map<String,String> parentOppCardExpMnthMap = new Map<String,String>();
        Map<String,String> parentOppCardExpYrMap = new Map<String,String>();
        Map<String,String> parentOppCVVMap = new Map<String,String>();
        
        //creating list of of account Ids
        
        for(opportunity opp : opplist){
            if( opp.Name_on_Card__c!= Null && opp.Card_Number__c!= NULL && (newmap.get(opp.id).Card_Number__c != oldmap.get(opp.id).Card_Number__c)){
                accids.add(opp.AccountId);
                acclist.add(opp.Account);
                oppId.add(opp.id);
                parentNChildOppty.add(opp);
                parentOppCardNoMap.put(opp.ID,opp.Card_Number__c);
                parentOppNameOnCardMap.put(opp.ID,opp.Name_on_Card__c);
                parentOppCardTypeMap.put(opp.ID,opp.card_Type__c);
                parentOppCardExpMnthMap.put(opp.ID,opp.Card_Expiration_Month__c);
                parentOppCardExpYrMap.put(opp.ID,opp.Card_Expiration_Year__c);
                parentOppCVVMap.put(opp.ID,opp.CVV__c);
                
            }        
        }
            
        System.debug('=========parentOppCardNoMap====='+parentOppCardNoMap);
        
        if(!oppId.isempty()){
            List<Opportunity> childOpptyList = [Select id,name,Parent_Opportunity__c,Account_Id__c,Parent_Opportunity__r.Card_Number__c, 
                                                Parent_Opportunity__r.Name_on_Card__c, Parent_Opportunity__r.card_Type__c,Parent_Opportunity__r.OwnerId,
                                                Parent_Opportunity__r.Card_Expiration_Month__c,Parent_Opportunity__r.Card_Expiration_Year__c, Parent_Opportunity__r.CVV__c,
                                                Parent_Opportunity__r.Street_Address__c,Parent_Opportunity__r.City__c,Parent_Opportunity__r.Country__c,Parent_Opportunity__r.State__c,
                                                Parent_Opportunity__r.Zip_Postal_Code__c,Parent_Opportunity__r.Payment_Method_Default__c,
                                                Street_Address__c, City__c, Country__c, State__c, Zip_Postal_Code__c, Card_Number__c,
                                                Name_on_Card__c,card_Type__c,Card_Expiration_Month__c, Card_Expiration_Year__c,
                                                Upsell_Oppty_Account_Id__c,DocuSign_Quote_Approved__c,Payment_Method_Default__c
                                                from Opportunity where Parent_Opportunity__c in:oppId]; 
   
                if(!childOpptyList.isempty()){
                    parentNChildOppty.addAll(childOpptyList);
                }
        }
        
        
        Map<String,Account> mapOfOpptyVsAcc = new Map<String,Account>();
        Map<String, invoiceit_s__Payment_Method__c> mapOfAccountVsPM = new Map<String, invoiceit_s__Payment_Method__c>();
        
        for(invoiceit_s__Payment_Method__c p : [Select id,invoiceit_s__Account__r.Id, name,invoiceit_s__Card_Number__c,Created_By_DocuSign__c,
                                                invoiceit_s__Name_on_Card__c,invoiceit_s__Card_Type__c,invoiceit_s__Card_Expiration_Month__c,
                                                invoiceit_s__Card_Expiration_Year__c,invoiceit_s__CVV__c,invoiceit_s__Billing_Address__c,
                                                invoiceit_s__Billing_City__c, invoiceit_s__Billing_Country__c,
                                                invoiceit_s__Billing_State_Province__c,invoiceit_s__Billing_Zip_Postal__c 
                                                from invoiceit_s__Payment_Method__c Where invoiceit_s__Active__c=True 
                                                AND invoiceit_s__Default__c=True ]){
                                                    
            mapOfAccountVsPM.put(p.invoiceit_s__Account__r.Id, p);
        }
        System.debug('==========mapOfAccountVsPM'+mapOfAccountVsPM);
  
       List<invoiceit_s__Payment_Method__c> createPM = new List<invoiceit_s__Payment_Method__c>();
        System.debug('==============================opplist'+opplist);
        System.debug('==============parentNChildOppty================'+parentNChildOppty);

        for(opportunity o : parentNChildOppty){


            //mapOfOpptyVsAcc.put(o.Id,o.Account);
            System.debug('===========o.Payment_Method_Default__c========'+o.Payment_Method_Default__c);
            System.debug('===========o.Parent_Opportunity__c========'+o.Parent_Opportunity__c);
            if(o.Payment_Method_Default__c == False && o.Parent_Opportunity__c == Null){
                //if( o.Name_on_Card__c!= Null && o.Card_Number__c!= NULL && (newmap.get(o.id).Card_Number__c != oldmap.get(o.id).Card_Number__c)){
                    System.debug('============================'+o.Account_Id__c); 
                    invoiceit_s__Payment_Method__c paymntmtd = new invoiceit_s__Payment_Method__c();
                    paymntmtd.invoiceit_s__Active__c = True;
                    
                    if(o.AutoPay__c == 'Yes'){
                        paymntmtd.invoiceit_s__Default__c = True;

                    }else{
                        paymntmtd.invoiceit_s__Default__c = False;

                    }
                    paymntmtd.invoiceit_s__Account__c = o.Account_Id__c;
                    paymntmtd.invoiceit_s__Card_Number__c = o.Card_Number__c;
                    paymntmtd.invoiceit_s__Name_on_Card__c = o.Name_on_Card__c;
                    paymntmtd.invoiceit_s__Card_Type__c = o.card_Type__c;
                    paymntmtd.invoiceit_s__Card_Expiration_Month__c = o.Card_Expiration_Month__c;
                    paymntmtd.invoiceit_s__Card_Expiration_Year__c = o.Card_Expiration_Year__c;
                    paymntmtd.invoiceit_s__CVV__c = o.CVV__c;
                    paymntmtd.invoiceit_s__Billing_Address__c = o.Street_Address__c;
                    paymntmtd.invoiceit_s__Billing_City__c = o.City__c;
                    paymntmtd.invoiceit_s__Billing_Country__c = o.Country__c;
                    paymntmtd.invoiceit_s__Billing_State_Province__c = o.State__c;
                    paymntmtd.invoiceit_s__Billing_Zip_Postal__c = o.Zip_Postal_Code__c;
                    paymntmtd.Created_By_DocuSign__c = o.OwnerId;
                    createPM.add(paymntmtd);
                    
                //}

                
            }else if(o.Payment_Method_Default__c == False && o.Parent_Opportunity__c != Null && o.Upsell_Oppty_Account_Id__c!=Null){
                    System.debug('============Child Opportunity Id============'+o.Id);
               // if(o.Name_on_Card__c!= Null && o.Card_Number__c!= NULL && (newmap.get(o.id).Card_Number__c != oldmap.get(o.id).Card_Number__c) ){
                    System.debug('===========inside child Ngage oppty - Parent Oppty============'+o.Parent_Opportunity__c);
                    System.debug('===========o.Parent_Opportunity__r.Card_Number__c============'+o.Parent_Opportunity__r.Card_Number__c);
                    System.debug('===========o.Parent_Opportunity__r.Name_on_Card__c============'+o.Parent_Opportunity__r.Name_on_Card__c);
                    System.debug('===========o.Parent_Opportunity__r.card_Type__c============'+o.Parent_Opportunity__r.card_Type__c);
                    System.debug('===========o.Parent_Opportunity__r.Card_Expiration_Month__c============'+o.Parent_Opportunity__r.Card_Expiration_Month__c);
                    System.debug('===========o.Street_Address__c============'+o.Street_Address__c);
                    System.debug('===========o.ParentStreet_Address__c==========='+o.Parent_Opportunity__r.Street_Address__c);
                    System.debug('==========o.Parent_Opportunity__r.CVV__c============'+o.Parent_Opportunity__r.CVV__c);
                    
                    invoiceit_s__Payment_Method__c paymntmtd4 = new invoiceit_s__Payment_Method__c();
                    paymntmtd4.invoiceit_s__Active__c = True;
                    paymntmtd4.invoiceit_s__Default__c = True;
                    paymntmtd4.invoiceit_s__Account__c = o.Account_Id__c;
                    System.debug('========parentOppCardNoMap=========='+parentOppCardNoMap.containskey(o.Parent_Opportunity__c));
                
                    if(parentOppCardNoMap.containskey(o.Parent_Opportunity__c)) {
                        paymntmtd4.invoiceit_s__Card_Number__c = parentOppCardNoMap.get(o.Parent_Opportunity__c);
                    }
                    if(parentOppNameOnCardMap.containskey(o.Parent_Opportunity__c)) {
                        paymntmtd4.invoiceit_s__Name_on_Card__c = parentOppNameOnCardMap.get(o.Parent_Opportunity__c);
                    }
                    if(parentOppCardTypeMap.containskey(o.Parent_Opportunity__c))   {
                        paymntmtd4.invoiceit_s__Card_Type__c = parentOppCardTypeMap.get(o.Parent_Opportunity__c);
                    }
                    if(parentOppCardExpMnthMap.containskey(o.Parent_Opportunity__c))    {
                        paymntmtd4.invoiceit_s__Card_Expiration_Month__c = parentOppCardExpMnthMap.get(o.Parent_Opportunity__c);
                    }
                    if(parentOppCardExpYrMap.containskey(o.Parent_Opportunity__c))  {
                        paymntmtd4.invoiceit_s__Card_Expiration_Year__c = parentOppCardExpYrMap.get(o.Parent_Opportunity__c);
                    }
                    if(parentOppCVVMap.containskey(o.Parent_Opportunity__c))    {
                        paymntmtd4.invoiceit_s__CVV__c = parentOppCVVMap.get(o.Parent_Opportunity__c);
                    }
           
                    System.debug('=======paymntmtd4.invoiceit_s__Card_Number__c====='+paymntmtd4.invoiceit_s__Card_Number__c);
                   
                    paymntmtd4.invoiceit_s__Billing_Address__c = o.Parent_Opportunity__r.Street_Address__c;
                    paymntmtd4.invoiceit_s__Billing_City__c = o.Parent_Opportunity__r.City__c;
                    paymntmtd4.invoiceit_s__Billing_Country__c = o.Parent_Opportunity__r.Country__c;
                    paymntmtd4.invoiceit_s__Billing_State_Province__c = o.Parent_Opportunity__r.State__c;
                    paymntmtd4.invoiceit_s__Billing_Zip_Postal__c = o.Parent_Opportunity__r.Zip_Postal_Code__c;
                    paymntmtd4.Created_By_DocuSign__c = o.Parent_Opportunity__r.OwnerId;
                    createPM.add(paymntmtd4);
                           
            }
            
            }
        
        System.debug('createPM'+createPM);
            if(!createPM.isEmpty()){
                insert createPM;   
                }  
    }    

    public void copyPMFromParent(List<Opportunity> opplist, map<id, opportunity> newmap, map<id, opportunity> oldmap){
        
        //Child Opportunity Ids
        //Parent Account Ids to get the Payment Methods
        Set<Id> parentAccIds = new Set<Id>();
        Set<Id> parentOpptyIds = new Set<Id>();
        Set<Id> ngageOpptyIds = new Set<Id>();
        List<Opportunity> ngageOpptyList = new List<Opportunity>();
        
        List<Opportunity> childOpptyList = new List<Opportunity>();
        List<Opportunity> parentOppty = new List<Opportunity>();
        List<Account> parentAcc = new List<Account>();
        List<invoiceit_s__Payment_Method__c> pmList = new List<invoiceit_s__Payment_Method__c>();
        Map<String, String> accIdNnameOnCardMap = new Map<String, String>();
        Map<String, String> accIdNcardNoMap = new Map<String, String>();
        Map<String, String> accIdNexpMonthMap = new Map<String, String>();
        Map<String, String> accIdNexpYrMap = new Map<String, String>();
        Map<String, String> accIdNcardTypeMap = new Map<String, String>();
        Map<String, String> accIdNcvvMap = new Map<String, String>();
        Map<String, String> accIdNbillingAddMap = new Map<String, String>();
        Map<String, String> accIdNbillingCityMap = new Map<String, String>();
        Map<String, String> accIdNbillingStateMap = new Map<String, String>();
        Map<String, String> accIdNbillingZipMap = new Map<String, String>();
        Map<String, String> accIdNbillingCountryMap = new Map<String, String>();
        
        
        
        List<invoiceit_s__Payment_Method__c> createPM = new List<invoiceit_s__Payment_Method__c>();
        
        Map<String, String> parentOpptyNChildOpptyMap = new Map<String, String>();
        
        System.debug('@@@@@@opplist'+opplist);
        
        for(Opportunity o: opplist){
            if(o.Payment_Method_Default__c == True && o.Parent_Opportunity__c == Null && /*o.DocuSign_Quote_Approved__c == True*/ oldmap.get(o.id).StageName != o.StageName && o.StageName == 'QA Review'){
                parentOpptyIds.add(o.Id);
                parentAccIds.add(o.AccountId);
                parentOppty.add(o);
                parentAcc.add(o.Account);
            }else if(o.Payment_Method_Default__c == False && o.Ngage_Upsell_Order__c!= Null && oldmap.get(o.id).StageName != o.StageName && o.StageName == 'QA Review'){
                ngageOpptyIds.add(o.Id);
            }
        }
        System.debug('@@@@parentOpptyIds'+parentOpptyIds);
        System.debug('@@@@@parentAccIds'+parentAccIds);
        System.debug('@@@@@ngageOpptyIds'+ngageOpptyIds);

        if(!parentOpptyIds.isempty()){
            childOpptyList = [Select id, name,OwnerId,Parent_Opportunity__c,Parent_Opportunity__r.OwnerId,Account_Id__c,Parent_Opportunity__r.AccountId,Payment_Method_Default__c from Opportunity Where Parent_Opportunity__c in:parentOpptyIds AND Payment_Method_Default__c=False];
            System.debug('@@@@@@@@childOpptyList'+childOpptyList);
            if(!childOpptyList.isempty()){
                for(Opportunity chilopp: childOpptyList){
                    parentOpptyNChildOpptyMap.put(chilopp.Parent_Opportunity__c, chilopp.id);
                }
            }
        }
        
        if(!ngageOpptyIds.isempty()){
            ngageOpptyList = [Select id, name,Ngage_Upsell_Order__c,OwnerId,Account.Id,Account_Id__c,Ngage_Upsell_Order__r.invoiceit_s__Account__r.invoiceit_s__Gateway__c,Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id, Payment_Method_Default__c from Opportunity Where id in: ngageOpptyIds AND Ngage_Upsell_Order__r.invoiceit_s__Account__r.invoiceit_s__Gateway__c !=Null];
            System.debug('@@@@@@@@ngageOpptyList '+ngageOpptyList );
            
            for(Opportunity o: ngageOpptyList ){
                parentAccIds.add(o.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id);
                
            }
        }
        
        
        System.debug('@@@@@parentOpptyNChildOpptyMap'+parentOpptyNChildOpptyMap);
        
        if((!childOpptyList.isempty() || !ngageOpptyList .isempty()) && !parentAccIds.isempty()){
            pmList = [Select id, name,invoiceit_s__Account__c,invoiceit_s__Default__c,invoiceit_s__Name_on_Card__c,invoiceit_s__Billing_Address__c,Created_By_DocuSign__c,
                      invoiceit_s__Billing_City__c, invoiceit_s__Billing_State_Province__c,invoiceit_s__Billing_Zip_Postal__c,invoiceit_s__Billing_Country__c,
                      invoiceit_s__Card_Number__c,invoiceit_s__Card_Expiration_Month__c,invoiceit_s__Card_Expiration_Year__c,
                      invoiceit_s__Card_Type__c,invoiceit_s__CVV__c
                      From invoiceit_s__Payment_Method__c Where invoiceit_s__Account__c in: parentAccIds AND invoiceit_s__Default__c= True];
            
            System.debug('@@@@pmList'+pmList);
            
            for(invoiceit_s__Payment_Method__c p: pmList){
                accIdNnameOnCardMap.put(p.invoiceit_s__Account__c, p.invoiceit_s__Name_on_Card__c);
                accIdNcardNoMap.put(p.invoiceit_s__Account__c, p.invoiceit_s__Card_Number__c);
                accIdNexpMonthMap.put(p.invoiceit_s__Account__c, p.invoiceit_s__Card_Expiration_Month__c);
                accIdNexpYrMap.put(p.invoiceit_s__Account__c, p.invoiceit_s__Card_Expiration_Year__c);
                accIdNcardTypeMap.put(p.invoiceit_s__Account__c, p.invoiceit_s__Card_Number__c);
                accIdNcvvMap.put(p.invoiceit_s__Account__c, p.invoiceit_s__CVV__c);
                accIdNbillingAddMap.put(p.invoiceit_s__Account__c, p.invoiceit_s__Billing_Address__c);
                accIdNbillingCityMap.put(p.invoiceit_s__Account__c, p.invoiceit_s__Billing_City__c);
                accIdNbillingStateMap.put(p.invoiceit_s__Account__c, p.invoiceit_s__Billing_State_Province__c);
                accIdNbillingZipMap.put(p.invoiceit_s__Account__c, p.invoiceit_s__Billing_Zip_Postal__c);
                accIdNbillingCountryMap.put(p.invoiceit_s__Account__c, p.invoiceit_s__Billing_Country__c);  
            }
        }
        System.debug('@@@@@accIdNnameOnCardMap'+accIdNnameOnCardMap);
        System.debug('@@@@@accIdNcardNoMap'+accIdNcardNoMap);
        System.debug('@@@@@accIdNexpMonthMap'+accIdNexpMonthMap);
        System.debug('@@@@@accIdNexpYrMap'+accIdNexpYrMap);
        System.debug('@@@@@accIdNcardTypeMap'+accIdNcardTypeMap);
        System.debug('@@@@@accIdNcvvMap'+accIdNcvvMap);
        
        if(!ngageOpptyList .isempty()){
            for(Opportunity ngageco: ngageOpptyList ){
                System.debug('@@@@@@@Check 1st condition'+ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id);
                System.debug('@@@@@@@@@@@@@Check the 2nd condition true or not'+accIdNnameOnCardMap.containskey(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id));
                //System.debug('@@@@@@Check the 3rd '+accIdNnameOnCardMap.containskey(ngageco.Parent_Opportunity__r.AccountId));
                
                if(parentAccIds!=Null){
                    invoiceit_s__Payment_Method__c paymntmtd1 = new invoiceit_s__Payment_Method__c();
                    paymntmtd1.invoiceit_s__Active__c = True;
                    paymntmtd1.invoiceit_s__Default__c = True;
                    paymntmtd1.Created_By_DocuSign__c = ngageco.OwnerId;
                    
                    if(accIdNnameOnCardMap.containskey(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id)){
                        paymntmtd1.invoiceit_s__Name_on_Card__c = accIdNnameOnCardMap.get(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id);
                    }
                    
                    if(accIdNcardNoMap.containskey(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id)){
                        paymntmtd1.invoiceit_s__Card_Number__c = accIdNcardNoMap.get(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id);
                    }
                
                    if(accIdNexpMonthMap.containskey(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id)){
                        paymntmtd1.invoiceit_s__Card_Expiration_Month__c = accIdNexpMonthMap.get(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id);
                    }
                
                    if(accIdNexpYrMap.containskey(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id)){
                        paymntmtd1.invoiceit_s__Card_Expiration_Year__c = accIdNexpYrMap.get(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id);
                    }
                
                    if(accIdNcardTypeMap.containskey(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id)){
                        paymntmtd1.invoiceit_s__Card_Number__c = accIdNcardTypeMap.get(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id);
                    }
                
                    if(accIdNcvvMap.containskey(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id)){
                        paymntmtd1.invoiceit_s__CVV__c = accIdNcvvMap.get(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id);
                    }
          
                    paymntmtd1.invoiceit_s__Account__c = ngageco.Account_Id__c;

                    if(accIdNbillingAddMap.containskey(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id)){
                        paymntmtd1.invoiceit_s__Billing_Address__c = accIdNbillingAddMap.get(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id);
                    }   
                
                    if(accIdNbillingCityMap.containskey(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id)){
                        paymntmtd1.invoiceit_s__Billing_City__c = accIdNbillingCityMap.get(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id);
                    }   
                
                    if(accIdNbillingStateMap.containskey(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id)){
                            paymntmtd1.invoiceit_s__Billing_State_Province__c = accIdNbillingStateMap.get(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id);
                    }
                
                    if(accIdNbillingZipMap.containskey(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id)){
                            paymntmtd1.invoiceit_s__Billing_Zip_Postal__c = accIdNbillingZipMap.get(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id);
                    }
                    
                    if(accIdNbillingCountryMap.containskey(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id)){
                            paymntmtd1.invoiceit_s__Billing_Country__c = accIdNbillingCountryMap.get(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id);
                    }
                
                    createPM.add(paymntmtd1);
                    
                }
            }
        }    
                    
                        
        
        
        if(!childOpptyList.isempty()){
            for(Opportunity co: childOpptyList){
                System.debug('@@@@@@@Check 1st condition'+parentOpptyNChildOpptyMap.containskey(co.Parent_Opportunity__c));
                System.debug('@@@@@@@@@@@@@Check the 2nd condition'+co.Parent_Opportunity__r.AccountId);
                System.debug('@@@@@@Check the 3rd '+accIdNnameOnCardMap.containskey(co.Parent_Opportunity__r.AccountId));
                
                if(parentOpptyNChildOpptyMap.containskey(co.Parent_Opportunity__c)){
                    
                    invoiceit_s__Payment_Method__c paymntmtd = new invoiceit_s__Payment_Method__c();
                        paymntmtd.invoiceit_s__Active__c = True;
                        paymntmtd.invoiceit_s__Default__c = True;
                        paymntmtd.Created_By_Docusign__c = co.Parent_Opportunity__r.OwnerId;
                        
                        if(accIdNnameOnCardMap.containskey(co.Parent_Opportunity__r.AccountId)){
                            paymntmtd.invoiceit_s__Name_on_Card__c = accIdNnameOnCardMap.get(co.Parent_Opportunity__r.AccountId);
                        }
                    
                        if(accIdNcardNoMap.containskey(co.Parent_Opportunity__r.AccountId)){
                            paymntmtd.invoiceit_s__Card_Number__c = accIdNcardNoMap.get(co.Parent_Opportunity__r.AccountId);
                        }
                    
                        if(accIdNexpMonthMap.containskey(co.Parent_Opportunity__r.AccountId)){
                            paymntmtd.invoiceit_s__Card_Expiration_Month__c = accIdNexpMonthMap.get(co.Parent_Opportunity__r.AccountId);
                        }
                    
                        if(accIdNexpYrMap.containskey(co.Parent_Opportunity__r.AccountId)){
                            paymntmtd.invoiceit_s__Card_Expiration_Year__c = accIdNexpYrMap.get(co.Parent_Opportunity__r.AccountId);
                        }
                    
                        if(accIdNcardTypeMap.containskey(co.Parent_Opportunity__r.AccountId)){
                            paymntmtd.invoiceit_s__Card_Number__c = accIdNcardTypeMap.get(co.Parent_Opportunity__r.AccountId);
                        }
                    
                        if(accIdNcvvMap.containskey(co.Parent_Opportunity__r.AccountId)){
                            paymntmtd.invoiceit_s__CVV__c = accIdNcvvMap.get(co.Parent_Opportunity__r.AccountId);
                        }
              
                        paymntmtd.invoiceit_s__Account__c = co.Account_Id__c;
    
                        if(accIdNbillingAddMap.containskey(co.Parent_Opportunity__r.AccountId)){
                            paymntmtd.invoiceit_s__Billing_Address__c = accIdNbillingAddMap.get(co.Parent_Opportunity__r.AccountId);
                        }   
                    
                        if(accIdNbillingCityMap.containskey(co.Parent_Opportunity__r.AccountId)){
                            paymntmtd.invoiceit_s__Billing_City__c = accIdNbillingCityMap.get(co.Parent_Opportunity__r.AccountId);
                        }   
                    
                        if(accIdNbillingStateMap.containskey(co.Parent_Opportunity__r.AccountId)){
                                paymntmtd.invoiceit_s__Billing_State_Province__c = accIdNbillingStateMap.get(co.Parent_Opportunity__r.AccountId);
                        }
                    
                        if(accIdNbillingZipMap.containskey(co.Parent_Opportunity__r.AccountId)){
                                paymntmtd.invoiceit_s__Billing_Zip_Postal__c = accIdNbillingZipMap.get(co.Parent_Opportunity__r.AccountId);
                        }
                        
                        if(accIdNbillingCountryMap.containskey(co.Parent_Opportunity__r.AccountId)){
                                paymntmtd.invoiceit_s__Billing_Country__c = accIdNbillingCountryMap.get(co.Parent_Opportunity__r.AccountId);
                        }
                    
                        createPM.add(paymntmtd);
                }
            }
        }
        
        
        
        if(!createPM.isempty()){
            insert createPM;
        }
        
    }
    
     public void checkIfMidTerm(list<opportunity> op)
       {
       set<id> midtermset = new set<id>();
       set<id> newrpc = new set<id>();
       list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> nwlist = new list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
       Id RecordTypeId_naggeOppty = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-NG Opportunity').getRecordTypeId();
        System.debug('@@@@@@@@@@RecordTypeId_naggeOppty '+RecordTypeId_naggeOppty );
       for (opportunity o:op)
       {
           System.debug('@@@@@@@@@@o.name'+o.name);
           if ((o.name.contains('Mid-Term') || o.name.contains('Midterm'))){
               System.debug('=====o.RecordTypeId'+o.RecordTypeId);
               if(o.RecordTypeId!=RecordTypeId_naggeOppty )
               midtermset.add(o.id);
           }
       }
       if(!midtermset.isempty() && midtermset!=NULL){
           for (invoiceit_crmx__Opportunity_Rate_Plan_Charge__c c: [select id, name, invoiceit_crmx__Opportunity__c from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c where invoiceit_crmx__Opportunity__c in :midtermset and quote_type__c = 'New'])
           {
                newrpc.add(c.invoiceit_crmx__Opportunity__c);
           }
       }
       midtermset.removeAll(newrpc);
       System.debug('============midtermset'+midtermset);
       for (id i : midtermset) 
       {
            String statusofopp = idvsnewopp.get(i).StageName;
            trigger.newMap.get(i).addError('You can not ' +statusofopp+ ' a Mid-Term opportunity since no new product has been added.');   
       }
       
   }
   
   
    /************************************************************
     * Author           : Sai
     * Description      : to update value Ids in attributes whenever opportunity stage goes to qa review
     * Date             : 20/02/2017
     * ***********************************************************/
     
    public static void updateValueIdsinAttributes(List<opportunity> opplist,map<Id,Opportunity> oldMap){
        Set<Id>optyIds                                                         = new Set<Id>();
        set<Id> optychargesIds;
         for(Opportunity oppt : opplist){
           if( (oppt.StageName != oldMap.get(oppt.Id).StageName && oppt.StageName == 'QA Review'))
          // || (oppt.StageName != oldMap.get(oppt.Id).StageName && oppt.StageName == 'Closed Won'))
           {
                    optyIds.add(oppt.id);
             }       
            system.debug('@@@ setofopps' + optyIds);
         }
        
        if(!optyIds.isEmpty()){
            optychargesIds = new map<id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>([select id 
                                                                                          from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c
                                                                                          where invoiceit_crmx__Opportunity__c IN:optyIds]).keyset();
            if(optychargesIds != null){
                Database.executeBatch(new BatchtoUpdateAttributeValues(optychargesIds), 100);
            }
            
            
        }
        
        
    } 
   
    public  void assignterms(List<opportunity> opplist, Map<Id,Opportunity> oldmap){
        
        system.debug('@@@@@ in assignterms'+ opplist[0].Next_Month_Number__c);
        for(opportunity oppt: opplist){
            if(oppt.Name.contains('Mid-Term') && 
                ((oppt.StageName != oldMap.get(oppt.Id).StageName && oppt.StageName == 'QA Review')
                 || (oppt.StageName != oldMap.get(oppt.Id).StageName && oppt.StageName == 'Closed Won'))){
                     
                     if(oppt.Next_Month_Number__c > oppt.SED_for_Terms__c){
                         oppt.invoiceit_crmx__Number_Of_Terms__c = 1;
                     }
                     else{
                         if(oppt.SED_for_Terms__c!=Null){
                             if(oppt.SED_for_Terms__c.year() == oppt.Next_Month_Number__c.year()){
                             oppt.invoiceit_crmx__Number_Of_Terms__c = integer.valueof(oppt.SED_for_Terms__c.month() - oppt.Next_Month_Number__c.month() + 1);
                             }
                             else{
                                 //oppt.invoiceit_crmx__Number_Of_Terms__c = (12 - oppt.SED_for_Terms__c.month() + oppt.Next_Month_Number__c.month() + 1) * (oppt.SED_for_Terms__c.year() - oppt.Next_Month_Number__c.year());
                                 //oppt.invoiceit_crmx__Number_Of_Terms__c   = integer.valueof(oppt.Next_Month_Number__c.daysBetween(oppt.SED_for_Terms__c)/30.25);
                                  /*decimal terms = oppt.Next_Month_Number__c.daysBetween(oppt.SED_for_Terms__c)/30.25;
                                 Integer termstoAssign = (terms - terms.intValue() > 0.1) ? terms.intValue() + 1: terms.intValue();*/
                                 Integer terms = oppt.Next_Month_Number__c.MonthsBetween(oppt.SED_for_Terms__c);
                                if(oppt.SED_for_Terms__c.day() > oppt.Next_Month_Number__c.day()){
                                    terms++;
                                }
                                 oppt.invoiceit_crmx__Number_Of_Terms__c   = terms;
                             }
                         }
                         
                     }
                     
                    
                     
                     }
            
            
            }
        
        
        
        
        
    }
    
    /************************************************************
     * Author           : Ronak
     * Description      : to update case owners based on sub area to Social Starter and editorial whenever opportunity stage goes to Closed Won
     * Date             : 06/12/2018
     * ***********************************************************/
     
    public static void updateCaseOwnersinOppty(List<opportunity> opplist, map<Id,Opportunity> oldMap, map<Id,Opportunity> newMap){
        Set<Id>optyIds = new Set<Id>();
        List<Case> updateCases = new List<Case>();
        
        Map<String,String> queueNareaMap = new Map<String,String>();
       
        Id RecordTypeId_mhOppty = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-H Opportunity').getRecordTypeId(); 
        
         for(Opportunity oppt : opplist){
             System.debug('@@@@@@@@@@@@oppt-StageName'+oppt.StageName);
             System.debug('@@@@@@@@@@@@oldMap.get(oppt.Id).StageName'+oldMap.get(oppt.Id).StageName);
             System.debug('@@@@@@@@@Inside old map-------->'+oldMap.get(oppt.Id).isWon);
             System.debug('@@@@@@@@@Inside new -00'+newMap.get(oppt.Id).isWon);

             System.debug('@@@@@@@Record Type'+RecordTypeId_mhOppty );
           if(oppt.StageName == 'Closed Won' && oppt.StageName!=oldMap.get(oppt.Id).StageName &&  oppt.RecordTypeid == RecordTypeId_mhOppty && oppt.CaseonOpportunity__c == true)
           {
               optyIds.add(oppt.id);
           }       
            system.debug('@@@ setofopps-new' + optyIds);
         }
        
        if(!optyIds.isEmpty() && optyIds!=NULL){
        
           List<Case> caseList = [Select id, sub_area__c,Area__c From case where Parent_Opportunity__c in:optyIds];
           system.debug('====@@@=====caseList'+caseList);
            if(!caseList.isempty() && caseList!=NULL){
                List<String> queueName = new List<String>();
               queueName.add('Social Starter');
               queueName.add('Editorial');
               //String queueName = 'Editorial,Social Starter'; 
               List<Group> queueList = [Select Id,Name from Group where Name in:queueName and Type = 'Queue'];
               System.debug('@@@@@@queue List'+queueList);

               
               for(Group g:queueList){
                   queueNareaMap.put(g.name,g.id);

               } 
                System.debug('@@@@@@@@@@queueNareaMap'+queueNareaMap);

            
            
                for(Case c : caseList){
                    if(queueNareaMap.containskey(c.Area__c)){
                        c.ownerId = queueNareaMap.get(c.Area__c);
                        updateCases.add(c);
                    }
                }
            }
          } 
            
            if(!updateCases.isempty()){
                update updateCases;
            }
            

        
        
        
    } 
    //Ngage Stage Update on Contact //updated saiv MHBS-4392
    public static void ngageStageUpdate(List<Opportunity> oplist, Map<Id,Opportunity> oldmap){
        List<Id> conList = new List<Id>();
        List<Contact> updateCon = new List<Contact>();
        Id RecordTypeId_ngageOppty = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-NG Opportunity').getRecordTypeId();
        for(Opportunity opty:oplist){
            system.debug('opty query==========='+opty);
            if(opty.StageName != oldMap.get(opty.Id).StageName && opty.StageName == 'Closed Won' && opty.Auth_By_Contact__c <> Null && opty.RecordtypeId == RecordTypeId_ngageOppty){
                conList.add(opty.Auth_By_Contact__c);
            }
            if(opty.StageName != oldMap.get(opty.Id).StageName && opty.StageName == 'Closed Won' && opty.invoiceit_crmx__Billing_Contact__c<> Null && opty.RecordtypeId == RecordTypeId_ngageOppty){
                conList.add(opty.invoiceit_crmx__Billing_Contact__c);
            }
            system.debug('con list==========='+conList);
        }
        if(!conList.isEmpty()){
            for(Contact con:[select id, NgageStage__c from Contact where ID IN:conList]){
            system.debug('con quet==========='+con);
                if(con.NgageStage__c != 'Client'){
                    con.NgageStage__c = 'Client';
                    updateCon.add(con);
                }
            }
            
            
        }
        if(!updateCon.isEmpty()){
            update updateCon;
        }
    }
    //prodbundle
    /*public void BundleProductValidations(List<opportunity> opplist, Map<Id,Opportunity> oldmap){
        set<Id> OppProdId = new set<Id>();
        set<Id> OppId = new set<Id>();
        for(Opportunity oppt : opplist){
           if((oppt.StageName != oldMap.get(oppt.Id).StageName && oppt.StageName == 'QA Review')
           || (oppt.StageName != oldMap.get(oppt.Id).StageName && oppt.StageName == 'Closed Won')){
               OppId.add(oppt.id);
               system.debug('=======Opp with bundle prod========'+OppId);
           }
         }
         for(invoiceit_crmx__Opportunity_Product__c OppPro: [select id, name, invoiceit_crmx__Product_Bundle__c from invoiceit_crmx__Opportunity_Product__c where id in:OppId and invoiceit_crmx__Product_Bundle__c!= null]){
             OppProdId.add(OppPro.id);
         }
         list<invoiceit_s__Product_Bundle__c> OppProdBundle = [select Biography_Xref_Maximum__c, Biography_Xref_Minimum__c from invoiceit_s__Product_Bundle__c where id in:OppProdId];
         list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> OppRPC = [select id, name, invoiceit_crmx__Quantity__c, invoiceit_crmx__Accounting_Code__c from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c where id in:OppProdId and Package_Component__c = true];
         for(invoiceit_s__Product_Bundle__c opb: OppProdBundle){
             for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c orpc: OppRPC){
                 if(orpc.invoiceit_crmx__Accounting_Code__c == '11007' && orpc.invoiceit_crmx__Quantity__c < opb.Biography_Xref_Minimum__c){
                     orpc.adderror('test exception');
                 }
             }
         }
    }*/

    // Sai: 10/7/2016    
    // using in before update, coz if we use in after update, coz of recursion old and new values not matching
    /*
    public static void updateAccountFiledsbasedonoptyClosedWon(Map<id,Opportunity> oldMap, Map<id,Opportunity> newMap,List<opportunity> opplist ){
        
        system.debug('@@@@ in updateAccountFiledsbasedonoptyClosedWon');
        
        //Declaration Section


        set<Id> accids             = new Set<Id>();

        List<account> accstoUpdate = new List<account>();
        
        //account RecordTypeIds to Update
        Id RecordTypeId_accountMDL = Schema.SObjectType.Account.getRecordTypeInfosByName().get('MDL Accounts').getRecordTypeId();
        Id RecordTypeId_accountNolo = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Nolo Account').getRecordTypeId();
        
        Id RecordTypeId_oppMDL  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MDL Opportunity').getRecordTypeId();
        Id RecordTypeId_oppNolo = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Nolo Opportunity').getRecordTypeId();
        
        //getting account ids to update accounts

        for(Opportunity opp : newMap.values()){

            if(oldMap.get(opp.id).stageName != newMap.get(opp.id).stageName && newMap.get(opp.id).stageName == 'Closed Won'){
                accids.add(opp.AccountId);
            }


        }
        system.debug('@@@accids'+accids);
        

        if(accids.size() > 0){

            for(account acc : [select id, Name,
                                      Billing_Schedule__c,Legal_Entity__c,
                                      invoiceit_s__Invoice_Delivery_Type__c,
                                      invoiceit_s__Payment_Terms__c,
                                      RecordTypeId,Order_Status__c,
                                      (select id,Name,StageName, 
                                              RecordType.DeveloperName
                                              from opportunities
                                              where StageName = 'Closed Won')
                                      from account 
                               where Order_Status__c = 'InActive' ]){

                                   
                                   system.debug('@@@@acc opportunities'+ acc.opportunities);
                                   //checking first opty closed won here
                                   //if(acc.opportunities.size() >= 0){
                                       //system.debug('@@@@opportunity'+ opplist[0]);
                                       if(opplist[0].RecordTypeId == RecordTypeId_oppMDL){
                                           acc.RecordTypeId                          = RecordTypeId_accountMDL;
                                           acc.Billing_Schedule__c                   = 'Arrears';
                                           acc.Legal_Entity__c                       = 'MH Taxable';
                                           acc.invoiceit_s__Invoice_Delivery_Type__c = 'Print';
                                           acc.invoiceit_s__Payment_Terms__c         = 'Net 30';
                                       }
                                       else if(opplist[0].RecordTypeId == RecordTypeId_oppNolo){
                                           acc.RecordTypeId                          = RecordTypeId_accountNolo;
                                           acc.Billing_Schedule__c                   = 'Advanced';
                                           acc.Legal_Entity__c                       = 'Nolo Taxable';
                                           acc.invoiceit_s__Invoice_Delivery_Type__c = 'Email & Print';
                                           acc.invoiceit_s__Payment_Terms__c         = 'Net 30';
                                       }
                                       accstoUpdate.add(acc);
                                       
                                  // }                 
                                   
                               
            }
        }
        
        
        //updating accounts here
        try{
            if(accstoUpdate.size() > 0){
                update accstoUpdate;
            }
        }
        catch(Exception e){
            system.debug('@@@@exception e'+ e);
        }
        
        
    }
    
   */ 
    
    webservice Static String ValidateChildOpptyStage(String ordId){
        String ChildOppStageName = '';
         // ChildOppStageName = False;
         List<Opportunity> ChildOppStage = [select id,Name, StageName From Opportunity Where StageName = 'QA Review' AND Ngage_Upsell_Order__c =:ordId];  
            If (!ChildOppStage.isEmpty()){
                ChildOppStageName = 'True';
            }
          return ChildOppStageName;
          
     }
    
    webservice Static String validateAttributes(String oppId){
        
        boolean error = false;
        string errorString = '';
        
        Set<Id> childNParentOpptyIds = new Set<Id>();
        list<Opportunity_Charge_Attribute__c> listOfOpptAttributes = new list<Opportunity_Charge_Attribute__c>();

        //Opportunity opport = [Select id, name,Lock_Record__c,IsUpsellOppty__c,invoiceit_crmx__Discount_Percent__c,Ngage_Source__c, StageName,Discoint_Approved__c, RecordType.Name, Parent_Opportunity__c,Parent_Opportunity__r.Id,(Select id, name,Parent_Opportunity__r.Id,Parent_Opportunity__c From Child_Opportunities__r ORDER BY CreatedDate LIMIT 1) From Opportunity Where id=: oppid];
          
        List<invoiceit_crmx__Opportunity_Product__c> opptyProd = [Select id, name,invoiceit_crmx__Product_Code__c , RecordType.Name From invoiceit_crmx__Opportunity_Product__c Where invoiceit_crmx__Opportunity__c =: oppid ];
        //(invoiceit_crmx__Product_Code__c = '11006' OR invoiceit_crmx__Product_Code__c = '01808' OR invoiceit_crmx__Product_Code__c = '01972' OR invoiceit_crmx__Product_Code__c = '01811') AND
        for(invoiceit_crmx__Opportunity_Product__c o: opptyProd){
            if(o.invoiceit_crmx__Product_Code__c == '11006' || o.invoiceit_crmx__Product_Code__c == '01686'|| o.invoiceit_crmx__Product_Code__c == '60010' || o.invoiceit_crmx__Product_Code__c == '01649' || o.invoiceit_crmx__Product_Code__c == '01681' || o.invoiceit_crmx__Product_Code__c == '01880' || o.invoiceit_crmx__Product_Code__c == '01649' || o.invoiceit_crmx__Product_Code__c == '01162' || o.invoiceit_crmx__Product_Code__c == '01649'|| o.invoiceit_crmx__Product_Code__c == '01811' || o.invoiceit_crmx__Product_Code__c == '01808' || o.invoiceit_crmx__Product_Code__c == '01972' || o.invoiceit_crmx__Product_Code__c == '01811'){
                childNParentOpptyIds.add(o.id);
            
            }else if(o.RecordType.Name == 'M-NG Opportunity Product'){
                childNParentOpptyIds.add(o.id);
            }
        }
       // if(!opport.Child_Opportunities__r.isempty()){
       //     childNParentOpptyIds.add(opport.Child_Opportunities__r[0].Id);
       // }
        System.debug('======childNParentOpptyIds===='+childNParentOpptyIds);
        listOfOpptAttributes = [SELECT Attribute_Order__c,Picklist_Value__c,Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c,Attribute_Picklist_Values__c,Phone_Value__c, Name,
                                    Attribute_Name__c,Attribute_Type__c,Boolean_Value__c,Date_Value__c,Number_Value__c,Opportunity_Rate_Plan_Charge__c,String_Value__c,Required__c
                                    FROM Opportunity_Charge_Attribute__c
                                    WHERE Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c in: childNParentOpptyIds];
        
        
        
        
        System.debug('listOfOpptAttributes==================='+listOfOpptAttributes );
        
        if(!listOfOpptAttributes.isEmpty()){
            
            for(Opportunity_Charge_Attribute__c attribute : listOfOpptAttributes){
                if(attribute.Attribute_Type__c == 'Text'){
                    
                    if(attribute.String_Value__c == '' || attribute.String_Value__c == Null){
                        error = true;
                        errorString = 'You can not Add Chat since few attributes are blank';
                        
                    }

                } 
                
                else if(attribute.Attribute_Type__c == 'Number'){

                    if(attribute.Number_Value__c == null){
                        error = true;
                        errorString = 'You can not Add Chat since few attributes are blank';
                    }

                }

                else if(attribute.Attribute_Type__c == 'Boolean'){

                    if(attribute.Boolean_Value__c != true){
                        error = true;
                        errorString = 'You can not Add Chat since few attributes are blank';
                    }

                }
                else if(attribute.Attribute_Type__c == 'Picklist'){

                    if(attribute.Picklist_Value__c == '' || attribute.Picklist_Value__c == null){
                        error = true;
                        errorString = 'You can not Add Chat since few attributes are blank';
                    }

                }
                else if(attribute.Attribute_Type__c == 'Date'){

                    if(attribute.Date_Value__c == null){
                        error = true;
                        errorString = 'You can not Add Chat since few attributes are blank';
                    }

                }
                else if(attribute.Attribute_Type__c == 'Phone'){

                    if(attribute.Phone_Value__c == null){
                        error = true;
                        errorString = 'You can not Add Chat since few attributes are blank';
                    }

                }
                else{
                
                }
            
            
            }
        }
        if(error){
            System.debug('@@@@@@@@@@@errorString'+errorString);
            return errorString;
        
        }else{
            return null;
        }
    }
    
    webservice Static String validateproductQuantity(String oppId){
        
        //added by saiv - Seo Services TOBEREMOVED Validation
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> rpcList = [select id,Name,invoiceit_crmx__Accounting_Code__c From invoiceit_crmx__Opportunity_Rate_Plan_Charge__c Where (Package_Wrapper__c= false OR Package_Component__c= false) and invoiceit_crmx__Opportunity__c =: oppId and (invoiceit_crmx__Accounting_Code__c = '30055' OR invoiceit_crmx__Accounting_Code__c = '30057' OR invoiceit_crmx__Accounting_Code__c = '01945')];
        system.debug('----------rpcList'+rpcList);
    
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> rateplanChargeList = [select id,Name, invoiceit_crmx__Quantity__c, invoiceit_crmx__Opportunity_Rate_Plan__c,
         invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Bundle__c , invoiceit_crmx__Accounting_Code__c,invoiceit_crmx__Opportunity__r.id,
        invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product__r.Name, Package_Component__c, Package_Wrapper__c
        from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c where (Package_Wrapper__c= true OR Package_Component__c= true) and invoiceit_crmx__Opportunity__c =: oppId];
        system.debug(logginglevel.error,'---rateplanChargeList --'+rateplanChargeList );
        
        Set<String> productBundleSet = new Set<String>();
        Map<String,Decimal> productNQuantityMap = new Map<String,Decimal>();
        Map<String,String> ProductNAccCodeMap = new Map<String,String>(); //added by saiv 10/12/18
        Boolean pkgWrpexist = false;
        Boolean pkgCmpntexist = false;
        for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c orpc :rateplanChargeList){
            
             //added by saiv 10/12/18
            if(orpc.Package_Wrapper__c == true && orpc.Package_Component__c == false){
                pkgWrpexist = true;
                
            }
            if(pkgWrpexist == true && orpc.Package_Component__c == true){
                pkgCmpntexist = true;
                
            }
            //added by saiv 10/12/18
            
            productBundleSet.add(orpc.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Bundle__c);
            Decimal cnt =0;
            if(orpc.Name.containsIgnoreCase('Web Site Video')){
                if(productNQuantityMap.containsKey('WebSiteVideo')){
                    cnt = productNQuantityMap.get('WebSiteVideo') + orpc.invoiceit_crmx__Quantity__c;
                }else{
                    cnt = orpc.invoiceit_crmx__Quantity__c;
                }
                productNQuantityMap.put('WebSiteVideo', cnt);
                
            }else if(orpc.Name.containsIgnoreCase('Preferred County') || orpc.Name.containsIgnoreCase('Preferred City Results')){
                if(productNQuantityMap.containsKey('PreferredCountyCity')){
                    cnt = productNQuantityMap.get('PreferredCountyCity') + orpc.invoiceit_crmx__Quantity__c;
                }else{
                    cnt = orpc.invoiceit_crmx__Quantity__c;
                }
                productNQuantityMap.put('PreferredCountyCity', cnt);
                
            }else if(orpc.Name.containsIgnoreCase('Biography Cross Reference') || orpc.Name.containsIgnoreCase('County Cross Reference')){
                if(productNQuantityMap.containsKey('BioCountyCross')){
                    cnt = productNQuantityMap.get('BioCountyCross') + orpc.invoiceit_crmx__Quantity__c;
                }else{
                    cnt = orpc.invoiceit_crmx__Quantity__c;
                }
                productNQuantityMap.put('BioCountyCross', cnt);
            }else if(orpc.Name.containsIgnoreCase('Preferred State Results')){
                if(productNQuantityMap.containsKey('PreferredStateResults')){
                    cnt = productNQuantityMap.get('PreferredStateResults') + orpc.invoiceit_crmx__Quantity__c;
                }else{
                    cnt = orpc.invoiceit_crmx__Quantity__c;
                }
                productNQuantityMap.put('PreferredStateResults', cnt);
            
            }else if(orpc.Name.containsIgnoreCase('SEO Services')){
                if(productNQuantityMap.containsKey('SEOServices')){
                    cnt = productNQuantityMap.get('SEOServices') + orpc.invoiceit_crmx__Quantity__c;
                }else{
                    cnt = orpc.invoiceit_crmx__Quantity__c;
                }
                productNQuantityMap.put('SEOServices', cnt);
                ProductNAccCodeMap.put('SEOServices',orpc.invoiceit_crmx__Accounting_Code__c);//added bysaiv 10/12/18
                
            }
            
        }
         system.debug(logginglevel.error,'---productNQuantityMap--'+productNQuantityMap);
         system.debug('=========ProductNAccCodeMap:'+ProductNAccCodeMap.values());
         
         if(pkgWrpexist == true && pkgCmpntexist == false){
            return 'Please remove package wrapper as there are no package components';
        }
    
        System.debug('@@@productBundleSet '+productBundleSet );
        List<invoiceit_s__Product_Bundle__c> bundleList = new List<invoiceit_s__Product_Bundle__c>();
        if(!productBundleSet.isempty() && productBundleSet!=NULL){
             bundleList = [select Name, Preferred_City_County_Maximum__c, Preferred_City_County_Minimum__c, 
             SEO_Services_Minimum__c, SEO_Services_Maximum__c, Preferred_State_Maximum__c, Preferred_State_Minimum__c, Website_Video_Maximum__c, Website_Video_Minimum__c , invoiceit_s__Quantity__c, invoiceit_s__Product_Bundle_Code__c, Bio_County_Xref_Minimum__c, Bio_County_Xref_Maximum__c from invoiceit_s__Product_Bundle__c where id IN: productBundleSet limit 1];
             
             system.debug(logginglevel.error,'---bundleList --'+bundleList );
         }
         Set<String> productNameSet  = new Set<String>();
         //added by saiv - 10/12/18 start
         for(invoiceit_s__Product_Bundle__c bunList: bundleList){
                system.debug('-----bunList.Name----'+bunList.Name);
                if(bunList.Name == 'Platinum Package' && !ProductNAccCodeMap.values().contains('30057')){
                    productNameSet.add('- Add SEO Services - Platinum AddOn');  
                }
                else if(bunList.Name == 'Gold Package' && !ProductNAccCodeMap.values().contains('30055')){
                    productNameSet.add('- Add SEO Services - Gold AddOn');
                }
                else if((bunList.Name == 'Bronze Package' || bunList.Name == 'Silver Package') && !rpcList.isEmpty()){
                    productNameSet.add('- Please Remove SEO Services/WebSite Video');
                }
                system.debug('@@@@@ProductNAccCodeMapkeyset:'+ProductNAccCodeMap.values());
             }
         //added by saiv - 10/12/18 end
         
         for(String productName : productNQuantityMap.keySet()){
            Decimal quantity = productNQuantityMap.get(productName);
            
            if(productName =='WebSiteVideo'){
                if(quantity < bundleList[0].Website_Video_Minimum__c || quantity > bundleList[0].Website_Video_Maximum__c){
                    productNameSet.add('Web Site Video');
                }
            }else if(productName =='PreferredCountyCity'){
                if(quantity < bundleList[0].Preferred_City_County_Minimum__c || quantity > bundleList[0].Preferred_City_County_Maximum__c){
                    productNameSet.add('Preferred County Results and Preferred City Results');
                }
            }else if(productName =='BioCountyCross'){
                if(quantity < bundleList[0].Bio_County_Xref_Minimum__c || quantity > bundleList[0].Bio_County_Xref_Maximum__c){
                    productNameSet.add('Biography Cross Reference and County Cross Reference');
                }
            }else if(productName =='PreferredStateResults'){
                if(quantity < bundleList[0].Preferred_State_Minimum__c || quantity > bundleList[0].Preferred_State_Maximum__c){
                    productNameSet.add('Preferred State Results ');
                }
            }/*else if(productName =='CountyCrossReference'){
                if(quantity < bundleList[0].County_Xref_Minimum__c || quantity > bundleList[0].County_Xref_Maximum__c){
                    productNameSet.add('County Cross Reference');
                    system.debug('======ccquantity====='+quantity);
                }
            }*/else if(productName =='SEOServices'){
                if(quantity < bundleList[0].SEO_Services_Minimum__c || quantity > bundleList[0].SEO_Services_Maximum__c){
                    productNameSet.add('SEO Services');
                    system.debug('@@@@@productName:'+productName);
                }
            }
            
         
        }
        
        String productStr = '';
        if(!productNameSet.isEmpty()){
            for(String s : productNameSet){
                productStr += s +', ';
            }
        }
        productStr.removeEnd(',');
        
        system.debug(logginglevel.error,'---productStr--'+productStr);
        return productStr;
    }
    webservice Static void validateChargesList(String oppId){
        //For Seq Num
        Decimal lastSeqNum;
        List<invoiceit_crmx__Opportunity_Product__c> OppProdUpdateList = new List<invoiceit_crmx__Opportunity_Product__c>();
        for(invoiceit_crmx__Opportunity_Product__c op: [select id,Name,invoiceit_crmx__Bundle_SequenceNumber__c,invoiceit_crmx__Opportunity__c,invoiceit_crmx__Product_Bundle__c,invoiceit_crmx__Product_Bundle__r.Name,invoiceit_crmx__Product_Family__c,Product_SIN__c,invoiceit_crmx__SequenceNumber__c from invoiceit_crmx__Opportunity_Product__c where invoiceit_crmx__Opportunity__c =: oppId order by invoiceit_crmx__SequenceNumber__c]){
            if(op.invoiceit_crmx__Product_Bundle__c != null){                
                lastSeqNum = op.invoiceit_crmx__SequenceNumber__c;
            }
        }
        // For Product rate plan and Product rate plan charge update
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> chargesList = [select id,Name,invoiceit_crmx__Accounting_Code__c,invoiceit_crmx__Opportunity_Rate_Plan__c,invoiceit_crmx__Product_Bundle_Line__c,invoiceit_crmx__Product_Rate_Plan_Charge__c,Created_From_Charge__c ,Package_Component__c ,Package_Wrapper__c from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c where invoiceit_crmx__Product_Bundle_Line__c != null and Package_Wrapper__c = false and Package_Component__c = false and invoiceit_crmx__Opportunity__c =: oppId];
            system.debug(logginglevel.error,'---chargesList --'+chargesList );      
            List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> ORPCtoUpdateList = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();        
            List<invoiceit_crmx__Opportunity_Rate_Plan__c> ORPUpdateList = new List<invoiceit_crmx__Opportunity_Rate_Plan__c>();
            Set<Id> bundleLineIds = new Set<Id>();
            Set<Id> oppRatePlanIds = new Set<Id>();
            Map<Id,Id> oppRatePlanBundleLineMap = new Map<Id,Id>(); //opprateplanId,bundleLineId
            
            for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c charge: chargesList){
                bundleLineIds.add(charge.invoiceit_crmx__Product_Bundle_Line__c);
                oppRatePlanIds.add(charge.invoiceit_crmx__Opportunity_Rate_Plan__c);
                oppRatePlanBundleLineMap.put(charge.invoiceit_crmx__Opportunity_Rate_Plan__c,charge.invoiceit_crmx__Product_Bundle_Line__c);
            }
            Map<Id,invoiceit_s__Product_Bundle_Line__c> prodBundleLineMap = new Map<Id,invoiceit_s__Product_Bundle_Line__c>();
            for(invoiceit_s__Product_Bundle_Line__c pbl: [select id,Name,invoiceit_s__Product_Bundle__c,invoiceit_s__Product__c,invoiceit_s__Product__r.Name,invoiceit_s__Product_Bundle__r.Name,invoiceit_s__Product_Rate_Plan__c,invoiceit_s__Product_Rate_Plan_Charge__c,invoiceit_s__Product_Rate_Plan_Charge__r.Name,invoiceit_s__Product_Rate_Plan_Charge__r.invoiceit_s__Accounting_Code__c from invoiceit_s__Product_Bundle_Line__c]){         
                prodBundleLineMap.put(pbl.Id,pbl);          
            }
            
            for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c charge : chargesList){
                  charge.Name = prodBundleLineMap.get(charge.invoiceit_crmx__Product_Bundle_Line__c).invoiceit_s__Product_Rate_Plan_Charge__r.Name;
                  charge.invoiceit_crmx__Accounting_Code__c = prodBundleLineMap.get(charge.invoiceit_crmx__Product_Bundle_Line__c).invoiceit_s__Product_Rate_Plan_Charge__r.invoiceit_s__Accounting_Code__c;
                  charge.invoiceit_crmx__Product_Rate_Plan_Charge__c =  prodBundleLineMap.get(charge.invoiceit_crmx__Product_Bundle_Line__c).invoiceit_s__Product_Rate_Plan_Charge__c;
                  ORPCtoUpdateList.add(charge);
            }
            Set<Id> oppProdsSet = new Set<Id>();
            for(invoiceit_crmx__Opportunity_Rate_Plan__c orp: [select id,invoiceit_crmx__Product_Rate_Plan__c,Name,invoiceit_crmx__Opportunity_Product__c from invoiceit_crmx__Opportunity_Rate_Plan__c where id IN: oppRatePlanIds]){
                orp.invoiceit_crmx__Product_Rate_Plan__c = prodBundleLineMap.get(oppRatePlanBundleLineMap.get(orp.id)).invoiceit_s__Product_Rate_Plan__c;
                ORPUpdateList.add(orp);
                oppProdsSet.add(orp.invoiceit_crmx__Opportunity_Product__c);
            }
            
            if(!ORPUpdateList.isEmpty()){
                database.update(ORPUpdateList, false);
            }
            if(!ORPCtoUpdateList.isEmpty()){
                database.update(ORPCtoUpdateList, false);
            }
            
            // To Update Opp Prod with Seq num
            Decimal count = 1;
            for(invoiceit_crmx__Opportunity_Product__c op: [select id,Name,invoiceit_crmx__Bundle_SequenceNumber__c,invoiceit_crmx__Opportunity__c,invoiceit_crmx__Product_Bundle__c,invoiceit_crmx__Product_Bundle__r.Name,invoiceit_crmx__Product_Family__c,Product_SIN__c,invoiceit_crmx__SequenceNumber__c from invoiceit_crmx__Opportunity_Product__c where Id IN: oppProdsSet]){
                op.invoiceit_crmx__SequenceNumber__c= lastSeqNum+count;
                count++;
                OppProdUpdateList.add(op);
            }
            if(!OppProdUpdateList.isEmpty()){
                database.update(OppProdUpdateList, false);
            }
    }
    
 //MHBS-4006 - validate the addition of ROF product
      public void validateROFProduct (list<Opportunity> listOfOpportunity, map<Id,Opportunity> oldMap){
        list<Opportunity_Charge_Attribute__c> listOfOpptAttributes = new list<Opportunity_Charge_Attribute__c>();
        map<Id,list<Opportunity_Charge_Attribute__c>> mapofOppToAttributes = new map<Id,list<Opportunity_Charge_Attribute__c>>();
         map<string,list<Opportunity_Charge_Attribute__c>> mapofURLToAttributes = new map<string,list<Opportunity_Charge_Attribute__c>>();
         
         set<id> setOfOpptids = new set<id>();
         
         
         for(Opportunity oppt : listOfOpportunity){
            if( (oppt.StageName != oldMap.get(oppt.Id).StageName && oppt.StageName == 'QA Review')
                    || (oppt.StageName != oldMap.get(oppt.Id).StageName && oppt.StageName == 'Closed Won')){
                    setOfOpptids.add(oppt.id);
           }
        }
            
        listOfOpptAttributes = [SELECT  Name,Attribute_Name__c,String_Value__c,Opportunity_Rate_Plan_Charge__r.Name,Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c ,Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Name,
                              Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c                                    
                                    FROM Opportunity_Charge_Attribute__c
                                    WHERE Attribute_Name__c = 'URL' AND (Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Name = 'Web Bronze' OR Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Name = 'Web Silver' OR Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c = '01980') AND Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c IN : setOfOpptids ];
                                    
                                    
                                    
        for(Opportunity_Charge_Attribute__c ObjAtt: listOfOpptAttributes){
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
        
            set<Id> oppErrorId= new set<Id>();
            set<Id> oppURLErrorId = new set<Id>();  
        for(Opportunity_Charge_Attribute__c ObjAtt: listOfOpptAttributes){
        String OppId = ObjAtt.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c;
             
          if(ObjAtt.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c == '01980'){
             
           
          
          //to verify if same url applies to more product
            if(mapofURLToAttributes.containskey(ObjAtt.String_Value__c)){
               if(mapofURLToAttributes.get(ObjAtt.String_Value__c).size()>1){
                   oppURLErrorId.add(OppId);
               }
            }else{
              oppErrorId.add(OppId);
           }
          }
        }
        
        
         for(Opportunity oppt : listOfOpportunity){
           if(oppURLErrorId.contains(oppt.Id)){
                oppt.adderror('Two Web products cannot contain the same URL. Please review');
            }if(oppErrorId.contains(oppt.Id)){
               oppt.adderror('Review Page Plus product can only be added along with Web Bronze or Web Silver product');
            }
            
        }                               
                                    
  }
       
}