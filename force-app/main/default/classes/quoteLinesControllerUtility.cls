/**@@ 
#CLASS NAME          :    quoteLinesControllerUtility
#TEST CLASS          :    
#CREATED BY          :    
#DESCRIPTION         :    This apex class called from apex class 'quoteLinesController' for SOQL Query on Object 'GEO_Location__c'

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-7163    Sachin        16/06/2022   Sai Vihari      T01     Miami city value is not showing up in production
************************************************************************************************************************
@@**/

public class quoteLinesControllerUtility {
	/*Public Static List<GEO_Location__c> getGeoLocforCountry = new List<GEO_Location__c>();
    Public Static List<GEO_Location__c> getGeoLocforState = new List<GEO_Location__c>();
    Public Static List<GEO_Location__c> getGeoLocforXrefState = new List<GEO_Location__c>();
    Public Static List<GEO_Location__c> getGeoLocforCity = new List<GEO_Location__c>();
    Public Static List<GEO_Location__c> getGeoLocforXrefCnCity = new List<GEO_Location__c>();
    Public Static List<GEO_Location__c> getGeoLocforSerCounty = new List<GEO_Location__c>();
    Public Static List<GEO_Location__c> getGeoLocforXrefCunCounty = new List<GEO_Location__c>();*/
    Public Static List<GEO_Location__c> getGeoLocSuggLst = new List<GEO_Location__c>();
    Public Static List<Usage_State_and_County__c> getUsgNCountyLst = new List<Usage_State_and_County__c>();
    
    public static List<GEO_Location__c> fetchSuggesforCountry(string inputTemp){
        if(getGeoLocSuggLst.size() == 0){
            getGeoLocSuggLst = [SELECT Id, CountryName__c FROM GEO_Location__c WHERE CountryName__c LIKE :inputTemp LIMIT 5];
        }
        return getGeoLocSuggLst; 
    }
    
    /* To Fetch Auto Suggestion values for all State Attributes */
    //for state and service state
    Public Static List<GEO_Location__c> fetchSuggesforState(string inputTemp, string strCountry){
        if(getGeoLocSuggLst.size() == 0){
            getGeoLocSuggLst = [SELECT Id, State_Abbrevation__c FROM GEO_Location__c WHERE CountryName__c =: strCountry AND State_Abbrevation__c LIKE :inputTemp LIMIT 5];
        }
        return getGeoLocSuggLst; 
    }
    //for xref state
    Public Static List<GEO_Location__c> fetchSuggesforXrefState(string inputTemp, string strXrefCountry, Id MHGeoRecTypeId){
        if(getGeoLocSuggLst.size() == 0){
            getGeoLocSuggLst = [SELECT Id, State_Abbrevation__c FROM GEO_Location__c WHERE CountryName__c =: strXrefCountry AND State_Abbrevation__c LIKE :inputTemp AND RecordTypeId =:MHGeoRecTypeId LIMIT 5];
        }
        return getGeoLocSuggLst; 
    }
    
    /* To Fetch Auto Suggestion values for all City Attributes */
    //for service city
    Public Static List<GEO_Location__c> fetchSuggesforSerCity(string inputTemp, string strServiceCountry, string strServiceState){
        System.debug('inputTemp ::'+inputTemp);
        System.debug('strServiceCountry ::'+strServiceCountry);
        System.debug('strServiceState ::'+strServiceState);
        if(getGeoLocSuggLst.size() == 0){
            //<T01>
            getGeoLocSuggLst = [SELECT Id, City_Name__c FROM GEO_Location__c WHERE CountryName__c =: strServiceCountry AND State_Abbrevation__c =: strServiceState AND City_Name__c LIKE :inputTemp ORDER BY City_Name__c LIMIT 5];
        }
        return getGeoLocSuggLst; 
    }
    //for xref city and city
    Public Static List<GEO_Location__c> fetchSuggesforXrefCnCity(string inputTemp, string strCountry, String strState,String countyName, Id MHGeoRecTypeId){
        System.debug('inputTemp ==>'+inputTemp);
        System.debug('strServiceCountry ==>'+strCountry);
        System.debug('strState ==>'+strState);
        System.debug('MHGeoRecTypeId ==>'+MHGeoRecTypeId);
        System.debug('countyName ==>'+countyName);
        if(getGeoLocSuggLst.size() == 0){
            if(String.isNotBlank(countyName)){
	    //<T01>
            getGeoLocSuggLst = [SELECT Id, City_Name__c FROM GEO_Location__c WHERE CountryName__c =: strCountry AND State_Abbrevation__c =: strState AND City_Name__c LIKE :inputTemp AND County_Name__c LIKE :countyName AND RecordTypeId =:MHGeoRecTypeId ORDER BY City_Name__c LIMIT 5];
            }else{
              getGeoLocSuggLst = [SELECT Id, City_Name__c FROM GEO_Location__c WHERE CountryName__c =: strCountry AND State_Abbrevation__c =: strState AND City_Name__c LIKE :inputTemp  AND RecordTypeId =:MHGeoRecTypeId ORDER BY City_Name__c LIMIT 5];
             
            }
            }
        return getGeoLocSuggLst; 
    }
    
