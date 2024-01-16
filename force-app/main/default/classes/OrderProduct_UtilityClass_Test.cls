@isTest
public class OrderProduct_UtilityClass_Test { 
    public static testmethod void testcaseA(){
        Set<Id> odItemIds = new Set<Id>();
        List<String> stt = new List<String>{'test'};
            Set<String> sttnn = new Set<String>{'test'};
                Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
        odItemIds.add(acc.Id);
        
        test.startTest();
        OrderProduct_UtilityClass ott = new OrderProduct_UtilityClass();
        OrderProduct_UtilityClass.ordlist(odItemIds);
        OrderProduct_UtilityClass.OrderProductCaseCreation(odItemIds);
        OrderProduct_UtilityClass.OrderProductCaseCreationNgage(odItemIds);
        OrderProduct_UtilityClass.OrderProductCaseCreationA(odItemIds);
        OrderProduct_UtilityClass.OrderProductCaseCreationGroup(stt);
        OrderProduct_UtilityClass.OrderProductCaseCreationAtt(odItemIds);
        OrderProduct_UtilityClass.getOrdItemListForStatus(odItemIds);
        OrderProduct_UtilityClass.getSubLstForStatus(odItemIds);
        OrderProduct_UtilityClass.getSubOrderItem(sttnn);
        OrderProduct_UtilityClass.getAssetLst(odItemIds);
        OrderProduct_UtilityClass.userListMethod();
        test.stopTest();
    }
}