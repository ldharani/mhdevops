public class BatchesRunController {

    public PageReference ok() {
        pageReference pageref = new PageReference('/home/home.jsp');
        return pageref;
    }

    
    
    //Our collection of the class/wrapper objects cContact 
    public List<classWrapp> classnamesList {get; set;}
    public static String currentUserProfileId    = userInfo.getProfileId();
    public static String casemanagementProfileId = [select id, Name from Profile 
                                                     where Name= 'Case Management' LIMIT  1].id;
    
    //This method uses a simple get class Names and to return a List of class Names
    public List<classWrapp> getClassNames() {
        if(classnamesList == null) {
            classnamesList = new List<classWrapp>();
            
           // classnamesList.add(new classWrapp('Auto Allocation- Nolo Promotional Credits'));
              classnamesList.add(new classWrapp('Create ACH file for Bank to charge the customer'));
           /* if(currentUserProfileId != casemanagementProfileId){
                classnamesList.add(new classWrapp('Convert Pending MH Migration Accounts to MH Migration Completed'));
                classnamesList.add(new classWrapp('Convert Pending MH PX Migration Accounts to MH PX Migration Completed'));
                classnamesList.add(new classWrapp('Create ACH file for Bank to charge the customer'));
            }
           */ 
        }
        return classnamesList;
    }
     
    public PageReference processSelected() {

                //We create a new list of class Names that we be populated only with Names if they are selected
        List<String> selectedClassNames = new List<String>();

        //We will cycle through our list of class Names and will check to see if the selected property is set to true, if it is we add the Contact to the selectedContacts list
        for(classWrapp cls: getClassNames()) {
            if(cls.selected == true) {
                selectedClassNames.add(cls.className);
            }
        }
        
        //if(selectedClassNames == null || selectedClassNames.isEmpty()){
        //    system.debug('@@@@in condition');
        //    apexPages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, 'Please Select atleast one Class Name'));
        //    return null;
       // }

        // Now we have our list of selected class Names and can perform any type of logic we want
        System.debug('These are the selected Class Names...');
        for(String clsName : selectedClassNames) {
           /* if(clsName == 'Convert Pending MH Migration Accounts to MH Migration Completed'){
                Database.executeBatch(new mdl_BatchtochangeAccountfields(), 20);
            }
            else if(clsName == 'Convert Pending MH PX Migration Accounts to MH PX Migration Completed'){
                 Database.executeBatch(new MDL_BatchtochangePX_MigrateAccountfields(), 20);
            }
            else if(clsName == 'Auto Allocation- Nolo Promotional Credits'){
                 Database.executeBatch(new mdl_BatchtoallocateNoloPayments(), 20);
            }
            else if(clsName == 'Create ACH file for Bank to charge the customer'){
                 Database.executeBatch(new createnewPayments('Nolo_Invoice'), 20);
            }    
           */
        
           if(clsName == 'Create ACH file for Bank to charge the customer'){
                 Database.executeBatch(new createnewPayments('Nolo_Invoice'), 20);
            }
        }
        classnamesList=null; // we need this line if we performed a write operation  because getClassNames gets a fresh list now
        return null;
    }

    
    // This is our wrapper/container class. A container class is a class, a data structure, or an abstract data type whose instances are collections of other objects. In this example a wrapper class contains both the standard salesforce object Contact and a Boolean value
    public class classWrapp {
        public String className {get; set;}
        public Boolean selected {get; set;}

        //This is the contructor method. When we create a new cContact object we pass a Contact that is set to the con property. We also set the selected value to false
        public classWrapp(String st) {
            className = st;
            selected  = false;
        }
    }


}