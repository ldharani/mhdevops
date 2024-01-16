public class populateProjectOnOrderChargeAttribute{
    @InvocableMethod
    public static void projectUpdateFromProcess(List<Id> orderChargeIds){
      Map<Id,List<Milestone1_Project__c>> projectOrderChargeMap = new Map<Id,List<Milestone1_Project__c>>(); //opptyId, project
      List<Opportunity_Charge_Attribute__c > ocaUpdateList = new List<Opportunity_Charge_Attribute__c >();
      List<Opportunity_Charge_Attribute__c > ocaList = new List<Opportunity_Charge_Attribute__c >();
      //Set<Id> opptyIds = new Set<Id>();
      
      for(Milestone1_Project__c project: [select id,Order_Rate_Plan_Charge__c,Order_Rate_Plan_Charge__r.Name,Order__c,
                                              Order__r.invoiceit_crmx__Opportunity__c,
                                             //added by sai c
                                              (select id,Project__c,Opportunity_Rate_Plan_Charge__c,
                                                     Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c
                                                    From Opportunity_Charge_Attributes__r)
                                               from Milestone1_Project__c 
                                               where Order__c IN: orderChargeIds]){
          system.debug('@@@project.Order_Rate_Plan_Charge__c here:::'+project.Order_Rate_Plan_Charge__c);
             system.debug(' @@@@Order__r.invoiceit_crmx__Opportunity__c here:::'+project.Order__r.invoiceit_crmx__Opportunity__c);                                       
          if(project.Order_Rate_Plan_Charge__c != null){
              if(projectOrderChargeMap.containsKey(project.Order__r.invoiceit_crmx__Opportunity__c)){
                  List<Milestone1_Project__c> tempProject =  projectOrderChargeMap.get(project.Order__r.invoiceit_crmx__Opportunity__c);
                  tempProject.add(project);
                  projectOrderChargeMap.put(project.Order__r.invoiceit_crmx__Opportunity__c,tempProject);
              }else{
                  List<Milestone1_Project__c> tempProject = new List<Milestone1_Project__c>();
                  tempProject.add(project);
                  projectOrderChargeMap.put(project.Order__r.invoiceit_crmx__Opportunity__c,tempProject);
              }
              
              system.debug('@@@@@project.Opportunity_Charge_Attributes__r'+project.Opportunity_Charge_Attributes__r);
              //added by sai c
              if(project.Opportunity_Charge_Attributes__r.size() >0){
                  for(Opportunity_Charge_Attribute__c oca : project.Opportunity_Charge_Attributes__r){
                      if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c != project.Order__r.invoiceit_crmx__Opportunity__c){
                           oca.Project__c  = NULL;
                           ocaUpdateList.add(oca);
                      }
                     
                  }
              } 
              
             
              
              
              //opptyIds.add(project.Order__r.invoiceit_crmx__Opportunity__c);
          }
      }
      system.debug('projectOrderChargeMap'+projectOrderChargeMap);
                
       if(Test.isRunningTest()){
       ocaList = [select id, Project__c, OpportunityId__c,
                          Attribute_Name__c,Opportunity_Rate_Plan_Charge__c,
                            Opportunity_Rate_Plan_Charge__r.Name 
                          from Opportunity_Charge_Attribute__c 
                    where OpportunityId__c IN: projectOrderChargeMap.keyset() Limit 1];
       system.debug('@@@@@test'+ocaList);
       }
       else {
           ocaList = [select id, Project__c, OpportunityId__c,
                          Attribute_Name__c,Opportunity_Rate_Plan_Charge__c,
                            Opportunity_Rate_Plan_Charge__r.Name 
                          from Opportunity_Charge_Attribute__c 
                    where OpportunityId__c IN: projectOrderChargeMap.keyset() ];
          system.debug('@@@@@ocaList'+ocaList); 
       }
              
      
      Set<Id> checkIdsSet = new Set<Id>();
      for(Opportunity_Charge_Attribute__c opptyCharge : ocaList){
          System.debug('@@@@@@@@@opptyCharge.Attribute_Name__c--------------->>>'+opptyCharge.Attribute_Name__c);
          if((opptyCharge.Attribute_Name__c.contains('AOP/Geo') || opptyCharge.Attribute_Name__c.contains('MH PPC Landing Page'))  && projectOrderChargeMap.containsKey(opptyCharge.OpportunityId__c)){
              for(Milestone1_Project__c proj : projectOrderChargeMap.get(opptyCharge.OpportunityId__c)){
                  if(opptyCharge.Opportunity_Rate_Plan_Charge__r.Name == proj.Order_Rate_Plan_Charge__r.Name){
                      opptyCharge.Project__c = proj.id;
                      
                      if(!checkIdsSet.contains(opptyCharge.id)){
                          ocaUpdateList.add(opptyCharge );
                          checkIdsSet.add(opptyCharge.id);
                      }
                  }
              }
              
          }
      }
      system.debug('ocaUpdateList'+ocaUpdateList);
      
      if(!ocaUpdateList.isEmpty())
      update ocaUpdateList;

      //converting list to map here
      //Map<id,Opportunity_Charge_Attribute__c> idVsattribute = new Map<id,Opportunity_Charge_Attribute__c>(ocaUpdateList);
      //if(!idVsattribute.isEmpty())
     // update idVsattribute.values();
     
    }
}