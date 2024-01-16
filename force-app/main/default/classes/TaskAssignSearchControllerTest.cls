@isTest(seeAlldata = true)
public class TaskAssignSearchControllerTest {
    
    static testmethod void run2condition(){
        
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        
        //creating user
        User user = testData.getUser();
        
        //creating public group
        Group testG = new Group();
        testG.Name = 'Test Group';
        insert testG;
        
        //Search keyword 
        String searchString = 'Test';
        PageReference pageRef = Page.TaskAssignSearchPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('lksrch', searchString);
        ApexPages.currentPage().getParameters().put('u', 'True');
        TaskAssignSearchController cc = new TaskAssignSearchController();
        cc.search();
         ApexPages.currentPage().getParameters().put('lksrch', searchString);
        ApexPages.currentPage().getParameters().put('u', 'false');
        TaskAssignSearchController cc1 = new TaskAssignSearchController();
        cc1.search();
        cc.getFormTag();
        cc.getTextBox();
        
        
        
    }

}