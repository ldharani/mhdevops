/*
Apex Class   : updateOrderItemStatusQueueable
Created By   : Serge Kandukuri
Description  : This is Queuable class for Order API
*/
public class updateOrderItemStatusQueueable implements Queueable, Database.AllowsCallouts {
    set<Id> sOIId;
    public updateOrderItemStatusQueueable(set<Id> sOIIdParam){
        sOIId = sOIIdParam;
    }
    
    public void execute(QueueableContext context) {
        List<OrderItem> lstOI = [SELECT Id, Status__c, Order.Account.MH_Cust_Number__c, SIN__c FROM OrderItem WHERE Id IN: sOIId];
        string strAccesstoken = authorization();
        List<OrderItem> lstOIUpdate = new List<OrderItem>();
        OrderItem objOI;
        string strOIStatus;
        for(OrderItem oi: lstOI){
            Http http = new Http(); //global class which is used in both request & response
            HttpRequest req = new HttpRequest(); //initiate HTTP request
            string strEndPoint = system.Label.Order_API_Endpoint + '/api/clients/' + oi.Order.Account.MH_Cust_Number__c + '/campaigns/' + oi.SIN__c + '/status';
            req.setEndpoint(strEndPoint);
            req.setHeader('Authorization', 'Bearer ' + strAccesstoken);
            req.setMethod('PATCH');
            
            strOIStatus = oi.Status__c;
            //if(strOIStatus == Constant.ORDER_STATUS_TRUNCATED){
                // strOIStatus = Constant.ORDER_STATUS_CANCELLED ;
            //}
            
            if(strOIStatus == Constant.ORDER_STATUS_CANCELLED){
                strOIStatus = Constant.ORDER_STATUS_INACTIVE;
            }
            
            String strBody = '';
            strBody = '{"status": "' + strOIStatus + '"}';
            req.setBody(strBody); 
            req.setHeader('Content-Type', 'application/json');
            String strResponse;
            if(Test.isRunningTest() == false){
                HTTPResponse res = http.send(req);
                System.debug('Response Body : '+res.getBody());
                strResponse = res.getBody();
            }
            String strSuccessErrorMsg = '';
            
            objOI = new OrderItem(id=oi.Id);
            objOI.Usage_Integration_Request_body__c = strBody;
            objOI.Usage_Integration_Response_body__c = strResponse;
            objOI.Usage_Integration_Success_Error_Msg__c = strSuccessErrorMsg;
            lstOIUpdate.add(objOI);
        }
        
        if(!lstOIUpdate.isEmpty()){
            update lstOIUpdate;
        }
    }
    
    /*
        Method Name: authorization
        Description: This method is used to authorize API
        Parameter  : None
    */
    Public static string authorization(){
        string strAccesstoken = '';
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(system.Label.Order_API_Endpoint + '/oauth/token');
        request.setHeader('Content-Type', 'application/json');
        
        request.setMethod('POST');
        string strBody = '';
        strBody += '{';
        strBody += '"grant_type": "client_credentials",';
        strBody += '"client_id": 1,';
        strBody += '"client_secret": "' + system.label.Order_API_client_secret + '"';
        strBody += '}';
        request.setBody(strBody);
        string strResponse;
        if(Test.isRunningTest() == false){
            HttpResponse response = http.send(request);
            strResponse = response.getBody();
        }else{
            strResponse = '{"token_type":"Bearer","expires_in":31536000,"access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiYjY0NGE2NTgxZmNiM2ZkZGFlOGI0MzliNWJlMTAyYTNiZjAwNGFhMGUyNTEwYzdlMDdlOWJjMGU4N2JlYzg4NTk5Zjg2ODcwNmZlMTBhNjAiLCJpYXQiOjE2MDk5NTIxMjksIm5iZiI6MTYwOTk1MjEyOSwiZXhwIjoxNjQxNDg4MTI5LCJzdWIiOiIiLCJzY29wZXMiOltdfQ.rD4-B3AHtZKctodWh2r3KIzngg1D88Fk5culO7z-LIhlEvaSo0mK9szMeGFECwJanylDRAeLRaPu52u9cyqZD7r8pPYrMHYaD05VHiQuDuiGbzXrohNw5wOsxHS01zaJRYz8hkO2UvsdMld8njSfqbFWXQuuNHXe3CMGx_BDrt3IOeV6t4sNVzirkV5cSN94ppdSLfJahJSB0at2FbCX7Q1UqWlyW9JjG_6dJ3kYLuRPfgzcns24PAtnToiPPRFPatmTddgzsCcnr8wGGOppeB5uN2se5TM7iAw3czd7FVTq3TTak8CwGbeIVT-iyDT7Y0lZ0kJaXDnvLnAYhJ1ACL0mpASi3QH9S-S7LOR99B3C9YCShg9OITfany8D2oi6iS7mS4FDgFKRlZsDQ3FsxvWe5U5X1c4T9qjJ8eoCl5Fdak6NUgUZxHe8fsXlZ8pzGb0LiHHBh-MqeZOTCNY8r8m_I930sMaapr1YmdaUdszsTeVaLSd6AaFjsdGLuO4L1znI_8aZ934aOMG_y0sO68ptG6WJWA3jndgwef99MyUQTR56HazN3_jqfKJMFlCL7P7coPTPeEhEWNRjztGu9EorgrZ-a-f_3Ki3nKXW3cBwyhNVAfZHt4p39wrgSGRkDWo4q1xFAnZTg3Rhtllqp5yWpyV2dW6mREJuvECnJt4"}';
        }
        
        JSONParser parser = JSON.createParser(strResponse);
        while (parser.nextToken() != null){
            if (parser.getCurrentName() == 'access_token'){                 
                parser.nextToken();
                strAccesstoken = parser.getText();
            }
        }
        
        return strAccesstoken;
    }
}