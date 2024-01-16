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

public class QuoteLineModel {
    public SBQQ__QuoteLine__c record;
    public Boolean amountDiscountProrated;
    public Integer parentGroupKey;
    public Integer parentItemKey;
    public Integer key;
    public Boolean upliftable;
    public String configurationType;
    public String configurationEvent;
    public Boolean reconfigurationDisabled;
    public Boolean descriptionLocked;
    public Boolean productQuantityEditable;
    public Decimal productQuantityScale;
    public String dimensionType;
    public Boolean productHasDimensions;
    public Decimal targetCustomerAmount;
    public Decimal targetCustomerTotal;
}