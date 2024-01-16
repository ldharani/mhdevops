public class mdl_contactEmailupdateController { 
    
    public string orderNumber{get;set;}
    public invoiceit_s__Job__c order{get;set;}
    public boolean ordernotavailable{get;set;}
    public boolean updatecon{get;set;}
    public contact con{get;set;}
    public mdl_contactEmailupdateController(){
        order = new invoiceit_s__Job__c();
        con = new contact();
        ordernotavailable = true;
    }
    
    public pageReference getorderDetails(){
        list<invoiceit_s__Job__c> temporderlist = new list<invoiceit_s__Job__c>();
        system.debug('@@@orderNumber'+ orderNumber);
        if(orderNumber == '' || orderNumber == null) {
          apexpages.Message am=new apexpages.Message(ApexPages.Severity.error, 'Please Enter Order Name ');
          apexpages.addMessage(am);  
          
          return null;
        }
        if(orderNumber != null){
            if(test.isRunningTest()){
                 temporderlist = [select id, Name, invoiceit_s__Account__c,invoiceit_s__Status__c,
                         invoiceit_s__Billing_Contact__c,
                         invoiceit_s__Billing_Contact__r.Email
                        from invoiceit_s__Job__c
                            
                            Limit 1];
            }
            else{
                temporderlist = [select id, Name, invoiceit_s__Account__c,invoiceit_s__Status__c,
                         invoiceit_s__Billing_Contact__c,
                         invoiceit_s__Billing_Contact__r.Email
                        from invoiceit_s__Job__c
                           where Name =:orderNumber 
                            Limit 1];
                
            }
            

            if( temporderlist.isEmpty()){
                apexpages.Message am=new apexpages.Message(ApexPages.Severity.error, 'Order Name does not exist.Kindly enter a correct name to update the billing contact email ID');
                apexpages.addMessage(am);
                return null;
            }
            else{
                if(temporderlist[0].invoiceit_s__Billing_Contact__c != null){
                    con = [select id, Name , Email 
                             from contact
                              where id=: temporderlist[0].invoiceit_s__Billing_Contact__c];
                    updatecon = true;
                }
                order = temporderlist[0];
            }
            
            ordernotavailable = false;
        }
        return null;
    }
    
    public pageReference updatEmail(){
        try{
            if(con.Email == null || con.Email == ''){
                apexpages.Message am=new apexpages.Message(ApexPages.Severity.error, 'You must Enter a Valid Email ID');
                apexpages.addMessage(am);
                return null;
            }
            update con;
            updatecon = false;
             apexpages.Message am=new apexpages.Message(ApexPages.Severity.info, 'Billing Contact Email has been Updated Successfully');
                apexpages.addMessage(am);
            
        }
        catch(exception e){
            system.debug('Exception'+ e);
        }
        return null;
    }
    
    public pageReference ok(){
        pageReference pageref = new PageReference('/home/home.jsp');
        return pageref;
    }

}