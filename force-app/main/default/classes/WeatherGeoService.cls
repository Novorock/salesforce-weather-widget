global with sharing class WeatherGeoService {
    @AuraEnabled
    public static Default_City__mdt getDefaultLocation() {
        return [
            SELECT Location__c, Country__c
            FROM Default_City__mdt
            WHERE Label='Default'
            LIMIT 1
        ];
    }

    @AuraEnabled
    public static List<GeoData> getGeoData(String location) {
        HttpRequest request = new HttpRequest();
        Service_Credential__mdt credential = [
            SELECT Endpoint__c, API_key__c
            FROM Service_Credential__mdt
            WHERE Label='geo'
        ];

        String apiKey = credential.API_key__c;
        String endpoint = credential.Endpoint__c +
        '?q=' + location
        + '&limit=2'
        + '&APPID=' + apiKey;
        request.setEndpoint(endpoint);
        request.setMethod('GET');

        Http http = new Http();
        HttpResponse response = http.send(request);
        Integer code = response.getStatusCode(); 

        if (200 <= code && code < 300) {
            try {
                return (List<GeoData>) JSON.deserialize(response.getBody(), List<GeoData>.class);
            } catch (Exception e) {
                AuraException ex = new AuraException();
                ex.setMessage('Unable to deserialize the data via: "'  + endpoint + '". The problem is caused by: ' + e.getMessage());
                throw ex;
            }
        } else {
            AuraException e = new AuraException();
            e.setMessage(response.getStatus());
            throw e;
        }
    }

    global class GeoData {
        @AuraEnabled
        global String name;
        global Double lat;
        global Double lon;
        @AuraEnabled
        global String country;
    }
}