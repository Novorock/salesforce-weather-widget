global class MockHttpGetWeatherResponse implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        Service_Credential__mdt credential = [
            SELECT Endpoint__c, API_key__c
            FROM Service_Credential__mdt
            WHERE Label='weather'
        ];

        if (credential == null) {
            System.assert(true, 'No specified metadata with endpoint to http callout.');
        }

        System.assertEquals('GET', req.getMethod());

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody('{"coord":{"lon":23.7,"lat":52.1},"weather":[{"main":"Snow","description":"light snow","icon":"13d"}],"main":{"temp":271.68},"wind":{"speed":5.27},"dt":1700557620}');

        return res;
    }
}