global class MockHttpGetForecastBadResponse implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        Service_Credential__mdt credential = [
            SELECT Endpoint__c, API_key__c
            FROM Service_Credential__mdt
            WHERE Label='forecast'
        ];

        if (credential == null) {
            System.assert(true, 'No specified metadata with endpoint to http callout.');
        }

        System.assertEquals('GET', req.getMethod());

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody('123');

        return res;
    }
}