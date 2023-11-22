global class MockHttpWeatherGeoBadResponse implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        Service_Credential__mdt credential = [
            SELECT Endpoint__c, API_key__c
            FROM Service_Credential__mdt
            WHERE Label='geo'
        ];

        if (credential == null) {
            System.assert(true, 'No specified metadata with endpoint to http callout.');
        }

        System.assertEquals('GET', req.getMethod());

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody('[{"bad body"}]');

        return res;
    }
}