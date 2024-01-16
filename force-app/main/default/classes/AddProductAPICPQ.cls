/***********************************************************************************************************************
* @author - VR
* @date - 01 Apr 2022
* @description - Add product automatically in QLE when triggered. A flow calls this method based on some conditions. 
* @testclass - AddProductAPICPQ_Test
* Referred Website : https://developer.salesforce.com/docs/atlas.en-us.cpq_dev_api.meta/cpq_dev_api/cpq_api_add_products.htm

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6368    VR            1/04/2022                           Added Invocable Method
MHMAC-460    SS            10/10/2023   John Mattheson  <T1>   Added changes for MA Promo Product
************************************************************************************************************************/

public class AddProductAPICPQ {
    
    @InvocableMethod
    public static void addProd(List<ID> quoteIDs)
    {
        try{
            System.debug('quoteIDs '+quoteIDs);
            
            ProductReader reader = new ProductReader();
            Product2 objProd =new Product2();
            Map<Id,String> promoMap = new Map<Id,String>();
            
            
            for(SBQQ__Quote__c q : [Select Id,Promo_Code__c,RecordType.DeveloperName from SBQQ__Quote__c where Id in :quoteIDs]){
                promoMap.put(q.Id,q.Promo_Code__c);
                if( q.RecordType.DeveloperName == 'M_A_Quote'){
                    //<T1> starts 
                    Final String PROMOFEEMA  = 'PROMOFEE-MA'; 
                    objProd = [Select ID from Product2 where ProductCode= :PROMOFEEMA limit 1];
                    //<T1> ends 
                }else{
                    Final String PROMOFEE  = 'PROMOFEE';  //Product Code of Promotional Fee Product           
                    objProd = [Select ID from Product2 where ProductCode= :PROMOFEE limit 1]; //Get Promotional Fee Product
                }
            }
            
            
            PricebookEntry pbe = [select ID from PricebookEntry where Product2Id = :objProd.ID limit 1]; //Get PriceBookEntry
            ProductModel productModel = reader.read(objProd.ID,pbe.ID,'USD');  //ProductReader.read returns the Product in ProductModel format
            System.debug(productModel.record);
            System.debug(productModel.record.Name);
            
            
            
            for(ID id : quoteIDs)
            {
                
                QuoteReader qreader = new QuoteReader();
                QuoteModel quoteModel = qreader.read(id); //QuoteReader.read returns the Quote in QuoteModel format
                System.debug(quoteModel.record);
                
                List<ProductModel> productModels = new List<ProductModel>();
                productModels.add(productModel);
                ProductAdder adder = new ProductAdder();
                QuoteModel quoteWithProducts = adder.add(quoteModel, productModels, 0); //ProductAdder.add adds the product to Quote
                System.debug(quoteWithProducts);
                
                QuoteSaver saver = new QuoteSaver();
                for(QuoteLineModel qlm : quoteWithProducts.lineItems){
                    if(qlm.record.ID == null){
                        qlm.record.IsPromotionalProd__c = true;
                        qlm.record.UpdateNetTotal__c = false;
                        qlm.record.SBQQ__StartDate__c = Date.Today();
                    }
                    
                }
                System.debug(quoteWithProducts);
                if(!test.isrunningtest()){
                    QuoteModel savedQuote = saver.save(quoteWithProducts); //QuoteSaver.save saves the added product
                }
                if(promoMap.get(ID) == 'Waive-ProRate-Plus-1-Mo'){
                    for(QuoteLineModel qlm : quoteWithProducts.lineItems){
                        if(qlm.record.ID == null){
                            qlm.record.IsPromotionalProd__c = true;
                            qlm.record.UpdateNetTotal__c = true;
                            qlm.record.IsIncludedinProrate__c = true;
                            qlm.record.SBQQ__StartDate__c = Date.today().addMonths(1).toStartOfMonth();
                        }
                        
                    }
                    System.debug(quoteWithProducts);
                    QuoteModel savedQuote1 = saver.save(quoteWithProducts); 
                }
                
                // System.debug('ADD PRODUCT API - saved'+savedQuote);
                
            }
        }
        catch(Exception e)
        {
            if(!test.isrunningtest()){
                Util.processException(e,true,'EXCEPTION OCCURRED DURING ADDING PRODUCT - API');
                System.debug('EXCEPTION OCCURRED DURING ADDING PRODUCT - API'+e);
            }
        }
    }
    
}