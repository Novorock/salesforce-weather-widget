public class PermissionService {
	@AuraEnabled(cacheable=true)
    public static Boolean hasCustomPermission() {
        Map<Id, CustomPermission> customPermissions = new Map<Id, CustomPermission>([
        	SELECT Id FROM CustomPermission
            WHERE NamespacePrefix='scww'
            AND DeveloperName='Weather_Widget_Access'
        ]);
        
        if (customPermissions.size() < 1)
            return false;
        
        List<SetupEntityAccess> setupEntities = [
            SELECT SetupEntityId
            FROM SetupEntityAccess
            WHERE SetupEntityId in :customPermissions.keySet()
            AND ParentId IN (SELECT PermissionSetId FROM PermissionSetAssignment
                             WHERE AssigneeId = :UserInfo.getUserId()
                            )
        ];
        
 		return setupEntities.size() > 0;
    }
}