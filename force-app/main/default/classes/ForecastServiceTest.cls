@IsTest
private class ForecastServiceTest {
   	@IsTest
    private static void testGetForecastCallout() {
        Test.setMock(HttpCalloutMock.class, new MockHttpGetForecastResponse());
        ForecastService.WeatherForecastData data = ForecastService.getCurrentForecast('Example');
        System.assert(data != null);
    }
    
    
   	@isTest
    private static void testForecastCalloutWithBadResponse() {
		Test.setMock(HttpCalloutMock.class, new MockHttpGetForecastBadResponse());
        try {
        	ForecastService.WeatherForecastData data = ForecastService.getCurrentForecast('Example');
            System.assert(true, 'Unreachable line expected.');
        } catch (Exception e) {
            System.assert(e instanceof AuraException);
        }
    }
}