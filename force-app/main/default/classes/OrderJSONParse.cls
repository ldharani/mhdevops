/*
Apex Class   : Trigger_QuoteLineConsumptionRate_Helper
Created By   : Serge Kandukuri
Description  : This is Parser class for API Response
*/
public class OrderJSONParse{
    public OrderJSONParse(){
    system.debug('####');
    }
    
    public cls_data data;
    public class cls_data {
        public cls_items items;
    }
    public class cls_items {
        public String id;   //5596601
        public cls_account account;
        public String parentIds;
        public String name; //null
        public String firmName; //Nama_mul_2
        public String firmUrl;  //null
        public String contactFirstName; //Nama
        public String contactLastName;  //Multi2
        public String contactEmail; //nama@multi2.com
        public String contactPhone1;    //9481122211
        public String contactPhone2;
        public String contactFax;
        public String contactAddress1;  //Mult St
        public String contactAddress2;
        public String contactCity;  //New York
        public cls_contactProvince contactProvince;
        public String contactPostalCode;    //41212
        public String urlKey;   //NOLO_11x5fb54c558469bx92589951
        public String urlKeyExpiration; //2021-01-17 08:31:17
        public String verticalId;   //11
        public cls_type type;
        public cls_paymentType paymentType;
        public String programType;  //lead
        public String fromProgramType;
        public String initCharge;   //0.00
        public String flatFeeCredit;
        public String pplCredit;
        public String fixFeeCredit;
        public String adminCredit;
        public String recurringCharge;  //0.00
        public String recurringFrequency;   //3
        public String lastChargeDate;
        public String nextChargeDate;
        public String potentialRevenue;
        public String contractTerm; //1 Year
        public String renewalType;  //auto-renew
        public String state;    //contract-activated
        public String status;   //active
        public String salesId;  //555
        public String salesName;    //rep1
        public String saleType; //new
        public String sendConfirmEmail;
        public String sendWelcomeEmail;
        public String profileOrigin;    //nolo.com
        public String leadCap;  //0.00
        public String leadCapFrequency; //Monthly
        public String rankingMultiplier;
        public String clientSiteId;
        public String subscriptionDataType;
        public String amendmentType;    //cm
        public String clientLastVisited;
        public String salesLastVisited;
        public String lastAdvertiserLimitCheck;
        public String contractStart;    //2020-11-18 08:31:17
        public String contractEnd;
        public String activated;    //2020-11-18 08:31:17
        public String lastSuspended;
        public String updated;  //2020-11-18 08:31:17
        public String created;  //2020-11-18 08:31:17
        public String bypasses;
        public String extraDatas;
        public cls_subscriptions[] subscriptions;
        public String termsConditions;
        public String revShare;
        public String revShareFixed;
        public String  groupSelectionAmountType;
        public String brandId;  //nolo
        public String smbGuid;
        public String externalId;
        public String providerId;
        public String taxType;  //0
        public String taxRate;
        public String taxAmount;
        public String totalAmount;
        public String taxPreIncluded;

    }
    public class cls_account {
        public String id;   //1001423516
        public String partnerId;
        public String brandId;  //nolo
        public String name; //Nama_mul_2
        public String url;  //null
        public String origin;   //nolo.com
        public String leadCap;
        public String leadCapFrequency;
        public String rankingMultiplier;
        public String status;   //active
        public String salesId;
        public String externalId;
        public String pauseStart;
        public String pauseEnd;
        public String inactiveDate; 
        public String encodedExtendInfo;
        public String updated;
        public String created;  //2020-11-18 08:31:17
        public String client_guid;
        public String proposals;
        public Integer verticalId;  //11
        public cls_type type;
        public String updatedBy;    //555

    }

    class cls_type {
        public String id;   //1
        public String name; //Lawfirms
        public String descriptions;
        public String proposals;
        public String proposalTypes;
        public String waitlists;
    }

    class cls_contactProvince {
        public String id;   //33
        public String code; //NY
        public String name; //New York
        public String urlEncodedName;   //new-york
        public String country;  //US
        public String created;  //2009-12-12 00:00:00
        public String updated;  //2009-12-12 00:00:00
        public String contactProvinces;

    }

    class cls_paymentType {
        public String id;   //2
        public String name; //Pay Per Lead
        public String descriptions;
        public String proposals;
    }

    public class cls_subscriptions {
        public String id;   //18157061
        public cls_proposal proposal;
        public String parentSubscription;
        public String start;    //2020-11-18 08:31:17
        public String discountAmt;  //0.00
        public String price;    //0.00
        public String elp;
        public String termLength;
        public String subscriptionCount;    //1
        public String pplDeposit;   //0.00
        public String leadCap;  //1050.00
        public String leadCapFrequency;
        public String rankingMultiplier;
        public String tier;
        public cls_subscriptionType subscriptionType;
        public String siteTid;
        public String startLeadVolume;
        public String endLeadVolume;
        public String leadVolumeUpdated;
        public String cancellationRequestDate;
        public String cancellationReason;
        public String status;   //active
        public String bypassLimitCheck; //0
        public String updated;
        public String created;  //2020-11-18 08:31:17
        public String elpUpdated;
        public String childrenSubscriptions;
        public String dataType1s;
        public String dataType2s;
        public cls_extraInfo extraInfo;
        public String revShare;
        public String revShareFixed;
        public String groupSelectionAmountType;
        public String docuTemplateId;
        public String sfSinId;  //1001423516.12345.8024D000000QXI3QAO

    }
    class cls_proposal {
        public String id;   //5596601
    }

    class cls_subscriptionType {
        public String id;   //9
    }

    class cls_extraInfo {
        public cls_term1 term1;
        public cls_term2Parents[] term2Parents;
        public cls_coverages coverages;
        public Decimal targetPrice; //0
    }
    class cls_term1 {
        public Integer id;  //169071
        public String category;
        public String parentTerm;
        public String name; //SSDI
        public String descriptions;
        public String level;
        public cls_childrenTerms[] childrenTerms;
        public String externalId;   //169071
        public String updated;
        public String created;
        public String primary;
        public String stateCode;
    }

    class cls_childrenTerms {
    }

    class cls_term2Parents {
        public Integer id;  //80373
        public String name; //Arizona
        public String externalId;   //80373
        public Integer selectedChildren;    //15
        public String totalChildren;    //15
    }
    class cls_coverages {
        public Integer min; //0
        public Integer max; //0
    }

    public static OrderJSONParse parse(String json){
        return (OrderJSONParse) System.JSON.deserialize(json, OrderJSONParse.class);
    }
}