public with sharing class ControllerForScheduling {

    public invoiceit_s__Invoice_RunScheduler__c invoiceRunScheduler {get; set;}
    public Boolean isEditMode {get; set;} 
    public string str {get; set;} 
    public ControllerForScheduling(ApexPages.StandardController stdController) {
        this.invoiceRunScheduler = (invoiceit_s__Invoice_RunScheduler__c)stdController.getRecord();

        if(invoiceRunScheduler.Id != null) {
            invoiceRunScheduler = CommonUtilClass.getinvoiceRunScheduler(invoiceRunScheduler.Id);   
            isEditMode = true;
        }
        else {
            invoiceRunScheduler.invoiceit_s__Type__c = 'Once'; 
        }
    }

    public PageReference onChangeOfType() {
        if(invoiceRunScheduler.invoiceit_s__Type__c == 'Daily') {
            invoiceRunScheduler.invoiceit_s__Start_date_and_time__c = system.Now();
            invoiceRunScheduler.invoiceit_s__Invoice_Date__c = invoiceRunScheduler.invoiceit_s__Start_date_and_time__c.Date();
            invoiceRunScheduler.invoiceit_s__Target_Date__c = invoiceRunScheduler.invoiceit_s__Invoice_Date__c;
            Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO,System.Label.invoiceit_s.DailyDateMessage);
            Apexpages.addMessage(infoMessage);
        }
        return null;
    }

    public void onChangeStartDate() {
        if(invoiceRunScheduler.invoiceit_s__Type__c == 'Daily') {
            invoiceRunScheduler.invoiceit_s__Invoice_Date__c = invoiceRunScheduler.invoiceit_s__Start_date_and_time__c.Date();
            invoiceRunScheduler.invoiceit_s__Target_Date__c = invoiceRunScheduler.invoiceit_s__Start_date_and_time__c.Date();
        }
    }

    public PageReference saveInvoiceRunScheduler() {
        SavePoint sp;
        boolean isValidations = validations();
        if(!isValidations) {
            try {            
                sp = DataBase.setSavePoint();
                
                if(isEditMode == true) {
                    System.abortJob(invoiceRunScheduler.invoiceit_s__JobId__c);
                }

                String cronExpr = null;
                String jobId  = null;           
                Date startDate =  invoiceRunScheduler.invoiceit_s__Start_date_and_time__c.Date();
                Integer hours =  invoiceRunScheduler.invoiceit_s__Start_date_and_time__c.Hour();
                Integer minutes = invoiceRunScheduler.invoiceit_s__Start_date_and_time__c.Minute();            
                String schedulerType  = invoiceRunScheduler.invoiceit_s__Type__c;
                Integer seconds = 0;
                Integer dayOfMonth = startDate.day();
                Integer month =  startDate.month(); 
                Integer year =  startDate.year();
                Date weekStart = startDate.toStartofWeek();
                Integer dayOfWeek = weekStart.daysBetween(startDate);
                String space = ' ';
                String questionMark = '?';
                String repeat  = '*';
                String comma = ',';
                dayOfWeek = dayOfWeek + 2;
                if('Once' == schedulerType)
                {
                    cronExpr = seconds+ space  + minutes+ space + hours + space +dayOfMonth+ space +month +space+ questionMark + space+  year;              
                }  
                else if('Weekly' == schedulerType)
                {
                    cronExpr = seconds+ space  + minutes+ space + hours + space + questionMark + space + repeat +space+ dayOfWeek + space+  repeat;
                }
                else if('Monthly' == schedulerType)
                {
                    cronExpr = seconds+ space  + minutes+ space + hours + space +dayOfMonth+ space +month + comma + repeat +space+  questionMark + space+  year + comma + repeat;
                }
                else if('Daily' == schedulerType)
                {
                    cronExpr = seconds+ space  + minutes+ space + hours + space +dayOfMonth+ comma +repeat + space + repeat +space+ questionMark  + space+  repeat;
                }
                
                jobId = System.schedule(invoiceRunScheduler.name ,cronExpr,new RunSchedulerInvoiceIT());
               
                invoiceRunScheduler.invoiceit_s__JobId__c = jobId;
                upsert invoiceRunScheduler;
            }
            catch(system.AsyncException asyncException) {
                Database.rollback(sp);
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.INFO,asyncException.getMessage());
                Apexpages.addMessage(errorMessage);  
                return null;
            }
            catch(system.DmlException dmlException) {
                Database.rollback(sp);
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dmlException.getMessage());
                Apexpages.addMessage(errorMessage);  
                return null;
            }
            catch(system.Exception ex) {
                Database.rollback(sp);
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,ex.getMessage());
                Apexpages.addMessage(errorMessage);  
                return null;
            }
            return new PageReference('/' + invoiceRunScheduler.Id);
        }
        else {
            return null;
        }
    }

    public boolean validations() {
        
        if(invoiceRunScheduler.invoiceit_s__Start_date_and_time__c == null) {
            invoiceRunScheduler.invoiceit_s__Start_date_and_time__c.addError(system.Label.invoiceit_s.Thisfieldisrequired);  
            return true;    
        } else if(invoiceRunScheduler.Name == null) {
            invoiceRunScheduler.Name.addError(system.Label.invoiceit_s.Thisfieldisrequired);    
            return true;
        } else if(invoiceRunScheduler.invoiceit_s__Invoice_Currency__c == null) {
            invoiceRunScheduler.invoiceit_s__Invoice_Currency__c.addError(system.Label.invoiceit_s.Thisfieldisrequired); 
            return true;
        } else if(invoiceRunScheduler.invoiceit_s__Type__c == 'Weekly') {
            if(invoiceRunScheduler.invoiceit_s__Invoice_Day_of_week__c == null) { 
                invoiceRunScheduler.invoiceit_s__Invoice_Day_of_week__c.addError(system.Label.invoiceit_s.Thisfieldisrequired);
                return true;
            } else if(invoiceRunScheduler.invoiceit_s__Target_Day_of_week__c == null) {
                invoiceRunScheduler.invoiceit_s__Target_Day_of_week__c.addError(system.Label.invoiceit_s.Thisfieldisrequired);
                return true;
            }

        } else if(invoiceRunScheduler.invoiceit_s__Type__c == 'Monthly') {
            invoiceRunScheduler.invoiceit_s__Invoice_Day_Of_Month__c = '1';
            if(invoiceRunScheduler.invoiceit_s__Invoice_Day_Of_Month__c == null) { 
                invoiceRunScheduler.invoiceit_s__Invoice_Day_Of_Month__c.addError(system.Label.invoiceit_s.Thisfieldisrequired);
                return true;
            } else if(invoiceRunScheduler.invoiceit_s__Target_Day_Of_Month__c == null) {
                invoiceRunScheduler.invoiceit_s__Target_Day_Of_Month__c.addError(system.Label.invoiceit_s.Thisfieldisrequired);
                return true;
            }
        } else if(invoiceRunScheduler.invoiceit_s__Start_date_and_time__c <= system.Now()) {
            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.invoiceit_s.Startdatehaspassed);
            Apexpages.addMessage(errorMessage);
            return true;
        }
        
        if(invoiceRunScheduler.invoiceit_s__Start_date_and_time__c != null && invoiceRunScheduler.invoiceit_s__Type__c == 'Daily' && invoiceRunScheduler.invoiceit_s__Start_date_and_time__c > system.now() + 1) {
            invoiceRunScheduler.invoiceit_s__Start_date_and_time__c.addError('DailySchedulerError');  
            return true;    
        }
        
        return false;
    }
    

}