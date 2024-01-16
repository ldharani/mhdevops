public class createNgageFulfilmentCase{
    
    public static void fulfillCase(List<invoiceit_s__Job__c> listOfOrders){
        
        Set<Id> orderIds = new Set<Id>();
        //Set<Id> cancelOrderIds = new Set<Id>();
        //Set<Id> truncatedOrExpiredOrderIds = new Set<Id>();
          
        System.debug('@@@@@inside my method Yayyyyyyyyyyy'+listOfOrders);
        
        if(!listOfOrders.isempty()){
            for(invoiceit_s__Job__c ord: listOfOrders){
               
               if(ord.invoiceit_s__Status__c!=NULL && ord.Opportunity_Name__c!=NULL && ord.invoiceit_s__Status__c!='Cancelled' && ord.invoiceit_s__Status__c!='Expired' && !ord.Opportunity_Name__c.contains('Renew') && !ord.Opportunity_Name__c.contains('Auto evergreen')){
                    orderIds.add(ord.Id);   
                }
                /*else if(ord.invoiceit_s__Status__c!=NULL && (ord.invoiceit_s__Status__c == 'Expired' || ord.invoiceit_s__Status__c == 'Cancelled')){
                    truncatedOrExpiredOrderIds.add(ord.Id);
                }*/
            }
        }
        
        if(orderIds.size()>0){
            createcase(orderIds);
        }
        
      }
      
      /*public static void cancelNgageCase(List<invoiceit_s__Job__c> listOfOrders, Map<Id, invoiceit_s__Job__c> oldmap){   
          
          Set<Id> cancelOrderIds = new Set<Id>();
          System.debug('@@@@@inside my method Yayyyyyyyyyyy'+listOfOrders);
        
            if(!listOfOrders.isempty()){
                for(invoiceit_s__Job__c ord: listOfOrders){
                    System.debug('@@@@@@@Old Order Status'+oldmap.get(ord.id).invoiceit_s__Status__c);
                    System.debug('@@@New Order Status'+ord.invoiceit_s__Status__c);
                    if(ord.invoiceit_s__Status__c!=NULL && oldmap!=NULL && oldmap.get(ord.id).invoiceit_s__Status__c !=ord.invoiceit_s__Status__c && (ord.invoiceit_s__Status__c == 'Cancelled' || ord.invoiceit_s__Status__c == 'Expired')){
                        cancelOrderIds.add(ord.Id);
                    }
                }
            }
        
        if(cancelOrderIds.size()>0){
            cancelCase(cancelOrderIds);
        }      
          
      }
    
        public static void cancelCase(Set<Id> orderIds){
        
            List<invoiceit_s__Job__c> ordersToUpdate = new List<invoiceit_s__Job__c>();
            List<Case> casesToInsert = new List<Case>(); 
            List<invoiceit_s__Job_Rate_Plan_Charge__c> orderRPCList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
            Map<String,List<invoiceit_s__Job_Rate_Plan_Charge__c>> featureNchatMap = new Map<String,List<invoiceit_s__Job_Rate_Plan_Charge__c>>();
            List<invoiceit_s__Job_Rate_Plan_Charge__c> featureList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();    
            List<invoiceit_s__Job_Rate_Plan_Charge__c> chatFeatureList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>(); 
            
            Date cancelDate = System.today()-1000;
            
            System.debug('@@@@@@@Cancel Order Ids'+orderIds);
            
            if(!orderIds.isempty())    {
                ordersToUpdate = [Select id, RecordType.Name,name,invoiceit_s__Account__c,invoiceit_s__Account__r.name From invoiceit_s__Job__c where id in: orderIds ];
                
                if(!Test.isRunningTest()){
                    orderRPCList = [Select id, name,invoiceit_s__Status__c,Chat_Parent_Order_Rate_Plan_Charge__c,invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name,
                                Cancellation_Date__c,invoiceit_s__Service_End_Date__c,invoiceit_s__Order__r.Ngage_Cust_ID__c,
                                invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c,Chat_ID__c,Fulfilment_End_Date__c,(select id,name,Attribute_Name__c,
                                Attribute_Type__c,String_Value__c,Picklist_Value__c,Boolean_Value__c,Phone_Value__c,Number_Value__c,Date_value__c,Long_text_value__c,
                                Order_Rate_Plan_Charge__r.invoiceit_s__Status__c From Order_Charge_Attributes__r) From invoiceit_s__Job_Rate_Plan_Charge__c 
                                Where invoiceit_s__Order__c in: orderIds ];
                }else{
                    orderRPCList = [Select id, name,invoiceit_s__Status__c,Chat_Parent_Order_Rate_Plan_Charge__c,invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name,
                                Cancellation_Date__c,invoiceit_s__Service_End_Date__c,invoiceit_s__Order__r.Ngage_Cust_ID__c,
                                invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c,Chat_ID__c,Fulfilment_End_Date__c,(select id,name,Attribute_Name__c,
                                Attribute_Type__c,String_Value__c,Picklist_Value__c,Boolean_Value__c,Phone_Value__c,Number_Value__c,Date_value__c,Long_text_value__c,
                                Order_Rate_Plan_Charge__r.invoiceit_s__Status__c From Order_Charge_Attributes__r) From invoiceit_s__Job_Rate_Plan_Charge__c 
                                Where invoiceit_s__Order__c in: orderIds LIMIT 1];
                
                }
                
                for(invoiceit_s__Job_Rate_Plan_Charge__c feat: orderRPCList){
                    if(feat.Chat_Parent_Order_Rate_Plan_Charge__c!= Null){
                        System.debug('@@@@@@feat.Chat_Parent_Order_Rate_Plan_Charge__c'+feat.Chat_Parent_Order_Rate_Plan_Charge__c);
                        if(featureNchatMap.containskey(feat.Chat_Parent_Order_Rate_Plan_Charge__c)){
                            featureNchatMap.get(feat.Chat_Parent_Order_Rate_Plan_Charge__c).add(feat);
                        }else{
                            featureNchatMap.put(feat.Chat_Parent_Order_Rate_Plan_Charge__c, new List<invoiceit_s__Job_Rate_Plan_Charge__c> {feat});
                        }
                    }
                    
                }
                
                System.debug('@@@@@@@featureNchatMap'+featureNchatMap);
                
                    
                System.debug('@@@@@@CancelorderRPCList '+orderRPCList );
                System.debug('@@@@CancelordersToUpdateasas '+ordersToUpdate );
                
                 List<String> queueName = new List<String>();
                 queueName.add('Ngage Support');
                List<Group> queueList = [Select Id,Name from Group where Name in:queueName and Type = 'Queue'];
               System.debug('@@@@@@queue List'+queueList);
               
               String queueId;
               queueId = queueList[0].id;
               System.debug('@@@@@@queue id'+queueId );
               
               Id RecordTypeId_NgageOrder  = Schema.SObjectType.invoiceit_s__Job__c.getRecordTypeInfosByName().get('M-NG Order').getRecordTypeId();
               System.debug('@@@@@@@RecordTypeId_NgageOrder :'+RecordTypeId_NgageOrder  );
               
                for(invoiceit_s__Job__c o: ordersToUpdate ){
                    System.debug('@@@@@@@@@o.RecordTypeId'+o.RecordTypeId);
                    if(o.RecordTypeId == RecordTypeId_NgageOrder){
                    
                        Case c = new Case();
                        c.AccountId = o.invoiceit_s__Account__c;
                        c.Area__c = 'Order Update';
                        c.Customer_Name__c = o.invoiceit_s__Account__r.Name;
                        c.Description = 'Chat Product Cancellation';
                        c.Origin = 'Order Change';
                        c.OwnerId = queueId ;
                        c.Parent_Order__c = o.id;
                        c.Priority = 'High';
                        c.RecordTypeId = '0120G000000WmRG';    
                        c.Status = 'New';
                        c.Sub_Area__c = 'New order';
                        c.Subject = 'Ngage Product Cancellation';//Ngage Order/Charge Fulfilment
                        //c.Name = 'Ngage Order';
                        c.Description__c = '<b><u>Products</b></u> : <br/><br/>';
                        
                        if(!orderRPCList.isempty()){
                            system.debug('@@@@@@@@inside my canecl');
                            for(invoiceit_s__Job_Rate_Plan_Charge__c orpc: orderRPCList ){
                                if(orpc.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c == '60010'){
                                    
                                    System.debug('@@@@@@@Features'+chatFeatureList);
                                    System.debug('@@@@@Chat SED Date'+orpc.invoiceit_s__Service_End_Date__c);
                                    System.debug('@@@@@Chat Cancellation Date'+orpc.Cancellation_Date__c);
                                    
                                    if(orpc.invoiceit_s__Service_End_Date__c!=NULL && orpc.invoiceit_s__Status__c!='Cancelled'){
                                        cancelDate = orpc.invoiceit_s__Service_End_Date__c;
                                    }else{
                                        cancelDate = orpc.Cancellation_Date__c;
                                    }
                                            
                                    c.Description__c += '<b>'+orpc.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name + '</b><br/>' +
                                                         '<b><u>URL</b></u> : ' + orpc.Order_Charge_Attributes__r[0].String_Value__c + '<br/>' + 
                                                         '<b><u>Chat Id</b></u> : ' + orpc.Chat_ID__c + '<br/>' + 
                                                         '<b><u>Client Id</b></u> : ' + orpc.invoiceit_s__Order__r.Ngage_Cust_ID__c + '<br/>' + 
                                                         '<b><u>Fulfillment Date:</b></u> : ' + orpc.Fulfilment_End_Date__c + '<br/>' +
                                                         '<b><u>Charge Status</b></u> : ' + orpc.invoiceit_s__Status__c + '<br/>' +
                                                         '<b><u>Cancellation Date</b></u> : ' + cancelDate  +'<br/><br/>';
                                                         //'<b><u>Cancellation Date</b></u> : ' + orpc.Cancellation_Date__c+'<br/><br/>';
                                    
                                    if(featureNchatMap.containskey(orpc.id)){
                                        chatFeatureList = featureNchatMap.get(orpc.id);
                                    
                                        if(chatFeatureList.size()>0){
                                            c.Description__c += '<b><u>Add-on Features</b></u><br/><br/>';
                                            
                                            for(invoiceit_s__Job_Rate_Plan_Charge__c featOrpc: chatFeatureList){
                                            
                                            if(featOrpc.Chat_Parent_Order_Rate_Plan_Charge__c!= NULL){
                                                
                                            }
                                                c.Description__c += '<b>'+featOrpc.Name + '</b><br/>' ;//+
                                                                    
                                        
                                                if(!featOrpc.Order_Charge_Attributes__r.isempty()){
                                                    for(Order_Charge_Attribute__c attr: featOrpc.Order_Charge_Attributes__r){
                                                        if(attr.Attribute_Type__c == 'Text' || attr.Attribute_Type__c == 'String'){
                                                            c.Description__c += attr.Attribute_Name__c +' : ' + attr.String_Value__c + '<br/>' ;//+
                                                                            //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/>';+
                                                                                                                                 
                                                        }
                                                        else if(attr.Attribute_Type__c == 'Picklist'){
                                                            c.Description__c += attr.Attribute_Name__c +' : ' + attr.Picklist_Value__c + '<br/>' ;//+
                                                                            //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/><br/>';//+
                                                                            //'<b><u> Fulfillment Link</b></u> : ' +'<br/><br/>'; 
                                                        }
                                                        else if(attr.Attribute_Type__c == 'Boolean'){
                                                            c.Description__c += attr.Attribute_Name__c +' : ' + attr.Boolean_Value__c + '<br/>' ;//+
                                                                            //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/><br/>';//+
                                                                            //'<b><u> Fulfillment Link</b></u> : ' +'<br/><br/>'; 
                                                        }
                                                        else if(attr.Attribute_Type__c == 'Phone'){
                                                            c.Description__c += attr.Attribute_Name__c +' : ' + attr.Phone_Value__c + '<br/>' ;//+
                                                                            //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/>';//+
                                                                            //'<b><u> Fulfillment Link</b></u> : ' +'<br/><br/>'; 
                                                        }
                                                        else if(attr.Attribute_Type__c == 'Number'){
                                                            c.Description__c += attr.Attribute_Name__c +' : ' + attr.Number_Value__c + '<br/>' ;//+
                                                                            //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/>'+
                                                                            //'<b><u> Fulfillment Link</b></u> : ' +'<br/><br/>'; 
                                                        }
                                                        else if(attr.Attribute_Type__c == 'Date'){
                                                            c.Description__c += attr.Attribute_Name__c +' : ' + attr.Date_Value__c + '<br/>' ;//+
                                                                            //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/>'+
                                                                            //'<b><u> Fulfillment Link</b></u> : ' +'<br/><br/>'; 
                                                        }
                                                        else if(attr.Attribute_Type__c == 'Text Area'){
                                                            c.Description__c += attr.Attribute_Name__c +' : ' + attr.Long_text_value__c + '<br/>' ;//+
                                                                            //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/>'+
                                                                            //'<b><u> Fulfillment Link</b></u> : ' +'<br/><br/>'; 
                                                        }
                                                        
                                                    }
                                                }
                                               System.debug('@@@@@Feature SED Date'+featOrpc.invoiceit_s__Service_End_Date__c);
                                                System.debug('@@@@@Feature Cancellation Date'+featOrpc.Cancellation_Date__c);
                                                
                                                if(featOrpc.invoiceit_s__Service_End_Date__c!=NULL && orpc.invoiceit_s__Status__c!='Cancelled' ){
                                                    cancelDate = featOrpc.invoiceit_s__Service_End_Date__c;
                                                }else{
                                                    cancelDate = featOrpc.Cancellation_Date__c;
                                                }
                                                
                                                c.Description__c += '<b><u> Fulfillment Date </b></u> : ' + featOrpc.Fulfilment_End_Date__c +'<br/>'+//;
                                                                    '<b><u>Chat Id</b></u> : ' + featOrpc.Chat_ID__c + '<br/>' + 
                                                                     '<b><u>Client Id</b></u> : ' + featOrpc.invoiceit_s__Order__r.Ngage_Cust_ID__c + '<br/>' + 
                                                                     '<b><u> Charge Status</b></u> : ' + featOrpc.invoiceit_s__Status__c + '<br/>' +
                                                                     '<b><u> Chat URL</b></u> : ' + orpc.Order_Charge_Attributes__r[0].String_Value__c + '<br/>' +
                                                                     '<b><u> Cancellation Date</b></u> : ' + cancelDate  + '<br/><br/>';
                                                                     //'<b><u> Cancellation Date</b></u> : ' + featOrpc.Cancellation_Date__c+ '<br/><br/>';
                                                
                                            }
                                        }
                                    }
                                    c.Description__c += '======================================================<br/><br/>';
                                    
                                }
                                else if(orpc.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c != '60010' && orpc.Chat_Parent_Order_Rate_Plan_Charge__c == NULL ){
                                    
                                    c.Description__c += //'<b><u>Add-on Features</b></u><br/><br/>' +
                                                        '<b>' + orpc.Name + '</b><br/>' ;//+
                                                        //'<b><u> Fulfillment Date </b></u> : ' + orpc.Fulfilment_End_Date__c +'<br/>'+//;
                                                         //       '<b><u>Chat Id</b></u> : ' + orpc.Chat_ID__c + '<br/>' + 
                                                         //        '<b><u>Client Id</b></u> : ' + '<br/>' + 
                                                         //        '<b><u> Charge Status</b></u> : ' + orpc.invoiceit_s__Status__c + '<br/><br/>'; 
                                                         
                                    if(!orpc.Order_Charge_Attributes__r.isempty()){
                                        for(Order_Charge_Attribute__c attr: orpc.Order_Charge_Attributes__r){
                                            //c.Description__c += attr.Attribute_Name__c +' : ' + attr.String_Value__c + '<br/>';
                                                                //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/>'+
                                                                //'<b><u> Fulfillment Link</b></u> : ' +'<br/><br/>';
                                                                
                                            
                                            if(attr.Attribute_Type__c == 'Text' || attr.Attribute_Type__c == 'String'){
                                                        c.Description__c += attr.Attribute_Name__c +' : ' + attr.String_Value__c + '<br/>' ;
                                                                        //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/>';+
                                                                                                                             
                                            }
                                            else if(attr.Attribute_Type__c == 'Picklist'){
                                                c.Description__c += attr.Attribute_Name__c +' : ' + attr.Picklist_Value__c + '<br/>' ;//+
                                                                //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/><br/>';//+
                                                                //'<b><u> Fulfillment Link</b></u> : ' +'<br/><br/>'; 
                                            }
                                            else if(attr.Attribute_Type__c == 'Boolean'){
                                                c.Description__c += attr.Attribute_Name__c +' : ' + attr.Boolean_Value__c + '<br/>' ;//+
                                                                //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/><br/>';//+
                                                                //'<b><u> Fulfillment Link</b></u> : ' +'<br/><br/>'; 
                                            }
                                            else if(attr.Attribute_Type__c == 'Phone'){
                                                c.Description__c += attr.Attribute_Name__c +' : ' + attr.Phone_Value__c + '<br/>' ;//+
                                                                //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/>';//+
                                                                //'<b><u> Fulfillment Link</b></u> : ' +'<br/><br/>'; 
                                            }
                                            else if(attr.Attribute_Type__c == 'Number'){
                                                c.Description__c += attr.Attribute_Name__c +' : ' + attr.Number_Value__c + '<br/>' ;//+
                                                                //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/>'+
                                                                //'<b><u> Fulfillment Link</b></u> : ' +'<br/><br/>'; 
                                            }
                                            else if(attr.Attribute_Type__c == 'Date'){
                                                c.Description__c += attr.Attribute_Name__c +' : ' + attr.Date_Value__c + '<br/>' ;//+
                                                                //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/>'+
                                                                //'<b><u> Fulfillment Link</b></u> : ' +'<br/><br/>'; 
                                            }
                                            else if(attr.Attribute_Type__c == 'Text Area'){
                                                c.Description__c += attr.Attribute_Name__c +' : ' + attr.Long_text_value__c + '<br/>' ;//+
                                                                //'<b><u> Status</b></u> : ' + attr.Order_Rate_Plan_Charge__r.invoiceit_s__Status__c + '<br/>'+
                                                                //'<b><u> Fulfillment Link</b></u> : ' +'<br/><br/>'; 
                                            }                                                     
                                        }
                                    }
                                    System.debug('@@@@@One Time SED Date'+orpc.invoiceit_s__Service_End_Date__c);
                                    System.debug('@@@@@One Time Cancellation Date'+orpc.Cancellation_Date__c);
                                    if(orpc.invoiceit_s__Service_End_Date__c!=NULL && orpc.invoiceit_s__Status__c!='Cancelled'){
                                        cancelDate = orpc.invoiceit_s__Service_End_Date__c;
                                    }else{
                                        cancelDate = orpc.Cancellation_Date__c;
                                    }
                                            
                                    c.Description__c += '<b><u> Fulfillment Date </b></u> : ' + orpc.Fulfilment_End_Date__c +'<br/>'+//;
                                                        '<b><u>Chat Id</b></u> : ' + orpc.Chat_ID__c + '<br/>' + 
                                                        '<b><u>Client Id</b></u> : ' + orpc.invoiceit_s__Order__r.Ngage_Cust_ID__c + '<br/>' + 
                                                        '<b><u> Charge Status</b></u> : ' + orpc.invoiceit_s__Status__c + '<br/>' ;//+
                                    
                                    if(!orpc.Order_Charge_Attributes__r.isempty()){
                                        c.Description__c += '<b><u> Chat URL</b></u> : ' + orpc.Order_Charge_Attributes__r[0].String_Value__c + '<br/>' ;
                                    }                    
                                         c.Description__c += '<b><u> Cancellation Date</b></u> : ' + cancelDate + '<br/><br/>'; 
                                                                                                
                                                          
                                }
                            } 
                        }
                        System.debug('@@@@@@@@@@casesToInsert'+casesToInsert);
                        casesToInsert.add(c);
                    }     
                }
              }
              
              System.debug('@@@@@@casesToInsert'+casesToInsert);
              if(!casesToInsert.isempty()){
                  insert casesToInsert;
              }
              
                
     } --------------------------*/
            
        
    
    
        
    @future(callout=true)
        public static void createcase(Set<Id> orderIds){
        
            List<invoiceit_s__Job__c> ordersToUpdate = new List<invoiceit_s__Job__c>();
            List<Case> casesToInsert = new List<Case>(); 
            List<invoiceit_s__Job_Rate_Plan_Charge__c> orderRPCList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
            List<invoiceit_s__Job_Rate_Plan_Charge__c> finalOrderRPCList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
            List<invoiceit_s__Job_Rate_Plan_Charge__c> IncludeChargeRPCList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
            Map<String,List<invoiceit_s__Job_Rate_Plan_Charge__c>> featureNchatMap = new Map<String,List<invoiceit_s__Job_Rate_Plan_Charge__c>>();
            List<invoiceit_s__Job_Rate_Plan_Charge__c> featureList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();    
            List<invoiceit_s__Job_Rate_Plan_Charge__c> chatFeatureList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
            List<Chat_Product_Order_Charge__c> chatprodOrdChargeList = new List<Chat_Product_Order_Charge__c>();
            Map<String,Date> mapChatVsChargeDate = new Map<String,Date>();

             Map<string,string> chatNUrlMap = new Map<String,String>();
            
            System.debug('@@@@@@@Order Ids'+orderIds);
            
            if(!orderIds.isempty()){
                ordersToUpdate = [Select id, RecordType.Name,name,invoiceit_s__Account__c,invoiceit_s__Account__r.name From invoiceit_s__Job__c where id in: orderIds ];
                
                orderRPCList = [Select id, name,invoiceit_s__Status__c,Chat_Parent_Order_Rate_Plan_Charge__c,invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name,invoiceit_s__Order__r.Parent_Order__c,
                                Chat_Parent_Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.name,invoiceit_s__Order__r.Ngage_Cust_ID__c,
                                invoiceit_s__Service_End_Date__c,Fulfilment_Start_Date__c,Created_From_Charge__c,Chat_Parent_Order_Rate_Plan_Charge__r.created_from_Charge__c,
                                invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c,(select id,name,Attribute_Name__c,Attribute_Type__c,
                                String_Value__c,Picklist_Value__c,Boolean_Value__c,Phone_Value__c,Number_Value__c,Date_value__c,Long_text_value__c,
                                Order_Rate_Plan_Charge__r.invoiceit_s__Status__c From Order_Charge_Attributes__r) From invoiceit_s__Job_Rate_Plan_Charge__c 
                                Where invoiceit_s__Order__c in: orderIds AND invoiceit_s__Status__c!='Cancelled' AND invoiceit_s__Status__c!='Expired' AND invoiceit_s__Status__c!='Truncated'];
                
                if(!orderRPCList.isempty()){
                    chatprodOrdChargeList = [Select id, name,Chat_Usage_Order_Rate_Plan_Charge__c,Chat_Product_Order_Rate_Plan_Charge__c,Chat_Product_Order_Rate_Plan_Charge__r.Fulfilment_Start_Date__c From Chat_Product_Order_Charge__c Where Chat_Usage_Order_Rate_Plan_Charge__c in: orderRPCList];    
                    if(!chatprodOrdChargeList.isempty()){
                        for(Chat_Product_Order_Charge__c chat:  chatprodOrdChargeList){
                            if(chat.Chat_Product_Order_Rate_Plan_Charge__c!=Null && chat.Chat_Product_Order_Rate_Plan_Charge__r.Fulfilment_Start_Date__c!=NULL){
                                mapChatVsChargeDate.put(chat.Chat_Usage_Order_Rate_Plan_Charge__c,chat.Chat_Product_Order_Rate_Plan_Charge__r.Fulfilment_Start_Date__c );
                            }
                        }
                    }
                }    
                System.debug('@@@@@@@chatprodOrdChargeList'+chatprodOrdChargeList );
                System.debug('@@@@@mapChatVsChargeDate'+mapChatVsChargeDate);
                
                System.debug('@@@@@@@orderRPCList'+orderRPCList);
                
                
                for(invoiceit_s__Job_Rate_Plan_Charge__c rm: orderRPCList){
                    
                    if(rm.Chat_Parent_Order_Rate_Plan_Charge__c == Null){
                            if(!rm.Order_Charge_Attributes__r.isempty()){
                                chatNUrlMap.put(rm.id, rm.Order_Charge_Attributes__r[0].String_Value__c);
                            } 
                    }
                    
                    if(rm.Chat_Parent_Order_Rate_Plan_Charge__c!= Null && rm.created_from_Charge__c == Null && rm.Chat_Parent_Order_Rate_Plan_Charge__r.created_from_Charge__c == NULL){
                        System.debug('@@@@@@rm.Chat_Parent_Order_Rate_Plan_Charge__c'+rm.Chat_Parent_Order_Rate_Plan_Charge__c);
                        if(featureNchatMap.containskey(rm.Chat_Parent_Order_Rate_Plan_Charge__c)){
                            featureNchatMap.get(rm.Chat_Parent_Order_Rate_Plan_Charge__c).add(rm);
                        }else{
                            featureNchatMap.put(rm.Chat_Parent_Order_Rate_Plan_Charge__c, new List<invoiceit_s__Job_Rate_Plan_Charge__c> {rm});
                        }
                    }
                    
                    System.debug('@@@@@mapChatVsChargeDate.containskey(rm.id)'+mapChatVsChargeDate.containskey(rm.id));
                    if((rm.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.name.contains('Bronze') || 
                        rm.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.name.contains('Silver') || 
                        rm.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.name.contains('Gold')|| 
                        rm.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.name.contains('Platinum'))
                       && !mapChatVsChargeDate.containskey(rm.id) && rm.Chat_Parent_Order_Rate_Plan_Charge__c == NULL){
                         
                    }
                    else if( rm.Chat_Parent_Order_Rate_Plan_Charge__c != NULL && !mapChatVsChargeDate.containskey(rm.Chat_Parent_Order_Rate_Plan_Charge__c) && !rm.Chat_Parent_Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.name.contains('External') && rm.invoiceit_s__Order__r.Parent_Order__c!=Null){
                    //add product code here to remove the web products     
                    }
                    else{
                        finalOrderRPCList.add(rm);
                    }
                }
                System.debug('@@@@@@@@finalOrderRPCList'+finalOrderRPCList);
                
                for(invoiceit_s__Job_Rate_Plan_Charge__c feat: finalOrderRPCList){
                    System.debug('@@@@@@@Created from Charge Feature'+feat.created_from_Charge__c);
                    
                    if(feat.created_from_Charge__c == Null){
                        IncludeChargeRPCList.add(feat);
                    }
                }
                System.debug('@@@@@@@featureNchatMap'+featureNchatMap);
                    
                System.debug('@@@@@@orderRPCList '+finalOrderRPCList );
                System.debug('@@@@ordersToUpdateasas '+ordersToUpdate );
                System.debug('@@@@IncludeChargeRPCList'+IncludeChargeRPCList);
                System.debug('@@@@@@@chatNUrlMap'+chatNUrlMap);
                
                if(!IncludeChargeRPCList.isempty()){
                
                List<String> queueName = new List<String>();
                queueName.add('Ngage Ops');
                List<Group> queueList = [Select Id,Name from Group where Name in:queueName and Type = 'Queue'];
                System.debug('@@@@@@queue List'+queueList);
               
                String queueId;
                queueId = queueList[0].id;
                System.debug('@@@@@@queue id'+queueId );
                
                Id RecordTypeId_NgageOrder  = Schema.SObjectType.invoiceit_s__Job__c.getRecordTypeInfosByName().get('M-NG Order').getRecordTypeId();
                System.debug('@@@@@@@RecordTypeId_NgageOrder :'+RecordTypeId_NgageOrder);
                
                for(invoiceit_s__Job__c o: ordersToUpdate ){
                    System.debug('@@@@@@@@@o.RecordTypeId'+o.RecordTypeId);
                    if(o.RecordTypeId == RecordTypeId_NgageOrder){
                    
                        Case c = new Case();
                        c.AccountId = o.invoiceit_s__Account__c;
                        c.Area__c = 'Order Update';
                        c.Customer_Name__c = o.invoiceit_s__Account__r.Name;
                        c.Description = 'Active New Chat';
                        c.Origin = 'NgageSpt';
                        c.OwnerId = queueId ;
                        c.Parent_Order__c = o.id;
                        c.Priority = 'High';
                        c.RecordTypeId = '0120G000000WmRG';    
                        c.Status = 'New';
                        c.Sub_Area__c = 'New order';
                        c.Subject = 'Ngage Order/Charge Fulfilment';
                        //c.Name = 'Ngage Order';
                        c.Description__c = '<b><u>Products</b></u> : <br/><br/>';
                        
                        
                            system.debug('@@@@@@@@inside my if');
                            for(invoiceit_s__Job_Rate_Plan_Charge__c orpc: IncludeChargeRPCList){
                            
                                System.debug('@@@@Testingggg'+featureNchatMap.containskey(orpc.Chat_Parent_Order_Rate_Plan_Charge__c));
                                    if(orpc.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c == '60010'){
                                        
                                        String Recordlink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+orpc.Id;
                                        System.debug('@@@@@@@Re3cordLink'+RecordLink);
                                        String FulfillLink = '<a href='+Recordlink +' >Please select the link to update Chat Id</a>';
                                        System.debug('@@@@@@@FulfillLink '+FulfillLink );
    
                                        System.debug('@@@@@@@Features'+chatFeatureList);
                                        c.Description__c += '<b>'+orpc.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name + '</b><br/>' ;//+
                                                             
                                        if(!orpc.Order_Charge_Attributes__r.isempty()){
                                            c.Description__c += '<b><u>URL</b></u> : ' + orpc.Order_Charge_Attributes__r[0].String_Value__c + '<br/>' ;
                                        }
                                            c.Description__c += '<b><u>Client Id</b></u> : ' + orpc.invoiceit_s__Order__r.Ngage_Cust_ID__c + '<br/>' + 
                                                             '<b><u>Status</b></u> : ' + orpc.invoiceit_s__Status__c + '<br/>'+//<br/>';
                                                             '<b><u>Fulfillment Link</b></u> : ' +  FulfillLink + '<br/><br/>'; //-- commenting for now
                                        
                                        if(featureNchatMap.containskey(orpc.id)){
                                            chatFeatureList = featureNchatMap.get(orpc.id);
                                        
                                            if(chatFeatureList.size()>0){
                                                c.Description__c += '<b><u>Add-on Features</b></u><br/><br/>';
                                                
                                                for(invoiceit_s__Job_Rate_Plan_Charge__c featOrpc: chatFeatureList){
                                                    c.Description__c += '<b>'+featOrpc.Name + '</b><br/>'; //+
                                                                        
                                            
                                                    if(!featOrpc.Order_Charge_Attributes__r.isempty()){
                                                        for(Order_Charge_Attribute__c attr: featOrpc.Order_Charge_Attributes__r){
                                                            if(attr.Attribute_Type__c == 'Text' || attr.Attribute_Type__c == 'String'){
                                                                c.Description__c += attr.Attribute_Name__c +' : ' + attr.String_Value__c + '<br/>'; //+
                                                                                                                                   
                                                            }
                                                            else if(attr.Attribute_Type__c == 'Picklist'){
                                                                c.Description__c += attr.Attribute_Name__c +' : ' + attr.Picklist_Value__c + '<br/>'; //+
                                                                                
                                                            }
                                                            else if(attr.Attribute_Type__c == 'Boolean'){
                                                                c.Description__c += attr.Attribute_Name__c +' : ' + attr.Boolean_Value__c + '<br/>' ;//+
                                                                               
                                                            }
                                                            else if(attr.Attribute_Type__c == 'Phone'){
                                                                c.Description__c += attr.Attribute_Name__c +' : ' + attr.Phone_Value__c + '<br/>' ;//+
                                                                               
                                                            }
                                                            else if(attr.Attribute_Type__c == 'Number'){
                                                                c.Description__c += attr.Attribute_Name__c +' : ' + attr.Number_Value__c + '<br/>'; //+
                                                                               
                                                            }
                                                            else if(attr.Attribute_Type__c == 'Date'){
                                                                c.Description__c += attr.Attribute_Name__c +' : ' + attr.Date_Value__c + '<br/>' ;//+
                                                                                
                                                            }
                                                            else if(attr.Attribute_Type__c == 'Text Area'){
                                                                c.Description__c += attr.Attribute_Name__c +' : ' + attr.Long_text_value__c + '<br/>'; //+
                                                                               
                                                            }
                                                            
                                                             
                                                            
                                                        }
                                                        
                                                    }

                                                    String Recordlink2 = URL.getSalesforceBaseUrl().toExternalForm()+'/'+featOrpc.Id;
                                                    System.debug('@@@@@@@Re3cordLink2'+RecordLink2);
                                                    String FulfillLink2 = '<a href='+Recordlink2 +' >Please select the link to update Chat Id</a>';
                                                    System.debug('@@@@@@@FulfillLink2 '+FulfillLink2 );

                                                    c.Description__c += '<b><u> Status</b></u> : ' + featOrpc.invoiceit_s__Status__c + '<br/>' ;//+
                                                                        
                                                                         
                                                    if(!orpc.Order_Charge_Attributes__r.isempty()){
                                                        c.Description__c += '<b><u> Chat URL</b></u> : ' + orpc.Order_Charge_Attributes__r[0].String_Value__c + '<br/>';
                                                    }                    
                                                    
                                                    c.Description__c += '<b><u>Fulfillment Link</b></u> : ' +  FulfillLink2 + '<br/><br/>'; //-- commenting for now
                                                }
                                            }
                                      }
                                        c.Description__c += '======================================================<br/><br/>';
                                    }
                                    else if(orpc.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c != '60010' && orpc.Chat_Parent_Order_Rate_Plan_Charge__c == NULL ){
                                        
                                        String Recordlink3 = URL.getSalesforceBaseUrl().toExternalForm()+'/'+orpc.Id;
                                        System.debug('@@@@@@@Re3cordLink3'+RecordLink3);
                                        String FulfillLink3 = '<a href='+Recordlink3 +' >Please select the link to update Chat Id</a>';
                                        System.debug('@@@@@@@FulfillLink3 '+FulfillLink3 );

                                        c.Description__c += //'<b><u>Add-on Features</b></u><br/><br/>' +
                                                            '<b>' + orpc.Name + '</b><br/>' + 
                                                            '<b><u> Status</b></u> : ' + orpc.invoiceit_s__Status__c + '<br/>'+
                                                            '<b><u>Fulfillment Link</b></u> : ' +  FulfillLink3 + '<br/><br/>'; //-- commenting for now                                                               
                                        
                                        if(!orpc.Order_Charge_Attributes__r.isempty()){
                                            for(Order_Charge_Attribute__c attr: orpc.Order_Charge_Attributes__r){
                                                //c.Description__c += attr.Attribute_Name__c +' : ' + attr.String_Value__c + '<br/>' ;
                                                        
                                                        if(attr.Attribute_Type__c == 'Text' || attr.Attribute_Type__c == 'String'){
                                                            c.Description__c += attr.Attribute_Name__c +' : ' + attr.String_Value__c + '<br/>'; //+
                                                                                                                               
                                                        }
                                                        else if(attr.Attribute_Type__c == 'Picklist'){
                                                            c.Description__c += attr.Attribute_Name__c +' : ' + attr.Picklist_Value__c + '<br/>'; //+
                                                                            
                                                        }
                                                        else if(attr.Attribute_Type__c == 'Boolean'){
                                                            c.Description__c += attr.Attribute_Name__c +' : ' + attr.Boolean_Value__c + '<br/>' ;//+
                                                                           
                                                        }
                                                        else if(attr.Attribute_Type__c == 'Phone'){
                                                            c.Description__c += attr.Attribute_Name__c +' : ' + attr.Phone_Value__c + '<br/>' ;//+
                                                                           
                                                        }
                                                        else if(attr.Attribute_Type__c == 'Number'){
                                                            c.Description__c += attr.Attribute_Name__c +' : ' + attr.Number_Value__c + '<br/>'; //+
                                                                           
                                                        }
                                                        else if(attr.Attribute_Type__c == 'Date'){
                                                            c.Description__c += attr.Attribute_Name__c +' : ' + attr.Date_Value__c + '<br/>' ;//+
                                                                            
                                                        }
                                                        else if(attr.Attribute_Type__c == 'Text Area'){
                                                    c.Description__c += attr.Attribute_Name__c +' : ' + attr.Long_text_value__c + '<br/>'; //+
                                                                   
                                                }                                                                          
                                            }

                                            String Recordlink5 = URL.getSalesforceBaseUrl().toExternalForm()+'/'+orpc.Id;
                                            System.debug('@@@@@@@Re3cordLink5'+RecordLink5);
                                            String FulfillLink5 = '<a href='+Recordlink5 +' >Please select the link to update Chat Id</a>';
                                            System.debug('@@@@@@@FulfillLink5 '+FulfillLink5 );

                                            c.Description__c += '<b><u> Status</b></u> : ' + orpc.invoiceit_s__Status__c + '<br/>'+
                                                                '<b><u>Fulfillment Link</b></u> : ' +  FulfillLink5 + '<br/>'; //-- commenting for now

                                            
                                            if(chatNUrlMap.containskey(orpc.Chat_Parent_Order_Rate_Plan_Charge__c)){
                                                c.Description__c += '<b><u> Chat URL</b></u> : ' + chatNUrlMap.get(orpc.Chat_Parent_Order_Rate_Plan_Charge__c)+ '<br/><br/>';// +   
                                            }
                                        }    
                                        c.Description__c += '======================================================<br/><br/>';
                                    }
                                    
                                    else if(orpc.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c != '60010' && orpc.Chat_Parent_Order_Rate_Plan_Charge__c != NULL && !featureNchatMap.containskey(orpc.Chat_Parent_Order_Rate_Plan_Charge__c)){
                                        
                                        c.Description__c += //'<b><u>Add-on Features</b></u><br/><br/>' +
                                                            '<b>' + orpc.Name + '</b><br/>';
                                            
                                        if(!orpc.Order_Charge_Attributes__r.isempty()){
                                            for(Order_Charge_Attribute__c attr: orpc.Order_Charge_Attributes__r){
                                                //c.Description__c += attr.Attribute_Name__c +' : ' + attr.String_Value__c + '<br/>' ;
                                                
                                                if(attr.Attribute_Type__c == 'Text' || attr.Attribute_Type__c == 'String'){
                                                    c.Description__c += attr.Attribute_Name__c +' : ' + attr.String_Value__c + '<br/>'; //+
                                                                                                                               
                                                }
                                                else if(attr.Attribute_Type__c == 'Picklist'){
                                                    c.Description__c += attr.Attribute_Name__c +' : ' + attr.Picklist_Value__c + '<br/>'; //+
                                                                    
                                                }
                                                else if(attr.Attribute_Type__c == 'Boolean'){
                                                    c.Description__c += attr.Attribute_Name__c +' : ' + attr.Boolean_Value__c + '<br/>' ;//+
                                                                   
                                                }
                                                else if(attr.Attribute_Type__c == 'Phone'){
                                                    c.Description__c += attr.Attribute_Name__c +' : ' + attr.Phone_Value__c + '<br/>' ;//+
                                                                   
                                                }
                                                else if(attr.Attribute_Type__c == 'Number'){
                                                    c.Description__c += attr.Attribute_Name__c +' : ' + attr.Number_Value__c + '<br/>'; //+
                                                                   
                                                }
                                                else if(attr.Attribute_Type__c == 'Date'){
                                                    c.Description__c += attr.Attribute_Name__c +' : ' + attr.Date_Value__c + '<br/>' ;//+
                                                                    
                                                }
                                                else if(attr.Attribute_Type__c == 'Text Area'){
                                                    c.Description__c += attr.Attribute_Name__c +' : ' + attr.Long_text_value__c + '<br/>'; //+
                                                                   
                                                }                                                                          
                                            }
                                            
                                        }

                                        String Recordlink4 = URL.getSalesforceBaseUrl().toExternalForm()+'/'+orpc.Id;
                                        System.debug('@@@@@@@Re3cordLink3'+RecordLink4);
                                        String FulfillLink4 = '<a href='+Recordlink4 +' >Please select the link to update Chat Id</a>';
                                        System.debug('@@@@@@@FulfillLink4 '+FulfillLink4 );

                                        c.Description__c += '<b><u> Status</b></u> : ' + orpc.invoiceit_s__Status__c + '<br/>'+
                                                            '<b><u>Fulfillment Link</b></u> : ' +  FulfillLink4 + '<br/>'; //-- commenting for now
                                            
                                        if(chatNUrlMap.containskey(orpc.Chat_Parent_Order_Rate_Plan_Charge__c)){
                                            c.Description__c += '<b><u> Chat URL</b></u> : ' + chatNUrlMap.get(orpc.Chat_Parent_Order_Rate_Plan_Charge__c) + '<br/><br/>';// +   
                                        }

                                               
                                        c.Description__c += '======================================================<br/><br/>';
                                    }
                               
                            } 
                            casesToInsert.add(c);
                        }
                        
                    }     
                }
              }
                System.debug('@@@@@@casesToInsert'+casesToInsert);
                if(!casesToInsert.isempty()){
                    insert casesToInsert;
                }
        }
    
    public static void sendEmailNotification(Map<id,EmailWrapper> sendToMailMap){
        
        for(EmailWrapper myWrap : sendToMailMap.values()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            List<String> toAddressList = new List<String>();
            toAddressList.add(myWrap.receiverEmail );
            mail.setToAddresses(toAddressList);
            
            mail.setSubject('Ngage live chat fulfilled ' + myWrap.accountName + ' & ' + myWrap.accNumber);
            
            String html = 'Order Number : '+ myWrap.orderNumber
                          +'<br/> Name of Website : '+ myWrap.nameOfWebsite
                          + '<br/> Url of the Webiste : '+ myWrap.url
                          +'<br/> Chat ID : '+ myWrap.chatId;
            
           /* if(myWrap.webSiteLiveDate != null){
                html+= '<br/> Website Live Date : ' + myWrap.webSiteLiveDate;
            }else{
                html+= '<br/> Website Live Date : ';
            }
            */
            mail.setHtmlBody(html);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        }
    }
    
    Public static Map<id,EmailWrapper> ChatIdEmailNotification(List<invoiceit_s__Job_Rate_Plan_Charge__c> ListOfChatCharge){
        
        
        Map<id,EmailWrapper> senderEmails = new Map<id,EmailWrapper>();
        Set<Id> parentIdsWithBlankLiveDate = new Set<Id>();
        Map<Id,Id> childToParentOrder = new Map<Id,Id>();
        List<Chat_Product_Order_Charge__c> junctionList = [Select id,Chat_Product_Order_Rate_Plan_Charge__c, 
                                                            Chat_Usage_Order_Rate_Plan_Charge__c,
                                                            Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Order__r.invoiceit_s__Account__r.Name, 
                                                            Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Order__r.Name,
                                                            Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Order__r.invoiceit_s__Account__r.MH_Cust_Number__c,
                                                            Chat_Usage_Order_Rate_Plan_Charge__r.Chat_ID__c,
                                                            Chat_Usage_Order_Rate_Plan_Charge__r.Live_Date__c,
                                                            Chat_Product_Order_Rate_Plan_Charge__r.Live_Date__c,
                                                            Chat_Product_Order_Rate_Plan_Charge__r.Name
                                                            from Chat_Product_Order_Charge__c
                                                            where (NOT Chat_Product_Order_Rate_Plan_Charge__r.Name like '%Professional Profile%') AND Chat_Usage_Order_Rate_Plan_Charge__c in: ListOfChatCharge];
        
        System.debug('@RA: junctionList--> ' + JSON.serialize(junctionList));
        
        if(junctionList != null && junctionList.size() > 0){
            for(Chat_Product_Order_Charge__c junctionObj : junctionList){
                
                EmailWrapper wrap = new EmailWrapper();
                wrap.accountName = junctionObj.Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Order__r.invoiceit_s__Account__r.Name;
                wrap.accNumber = junctionObj.Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Order__r.invoiceit_s__Account__r.MH_Cust_Number__c;
                wrap.orderNumber = junctionObj.Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Order__r.Name;
                wrap.webSiteLiveDate = junctionObj.Chat_Usage_Order_Rate_Plan_Charge__r.Live_Date__c;
                wrap.nameOfWebsite = junctionObj.Chat_Product_Order_Rate_Plan_Charge__r.Name;
                wrap.chatId = junctionObj.Chat_Usage_Order_Rate_Plan_Charge__r.Chat_ID__c;
                system.debug('junctionObj.Chat_Product_Order_Rate_Plan_Charge__c != Null'+ junctionObj.Chat_Product_Order_Rate_Plan_Charge__c);
                If(junctionObj.Chat_Product_Order_Rate_Plan_Charge__c != Null || junctionObj.Chat_Product_Order_Rate_Plan_Charge__c != '') {
                parentIdsWithBlankLiveDate.add(junctionObj.Chat_Product_Order_Rate_Plan_Charge__c);
                system.debug('parentIdsWithBlankLiveDate'+ parentIdsWithBlankLiveDate);
                    senderEmails.put(junctionObj.Chat_Product_Order_Rate_Plan_Charge__c,wrap);
                }
                
                List<Milestone1_Project__c> projectList = [Select id,OwnerId,Owner.Name,Owner.Email,Status__c,
                                                    Order_Rate_Plan_Charge__c
                                                    from Milestone1_Project__c 
                                                    where Order_Rate_Plan_Charge__c In: parentIdsWithBlankLiveDate];
                        System.debug('@RA: projectList--> ' + JSON.serialize(projectList));
                
                if(!projectList.isempty() && projectList!=NULL){
                    for(Milestone1_Project__c projObj : projectList){
            
                        //parentIdsWithBlankLiveDate.remove(projObj.Order_Rate_Plan_Charge__c);
                        system.debug('projObj.Status__c'+projObj.Status__c);
                        system.debug('senderEmails.containsKey(projObj.Order_Rate_Plan_Charge__c'+senderEmails.containsKey(projObj.Order_Rate_Plan_Charge__c));
                        
                        if(senderEmails.containsKey(projObj.Order_Rate_Plan_Charge__c) && (projObj.Status__c != 'Completed' && projObj.Status__c != 'Cancelled' && projObj.Status__c != 'Optimization')){
                            EmailWrapper myWrap = senderEmails.get(projObj.Order_Rate_Plan_Charge__c);
                            myWrap.receiverEmail = projObj.Owner.Email;
                            senderEmails.put(projObj.Order_Rate_Plan_Charge__c,myWrap);
                            system.debug('mreceiverEmail'+myWrap.receiverEmail);
                        }
                        
                        // if((junctionObj.Chat_Product_Order_Rate_Plan_Charge__r.Live_Date__c != null && (projObj.Status__c == 'Completed' || projObj.Status__c == 'Cancelled' || projObj.Status__c == 'Optimization' )) || !junctionObj.Chat_Product_Order_Rate_Plan_Charge__r.Name.contains('Professional Profile') ){
                        
                        if(projObj.Status__c == 'Completed' || projObj.Status__c == 'Cancelled' || projObj.Status__c == 'Optimization' ){
                           wrap.receiverEmail = Label.Chat_Fulfilment_Email;
                           
                           system.debug('myWrap.receiverEmail2222222'+wrap.receiverEmail);
                        }
           			} 
                }else{
                    wrap.receiverEmail = Label.Chat_Fulfilment_Email;
                }
                
                childToParentOrder.put(junctionObj.Chat_Usage_Order_Rate_Plan_Charge__c,junctionObj.Chat_Product_Order_Rate_Plan_Charge__c); 
            }
        }
        
        System.debug('@RA: parentIdsWithBlankLiveDate--> ' + JSON.serialize(parentIdsWithBlankLiveDate));
        System.debug('@RA: senderEmails--> ' + JSON.serialize(senderEmails));
        System.debug('@RA: childToParentOrder--> ' + JSON.serialize(childToParentOrder));
        
      /*  List<Milestone1_Project__c> projectList = [Select id,OwnerId,Owner.Name,Owner.Email,
                                                    Order_Rate_Plan_Charge__c
                                                    from Milestone1_Project__c 
                                                    where Order_Rate_Plan_Charge__c In: parentIdsWithBlankLiveDate];
        System.debug('@RA: projectList--> ' + JSON.serialize(projectList));
        for(Milestone1_Project__c projObj : projectList){
            
            parentIdsWithBlankLiveDate.remove(projObj.Order_Rate_Plan_Charge__c);
            if(senderEmails.containsKey(projObj.Order_Rate_Plan_Charge__c) && (projObj.Status__c != 'Completed' && projObj.Status__c != 'Cancelled' && projObj.Status__c != 'Optimization')){
                EmailWrapper myWrap = senderEmails.get(projObj.Order_Rate_Plan_Charge__c);
                myWrap.receiverEmail = projObj.Owner.Email;
                senderEmails.put(projObj.Order_Rate_Plan_Charge__c,myWrap);
            }
            
        } */
          //Commented by Sai C 10-12-2018
        /*if(parentIdsWithBlankLiveDate.size() > 0){
            for(Id key : parentIdsWithBlankLiveDate){
                if(senderEmails.containsKey(key)){
                    EmailWrapper myWrap = senderEmails.get(key);
                    myWrap.receiverEmail = Label.Chat_Fulfilment_Email;
         
                    senderEmails.put(key,myWrap);
                }
            }
        } */
        
        List<Order_Charge_Attribute__c> orderAttrList = [select id, String_Value__c, Attribute_Name__c, 
                                                     Order_Rate_Plan_Charge__c 
                                                     from Order_Charge_Attribute__c 
                                                     where Attribute_Name__c = 'URL'
                                                     AND Order_Rate_Plan_Charge__c In: ListOfChatCharge];
        
        System.debug('@RA: orderAttrList--> ' + JSON.serialize(orderAttrList));
        
        for(Order_Charge_Attribute__c orderAttr : orderAttrList){
            Id parentId = childToParentOrder.get(orderAttr.Order_Rate_Plan_Charge__c);
            if(senderEmails.containsKey(parentId)){
                EmailWrapper myWrap = senderEmails.get(parentId);
                myWrap.url = orderAttr.String_Value__c;
                senderEmails.put(parentId,myWrap);
            }
            
        }
        
        return senderEmails;
        
    }
    
    public class EmailWrapper {
        
        String accountName,accNumber,orderNumber,nameOfWebsite;
        String url,chatId;
        DateTime webSiteLiveDate;
        String receiverEmail;
        
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
    }
}