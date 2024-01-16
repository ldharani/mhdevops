public class NgageChatFeatureController {
    private ApexPages.StandardController standardController;
    public id Oppid{get;set;}
    public list<AttributesWrapper> ChatProdList{get;set;}
    public list<AttributesWrapper> ChatProdListFinal{get;set;}
    private list<invoiceit_crmx__Opportunity_Product__c> OppProduct = new list<invoiceit_crmx__Opportunity_Product__c>();
    private list<invoiceit_crmx__Opportunity_Rate_Plan__c> OppProductRatePlan = new list<invoiceit_crmx__Opportunity_Rate_Plan__c>();
    private list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> OppProductRatePlanCharge = new list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();  
    private list<invoiceit_s__Job_Product__c > OrdProduct = new list<invoiceit_s__Job_Product__c >();
    private list<invoiceit_s__Job_Rate_Plan__c > OrdProductRatePlan = new list<invoiceit_s__Job_Rate_Plan__c >();
    private list<invoiceit_s__Job_Rate_Plan_Charge__c > OrdProductRatePlanCharge = new list<invoiceit_s__Job_Rate_Plan_Charge__c >();  
    private list<id> OppDeleteChat = new list<id>();
    private list<id> OppDeleteProd = new list<id>();
    private map<id, invoiceit_s__Product_Rate_Plan_Charge__c> prodrpc = new map<id, invoiceit_s__Product_Rate_Plan_Charge__c>();
    //invoiceit_s__Product__c chatProduct = [select id, name, invoiceit_s__Product_Code__c, invoiceit_s__Product_Family__c, (select id, name from invoiceit_s__ProductRatePlan__r) from invoiceit_s__Product__c where name  = 'Ngage Chat' limit 1];
    map<id, invoiceit_s__Product__c> chatProduct = new map<id, invoiceit_s__Product__c>();
    map<id, Chat_Product_Opportunity_Charge__c> mapchat =  new map<id, Chat_Product_Opportunity_Charge__c>();
    private decimal seqno;
    map<id, id> prodChatmap  = new map<id, id>();
    map<id, id> prodFeatureMap = new Map<id, id>();
    map<id, id> prodOrpcChatMap = new map<id, id>();
    boolean professionalProfile = false;
    list<Chat_Product_Opportunity_Charge__c> chatlist = new list<Chat_Product_Opportunity_Charge__c>();
    private list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> chatusagelist = new list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
    list<Chat_Product_Opportunity_Charge__c> cpoc = new list<Chat_Product_Opportunity_Charge__c>();
    list<invoiceit_crmx__Opportunity_Product__c> op = new list<invoiceit_crmx__Opportunity_Product__c>();
    opportunity opptyList = new Opportunity();   //Ronak
    public string conversationcode;
    Opportunity opp = new opportunity();
    set<String> productNameList = new set<String>();
    set<string> multiProdPerChatList = new set<string>();
    set<id> prodforchat  = new set<id>();
    set<id> newchatlist = new set<id>();
    public Opportunity childopp{get;set;}
    public Opportunity ngageChildOpp{get;set;}
    public Account MNGchildacc{get;set;}
    public String mngrectypeId {get;set;}
    public Set<String> addonchatslistcodes {get;set;}
    public Map<string,invoiceit_s__Product__c> addonchatProductstoCreate{get;set;}
    public Set<String> addonChatProducts {get;set;}
    public Id ngageUpsellOrderId;
    public Id cancelId;
    public invoiceit_s__Job__c ngageUpsellOrder;
    //public List<standalonechat> standalonechatslist{get;set;}
    //public standalonechat singlestandalonechat; //this is used to add/delete Row functionality
   // public  List<childcharges> childaddonchatswrapperforstandlonetemp;
    //public Integer standalonechatsSize{get;set;}
    //public Map<string,boolean> childCheckAddOnProd {get;set;}
    
    public NgageChatFeatureController(ApexPages.StandardController standardController) {
        this.standardController = standardController;
        chatProdList = new list<AttributesWrapper>();
        ChatProdListFinal = new list<AttributesWrapper>();
        addonchatProductstoCreate = new Map<string,invoiceit_s__Product__c>();
        
        Oppid = standardController.getId();
        
        ngageUpsellOrderId = apexPages.currentPage().getParameters().get('orderid');
        system.debug('@@@@ngageUpsellOrderId'+ngageUpsellOrderId);
        If(ngageUpsellOrderId != NULL){
            ngageUpsellOrder = [select id,name, invoiceit_s__Number_Of_Terms__c
                                    From invoiceit_s__Job__c
                                     where id=:ngageUpsellOrderId];
            cancelId = ngageUpsellOrderId;
        }
        mngrectypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('M-NG Account').getRecordTypeId();
        
        
        //        for(invoiceit_s__Product__c p: [select id, name, invoiceit_s__Product_Code__c, invoiceit_s__Product_Family__c, (select id, name from invoiceit_s__ProductRatePlan__r) from invoiceit_s__Product__c where name  in ('Site Activation fee', 'Per Conversation fee')])
        if(OppId!=Null){
        Opportunity opp = [select id, name,Account.ParentId,Account.Parent.Name ,Discount__c, invoiceit_crmx__Number_Of_Terms__c, invoiceit_crmx__Discount_Percent__c, invoiceit_crmx__Discount_Value__c from opportunity where id = :oppid];
        system.debug('========opp'+opp);
           cancelId = oppId;
        }
        
        //Add on products logic
        Map<String,List<String>> prodVsAddonProducts = new Map<String,List<String>>();
        addonChatProducts          = new Set<String>();
        addonchatslistcodes                         = new Set<String>();
        
        for (Chat_Products__c c: Chat_Products__c.getall().values())
        {
            
            if (c.ConversationProduct__c != False)
            {
                List<String> tempstrings = new List<string>();
                if(c.Add_on_Chats__c != NULL){
                    tempstrings = c.Add_on_Chats__c.split(',');
                }
                productNameList.add(c.Product_Name__c);
                if(!tempstrings.isEmpty()){
                    addonChatProducts.addAll(tempstrings);
                    prodVsAddonProducts.put(c.Product_Name__c,tempstrings);
                    addonchatslistcodes.addAll(tempstrings);
                }
                
                conversationcode = c.Product_Name__c;
                addonchatslistcodes.add(conversationcode);
            }
               
        }
        system.debug('@@@@@@productNameList'+productNameList);
        system.debug('================multiProdPerChatList'+multiProdPerChatList);
        system.debug('@@@@@addonChatProducts'+addonChatProducts);  
         system.debug('@@@@@addonchatslistcodes'+addonchatslistcodes);   
        
        List<Opportunity> childOpptyList = [select id, name, Discount__c, invoiceit_crmx__Number_Of_Terms__c, 
                                            invoiceit_crmx__Discount_Percent__c, invoiceit_crmx__Discount_Value__c 
                                            from opportunity where Parent_Opportunity__c = :oppid
                                                    AND StageName != 'Closed Lost'];
        if(childOpptyList != null && childOpptyList.size() > 0){
            childopp = childOpptyList[0];
        }
        integer procnt;
        if(childopp != null)
            procnt = [select Chat_Product_Opp_Rate_Plan_Charge__c, 
                         Chat_Product_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product__c, 
                         Chat_Product_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name,
                         Chat_Usage_Opp_Rate_Plan_Charge__c 
                         from Chat_Product_Opportunity_Charge__c 
                         where Chat_Usage_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity__c = :childopp.id 
                             and Chat_Product_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c  in :multiProdPerChatList].size();
        if (procnt > 0) professionalprofile = true;
        
        //qeurying all chat products and addon chat products here
        for(invoiceit_s__Product__c p: [select id, name, invoiceit_s__Product_Code__c, 
                                            invoiceit_s__Product_Family__c, 
                                          (select id, name,
                                           Product_Code__c from invoiceit_s__ProductRatePlan__r
                                           
                                          ) 
                                            from invoiceit_s__Product__c 
                                              where invoiceit_s__Product_Code__c  IN: addonchatslistcodes])
        {
            if(p.invoiceit_s__Product_Code__c == conversationcode){
                chatProduct.put(p.id, p);
            }
            else{
                addonchatProductstoCreate.put(p.invoiceit_s__Product_Code__c,p);
            }
            
        }
        system.debug('=========chatProduct'+chatProduct);
        if(OppId!=Null){
        seqno = [select invoiceit_crmx__SequenceNumber__c from invoiceit_crmx__Opportunity_Product__c where invoiceit_crmx__Opportunity__c = :oppid and invoiceit_crmx__SequenceNumber__c != null order by invoiceit_crmx__SequenceNumber__c desc limit 1].invoiceit_crmx__SequenceNumber__c;
        }else if(ngageUpsellOrderId!=Null){
            seqno = [select invoiceit_s__SequenceNumber__c  from invoiceit_s__Job_Product__c  where invoiceit_s__Job__c  = :ngageUpsellOrderId and invoiceit_s__SequenceNumber__c != null order by invoiceit_s__SequenceNumber__c desc limit 1].invoiceit_s__SequenceNumber__c;    
        }
        if(childopp != null ){
            for ( Chat_Product_Opportunity_Charge__c o: [select Chat_Product_Opp_Rate_Plan_Charge__c, 
                                                         Chat_Product_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product__c, 
                                                         Chat_Product_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__SequenceNumber__c,
                                                         Chat_Product_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name, 
                                                         Chat_Product_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c, 
                                                         Chat_Usage_Opp_Rate_Plan_Charge__c, Chat_Product_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Accounting_Code__c,
                                                         Chat_Usage_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product__c, 
                                                         Chat_Usage_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__SequenceNumber__c,
                                                         Chat_Usage_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c,
                                                         Chat_Usage_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name, Chat_Usage_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Accounting_Code__c
                                                         from Chat_Product_Opportunity_Charge__c 
                                                         where Chat_Usage_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity__c = :childopp.id])
            {
                chatlist.add(o);
                mapchat.put(o.Chat_Usage_Opp_Rate_Plan_Charge__c, o);
            }
        }
       
        system.debug('======chatlist'+chatlist + '====mapchat'+mapchat);
        //        system.debug('Chat Product:  ' + prodchatmap + ' Chat orpc: ' + prodOrpcChatMap);
        integer cnt = 0;
        
       
        Map<Id,List<String>> parentChatVsChildAcctCode = new Map<Id,List<String>>();
        Map<Id,List<String>> parentChatVsChildAcctCodeOrd = new Map<id,List<String>>();
        //Ronak Added 
        if(Childopp == Null){
            List<invoiceit_crmx__Opportunity_Product__c> existingAddOnProducts = [Select id, name,IsAddOnFeature__c,Created_From_Opportunity_Product__c,invoiceit_crmx__Product_Code__c from invoiceit_crmx__Opportunity_Product__c where IsAddOnFeature__c=True AND invoiceit_crmx__Opportunity__c =:Oppid];
            Set<String> existingaddonChatProducts = new Set<String>();
             
            
            if(!existingAddOnProducts.isempty()){
                for(invoiceit_crmx__Opportunity_Product__c oprpc : existingAddOnProducts){
                   existingaddonChatProducts.add(oprpc.invoiceit_crmx__Product_Code__c); 
                    if(parentChatVsChildAcctCode.containsKey(oprpc.Created_From_Opportunity_Product__c)){
                        parentChatVsChildAcctCode.get(oprpc.Created_From_Opportunity_Product__c).add(oprpc.invoiceit_crmx__Product_Code__c);    
                    }else{
                        parentChatVsChildAcctCode.put(oprpc.Created_From_Opportunity_Product__c,new List<String>{oprpc.invoiceit_crmx__Product_Code__c});                
                    }   
                    System.debug('=========parentChatVsChildAcctCode=========='+parentChatVsChildAcctCode);
                }
            }
        }
        
        if(ngageUpsellOrderId!= Null){
           //invoiceit_s__Job_Product__r.Job_Rate_Plan__r[0].Job_Rate_Plan_Charge__r[0]!=Null AND
            List<invoiceit_s__Job_Product__c > existingAddOnProducts = [Select id, name,IsAddOnFeature__c,Created_From_Order_Product__c,invoiceit_s__Product_Code__c from invoiceit_s__Job_Product__c  where  IsAddOnFeature__c=True AND invoiceit_s__Job__c =:ngageUpsellOrderId];
            Set<String> existingaddonChatProducts = new Set<String>();

            if(!existingAddOnProducts.isempty()){
                for(invoiceit_s__Job_Product__c oprpc : existingAddOnProducts){
                   existingaddonChatProducts.add(oprpc.invoiceit_s__Product_Code__c); 
                    if(parentChatVsChildAcctCodeOrd.containsKey(oprpc.Created_From_Order_Product__c)){
                        parentChatVsChildAcctCodeOrd.get(oprpc.Created_From_Order_Product__c).add(oprpc.invoiceit_s__Product_Code__c);    
                    }else{
                        parentChatVsChildAcctCodeOrd.put(oprpc.Created_From_Order_Product__c,new List<String>{oprpc.invoiceit_s__Product_Code__c});                
                    }   
                    System.debug('=========parentChatVsChildAcctCodeOrd=========='+parentChatVsChildAcctCodeOrd);
                }
            }
          }
       
        
        
        System.debug('=========addonChatProducts========'+addonChatProducts);
        List<invoiceit_s__Product_Rate_Plan_Charge__c> addonchatslist = new List<invoiceit_s__Product_Rate_Plan_Charge__c>();
        for (invoiceit_s__Product_Rate_Plan_Charge__c  o : [select id, name, invoiceit_s__Accounting_Code__c, invoiceit_s__Product_Rate_Plan__r.Product_Code__c,
                                                                  invoiceit_s__Product_Rate_Plan__r.invoiceit_s__Product__r.Name
                                                                  
                                                                   from invoiceit_s__Product_Rate_Plan_Charge__c  
                                                                   where 
                                                                      invoiceit_s__Accounting_Code__c in :addonChatProducts
                                                                    ])
        {
            addonchatslist.add(o);
        }
        
        
        
        /************Akash : Forming wrapper class to show on page here ********************************************************************/
        System.debug('=====Oppid======'+Oppid);
        System.debug('========productNameList======'+productNameList);
        System.debug('========childopp======'+childopp);
        If(childopp == NULL){
                 for (invoiceit_crmx__Opportunity_Rate_Plan_Charge__c  o : [select id, name, invoiceit_crmx__Accounting_Code__c, 
                                                                       invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, 
                                                                       invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c,
                                                                       invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name, 
                                                                       invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__SequenceNumber__c,
                                                                       (select id, Attribute_Name__c, string_value__c 
                                                                          from Opportunity_Charge_Attributes__r where Attribute_Name__c = 'URL') 
                                                                       from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c  
                                                                       where invoiceit_crmx__Opportunity__c = :Oppid 
                                                                          and invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c in :productNameList
                                                                          
                                                                        // and 
                                                                       //id not in (select Chat_Product_Opp_Rate_Plan_Charge__c from Chat_Product_Opportunity_Charge__c)
                                                                       ])
            {
              
                     AttributesWrapper ow = new AttributesWrapper();
                    ow.oppAttrib = o;
                    ow.chatexists = false;
                    ow.chatcheck = false;
                    ow.createdFromOpportunityProduct = o.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c;
                    //establishing relationship between opportunity products here : akash 06/01/2018
                    
                    
                    
                    if (o.Opportunity_Charge_Attributes__r.size() > 0)
                        ow.attrib = o.Opportunity_Charge_Attributes__r[0].string_value__c;
                    system.debug(ow);
                    System.debug('======multiProdPerChatList====='+multiProdPerChatList);
                   
                    ChatProdList.add(ow);
                    prodforchat.add(o.id);  
                    System.debug('======ChatProdList======'+ChatProdList);
                    System.debug('======prodforchat======'+prodforchat);
        
            }
            
        }
        //Code for Order RPC
        if(ngageUpsellOrderId!= Null){
            for (invoiceit_s__Job_Rate_Plan_Charge__c   o : [select id, name, invoiceit_s__Accounting_Code__c, 
                                                                       invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c, invoiceit_s__Status__c,
                                                                       invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c,
                                                                       invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.name, 
                                                                       invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__SequenceNumber__c,
                                                                       (select id, Attribute_Name__c , string_value__c 
                                                                          from Order_Charge_Attributes__r where Attribute_Name__c = 'URL') 
                                                                       from invoiceit_s__Job_Rate_Plan_Charge__c   
                                                                       where invoiceit_s__Order__c  = :ngageUpsellOrderId and invoiceit_s__Status__c='Active' //and invoiceit_s__Status__c!='Cancelled'
                                                                          and invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c in :productNameList
                                                                          
                                                                        // and 
                                                                       //id not in (select Chat_Product_Opp_Rate_Plan_Charge__c from Chat_Product_Opportunity_Charge__c)
                                                                       ])
            {
              
                     AttributesWrapper ow = new AttributesWrapper();
                    ow.ordrattrib = o;
                    ow.chatexists = false;
                    ow.chatcheck = false;
                    ow.createdFromOrderProduct = o.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c;
                    //establishing relationship between opportunity products here : akash 06/01/2018
                    
                    
                    
                    if (o.Order_Charge_Attributes__r.size() > 0)
                        ow.attrib = o.Order_Charge_Attributes__r[0].string_value__c;
                    system.debug(ow);
                    System.debug('======multiProdPerChatList====='+multiProdPerChatList);
                   
                    ChatProdList.add(ow);
                    prodforchat.add(o.id);  
                    System.debug('======ChatProdList======'+ChatProdList);
                    System.debug('======prodforchat======'+prodforchat);
                    System.debug('=========ow.createdFromOrderProduct==========='+ow.createdFromOrderProduct);
            }
        }
        system.debug('@@@@addonchatslist'+addonchatslist);
        System.debug('===ChatProdList==='+ChatProdList);
        
        //adding addon charges into wrapper classes here
       
        String prodCode;
        if(childopp == Null){
            for(AttributesWrapper aw: ChatProdList){
                if(prodVsAddonProducts.containsKey(aw.oppattrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c)){
                    List<childcharges> ccList = new List<childcharges>();
                    
                    System.debug('======parentChatVsChildAcctCode======'+parentChatVsChildAcctCode);
                    System.debug('=======existing product id========'+aw.oppattrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id);
                    
                    if(parentChatVsChildAcctCode.containskey(aw.oppattrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id)){
                        List<String> addedproductCodes = parentChatVsChildAcctCode.get(aw.oppattrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id);
                        System.debug('========addedproductCodes========'+addedproductCodes);
                    
                    for(invoiceit_s__Product_Rate_Plan_Charge__c orpc : addonchatslist){
    
                      prodCode = orpc.invoiceit_s__Product_Rate_Plan__r.Product_Code__c;
                      System.debug('=======prodCode ====='+prodCode ); 
                       if(addedproductCodes.contains(prodCode)){
                           //addonchatslist.removeall(addedproductCodes);
                       }else{
                           ccList.add(new childcharges(orpc));
                       }
                    }
                    system.debug('@@@ccList'+ccList.size());
                    if(!ccList.isEmpty()){
                        aw.chatproducts = ccList;
                    }
                  }else{
                      for(invoiceit_s__Product_Rate_Plan_Charge__c orpc : addonchatslist){
                          ccList.add(new childcharges(orpc));
                      }
                      system.debug('@@@ccList'+ccList.size());
                    if(!ccList.isEmpty()){
                        aw.chatproducts = ccList;
                    }
                      
                  }
                }
                  ChatProdListFinal.add(aw);
                
            }
        }
        if(ngageUpsellOrderId!=Null){
            for(AttributesWrapper aw: ChatProdList){
                if(prodVsAddonProducts.containsKey(aw.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c)){
                    List<childcharges> ccList = new List<childcharges>();
                    
                    System.debug('======parentChatVsChildAcctCodeOrd======'+parentChatVsChildAcctCodeOrd);
                    System.debug('=======existing product id========'+aw.oppattrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id);
                    
                    if(parentChatVsChildAcctCodeOrd.containskey(aw.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Id)){
                        List<String> addedproductCodes = parentChatVsChildAcctCodeOrd.get(aw.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Id);
                        System.debug('========addedproductCodes========'+addedproductCodes);
                    
                    for(invoiceit_s__Product_Rate_Plan_Charge__c orpc : addonchatslist){
    
                      prodCode = orpc.invoiceit_s__Product_Rate_Plan__r.Product_Code__c;
                      System.debug('=======prodCode ====='+prodCode ); 
                       if(addedproductCodes.contains(prodCode)){
                           //addonchatslist.removeall(addedproductCodes);
                       }else{
                           ccList.add(new childcharges(orpc));
                       }
                    }
                    system.debug('@@@ccList'+ccList.size());
                    if(!ccList.isEmpty()){
                        aw.chatproducts = ccList;
                    }
                  }else{
                      for(invoiceit_s__Product_Rate_Plan_Charge__c orpc : addonchatslist){
                          ccList.add(new childcharges(orpc));
                      }
                      system.debug('@@@ccList'+ccList.size());
                    if(!ccList.isEmpty()){
                        aw.chatproducts = ccList;
                    }
                      
                  }
                }
                  ChatProdListFinal.add(aw);
                
            }
        }
        /*********************************************************************************************************************/
        system.debug('prodforchat---'+prodforchat + '====:::::==='+ChatProdList);
        System.debug('=========FinalChatProdList====='+ChatProdListFinal);
        
    }
    
    //wrapper class to hold the data
    public class AttributesWrapper{
        public invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppattrib{get;set;}
        //for order RPC
        public invoiceit_s__Job_Rate_Plan_Charge__c ordrattrib{get;set;}
        public Id createdFromOrderProduct{get;set;} 
        
        public Id createdFromOpportunityProduct{get;set;}  //akash
        public Boolean  chatCheck{get;set;}
        public string attrib{get;set;}
        public List<childcharges> chatproducts {get;set;} //child wrapper to hold add on chat products
        @testvisible boolean chatexists;
        public AttributesWrapper(){
            this.chatproducts = new List<childcharges>();
        }
    }
    
    //hold add on chat products data here
    public class childcharges{
         public invoiceit_s__Product_Rate_Plan_Charge__c oppattribchild{get;set;}
        public boolean childcheck{get;set;}
        public boolean isAddonFeature{get;set;}
        public childcharges(invoiceit_s__Product_Rate_Plan_Charge__c prpc){ 
            this.oppattribchild = prpc;
            this.childcheck   = false;
            this.isAddonFeature = false;
        }
    } 
    
    public Pagereference Save()
    {
        /*
        list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> oprc = new list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        set<id> prodid = new set<id>();
        for (invoiceit_crmx__Opportunity_Rate_Plan_Charge__c orpc: [select id, name, invoiceit_crmx__Accounting_Code__c, 
                                                                    invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, 
                                                                    invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c 
                                                                    from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c 
                                                                    where invoiceit_crmx__Opportunity__c = :Oppid and invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c in :productNameList]){
                                                                        
             prodid.add(orpc.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c);                                                        
         }
            
        System.debug('========prodid====='+prodid);
        op = [select id, name, Is_Chat_Option_Shown__c, invoiceit_crmx__Product__c, 
              invoiceit_crmx__Product_Code__c, invoiceit_crmx__SequenceNumber__c   
              from invoiceit_crmx__Opportunity_Product__c 
               where invoiceit_crmx__Opportunity__c = :Oppid and id in :prodid];
        System.debug('=====Opportunity Products======'+op);
        for (invoiceit_crmx__Opportunity_Product__c o:op)
        {
            if (o.Is_Chat_Option_Shown__c == null)
                o.Is_Chat_Option_Shown__c = 'No';
        }
        */
        
        List<Opportunity> childOppList = [select id, name, Discount__c, invoiceit_crmx__Number_Of_Terms__c, invoiceit_crmx__Discount_Percent__c, invoiceit_crmx__Discount_Value__c from opportunity where Parent_Opportunity__c = :oppid];
        
        if(childOppList != null && childOppList.size() > 0){
            childopp = childOppList[0];
        }else{
            //Added by Ronak
            //childopp = createChildOpp(oppid);
        }
        
        for(AttributesWrapper a : ChatProdListFinal )
        {
            system.debug('@@@@@@@a.chatcheck: ' + a.chatCheck); 
            system.debug('@@@@@@@a.chatexists: ' + a.chatexists); 
            system.debug('@@@@a child chages'+ a.chatproducts);
           
            // Test code by Ronak
            //create opportunity when anyone of selection is yes
            //if(ngageUpsellOrderId != NULL){
                //ngageChildOpp = createChildOpp(oppid);
            //}
            
            if (a.chatexists == false)
            {
                 //create opportunity when anyone of selection is yes
            if(childopp == NULL){
                //childopp = createChildOpp(oppid);
            }
                if(oppId!=Null){
                    system.debug('a.chatCheck: if' + a.chatCheck);
                    system.debug('@@@opp product referece' + a.createdFromOpportunityProduct);
                    createChatOppRPC(a);
                }
                if(ngageUpsellOrderId!=Null){
                    createFeatureOrdRPC(a);
                }
                
              /*  for (invoiceit_crmx__Opportunity_Product__c op1:op)
                {
                    if (!multiProdPerChatList.contains(a.oppAttrib.invoiceit_crmx__Accounting_Code__c) && a.oppAttrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c == op1.invoiceit_crmx__Product_Code__c)
                    {
                        if (op1.id == a.oppattrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c)
                        {
                            op1.Is_Chat_Option_Shown__c = 'Yes';
                            system.debug('Op1: ' + op1 + ' : ' + op); 
                        }
                    }
                    else
                    {                        
                        if (multiProdPerChatList.contains(a.oppAttrib.invoiceit_crmx__Accounting_Code__c) && a.oppAttrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c == op1.invoiceit_crmx__Product_Code__c)
                        {
                            op1.Is_Chat_Option_Shown__c = 'Yes';
                            system.debug('Op1: ' + op1 + ' : ' + op); 
                        }
                    }
                }*/
            }
            if (a.chatCheck == false && a.chatexists == true)
            {
                OppDeleteChat.add(prodchatmap.get(a.oppattrib.id));
                OppdeleteProd.add(a.oppattrib.id);
            }
            
        }
        system.debug('@@@Rama Opp Products: ' + Oppproduct);
        if (!OppProduct.isempty())
        {
            // inserting all opp Products here
            insert OppProduct;
            system.debug('Opp Product after insert: ' + OppProduct);
        
            createOppProductRatePlan();
            createOppProductRatePlanCharge();
     
            //establishing relationship between orpc and addonchatorpc
            //by using opportunity product and chat parent opportunity product just set above
            Map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>oppProdctIdVsCharge = new Map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
             Map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>chargeIdVschatCharge = new Map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
            if(OppId!=Null){
                for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c c:[select id,Name,invoiceit_crmx__Accounting_Code__c,
                                                                         Chat_Parent_Opportunity_Rate_Plan_Charge__c,invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Created_From_Opportunity_Product__c,
                                                                         invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c,
                                                                         invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c,
                                                                         invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Chat_Parent_Opportunity_Product__c
                                                                         From invoiceit_crmx__Opportunity_Rate_Plan_Charge__c
                                                                       where invoiceit_crmx__Opportunity__c =:OppId]){
                    if(c.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c == conversationcode ){
                        oppProdctIdVsCharge.put(c.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, c);
                        
                    }
                    else{
                        
                        chargeIdVschatCharge.put(c.id,c);
                    }
                }
                
                system.debug('@@@@oppProdctIdVsCharge'+oppProdctIdVsCharge);
                system.debug('@@@@chargeIdVschatCharge'+chargeIdVschatCharge);
                
                If(!chargeIdVschatCharge.isEmpty()){
                    for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c c1:chargeIdVschatCharge.values()){
                        //ronak
                        if(oppProdctIdVsCharge.containskey(c1.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Created_From_Opportunity_Product__c)){
                            //c1.Add_on_Chat_Parent__c = oppProdctIdVsCharge.get(c1.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Created_From_Opportunity_Product__c).id;
                           c1.Chat_Parent_Opportunity_Rate_Plan_Charge__c= oppProdctIdVsCharge.get(c1.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Created_From_Opportunity_Product__c).id;

                        //c1.Add_on_Chat_Parent__r.Id = oppProdctIdVsCharge.get(ProdIdVsCreatedFromProd.get(c1.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id));
                        }
                            
                        
                    }
                    update chargeIdVschatCharge.values();
                }
                
            } 
        }
        
        if (!OrdProduct.isempty())
        {
            // inserting all order Products here
            insert OrdProduct;
            system.debug('Ord Product after insert: ' + OrdProduct);
                    
            createOrdProductRatePlan();
            createOrdProductRatePlanCharge();
            
            Map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> ordProdctIdVsCharge = new Map<Id,invoiceit_s__Job_Rate_Plan_Charge__c>();
             Map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> ordchargeIdVschatCharge = new Map<Id,invoiceit_s__Job_Rate_Plan_Charge__c>();
            if(ngageUpsellOrderId!=Null){
                for(invoiceit_s__Job_Rate_Plan_Charge__c c:[select id,Name,invoiceit_s__Accounting_Code__c,
                                                                         invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Created_From_Order_Product__c,
                                                                         invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c,
                                                                         invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c
                                                                         From invoiceit_s__Job_Rate_Plan_Charge__c
                                                                       where invoiceit_s__Order__c =:ngageUpsellOrderId]){
                    if(c.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c == conversationcode ){
                        ordProdctIdVsCharge.put(c.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c, c);
                        
                    }
                    else{
                        
                        ordchargeIdVschatCharge.put(c.id,c);
                    }
                }
                
                system.debug('@@@@ordProdctIdVsCharge'+ordProdctIdVsCharge);
                system.debug('@@@@ordchargeIdVschatCharge'+ordchargeIdVschatCharge);
                
                If(!ordchargeIdVschatCharge.isEmpty()){
                    for(invoiceit_s__Job_Rate_Plan_Charge__c c1:ordchargeIdVschatCharge.values()){
                        //ronak
                        if(ordProdctIdVsCharge.containskey(c1.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Created_From_Order_Product__c)){
                        c1.Add_on_Chat_Product__c = ordProdctIdVsCharge.get(c1.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Created_From_Order_Product__c).id;
                        //c1.Add_on_Chat_Parent__r.Id = ordProdctIdVsCharge.get(ProdIdVsCreatedFromProd.get(c1.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id));
                        }
                    }
                    update ordchargeIdVschatCharge.values();
                }
                
            } 
            
            
        }
        system.debug('@@@Rama CPOC: ' + cpoc);
        insert cpoc;
        
        system.debug('Opp Products: ' + op); 
        update op; 
      
        if(ngageUpsellOrderId != NULL){
             return new pageReference('/'+ngageUpsellOrderId);
        }
        else{
             return new pageReference('/'+oppid);
        }
        
        
       
    }
    public Opportunity oppty{get;set;}
    
    public Opportunity createChildOpp(Id oppId){
        system.debug('oppId'+oppId);
        oppty = [select id, name,StageName,CloseDate,Account.ParentId,Account.Parent.Name ,Discount__c, invoiceit_crmx__Number_Of_Terms__c, invoiceit_crmx__Discount_Percent__c, invoiceit_crmx__Discount_Value__c from opportunity where id = :oppid]; 
        system.debug('::::--- opp.Account.ParentId ----::::'+oppty.Account.ParentId+'::::---opp name----::::'+oppty.Name+'::::---opp Term----::::'+oppty.invoiceit_crmx__Number_Of_Terms__c);
        system.debug('::::--- mngrectypeId ----::::'+mngrectypeId);
        List<Account> MNGaccountList = [select id,Name from Account where parentid =: oppty.Account.ParentId and recordtypeid =: mngrectypeId];
        if(MNGaccountList != null && MNGaccountList.size() > 0){
            MNGchildacc = MNGaccountList[0];
        }else{
            MNGchildacc = createchildMNGacc();
        }
        
        Opportunity copp = new Opportunity();
        copp.Name = 'Ngage Upsell ' + oppty.Name;
        if(ngageUpsellOrderId != NULL){
            copp.Ngage_Upsell_Order__c = ngageUpsellOrderId;
            copp.invoiceit_crmx__Number_Of_Terms__c = ngageUpsellOrder.invoiceit_s__Number_Of_Terms__c;
            copp.StageName = 'Prospecting';
            copp.IsNewNgageOppty__c = True;
            //copp.Parent_Opportunity__c = oppid;
        }
        else{
            copp.Parent_Opportunity__c = oppid;
            copp.StageName = oppty.StageName;
        }
        
        copp.AccountId = MNGchildacc.id;
        
        copp.CloseDate = oppty.CloseDate;
        insert copp;
        return copp;
    }
    public Account createchildMNGacc(){
        Account acc = new Account();
        acc.Name = oppty.Account.Parent.Name;
        acc.parentid = oppty.Account.ParentId;
        acc.recordtypeid = mngrectypeId;
        acc.Business_Unit__c = 'Martindale-Ngage'; 
        insert acc;
        return acc;
    }
    private void createChatOppRPC(AttributesWrapper a)
    {
        system.debug('CreateChat: ' + a);
        if (prodChatmap.isEmpty() && prodOrpcChatMap.isEmpty())
        {
            createOppProduct(a);
        }
        else if(prodChatmap.get(a.oppattrib.id) == null)
        {
            createOppProduct(a);  
        }
    }
    
    private void createFeatureOrdRPC(AttributesWrapper a)
    {
        system.debug('CreateChat: ' + a);
        if (prodFeatureMap.isEmpty() && prodOrpcChatMap.isEmpty())
        {
            createOrdProduct(a);
        }
        else if(prodFeatureMap.get(a.ordrattrib.id) == null)
        {
            createOrdProduct(a);  
        }
    }
    
    public void createaddonChatOppProduct(AttributesWrapper a ){
       
        for(childcharges cc : a.chatproducts){
            system.debug('@@@in child chat product creation1'+cc.childcheck);
            If(cc.childcheck == true){
                system.debug('@@@in child chat product creation'+cc);
                 invoiceit_s__Product__c c = new invoiceit_s__Product__c(); 
            c= addonchatProductstoCreate.get(cc.oppattribchild.invoiceit_s__Accounting_Code__c);
            invoiceit_crmx__Opportunity_Product__c OProd = new invoiceit_crmx__Opportunity_Product__c();
                
                if(ngageUpsellOrderId==Null){
                    Oprod.invoiceit_crmx__Opportunity__c = Oppid;
                }else{
                    Oprod.invoiceit_crmx__Opportunity__c = ngageChildOpp.Id; //childopp.id;(ronak Changed) //Oppid;
                }
            //childCheckAddOnProd.put(Oprod.Name, cc.childcheck);    
            Oprod.invoiceit_crmx__Product_Code__c = c.invoiceit_s__Product_Code__c;
            Oprod.invoiceit_crmx__Product__c = c.id;
            Oprod.isAddonFeature__c = True;
            oprod.Created_From_Opportunity_Product__c = a.createdFromOpportunityProduct;
            seqno++;
            Oprod.invoiceit_crmx__SequenceNumber__c = seqno;
            Oprod.invoiceit_crmx__Product_Family__c = c.invoiceit_s__Product_Family__c;
            Oprod.name = c.Name + ' - ' + a.oppattrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name ;
            //            if (a.oppattrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name != 'Professional Profile')
            //              Oprod.name = Oprod.name + ' : ' + a.oppattrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__SequenceNumber__c;
            
            OppProduct.add(Oprod);
            }
            
        }
        
    }
    
    public void createaddonFeatureOrdProduct(AttributesWrapper a ){
       
        for(childcharges cc : a.chatproducts){
            system.debug('@@@in child chat product creation1'+cc.childcheck);
            If(cc.childcheck == true){
                system.debug('@@@in child chat product creation'+cc);
                 invoiceit_s__Product__c c = new invoiceit_s__Product__c(); 
            c= addonchatProductstoCreate.get(cc.oppattribchild.invoiceit_s__Accounting_Code__c);
            invoiceit_s__Job_Product__c OProd = new invoiceit_s__Job_Product__c();
                
                if(ngageUpsellOrderId!=Null)
                    Oprod.invoiceit_s__Job__c  = ngageUpsellOrderId;
                
            //childCheckAddOnProd.put(Oprod.Name, cc.childcheck);    
            Oprod.invoiceit_s__Product_Code__c  = c.invoiceit_s__Product_Code__c;
            Oprod.invoiceit_s__Product__c  = c.id;
            Oprod.isAddonFeature__c = True;
            oprod.Created_From_Order_Product__c  = a.createdFromOrderProduct;
            seqno++;
            Oprod.invoiceit_s__SequenceNumber__c  = seqno;
            Oprod.invoiceit_s__Product_Family__c  = c.invoiceit_s__Product_Family__c;//ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c
            Oprod.name = c.Name + ' - ' + a.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.name ;
            //            if (a.oppattrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name != 'Professional Profile')
            //              Oprod.name = Oprod.name + ' : ' + a.oppattrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__SequenceNumber__c;
            
            OrdProduct.add(Oprod);
            }
            
        }
        
    }
    
    public void createOppProduct(AttributesWrapper a) {
        

        system.debug('ChatProduct: ' + chatProduct);
        map<string, invoiceit_crmx__Opportunity_Product__c> mapoppProd = new map<string, invoiceit_crmx__Opportunity_Product__c>();
        for (id i :chatProduct.keyset())
        {
            invoiceit_s__Product__c c = new invoiceit_s__Product__c(); 
            c= chatProduct.get(i);
            invoiceit_crmx__Opportunity_Product__c OProd = new invoiceit_crmx__Opportunity_Product__c();
            Oprod.invoiceit_crmx__Opportunity__c = Oppid; //childopp.id; (ronak changed)//Oppid;
            Oprod.invoiceit_crmx__Product_Code__c = c.invoiceit_s__Product_Code__c;
            Oprod.invoiceit_crmx__Product__c = c.id;
            oprod.Created_From_Opportunity_Product__c = a.createdFromOpportunityProduct;
            seqno++;
            Oprod.invoiceit_crmx__SequenceNumber__c = seqno;
            Oprod.invoiceit_crmx__Product_Family__c = c.invoiceit_s__Product_Family__c;
            Oprod.name = c.Name + ' - ' + a.oppattrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name ;
            //            if (a.oppattrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name != 'Professional Profile')
            //              Oprod.name = Oprod.name + ' : ' + a.oppattrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__SequenceNumber__c;
            //OppProduct.add(Oprod);
            system.debug('CreateOppProduct: ' + oppProduct + ' : ' + oppProduct.size());
        }
        
        if(a.chatproducts.size() > 0){
           createaddonChatOppProduct(a);       
        }
    }
    
    public void createOrdProduct(AttributesWrapper a) {
        

        system.debug('ChatProduct: ' + chatProduct);
        map<string, invoiceit_s__Job_Product__c> mapoppProd = new map<string, invoiceit_s__Job_Product__c>();
        for (id i :chatProduct.keyset())
        {
            invoiceit_s__Product__c c = new invoiceit_s__Product__c(); 
            c= chatProduct.get(i);
            invoiceit_s__Job_Product__c OProd = new invoiceit_s__Job_Product__c();
            Oprod.invoiceit_s__Job__c  = ngageUpsellOrderId; //childopp.id; (ronak changed)//Oppid;
            Oprod.invoiceit_s__Product_Code__c  = c.invoiceit_s__Product_Code__c;
            Oprod.invoiceit_s__Product__c  = c.id;
            oprod.Created_From_Order_Product__c  = a.createdFromOrderProduct;
            seqno++;
            Oprod.invoiceit_s__SequenceNumber__c  = seqno;
            Oprod.invoiceit_s__Product_Family__c  = c.invoiceit_s__Product_Family__c;//ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c
            Oprod.name = c.Name + ' - ' + a.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.name ;
            //            if (a.oppattrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name != 'Professional Profile')
            //              Oprod.name = Oprod.name + ' : ' + a.oppattrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__SequenceNumber__c;
            //OrdProduct.add(Oprod);
            system.debug('createOrdProduct: ' + OrdProduct + ' : ' + OrdProduct.size());
        }
        
        if(a.chatproducts.size() > 0){
           createaddonFeatureOrdProduct(a);       
        }
    }
    
    public void createOppProductRatePlan() {
        if (oppProduct.isEmpty()) return;
        list<id> prp = new list<id>();
        
        for(invoiceit_crmx__Opportunity_Product__c o : OppProduct)
        {   
            // invoiceit_crmx__Opportunity_Rate_Plan__c OppRP = new invoiceit_crmx__Opportunity_Rate_Plan__c();
            //         for (invoiceit_s__Product__c c:chatProduct) {
            system.debug('@@@@oppProduct'+o);
             invoiceit_s__Product__c c; 
            if(addonChatProducts.contains(o.invoiceit_crmx__Product_Code__c)){
                 c = addonchatProductstoCreate.get(o.invoiceit_crmx__Product_Code__c);
            }
            else{
                 c = chatProduct.get(o.invoiceit_crmx__Product__c);//(changed by ronak)
            }
            system.debug('@@@@@c'+c);
            for (invoiceit_s__Product_Rate_Plan__c a:c.invoiceit_s__ProductRatePlan__r)
            {
                system.debug('@@@@@a product code'+ a.Product_Code__c);
                system.debug('@@@@@a conversationcode'+ conversationcode);
                system.debug('@@@@@a Name'+ a.Name);
                if((a.Product_Code__c == conversationcode && a.Name == 'Standard Chat USD - Usage Price') || (o.invoiceit_crmx__Product_Code__c != conversationcode)){
                     invoiceit_crmx__Opportunity_Rate_Plan__c OppRP = new invoiceit_crmx__Opportunity_Rate_Plan__c();
                OppRp.name = a.name;
                OppRp.invoiceit_crmx__Product_Rate_Plan__c = a.id;
                oppRp.invoiceit_crmx__SequenceNumber__c = o.invoiceit_crmx__SequenceNumber__c;
                prp.add(a.id);
                OppRp.invoiceit_crmx__Opportunity_Product__c = o.id;
                OppProductRatePlan.add(OppRp);
                }
               
            }
            //           }
            
        }
        for (invoiceit_s__Product_Rate_Plan_Charge__c p:[select id, name, invoiceit_s__Accounting_Code__c, 
                                                            invoiceit_s__Product_Charge_Category__c, invoiceit_s__Product_Rate_Plan__c, 
                                                             invoiceit_s__Price_Format__c, invoiceit_s__Is_Product_Editable__c, 
                                                             invoiceit_s__CurrencyL__c, invoiceit_s__Default_Quantity__c, 
                                                            invoiceit_s__Charge_Sequence_Number__c,  invoiceit_s__Price_Type__c, 
                                                              invoiceit_s__Cost_Price__c, invoiceit_s__Unit_Price__c 
                                                             from invoiceit_s__Product_Rate_Plan_Charge__c 
                                                             where invoiceit_s__Product_Rate_Plan__c in :prp])
                                                            // where invoiceit_s__Product_Rate_Plan__c = 'a0T2F000000pr2O'])
            prodrpc.put(p.invoiceit_s__Product_Rate_Plan__c, p);
        system.debug('@@@Rama ProdRPC: ' + prodrpc + ' Opp Product Rate Plan: ' + OppProductRatePlan);
        insert OppProductRatePlan;
        
    }
    
    public void createOrdProductRatePlan() {
        if (OrdProduct.isEmpty()) return;
        list<id> prp = new list<id>();
        
        for(invoiceit_s__Job_Product__c o : OrdProduct)
        {   
            // invoiceit_crmx__Opportunity_Rate_Plan__c OppRP = new invoiceit_crmx__Opportunity_Rate_Plan__c();
            //         for (invoiceit_s__Product__c c:chatProduct) {
            system.debug('@@@@oppProduct'+o);
             invoiceit_s__Product__c c; 
            if(addonChatProducts.contains(o.invoiceit_s__Product_Code__c )){
                 c = addonchatProductstoCreate.get(o.invoiceit_s__Product_Code__c );
            }
            else{
                 c = chatProduct.get(o.invoiceit_s__Product__c );//(changed by ronak)
            }
            system.debug('@@@@@c'+c);
            for (invoiceit_s__Product_Rate_Plan__c a:c.invoiceit_s__ProductRatePlan__r)
            {
                system.debug('@@@@@a product code'+ a.Product_Code__c);
                system.debug('@@@@@a conversationcode'+ conversationcode);
                system.debug('@@@@@a Name'+ a.Name);
                if((a.Product_Code__c == conversationcode && a.Name == 'Standard Chat USD - Usage Price') || (o.invoiceit_s__Product_Code__c != conversationcode)){
                     invoiceit_s__Job_Rate_Plan__c  OppRP = new invoiceit_s__Job_Rate_Plan__c();
                OppRp.name = a.name;
                OppRp.invoiceit_s__Product_Rate_Plan__c  = a.id;
                oppRp.invoiceit_s__SequenceNumber__c   = o.invoiceit_s__SequenceNumber__c ;
                prp.add(a.id);
                OppRp.invoiceit_s__Job_Product__c = o.id;
                OrdProductRatePlan.add(OppRp);
                }
               
            }
            //           }
            
        }
        for (invoiceit_s__Product_Rate_Plan_Charge__c p:[select id, name, invoiceit_s__Accounting_Code__c, 
                                                            invoiceit_s__Product_Charge_Category__c, invoiceit_s__Product_Rate_Plan__c, 
                                                             invoiceit_s__Price_Format__c, invoiceit_s__Is_Product_Editable__c, 
                                                             invoiceit_s__CurrencyL__c, invoiceit_s__Default_Quantity__c, 
                                                            invoiceit_s__Charge_Sequence_Number__c,  invoiceit_s__Price_Type__c, 
                                                              invoiceit_s__Cost_Price__c, invoiceit_s__Unit_Price__c 
                                                             from invoiceit_s__Product_Rate_Plan_Charge__c 
                                                             where invoiceit_s__Product_Rate_Plan__c in :prp])
                                                            // where invoiceit_s__Product_Rate_Plan__c = 'a0T2F000000pr2O'])
            prodrpc.put(p.invoiceit_s__Product_Rate_Plan__c, p);
        system.debug('@@@Rama ProdRPC: ' + prodrpc + ' Ord Product Rate Plan: ' + OrdProductRatePlan);
        insert OrdProductRatePlan;
        
    }
    
    public void createOppProductRatePlanCharge() {
        
        if (OppProductRatePlan.isEmpty()) return;
        for(invoiceit_crmx__Opportunity_Rate_Plan__c o:OppProductRatePlan )
        {
            invoiceit_s__Product_Rate_Plan_Charge__c a = new invoiceit_s__Product_Rate_Plan_Charge__c();
            a = prodrpc.get(o.invoiceit_crmx__Product_Rate_Plan__c);
            invoiceit_crmx__Opportunity_Rate_Plan_Charge__c OpRPC = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(); 
            OpRPC.name = a.name;
            OpRPC.invoiceit_crmx__Opportunity__c = Oppid; //childopp.id; (changed by Ronak)//Oppid;
            opRPC.Quote_Type__c = 'New'; //OppProduct[0].invoiceit_crmx__Opportunity__r.quote_type__c;
            OpRPC.invoiceit_crmx__Accounting_Code__c = a.invoiceit_s__Accounting_Code__c;
            opRPC.invoiceit_crmx__Opportunity_Rate_Plan__c = o.id;
            opRPC.invoiceit_crmx__Price_Type__c = a.invoiceit_s__Price_Type__c;
            opRPC.invoiceit_crmx__Unit_Price__c = a.invoiceit_s__Unit_Price__c;
            opRPC.invoiceit_crmx__CurrencyL__c = a.invoiceit_s__CurrencyL__c;
            opRPC.invoiceit_crmx__Is_Product_Editable__c = a.invoiceit_s__Is_Product_Editable__c;
            opRPC.IsAddOnFeature__c = TRUE;
            if (a.invoiceit_s__Default_Quantity__c == null)
                a.invoiceit_s__Default_Quantity__c = 0;
            if (a.invoiceit_s__Unit_Price__c == null)
                a.invoiceit_s__Unit_Price__c = 0;            
            system.debug('a: ' + a.invoiceit_s__Unit_Price__c + ' default: ' + a.invoiceit_s__Default_Quantity__c);
            opRPC.invoiceit_crmx__Price__c = a.invoiceit_s__Unit_Price__c * a.invoiceit_s__Default_Quantity__c;
            opRPC.invoiceit_crmx__Price_Format__c = a.invoiceit_s__Price_Format__c;
            opRPC.invoiceit_crmx__Net_Total__c = a.invoiceit_s__Unit_Price__c * a.invoiceit_s__Default_Quantity__c;
            opRPC.invoiceit_crmx__Discount_Percent__c = opp.invoiceit_crmx__Discount_Percent__c;
            opRPC.invoiceit_crmx__Product_Charge_Category__c = a.invoiceit_s__Product_Charge_Category__c;
            opRPC.invoiceit_crmx__Product_Rate_Plan_Charge__c = a.id;
            opRPC.invoiceit_crmx__Sequence_No__c = a.invoiceit_s__Charge_Sequence_Number__c;
            system.debug('a: ' + a.invoiceit_s__Unit_Price__c + ' default: ' + a.invoiceit_s__Default_Quantity__c + ' seq no: ' + a.invoiceit_s__Charge_Sequence_Number__c);
            opRPC.invoiceit_crmx__Quantity__c = a.invoiceit_s__Default_Quantity__c;
            opRPC.invoiceit_crmx__Tax__c = 0;
            //                opRPC.nvoiceit_crmx__Cost_Price__c = 0.0;
            //                opRPC.nvoiceit_crmx__Cost__c = 0.0;
            opRPC.invoiceit_crmx__Tax_Percentage__c = 0;
            opRPC.invoiceit_crmx__Discount_Type__c = 'By Percentage';
            opRPC.Terms_Months__c   = opp.invoiceit_crmx__Number_Of_Terms__c;
            OppProductRatePlanCharge.add(opRPC);
        }
        system.debug('@@@@Rama Opp Charges: ' + OppProductRatePlanCharge );
        if (!OppProductRatePlanCharge.isEmpty())
            insert OppProductRatePlanCharge;  
        
        for (invoiceit_crmx__Opportunity_Rate_Plan_Charge__c o:OppProductRatePlanCharge)
            newchatlist.add(o.id);
        
        system.debug('New chat List: ' + newchatlist);
        //        chatusagelist = [select id, name, invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c where  invoiceit_crmx__Opportunity__c = :Oppid and invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product__r.name in ('Site Activation fee', 'Per Conversation fee')];
        chatusagelist = [select id, name, invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c where  invoiceit_crmx__Opportunity__c = :Oppid and invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c = :conversationcode];
    }
    
    public void createOrdProductRatePlanCharge() {
        
        if (OrdProductRatePlan.isEmpty()) return;
        for(invoiceit_s__Job_Rate_Plan__c  o:OrdProductRatePlan )
        {
            invoiceit_s__Product_Rate_Plan_Charge__c a = new invoiceit_s__Product_Rate_Plan_Charge__c();
            a = prodrpc.get(o.invoiceit_s__Product_Rate_Plan__c );
            invoiceit_s__Job_Rate_Plan_Charge__c  OpRPC = new invoiceit_s__Job_Rate_Plan_Charge__c (); 
            OpRPC.name = a.name;
            OpRPC.invoiceit_s__Order__c  = ngageUpsellOrderId; //childopp.id; (changed by Ronak)//Oppid;
            opRPC.Quote_Type__c  = 'New'; //OppProduct[0].invoiceit_crmx__Opportunity__r.quote_type__c;
            OpRPC.invoiceit_s__Accounting_Code__c  = a.invoiceit_s__Accounting_Code__c;
            opRPC.invoiceit_s__Job_Rate_Plan__c  = o.id;
            opRPC.invoiceit_s__Price_Type__c  = a.invoiceit_s__Price_Type__c;
            opRPC.invoiceit_s__Unit_Price__c  = a.invoiceit_s__Unit_Price__c;
            opRPC.invoiceit_s__CurrencyL__c  = a.invoiceit_s__CurrencyL__c;
            opRPC.invoiceit_s__Is_Product_Editable__c  = a.invoiceit_s__Is_Product_Editable__c;
            //opRPC.IsAddOnFeature__c = TRUE;
            if (a.invoiceit_s__Default_Quantity__c == null)
                a.invoiceit_s__Default_Quantity__c = 0;
            if (a.invoiceit_s__Unit_Price__c == null)
                a.invoiceit_s__Unit_Price__c = 0;            
            system.debug('a: ' + a.invoiceit_s__Unit_Price__c + ' default: ' + a.invoiceit_s__Default_Quantity__c);
            opRPC.invoiceit_s__Price__c  = a.invoiceit_s__Unit_Price__c * a.invoiceit_s__Default_Quantity__c;
            opRPC.invoiceit_s__Price_Format__c  = a.invoiceit_s__Price_Format__c;
            opRPC.invoiceit_s__Net_Total__c  = a.invoiceit_s__Unit_Price__c * a.invoiceit_s__Default_Quantity__c;
            opRPC.invoiceit_s__Discount_Percent__c  = opp.invoiceit_crmx__Discount_Percent__c;
            opRPC.invoiceit_s__Product_Charge_Category__c  = a.invoiceit_s__Product_Charge_Category__c;
            opRPC.invoiceit_s__Product_Rate_Plan_Charge__c  = a.id;
            opRPC.invoiceit_s__Sequence_No__c  = a.invoiceit_s__Charge_Sequence_Number__c;
            //system.debug('a: ' + a.invoiceit_s__Unit_Price__c + ' default: ' + a.invoiceit_s__Default_Quantity__c + ' seq no: ' + a.invoiceit_s__Charge_Sequence_Number__c);
            opRPC.invoiceit_s__Quantity__c  = a.invoiceit_s__Default_Quantity__c;
            opRPC.invoiceit_s__Tax__c  = 0;
            //                opRPC.nvoiceit_crmx__Cost_Price__c = 0.0;
            //                opRPC.nvoiceit_crmx__Cost__c = 0.0;
            opRPC.invoiceit_s__Tax_Percentage__c  = 0;
            opRPC.invoiceit_s__Discount_Type__c  = 'By Percentage';
            opRPC.Terms_Months__c    = opp.invoiceit_crmx__Number_Of_Terms__c;
            OrdProductRatePlanCharge.add(opRPC);
        }
        system.debug('@@@@Rama Ord Charges: ' + OrdProductRatePlanCharge );
        if (!OrdProductRatePlanCharge.isEmpty())
            insert OrdProductRatePlanCharge;  
        
        for (invoiceit_crmx__Opportunity_Rate_Plan_Charge__c o:OppProductRatePlanCharge)
            newchatlist.add(o.id);
        
        system.debug('New chat List: ' + newchatlist);
        //        chatusagelist = [select id, name, invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c where  invoiceit_crmx__Opportunity__c = :Oppid and invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product__r.name in ('Site Activation fee', 'Per Conversation fee')];
        chatusagelist = [select id, name, invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c where  invoiceit_crmx__Opportunity__c = :Oppid and invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c = :conversationcode];
    }
    public Pagereference Cancel()
    {   
        Pagereference pag =new Pagereference('/'+cancelId);
        return pag;  
    }
}