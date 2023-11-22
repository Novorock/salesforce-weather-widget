@IsTest
private class WeatherWidgetServiceTest {
	@IsTest
    private static void testGetWeatherCallout() {
        Test.setMock(HttpCalloutMock.class, new MockHttpGetWeatherResponse());
        WeatherWidgetService.WeatherData data = WeatherWidgetService.getCurrentWeather('Example');
        System.assert(data != null);
    }
    
    @isTest
    private static void testWeatherCalloutWithBadResponse() {
		Test.setMock(HttpCalloutMock.class, new MockHttpGetWeatherBadResponse());
        try {
        	WeatherWidgetService.WeatherData data = WeatherWidgetService.getCurrentWeather('Example');
            System.assert(true, 'Unreachable line expected.');
        } catch (Exception e) {
        }
    }
    
   	@IsTest
    private static void testGetForecastCallout() {
        Test.setMock(HttpCalloutMock.class, new MockHttpGetForecastResponse());
        WeatherWidgetService.WeatherForecastData data = WeatherWidgetService.getCurrentForecast('Example');
        System.assert(data != null);
    }
    
    
   	@isTest
    private static void testForecastCalloutWithBadResponse() {
		Test.setMock(HttpCalloutMock.class, new MockHttpGetForecastBadResponse());
        try {
        	WeatherWidgetService.WeatherForecastData data = WeatherWidgetService.getCurrentForecast('Example');
            System.assert(true, 'Unreachable line expected.');
        } catch (Exception e) {
            System.assert(e instanceof AuraException);
        }
    }
}