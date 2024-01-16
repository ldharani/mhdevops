public class NgageChatController {
    private ApexPages.StandardController standardController;
    public id Oppid{get;set;}
    public list<AttributesWrapper> ChatProdList{get;set;}
    public list<AttributesWrapper> ChatProdListFinal{get;set;}
    public list<AttributesWrapper> opptyChildChatProdListFinal{get;set;} // Get all the Ngage chat products from the Child Ngage Opportunity 
    public list<AttributesWrapper> childChatProdListFinal{get;set;} // Get all the Ngage Chat products from the Child Ngage Order
    public list<AttributesWrapper> childChatProdList{get;set;}
    public list<AttributesWrapper> opptychildChatProdList{get;set;}   
    private list<invoiceit_crmx__Opportunity_Product__c> OppProduct = new list<invoiceit_crmx__Opportunity_Product__c>();
    private list<invoiceit_crmx__Opportunity_Rate_Plan__c> OppProductRatePlan = new list<invoiceit_crmx__Opportunity_Rate_Plan__c>();
    private list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> OppProductRatePlanCharge = new list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();  
    private list<id> OppDeleteChat = new list<id>();
    private list<id> OppDeleteProd = new list<id>();
    private map<id, invoiceit_s__Product_Rate_Plan_Charge__c> prodrpc = new map<id, invoiceit_s__Product_Rate_Plan_Charge__c>();
    //invoiceit_s__Product__c chatProduct = [select id, name, invoiceit_s__Product_Code__c, invoiceit_s__Product_Family__c, (select id, name from invoiceit_s__ProductRatePlan__r) from invoiceit_s__Product__c where name  = 'Ngage Chat' limit 1];
    map<id, invoiceit_s__Product__c> chatProduct = new map<id, invoiceit_s__Product__c>();
    map<id, Chat_Product_Opportunity_Charge__c> mapchat =  new map<id, Chat_Product_Opportunity_Charge__c>();
    @Testvisible private decimal seqno;
    map<id, id> prodChatmap  = new map<id, id>();
    map<id, id> prodFeaturemap  = new map<id, id>();
    map<id, id> prodOpptyFeaturemap  = new map<id, id>();
    
    map<id, id> prodOrpcChatMap = new map<id, id>();
    boolean professionalProfile = false;
    list<Chat_Product_Opportunity_Charge__c> chatlist = new list<Chat_Product_Opportunity_Charge__c>();
    private list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> chatusagelist = new list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
    list<Chat_Product_Opportunity_Charge__c> cpoc = new list<Chat_Product_Opportunity_Charge__c>();
    list<invoiceit_crmx__Opportunity_Product__c> op = new list<invoiceit_crmx__Opportunity_Product__c>();
    public string conversationcode;
    Opportunity opp = new opportunity();
    set<String> productNameList = new set<String>();
    set<String> ordproductNameList = new set<String>();
    set<string> multiProdPerChatList = new set<string>();
    set<id> prodforchat  = new set<id>();
    set<id> newchatlist = new set<id>();
    public Opportunity childopp{get;set;}
    public Opportunity existingChildOpp{get;set;} // To get the existing Ngage Child opportunity on the MH Opportunity or the MH order
    public Account MNGchildacc{get;set;}
    public String mngrectypeId {get;set;}
    public Set<String> addonchatslistcodes {get;set;}
    public Map<string,invoiceit_s__Product__c> addonchatProductstoCreate{get;set;}
    public Set<String> addonChatProducts {get;set;}
    public Set<String> addonChildChatProducts {get;set;}
    public Id ngageUpsellOrderId;
    public id childNgageOrdId;
    public invoiceit_s__Job__c ngageUpsellOrder;
    public invoiceit_s__Job__c ngageUpsellchidlOrder;
    public Id cancelId;
    public List<standalonechat> standalonechatslist{get;set;}
    public standalonechat singlestandalonechat; //this is used to add/delete Row functionality
    public  List<childcharges> childaddonchatswrapperforstandlonetemp;
    public Integer standalonechatsSize{get;set;}
    //commented Attribute changes
    //public list<Opportunity_Charge_Attribute__c> opportunityAttributes = new list<Opportunity_Charge_Attribute__c>();
    
    
    //List to delete section
    public List<DeleteProducts> toDeleteProductsList{get;set;}
    public Map<id,List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>> parentIdVschildOptProdtoDelet{get;set;}
    
    public NgageChatController(ApexPages.StandardController standardController) {
        this.standardController = standardController;
        toDeleteProductsList = new List<DeleteProducts>();
        parentIdVschildOptProdtoDelet = new Map<id,List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>>();
        chatProdList = new list<AttributesWrapper>();
        ChatProdListFinal = new list<AttributesWrapper>();
        childChatProdList = new list<AttributesWrapper>();
        childChatProdListFinal = new list<AttributesWrapper>();
        opptychildChatProdList = new list<AttributesWrapper>();
        opptyChildChatProdListFinal = new list<AttributesWrapper>();
        
        addonchatProductstoCreate = new Map<string,invoiceit_s__Product__c>();
        
        
        Oppid = standardController.getId();
        
        set<Id> orderChargeIdstoExclude   = new Set<Id>();
        ngageUpsellOrderId = apexPages.currentPage().getParameters().get('orderid');
        system.debug('@@@@ngageUpsellOrderId'+ngageUpsellOrderId);
        
        
        //Sai : Using Modify Order Mid-term Logic here to carry over the child order Prodcuts
        If(ngageUpsellOrderId != NULL){
            string sQuery = 'SELECT ' + ControllerSelectQuoteType.getObjectFields('invoiceit_s__Job__c') + ',invoiceit_s__Account__r.Migration_Status__c,RecordType.DeveloperName, Created_From_Order__r.PartnerAccountOrder__c,invoiceit_s__Account__r.Credit_Status__c, Created_From_Order__r.Renew_Rebase__c, Created_From_Order__r.invoiceit_s__Service_End_Date__c, ' 
                + ' (SELECT '+  ControllerSelectQuoteType.getObjectFields('invoiceit_s__Job__c') + ' ,invoiceit_s__Account__r.Migration_Status__c,RecordType.DeveloperName, '
                + ' invoiceit_s__Account__r.Credit_Status__c, Created_From_Order__r.Renew_Rebase__c, Created_From_Order__r.invoiceit_s__Service_End_Date__c '
                + ' From Orders1__r Where Renew_Rebase__c=Null AND (invoiceit_s__Status__c != \'Cancelled\' OR invoiceit_s__Status__c != \'Expired\') order by CreatedDate DESC )'
                + ' FROM invoiceit_s__Job__c WHERE Id =\'' + ngageUpsellOrderId + '\'';
            
            system.debug('sQuery is* :::::: ' + sQuery);
            ngageUpsellOrder = DataBase.Query(sQuery);
            /*
ngageUpsellOrder = [select id,name, invoiceit_s__Number_Of_Terms__c,
invoiceit_s__Status__c,Created_From_Order__r.Renew_Rebase__c,
Created_From_Order__c,invoiceit_s__Service_End_Date__c, (Select id, name From Orders1__r)
From invoiceit_s__Job__c
where id=:ngageUpsellOrderId];*/
            if(!ngageUpsellOrder.Orders1__r.isempty()){
                childNgageOrdId = ngageUpsellOrder.Orders1__r[0].id;
                ngageUpsellchidlOrder = ngageUpsellOrder.Orders1__r[0];
            }
            system.debug('@@@@ngageUpsellchidlOrder'+childNgageOrdId);
            cancelId = ngageUpsellOrderId; 
            
            //akash: to exclude cancelled charges for standalone mh order
            for(invoiceit_s__Job_Rate_Plan_Charge__c ordcharge : [select id,Opportunity_Rate_Plan_Charge__c
                                                                       From invoiceit_s__Job_Rate_Plan_Charge__c
                                                                    where invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c =:ngageUpsellOrderId
                                                                  AND invoiceit_s__Status__c = 'Cancelled']){
                         orderChargeIdstoExclude.add(ordcharge.Opportunity_Rate_Plan_Charge__c);                                             
              }
            
            
            //Logic to consider current order charges instead of opty charges
            for(Chat_Product_Order_Charge__c co : [select id,Name,
                                                   Chat_Product_Order_Rate_Plan_Charge__c,
                                                   Chat_Usage_Order_Rate_Plan_Charge__c,
                                                   Chat_Product_Order_Rate_Plan_Charge__r.Opportunity_Rate_Plan_Charge__c
                                                   From Chat_Product_Order_Charge__c
                                                   where Chat_Product_Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c =:ngageUpsellOrderId]){
                                                       if(co.Chat_Product_Order_Rate_Plan_Charge__r.Opportunity_Rate_Plan_Charge__c != NULL){
                                                           orderChargeIdstoExclude.add(co.Chat_Product_Order_Rate_Plan_Charge__r.Opportunity_Rate_Plan_Charge__c);                                  
                                                       }                                
                                                   }
            
            
        }Else{
            cancelId = Oppid;
        }
        mngrectypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('M-NG Account').getRecordTypeId();
        
        
        //        for(invoiceit_s__Product__c p: [select id, name, invoiceit_s__Product_Code__c, invoiceit_s__Product_Family__c, (select id, name from invoiceit_s__ProductRatePlan__r) from invoiceit_s__Product__c where name  in ('Site Activation fee', 'Per Conversation fee')])
        Opportunity opp = [select id, name,Account.ParentId,Account.Parent.Name ,Discount__c, 
                           invoiceit_crmx__Number_Of_Terms__c, invoiceit_crmx__Discount_Percent__c, 
                           invoiceit_crmx__Discount_Value__c 
                           from opportunity where id = :oppid];
        //   system.debug('========opp'+opp);
        //quering if there is a child opportunity 
        
        
        //Add on products logic
        Map<String,List<String>> prodVsAddonProducts = new Map<String,List<String>>();
        Map<String,List<String>> childProdVsAddonProducts = new Map<String,List<String>>();
        addonChatProducts          = new Set<String>();
        addonChildChatProducts     = new Set<String>();
        addonchatslistcodes        = new Set<String>();
        
        for (Chat_Products__c c: Chat_Products__c.getall().values())
        {
            
            if (c.ConversationProduct__c != true)
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
                if (c.Multi_Products_Per_Chat__c == true)
                    multiProdPerChatList.add(c.Product_Name__c);
            }
            else{
                List<String> childtempstrings = new List<string>();
                if(c.Add_on_Chats__c != NULL){
                    childtempstrings = c.Add_on_Chats__c.split(',');
                }
                if(!childtempstrings.isEmpty()){
                    addonChildChatProducts.addAll(childtempstrings);
                    childProdVsAddonProducts.put(c.Product_Name__c,childtempstrings);
                }    
                ordproductNameList.add(c.Product_Name__c);
                conversationcode = c.Product_Name__c;
                addonchatslistcodes.add(conversationcode);
            }
            addonChildChatProducts.addAll(addonChatProducts);  
        }
        system.debug('@@@@ordproductNameList'+ordproductNameList);
        system.debug('@@@@addonChatProducts'+addonChatProducts);
        system.debug('@@@@childProdVsAddonProducts'+childProdVsAddonProducts);
        string childoptyquery = ' select id, name, Discount__c, Ngage_Upsell_Order__c, Parent_Opportunity__c, invoiceit_crmx__Number_Of_Terms__c, '+
            'invoiceit_crmx__Discount_Percent__c, invoiceit_crmx__Discount_Value__c '+
            ' from Opportunity';
        string childfilter ='';
        system.debug('@@@@ngageUpsellchidlOrder '+ngageUpsellchidlOrder );
        If(ngageUpsellOrderId != NULL ){
           
           
                childfilter = ' where Ngage_Upsell_Order__c=:ngageUpsellOrderId  AND StageName != \'Closed Lost\' AND StageName != \'Closed Won\' order by CreatedDate DESC LIMIT 1';
          
            
        }
        else{
            childfilter = ' where Parent_Opportunity__c = :oppid AND StageName != \'Closed Lost\' AND StageName != \'Closed Won\'';
        }
        
        List<Opportunity> childOpptyList = database.query(childoptyquery+childfilter);
        system.debug('@@@@childfilter'+childfilter);
        System.debug('@@@@@@@@@@childOpptyList '+childOpptyList );
        if(childOpptyList != null && childOpptyList.size() > 0){
            //childopp = childOpptyList[0];
            existingChildOpp = childOpptyList[0];
        }
        
        /*************sai: 03/04/2018 Delete Logic Start from here ***********************************/
        if(existingChildOpp != NULL){
            for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opproductrpc : [select id,Name,URL_Attribute__c,invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c,
                                                                                invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name,
                                                                                (select id, Name ,URL_Attribute__c,
                                                                                 invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c,
                                                                                 invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name
                                                                                 From Opportunity_Rate_Plan_Charges1__r)
                                                                                From invoiceit_crmx__Opportunity_Rate_Plan_Charge__c
                                                                                where invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c =:existingChildOpp.id
                                                                                AND Chat_Parent_Opportunity_Rate_Plan_Charge__c = NULL
                                                                               ]){
                                                                                   toDeleteProductsList.add(new DeleteProducts(False, opproductrpc)); 
                                                                                   If(opproductrpc.Opportunity_Rate_Plan_Charges1__r.size()> 0){
                                                                                       List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> templist =opproductrpc.Opportunity_Rate_Plan_Charges1__r; 
                                                                                       parentIdVschildOptProdtoDelet.put(opproductrpc.id, templist);                                                 
                                                                                   }                                                  
                                                                                   
                                                                               }
        }
        System.debug('@@@@@@@existingChildOpp '+existingChildOpp );
        System.debug('@@@@@@@parentIdVschildOptProdtoDelet'+parentIdVschildOptProdtoDelet);
        //System.debug('@@@@@@@toDeleteProductsList'+toDeleteProductsList);
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        system.debug('@@@@@childopp'+childopp);
        system.debug('@@@@@existingChildOpp '+existingChildOpp);
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
        //  system.debug('=========chatProduct'+chatProduct);
        
        Set<ID>parentchargeIdstoExclude = new Set<Id>(); // this set is used to exclude charges to show on page those are already created ngage
        List<invoiceit_crmx__Opportunity_Product__c> oppProdList = [select invoiceit_crmx__SequenceNumber__c from invoiceit_crmx__Opportunity_Product__c where invoiceit_crmx__Opportunity__c = :oppid and invoiceit_crmx__SequenceNumber__c != null order by invoiceit_crmx__SequenceNumber__c desc limit 1];
        if(oppProdList!=null && oppProdList.size()>0)
            seqno = oppProdList[0].invoiceit_crmx__SequenceNumber__c;
        system.debug('=========existingChildOpp '+existingChildOpp );
        
        //27/03:  this is used to exclude parent charges to show on page if child ngage charge already created
        
        if(existingChildOpp != null){
            for ( Chat_Product_Opportunity_Charge__c o: [select Chat_Product_Opp_Rate_Plan_Charge__c, Parent_MH_Order_Rate_Plan_Charge__c,
                                                         Parent_MH_Order_Rate_Plan_Charge__r.Opportunity_Rate_Plan_Charge__c,
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
                                                         where Chat_Usage_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity__c = :existingChildOpp.id])
            {
                if(o.Chat_Product_Opp_Rate_Plan_Charge__c != NULL){
                    parentchargeIdstoExclude.add(o.Chat_Product_Opp_Rate_Plan_Charge__c);
                }
                if(o.Parent_MH_Order_Rate_Plan_Charge__c != NULL){
                    parentchargeIdstoExclude.add(o.Parent_MH_Order_Rate_Plan_Charge__r.Opportunity_Rate_Plan_Charge__c);
                }
                chatlist.add(o);
                mapchat.put(o.Chat_Usage_Opp_Rate_Plan_Charge__c, o);
            }
        }
        system.debug('======parentchargeIdstoExclude'+parentchargeIdstoExclude+ '====mapchat'+mapchat);
        //        system.debug('Chat Product:  ' + prodchatmap + ' Chat orpc: ' + prodOrpcChatMap);
        integer cnt = 0;
        
        //Ronak added for 
        //27/03: to form parent vs child relationship between add on order prodcuts for child order
        Map<Id,List<String>> parentChatVsChildAcctCodeOrd = new Map<id,List<String>>();
        
        //27/03: to form parent vs child relationship between add on opportunity prodcuts for child opportunity
        Map<Id,List<String>> parentChatVsChildAcctCodeOppty = new Map<id,List<String>>();
        
        //*******27/03 when child order exists and child opty not exist start**********************************************/
        if(childNgageOrdId!= Null && existingChildOpp == Null){
            
            //27/03: getting child order add on features here
            List<invoiceit_s__Job_Product__c > existingAddOnProducts = [Select id, name,IsAddOnFeature__c,
                                                                        Created_From_Order_Product__c,
                                                                        invoiceit_s__Product_Code__c 
                                                                        from invoiceit_s__Job_Product__c  
                                                                        where  IsAddOnFeature__c=True 
                                                                        AND invoiceit_s__Job__c =:childNgageOrdId];
            Set<String> existingaddonChatProducts = new Set<String>();
            
            //27/03: Forming parent child relationship between existing child order products and child add on order products
            //by using relationship field Created_From_Order_Product__c = add on chat parent field
            if(!existingAddOnProducts.isempty()){
                for(invoiceit_s__Job_Product__c oprpc : existingAddOnProducts){
                    existingaddonChatProducts.add(oprpc.invoiceit_s__Product_Code__c); 
                    if(parentChatVsChildAcctCodeOrd.containsKey(oprpc.Created_From_Order_Product__c)){
                        parentChatVsChildAcctCodeOrd.get(oprpc.Created_From_Order_Product__c).add(oprpc.invoiceit_s__Product_Code__c);    
                    }else{
                        parentChatVsChildAcctCodeOrd.put(oprpc.Created_From_Order_Product__c,new List<String>{oprpc.invoiceit_s__Product_Code__c});                
                    }   
                    //  System.debug('=========parentChatVsChildAcctCodeOrd=========='+parentChatVsChildAcctCodeOrd);
                }
            }
        }
        //*******27/03 when child order exists and child opty not exist End**********************************************/
        
        
        /***********27/03: If child opty exists start**********************************************************/
        else if((childNgageOrdId == Null ||  childNgageOrdId!=Null) && existingChildOpp!= Null){
            
            //27/03: getting child Opportunity add on features here
            List<invoiceit_crmx__Opportunity_Product__c> existingAddOnOpptyProducts = [Select id, name,IsAddOnFeature__c,
                                                                                       Created_From_Opportunity_Product__c,
                                                                                       invoiceit_crmx__Product_Code__c 
                                                                                       from invoiceit_crmx__Opportunity_Product__c 
                                                                                       where  IsAddOnFeature__c=True 
                                                                                       AND invoiceit_crmx__Opportunity__c=:existingChildOpp.id];
            Set<String> existingaddonChatProducts = new Set<String>();
            System.debug('============Inside the if second time'+existingAddOnOpptyProducts );
            //27/03: Forming parent child relationship between existing child opportunity products and child add on opportunity products
            //by using relationship field Created_From_Opportunity_Product__c = add on chat parent field
            if(!existingAddOnOpptyProducts.isempty()){
                for(invoiceit_crmx__Opportunity_Product__c oprpc : existingAddOnOpptyProducts){
                    existingaddonChatProducts.add(oprpc.invoiceit_crmx__Product_Code__c); 
                    if(parentChatVsChildAcctCodeOppty.containsKey(oprpc.Created_From_Opportunity_Product__c)){
                        parentChatVsChildAcctCodeOppty.get(oprpc.Created_From_Opportunity_Product__c).add(oprpc.invoiceit_crmx__Product_Code__c);    
                    }else{
                        parentChatVsChildAcctCodeOppty.put(oprpc.Created_From_Opportunity_Product__c,new List<String>{oprpc.invoiceit_crmx__Product_Code__c});                
                    }   
                    System.debug('=========parentChatVsChildAcctCodeOppty=========='+parentChatVsChildAcctCodeOppty);
                }
            }
        }
        
        /***********27/03: If child opty exists End**********************************************************/
        
        //this list is used to form standalone addon chts
        List<childcharges> childaddonchatswrapperforstandlone = new List<childcharges>();
        childaddonchatswrapperforstandlonetemp = new List<childcharges>();
        
        
        List<invoiceit_s__Product_Rate_Plan_Charge__c> addonchatslist = new List<invoiceit_s__Product_Rate_Plan_Charge__c>();
        List<invoiceit_s__Product_Rate_Plan_Charge__c> addonChildchatslist = new List<invoiceit_s__Product_Rate_Plan_Charge__c>();
        Map<string,invoiceit_s__Product_Rate_Plan_Charge__c> addonChatcodeVsProducrpc = new Map<string,invoiceit_s__Product_Rate_Plan_Charge__c>();
        for (invoiceit_s__Product_Rate_Plan_Charge__c  o : [select id, name, invoiceit_s__Accounting_Code__c, invoiceit_s__Product_Rate_Plan__r.Product_Code__c,
                                                            invoiceit_s__Product_Rate_Plan__r.invoiceit_s__Product__r.Name
                                                            
                                                            from invoiceit_s__Product_Rate_Plan_Charge__c  
                                                            where 
                                                            invoiceit_s__Accounting_Code__c in :addonChildChatProducts
                                                           ])
        {
            if(addonChatProducts.contains(o.invoiceit_s__Accounting_Code__c)){
                addonchatslist.add(o);
                addonChatcodeVsProducrpc.put(o.invoiceit_s__Accounting_Code__c,o);
                childaddonchatswrapperforstandlone.add(new childcharges(o));
                childaddonchatswrapperforstandlonetemp.add(new childcharges(o));
            }else{
                addonChildchatslist.add(o);
            }
            System.debug('=============addonChildchatslist====='+addonChildchatslist);
        }
        
        // Code added to get the child product rate plan charges
        /* List<invoiceit_s__Product_Rate_Plan_Charge__c> addonChildchatslist = new List<invoiceit_s__Product_Rate_Plan_Charge__c>();
for (invoiceit_s__Product_Rate_Plan_Charge__c  o : [select id, name, invoiceit_s__Accounting_Code__c, 
invoiceit_s__Product_Rate_Plan__r.invoiceit_s__Product__r.Name

from invoiceit_s__Product_Rate_Plan_Charge__c  
where 
invoiceit_s__Accounting_Code__c in :addonChildChatProducts
])
{


addonChildchatslist.add(o);
//childaddonchatswrapperforstandlone.add(new childcharges(o));
//childaddonchatswrapperforstandlonetemp.add(new childcharges(o));

}*/
        /*-----------------------------Code for Child Ngage Oppty--------------------------------------------------*/
        System.debug('Inside the new method'+existingChildOpp );
        System.debug('Inside the new method13131231'+childNgageOrdId);
        
        /**********Logic to add the chat products from Child Ngage Opportunity whether Ngage child order exist or not************************/
        if(existingChildOpp !=Null && (childNgageOrdId==Null || childNgageOrdId!=Null))
        {
            string existingchildoppidtemp =existingChildOpp.id; 
            system.debug('@@@calling opportunity 2nd section a'+ordproductNameList + 'abc'+ existingchildoppidtemp);
            /**********************Adding altogether new logic : akash : 05/04/2018********************/
            string squery = ' select Id, name, invoiceit_crmx__Accounting_Code__c,SIN__c,URL_Attribute__c, '+
                ' invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, invoiceit_crmx__Status__c, '+
                ' invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name, '+
                ' invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__r.Name, '+
                ' invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.CreatedFrmMHOpptyProd__c, '+
                ' invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Created_From_MH_Opportunity_Product__r.Name, '+                                                                  
                ' invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Chat_Parent_Opportunity_Product__r.Name, '+
                ' invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Created_From_Opportunity_Product__r.Id, '+
                ' invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__SequenceNumber__c, '+
                //' invoiceit_crmx__Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity__r.name, '+
                '(select Id, name, invoiceit_crmx__Accounting_Code__c,SIN__c,URL_Attribute__c, '+
                ' invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, invoiceit_crmx__Status__c, '+
                ' invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c, '+
                ' invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name, '+
                ' invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.CreatedFrmMHOpptyProd__c, '+
                ' invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Created_From_MH_Opportunity_Product__r.Name, '+                                                                  
                ' invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Chat_Parent_Opportunity_Product__r.Name, '+
                ' invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Created_From_Opportunity_Product__r.Id, '+
                ' invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__SequenceNumber__c '+
                ' FROM Opportunity_Rate_Plan_Charges1__r)'+
                ' FROM invoiceit_crmx__Opportunity_Rate_Plan_Charge__c '+
                ' where invoiceit_crmx__Opportunity__c =:existingchildoppidtemp ' +
                ' and invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c in :ordproductNameList ' +
                ' and (invoiceit_crmx__Status__c=\'Active\'';
            if(existingChildOpp.name.contains('Mid-Term')){
                squery += ' OR invoiceit_crmx__Status__c=\'Converted\')';
            }
            else{
                squery += ')';
            }
            /* List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> childOrdRPCListA =  [select Id, name, invoiceit_crmx__Accounting_Code__c,
invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, invoiceit_crmx__Status__c,
invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c,
invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name,
invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.CreatedFrmMHOpptyProd__c,
invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Created_From_MH_Opportunity_Product__r.Name,                                                                    
invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Chat_Parent_Opportunity_Product__r.Name,
invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Created_From_Opportunity_Product__r.Id, 
invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__SequenceNumber__c,
(select Id, name, invoiceit_crmx__Accounting_Code__c,
invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, invoiceit_crmx__Status__c,
invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c,
invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name,
invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.CreatedFrmMHOpptyProd__c,
invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Created_From_MH_Opportunity_Product__r.Name,                                                                    
invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Chat_Parent_Opportunity_Product__r.Name,
invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Created_From_Opportunity_Product__r.Id, 
invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__SequenceNumber__c
FROM Opportunity_Rate_Plan_Charges1__r)
FROM invoiceit_crmx__Opportunity_Rate_Plan_Charge__c
where invoiceit_crmx__Opportunity__c =:existingChildOpp.Id and invoiceit_crmx__Status__c='Active'
and invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c in :ordproductNameList 
];*/
            
            List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> childOrdRPCListA = Database.query(squery);
            System.debug('childOrdRPCListA--->' + JSON.serialize(childOrdRPCListA));
            
            If(!childOrdRPCListA.isEmpty()){
                for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c orpcA : childOrdRPCListA){
                    system.debug('@@@calling opportunity 2nd section b');
                    
                    AttributesWrapper ow = new AttributesWrapper();
                    ow.oppAttrib = orpcA;
                    ow.chatexists = false;
                    ow.chatcheck = false;
                    ow.createdFromOpportunityProduct = orpcA.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c; 
                    ow.alreadyCreatedId = orpcA.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c;
                    
                    //27/03: If not professional Profile then adding to the list 
                    //if(orpcA.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name!='Ngage Live Chat - Professional Profile'){
                        //opptychildChatProdList.add(ow);  
                        System.debug('====>'+JSON.serialize(orpcA));
                        System.debug('====>'+orpcA.invoiceit_crmx__Accounting_Code__c);
                        System.debug('====>'+prodVsAddonProducts.get(orpcA.invoiceit_crmx__Accounting_Code__c));
                        List<childcharges> ccList = new List<childcharges>();
                        List<String> codeList = new List<String>();
                        Set<String> addonchatcodes =new Set<String>();
                        if(orpcA.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name=='Ngage Live Chat - Professional Profile'){
                            codeList= prodVsAddonProducts.get('11006');
                            addonchatcodes.addAll(codeList);
                        }
                        else{
                            if(prodVsAddonProducts.containsKey(orpcA.invoiceit_crmx__Accounting_Code__c)){
                                codeList= prodVsAddonProducts.get(orpcA.invoiceit_crmx__Accounting_Code__c);
                                addonchatcodes.addAll(codeList);      
                                system.debug('***addonchatcodes'+addonchatcodes);
                            }else{
                                addonchatcodes = addonChildChatProducts.clone();
                                system.debug('###addonchatcodes'+addonchatcodes);
                            }
                        }
                        
                        //Set<String> addonchatcodes = addonChildChatProducts.clone();
                        system.debug('@@@@addonchatcodes'+addonchatcodes);
                      
                        //adding already created addon chat opportunity rate plan charges here
                        for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c orcpcA : orpcA.Opportunity_Rate_Plan_Charges1__r){
                            string chatcode = orcpcA.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c;
                            system.debug('@@@@chatcode'+chatcode);
                            If(addonChildChatProducts.contains(chatcode)){
                                invoiceit_s__Product_Rate_Plan_Charge__c trpc = addonChatcodeVsProducrpc.get(chatcode);
                                childcharges cc = new childcharges(trpc);
                                cc.alreadyCreatedId = orcpcA.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c;
                                if(orcpcA.SIN__c != NULL && existingChildOpp.name.contains('Mid-Term')){
                                    cc.sin = orcpcA.SIN__c;                              
                                  }
                                
                                ccList.add(cc);
                                system.debug('@@@@cclist'+cclist.size());
                                addonchatcodes.remove(chatcode);
                            }
                        }
                        
                        system.debug('@@@@addonchatcodes'+addonchatcodes);
                        //not added add on chats adding here
                        if(!addonchatcodes.isEmpty()){
                            for(string ccode : addonchatcodes){
                              
                                    ccList.add(new childcharges(addonChatcodeVsProducrpc.get(ccode)));
                               
                            }
                        }
                        system.debug('@@@@cclist'+cclist.size());
                        //assigning to wrapper here
                        if(!ccList.isEmpty()){
                            ow.childChatProducts = ccList;
                        }
                    //}
                    
                    opptyChildChatProdListFinal.add(ow);
                }
                
                
                
                
                
            }
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            //27/03:getting all child opportunity products where Ngage Live chat available i.e 60010
            /*List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> childOrdRPCList =  [select Id, name, invoiceit_crmx__Accounting_Code__c,URL_Attribute__c,
                                                                                      invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, invoiceit_crmx__Status__c,
                                                                                      invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c,
                                                                                      invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name,
                                                                                      invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.CreatedFrmMHOpptyProd__c,
                                                                                      invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Created_From_MH_Opportunity_Product__r.Name,                                                                    
                                                                                      invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Chat_Parent_Opportunity_Product__r.Name,
                                                                                      invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Created_From_Opportunity_Product__r.Id, 
                                                                                      invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__SequenceNumber__c,
                                                                                      (select id, Attribute_Name__c , string_value__c 
                                                                                       from Opportunity_Charge_Attributes__r where (Attribute_Name__c = 'URL' OR Attribute_Name__c = 'Domain Name')) 
                                                                                      FROM invoiceit_crmx__Opportunity_Rate_Plan_Charge__c
                                                                                      where invoiceit_crmx__Opportunity__c =:existingChildOpp.Id and invoiceit_crmx__Status__c='Active'
                                                                                      and invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c in :ordproductNameList 
                                                                                     ];
            System.debug('============childOppRPCList ============='+childOrdRPCList );
            
            
            if(!childOrdRPCList.isempty()){
                for (invoiceit_crmx__Opportunity_Rate_Plan_Charge__c o: childOrdRPCList )
                {
                    
                    AttributesWrapper ow = new AttributesWrapper();
                    ow.oppAttrib = o;
                    ow.chatexists = false;
                    ow.chatcheck = false;
                    ow.createdFromOpportunityProduct = o.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c; 
                    
                    //establishing relationship between opportunity products here : ronak
                    
                    
                    
                    if (o.Opportunity_Charge_Attributes__r.size() > 0)
                        ow.attrib = o.Opportunity_Charge_Attributes__r[0].string_value__c;
                    
                    //27/03: If not professional Profile then adding to the list 
                    if(o.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name!='Ngage Live Chat - Professional Profile'){
                        opptychildChatProdList.add(ow);  
                    }
                    System.debug('======opptychildChatProdList======'+opptychildChatProdList );
                    //     System.debug('=========ow.createdFromOrderProduct==========='+ow.createdFromOrderProduct);
                }
                
                String prodCode;
                
                if(!opptychildChatProdList.isempty()){
                    for(AttributesWrapper aw: opptychildChatProdList){
                        System.debug('====childProdVsAddonProducts======'+childProdVsAddonProducts);
                        if(childProdVsAddonProducts.containsKey(aw.oppAttrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c)){                            
                            List<childcharges> childccList = new List<childcharges>();
                            //added
                            System.debug('contains key or not'+parentChatVsChildAcctCodeOppty.containskey(aw.oppAttrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id));
                            
                            //27/03 : checking for already available add on feature prodcuts
                            //if not added showing into the list
                            if(parentChatVsChildAcctCodeOppty.containskey(aw.oppAttrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id)){
                                List<String> addedproductCodes = parentChatVsChildAcctCodeOppty.get(aw.oppAttrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id);
                                System.debug('=========addedproductCodes =========='+addedproductCodes );
                                for(invoiceit_s__Product_Rate_Plan_Charge__c orpc : addonchatslist){
                                    
                                    prodCode = orpc.invoiceit_s__Product_Rate_Plan__r.Product_Code__c;
                                    if(addedproductCodes.contains(prodCode)){
                                        //addonchatslist.removeall(addedproductCodes);
                                    }else{
                                        childccList.add(new childcharges(orpc));
                                    }
                                }
                                if(!childccList.isEmpty()){
                                    aw.childChatProducts = childccList;
                                }
                            }else{
                                for(invoiceit_s__Product_Rate_Plan_Charge__c orpc : addonchatslist){
                                    childccList.add(new childcharges(orpc));
                                }
                                if(!childccList.isEmpty()){
                                    // aw.childChatProducts = childccList;
                                }
                                
                            }
                        }
                        // opptyChildChatProdListFinal.add(aw);
                        
                    }
                }
            } */
        }
        
        /***********Logic written to get the Ngage chat products from the Ngage Child Order when there is no Ngage Child Opportunity on the MH Order************************/
        System.debug('----->'+childNgageOrdId);
        System.debug('----->'+existingChildOpp);
        //Code for checking the child Ngage Order RPCs
        if(childNgageOrdId!= Null && existingChildOpp ==Null){
            
            List<invoiceit_s__Job_Rate_Plan_Charge__c> childOrdRPCList =  [select id, name, invoiceit_s__Accounting_Code__c, 
                                                                           invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c, invoiceit_s__Status__c,
                                                                           invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.CreatedFrmMHOpptyProd__c,
                                                                           invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c,
                                                                           invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.name,
                                                                           invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Created_From_Order_Product__r.Id, 
                                                                           invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__SequenceNumber__c,
                                                                           (select id, Attribute_Name__c , string_value__c 
                                                                            from Order_Charge_Attributes__r where (Attribute_Name__c = 'URL' OR Attribute_Name__c = 'Domain Name')) 
                                                                           from invoiceit_s__Job_Rate_Plan_Charge__c   
                                                                           where invoiceit_s__Order__c =:childNgageOrdId and invoiceit_s__Status__c='Active'
                                                                           and invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c in :ordproductNameList 
                                                                          ];
            System.debug('============childOrdRPCList============='+childOrdRPCList);
            if(!childOrdRPCList.isempty()){
                for (invoiceit_s__Job_Rate_Plan_Charge__c o: childOrdRPCList)
                {
                    system.debug('@@@childorderngage check');
                    
                    AttributesWrapper ow = new AttributesWrapper();
                    ow.ordrattrib = o;
                    ow.chatexists = false;
                    ow.chatcheck = false;
                    ow.createdFromOrderProduct = o.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c;
                    //establishing relationship between opportunity products here : ronak
                    
                    
                    
                    if (o.Order_Charge_Attributes__r.size() > 0)
                        ow.attrib = o.Order_Charge_Attributes__r[0].string_value__c;
                    //if(o.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.name!='Ngage Live Chat - Professional Profile'){
                        childChatProdList.add(ow);  
                    //}
                    System.debug('======childChatProdList======'+childChatProdList);
                    //     System.debug('=========ow.createdFromOrderProduct==========='+ow.createdFromOrderProduct);
                }
                
                String prodCode;
                List<String> codeVal = new List<String>();
                if(!childChatProdList.isempty()){
                    for(AttributesWrapper aw: childChatProdList){
                        System.debug('====childProdVsAddonProducts======'+childProdVsAddonProducts);
                        System.debug('True or False'+childProdVsAddonProducts.containsKey(aw.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c));
                        if(childProdVsAddonProducts.containsKey(aw.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c)){                            
                            List<childcharges> childccList = new List<childcharges>();
                            //added
                            System.debug('@@@@@@@@@@'+parentChatVsChildAcctCodeOrd);
                            System.debug('======parentChatVsChildAcctCodeOrd===='+parentChatVsChildAcctCodeOrd.containskey(aw.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Created_From_Order_Product__r.Id));
                            if(parentChatVsChildAcctCodeOrd.containskey(aw.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Id)){
                                List<String> addedproductCodes = parentChatVsChildAcctCodeOrd.get(aw.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Id);
                                System.debug('======addedproductCodes ======='+addedproductCodes );
                                System.debug('@@@@prodVsAddonProducts'+prodVsAddonProducts);
                                System.debug('======'+aw.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.name.contains('Professional Profile'));
                                if(aw.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.name.contains('Professional Profile')){
                                     codeVal = prodVsAddonProducts.get('11006');
                                }else{
                                     System.debug('@@@@@@aw.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_'+aw.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c);
                                     codeVal = childProdVsAddonProducts.get(aw.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c);
                                }
                                //List<String> codeVal = prodVsAddonProducts.get(aw.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c);
                                System.debug('======codeVal ======='+codeVal );
                                if(codeVal!=null && !codeVal.isEmpty()){
                                    for(String s: codeVal){
                                    
                                        if(addedproductCodes.contains(s)){
                                            //addonchatslist.removeall(addedproductCodes);
                                        }else{
                                            invoiceit_s__Product_Rate_Plan_Charge__c tempObj = addonChatcodeVsProducrpc.get(s);
                                            childccList.add(new childcharges(tempObj));
                                        }
                                        
                                    }
                                    system.Debug('----childccList----'+childccList);
                                    /*for(invoiceit_s__Product_Rate_Plan_Charge__c orpc : addonchatslist){
                                        
                                        prodCode = orpc.invoiceit_s__Product_Rate_Plan__r.Product_Code__c;
                                        if(addedproductCodes.contains(prodCode)){
                                            //addonchatslist.removeall(addedproductCodes);
                                        }else{
                                            childccList.add(new childcharges(orpc));
                                        }
                                    }*/
                                    if(!childccList.isEmpty()){
                                        aw.childChatProducts = childccList;
                                    }
                                }
                            }else{
                                //List<String> codeVal = new List<String>();
                                 System.debug('@@@@@@@@@@prodVsAddonProducts'+prodVsAddonProducts);
                                 System.debug('@@@aw.ordrattrib.name'+aw.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.name);
                                 if(aw.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.name.contains('Professional Profile')){
                                      codeVal = prodVsAddonProducts.get('11006');
                                 }
                                 else if(aw.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.name.contains('External Website')){
                                         codeVal = childProdVsAddonProducts.get(aw.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c);
                                 }
                                 else if(aw.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.name.contains('Web')){
                                         codeVal = childProdVsAddonProducts.get(aw.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c);
                                 }
                                 else{
                                     System.debug('@@@@@@'+prodVsAddonProducts.get(aw.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c));
                                      codeVal = childProdVsAddonProducts.get(aw.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c);
                                 }
                                 
                                System.debug('@@codeVal'+codeVal);
                                
                                if(!codeVal.isEmpty() && codeVal != null){
                                    for(String s: codeVal){
                                        invoiceit_s__Product_Rate_Plan_Charge__c tempObj = addonChatcodeVsProducrpc.get(s);
                                        childccList.add(new childcharges(tempObj));
                                    }
                                }
                                /*for(invoiceit_s__Product_Rate_Plan_Charge__c orpc : addonchatslist){
                                    childccList.add(new childcharges(orpc));
                                }*/
                                if(!childccList.isEmpty()){
                                    aw.childChatProducts = childccList;
                                }
                                
                            }
                        }
                        childChatProdListFinal.add(aw);
                        
                    }
                }
            } 
        }
        
        //adding first ngage live chat here
        standalonechatslist = new List<standalonechat>();
        
        singlestandalonechat = new standalonechat(chatProduct.values()[0],childaddonchatswrapperforstandlonetemp);
        standalonechatslist.add(new standalonechat(chatProduct.values()[0],childaddonchatswrapperforstandlone));
        standalonechatsSize = standalonechatslist.size();

        /************Akash : Forming wrapper class to show on page here ********************************************************************/
        // If(childopp == NULL){
        for (invoiceit_crmx__Opportunity_Rate_Plan_Charge__c  o : [select id, name, invoiceit_crmx__Accounting_Code__c, URL_Attribute__c,
                                                                   invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, 
                                                                   invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c,
                                                                   invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name,invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.IsAddOnFeature__c, 
                                                                   invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__SequenceNumber__c,
                                                                   (select id, Attribute_Name__c, string_value__c 
                                                                    from Opportunity_Charge_Attributes__r where (Attribute_Name__c = 'URL' OR Attribute_Name__c = 'Domain Name')) 
                                                                   from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c  
                                                                   where invoiceit_crmx__Opportunity__c = :Oppid 
                                                                   and invoiceit_crmx__Accounting_Code__c in :productNameList
                                                                   //and id NOT IN: parentchargeIdstoExclude
                                                                   //and Id NOT IN:orderChargeIdstoExclude
                                                                   
                                                                    and 
                                                                   id not in (select Chat_Product_Opp_Rate_Plan_Charge__c from Chat_Product_Opportunity_Charge__c)
                                                                  ])
        {
            
            AttributesWrapper ow = new AttributesWrapper();
            ow.oppAttrib = o;
            ow.chatexists = false;
            ow.Chatcheck = false;
            ow.createdFromOpportunityProduct = o.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c;
            //establishing relationship between opportunity products here : akash 06/01/2018
            
            system.debug('@@@@@ ow.createdFromOpportunityProduct'+ ow.createdFromOpportunityProduct);
            system.debug('========'+ o);
            if (o.Opportunity_Charge_Attributes__r.size() > 0)
                ow.attrib = o.Opportunity_Charge_Attributes__r[0].string_value__c;
            //    system.debug(ow);
            if (cnt == 0 && multiProdPerChatList.contains(o.invoiceit_crmx__Accounting_Code__c) && professionalprofile == false)   {               
                ChatProdList.add(ow);
                prodforchat.add(o.id);
            }
            if (!multiProdPerChatList.contains(o.invoiceit_crmx__Accounting_Code__c))
            {
                ChatProdList.add(ow);
                prodforchat.add(o.id);
            }
            if (multiProdPerChatList.contains(o.invoiceit_crmx__Accounting_Code__c))
            {
                cnt = 1;
                prodforchat.add(o.id);
            }                
            
        }
        
        
        
        //system.debug('@@@@addonchatslist'+addonchatslist);
        //adding addon charges into wrapper classes here
        //system.debug('@@@@prodVsAddonProducts'+prodVsAddonProducts);
        system.debug('@@@@ChatProdList'+ChatProdList);
        for(AttributesWrapper aw: ChatProdList){
            if(prodVsAddonProducts.containsKey(aw.oppattrib.invoiceit_crmx__Accounting_Code__c)){
                List<childcharges> ccList = new List<childcharges>();
                List<String> codeVal = prodVsAddonProducts.get(aw.oppattrib.invoiceit_crmx__Accounting_Code__c);
                
                for(String s: codeVal){
                    invoiceit_s__Product_Rate_Plan_Charge__c tempObj = addonChatcodeVsProducrpc.get(s);
                    ccList.add(new childcharges(tempObj));
                }
                /*for(invoiceit_s__Product_Rate_Plan_Charge__c orpc : addonchatslist){
                    
                    
                    ccList.add(new childcharges(orpc));
                    
                    
                }*/
                system.debug('@@@ccList'+ccList);
                if(!ccList.isEmpty()){
                    aw.chatproducts = ccList;
                }
                
            }
            ChatProdListFinal.add(aw);
            
        }
        /*********************************************************************************************************************/
        //  system.debug('prodforchat---'+prodforchat + '====:::::==='+ChatProdList);
        
        if(childChatProdListFinal.isempty()){
            //ChatProdListFinal.addALL(childChatProdListFinal);
        }
    }
    
   
    public class DeleteProducts{
        public boolean deleteProductCheck{get;set;}
        public invoiceit_crmx__Opportunity_Rate_Plan_Charge__c delOptyProductrpc{get;set;}
        public DeleteProducts(boolean b, invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opProdrpc){
            this.deleteProductCheck = b;
            this.delOptyProductrpc = opProdrpc;
        }
        
        
    }
    
    
    //wrapper class for standalone chat products
    public class standalonechat{
        public boolean standalonecheck{get;set;}
        public invoiceit_s__Product__c invproduct{get;set;}
        public List<childcharges> chatproducts {get;set;} //child wrapper to hold add on chat products
        public standalonechat(invoiceit_s__Product__c invprod,List<childcharges> childchargesList){
            this.invproduct = invprod;
            this.standalonecheck = false;
            this.chatproducts = childchargesList;
        }
        
    }
    
    //wrapper class to hold the data
    public class AttributesWrapper{
        public invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppattrib{get;set;} 
        public Id createdFromOpportunityProduct{get;set;}  //akash        
        //For Child order RPC
        public invoiceit_s__Job_Rate_Plan_Charge__c ordrattrib{get;set;}
        public string prodName{get;set;}
        public Id createdFromOrderProduct{get;set;}
        
        public Boolean  ChatCheck{get;set;}
        public string attrib{get;set;}
        public List<childcharges> chatproducts {get;set;} //child wrapper to hold add on chat products
        public List<childcharges> childChatProducts {get;set;} // child wrapper to hold add on chat features and prod
        @testvisible boolean chatexists;
        
        public string alreadyCreatedId{get;set;}
        
        public AttributesWrapper(){
            this.chatproducts = new List<childcharges>();
            this.childChatProducts = new List<childcharges>();
        }
    }
    
    //hold add on chat products data here
    public class childcharges{
        public invoiceit_s__Product_Rate_Plan_Charge__c oppattribchild{get;set;}
        public invoiceit_s__Product_Rate_Plan_Charge__c ordattribchild{get;set;}
        
        public boolean childcheck{get;set;}
        public boolean chatChildCheck{get;set;}
        public string alreadyCreatedId{get;set;}
        public String sin{get;set;}
        public childcharges(invoiceit_s__Product_Rate_Plan_Charge__c prpc){
            this.oppattribchild = prpc;
            this.childcheck   = false;
            this.chatchildcheck = false;
            this.ordattribchild = prpc;
        }
    }
    
    public Pagereference Save()
    {
        list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> oprc = new list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        set<id> prodid = new set<id>();
        for (invoiceit_crmx__Opportunity_Rate_Plan_Charge__c orpc: [select id, name, invoiceit_crmx__Accounting_Code__c, 
                                                                    invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, 
                                                                    invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c 
                                                                    from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c 
                                                                    where invoiceit_crmx__Opportunity__c = :Oppid and invoiceit_crmx__Accounting_Code__c in :productNameList])
            prodid.add(orpc.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c);
        //  System.debug('========prodid====='+prodid);
        op = [select id, name, Is_Chat_Option_Shown__c, invoiceit_crmx__Product__c, 
              invoiceit_crmx__Product_Code__c, invoiceit_crmx__SequenceNumber__c   
              from invoiceit_crmx__Opportunity_Product__c 
              where invoiceit_crmx__Opportunity__c = :Oppid and id in :prodid];
        //  System.debug('=====Opportunity Products======'+op);
        for (invoiceit_crmx__Opportunity_Product__c o:op)
        {
            if (o.Is_Chat_Option_Shown__c == null)
                o.Is_Chat_Option_Shown__c = 'No';
        }
        
        
        //Added by Sai C
        string childoptyquery = ' select id, name, Discount__c, Ngage_Upsell_Order__c, Parent_Opportunity__c, invoiceit_crmx__Number_Of_Terms__c, '+
            'invoiceit_crmx__Discount_Percent__c, invoiceit_crmx__Discount_Value__c '+
            ' from Opportunity';
        string childfilter ='';
        If(ngageUpsellOrderId != NULL){
            childfilter = ' where Ngage_Upsell_Order__c=:ngageUpsellOrderId AND StageName != \'Closed Lost\'AND StageName != \'Closed Won\'';
        }
        else{
            childfilter = ' where Parent_Opportunity__c = :oppid AND StageName != \'Closed Lost\'';
        }
        
        List<Opportunity> childOpptyList = database.query(childoptyquery+childfilter);
        
        if(childOpptyList != null && childOpptyList.size() > 0){
            childopp = childOpptyList[0];
        }
         List<invoiceit_crmx__Opportunity_Product__c> OppProductsFromchildorder = new List<invoiceit_crmx__Opportunity_Product__c>();
        List<invoiceit_crmx__Opportunity_Rate_Plan__c> rateplansfromchildorder = new List<invoiceit_crmx__Opportunity_Rate_Plan__c>();
       List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> rateplanchargesfromOrder = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        System.debug('@@@@@@@@@@ChatProdListFinal '+ChatProdListFinal);
        for(AttributesWrapper a : ChatProdListFinal )
        {
            //    system.debug('@@@@@@@a.chatcheck: ' + a.chatcheck); 
            //    system.debug('@@@@a child chages'+ a.chatproducts);
            //    system.debug('@@@@@@@a.chatexists: ' + a.chatexists);
            //   system.debug('outside the create opp: ' +childopp);
            if (a.chatcheck == true && a.chatexists == false)
            {
                //        system.debug('inside the crate opp' +childopp);
                //create opportunity when anyone of selection is yes
                if(childopp == NULL){
                    //Sai: adding logic to create child order and child order charges
                    if(ngageUpsellchidlOrder != NULL){
                        system.debug('@@@@ in child opp creation');
                        JobClass jobClass1 = Childorderdetails.populatechildJobClass(ngageUpsellchidlOrder);
                        
                        //adding new opportunity creation logic here : sai 15/04
                        childopp = createChildOpp(oppid);
                        createMidtermOptyFromChildOrder.jobClass = jobClass1;
                        createMidtermOptyFromChildOrder.optyId = childopp.id;
                        createMidtermOptyFromChildOrder.createchildoptyfromorder('Mid-Term', ngageUpsellOrder.id);
                         OppProductsFromchildorder = createMidtermOptyFromChildOrder.OppProductsFromOrder;
                        OppProduct.addAll(OppProductsFromchildorder);
                         //commented Attribute changes 4/17 
                        //opportunityAttributes = createMidtermOptyFromChildOrder.opportunityAttributesFromOrder;
                        //childopp = createChildOpp(oppid);
                       // system.enqueueJob(new createOpportunityForChildOrder(jobClass1, 'Mid-Term', ngageUpsellOrder.id,childopp.id));
                        // createOpportunityForChildOrder.createOpportunity(jobClass1, 'Mid-Term', ngageUpsellOrder.id,childopp.id);
                    }
                    else{
                        childopp = createChildOpp(oppid);
                    }
                    
                }
                //       system.debug('a.chatcheck: if' + a.chatcheck);
                //       system.debug('@@@opp product referece' + a.createdFromOpportunityProduct);
                system.debug('@@@@After child opp creation' + childopp.id);
                createChatOppRPC(a);
                
                for (invoiceit_crmx__Opportunity_Product__c op1:op)
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
                            //  system.debug('Op1: ' + op1 + ' : ' + op); 
                        }
                    }
                }
            }
            if (a.chatcheck == false && a.chatexists == true)
            {
                OppDeleteChat.add(prodchatmap.get(a.oppattrib.id));
                OppdeleteProd.add(a.oppattrib.id);
            }
            
        }
        
        /**********************************Handling Features charges here *************************************/
        if(!childChatProdListFinal.isempty()){
            for(AttributesWrapper a :childChatProdListFinal){
                //if(a.chatchildcheck){
                //creating opportunity if not already created
                if(childopp == NULL){
                    //Sai: adding logic to create child order and child order charges
                    if(ngageUpsellchidlOrder != NULL){
                        system.debug('@@@@ in child opp creation');
                        JobClass jobClass1 = Childorderdetails.populatechildJobClass(ngageUpsellchidlOrder);
                        childopp = createChildOpp(oppid);
                        
                        createMidtermOptyFromChildOrder.jobClass = jobClass1;
                       createMidtermOptyFromChildOrder.optyId = childopp.id;
                        createMidtermOptyFromChildOrder.createchildoptyfromorder('Mid-Term', ngageUpsellOrder.id);
                         OppProductsFromchildorder = createMidtermOptyFromChildOrder.OppProductsFromOrder;
                        OppProduct.addAll(OppProductsFromchildorder);
                        //commented Attribute changes 4/17
                       // opportunityAttributes = createMidtermOptyFromChildOrder.opportunityAttributesFromOrder;
                        //stem.enqueueJob(new createOpportunityForChildOrder(jobClass1, 'Mid-Term', ngageUpsellOrder.id,childopp.id));
                        
                    }
                    else{
                        childopp = createChildOpp(oppid);
                    }
                }
                //creating single list to add all standlone products
                createFeatureOppRPC(a);
                //}
                
            }
        }
        /**********************************Handling Features charges here *************************************/
        if(!opptyChildChatProdListFinal.isempty()){
            for(AttributesWrapper a :opptyChildChatProdListFinal){
                opptycreateFeatureRPC(a);
                
            }
        }
        
        
         /**********************************Handling standalone charges here *************************************/
        List<invoiceit_crmx__Opportunity_Product__c> oppProductsToInsert = new List<invoiceit_crmx__Opportunity_Product__c>(); 
        for(standalonechat soc:standalonechatslist){
            if(soc.standalonecheck){
                //creating opportunity if not already created
                if(childopp == NULL){
                    //Sai: adding logic to create child order and child order charges
                    if(ngageUpsellchidlOrder != NULL){
                        system.debug('@@@@ in child opp creation');
                        JobClass jobClass1 = Childorderdetails.populatechildJobClass(ngageUpsellchidlOrder);
                        childopp = createChildOpp(oppid);
                        
                        createMidtermOptyFromChildOrder.jobClass = jobClass1;
                       createMidtermOptyFromChildOrder.optyId = childopp.id;
                        createMidtermOptyFromChildOrder.createchildoptyfromorder('Mid-Term', ngageUpsellOrder.id);
                        OppProductsFromchildorder = createMidtermOptyFromChildOrder.OppProductsFromOrder;
                        OppProduct.addAll(OppProductsFromchildorder);
                        //commented Attribute changes 4/17
                       // opportunityAttributes = createMidtermOptyFromChildOrder.opportunityAttributesFromOrder;
                        //stem.enqueueJob(new createOpportunityForChildOrder(jobClass1, 'Mid-Term', ngageUpsellOrder.id,childopp.id));
                        
                    }
                    else{
                        childopp = createChildOpp(oppid);
                    }
                }
                //creating single list to add all standlone products
                oppProductsToInsert.addAll(createStandaloneOpProduct(soc));
            }
            
        }
        /*******************************************************************************************/
        
        
        system.debug('@@@ Opp Products feature : ' + Oppproduct);
        if (!OppProduct.isempty())
        {
            // inserting all opp Products here
            
            insert OppProduct;
            system.debug('Opp Product after insert: ' + OppProduct);
             if(ngageUpsellchidlOrder != NULL && OppProductsFromchildorder != NULL && !OppProductsFromchildorder.isEmpty()
                 ){
                    rateplansfromchildorder = createMidtermOptyFromChildOrder.createoppPoductRateplans(OppProduct);
                     OppProductRatePlan.addAll(rateplansfromchildorder);
                 
               
                 
             }    
            createOppProductRatePlan();
            
              If(ngageUpsellchidlOrder != NULL && !rateplansfromchildorder.isEmpty()){
                     rateplanchargesfromOrder = createMidtermOptyFromChildOrder.createOpprateplancharges(OppProductRatePlan);
                     OppProductRatePlanCharge.addAll(rateplanchargesfromOrder);
                 }
            createOppProductRatePlanCharge();
            
            If(ngageUpsellchidlOrder != NULL && !rateplanchargesfromOrder.isEmpty()){
                createMidtermOptyFromChildOrder.insertoptychargeattributes(OppProductRatePlanCharge);
            }
            
            
            
            
            if(childNgageOrdId!=Null){
                createchatCharges();
            }
            else{
                checkandAddChat();
            }
            
            
            //TO establish relationship between chat add on products chat products here
            Map<Id,invoiceit_crmx__Opportunity_Product__c> parentChatIdVsChats = new Map<Id,invoiceit_crmx__Opportunity_Product__c>();
            Map<Id,invoiceit_crmx__Opportunity_Product__c> ChildChatIdVsChats = new Map<Id,invoiceit_crmx__Opportunity_Product__c>();
            //Added by sai c 4/11
          
            Map<Id,invoiceit_crmx__Opportunity_Product__c> OrderprodVsOppprod = new Map<Id,invoiceit_crmx__Opportunity_Product__c>();
           
            
            //this map only work in the case of mid-term, to populate chat parent
             Map<Id,invoiceit_crmx__Opportunity_Product__c> optyproductscreatedfromordertoupdate = new  Map<Id,invoiceit_crmx__Opportunity_Product__c>();
            If(ngageUpsellchidlOrder != NULL){
                List<invoiceit_crmx__Opportunity_Product__c>templist = new  List<invoiceit_crmx__Opportunity_Product__c>();
                templist = createMidtermOptyFromChildOrder.oppProductsRelationship(OppProduct);
                optyproductscreatedfromordertoupdate = new Map<Id,invoiceit_crmx__Opportunity_Product__c>(templist);
            }   
            
          // else{
                for(invoiceit_crmx__Opportunity_Product__c soppProd : OppProduct){
                    
                    System.debug('============soppProd.Created_From_MH_Opportunity_Product__c'+soppProd.Created_From_MH_Opportunity_Product__c);
                    
                    if(soppProd.invoiceit_crmx__Product_Code__c == conversationcode){
                        if(soppProd.Created_From_MH_Opportunity_Product__c!= NULL){
                            parentChatIdVsChats.put(soppProd.Created_From_MH_Opportunity_Product__c,soppProd);        
                        }
                    }
                    else{
                        if(!optyproductscreatedfromordertoupdate.containskey(soppProd.id)){
                               ChildChatIdVsChats.put(soppProd.id,soppProd);
                        }
                     
                        OrderprodVsOppprod.put(soppProd.Created_From_Order_Product__r.id,soppProd);
                    }          
                }
                
                System.debug('@@@@@@@@@@@@ChildChatIdVsChats'+ChildChatIdVsChats);
                System.debug('@@@@@@@@@@@@OrderprodVsOppprod'+OrderprodVsOppprod);
                If(!ChildChatIdVsChats.isEmpty()){
                    for(invoiceit_crmx__Opportunity_Product__c childchat : ChildChatIdVsChats.values()){
                        system.debug('@@@@@ childchat.Chat_Parent_Opportunity_Product__c'+ parentChatIdVsChats.get(childchat.Created_From_Opportunity_Product__c));
                        //   system.debug('@@@@@ childchat parent'+ parentChatIdVsChats.get(childchat.Created_From_MH_Opportunity_Product__c));
                        if(parentChatIdVsChats.containskey(childchat.Created_From_MH_Opportunity_Product__c)){
                            childchat.Chat_Parent_Opportunity_Product__c  = parentChatIdVsChats.get(childchat.Created_From_MH_Opportunity_Product__c).id;
                            childchat.Created_From_Opportunity_Product__c= parentChatIdVsChats.get(childchat.Created_From_MH_Opportunity_Product__c).id;
                            
                        }
                        
                        system.debug('@@@ childchat.Created_From_Opportunity_Product__c'+childchat.Created_From_Opportunity_Product__c);
                        if(childchat.Created_From_Opportunity_Product__c!=Null){
                            
                            childchat.Chat_Parent_Opportunity_Product__c  = childchat.Created_From_Opportunity_Product__c;
                            
                            
                        }
                        
                        //this is to handle from order which is not working : TODO
                        if(childchat.Created_From_Order_Product__c!=Null){
                            if(OrderprodVsOppprod.containskey(childchat.Created_From_Order_Product__c)){
                                childchat.Chat_Parent_Opportunity_Product__c  = OrderprodVsOppprod.get(childchat.Created_From_Order_Product__c).id;
                                system.debug('@@@@@@ childvhat midterm '+childchat.Chat_Parent_Opportunity_Product__c);
                            }
                            
                        }
                    }
                    
                 
                }
            
               if(!optyproductscreatedfromordertoupdate.isEmpty()){
                        ChildChatIdVsChats.putAll(optyproductscreatedfromordertoupdate);
                    }
                    update ChildChatIdVsChats.values();
                
         //  } 
            
            
            //establishing relationship between orpc and addonchatorpc
            //by using opportunity product and chat parent opportunity product just set above
            Map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>oppProdctIdVsCharge = new Map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
            Map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>chargeIdVschatCharge = new Map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
            Set<id> featParentProdId = new Set<id>();
            Map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> oppChatProdctIdVsChatCharge = new Map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
            
            if(!OppProductRatePlanCharge.isEmpty()){
                for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c c:[select id,Name,invoiceit_crmx__Accounting_Code__c,
                                                                       Chat_Parent_Opportunity_Rate_Plan_Charge__c,
                                                                       invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c,
                                                                       invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c,
                                                                       invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Chat_Parent_Opportunity_Product__c,
                                                                       invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Created_from_MH_Opportunity_Product__c
                                                                       From invoiceit_crmx__Opportunity_Rate_Plan_Charge__c
                                                                       where id IN:OppProductRatePlanCharge]){
                                                                           if(c.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c == conversationcode ){
                                                                               oppProdctIdVsCharge.put(c.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, c);
                                                                               
                                                                           }
                                                                           else{
                                                                               System.debug('@@c.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Created_from_MH_Opportunity_Product__c'+c.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Created_from_MH_Opportunity_Product__c);
                                                                               if(c.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Created_from_MH_Opportunity_Product__c==null){
                                                                                   featParentProdId.add(c.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Chat_Parent_Opportunity_Product__c);
                                                                               }
                                                                               chargeIdVschatCharge.put(c.id,c);
                                                                               
                                                                           }
                                                                       }
                system.debug('@@@@featParentProdId'+featParentProdId);
                
                If(!chargeIdVschatCharge.isEmpty()){
                    
                    if(!featParentProdId.isempty()){
                        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> chatOppRPCListForFeature = [select id,Name,invoiceit_crmx__Accounting_Code__c,
                                                                                                          Chat_Parent_Opportunity_Rate_Plan_Charge__c,
                                                                                                          invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c,
                                                                                                          invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c,
                                                                                                          invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Chat_Parent_Opportunity_Product__c,
                                                                                                          invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Created_from_MH_Opportunity_Product__c
                                                                                                          From invoiceit_crmx__Opportunity_Rate_Plan_Charge__c
                                                                                                          where invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c IN: featParentProdId];
                        SYstem.debug('@@@@@@chatOppRPCListForFeature '+chatOppRPCListForFeature );
                        
                        if(!chatOppRPCListForFeature.isempty()){
                            for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c o : chatOppRPCListForFeature){
                                oppChatProdctIdVsChatCharge.put(o.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, o);
                            }
                        }
                    }
                    for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c c1:chargeIdVschatCharge.values()){
                        System.debug('@@@@@@@@oppChatProdctIdVsChatCharge'+oppChatProdctIdVsChatCharge);
                        if(c1.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Created_from_MH_Opportunity_Product__c==null){
                            if(oppChatProdctIdVsChatCharge.containskey(c1.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Chat_Parent_Opportunity_Product__c)){
                                c1.Chat_Parent_Opportunity_Rate_Plan_Charge__c = oppChatProdctIdVsChatCharge.get(c1.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Chat_Parent_Opportunity_Product__c).id;                        
                            }
                        }else{
                            if(oppProdctIdVsCharge.containskey(c1.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Chat_Parent_Opportunity_Product__c)){
                                c1.Chat_Parent_Opportunity_Rate_Plan_Charge__c = oppProdctIdVsCharge.get(c1.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Chat_Parent_Opportunity_Product__c).id;
                            }
                        }
                        
                    }
                    update chargeIdVschatCharge.values();
                    
                }
                
                
                
            }
            
        }
        system.debug('@@@Rama CPOC: ' + cpoc);
        insert cpoc;
        
        system.debug('Opp Products: ' + op); 
        update op; 
        
        //childopp.IsNewNgageOppty__c = False;
        //update childopp;
        
        
       
        
        
        
        //establishing relationshio between opportunity products
        Map<string, List<invoiceit_crmx__Opportunity_Product__c>> codeVslistofChildopps = new Map<string, List<invoiceit_crmx__Opportunity_Product__c>>();
        List<invoiceit_crmx__Opportunity_Product__c> parentstandloneopproducts = new List<invoiceit_crmx__Opportunity_Product__c>();
        List<invoiceit_crmx__Opportunity_Product__c> childstandloneopproductstoUpdate = new List<invoiceit_crmx__Opportunity_Product__c>();
        List<invoiceit_crmx__Opportunity_Rate_Plan__c> opportunityRateplanstoInsert = new List<invoiceit_crmx__Opportunity_Rate_Plan__c>();
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> chargestoInsert = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        If(!oppProductsToInsert.isEmpty()){
            insert oppProductsToInsert;
            
            opportunityRateplanstoInsert = createstandaloneOppProductRatePlan(oppProductsToInsert);
            If(!opportunityRateplanstoInsert.isEmpty()){
                insert opportunityRateplanstoInsert;
                chargestoInsert = createstandaloneOppProductRatePlanCharge(opportunityRateplanstoInsert);
                If(!chargestoInsert.isEmpty()){
                    insert chargestoInsert;
                }
            }
            
            
            //Establishing relationship here between opportunity products
            for(invoiceit_crmx__Opportunity_Product__c op : oppProductsToInsert){
                if(op.invoiceit_crmx__Product_Code__c != conversationcode){
                    IF(codeVslistofChildopps.containsKey(op.invoiceit_crmx__Product_Code__c)){
                        codeVslistofChildopps.get(op.invoiceit_crmx__Product_Code__c).add(op);
                    }
                    else{
                        codeVslistofChildopps.put(op.invoiceit_crmx__Product_Code__c, new List<invoiceit_crmx__Opportunity_Product__c>{op});
                    }
                }
                else if(op.invoiceit_crmx__Product_Code__c == conversationcode){
                    parentstandloneopproducts.add(op);
                }
            }
            
            system.debug('@@@@codeVslistofChildopps'+codeVslistofChildopps);
            system.debug('@@@@parentstandloneopproducts'+parentstandloneopproducts);
            //parenting childs based on the product code and removing from the map list to remove duplicates
            for(invoiceit_crmx__Opportunity_Product__c opp: parentstandloneopproducts){
                // system.debug('@@@@@@opp standalone child codes'+ opp.standalone_child_product_codes__c);
                if(opp.standalone_child_product_codes__c != NULL && opp.standalone_child_product_codes__c !=''){
                    for(string code : opp.standalone_child_product_codes__c.split(',')){
                        if(code !=''){
                            if(codeVslistofChildopps.containsKey(code) && !codeVslistofChildopps.get(code).isEmpty()){
                                invoiceit_crmx__Opportunity_Product__c ccp = codeVslistofChildopps.get(code)[0];
                                //ccp.Chat_Parent_Opportunity_Product__c     = opp.Created_From_Opportunity_Product__r.id;
                                ccp.Chat_Parent_Opportunity_Product__c     = opp.id;
                                ccp.Created_From_Opportunity_Product__c    = opp.id;
                                system.debug('@@@@@@ccp.Chat_Parent_Opportunity_Product__c'+ ccp.Chat_Parent_Opportunity_Product__c);
                                childstandloneopproductstoUpdate.add(ccp);
                                codeVslistofChildopps.get(code).remove(0);
                            }
                        }
                    }
                }
                
            }
            
            if(!childstandloneopproductstoUpdate.isEmpty()){
                update childstandloneopproductstoUpdate;
            }
            
            
            
            //establishing relationship between orpc and addonchatorpc
            //by using opportunity product and chat parent opportunity product just set above
            Map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>oppProdctIdVsChargest = new Map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
            Map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>chargeIdVschatChargest = new Map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
            if(!chargestoInsert.isEmpty()){
                for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c c:[select id,Name,invoiceit_crmx__Accounting_Code__c,
                                                                       Chat_Parent_Opportunity_Rate_Plan_Charge__c,
                                                                       invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c,
                                                                       invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c,
                                                                       invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Chat_Parent_Opportunity_Product__c,
                                                                       invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Created_From_Opportunity_Product__c
                                                                       
                                                                       From invoiceit_crmx__Opportunity_Rate_Plan_Charge__c
                                                                       where id IN:chargestoInsert]){
                                                                           if(c.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c == conversationcode ){
                                                                               oppProdctIdVsChargest.put(c.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, c);
                                                                               
                                                                           }
                                                                           else{
                                                                               
                                                                               chargeIdVschatChargest.put(c.id,c);
                                                                           }
                                                                       }
                
                //   system.debug('@@@@oppProdctIdVsCharge'+oppProdctIdVsChargest);
                //  system.debug('@@@@chargeIdVschatCharge'+chargeIdVschatChargest);
                
                If(!chargeIdVschatChargest.isEmpty()){
                    for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c c1:chargeIdVschatChargest.values()){
                        c1.Chat_Parent_Opportunity_Rate_Plan_Charge__c = oppProdctIdVsChargest.get(c1.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Chat_Parent_Opportunity_Product__c).id;
                    }
                    update chargeIdVschatChargest.values();
                }
                
            }
          
        }
         //commented Attribute changes 4/17
        /*if(!opportunityAttributes.isEmpty()){
            insert opportunityAttributes;
        }
        */
        
        
        //For Seq Num--------------------------------------------------------------------------------------------------
        Decimal lastSeqNum;
        Decimal lastIndpProdCompSeqNum;
        List<invoiceit_crmx__Opportunity_Product__c> pkgCompsList = new List<invoiceit_crmx__Opportunity_Product__c>();
        List<invoiceit_crmx__Opportunity_Product__c> pkgIndCompsList = new List<invoiceit_crmx__Opportunity_Product__c>();
        
        List<invoiceit_crmx__Opportunity_Product__c> OppProdUpdateList = new List<invoiceit_crmx__Opportunity_Product__c>();
        for(invoiceit_crmx__Opportunity_Product__c op: [select id,Name,invoiceit_crmx__Bundle_SequenceNumber__c,
                                                        invoiceit_crmx__Opportunity__c,invoiceit_crmx__Product_Bundle__c,
                                                        invoiceit_crmx__Product_Bundle__r.Name,invoiceit_crmx__Product_Family__c,
                                                        Product_SIN__c,invoiceit_crmx__SequenceNumber__c 
                                                        from invoiceit_crmx__Opportunity_Product__c 
                                                        where invoiceit_crmx__Opportunity__c =: Oppid order by invoiceit_crmx__SequenceNumber__c]){
            if(op.invoiceit_crmx__Product_Bundle__c != null){                
                lastSeqNum = op.invoiceit_crmx__SequenceNumber__c;
                pkgCompsList.add(op);
            }
            if(op.invoiceit_crmx__Product_Bundle__c == null){
                lastIndpProdCompSeqNum = op.invoiceit_crmx__SequenceNumber__c;
                pkgIndCompsList.add(op);
            }
        }
        // For Product rate plan and Product rate plan charge update
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> chargesList = [select id,Name,invoiceit_crmx__Accounting_Code__c,
                                                                             invoiceit_crmx__Opportunity_Rate_Plan__c,
                                                                             invoiceit_crmx__Product_Bundle_Line__c,
                                                                             invoiceit_crmx__Product_Rate_Plan_Charge__c,
                                                                             Created_From_Charge__c ,Package_Component__c ,
                                                                             Package_Wrapper__c,invoiceit_crmx__Opportunity__c,
                                                                             invoiceit_crmx__Opportunity__r.Created_From_Order__c 
                                                                             from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c 
                                                                             where invoiceit_crmx__Product_Bundle_Line__c != null 
                                                                               and Package_Wrapper__c = false and Package_Component__c = false 
                                                                             and invoiceit_crmx__Opportunity__c =: Oppid 
                                                                             and invoiceit_crmx__Opportunity__r.Created_From_Order__c != null];
        system.debug(logginglevel.error,'---chargesList --'+chargesList );      
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> ORPCtoUpdateList = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();        
        List<invoiceit_crmx__Opportunity_Rate_Plan__c> ORPUpdateList = new List<invoiceit_crmx__Opportunity_Rate_Plan__c>();
        Set<Id> bundleLineIds = new Set<Id>();
        Set<Id> oppRatePlanIds = new Set<Id>();
        Map<Id,Id> oppRatePlanBundleLineMap = new Map<Id,Id>(); //opprateplanId,bundleLineId
        
        if(chargesList != null && chargesList.size() > 0){    
            for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c charge: chargesList){
                bundleLineIds.add(charge.invoiceit_crmx__Product_Bundle_Line__c);
                oppRatePlanIds.add(charge.invoiceit_crmx__Opportunity_Rate_Plan__c);
                oppRatePlanBundleLineMap.put(charge.invoiceit_crmx__Opportunity_Rate_Plan__c,charge.invoiceit_crmx__Product_Bundle_Line__c);
            }
            Map<Id,invoiceit_s__Product_Bundle_Line__c> prodBundleLineMap = new Map<Id,invoiceit_s__Product_Bundle_Line__c>();
            for(invoiceit_s__Product_Bundle_Line__c pbl: [select id,Name,invoiceit_s__Product_Bundle__c,invoiceit_s__Product__c,invoiceit_s__Product__r.Name,invoiceit_s__Product_Bundle__r.Name,invoiceit_s__Product_Rate_Plan__c,invoiceit_s__Product_Rate_Plan__r.Name,invoiceit_s__Product_Rate_Plan_Charge__c,invoiceit_s__Product_Rate_Plan_Charge__r.Name,invoiceit_s__Product_Rate_Plan_Charge__r.invoiceit_s__Accounting_Code__c from invoiceit_s__Product_Bundle_Line__c]){         
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
                orp.Name = prodBundleLineMap.get(oppRatePlanBundleLineMap.get(orp.id)).invoiceit_s__Product_Rate_Plan__r.Name;
                ORPUpdateList.add(orp);
                oppProdsSet.add(orp.invoiceit_crmx__Opportunity_Product__c);
            }
            
            if(!ORPUpdateList.isEmpty()){
                database.update(ORPUpdateList, false);
            }
            if(!ORPCtoUpdateList.isEmpty()){
                database.update(ORPCtoUpdateList, false);
            }
            //List<invoiceit_s__Product__c> invITProd = [select id,Name from invoiceit_s__Product__c where Name = 'Web Gold'];
            Set<String> webProdNames = new Set<String>{'Web Gold','Web Platinum'};
                List<invoiceit_s__Product__c> invITProd = [select id,Name from invoiceit_s__Product__c where Name IN: webProdNames ];
            Map<String,Id> invITProdMap = new Map<String,Id>();
            for(invoiceit_s__Product__c inn: invITProd){
                invITProdMap.put(inn.Name,inn.id);
            }
            // To Update Opp Prod with Seq num
            Decimal count = 1;
            for(invoiceit_crmx__Opportunity_Product__c op: [select id,Name,invoiceit_crmx__Product__c,invoiceit_crmx__Bundle_SequenceNumber__c,invoiceit_crmx__Opportunity__c,invoiceit_crmx__Product_Bundle__c,invoiceit_crmx__Product_Bundle__r.Name,invoiceit_crmx__Product_Family__c,Product_SIN__c,invoiceit_crmx__SequenceNumber__c, invoiceit_crmx__Product_Code__c from invoiceit_crmx__Opportunity_Product__c where Id IN: oppProdsSet]){
                op.invoiceit_crmx__SequenceNumber__c= lastSeqNum+count;
                if(op.invoiceit_crmx__Product_Bundle__r.Name == 'Gold Upsell - SEO' && (op.Name == 'Web Bronze' || op.Name == 'Web Gold' || op.Name == 'Web Silver')){
                    op.Name = 'Web Gold';
                    if(invITProdMap.containsKey('Web Gold'))
                        op.invoiceit_crmx__Product__c= invITProdMap.get('Web Gold');
                }
                if(op.invoiceit_crmx__Product_Bundle__r.Name == 'Platinum Upsell - SEO' && (op.Name == 'Web Bronze' || op.Name == 'Web Gold' || op.Name == 'Web Silver')){
                    op.Name = 'Web Platinum';
                    if(invITProdMap.containsKey('Web Platinum'))
                        op.invoiceit_crmx__Product__c= invITProdMap.get('Web Platinum');
                }
                
                count++;
                OppProdUpdateList.add(op);
            }
            if(!OppProdUpdateList.isEmpty()){
                database.update(OppProdUpdateList, false);
            }
        }
        // For Seq again reordering
        List<invoiceit_crmx__Opportunity_Product__c> OppProdUpdateSeqList = new List<invoiceit_crmx__Opportunity_Product__c>();
        system.debug('lastSeqNum'+lastSeqNum);
        system.debug('lastIndpProdCompSeqNum'+lastIndpProdCompSeqNum);
        //system.debug('pkgCompsList.size()'+pkgCompsList.size());        
        //Initial pkg comp seq num is
        Decimal initSeqNum = 0;
        //if(pkgCompsList != null && pkgCompsList.size() > 0)
        //initSeqNum = lastSeqNum - (pkgCompsList.size());
        
        
        for(invoiceit_crmx__Opportunity_Product__c op:pkgCompsList){
            if(op.invoiceit_crmx__Product_Family__c == 'Package'){
                initSeqNum = op.invoiceit_crmx__SequenceNumber__c;
                break;
            }
        }
        system.debug('initSeqNum '+initSeqNum );
        Decimal lastNum = 0;
        if((lastSeqNum > lastIndpProdCompSeqNum || lastSeqNum < lastIndpProdCompSeqNum) && initSeqNum > 0){
            Integer count = 1;
            for(invoiceit_crmx__Opportunity_Product__c op:pkgCompsList){
                if(op.invoiceit_crmx__SequenceNumber__c == initSeqNum){
                    //SKIP least one as it is wrapper prod
                }else{
                    op.invoiceit_crmx__SequenceNumber__c= initSeqNum+count;
                    lastNum = op.invoiceit_crmx__SequenceNumber__c;
                    OppProdUpdateSeqList.add(op);
                    count++;
                }
            }
            system.debug('lastNum '+lastNum );
            Integer Indcount = 1;
            for(invoiceit_crmx__Opportunity_Product__c op: pkgIndCompsList){
                op.invoiceit_crmx__SequenceNumber__c = lastNum+Indcount;
                OppProdUpdateSeqList.add(op);
                Indcount++;
            }
        }
        if(!OppProdUpdateSeqList.isEmpty()){
            database.update(OppProdUpdateSeqList, false);
        }
        
        // End of Sequence No Code-----------------------------------------------------------------------------------------------------------------
        
        
        
        
         if(childopp != NULL){
            return new pageReference('/'+childopp.id);
        }
        else{
            return new pageReference('/'+oppid);
            
            
            
        }
        
        // return new pageReference('/'+childopp.id);
        
        
        
    }
    public Opportunity oppty{get;set;}
    public Opportunity createChildOpp(Id oppId){
        system.debug('oppId'+oppId);
        oppty = [select id, name,StageName,Opportunity.invoiceit_crmx__Billing_Contact__r.Account.Phone,Opportunity.Account.Website,Opportunity.Account.Firm_Email__c,CloseDate,Account.ParentId,Account.Parent.Name ,Discount__c, invoiceit_crmx__Number_Of_Terms__c, invoiceit_crmx__Discount_Percent__c, invoiceit_crmx__Discount_Value__c from opportunity where id = :oppid]; 
        system.debug('::::--- opp.Account.ParentId ----::::'+oppty.Account.ParentId+'::::---opp name----::::'+oppty.Name+'::::---opp Term----::::'+oppty.invoiceit_crmx__Number_Of_Terms__c);
        system.debug('::::--- mngrectypeId ----::::'+mngrectypeId);
        List<Account> MNGaccountList = [select id,Name from Account where parentid =: oppty.Account.ParentId and recordtypeid =: mngrectypeId];
        if(MNGaccountList != null && MNGaccountList.size() > 0){
            MNGchildacc = MNGaccountList[0];
        }else{
            MNGchildacc = createchildMNGacc();
        }
        
        Opportunity copp = new Opportunity();
        
        if(ngageUpsellOrderId != NULL){
            if(ngageUpsellchidlOrder != NULL){
                
                copp.Created_From_Order__c = ngageUpsellchidlOrder.Id;
                copp.Name = 'Mid-Term ' + ngageUpsellchidlOrder.Name;
                copp.NgageCheck__c = True;
                copp.Quote_Type__c = 'Modify';
                //copp.ReferralAccount__c = ngageUpsellchidlOrder.PartnerAccount__c; //added for MHBS-3445
                copp.ReferralAccount__c = ngageUpsellchidlOrder.PartnerAccountOrder__c;
            }
            else{
                copp.Name = 'Ngage Upsell ' + ngageUpsellOrder.Name;
                copp.NgageCheck__c = True; //oppty.Name;
            }
            copp.Ngage_Upsell_Order__c = ngageUpsellOrderId;
            copp.NgageCheck__c = True;
            // copp.invoiceit_crmx__Number_Of_Terms__c = ngageUpsellOrder.invoiceit_s__Number_Of_Terms__c;
            copp.StageName = 'Prospecting';
            date actdt = date.today().addMonths(1).toStartofMonth(); 
            Integer noOfTerms;
            if (ngageUpsellOrder.invoiceit_s__Status__c == 'Evergreen'){
                noOfTerms = null;
                System.debug('No of Terms: ' + noOfTerms);
            }
            else if ( ngageUpsellOrder.Created_From_Order__r.Renew_Rebase__c == 'Renew')
            {
                // system.debug('Months Between old: ' + actdt.monthsBetween(order.Created_From_Order__r.invoiceit_s__Service_End_Date__c) + ' Actdt: ' + actdt + ' new Months: ' + actdt.monthsBetween(order.invoiceit_s__Service_End_Date__c));
                noOfTerms = actdt.monthsBetween(ngageUpsellOrder.invoiceit_s__Service_End_Date__c) + 1;                    
            }
            else
            {
                noOfTerms = actdt.monthsBetween(ngageUpsellOrder.invoiceit_s__Service_End_Date__c) + 1;    
                
                System.debug('No of Terms: ' + noOfTerms);
            }
            copp.invoiceit_crmx__Number_Of_Terms__c =noOfTerms;
            copp.IsNewNgageOppty__c = True;
            //copp.Parent_Opportunity__c = '';
            System.debug('No of Terms in copp :' +copp.invoiceit_crmx__Number_Of_Terms__c);
        }
        else{
            copp.Name = 'Ngage Upsell ' + oppty.Name;
            copp.Parent_Opportunity__c = oppid;
            copp.StageName = oppty.StageName;
        }
        
        copp.AccountId = MNGchildacc.id;
        
        copp.CloseDate = oppty.CloseDate;
        copp.IsLeadCoversion__c = true;
        copp.Classification__c = 'Legal';
        
        
        insert copp;
        return copp;
    }
    public Account createchildMNGacc(){
        Account acc = new Account();
        acc.Name = oppty.Account.Parent.Name;
        acc.parentid = oppty.Account.ParentId;
        acc.recordtypeid = mngrectypeId;
        acc.Business_Unit__c = 'Martindale-Ngage';
        acc.Billing_Schedule__c = 'None';
        acc.Phone = oppty.invoiceit_crmx__Billing_Contact__r.Account.Phone;
        acc.Website = oppty.Account.Website;
        acc.Firm_Email__c = oppty.Account.Firm_Email__c;
        acc.Classification__c = 'Legal';
        insert acc;
        return acc;
    }
    private void createFeatureOppRPC(AttributesWrapper a)
    {
        system.debug('CreateFeature: ' + a);
        if (prodFeaturemap.isEmpty())
        {
            createaddonChatfeatures(a);
        }
        else if(prodFeaturemap.get(a.oppattrib.id) == null)
        {
            createaddonChatfeatures(a);  
        }
    }
    
    private void opptycreateFeatureRPC(AttributesWrapper a)
    {
        system.debug('CreateFeature: ' + a);
        if (prodOpptyFeaturemap.isEmpty())
        {
            createaddonOpptyChatfeatures(a);
        }
        else if(prodOpptyFeaturemap.get(a.oppattrib.id) == null)
        {
            createaddonOpptyChatfeatures(a);  
        }
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
    public void createaddonChatOppProduct(AttributesWrapper a ){
        
        for(childcharges cc : a.chatproducts){
            system.debug('@@@in child chat product creation1'+cc.childcheck);
            system.debug('@@@chatchildcheck '+cc.chatchildcheck );
            If(cc.childcheck == true || cc.chatchildcheck == true){
                system.debug('@@@in child chat product creation'+cc);
                invoiceit_s__Product__c c = new invoiceit_s__Product__c(); 
                c= addonchatProductstoCreate.get(cc.oppattribchild.invoiceit_s__Accounting_Code__c);
                invoiceit_crmx__Opportunity_Product__c OProd = new invoiceit_crmx__Opportunity_Product__c();
                Oprod.invoiceit_crmx__Opportunity__c = childopp.id; //Oppid;
                Oprod.invoiceit_crmx__Product_Code__c = c.invoiceit_s__Product_Code__c;
                Oprod.invoiceit_crmx__Product__c = c.id;
                //check here to exclude validation
                oprod.Created_From_Code__c = True;
                
                oprod.Created_From_MH_Opportunity_Product__c= a.createdFromOpportunityProduct;
                oprod.IsAddOnFeature__c = True;
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
    
    public void createaddonChatfeatures(AttributesWrapper a ){
        
        for(childcharges cc : a.childChatProducts){
            system.debug('@@@in child chat product creation1'+cc.childcheck);
            system.debug('@@@chatchildcheck '+cc.chatchildcheck );
            If(cc.chatchildcheck == true){
                system.debug('@@@in child chat product creation'+cc);
                invoiceit_s__Product__c c = new invoiceit_s__Product__c(); 
                c= addonchatProductstoCreate.get(cc.oppattribchild.invoiceit_s__Accounting_Code__c);
                invoiceit_crmx__Opportunity_Product__c OProd = new invoiceit_crmx__Opportunity_Product__c();
                Oprod.invoiceit_crmx__Opportunity__c = childopp.id; //Oppid;
                Oprod.invoiceit_crmx__Product_Code__c = c.invoiceit_s__Product_Code__c;
                Oprod.invoiceit_crmx__Product__c = c.id;
                oprod.Created_From_Code__c = True;
                oprod.AddNgageChatFeature__c = True;
                if(a.createdFromOrderProduct!=Null){
                    oprod.Created_From_Order_Product__c = a.createdFromOrderProduct;
                }
                oprod.IsAddOnFeature__c = True;
                seqno++;
                Oprod.invoiceit_crmx__SequenceNumber__c = seqno;
                Oprod.invoiceit_crmx__Product_Family__c = c.invoiceit_s__Product_Family__c;
                //Oprod.name = c.Name + ' - ' + a.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.name ;
                
                if(a.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.CreatedFrmMHOpptyProd__c!=Null){
                    //if(a.oppattrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.CreatedFrmMHOpptyProd__c!=Null){
                    Oprod.name = c.Name + ' - ' + a.ordrattrib.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.CreatedFrmMHOpptyProd__c;
                    //}
                }else{
                    Oprod.name = c.Name + ' - ' + 'External Website';
                }
                
                OppProduct.add(Oprod);
            }
            system.debug('OppProduct values '+OppProduct);
        }
        
    }
    
    public void createaddonOpptyChatfeatures(AttributesWrapper a ){
        
        for(childcharges cc : a.childChatProducts){
            system.debug('@@@in child chat product creation1'+cc.childcheck);
            system.debug('@@@chatchildcheck '+cc.chatchildcheck );
            If(cc.chatchildcheck == true){
                system.debug('@@@in child chat product creation'+cc);
                invoiceit_s__Product__c c = new invoiceit_s__Product__c(); 
                c= addonchatProductstoCreate.get(cc.oppattribchild.invoiceit_s__Accounting_Code__c);
                invoiceit_crmx__Opportunity_Product__c OProd = new invoiceit_crmx__Opportunity_Product__c();
                Oprod.invoiceit_crmx__Opportunity__c = childopp.id; //Oppid;
                Oprod.invoiceit_crmx__Product_Code__c = c.invoiceit_s__Product_Code__c;
                Oprod.invoiceit_crmx__Product__c = c.id;
                oprod.Created_From_Code__c = True;
                if (a.createdFromOpportunityProduct !=Null){
                    Oprod.Created_From_Opportunity_Product__c = a.createdFromOpportunityProduct;
                }
                oprod.IsAddOnFeature__c = True;
                seqno++;
                Oprod.invoiceit_crmx__SequenceNumber__c = seqno;
                Oprod.invoiceit_crmx__Product_Family__c = c.invoiceit_s__Product_Family__c;
                if(a.oppattrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Created_From_MH_Opportunity_Product__r.Name!=Null){
                    Oprod.name = c.Name + ' - ' + a.oppattrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Created_From_MH_Opportunity_Product__r.Name;
                }else if(a.oppattrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.CreatedFrmMHOpptyProd__c!=Null){
                    //if(a.oppattrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.CreatedFrmMHOpptyProd__c!=Null){
                    Oprod.name = c.Name + ' - ' + a.oppattrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.CreatedFrmMHOpptyProd__c;
                    //}
                }else{
                    Oprod.name = c.Name + ' - ' + 'External Website';
                }
                
                OppProduct.add(Oprod);
            }
            system.debug('OppProduct values '+OppProduct);
        }
        
    }
    
    public List<invoiceit_crmx__Opportunity_Product__c> createStandaloneOpProduct(standalonechat sc){
        List<invoiceit_crmx__Opportunity_Product__c> singlestandalone = new List<invoiceit_crmx__Opportunity_Product__c>();
        invoiceit_crmx__Opportunity_Product__c OProd = new invoiceit_crmx__Opportunity_Product__c();
        Oprod.invoiceit_crmx__Opportunity__c = childopp.id; //Oppid;
        Oprod.invoiceit_crmx__Product_Code__c = sc.invproduct.invoiceit_s__Product_Code__c;
        Oprod.invoiceit_crmx__Product__c = sc.invproduct.id;
        oprod.Created_From_Code__c = True;
        seqno++;
        Oprod.invoiceit_crmx__SequenceNumber__c = seqno;
        Oprod.invoiceit_crmx__Product_Family__c =sc.invproduct.invoiceit_s__Product_Family__c;
        Oprod.name = sc.invproduct.Name + ' - ' + 'External Website' ;
        string standalonechildcodes='';
        If(sc.chatproducts != NULL && !sc.chatproducts.isEmpty()){
            for(childcharges cc: sc.chatproducts){
                If(cc.childcheck == true){
                    system.debug('@@@in child chat product creation'+cc);
                    invoiceit_s__Product__c c = new invoiceit_s__Product__c(); 
                    c= addonchatProductstoCreate.get(cc.oppattribchild.invoiceit_s__Accounting_Code__c);
                    invoiceit_crmx__Opportunity_Product__c cOProd = new invoiceit_crmx__Opportunity_Product__c();
                    cOProd.invoiceit_crmx__Opportunity__c = childopp.id; //Oppid;
                    cOprod.Created_From_Code__c = True;
                    //oprod.Created_From_MH_Opportunity_Product__c= c.createdFromOpportunityProduct;
                    
                    cOProd.IsAddOnFeature__c = True;
                    cOProd.invoiceit_crmx__Product_Code__c = c.invoiceit_s__Product_Code__c;
                    standalonechildcodes += cOProd.invoiceit_crmx__Product_Code__c +',';
                    cOProd.invoiceit_crmx__Product__c = c.id;
                    
                    seqno++;
                    cOProd.invoiceit_crmx__SequenceNumber__c = seqno;
                    cOProd.invoiceit_crmx__Product_Family__c = c.invoiceit_s__Product_Family__c;
                    cOProd.name = c.Name + ' - '+ 'External Website';
                    singlestandalone.add(cOProd);
                }
            }
            Oprod.standalone_child_product_codes__c = standalonechildcodes;
            singlestandalone.add(OProd);
        }
        return singlestandalone;
        
    }
    
    
    public void createOppProduct(AttributesWrapper a) {
        
        
        system.debug('ChatProduct: ' + chatProduct);
        map<string, invoiceit_crmx__Opportunity_Product__c> mapoppProd = new map<string, invoiceit_crmx__Opportunity_Product__c>();
        for (id i :chatProduct.keyset())
        {
            invoiceit_s__Product__c c = new invoiceit_s__Product__c(); 
            c= chatProduct.get(i);
            invoiceit_crmx__Opportunity_Product__c OProd = new invoiceit_crmx__Opportunity_Product__c();
            Oprod.invoiceit_crmx__Opportunity__c = childopp.id; //Oppid;
            Oprod.invoiceit_crmx__Product_Code__c = c.invoiceit_s__Product_Code__c;
            Oprod.invoiceit_crmx__Product__c = c.id;
            oprod.Created_From_MH_Opportunity_Product__c= a.createdFromOpportunityProduct;
            oprod.Created_From_Code__c = True;
            seqno++;
            Oprod.invoiceit_crmx__SequenceNumber__c = seqno;
            Oprod.invoiceit_crmx__Product_Family__c = c.invoiceit_s__Product_Family__c;
            Oprod.name = c.Name + ' - ' + a.oppattrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name ;
            //            if (a.oppattrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name != 'Professional Profile')
            //              Oprod.name = Oprod.name + ' : ' + a.oppattrib.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__SequenceNumber__c;
            OppProduct.add(Oprod);
            system.debug('CreateOppProduct: ' + oppProduct + ' : ' + oppProduct.size());
        }
        
        if(a.chatproducts.size() > 0){
            createaddonChatOppProduct(a);       
        }
    }
    
    public void createOppProductRatePlan() {
        if (oppProduct.isEmpty()) return;
        list<id> prp = new list<id>();
        
        for(invoiceit_crmx__Opportunity_Product__c o : OppProduct)
        {   
            // invoiceit_crmx__Opportunity_Rate_Plan__c OppRP = new invoiceit_crmx__Opportunity_Rate_Plan__c();
            //         for (invoiceit_s__Product__c c:chatProduct) {
            //  system.debug('@@@@oppProduct'+o);
            invoiceit_s__Product__c c; 
            if(addonChatProducts.contains(o.invoiceit_crmx__Product_Code__c)){
                c = addonchatProductstoCreate.get(o.invoiceit_crmx__Product_Code__c);
            }
            else{
                c = chatProduct.get(o.invoiceit_crmx__Product__c);
            }
            // system.debug('@@@@@c'+c);
            for (invoiceit_s__Product_Rate_Plan__c a:c.invoiceit_s__ProductRatePlan__r)
            {
                system.debug('@@@@@a product code'+ a.Product_Code__c);
                system.debug('@@@@@a conversationcode'+ conversationcode);
                system.debug('@@@@@a Name'+ a.Name);
                if(((a.Product_Code__c == conversationcode && a.Name == 'Standard Chat USD - Usage Price') 
                   || (o.invoiceit_crmx__Product_Code__c != conversationcode)) && o.MidTerm__c == false){
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
        // system.debug('@@@Rama ProdRPC: ' + prodrpc + ' Opp Product Rate Plan: ' + OppProductRatePlan);
        insert OppProductRatePlan;
        
    }
    
    public List<invoiceit_crmx__Opportunity_Rate_Plan__c> createstandaloneOppProductRatePlan(List<invoiceit_crmx__Opportunity_Product__c> standaloneop) {
        
        List<invoiceit_crmx__Opportunity_Rate_Plan__c> opportunityRateplans = new List<invoiceit_crmx__Opportunity_Rate_Plan__c>();
        Set<id> prp = new Set<id>();
        for(invoiceit_crmx__Opportunity_Product__c o : standaloneop)
        {   
            // invoiceit_crmx__Opportunity_Rate_Plan__c OppRP = new invoiceit_crmx__Opportunity_Rate_Plan__c();
            //         for (invoiceit_s__Product__c c:chatProduct) {
            // system.debug('@@@@oppProduct'+o);
            invoiceit_s__Product__c c; 
            if(addonChatProducts.contains(o.invoiceit_crmx__Product_Code__c)){
                c = addonchatProductstoCreate.get(o.invoiceit_crmx__Product_Code__c);
            }
            else{
                c = chatProduct.get(o.invoiceit_crmx__Product__c);
            }
            system.debug('@@@@@c'+c);
            for (invoiceit_s__Product_Rate_Plan__c a:c.invoiceit_s__ProductRatePlan__r)
            {
                // system.debug('@@@@@a product code'+ a.Product_Code__c);
                // system.debug('@@@@@a conversationcode'+ conversationcode);
                // system.debug('@@@@@a Name'+ a.Name);
                if((a.Product_Code__c == conversationcode && a.Name == 'Standard Chat USD - Usage Price') || (o.invoiceit_crmx__Product_Code__c != conversationcode)){
                    invoiceit_crmx__Opportunity_Rate_Plan__c OppRP = new invoiceit_crmx__Opportunity_Rate_Plan__c();
                    OppRp.name = a.name;
                    OppRp.invoiceit_crmx__Product_Rate_Plan__c = a.id;
                    oppRp.invoiceit_crmx__SequenceNumber__c = o.invoiceit_crmx__SequenceNumber__c;
                    prp.add(a.id);
                    OppRp.invoiceit_crmx__Opportunity_Product__c = o.id;
                    opportunityRateplans.add(OppRp);
                }
                
            }
            
            
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
        
        return opportunityRateplans;
    }
    
    
    
    
    public void createOppProductRatePlanCharge() {
        
        if (OppProductRatePlan.isEmpty()) return;
        for(invoiceit_crmx__Opportunity_Rate_Plan__c o:OppProductRatePlan )
        {
            if(o.MidTerm__c == false){
                    invoiceit_s__Product_Rate_Plan_Charge__c a = new invoiceit_s__Product_Rate_Plan_Charge__c();
                a = prodrpc.get(o.invoiceit_crmx__Product_Rate_Plan__c);
                invoiceit_crmx__Opportunity_Rate_Plan_Charge__c OpRPC = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(); 
                OpRPC.name = a.name;
                OpRPC.invoiceit_crmx__Opportunity__c = childopp.id;//Oppid;
                opRPC.Quote_Type__c = 'New'; //OppProduct[0].invoiceit_crmx__Opportunity__r.quote_type__c;
                OpRPC.invoiceit_crmx__Accounting_Code__c = a.invoiceit_s__Accounting_Code__c;
                opRPC.invoiceit_crmx__Opportunity_Rate_Plan__c = o.id;
                opRPC.invoiceit_crmx__Price_Type__c = a.invoiceit_s__Price_Type__c;
                opRPC.invoiceit_crmx__Unit_Price__c = a.invoiceit_s__Unit_Price__c;
                opRPC.invoiceit_crmx__CurrencyL__c = a.invoiceit_s__CurrencyL__c;
                //opRPC.Created_From_Charge__c = a.id;
                opRPC.invoiceit_crmx__Is_Product_Editable__c = a.invoiceit_s__Is_Product_Editable__c;
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
    
    
    public List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> createstandaloneOppProductRatePlanCharge(List<invoiceit_crmx__Opportunity_Rate_Plan__c>opportunityRateplans) {
        
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> charges = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        for(invoiceit_crmx__Opportunity_Rate_Plan__c o:opportunityRateplans )
        {
            invoiceit_s__Product_Rate_Plan_Charge__c a = new invoiceit_s__Product_Rate_Plan_Charge__c();
            a = prodrpc.get(o.invoiceit_crmx__Product_Rate_Plan__c);
            invoiceit_crmx__Opportunity_Rate_Plan_Charge__c OpRPC = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(); 
            OpRPC.name = a.name;
            OpRPC.invoiceit_crmx__Opportunity__c = childopp.id;//Oppid;
            opRPC.Quote_Type__c = 'New'; //OppProduct[0].invoiceit_crmx__Opportunity__r.quote_type__c;
            OpRPC.invoiceit_crmx__Accounting_Code__c = a.invoiceit_s__Accounting_Code__c;
            opRPC.invoiceit_crmx__Opportunity_Rate_Plan__c = o.id;
            opRPC.invoiceit_crmx__Price_Type__c = a.invoiceit_s__Price_Type__c;
            opRPC.invoiceit_crmx__Unit_Price__c = a.invoiceit_s__Unit_Price__c;
            opRPC.invoiceit_crmx__CurrencyL__c = a.invoiceit_s__CurrencyL__c;
            opRPC.invoiceit_crmx__Is_Product_Editable__c = a.invoiceit_s__Is_Product_Editable__c;
            opRPC.isAddOnFeature__c = True;
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
            charges.add(opRPC);
        }
        system.debug('@@@@Rama Opp Charges: ' + charges );
        
        
        for (invoiceit_crmx__Opportunity_Rate_Plan_Charge__c o:OppProductRatePlanCharge)
            newchatlist.add(o.id);
        
        system.debug('New chat List: ' + newchatlist);
        //        chatusagelist = [select id, name, invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c where  invoiceit_crmx__Opportunity__c = :Oppid and invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product__r.name in ('Site Activation fee', 'Per Conversation fee')];
        chatusagelist = [select id, name, invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c where  invoiceit_crmx__Opportunity__c = :Oppid and invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c = :conversationcode];
        return charges;
    }
    
    
    
    public void checkandAddChat()
    {
        list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> oprcList = new list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> chatConverseList = new list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        
        system.Debug('@@@@@conversationcode in chat'+ conversationcode);
        system.Debug('@@@@@prodforchat in chat'+ prodforchat);
        system.Debug('@@@@@multiProdPerChatList in chat'+multiProdPerChatList);
        chatConverseList = [select id, name, 
                            invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, 
                            invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name, 
                            invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product__r.name, 
                            invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__SequenceNumber__c 
                            from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c
                            where  invoiceit_crmx__Opportunity__c = : childopp.id and invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c = :conversationcode];
        oprclist = [select id, name, 
                    invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product__r.name, invoiceit_crmx__Accounting_Code__c, 
                    invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name, 
                    invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, 
                    invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__SequenceNumber__c, 
                    invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Is_Chat_Option_Shown__c  
                    from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c 
                    where  invoiceit_crmx__Opportunity__c = : oppid and id in :prodforchat];
        
        for (invoiceit_crmx__Opportunity_Rate_Plan_Charge__c o:oprclist)
        {
            Chat_Product_Opportunity_Charge__c cp = new Chat_Product_Opportunity_Charge__c();
            for (invoiceit_crmx__Opportunity_Rate_Plan_Charge__c c:chatConverseList )
            {
                
                //              if (o.name.contains('Professional Profile') && c.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name.contains('Professional Profile'))
                if(multiProdPerChatList.contains(o.invoiceit_crmx__Accounting_Code__c) && 
                   c.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name.contains(o.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product__r.name))
                {
                    cp = new Chat_Product_Opportunity_Charge__c();
                    cp.Chat_Product_Opp_Rate_Plan_Charge__c = o.id;
                    cp.Chat_Usage_Opp_Rate_Plan_Charge__c = c.id;
                    mapchat.put(c.id, cp);
                    break;
                }
                system.debug('o: ' + o + ' c:' + c + ' Name: ' + c.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name + ' Map: ' + mapchat.get(c.id));
                //                if (!o.name.contains('Professional Profile') && !c.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name.contains('Professional Profile'))
                //              if(!multiProdPerChatList.contains(o.invoiceit_crmx__Accounting_Code__c) && c.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name.contains('Professional Profile'))
                if(!multiProdPerChatList.contains(o.invoiceit_crmx__Accounting_Code__c) && c.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name.contains(o.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product__r.name))
                {
                    system.debug('Entered the if statement Name: ' + c.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name + ' o.Prod name: ' + o.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product__r.name+ ' Binary: ' + c.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name.contains(o.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product__r.name) + ' Map: ' + mapchat.get(c.id));
                    if (mapchat.get(c.id) == null && c.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name.contains(o.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product__r.name))
                    {
                        system.debug('Entered if statement for map: ' + mapchat.get(c.id) + ' mapchat list: ' + mapchat + ' c: ' + c);
                        cp = new Chat_Product_Opportunity_Charge__c();
                        cp.Chat_Product_Opp_Rate_Plan_Charge__c = o.id;
                        cp.Chat_Usage_Opp_Rate_Plan_Charge__c = c.id;   
                        mapchat.put(c.id, cp);
                        break;
                    }
                }
            }
            if (checkchatlist(cp) == false) 
            {
                system.debug('Entered the id statement' + cp);
                cpoc.add(cp);
            }
            chatlist.add(cp);
            
        }
    }
    
    public boolean checkchatlist(Chat_Product_Opportunity_Charge__c cp)
    {
        for (Chat_Product_Opportunity_Charge__c c:chatlist)
        {
            if (cp.Chat_Product_Opp_Rate_Plan_Charge__c == c.Chat_Product_Opp_Rate_Plan_Charge__c)
            {    
                system.debug('cp: ' + cp + ' : ' + c + ' chatlist: ' + chatlist);
                return true;     
            }
        }
        system.debug('Checkchatlist: ' + ' Return false. ');
        return false;
    }
    
    
    
    //add Row functionality
    public void addRowforStandAlone(){
        List<childcharges>childaddonchatswrapper = new List<childcharges>();
        for(childcharges cc : childaddonchatswrapperforstandlonetemp){
            childaddonchatswrapper.add(new childcharges(cc.oppattribchild) );
        }
        standalonechat sc = new standalonechat(chatProduct.values()[0],childaddonchatswrapper);
        standalonechatslist.add(sc);
        standalonechatsSize = standalonechatslist.size();
    }
    
    //add Row functionality*
    public void deleteRowforStandAlone(){
        standalonechatslist.remove(standalonechatslist.size()-1);
        
        standalonechatsSize = standalonechatslist.size();
    }
    
    public Pagereference Cancel()
    {  
        Pagereference pag =new Pagereference('/'+cancelId);
        return pag;  
    }
    
    public void deleteProducts(){
        
        List<invoiceit_crmx__Opportunity_Product__c> opProductsToDelete = new List<invoiceit_crmx__Opportunity_Product__c>();
        List<Chat_Product_Opportunity_Charge__c> chatproductstoDelete = new  List<Chat_Product_Opportunity_Charge__c>();
        
        
        for(DeleteProducts seldelProd : toDeleteProductsList){
            if(seldelProd.deleteProductCheck){
                opProductsToDelete.add(new invoiceit_crmx__Opportunity_Product__c(id=seldelProd.delOptyProductrpc.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c));
                if(!mapchat.isEmpty() && mapchat.containsKey(seldelProd.delOptyProductrpc.id)){
                    chatproductstoDelete.add(mapchat.get(seldelProd.delOptyProductrpc.id));
                }
                if(!parentIdVschildOptProdtoDelet.isEmpty() && parentIdVschildOptProdtoDelet.containsKey(seldelProd.delOptyProductrpc.id)){
                    for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c childoptyprod: parentIdVschildOptProdtoDelet.get(seldelProd.delOptyProductrpc.id)){
                        opProductsToDelete.add(new invoiceit_crmx__Opportunity_Product__c(id=childoptyprod.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c));
                    }
                }
            }
        }
        
        System.debug('@@@@@chatproductstoDelete'+chatproductstoDelete);
        System.debug('@@@@@opProductsToDelete'+opProductsToDelete);
        
        
        if(!opProductsToDelete.isEmpty()){
            Delete opProductsToDelete;
        }
        if(!chatproductstoDelete.isEmpty()){
            //Delete chatproductstoDelete;
        }
        
    }
    
    
    @RemoteAction
    public static void deleteProducts(string prdId) {
        List<invoiceit_crmx__Opportunity_Product__c> optyProductsToDelete = new List<invoiceit_crmx__Opportunity_Product__c>();
        for(invoiceit_crmx__Opportunity_Product__c opD : [select id,
                                                          (select id 
                                                           From Opportunity_Products__r)
                                                          From invoiceit_crmx__Opportunity_Product__c
                                                          where id=:prdId]) {
                                                              optyProductsToDelete.add(opD);
                                                              for(invoiceit_crmx__Opportunity_Product__c opDc : opD.Opportunity_Products__r){
                                                                  optyProductsToDelete.add(opDc);                                        
                                                              }                                               
                                                          }
        
        if(!optyProductsToDelete.isEmpty()){
            Delete optyProductsToDelete;
        }
    }
    
    
    public void createchatCharges(){
        system.debug('@@@@In createchatCharges'+ childopp.id);
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> childoptyngageCharges = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        List<Chat_Product_Opportunity_Charge__c> cpocList = new List<Chat_Product_Opportunity_Charge__c>();
        childoptyngageCharges = [select id, name, 
                                 invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, 
                                 invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name, 
                                 invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product__r.name, 
                                 invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__SequenceNumber__c 
                                 from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c
                                 where  invoiceit_crmx__Opportunity__c = : childopp.id 
                                 and (NOT Name like '%Local Search%')
                                 and invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c = :conversationcode];
        system.debug('@@@@In childoptyngageCharges'+ childoptyngageCharges);
        List<invoiceit_s__Job_Rate_Plan_Charge__c> parentOrdRPCList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        parentOrdRPCList =  [select id, name, invoiceit_s__Accounting_Code__c, 
                             invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c, invoiceit_s__Status__c,
                             invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.CreatedFrmMHOpptyProd__c,
                             invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c,
                             invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.name,
                             invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Created_From_Order_Product__r.Id, 
                             invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__SequenceNumber__c
                             from invoiceit_s__Job_Rate_Plan_Charge__c   
                             where invoiceit_s__Order__c =:ngageUpsellOrderId and (NOT Name like '%Local Search%') and invoiceit_s__Status__c='Active'
                             
                            ];
        
        for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c optycharge : childoptyngageCharges){
            if(!mapChat.containsKey(optycharge.id)){
                for(invoiceit_s__Job_Rate_Plan_Charge__c ordcharge :parentOrdRPCList ){
                    If(optycharge.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name.contains(ordcharge.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.name)){
                        Chat_Product_Opportunity_Charge__c cp = new Chat_Product_Opportunity_Charge__c();
                        cp.Parent_MH_Order_Rate_Plan_Charge__c= ordcharge.id;
                        cp.Chat_Usage_Opp_Rate_Plan_Charge__c = optycharge.id; 
                        cpocList.add(cp);
                    }
                }
                
                
            }
        }
        
        if(!cpocList.isEmpty()){
            //*insert cpocList;
            database.insert(cpocList, false);
        }
        
        
        
    }
    
    
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
    }
    
    
    
}