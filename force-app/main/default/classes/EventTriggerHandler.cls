public class EventTriggerHandler {

public static void firstEventCreatedonLead(List<Event>eventList){
        
        Set<String> leadIds = new Set<String>();
        Map<Id,Lead> idVsLead = new Map<Id,Lead>();
        List<lead> leadstoUpdate = new List<lead>();
        for(Event singleevent : eventList){
            
            if(singleevent.WhoId != NULL ){
                string whoIdtemp = string.valueOf(singleevent.WhoId);
                if(whoIdtemp.startsWith('00Q')){
                    leadIds.add(whoIdtemp);
                }
            }
        }
        
        if(!leadIds.isEmpty()){
            idVsLead = new Map<Id,Lead>([select id, Name , OwnerId,First_Activity_Created__c from Lead
                                                      where Id IN:leadIds AND First_Activity_Created__c= FALSE]);
            if(!idVsLead.isEmpty()){
                for(Event singleevent : eventList){
                    if(idVsLead.containsKey(singleevent.WhoId)){
                          lead l = idVsLead.get(singleevent.WhoId);
                        if(singleevent.CreatedById == l.OwnerId){
                           
                            l.First_Activity_Created__c = true;
                            leadstoUpdate.add(l);
                        }
                       
                    }
                }
            }
        }
        
        if(!leadstoUpdate.isEmpty()){
            update leadstoUpdate;
        }
        
        
        
      }  
      //MHBS-5456-prevent the user who is not task owner from editing the task record
     
    public static void restrictRecordEdit(List<Event> EventsList,map<id,Event>mapofoldEvents){
     
     List<String> ProfileNameList = new list<string>{'MN Ad Services','Nolo Acct Mgrs','MN Sales Reps','CPQ MH Sales Rep','MH Avvo Sales Rep','Ngage Sales'};
     List<string> ProfileIds = new list<string>();
     for(Profile objProf: [select Id from profile where Name in: ProfileNameList]){
         ProfileIds.add(objProf.Id);
     }
     for(Event objEvt: EventsList){
          if(mapofoldEvents!=null){
          if((objEvt.OwnerId!= mapofoldEvents.get(objEvt.id).ownerid && ProfileIds.contains(UserInfo.getProfileId()))||(objEvt.OwnerId!=UserInfo.getUserId() && (ProfileIds.contains(UserInfo.getProfileId())))){
              system.debug('error edit');
             objEvt.adderror('You do not have permissions to edit/delete this record.');
          }
         
          }
         else{
          if(objEvt.OwnerId!=UserInfo.getUserId() && (ProfileIds.contains(UserInfo.getProfileId()))){
             objEvt.adderror('You do not have permissions to edit/delete this record.');
          }
          }
      }
    
    }
    }