global class WeatherService {
    @AuraEnabled
    public static WeatherData getCurrentWeather(String location) {
        HttpRequest request = new HttpRequest();
        scww__Service_Credential__mdt credential = [
            SELECT Endpoint__c, API_key__c
            FROM scww__Service_Credential__mdt
            WHERE Label='weather'
            LIMIT 1
        ];

        String apiKey = credential.API_key__c;
        String endpoint = credential.Endpoint__c +
        '?q=' + location
        + '&APPID=' + apiKey;
        request.setEndpoint(endpoint);
        request.setMethod('GET');

        Http http = new Http();
        HttpResponse response = http.send(request);
        Integer code = response.getStatusCode(); 
        if (200 <= code && code < 300) {
            Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            
            try {
                return deserializeWeatherJSON(body);
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
    
    public static WeatherData deserializeWeatherJSON(Map<String, Object> body) {
        WeatherData data = new WeatherData();

        List<Object> t = (List<Object>) body.get('weather');
        Map<String, Object> weather = (Map<String, Object>) t.get(0);

        data.timestamp = (Long) body.get('dt');
        data.description = ((String) weather.get('description')).capitalize();
        data.iconUrl = 'https://openweathermap.org/img/wn/' + ((String) weather.get('icon')) + '@4x.png';

        Map<String, Object> main = (Map<String, Object>) body.get('main');
        
        data.temperature = (Integer) Math.roundToLong(((Double) main.get('temp')) - 273.15);
        
        Map<String, Object> wind = (Map<String, Object>) body.get('wind');
        data.wind = (Decimal) wind.get('speed');
        
        return data;
    }
    
    global class WeatherData {
        @AuraEnabled
        global Long timestamp;
        @AuraEnabled
        global Integer temperature;
        @AuraEnabled
        global Decimal wind;
        @AuraEnabled
        global String description;
        @AuraEnabled
        global String iconUrl;
    }
}