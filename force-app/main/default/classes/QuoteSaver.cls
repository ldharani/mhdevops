/***********************************************************************************************************************
 * @author - VR
 * @date - 01 Apr 2022
 * @description - Add Product API of CPQ 
 * @testclass - AddProductAPICPQ_Test

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6368    VR            1/04/2022                            Class is used by Add Product API of CPQ
************************************************************************************************************************/

public with sharing class QuoteSaver {
    public QuoteModel save(QuoteModel quote) {
        String quoteJSON = SBQQ.ServiceRouter.save('SBQQ.QuoteAPI.QuoteSaver', JSON.serialize(quote));
        return (QuoteModel) JSON.deserialize(quoteJSON, QuoteModel.class);
    }
}