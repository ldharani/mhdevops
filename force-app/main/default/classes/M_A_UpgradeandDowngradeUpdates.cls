/** change history 
Class Name: M_A_UpgradeandDowngradeUpdates 
Testclass - 
Jira         ModifiedBy       Date         Requested By     Tag      Description
MHMAC-394       SaiV        09/7/2023       SaiC            T00      Update Professional Contact with Active MAC Product association
MHMAC-395       SaiV        09/7/2023       SaiC            T01      Build a custom logic to update the Origin and Path value during Upgrade & Downgrade
MHMAC-458       SaiV        10/18/2023      Nama            T02      Enh - Dev: Update/remove code in Amendment tab supporting upgrade/downgrades
MHMAC-522       CK          10/18/2023      John            T03      Set start date as next month first for Upgrade/Downgrade scenario
*/
public class M_A_UpgradeandDowngradeUpdates { 
    //updates on the related professional record based on the product and tier value
    //MHMAC-394 Added by saiv 08/24/2023 - T00 T02
    public static void contactUpdatesafterOrderProdCreation(List<OrderItem> newList){
        Set<Id> conIdforQuery = new Set<Id>();
        List<Contact> ordItems = new List<Contact>();
        List<Contact> conListForUpdate = new List<Contact>();
        Map<Id,List<String>> ordItmVsProdCode = new Map<Id,List<String>>();
        Map<Id,List<String>> conIdVsStatus = new Map<Id,List<String>>();
        Map<Id,Map<Id,List<String>>> conIdVsordItmWProdCode = new  Map<Id,Map<Id,List<String>>>();
        system.debug('======newList======'+newList);
        for(OrderItem oi: newList){
            system.debug('======oi1======'+oi);
            if(oi.Productcode__c == '11014' || oi.Productcode__c == '11015' || oi.Productcode__c == '11016'){ 
                conIdforQuery.add(oi.Contact__c);
            }
        }
        system.debug('===conIdforQuery==='+conIdforQuery);
        List<OrderItem> oiLst = [select id, Productcode__c, Contact__c, Quantity, Status__c from OrderItem where Contact__c=:conIdforQuery
                                AND (Productcode__c = '11014' OR Productcode__c = '11015' OR Productcode__c = '11016')];
        
        for(OrderItem oi:oiLst){
            system.debug('===oi=='+oi.Productcode__c+':'+oi.Status__c);
            if(oi.Quantity > 0){
                if(ordItmVsProdCode.containsKey(oi.Contact__c)) {
                    ordItmVsProdCode.get(oi.Contact__c).add(oi.Productcode__c+':'+oi.Status__c);
                }else{
                    ordItmVsProdCode.put(oi.Contact__c, new List<String> {oi.Productcode__c+':'+oi.Status__c});
                }    
            }
            system.debug('====ordItmVsProdCode===='+ordItmVsProdCode);
        }
        for(Contact con:[select id, Active_Product__c, ActiveProductCode__c from Contact where id=:ordItmVsProdCode.keySet()]){
            system.debug('=====con====='+con);
            List<String> activeProducts = new List<String>();
            List<String> activeProductCodes = new List<String>();
            for(String str: ordItmVsProdCode.get(con.Id)){
                system.debug('======str======'+str);
                system.debug('=====containsCancel==='+!str.contains('Cancelled'));
                if(!str.contains('Cancelled') && !str.contains('Downgraded') && !str.contains('Upgraded')){
                    if( str.contains('11014') && !activeProducts.contains('CPP')){
                        activeProducts.add('CPP');
                        activeProductCodes.add('11014');    
                    }
                    if(str.contains('11015') && !activeProducts.contains('MBP')){
                        activeProducts.add('MBP');
                        activeProductCodes.add('11015');
                    }
                    if(str.contains('11016') && !activeProducts.contains('ABP')){
                        activeProducts.add('ABP');
                        activeProductCodes.add('11016');
                    }
                    con.Active_Product__c = String.join(activeProducts, ',');
                    con.ActiveProductCode__c = String.join(activeProductCodes, ',');
                }else if(str.contains('Cancelled')){
                    List<String> activeProdVal = new List<String>();
                    List<String> activeProdCodeVal = new List<String>();
                    if(con.Active_Product__c != null){
                        activeProdVal = con.Active_Product__c.split(',');
                    }
                    if(con.ActiveProductCode__c != null){
                        activeProdCodeVal = con.ActiveProductCode__c.split(',');
                    }
                    system.debug('=====activeProdVal59else====='+activeProdVal);
                    system.debug('=====activeProdCodeVal60else====='+activeProdCodeVal);
                    List<String> updatedProdValues = new List<String>();
                    List<String> updatedProdCodeValues = new List<String>();
                    String removeProdVal = '';
                    String removeProdCodeVal = '';
                    if(str.contains('11014') && !activeProducts.contains('CPP')){
                        removeProdVal = 'CPP';
                        removeProdCodeVal = '11014';    
                    }
                    if(str.contains('11015') && !activeProducts.contains('MBP')){
                        removeProdVal = 'MBP';
                        removeProdCodeVal = '11015';
                    }
                    if(str.contains('11016') && !activeProducts.contains('ABP')){
                        removeProdVal = 'ABP';
                        removeProdCodeVal = '11016';
                    }
                    for (String value : activeProdVal) {
                        if (value != removeProdVal) {
                            updatedProdValues.add(value);
                        }
                    }
                    for (String value : activeProdCodeVal) {
                        if (value != removeProdCodeVal) {
                            updatedProdCodeValues.add(value);
                        }
                    }
                    con.Active_Product__c = String.join(updatedProdValues, ','); 
                    con.ActiveProductCode__c = String.join(updatedProdCodeValues, ',');
                }
                conListForUpdate.add(con);
            }
        }
        system.debug('===conListForUpdate==='+conListForUpdate);
        //MDL_RecursionHandler.contactUpdatesFromOIRecursion = false;
        
        Map<Id, Contact> updatedContMap = new Map<Id, Contact>();
        updatedContMap.putall(conListForUpdate);
        system.debug('===updatedContMap==='+updatedContMap);
        if(updatedContMap.size() > 0){
            update updatedContMap.values();
        }        
    }
    
