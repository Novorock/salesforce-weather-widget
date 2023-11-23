global class ForecastService {
    @AuraEnabled
    public static WeatherForecastData getCurrentForecast(String location) {
        HttpRequest request = new HttpRequest();
        scww__Service_Credential__mdt credential = [
            SELECT Endpoint__c, API_key__c
            FROM scww__Service_Credential__mdt
            WHERE Label='forecast'
            LIMIT 1
        ];

        String apiKey = credential.API_key__c;
        String endpoint = credential.Endpoint__c +
        '?q=' + location
        + '&cnt=8'
        + '&APPID=' + apiKey;
        request.setEndpoint(endpoint);
        request.setMethod('GET');

        Http http = new Http();
        HttpResponse response = http.send(request);
        Integer code = response.getStatusCode(); 
        if (200 <= code && code < 300) {            
            try {
				WeatherForecastData forecast = new WeatherForecastData();
            	forecast.forecast = new List<WeatherService.WeatherData>();
            	Map<String, Object> t = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            	List<Object> li = (List<Object>) t.get('list');
                
                for (Object body : li) {
                    forecast.forecast.add(WeatherService.deserializeWeatherJSON((Map<String, Object>) body));
                }

                return forecast;
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
    
    global class WeatherForecastData {
        @AuraEnabled
        global List<WeatherService.WeatherData> forecast;
    }
}