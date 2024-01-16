public class MergeAccountCallout {
    
    public static Boolean isFirstTime = true;
    
    @Future(callout=true)
    public static void mergeAccUpdate(Set<Id> masterAccId, Set<Id> deletedAccIds, Set<Id> delAccIds,Set<Id> delAttyIds, Id masterRecIds) {
        
        String IB_CustomerNumberM;
        String MH_CustomerNumberM;
        String MH_OrgId_M;
        String MN_CustomerNumberM;
        String MN_GroupId_M;
        String MNG_CustomerNumberM;
        String CAP_CustomerNumberM;
        String Frim_CustomerNumberM;
        List<String> Attorney_CustomerNumberM = new List<String>();
        
        String IB_CustomerNumberDel;
        String MH_CustomerNumberDel; 
        String MH_OrgId_Del;
        String MN_CustomerNumberDel;
        String MN_GroupId_Del;
        String MNG_CustomerNumberDel;
        String CAP_CustomerNumberDel;
        String Frim_CustomerNumberDel;
        List<String> Attorney_CustomerNumberDel = new List<String>();
        
        //Get all the Delete Account related Customer Number[PREVIOUS SF]
        List<Account> IBAccountDelList = [SELECT Id,ParentId,RecordTypeId,MH_Cust_Number__c FROM Account WHERE Id IN : deletedAccIds];
        for(Account accIB : IBAccountDelList){
            if(accIB.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId()){
                IB_CustomerNumberDel = accIB.MH_Cust_Number__c;
            }
        }
        Set<Id> FirmAccountIdDel = new Set<Id>();
        List<Account> allDelAccList = [SELECT Id,ParentId,RecordTypeId,MH_Cust_Number__c,Org_Id__c,Nolo_Group_ID__c FROM Account WHERE Id IN: delAccIds];
        for(Account accAll : allDelAccList){
            if(accAll.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId()){
                MH_CustomerNumberDel = accAll.MH_Cust_Number__c; 
                MH_OrgId_Del = accAll.Org_Id__c;
            }
            if(accAll.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-N Account').getRecordTypeId()){
                MN_CustomerNumberDel = accAll.MH_Cust_Number__c; 
                MN_GroupId_Del = accAll.Nolo_Group_ID__c;
            }
            if(accAll.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-NG Account').getRecordTypeId()){
                MNG_CustomerNumberDel = accAll.MH_Cust_Number__c; 
            }
            if(accAll.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Captorra Account').getRecordTypeId()){
                CAP_CustomerNumberDel = accAll.MH_Cust_Number__c; 
            }
            if(accAll.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Firm Account').getRecordTypeId()){
                Frim_CustomerNumberDel = accAll.MH_Cust_Number__c;
                FirmAccountIdDel.add(accAll.Id);
                System.debug('XXXXXXXXXX' + FirmAccountIdDel);
            }
        } 
        if(delAttyIds.Size() > 0){
            System.debug('YYYYYYYYYY');
            for(Account att : [SELECT Id,ParentId,RecordTypeId,MH_Cust_Number__c FROM Account WHERE Id IN : delAttyIds]){
                Attorney_CustomerNumberDel.add(att.MH_Cust_Number__c);
                System.debug('yyyyyyyyyy' + Attorney_CustomerNumberDel);
            } 
        }else{
            for(Account att : [SELECT Id,ParentId,RecordTypeId,MH_Cust_Number__c FROM Account WHERE ParentId IN : FirmAccountIdDel]){
                Attorney_CustomerNumberDel.add(att.MH_Cust_Number__c);
                System.debug('yyyyyyyyyyZZ' + Attorney_CustomerNumberDel);
            } 
        }
        
        
        //Get all the Master Account related Customer Number[Current SF]
        List<Account> IBAccountList = [SELECT Id,ParentId,RecordTypeId,MH_Cust_Number__c FROM Account WHERE Id IN : masterAccId];
        for(Account accIB : IBAccountList){
            if(accIB.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId()){
                IB_CustomerNumberM = accIB.MH_Cust_Number__c;
            }
        }
        Set<Id> FirmAccountId = new Set<Id>();
        List<Account> allAccountList = [SELECT Id,ParentId,RecordTypeId,MH_Cust_Number__c,Org_Id__c,Nolo_Group_ID__c FROM Account WHERE ParentId IN : masterAccId];
        for(Account accAll : allAccountList){
            if(accAll.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId()){
                MH_CustomerNumberM = accAll.MH_Cust_Number__c; 
                MH_OrgId_M = accAll.Org_Id__c;
            }
            if(accAll.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-N Account').getRecordTypeId()){
                MN_CustomerNumberM = accAll.MH_Cust_Number__c; 
                MN_GroupId_M = accAll.Nolo_Group_ID__c;
            }
            if(accAll.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-NG Account').getRecordTypeId()){
                MNG_CustomerNumberM = accAll.MH_Cust_Number__c; 
            }
            if(accAll.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Captorra Account').getRecordTypeId()){
                CAP_CustomerNumberM = accAll.MH_Cust_Number__c; 
            }
            if(accAll.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Firm Account').getRecordTypeId()){
                Frim_CustomerNumberM = accAll.MH_Cust_Number__c; 
                FirmAccountId.add(accAll.Id);
            }
        } 
        for(Account att : [SELECT Id,ParentId,RecordTypeId,MH_Cust_Number__c FROM Account WHERE ParentId IN : FirmAccountId]){
            if(att.ParentId != Null){
                Attorney_CustomerNumberM.add(att.MH_Cust_Number__c);
            }
        }
        System.debug('IB_CustomerNumberM*********'+ IB_CustomerNumberM);
        System.debug('MH_CustomerNumberM*********'+ MH_CustomerNumberM);
        System.debug('MH_OrgId_M*********'+ MH_OrgId_M);
        System.debug('MN_CustomerNumberM*********'+ MN_CustomerNumberM);
        System.debug('MN_GroupId_M*********'+ MN_GroupId_M);
        System.debug('MNG_CustomerNumberM*********'+ MNG_CustomerNumberM);
        System.debug('CAP_CustomerNumberM*********'+ CAP_CustomerNumberM);
        System.debug('Frim_CustomerNumberM*********'+ Frim_CustomerNumberM);
        System.debug('Attorney_CustomerNumberM*********'+ Attorney_CustomerNumberM);
        
        
        
        
        List<Account> mastAccDate = [SELECT Id,ParentId,RecordTypeId,MH_Cust_Number__c,Org_Id__c,Nolo_Group_ID__c,Deleted_Date_Time__c,LastModifiedDate  FROM Account WHERE Id IN : masterAccId];
        Datetime dt = mastAccDate[0].LastModifiedDate;
        String DateT = dt.format('MMddyyyyHHmmss');
        Long dateTime_merg = long.valueOf(DateT);
        System.debug('datetimeeeee' + dateTime_merg);
        
        
        System.debug('IB_CustomerNumberDel*********'+ IB_CustomerNumberDel);
        System.debug('MH_CustomerNumberDel*********'+ MH_CustomerNumberDel);
        System.debug('MH_OrgId_Del*********'+ MH_OrgId_Del);
        System.debug('MN_CustomerNumberDel*********'+ MN_CustomerNumberDel);
        System.debug('MN_GroupId_Del*********'+ MN_GroupId_Del);
        System.debug('MNG_CustomerNumberDel*********'+ MNG_CustomerNumberDel);
        System.debug('CAP_CustomerNumberDel*********'+ CAP_CustomerNumberDel);
        System.debug('Frim_CustomerNumberDel*********'+ Frim_CustomerNumberDel);
        System.debug('Attorney_CustomerNumberDel*********'+ Attorney_CustomerNumberDel);
        System.debug('dateTime_merg*********'+ dateTime_merg);
        
        /**************Convert String to Integer********************/
        Long IB_CustomerNumberM_I;  
        Long MH_CustomerNumberM_I;
        Long MH_OrgId_M_I;
        Long MN_CustomerNumberM_I;
        Long MN_GroupId_M_I;
        Long MNG_CustomerNumberM_I;
        Long CAP_CustomerNumberM_I;
        Long Frim_CustomerNumberM_I;
        List<Integer> Attorney_CustomerNumberM_I = new List<Integer>();
         
        if(IB_CustomerNumberM != Null){
            IB_CustomerNumberM_I = Long.ValueOf(IB_CustomerNumberM);
        }else{
            IB_CustomerNumberM_I = 0;
        }
        if(MH_CustomerNumberM != Null){
            System.debug('MH_CustomerNumberM------------>' + MH_CustomerNumberM);
            MH_CustomerNumberM_I = Long.ValueOf(MH_CustomerNumberM);
            System.debug('MH_CustomerNumberM_I------------->' + MH_CustomerNumberM_I);
        }else{
            MH_CustomerNumberM_I = 0;
        }
        if(MH_OrgId_M != Null){
            MH_OrgId_M_I = Long.ValueOf(MH_OrgId_M);
        }else{
            MH_OrgId_M_I = 0;
        }
        if(MN_CustomerNumberM != Null){
            MN_CustomerNumberM_I = Long.ValueOf(MN_CustomerNumberM);
        }else{
            MN_CustomerNumberM_I = 0;
        }
        if(MN_GroupId_M != Null){
            MN_GroupId_M_I = Long.ValueOf(MN_GroupId_M);
        }else{
            MN_GroupId_M_I = 0;
        }
        if(MNG_CustomerNumberM != Null){
            MNG_CustomerNumberM_I = Long.ValueOf(MNG_CustomerNumberM);
        }else{
            MNG_CustomerNumberM_I = 0;
        }
        if(CAP_CustomerNumberM != Null){
            CAP_CustomerNumberM_I = Long.ValueOf(CAP_CustomerNumberM);
        }else{
            CAP_CustomerNumberM_I = 0;
        }
        if(Frim_CustomerNumberM != Null){
            Frim_CustomerNumberM_I = Long.ValueOf(Frim_CustomerNumberM);
        }else{
            Frim_CustomerNumberM_I = 0;
        }
        if(Attorney_CustomerNumberM.size() > 0){
            for(String att : Attorney_CustomerNumberM ){
                Attorney_CustomerNumberM_I.add(Integer.ValueOf(att));
            }
        }else{
            Attorney_CustomerNumberM_I.add(0);
        }
        //----------------------------------------------//
        Long IB_CustomerNumberDel_I;
        Long MH_CustomerNumberDel_I;
        Long MN_CustomerNumberDel_I;
        Long MH_OrgId_Del_I;
        Long MN_GroupId_Del_I;
        Long MNG_CustomerNumberDel_I;
        Long CAP_CustomerNumberDel_I;
        Long Frim_CustomerNumberDel_I;
        List<Integer> Attorney_CustomerNumberDel_I = new List<Integer>();
        
        if(IB_CustomerNumberDel != Null){
            IB_CustomerNumberDel_I = Long.ValueOf(IB_CustomerNumberDel);
        }else{
            IB_CustomerNumberDel_I = 0;
        }
        if(MH_CustomerNumberDel != Null){
            MH_CustomerNumberDel_I = Long.ValueOf(MH_CustomerNumberDel);
        }else{
            MH_CustomerNumberDel_I = 0;
        }
        if(MH_OrgId_Del != Null){
            MH_OrgId_Del_I = Long.ValueOf(MH_OrgId_Del);
        }else{
            MH_OrgId_Del_I = 0;
        }
        if(MN_CustomerNumberDel != Null){
            MN_CustomerNumberDel_I = Long.ValueOf(MN_CustomerNumberDel);
        }else{
            MN_CustomerNumberDel_I = 0;
        }
        if(MN_GroupId_Del != Null){
            MN_GroupId_Del_I = Long.ValueOf(MN_GroupId_Del);
        }else{
            MN_GroupId_Del_I = 0;
        }
        if(MNG_CustomerNumberDel != Null){
            MNG_CustomerNumberDel_I = Long.ValueOf(MNG_CustomerNumberDel);
        }else{
            MNG_CustomerNumberDel_I = 0;
        }
        if(CAP_CustomerNumberDel != Null){
            CAP_CustomerNumberDel_I = Long.ValueOf(CAP_CustomerNumberDel);
        }else{
            CAP_CustomerNumberDel_I = 0;
        }
        if(Frim_CustomerNumberDel != Null){
            Frim_CustomerNumberDel_I = Long.ValueOf(Frim_CustomerNumberDel);
        }else{
            Frim_CustomerNumberDel_I = 0;
        }
        if(Attorney_CustomerNumberDel.size() > 0){
            for(String att : Attorney_CustomerNumberM ){
                Attorney_CustomerNumberDel_I.add(Integer.ValueOf(att));
            }
        }else{
            Attorney_CustomerNumberDel_I.add(0);
        }
        
        /**************currentSfNumbers********************/
        MergeAccounrJson.MhCustomerNumbers mhcstnumbersM = new MergeAccounrJson.MhCustomerNumbers();
        mhcstnumbersM.mhCustomerNumber = MH_CustomerNumberM_I;
        mhcstnumbersM.mhOrgId = MH_OrgId_M_I;
        
        MergeAccounrJson.AvvoCustomerNumbers avvocstnumbersM = new MergeAccounrJson.AvvoCustomerNumbers();
        avvocstnumbersM.avvoFirmCustomerNumber = Frim_CustomerNumberM_I;
        avvocstnumbersM.avvoAttorneyCustomerNumbers = Attorney_CustomerNumberM_I;
        
        MergeAccounrJson.NoloCustomerNumbers nolocstnumbersM = new MergeAccounrJson.NoloCustomerNumbers();
        nolocstnumbersM.noloCustomerNumber = MN_CustomerNumberM_I;
        nolocstnumbersM.noloGidNumber = MN_GroupId_M_I;
        
        MergeAccounrJson.CurrentSfNumbers currentnumbers = new MergeAccounrJson.CurrentSfNumbers();
        currentnumbers.sfGuid = IB_CustomerNumberM_I;
        currentnumbers.mhCustomerNumbers = mhcstnumbersM;
        currentnumbers.ngageCustomerNumber = MNG_CustomerNumberM_I;
        currentnumbers.captorraCustomerNumber = CAP_CustomerNumberM_I;
        currentnumbers.noloCustomerNumbers = nolocstnumbersM;
        currentnumbers.avvoCustomerNumbers = avvocstnumbersM;
        
        /**************previousSfNumbers********************/
        MergeAccounrJson.MhCustomerNumbers mhcstnumbersD = new MergeAccounrJson.MhCustomerNumbers();
        mhcstnumbersD.mhCustomerNumber = MH_CustomerNumberDel_I;
        mhcstnumbersD.mhOrgId = MH_OrgId_Del_I;
        
        MergeAccounrJson.AvvoCustomerNumbers avvocstnumbersD = new MergeAccounrJson.AvvoCustomerNumbers();
        avvocstnumbersD.avvoFirmCustomerNumber = Frim_CustomerNumberDel_I;
        avvocstnumbersD.avvoAttorneyCustomerNumbers = Attorney_CustomerNumberDel_I;
        
        MergeAccounrJson.NoloCustomerNumbers nolocstnumbersD = new MergeAccounrJson.NoloCustomerNumbers();
        nolocstnumbersD.noloCustomerNumber = MN_CustomerNumberDel_I;
        nolocstnumbersD.noloGidNumber = MN_GroupId_Del_I;
        
        MergeAccounrJson.CurrentSfNumbers previousnumbers = new MergeAccounrJson.CurrentSfNumbers();
        previousnumbers.sfGuid = IB_CustomerNumberDel_I;
        previousnumbers.mhCustomerNumbers = mhcstnumbersD;
        previousnumbers.ngageCustomerNumber = MNG_CustomerNumberDel_I;
        previousnumbers.captorraCustomerNumber = CAP_CustomerNumberDel_I;
        previousnumbers.noloCustomerNumbers = nolocstnumbersD;
        previousnumbers.avvoCustomerNumbers = avvocstnumbersD;
        
        MergeAccounrJson.message msg = new  MergeAccounrJson.message();
        msg.currentSfNumbers = currentnumbers;
        msg.previousSfNumbers = previousNumbers;
        msg.updatedAt = dateTime_merg;
        
        MergeAccounrJson Msgjson = new MergeAccounrJson();
        Msgjson.message = msg ;
        
        String str = JSON.serialize(Msgjson.message);
        String requestbodyX = '{ "message": ' + str + '}';
        //String strrr = JSON.serialize(requestbodyX);
        
        System.debug('TEST-->' + requestbodyX );
        
        //MergeAccounrJson myClass = MergeAccounrJson.parse(requestbodyX);
        //System.debug('XXXXXXXX-->' + myClass );
        List<Group> queueId = [SELECT Id FROM Group WHERE Name = 'Tech Support' AND Type = 'Queue'];
        try{
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http = new Http();
            
            request.setEndpoint(System.Label.Account_Merge_End_Point);
            request.setHeader('Content-Type','application/json'); 
            request.setHeader('Source','Salesforce');
            request.setMethod('POST');
            request.setBody(requestbodyX ); 
            request.setCompressed(false);
            
            response = http.send(request);
            if (response.getStatusCode() == 200) {
                Case csRec = new Case();
                csRec.Status = 'New';
                csRec.Area__c = 'Accounts Receivable';
                csRec.Subject = 'Reparenting and JSON is done successfully';
                csRec.Description = response.getBody();
                csRec.Origin = 'Maintenance';
                csRec.AccountId = masterRecIds;
                csRec.JSON_Request__c = requestbodyX; 
                csRec.OwnerId = queueId[0].Id;
                insert csRec;
                System.debug('Response' + response.getBody());
            } else{
                System.debug('elsecase' + response.getBody());
            } 
        }
        catch(System.CalloutException e){
            Error_Log__c errRec = new Error_Log__c();
            errRec.Order_Name__c = 'Legal Message Bus';
            errRec.Error_Reason__c = 'Callout Fails';
            errRec.Error_Message__c = e.getMessage();
            errRec.Account_Name__c = masterRecIds;
            insert errRec;
            System.debug('Error' + e.getMessage());   
        }
    }
    public static void reparentAcc(Set<Id> masterAccId , Set<Id> deletedAccIds) {
        //To reparent other records related to IB Account
        System.debug('XXXXXXXXXXXX' + masterAccId);
        System.debug('YYYYYYYYYYYY' + deletedAccIds);
        
        Id masterIdss;
        Id firmId;
        List<Account> accUpList = New List<Account>();
        for(Id accM : masterAccId){
            masterIdss = accM;
        }
        for(Account accR : [SELECT Id,ParentId,RecordTypeId,MH_Cust_Number__c FROM Account WHERE ParentId IN : deletedAccIds]){       
            accR.ParentId = masterIdss;
            accUpList.add(accR);
        }
        Update accUpList;
    }
}