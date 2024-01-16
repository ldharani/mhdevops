/*****
Class Name: AvalaraAddressQueueable 
Created by: SS
* @testclass - AvalaraAddressQueueableTest

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-8377    SS            10/1/2023    John Mattheson  <T03>   Call Avalara Address Validation for leads created through MH prospect list
************************************************************************************************************************/
public class AvalaraAddressQueueable implements Queueable, Database.AllowsCallouts {
    private List<String> leadsString;

    public AvalaraAddressQueueable(List<String> leads) {
        this.leadsString = leads;
    }

    public void execute(QueueableContext context) {
        System.debug('validateLeadAddressAndUpdateInvalidAddress');
        AvalaraAddressValidationAPI.validateLeadAddressAndUpdateInvalidAddress(leadsString);
    }

}