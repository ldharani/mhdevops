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

public class QuoteModel {
    public SBQQ__Quote__c record;
    public QuoteLineModel[] lineItems;
    public QuoteLineGroupModel[] lineItemGroups;
    public Integer nextKey;
    public Boolean applyAdditionalDiscountLast;
    public Boolean applyPartnerDiscountFirst;
    public Boolean channelDiscountsOffList;
    public Decimal customerTotal;
    public Decimal netTotal;
    public Decimal netNonSegmentTotal;
}