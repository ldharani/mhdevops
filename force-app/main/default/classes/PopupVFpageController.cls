public with sharing class PopupVFpageController{


    public PopupVFpageController(ApexPages.StandardController controller) {

    }


    public PageReference closePopup() {
        displayPopup = false;
        return null;

    }


public boolean Edit{get;set;}
public boolean displayPopup{get;set;}

public pageReference Edit(){
 
system.debug('@@@@'+Edit);

//if(Edit==true)
displayPopup = true;
 
system.debug('----@'+displayPopup );
return null;
}
}