global class MockHttpResponse implements HttpCalloutMock {
    private Integer statusCode;

    public MockHttpResponse(Integer statusCode){
        this.statusCode = statusCode;
    }

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"foo":"bar"}');
        res.setStatusCode(this.statusCode);
        return res;
    }
}