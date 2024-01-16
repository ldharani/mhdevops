global class AmendQueueable implements Queueable,Database.AllowsCallouts{
    public Id Contractid ; 
    public AmendQueueable (string Contid){
        this.Contractid = Contid;  
    }
    
    public void execute(Queueablecontext context){
    
        Contract con = [Select Id from Contract where Id =: Contractid ];
        String qmodelJson = SBQQ.ServiceRouter.load('SBQQ.ContractManipulationAPI.ContractAmender', con.Id, null);
    }
}