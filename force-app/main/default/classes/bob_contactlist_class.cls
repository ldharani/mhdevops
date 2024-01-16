global class bob_contactlist_class {
    public List<selectoption> areasOfPracticeList{get;set;}
    public String selectedareaOfPractice {get;set;}
    public String selectedProdType{get;set;}
    public List<GEO_Location__c > geoLocationsList{get;set;} 
    public list<selectoption> prodTypeList{get;set;}
    public Map<String,String> prodCodeMap {get;set;}
    public string searchCountry {get;set;}
    public string searchState {get;set;}
    public string searchCounty {get;set;}
    public string searchCity {get;set;}
    public boolean for_select_button{get;set;}
	
    public List<Contact> selected_con_list{get;set;}
    public List<wrapCon> con_list{get; set;}
    
    public bob_contactlist_class(){
        prodTypeList = new list<selectoption>();
        prodCodeMap = new Map<String,String>();
        List<Inventoried_Products_list_using_Product__c > iplist = Inventoried_Products_list_using_Product__c.getall().values();
        for(Inventoried_Products_list_using_Product__c ip: iplist){
            prodTypeList.add(new SelectOption(ip.Product_Name__c,ip.Product_Name__c));
            prodCodeMap.put(ip.Product_Name__c,ip.Product_Code__c);
        }
        selectedProdType = 'Lawyers.com Preferred Banner Placements';
        aop_List_Generation();
        searchCountry = 'USA';
        for_select_button = false;
    }

    public void aop_List_Generation(){
    	areasOfPracticeList = new list<selectoption>();        
        geoLocationsList = new List<GEO_Location__c>();
        String prodId = prodCodeMap.get(selectedProdType);
        String squery = 'select id,AOP_List_value__c,AOP_Name__c from GEO_Location__c where AOP_List_value__c INCLUDES (\'' + prodId + '\') order by AOP_Name__c limit 1000';
        geoLocationsList = database.query(squery);
        for(GEO_Location__c geo:geoLocationsList ){
            areasOfPracticeList.add(new SelectOption(geo.AOP_Name__c ,geo.AOP_Name__c));
        }
        
    }
    
    public void getContacts(){
        selected_con_list = new List<Contact>();
        con_list = new List<wrapCon>();
        for(Contact c : [select Id,AccountId,Name,Phone,Email from Contact where (Practice_Area_1__c = :selectedareaOfPractice or Practice_Area_2__c = :selectedareaOfPractice or Practice_Area_3__c = :selectedareaOfPractice or Practice_Area_4__c = :selectedareaOfPractice or Practice_Area_5__c = :selectedareaOfPractice) and DoNotCall=false and (Practice_Status__c != 'Judge' or Practice_Status__c != 'Deceased' or Practice_Status__c != 'Retired' or Practice_Status__c != 'Not Practicing' or Practice_Status__c != 'License Issues' or Practice_Status__c != 'Bad Contact Info' or Practice_Status__c != 'Government Attorney' or Practice_Status__c != 'Not an attorney') and (MH_Customer_Status__c != 'Active' or MH_Customer_Status__c != 'Evergreen') and Country__c = :searchCountry and (State__c = :searchState or State_2__c = :searchState or State_3__c = :searchState) and (County_1__c = :searchCounty or County_2__c = :searchCounty or County_3__c = :searchCounty) and (City__c =: searchCity or City_2__c =: searchCity or City_3__c =: searchCity) and In_AE_Book__c = false and Open_MH_Lead__c = false]){
            con_list.add(new wrapCon(c));
        }
        if(!con_list.isEmpty()){
            for_select_button = true;
        }
    }
    
    public void reset_details(){
        con_list.clear();
        selected_con_list.clear();
        for_select_button = false;
    }
    
    public void getSelectedCon(){
        selected_con_list.clear();
        for(wrapCon obj : con_list) {
            if(obj.selected == true) {
                selected_con_list.add(obj.con);
            }
        }
        //System.debug(selected_con_list);
        for(Contact c : selected_con_list){
            System.debug(c.Id +' '+ c.Name);
        }
    }
    
    public class wrapCon{
       	public Contact con {get; set;}
        public Boolean selected {get; set;}	
        public wrapCon(Contact c) {
            con = c;
            selected = false;
        }
    }
}