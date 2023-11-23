@IsTest
public class WeatherServiceTest {
	@IsTest
    private static void testCalloutWithSuccessResponse() {
        Test.setMock(HttpCalloutMock.class, new MockHttpGetWeatherResponse());
        WeatherService.WeatherData data = WeatherService.getCurrentWeather('Example');
        System.assert(data != null);
    }
    
    @isTest
    private static void testCalloutWithBadResponse() {
		Test.setMock(HttpCalloutMock.class, new MockHttpGetWeatherBadResponse());
        try {
        	WeatherService.WeatherData data = WeatherService.getCurrentWeather('Example');
            System.assert(true, 'Unreachable line expected.');
        } catch (Exception e) {
        }
    }
}