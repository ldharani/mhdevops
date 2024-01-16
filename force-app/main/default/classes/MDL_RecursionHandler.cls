/***********************************************************************************************************************
* @author - Sc
* @date - 30 Mar 2022
* @description - MDL_RecursionHandler
* @testclass - 

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6320    SS            31/03/2022   John Mattheson          Moving process builder to Apex
VR            12/05/2022                   T01     Too Many SOQL 101 Issues
MHBS-6018    SS            31/03/2022   John Mattheson  T02     Move process builders to apex
MHBS-7812    Lakshmi       30/09/2022   Lori            T03     Add recursion variable for populating Sales Rep Director    
************************************************************************************************************************/
global with sharing class MDL_RecursionHandler {
    global static boolean firstRun = true;
    global static boolean CheckUpdate = true;
    global static boolean milestonecheck = true;
    global static boolean CancelHandleronQuote= true;
    global static boolean releaseInvQuote= true;
    global static boolean updateAcquisitionDate = true;
    global static boolean UpsellPackageAssist= true;
    global static boolean createPaymentMethod = true;
    global static boolean voidDocuSignEnvelopes = true;
    global static boolean AfterOnOrderRPCCheck =  true;
    global static boolean orderContactUpdate = true;
    global static boolean orderProdOffset = true;
    global static boolean orderProdCancel = true;
    global static boolean updateSubc = true;
    global static boolean quoteHandlerCheck = true;
    //global static boolean OrderProductCaseCreation_AC  =  true;
    global static boolean packgrecursion = true;
    global static boolean CheckAfterUpdate = true;    
    global static boolean checkValidation = true;
    global static boolean allowtestclass = false;
    global static boolean recursiveCheck = true;    
    global static boolean recursiveCheckOI = true;//<T02>
    global static boolean recursiveCheckOIUpdate1 = true; //T01
    global static boolean recursiveCheckOIUpdate2 = true; //T01
    global static boolean recursiveCheckOIUpdate3 = true; //T01
    global static boolean attrLineCheck = true;
    global static boolean updateContactRecursion = true;
    global static boolean releaseInventoryOnOppClosedLost = true;
    global static Map<Id,Boolean> mapOrderRPCIdNBooleanForCancelXML = new Map<Id,Boolean>();
    global static Map<Id,Boolean> mapOrderRPCIdNBooleanForOrderFFDXML = new Map<Id,Boolean>();
    global static Map<Id,Boolean> mapOrderRPCIdNBooleanForManuallyFFDXML = new Map<Id,Boolean>();   
    global static boolean stopAccRecursion = true;
    global static Map<String,Boolean> mapInventoryIdNBooleanForReleaseInventory = new Map<String,Boolean>();
    global static boolean avvoWinbackProcessRecurssion = true;
    global static boolean populateLatestChildOrderRecursion = true;
    global static boolean checkhandleMilestoneBeforeTriggerRecursion = true; //added by sai MHBS-4392
    //global static boolean TaskAfterUpdateRecurstion = true; //added by sai MHBS-4392
    global static boolean UpdateQuoteStartEndDate = true;
    global static boolean UpdatepaymentTerms = true;
    global static boolean UpdatepaymentTermsInsert = true;
    global static boolean updatePaymentTermsonQuote = true;
    global static boolean handleTCVlogicOnSubHandler = true;
    global static boolean handleTCVlogicOnSubHandlerUpdate = true;
    global static boolean handleAvvoProjectCreation = true;
    global static boolean batchAutoEvgPriceincreaseCheck = true;
    global static boolean contractHandlerCheck = true;//MHBS-6320
    global static boolean contractUpdateCheck = true;//MHBS-6320
    global static boolean cancelQuoteCreationCheck = true;
    global static boolean restrictSalesRepDirectorMultipleUpdate = true; //<T03>
    global static boolean TruncatedStatusUpdateonEGandREG = true;
    global static boolean updateOIRenewRebase = true;
    global static boolean contactUpdatesFromOIRecursion = true;
    global static boolean qlUpgrdDwngrdUpdates = true;
        global static boolean restrictmultipleorderitemstatusupdate = true;
}