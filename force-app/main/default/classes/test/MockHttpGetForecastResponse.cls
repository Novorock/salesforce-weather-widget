global class MockHttpGetForecastResponse implements HttpCalloutMock {
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
        res.setBody('{"cod":"200","message":0,"cnt":1,"list":[{"dt":1700568000,"main":{"temp":271.24,"feels_like":266.02,"temp_min":271.24,"temp_max":271.58,"pressure":1017,"sea_level":1017,"grnd_level":1001,"humidity":51,"temp_kf":-0.34},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04d"}],"clouds":{"all":77},"wind":{"speed":4.72,"deg":72,"gust":6.21},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-11-21 12:00:00"}],"city":{"id":627904,"name":"Hrodna","coord":{"lat":53.6884,"lon":23.8258},"country":"BY","population":317365,"timezone":10800,"sunrise":1700546481,"sunset":1700576392}}');

        return res;
    }
}