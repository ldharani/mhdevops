/*
Apex Class   : OrderItemMockImpl
Created By   : Serge Kandukuri
Description  : This is Mock Generation Http Class
*/
global class OrderItemMockImpl implements  HttpCalloutMock{
    
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();

       
            res.setStatusCode(200);
      return res;
    }
}