/*
** Modified By : Lister Technologies
** Modified Purpose : To not allow renewal of product charges that have an unchecked renew checkbox
*/
public with sharing class MDL_trgHandlerOnOrderForRenewingOpp {

	/*public void RenewOpp(List<invoiceit_s__Job__c> lstOrders,Map<Id,invoiceit_s__Job__c> mapIdNOrder) {
	     List<Id> lstOrderIds = new List<Id>();
	     List<Id> lstOrderProductIds = new List<Id>();
	     List<Id> lstOrderProductRatePlanIds = new List<Id>();
	     List<Id> list_chargeIds = new List<Id>();
	     List<Id> lstOpportunityIds = new List<Id>();
	     Map<Id,Opportunity> MapClonedOpportunities= new Map<Id,Opportunity>();
	     Map<Id,Id> MapOfOppIdToOrderId = new Map<Id,Id>();
	     Map<Id,Date> MapOfOppIdToServiceEndDate = new Map<Id,Date>();
	     List<invoiceit_s__Job_Rate_Plan_Charge__c> lstCharges = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
	     list<invoiceit_crmx__Opportunity_Product__c > insertOpptyProduct= new list<invoiceit_crmx__Opportunity_Product__c>();
	     invoiceit_crmx__Opportunity_Product__c  prodToClone= new invoiceit_crmx__Opportunity_Product__c ();
	     list<invoiceit_crmx__Opportunity_Product__c> lstOpptyProductsToClone= new List<invoiceit_crmx__Opportunity_Product__c>();
	     boolean isChecked = false;
		
		 invoiceit_crmx__Opportunity_Rate_Plan__c opptRatePlanCloned = new invoiceit_crmx__Opportunity_Rate_Plan__c();
	     invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opptRatePlanChargeCloned = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c();
	     Opportunity_Charge_Attribute__c OpptAttributeClonned = new Opportunity_Charge_Attribute__c();
	    //For not renewing One-Time products
	    Map<Id,String> mapOfOppPrIdAndPriceType = new Map<Id,String>();
	    Map<Id,String> mapOfOppRPIdAndPriceType = new Map<Id,String>();
	    Map<Id,String> mapOfOppRPCIdAndPriceType = new Map<Id,String>(); 
	    Map<Id,Boolean> mapOfOppRPCIdAndRenewable = new Map<Id,Boolean>();
	    Map<Id,Decimal> mapOfOppIdToAmount = new Map<Id,Decimal>();
    // varibale declaration 
   
    system.debug('trigger run ' + MDL_RecursionHandler.firstRun);
    if(MDL_RecursionHandler.firstRun){
    for(invoiceit_s__Job__c orderObj : lstOrders) {
    	
        if(orderObj.invoiceit_s__Status__c == 'Cancelled')
            lstOrderIds.add(orderObj.Id);
        //check if renew checkbox is checked , if yes go on to create a renewal opportunity
        System.debug('orderObj.Renew__c-->'+orderObj.Renew__c);
        if(orderObj.Renew__c == true && mapIdNOrder.get(orderObj.Id).Renew__c != true) {
            if(orderObj.invoiceit_crmx__Opportunity__c != null)
    			MapOfOppIdToOrderId.put(orderObj.invoiceit_crmx__Opportunity__c, orderObj.id);
    		if(orderObj.invoiceit_s__Service_End_Date__c != null)
    			MapOfOppIdToServiceEndDate.put(orderObj.invoiceit_crmx__Opportunity__c, orderObj.invoiceit_s__Service_End_Date__c)	;
            lstOpportunityIds.add(orderObj.invoiceit_crmx__Opportunity__c);
            isChecked=true;
        }
    }
    System.debug('list of canc order-->'+lstOrderIds);
    List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> oppRPC = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
    
    oppRPC = [Select Id , invoiceit_crmx__Opportunity__c , 	invoiceit_crmx__Opportunity_Rate_Plan__c ,invoiceit_crmx__Price_Type__c,
    			invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c , 	invoiceit_crmx__Row_Total__c ,
    			invoiceit_crmx__Product_Rate_Plan_Charge__r.Renewable__c, invoiceit_crmx__Product_Rate_Plan_Charge__c
    			from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c
    			where invoiceit_crmx__Opportunity__c in : lstOpportunityIds
    			and RecordType.DeveloperName = 'MDL_Opportunity_Rate_Plan_Charge'];
   
   //FOR RENEWAL OF ONLY SUBSCRIPTION PRODUCTS 			
    for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRPCIter : oppRPC){
    	mapOfOppPrIdAndPriceType.put(oppRPCIter.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c , oppRPCIter.invoiceit_crmx__Price_Type__c);
    	mapOfOppRPIdAndPriceType.put(oppRPCIter.invoiceit_crmx__Opportunity_Rate_Plan__c, oppRPCIter.invoiceit_crmx__Price_Type__c);
    	mapOfOppRPCIdAndPriceType.put(oppRPCIter.Id, oppRPCIter.invoiceit_crmx__Price_Type__c);
    	mapOfOppRPCIdAndRenewable.put(oppRPCIter.Id,oppRPCIter.invoiceit_crmx__Product_Rate_Plan_Charge__r.Renewable__c);
    	Decimal tempAmt = 0;
    	if(oppRPCIter.invoiceit_crmx__Price_Type__c != 'One Time' && oppRPCIter.invoiceit_crmx__Row_Total__c != null){
    		
    		if(mapOfOppIdToAmount.containsKey(oppRPCIter.invoiceit_crmx__Opportunity__c)){
    			tempAmt = mapOfOppIdToAmount.get(oppRPCIter.invoiceit_crmx__Opportunity__c);
				tempAmt += 	oppRPCIter.invoiceit_crmx__Row_Total__c;	
				mapOfOppIdToAmount.put(oppRPCIter.invoiceit_crmx__Opportunity__c , tempAmt);	
    		}
    		else{
    			tempAmt += oppRPCIter.invoiceit_crmx__Row_Total__c;	
    			mapOfOppIdToAmount.put(oppRPCIter.invoiceit_crmx__Opportunity__c , tempAmt);
    		}
    	}	
    }
    for(invoiceit_s__Job_Product__c orderProd : [Select id,name,invoiceit_s__Job__c 
    											from invoiceit_s__Job_Product__c 
    											where invoiceit_s__Job__c in : lstOrderIds 
    											and RecordType.DeveloperName = 'MDL_Order_Product']) {
        lstOrderProductIds.add(orderProd.Id);
    }
    for(invoiceit_s__Job_Rate_Plan__c orderRatePlan : [Select i.invoiceit_s__Job_Product__c, i.Name, i.Id 
    													From invoiceit_s__Job_Rate_Plan__c i 
    													where i.invoiceit_s__Job_Product__c in : lstOrderProductIds
    													and RecordType.DeveloperName = 'MDL_Order_Rate_Plan']) {
        lstOrderProductRatePlanIds.add(orderRatePlan.Id);
    }
    for(invoiceit_s__Job_Rate_Plan_Charge__c oRatePlanCharge : [Select i.invoiceit_s__Status__c,i.invoiceit_s__Job_Rate_Plan__c, i.Name, i.Id 
    															From invoiceit_s__Job_Rate_Plan_Charge__c i 
    															where i.invoiceit_s__Job_Rate_Plan__c in : lstOrderProductRatePlanIds
    															and RecordType.DeveloperName = 'MDL_Order_Rate_Plan_Charge']) {
        oRatePlanCharge.invoiceit_s__Status__c = 'Cancelled';
        list_chargeIds.add(oRatePlanCharge.Id);
        lstCharges.add(oRatePlanCharge);
    }
    System.debug('Printing lstOpportunityIds-->'+lstOpportunityIds);
    for(Opportunity oppObj : [Select o.invoiceit_crmx__VAT__c, o.invoiceit_crmx__Total__c, o.invoiceit_crmx__Total_Profit__c, o.invoiceit_crmx__Total_Cost__c, 
                                     o.invoiceit_crmx__Total_Contract_Value__c, o.invoiceit_crmx__TotalQuoteValue__c, o.invoiceit_crmx__TotalProfitPercent__c, 
                                     o.invoiceit_crmx__TotalOrderValue__c, o.invoiceit_crmx__Tax__c, o.invoiceit_crmx__Synced_Quote__c, 
                                     o.invoiceit_crmx__Sub_Total__c, o.invoiceit_crmx__Start_Date__c, o.invoiceit_crmx__Shipping_Contact__c, 
                                     o.invoiceit_crmx__Recalculate__c, o.invoiceit_crmx__Number_Of_Terms__c, o.invoiceit_crmx__Net_Total__c, 
                                     o.invoiceit_crmx__Exchange_Rate_Applied__c, o.invoiceit_crmx__Do_Not_Create_Automatic_Order__c, 
                                     o.invoiceit_crmx__Discount_Value__c, o.invoiceit_crmx__Discount_Percent__c, o.invoiceit_crmx__Discount_Code__c, 
                                     o.invoiceit_crmx__CurrencyL__c, o.invoiceit_crmx__Create_Quote__c, o.invoiceit_crmx__Create_Order__c, 
                                     o.invoiceit_crmx__Billing_Contact__c, o.Type, o.SyncedQuoteId, o.Quote_Type__c, 
                                     o.Pricebook2Id, o.OwnerId, o.NextStep, o.Name, o.LeadSource, o.Id, 
                                     o.ForecastCategory, o.FiscalYear, o.FiscalQuarter, o.Fiscal, o.Description, o.Created_From_Order__c, o.CloseDate, 
                                     o.CampaignId, o.Amount, o.AccountId , o.Account.OwnerId From Opportunity o where o.Id in : lstOpportunityIds
                                     and RecordType.DeveloperName = 'MH_Opportunity']) {
                                        
		                                        Opportunity oppClone = oppObj.clone();
		                                        oppClone.Name = 'Renew ' + oppObj.Name;
		                                        oppClone.Created_From_Order__c = oppObj.Created_From_Order__c;
		                                        oppClone.StageName = 'Value Proposition';
		                                        oppClone.OwnerId = oppObj.Account.OwnerId;
		                                        if(MapOfOppIdToOrderId.containsKey(oppObj.Id))
		                                        	oppClone.Created_From_Order__c = MapOfOppIdToOrderId.get(oppObj.Id);
		                                        //if(MapOfOppIdToServiceEndDate.containsKey(oppObj.Id))
		                                        	//oppClone.CloseDate = MapOfOppIdToServiceEndDate.get(oppObj.Id);
		                                        oppClone.CloseDate = system.today().addDays(90);	
		                                        if(mapOfOppIdToAmount.containskey(oppObj.Id)){
		                                        	oppClone.Amount = mapOfOppIdToAmount.get(oppObj.Id);
		                                        }
		                                        MapClonedOpportunities.put(oppObj.Id,oppClone);
		                                        
		                                        
                                        
     }
     System.debug('Printing oppt-->'+MapClonedOpportunities);
     System.debug('Cancelled charges list+++'+lstCharges.size());
     System.debug('Cancelled charges list2 '+lstCharges);
    if(lstCharges.size() > 0)
        Database.update(lstCharges);
     System.debug('Cancelled charges list3 '+lstCharges);
    
    lstCharges = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();  
    lstCharges = [Select Id,invoiceit_s__Status__c from invoiceit_s__Job_Rate_Plan_Charge__c where Id in :list_chargeIds 
    				and RecordType.DeveloperName = 'MDL_Order_Rate_Plan_Charge'];
    
    System.debug('Cancelled charges list after query '+lstCharges);   
    if(MapClonedOpportunities.values().size() > 0) 
        Database.insert(MapClonedOpportunities.values());
        //System.debug('MapClonedOpportunities.values()---------------------------------------------------------------------------->'+MapClonedOpportunities.values());

   //
    //code logic for cloning the Oppty Product corresponding to every Opportunity
    //
    Map<Id,invoiceit_crmx__Opportunity_Product__c> MapClonedOpportunitiesProducts = new Map<Id,invoiceit_crmx__Opportunity_Product__c>();
    Map<Id,invoiceit_crmx__Opportunity_Rate_Plan__c> MapClonedOpportunitiesPlans = new Map<Id,invoiceit_crmx__Opportunity_Rate_Plan__c>();
    Map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> MapClonedOpportunitiesCharges = new Map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
    if(isChecked){

        lstOpptyProductsToClone=[select InventoryId__c,invoiceit_crmx__Opportunity__c,Id,Name,invoiceit_crmx__Product__c,invoiceit_crmx__Product_Family__c,invoiceit_crmx__SequenceNumber__c,invoiceit_crmx__Description__c,invoiceit_crmx__Product_Code__c 
        						from invoiceit_crmx__Opportunity_Product__c 
        						where invoiceit_crmx__Opportunity__c in :MapClonedOpportunities.KeySet()
        						and RecordType.DeveloperName = 'MDL_Opportunity_Product'];


        for(invoiceit_crmx__Opportunity_Product__c  prod: lstOpptyProductsToClone){
        	if(mapOfOppPrIdAndPriceType.containsKey(prod.id)){
        		if(mapOfOppPrIdAndPriceType.get(prod.id) != 'One Time'){
		            prodToClone= prod.clone();
		            prodToClone.Name = prod.Name;
		            if(MapClonedOpportunities.containsKey(prod.invoiceit_crmx__Opportunity__c)){
		            	prodToClone.invoiceit_crmx__Opportunity__c=MapClonedOpportunities.get(prod.invoiceit_crmx__Opportunity__c).Id;
		            	MapClonedOpportunitiesProducts.put(prod.id,prodToClone);
		            	insertOpptyProduct.add(prodToClone);
		            }	
        		}
        	}
        }
        //System.debug('insertOpptyProduct------------------------------------------------->'+insertOpptyProduct);
        insert insertOpptyProduct;
        
        list<invoiceit_crmx__Opportunity_Rate_Plan__c> OpptRatePlanList = [SELECT ID,Name,invoiceit_crmx__Opportunity_Product__c,invoiceit_crmx__SequenceNumber__c,invoiceit_crmx__Description__c
                                                                           FROM invoiceit_crmx__Opportunity_Rate_Plan__c
                                                                           WHERE invoiceit_crmx__Opportunity_Product__c IN :MapClonedOpportunitiesProducts.keySet()
                                                                           and RecordType.DeveloperName = 'MDL_Opportunity_Rate_Plan'];
        for(invoiceit_crmx__Opportunity_Rate_Plan__c plan : OpptRatePlanList){
            //opptRatePlanCloned = new invoiceit_crmx__Opportunity_Rate_Plan__c();
            if(mapOfOppRPIdAndPriceType.containsKey(plan.id)){
            	if(mapOfOppRPIdAndPriceType.get(plan.id) != 'One Time'){
		            opptRatePlanCloned = plan.clone();
		            opptRatePlanCloned.Name = plan.Name;
		            if(MapClonedOpportunitiesProducts.containsKey(plan.invoiceit_crmx__Opportunity_Product__c)){
			            opptRatePlanCloned.invoiceit_crmx__Opportunity_Product__c = MapClonedOpportunitiesProducts.get(plan.invoiceit_crmx__Opportunity_Product__c).id;
			            MapClonedOpportunitiesPlans.put(plan.id,opptRatePlanCloned);
		            }
            	}
            }	
        }       
        insert MapClonedOpportunitiesPlans.values();
         list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> OpptChargeList = [SELECT Account_Id__c,Created_From_Charge__c,Id,
                                                                                 invoiceit_crmx__Accounting_Code__c,
                                                                                 invoiceit_crmx__Charge_Code__c,invoiceit_crmx__Cost_Price__c,
                                                                                 invoiceit_crmx__Cost__c,invoiceit_crmx__CurrencyL__c,
                                                                                 invoiceit_crmx__Discount_Percent__c,
                                                                                 invoiceit_crmx__Discount_Value__c, 
                                                                                 invoiceit_crmx__Is_Product_Editable__c,invoiceit_crmx__Net_Total__c,invoiceit_crmx__Opportunity_Rate_Plan__c,invoiceit_crmx__Opportunity__c,invoiceit_crmx__Percentage_of_other_Charges__c,invoiceit_crmx__Price_Format__c,invoiceit_crmx__Price_Type__c,invoiceit_crmx__Price__c,invoiceit_crmx__Product_Charge_Category__c,invoiceit_crmx__Profit__c,invoiceit_crmx__Quantity__c,invoiceit_crmx__Row_Total__c,invoiceit_crmx__Sequence_No__c,invoiceit_crmx__Status__c,invoiceit_crmx__Tax_Code__c,invoiceit_crmx__Tax_Percentage__c,invoiceit_crmx__Tax__c,invoiceit_crmx__Unit_Of_Measurement__c,invoiceit_crmx__Unit_Price__c,invoiceit_crmx__VAT_Percentage__c,invoiceit_crmx__VAT__c,LastActivityDate,Name,Quote_Type__c,SIN__c,
                                                                                 invoiceit_crmx__Product_Rate_Plan_Charge__r.Renewable__c, invoiceit_crmx__Product_Rate_Plan_Charge__c
                                                                                 FROM invoiceit_crmx__Opportunity_Rate_Plan_Charge__c
                                                                                 WHERE invoiceit_crmx__Opportunity_Rate_Plan__c IN:MapClonedOpportunitiesPlans.keyset()
                                                                                 and RecordType.DeveloperName = 'MDL_Opportunity_Rate_Plan_Charge'];
        system.debug('List Charges Size ' +  OpptChargeList.size());
        for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c charge:OpptChargeList){
        	if(mapOfOppRPCIdAndPriceType.containsKey(charge.id) && mapOfOppRPCIdAndRenewable.containsKey(charge.id)){
        		system.debug('!!ppp ' + mapOfOppRPCIdAndPriceType.get(charge.id));
        		system.debug('&&ppp'+mapOfOppRPCIdAndRenewable.get(charge.id));
        		if(mapOfOppRPCIdAndPriceType.get(charge.id) != 'One Time' && mapOfOppRPCIdAndRenewable.get(charge.id) != false){
        			System.debug('it is not a one time & it is a renewable product');
	                opptRatePlanChargeCloned = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c();
	                opptRatePlanChargeCloned = charge.clone();
	                opptRatePlanChargeCloned.Name = charge.Name;
	                opptRatePlanChargeCloned.invoiceit_crmx__Status__c = 'Active';
	                if(MapClonedOpportunitiesPlans.containsKey(charge.invoiceit_crmx__Opportunity_Rate_Plan__c)){
	                	opptRatePlanChargeCloned.invoiceit_crmx__Opportunity_Rate_Plan__c = MapClonedOpportunitiesPlans.get(charge.invoiceit_crmx__Opportunity_Rate_Plan__c).id;
	                	MapClonedOpportunitiesCharges.put(charge.id,opptRatePlanChargeCloned);
	                }	
        		}
        	}	
        }
        insert MapClonedOpportunitiesCharges.values();
        
        List<id> chargeIdForAtt = new List<Id>();
        for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c iter : MapClonedOpportunitiesCharges.values()){
        	chargeIdForAtt.add(iter.Id);
        }
        list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> listOfCharges1 = [Select id , (Select id from Opportunity_Charge_Attributes__r 
        																		where RecordType.DeveloperName = 'MDL_Opportunity_Charge_Attribute')
        																		from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c
                                                                 				WHERE id IN:chargeIdForAtt];
        
        List<Opportunity_Charge_Attribute__c> attributeToDelete = new List<Opportunity_Charge_Attribute__c>();
        for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oRPCIter :  listOfCharges1){
        	
        	for(Opportunity_Charge_Attribute__c attribute : oRPCIter.Opportunity_Charge_Attributes__r){
        			attributeToDelete.add(attribute);
        	}
        }
        
        if(attributeToDelete.size() > 0)
        	delete attributeToDelete;
        
        
         list<Opportunity_Charge_Attribute__c> listOfAttributs = new List<Opportunity_Charge_Attribute__c>(); 
         listOfAttributs = [SELECT ID,Name,Attribute_Name__c,Attribute_Order__c,Attribute_Picklist_Values__c,Attribute_Type__c,Boolean_Value__c,Date_Value__c,Maximum_No_Of_Characters_In_Text__c,Minimum_No_Of_Characters_In_Text__c,Number_Value__c,Opportunity_Rate_Plan_Charge__c,Phone_Value__c,Picklist_Value__c,String_Value__c
                             FROM Opportunity_Charge_Attribute__c
                             WHERE Opportunity_Rate_Plan_Charge__c IN:MapClonedOpportunitiesCharges.keyset()
                             and RecordType.DeveloperName = 'MDL_Opportunity_Charge_Attribute'];
                                                                 
        list<Opportunity_Charge_Attribute__c> listOfAttriutestoUpdate = new list<Opportunity_Charge_Attribute__c>();
        for(Opportunity_Charge_Attribute__c attribute: listOfAttributs){
            OpptAttributeClonned = attribute.clone();
            if(MapClonedOpportunitiesCharges.containsKey(attribute.Opportunity_Rate_Plan_Charge__c)){
            	OpptAttributeClonned.Opportunity_Rate_Plan_Charge__c = MapClonedOpportunitiesCharges.get(attribute.Opportunity_Rate_Plan_Charge__c).id;
            	listOfAttriutestoUpdate.add(OpptAttributeClonned);
            }	
        }
        if(listOfAttriutestoUpdate.size() > 0)
        	insert listOfAttriutestoUpdate;
    }
	}
	}*/
}