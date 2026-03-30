/**
 * @description Object-level and field-level access helpers for queue expert validation flows.
 */
public with sharing class QueueExpertAccessFieldSupport {
    /**
     * @description Verifies object-level CRUD access for the supplied sObject type.
     * @param sObjectType Target sObject type to validate.
     * @param accessType Access type to enforce.
     * @param errorMessage Error message to throw when access is denied.
     */
    public static void checkObjectAccess(Schema.SObjectType sObjectType, String accessType, String errorMessage) {
        if (!hasObjectAccess(sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED), accessType)) {
            throw new AuraHandledException(errorMessage);
        }
    }

    /**
     * @description Verifies field-level access using the supplied request definition.
     * @param request Field-access request wrapper to evaluate.
     */
    public static void checkFieldAccess(QueueExpertAccessSupport.FieldAccessRequest request) {
        Map<String, Schema.SObjectField> fieldMap = request.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).fields.getMap();
        for (String fieldApiName : request.fieldApiNames) {
            Schema.DescribeFieldResult fieldDescribe = getRequestedFieldDescribe(fieldMap, fieldApiName);
            if (!hasFieldAccess(fieldDescribe, request.accessType)) {
                throw new AuraHandledException(request.errorMessage);
            }
        }
    }

    /**
     * @description Returns whether the supplied object describe permits the requested access type.
     * @param describeResult Describe result for the target object.
     * @param accessType Access type to evaluate.
     * @return `true` when the requested access is allowed.
     */
    private static Boolean hasObjectAccess(Schema.DescribeSObjectResult describeResult, String accessType) {
        if (accessType == QueueExpertAccessSupport.ACCESS_READ) {
            return describeResult.isAccessible();
        }
        if (accessType == QueueExpertAccessSupport.ACCESS_CREATE) {
            return describeResult.isCreateable();
        }
        return describeResult.isUpdateable();
    }

    /**
     * @description Returns the describe metadata for a requested field API name.
     * @param fieldMap Field map for the target sObject type.
     * @param fieldApiName Requested field API name.
     * @return Describe result for the requested field.
     */
    private static Schema.DescribeFieldResult getRequestedFieldDescribe(
        Map<String, Schema.SObjectField> fieldMap,
        String fieldApiName
    ) {
        if (!fieldMap.containsKey(fieldApiName)) {
            throw new AuraHandledException('Unsupported field requested: ' + fieldApiName);
        }
        return fieldMap.get(fieldApiName).getDescribe();
    }

    /**
     * @description Returns whether the supplied field describe permits the requested access type.
     * @param fieldDescribe Describe result for the target field.
     * @param accessType Access type to evaluate.
     * @return `true` when the requested field access is allowed.
     */
    private static Boolean hasFieldAccess(Schema.DescribeFieldResult fieldDescribe, String accessType) {
        if (accessType == QueueExpertAccessSupport.ACCESS_READ) {
            return fieldDescribe.isAccessible();
        }
        if (accessType == QueueExpertAccessSupport.ACCESS_CREATE) {
            return fieldDescribe.isCreateable();
        }
        return fieldDescribe.isUpdateable();
    }
}