    //Updates on quote line based on the related professional and existing quote line upgrades or downgrades - T01 T02
    public static void quoteLineUpgradeandDowngradeUpdates(List<SBQQ__QuoteLine__c> quoteLinesLst, Map<Id,SBQQ__QuoteLine__c> oldMap){
        system.debug('====quoteLinesLst125===='+quoteLinesLst);
        List<SBQQ__QuoteLine__c> qlinesToUpdate = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> qlinesLst = new List<SBQQ__QuoteLine__c>();
        Boolean isCancelQLPresent = false;
        Map<Id, List<String>> cancldConIdVsProdCode = new Map<Id, List<String>>();
        Map<Id, List<String>> activeConIdVsProdCode = new Map<Id, List<String>>();
        Date startDateOfNextMonth;//<T03>
        Date currentDate = Date.today();
        Set<Id> relatedConIds = new Set<Id>();
        startDateOfNextMonth = currentDate.toStartOfMonth().addMonths(1);//<T03>
        for(SBQQ__QuoteLine__c qoln: quoteLinesLst){
            if(qoln.contact__c != null &&
               (qoln.SBQQ__ProductCode__c == '11014' || qoln.SBQQ__ProductCode__c == '11015'|| qoln.SBQQ__ProductCode__c == '11016')){
                   relatedConIds.add(qoln.contact__c);
               }
        }
        system.debug('====relatedConIds===='+relatedConIds);
        if(relatedConIds != null){
            qlinesLst = [select id, path__c, origin__c, contact__c, contact__r.Active_Product__c, contact__r.Tier_Value__c,SIN__c,SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__Status__c,Tier_Value__c,Contact__r.ActiveProductCode__c, 
                              Upgrade_Downgrade_Tag__c,Origin_Product_Code__c, SBQQ__ProductCode__c, SBQQ__Quantity__c,SBQQ__StartDate__c 
                         from SBQQ__QuoteLine__c where contact__c IN:relatedConIds AND SBQQ__Quote__r.SBQQ__Status__c != 'Closed Won' AND SBQQ__Quote__r.SBQQ__Status__c !='Closed Lost'];
            for(SBQQ__QuoteLine__c ql: qlinesLst){
                if(ql.SBQQ__Quantity__c < 1){
                    if(cancldConIdVsProdCode.containsKey(ql.Contact__c)) {
                        cancldConIdVsProdCode.get(ql.Contact__c).add(ql.SBQQ__ProductCode__c);
                    }else{
                        cancldConIdVsProdCode.put(ql.Contact__c, new List<String> {ql.SBQQ__ProductCode__c});
                    } 
                }else if(ql.SBQQ__Quantity__c > 0 && ql.SIN__c == Null){
                    if(activeConIdVsProdCode.containsKey(ql.Contact__c)) {
                        activeConIdVsProdCode.get(ql.Contact__c).add(ql.SBQQ__ProductCode__c);
                    }else{
                        activeConIdVsProdCode.put(ql.Contact__c, new List<String> {ql.SBQQ__ProductCode__c});
                    } 
                }
            }
            system.debug('cancldConIdVsProdCode========='+cancldConIdVsProdCode);
            system.debug('activeConIdVsProdCode========='+activeConIdVsProdCode);
            
            for(SBQQ__QuoteLine__c qline: qlinesLst){
                if(activeConIdVsProdCode.get(qline.Contact__c)!= null && cancldConIdVsProdCode.get(qline.Contact__c)!= null){
                    for(String str: activeConIdVsProdCode.get(qline.Contact__c)){
                        system.debug('===167'+qline.Id);
                        if(qline.SBQQ__ProductCode__c == '11014' && str == '11014' && cancldConIdVsProdCode.get(qline.Contact__c)!= null){
                            qline.SBQQ__StartDate__c = startDateOfNextMonth;
                            qline.Path__c = 'Upgrade';
                            system.debug('===171'+qline.Id);
                            if(cancldConIdVsProdCode.get(qline.contact__c).contains('11015') && qline.Contact__r.ActiveProductCode__c == '11015'){
                                qline.Origin_Product_Code__c = qline.Contact__r.ActiveProductCode__c;
                                qline.Origin__c = 'MBP'; 
                            }else if(cancldConIdVsProdCode.get(qline.contact__c).contains('11016') && qline.Contact__r.ActiveProductCode__c == '11016'){
                                qline.Origin_Product_Code__c = qline.Contact__r.ActiveProductCode__c;
                                qline.Origin__c = 'ABP'; 
                            }
                        }
                        if(( (qline.SBQQ__ProductCode__c == '11015' && str == '11015') || (qline.SBQQ__ProductCode__c == '11016' && str == '11016')) && cancldConIdVsProdCode.get(qline.Contact__c)!= null){
                            system.debug('===181'+qline.Id);
                            if(cancldConIdVsProdCode.get(qline.contact__c).contains('11014') && qline.Contact__r.ActiveProductCode__c == '11014'){
                                qline.Origin_Product_Code__c = qline.Contact__r.ActiveProductCode__c;
                                qline.Path__c = 'Downgrade';
                                qline.Origin__c = 'CPP'; 
                                qline.SBQQ__StartDate__c = startDateOfNextMonth;
                            }
                            
                        } 
                        if(!qlinesToUpdate.contains(qline)){
                            qlinesToUpdate.add(qline);    
                        }
                    }
                    for(String str:cancldConIdVsProdCode.get(qline.Contact__c)){
                        system.debug('===195'+qline.Id);
                        if(qline.SBQQ__ProductCode__c == '11014' && str == '11014'){
                            qline.Path__c = 'Downgrade';
                            qline.Origin__c = qline.Contact__r.Active_Product__c;
                            qline.Origin_Product_Code__c = qline.Contact__r.ActiveProductCode__c;
                        }
                        if(( (qline.SBQQ__ProductCode__c == '11015' && str == '11015') || (qline.SBQQ__ProductCode__c == '11016' && str == '11016') )
                              && activeConIdVsProdCode.get(qline.contact__c).contains('11014') ){
                            system.debug('===208'+qline.Id);
                            qline.Path__c = 'Upgrade';
                            qline.Origin__c = qline.Contact__r.Active_Product__c;
                            qline.Origin_Product_Code__c = qline.Contact__r.ActiveProductCode__c;
                            
                        }
                        if(!qlinesToUpdate.contains(qline)){
                            qlinesToUpdate.add(qline);    
                        }
                    }
                }
            }
        }
        MDL_RecursionHandler.qlUpgrdDwngrdUpdates = false;
        system.debug('====qlinesToUpdate==='+qlinesToUpdate);
        if(!qlinesToUpdate.isEmpty()){
            update qlinesToUpdate;
        }
    }
}