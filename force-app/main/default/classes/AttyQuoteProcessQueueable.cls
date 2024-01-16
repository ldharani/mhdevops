/***************
 * Class Name: AttyQuoteProcessQueueable
 * Test Class: BatchToCreateAttyQuoteProcess_Test
 * Description: MHMAC-14 : [Discovery] : Automating Quote/Quote line creation from Avvo subscription lines
 * Developed By: Jeyamugundan
 * Modification History : Created on Jan 13,2023* 
 * ******/
public class AttyQuoteProcessQueueable implements Queueable,Database.AllowsCallouts { 
    public List<SBQQ__Quote__c> quo = new List<SBQQ__Quote__c>();
    Public AttyQuoteProcessQueueable(List<SBQQ__Quote__c> quo){
        system.debug('ssssssssssssq' + quo);
        This.quo = quo;
    }
    public void execute(QueueableContext context) {
        //system.debug('gggsjgjgsjgsjgs' + quo[0].Id);
        //System.debug('QQQQQQQQQQQVSSAAA');
        List<String> QuoList = new List<String>();
        for(SBQQ__Quote__c QQQ : quo){ 
            System.debug('hjghjghjgj ' +QQQ.ID );
            QuoList.add(QQQ.ID+',1,');
        }
        if(!QuoList.isEmpty()){
            //System.debug('hjghssssssssjghjgj ' +QuoList);
            quoteHandler.reCalculateQuoteFuture(QuoList);
        }
    }
}