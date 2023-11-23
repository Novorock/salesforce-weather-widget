@IsTest
private class PermissionServiceTest {
	@isTest
    private static void testHasPermission() {
    	PermissionSet permissionSet = new PermissionSet();
    	permissionSet.Name = 'Test';
    	permissionSet.Label = 'Test';
    	insert permissionSet;
        
        List<CustomPermission> customPermission = [
            SELECT Id FROM CustomPermission
            WHERE DeveloperName='Weather_Widget_Access'
        ];
        
        if (customPermission.size() > 0) {
           	SetupEntityAccess sea = new SetupEntityAccess();
    		sea.ParentId = permissionSet.Id;
    		sea.SetupEntityId = customPermission.get(0).Id;
    		insert sea;
        
    		PermissionSetAssignment psa = new PermissionSetAssignment();
    		psa.AssigneeId = UserInfo.getUserId();
    		psa.PermissionSetId = permissionSet.Id;
    		insert psa;
 
    		System.assertEquals(true, PermissionService.hasCustomPermission());    
        }
    }
}