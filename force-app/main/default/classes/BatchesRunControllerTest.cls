// Author           : Sai
// Description      : Test class for BatchesRunController


@isTest
public class BatchesRunControllerTest {
    
    static testmethod void run2condition(){
        
        BatchesRunController classinstance = new BatchesRunController(); 
        List<BatchesRunController.classWrapp> wrapp = new List<BatchesRunController.classWrapp>();
        wrapp = classinstance.getClassNames();
        
        //making checkboxes true here
        for(BatchesRunController.classWrapp singlewrap : wrapp){
            singlewrap.selected = true;
        }
        classinstance.processSelected();
        
    }
  
}