    /* To Fetch Auto Suggestion values for all County Attributes */
    //for service county - MH
    Public Static List<GEO_Location__c> fetchSuggesforSerCounty(string inputTemp, string strServiceState){
        if(getGeoLocSuggLst.size() == 0){
            getGeoLocSuggLst = [SELECT Id, County_Name__c FROM GEO_Location__c WHERE State_Abbrevation__c =: strServiceState AND County_Name__c LIKE :inputTemp LIMIT 5];
        }
        return getGeoLocSuggLst; 
    }
    //for ussage county
    Public Static List<GEO_Location__c> fetchSuggesforSerCountyUsage(string inputTemp){
        if(getGeoLocSuggLst.size() == 0){
            getGeoLocSuggLst = [SELECT Id, County_Name__c FROM GEO_Location__c WHERE County_Name__c LIKE :inputTemp LIMIT 5];
        }
        return getGeoLocSuggLst; 
    }
    //for service county - MH
    Public Static List<GEO_Location__c> fetchSuggesforXrefCoNCounty(string inputTemp, string strServiceCountry, string strState, id MHGeoRecTypeId){
        System.debug('getGeoLocSuggLst==>>'+getGeoLocSuggLst);
        System.debug('inputTemp ==>'+inputTemp);
        System.debug('strServiceCountry ==>'+strServiceCountry);
        System.debug('strState ==>'+strState);
        System.debug('MHGeoRecTypeId ==>'+MHGeoRecTypeId);
        
        if(getGeoLocSuggLst.size() == 0){
            getGeoLocSuggLst = [SELECT Id, County_Name__c FROM GEO_Location__c WHERE CountryName__c =: strServiceCountry AND State_Abbrevation__c =: strState AND County_Name__c LIKE :inputTemp AND RecordTypeId =:MHGeoRecTypeId LIMIT 5];
             System.debug('getGeoLoc==>>'+JSON.Serialize(getGeoLocSuggLst.size()));
        }
        return getGeoLocSuggLst; 
    }
    
    /* To Fetch Auto Suggestion values for AOP and PA Attributes */
    //for AOP
    Public Static List<GEO_Location__c> fetchSuggesforAOP(string inputTemp,id AOPListRecTypeId, Product2 prdC){
        List<GEO_Location__c> glLst = new List<GEO_Location__c>();
        if(getGeoLocSuggLst.size() == 0){
            getGeoLocSuggLst = [SELECT Id, AOP_Name__c, AOP_List_value__c FROM GEO_Location__c WHERE AOP_Name__c LIKE :inputTemp AND AOP_Name__c != null AND RecordTypeId =: AOPListRecTypeId LIMIT 1000];
            for(GEO_Location__c g:getGeoLocSuggLst){
                List<String> tempSt = g.AOP_List_value__c.split(';');
                if(tempSt.contains(prdC.ProductCode)){
                    glLst.add(g);
                }
            }
        }
        system.debug('==glLst=='+glLst);
        return glLst;
    }
    //for Practice Area
    Public Static List<Usage_State_and_County__c> fetchSuggesforPA(string inputTemp){
        if(getUsgNCountyLst.size() == 0){
            getUsgNCountyLst = [SELECT Id, Practice_Area__c, Practice_Area_Integration_Id__c FROM Usage_State_and_County__c WHERE Practice_Area__c LIKE :inputTemp AND Practice_Area__c != null LIMIT 10];
        }
        return getUsgNCountyLst; 
    }
}