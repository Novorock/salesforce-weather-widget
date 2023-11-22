global with sharing class WeatherGeoService {
    @AuraEnabled
    public static Location getDefaultLocation() {
        Location loc = new Location();
        Id id = UserInfo.getUserId();
        User u = [SELECT City, Country FROM User WHERE Id=:id LIMIT 1];
        
        if (String.isNotBlank(u.City) && String.isNotBlank(u.Country)) {
            loc.City = u.City;
            loc.Country = u.Country;
            
            return loc;
        }

        Default_City_Setting__mdt mdt = [
            SELECT Location__c, Country__c
            FROM Default_City_Setting__mdt
            WHERE Label='Default'
            LIMIT 1
        ];

        loc.City = mdt.Location__c;
        loc.Country = mdt.Country__c;

        return loc;
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

    global class Location {
        @AuraEnabled
        global String City;
        @AuraEnabled
        global String Country;
    }
}