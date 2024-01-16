@isTest
global class Test_MockSendToBananaStand implements HttpCalloutMock {

    boolean returnError;
    string statusString = '';
    string responseBody = '';
    public boolean returnException;
    public string exceptionMessage;

    global Test_MockSendToBananaStand() {
        this.returnError = false;
    }

    global Test_MockSendToBananaStand(string responseBody) {
        this.returnError = false;
        this.responseBody = responseBody;
    }

    global Test_MockSendToBananaStand(boolean returnError, string errorString) {
        this.returnError = returnError;
        this.statusString = errorString;
    }

    global Test_MockSendToBananaStand(boolean returnError, string errorString, string responseBody){
        this.returnError = returnError;
        this.statusString = errorString;
        this.responseBody = responseBody;
    }

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();

        if (returnException == true) {
            throw new Test_MockSendToBananaStandException(exceptionMessage);
        }

        if (returnError == false) {
            res.setStatusCode(200);
            res.setBody(responseBody);
            res.setStatus(statusString);
        }
        else {
            res.setStatusCode(400);
            res.setStatus(statusString);
            res.setBody(responseBody);
        }

        return res;
    }

    global static Test_MockSendToBananaStand ErrorMessageSend(string errorMessage) {
        Test_MockSendToBananaStand mock = new Test_MockSendToBananaStand();

        mock.returnException = true;
        mock.exceptionMessage = errorMessage;

        return mock;
    }

    private class Test_MockSendToBananaStandException Extends Exception {
    }
}