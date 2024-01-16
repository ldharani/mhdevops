@isTest
public class MDL_test_ctrl_viewDunningLetter {
static testMethod void testView() {
	PageReference myVfPage = Page.MDL_ViewDunningLetters;
    Test.setCurrentPage(myVfPage);
    MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
	myVfPage.getParameters().put('id', 'dd');
    MDL_Ctrl_ViewDunningLetters mytestCase=new MDL_Ctrl_ViewDunningLetters();
}
}