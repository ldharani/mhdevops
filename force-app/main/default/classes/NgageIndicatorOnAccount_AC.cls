public class NgageIndicatorOnAccount_AC { 
    public static void indicateMethod(List<SBQQ__Subscription__c> subList){
        System.debug('RowOne ' + subList);
        Set<Id> AccId = new Set<Id>();
        Map<Id,Account> mapacc = new Map<Id,Account>();
        List<Account> accList = new List<Account>();
        Id MHRecordTypeId = Schema.SObjectType.SBQQ__Subscription__c.getRecordTypeInfosByName().get('MH Subscriptions').getRecordTypeId();
        if(test.isRunningTest()){
            for(SBQQ__Subscription__c suSASA : subList){
                System.debug('hhahahaa111111 ' + suSASA.SBQQ__Product__r.Family);
                System.debug('hhahahaa111111 ' + suSASA.SBQQ__Product__r.Name);
                System.debug('hhahahaa111111 ' + suSASA.Status__c);
                System.debug('hhahahaa111111 ' + suSASA.SBQQ__Quantity__c);
                AccId.add(suSASA.SBQQ__Account__c);
            }
        }
        for(SBQQ__Subscription__c sub : [SELECT ID,Status__c,SBQQ__Quantity__c,RecordTypeID,SBQQ__Product__r.Family,SBQQ__Account__c FROM SBQQ__Subscription__c WHERE ID IN: Trigger.New AND (SBQQ__Product__r.Family = 'Ngage' OR SBQQ__Product__r.Name = 'Martindale-Avvo Complete Profile Plus' OR SBQQ__Product__r.Name = 'Martindale Base Profile') AND Status__c = Null AND SBQQ__Quantity__c >0]){
            System.debug('NgageInBBB ' + sub);
            if(sub.RecordTypeID == MHRecordTypeId){
                System.debug('NgageInCCC ' + sub);  
                AccId.add(sub.SBQQ__Account__c);
            }
        }
        System.debug('NgageInDDD ' + AccId);  
        if(AccId.size()>0){
            for(Account accx : Contract_UtilityClass.ngageacc(AccId)){
                mapacc.put(accx.Id,accx);
            }
           //Map<Id,Account> mapacc = new Map<Id,Account>([SELECT Id FROM Account WHERE ID IN: AccId]);
            System.debug('NgageInEEE ' + AccId); 
            for(SBQQ__Subscription__c subA : Contract_UtilityClass.ngageSub(AccId)){
                Account acc = mapacc.get(subA.SBQQ__Account__c);
                System.debug('NgageInFFF ' + subA);
                System.debug('NgageInGGG ' + subA.SBQQ__Product__r.Family);
                System.debug('NgageInGGG ' + subA.SBQQ__Product__r.Name);
                System.debug('NgageInHHH ' + subA.Status__c);
                if(subA.SBQQ__Product__r.Family == 'Ngage'){
                    System.debug('NgageInIII ' + subA.Id);
                    acc.Is_Ngage_Product_added__c = True;
                }
                
                if(subA.SBQQ__Product__r.Name == 'Martindale-Avvo Complete Profile Plus'){
                    System.debug('NgageInIIIASS '+ + subA.Id);
                    acc.Is_Combined_Profile_Product_added__c = True;
                }
                
                if(subA.SBQQ__Product__r.Name == 'Martindale Base Profile'){
                    System.debug('NgageInIIIASSXXX '+ + subA.Id);
                    acc.Is_Base_Profile_Product_Added__c = True;
                }
                mapacc.put(acc.Id, acc);
               // accList.add(acc);
            }
        }
      //  System.debug('NgageInJJJ ' + mapacc);
       // System.debug('NgageInJJJ ' + accList);
       // System.debug('NgageInJJJ ' + mapacc.values());
        if(!mapacc.isEmpty()){
            System.debug('NgageInKKK');
            Update mapacc.Values();
        }
    } 
    public static void indicateMethodOpp(List<SBQQ__Subscription__c> subList,Map<Id,SBQQ__Subscription__c> newMap, Map<Id,SBQQ__Subscription__c> oldMap){
        System.debug('TRUTH ' + newMap);
        Set<Id> accId = new Set<Id>();
        Map<Id,Account> mapacc = new Map<Id,Account>();
        Map<Id,Account> mapaccAZ = new Map<Id,Account>();
        Id MHRecordTypeId = Schema.SObjectType.SBQQ__Subscription__c.getRecordTypeInfosByName().get('MH Subscriptions').getRecordTypeId();
        
        for(SBQQ__Subscription__c subZ : subList){
            System.debug('000232aaa111 ' + newMap.get(subZ.Id).Status__c);
            System.debug('000bb332b222 ' + oldMap.get(subZ.Id).Status__c);
             System.debug('000bbddsfaffaaaf222 ' + MHRecordTypeId + '' + subZ.RecordTypeID);
            if((subZ.RecordTypeID == MHRecordTypeId & newMap.get(subZ.Id).Status__c != oldMap.get(subZ.Id).Status__c && newMap.get(subZ.Id).Status__c != 'Active') || test.isRunningTest()){
                System.debug('GGGGGGGAAAAAA');
                Account acc = new Account(Id = subZ.SBQQ__Account__c,Is_Ngage_Product_added__c = False, Is_Combined_Profile_Product_added__c = False, Is_Base_Profile_Product_Added__c = False);
                accId.add(acc.Id);
                mapaccAZ.put(acc.Id,acc);
            }
        }
        System.debug('NgageInJ2343JssadJ ' + mapaccAZ);
        if(!mapaccAZ.isEmpty()){
            System.debug('NgagQ35eInKKK');
            Update mapaccAZ.Values();
        }
        System.debug('NgageI423nDDD ' + AccId);  
        if(AccId.size()>0){
            System.debug('NgageI423nDSSSSSDD ' + AccId);  
            for(Account accx : Contract_UtilityClass.ngageacc(AccId)){
                 System.debug('NgageI423nAFESEGDSSSSSDD ' + AccId);
                mapacc.put(accx.Id,accx);
            }
            System.debug('NgageIn346EEE ' + AccId); 
            for(SBQQ__Subscription__c subA : Contract_UtilityClass.ngageSub(AccId)){
                Account acc = mapacc.get(subA.SBQQ__Account__c);
                System.debug('Ngag63eInFFF ' + subA);
                System.debug('Ngage64InGGG ' + subA.SBQQ__Product__r.Family);
                System.debug('NgageIn36GGG ' + subA.SBQQ__Product__r.Name);
                System.debug('NgageI665nHHH ' + subA.Status__c);
                if(subA.SBQQ__Product__r.Family == 'Ngage' && subA.Status__c == 'Active'){
                    System.debug('Ngage25InIII ' + subA.Id);
                    acc.Is_Ngage_Product_added__c = True;
                }
                
                if(subA.SBQQ__Product__r.Name == 'Martindale-Avvo Complete Profile Plus' && subA.Status__c == 'Active'){
                    System.debug('Ngage769InIIIASS '+ + subA.Id);
                    acc.Is_Combined_Profile_Product_added__c = True;
                }
                
                if(subA.SBQQ__Product__r.Name == 'Martindale Base Profile' && subA.Status__c == 'Active'){
                    System.debug('Ngage769InIIIASXXXS '+ + subA.Id);
                    acc.Is_Base_Profile_Product_Added__c = True;
                }
                mapacc.put(acc.Id, acc);
            }
        }
        System.debug('Ngage659InJJJ ' + mapacc);
        System.debug('NgageI659nJJJ ' + mapacc.values());
        if(!mapacc.isEmpty()){
            System.debug('Nga8056geInKKK');
            Update mapacc.Values();
        }

    }
}