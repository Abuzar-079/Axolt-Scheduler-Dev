/**
 * @description CRUD, field-access, and DML helpers extracted from QueueExpertAccessValidationSupport.
 */
public with sharing class QueueExpertAccessValidationCrudSupport {
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
     * @description Deserializes client-submitted values for record updates.
     * @param payload Serialized payload from the client.
     * @param errorMessage Error message to throw when deserialization fails.
     * @return Deserialized list of values.
     */
    public static List<String> deserializeSubmittedValues(String payload, String errorMessage) {
        QueueExpertAccessValidationSupport.validateNotBlank(payload, errorMessage);
        try {
            List<String> submittedValues = (List<String>)JSON.deserialize(payload, List<String>.class);
            return submittedValues == null ? new List<String>() : submittedValues;
        } catch (JSONException ex) {
            throw new AuraHandledException(errorMessage);
        }
    }

    /**
     * @description Applies approved record-update values to the target registration.
     * @param registrationToUpdate Registration record being prepared for update.
     * @param recordValues Ordered values submitted by the client.
     * @param updateFieldsByIndex Supported field mapping keyed by list index.
     */
    public static void applyApprovedUpdateRecordValues(
        Registration_SCH__c registrationToUpdate,
        List<String> recordValues,
        Map<Integer, String> updateFieldsByIndex
    ) {
        for (Integer indexValue : updateFieldsByIndex.keySet()) {
            if (recordValues.size() > indexValue) {
                registrationToUpdate.put(
                    updateFieldsByIndex.get(indexValue),
                    QueueExpertAccessValidationSupport.normalizeForField(recordValues[indexValue])
                );
            }
        }
        if (recordValues.size() >= 15) {
            registrationToUpdate.Status__c = 'Completed';
        }
    }

    /**
     * @description Throws an AuraHandledException when an insert result contains an error.
     * @param saveResult Database insert result to inspect.
     * @param errorMessage Base error message to include in the exception.
     */
    public static void saveInsertResult(Database.SaveResult saveResult, String errorMessage) {
        throwIfSaveFailed(saveResult, errorMessage);
    }

    /**
     * @description Throws an AuraHandledException when an update result contains an error.
     * @param saveResult Database update result to inspect.
     * @param errorMessage Base error message to include in the exception.
     */
    public static void saveUpdateResult(Database.SaveResult saveResult, String errorMessage) {
        throwIfSaveFailed(saveResult, errorMessage);
    }

    /**
     * @description Throws an AuraHandledException when a delete result contains an error.
     * @param deleteResult Database delete result to inspect.
     * @param errorMessage Base error message to include in the exception.
     */
    public static void saveDeleteResult(Database.DeleteResult deleteResult, String errorMessage) {
        if (deleteResult == null || !deleteResult.isSuccess()) {
            throw buildDmlException(errorMessage, deleteResult == null ? null : deleteResult.getErrors());
        }
    }

    private static Boolean hasObjectAccess(Schema.DescribeSObjectResult describeResult, String accessType) {
        if (accessType == QueueExpertAccessSupport.ACCESS_READ) {
            return describeResult.isAccessible();
        }
        if (accessType == QueueExpertAccessSupport.ACCESS_CREATE) {
            return describeResult.isCreateable();
        }
        return describeResult.isUpdateable();
    }

    private static Schema.DescribeFieldResult getRequestedFieldDescribe(
        Map<String, Schema.SObjectField> fieldMap,
        String fieldApiName
    ) {
        if (!fieldMap.containsKey(fieldApiName)) {
            throw new AuraHandledException('Unsupported field requested: ' + fieldApiName);
        }
        return fieldMap.get(fieldApiName).getDescribe();
    }

    private static Boolean hasFieldAccess(Schema.DescribeFieldResult fieldDescribe, String accessType) {
        if (accessType == QueueExpertAccessSupport.ACCESS_READ) {
            return fieldDescribe.isAccessible();
        }
        if (accessType == QueueExpertAccessSupport.ACCESS_CREATE) {
            return fieldDescribe.isCreateable();
        }
        return fieldDescribe.isUpdateable();
    }

    private static void throwIfSaveFailed(Database.SaveResult saveResult, String errorMessage) {
        if (saveResult == null || !saveResult.isSuccess()) {
            throw buildDmlException(errorMessage, saveResult == null ? null : saveResult.getErrors());
        }
    }

    private static AuraHandledException buildDmlException(String errorMessage, Database.Error[] errors) {
        String finalMessage = errorMessage;
        if (errors != null && !errors.isEmpty() && !String.isBlank(errors[0].getMessage())) {
            finalMessage += ' ' + errors[0].getMessage();
        }
        return new AuraHandledException(finalMessage);
    }
}
