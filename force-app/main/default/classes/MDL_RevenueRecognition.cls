/*
**Created by : Lister Technologies
**Created Date : 2/7/14
**Purpose : When a fulfillment start date has been entered on an order charge line, 
			it will use the revenue recognition months to create that number of records in the 'Order Product Charge Revenue' 
			the amount of revenue will be evenly divided between order charge line amount and the number of months .
			
			When a service end date is set, if there are any Order Product Charge Revenue that have a future date, their dates will be reset to the current service end date
**Test Class : MDL_TestRevenueRecognition.cls
*/
public with sharing class MDL_RevenueRecognition {
	public static void trgHandlerOrderRPC(List<Id> lstOrderChargeIds) {
		List<Order_Product_Charge_Revenue__c> lstExistingChargeRevenues = new List<Order_Product_Charge_Revenue__c>();
		List<Order_Product_Charge_Revenue__c> lstToBeCreatedChargeRevenues = new List<Order_Product_Charge_Revenue__c>();
		List<invoiceit_s__Job_Rate_Plan_Charge__c> lstOrderCharges = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
		lstExistingChargeRevenues = [Select o.Revenue_Date__c, o.Order_Rate_Plan_Charge__c, o.Name, o.Id, o.Amount__c 
									 From Order_Product_Charge_Revenue__c o
									 Where o.Order_Rate_Plan_Charge__c in : lstOrderChargeIds];
		if(lstExistingChargeRevenues.size() > 0) {
			Database.delete(lstExistingChargeRevenues);
		}
		lstOrderCharges = [Select Fulfilment_Start_Date__c,invoiceit_s__Service_End_Date__c,invoiceit_s__Product_Rate_Plan_Charge__r.Revenue_Recognition_Months__c,
						   invoiceit_s__Net_Total__c
						   From invoiceit_s__Job_Rate_Plan_Charge__c where Id in :lstOrderChargeIds];							 
		for(invoiceit_s__Job_Rate_Plan_Charge__c orderCharges : lstOrderCharges) {			
			System.debug('Revenue recog months^^^'+orderCharges.invoiceit_s__Product_Rate_Plan_Charge__r.Revenue_Recognition_Months__c);
			if(orderCharges.invoiceit_s__Product_Rate_Plan_Charge__r.Revenue_Recognition_Months__c > 0) {
				Integer i = orderCharges.invoiceit_s__Product_Rate_Plan_Charge__r.Revenue_Recognition_Months__c.intValue();
				for(Integer j = 0;j<i;j++) {
					Order_Product_Charge_Revenue__c chargeRevenue = new Order_Product_Charge_Revenue__c();
					chargeRevenue.Amount__c = (orderCharges.invoiceit_s__Net_Total__c /i);
					Date revenueDate = orderCharges.Fulfilment_Start_Date__c;
					if(orderCharges.Fulfilment_Start_Date__c!=null){
						if(orderCharges.invoiceit_s__Service_End_Date__c!=null){
							if(revenueDate.addMonths(j) >= orderCharges.invoiceit_s__Service_End_Date__c) {
								chargeRevenue.Revenue_Date__c = orderCharges.invoiceit_s__Service_End_Date__c;
								System.debug('Revenue Date Greater Than Service End Date');
							}											
						}
						else{
								chargeRevenue.Revenue_Date__c = revenueDate.addMonths(j);
								System.debug('Revenue Date Lesser Than Service End Date');
						}
					}					
										
					chargeRevenue.Order_Rate_Plan_Charge__c = orderCharges.Id;
					lstToBeCreatedChargeRevenues.add(chargeRevenue);
				}
			}
		}
		if(lstToBeCreatedChargeRevenues.size() > 0)
			Database.insert(lstToBeCreatedChargeRevenues);
	}
	public static void trgHandlerServiceDateChange(List<invoiceit_s__Job_Rate_Plan_Charge__c> lstCharges) {
		System.debug('&&&inside service date update method&&&');
		Map<Id,List<Order_Product_Charge_Revenue__c>> mapChargeIdNlstExistingChargeRevenues = new Map<Id,List<Order_Product_Charge_Revenue__c>>();
		List<Id> lstOrderChargeIds = new List<Id>();
		List<Order_Product_Charge_Revenue__c> lstOrderChargeRevenuesToUpdate = new List<Order_Product_Charge_Revenue__c>();
		for(invoiceit_s__Job_Rate_Plan_Charge__c oCharge : lstCharges) {
			lstOrderChargeIds.add(oCharge.Id);
		}
		for(Order_Product_Charge_Revenue__c revenue : [Select o.Revenue_Date__c, o.Order_Rate_Plan_Charge__c, o.Name, o.Id, o.Amount__c 
									 				   From Order_Product_Charge_Revenue__c o
									 				   Where o.Order_Rate_Plan_Charge__c in : lstOrderChargeIds]) {
			if(mapChargeIdNlstExistingChargeRevenues.containsKey(revenue.Order_Rate_Plan_Charge__c)) {
				mapChargeIdNlstExistingChargeRevenues.get(revenue.Order_Rate_Plan_Charge__c).add(revenue);
			}
			else {
				mapChargeIdNlstExistingChargeRevenues.put(revenue.Order_Rate_Plan_Charge__c,new List<Order_Product_Charge_Revenue__c>{revenue});
			}
		}
		for(invoiceit_s__Job_Rate_Plan_Charge__c oCharge: lstCharges) {
			if(mapChargeIdNlstExistingChargeRevenues.containsKey(oCharge.Id)) {
				for(Order_Product_Charge_Revenue__c rev : mapChargeIdNlstExistingChargeRevenues.get(oCharge.Id)) {
					if(rev.Revenue_Date__c >= oCharge.invoiceit_s__Service_End_Date__c) {
						rev.Revenue_Date__c = oCharge.invoiceit_s__Service_End_Date__c;
						lstOrderChargeRevenuesToUpdate.add(rev);
					}
				}
			}
		}
		if(lstOrderChargeRevenuesToUpdate.size() > 0) {
			Database.update(lstOrderChargeRevenuesToUpdate);
		}								 				   	
	}
}