@isTest(SeeAllData=true)
public with sharing class MDL_Test_CtrlDunningDisplayPage {
		static testMethod void Test_Page() {
			MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
            MDL_CtrlDunningDisplayPage Tst=new MDL_CtrlDunningDisplayPage();
            Tst.generateDunningLetters();
            Tst.sendMail();
        }
}