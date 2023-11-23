@IsTest
public class GeoServiceTest {
    @isTest
    private static void testCallout() {
        Test.setMock(HttpCalloutMock.class, new MockHttpWeatherGeoResponse());
        List<GeoService.GeoData> data = GeoService.getGeoData('Example');
        System.assert(String.isNotBlank(data.get(0).name));
        System.assert(String.isNotBlank(data.get(0).country));
    }
    
    @isTest
    private static void testCalloutWithBadResponse() {
		Test.setMock(HttpCalloutMock.class, new MockHttpWeatherGeoBadResponse());
        try {
        	List<GeoService.GeoData> data = GeoService.getGeoData('Example');
            System.assert(true, 'Unreachable line expected.');
        } catch (Exception e) {
            System.assert(e instanceof AuraException);
        }
    }
    
    @isTest
    private static void testGetDefaultLocation() {
       	Id id = UserInfo.getUserId();
        User u = [SELECT City, Country FROM User WHERE Id=:id LIMIT 1];
        
        System.runAs(u) {
			GeoService.Location loc = GeoService.getDefaultLocation();        
        	System.assertEquals(loc.City, u.City);
			System.assertEquals(loc.Country, u.Country);
        }
        
		u.City = '';
        u.Country = 'BY';
        update u;
       	System.runAs(u) {
        	Default_City_Setting__mdt mdt = [
            	SELECT Location__c, Country__c
            	FROM Default_City_Setting__mdt
            	WHERE Label='Default'
            	LIMIT 1
        	];
       
        	GeoService.Location loc = GeoService.getDefaultLocation();
			System.assertEquals(mdt.Location__c, loc.City);
        	System.assertEquals(mdt.Country__c, loc.Country);    
        }
    }
}