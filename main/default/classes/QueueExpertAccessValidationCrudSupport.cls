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
        QueueExpertAccessValidationFieldAccessSupport.checkObjectAccess(sObjectType, accessType, errorMessage);
    }

    /**
     * @description Verifies field-level access using the supplied request definition.
     * @param request Field-access request wrapper to evaluate.
     */
    public static void checkFieldAccess(QueueExpertAccessSupport.FieldAccessRequest request) {
        QueueExpertAccessValidationFieldAccessSupport.checkFieldAccess(request);
    }

    /**
     * @description Deserializes client-submitted values for record updates.
     * @param payload Serialized payload from the client.
     * @param errorMessage Error message to throw when deserialization fails.
     * @return Deserialized list of values.
     */
    public static List<String> deserializeSubmittedValues(String payload, String errorMessage) {
        return QueueExpertAccessValidationPayloadSupport.deserializeSubmittedValues(payload, errorMessage);
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
        QueueExpertAccessValidationPayloadSupport.applyApprovedUpdateRecordValues(
            registrationToUpdate,
            recordValues,
            updateFieldsByIndex
        );
    }

    /**
     * @description Throws an AuraHandledException when an insert result contains an error.
     * @param saveResult Database insert result to inspect.
     * @param errorMessage Base error message to include in the exception.
     */
    public static void saveInsertResult(Database.SaveResult saveResult, String errorMessage) {
        QueueExpertAccessValidationDmlSupport.saveInsertResult(saveResult, errorMessage);
    }

    /**
     * @description Throws an AuraHandledException when an update result contains an error.
     * @param saveResult Database update result to inspect.
     * @param errorMessage Base error message to include in the exception.
     */
    public static void saveUpdateResult(Database.SaveResult saveResult, String errorMessage) {
        QueueExpertAccessValidationDmlSupport.saveUpdateResult(saveResult, errorMessage);
    }

    /**
     * @description Throws an AuraHandledException when a delete result contains an error.
     * @param deleteResult Database delete result to inspect.
     * @param errorMessage Base error message to include in the exception.
     */
    public static void saveDeleteResult(Database.DeleteResult deleteResult, String errorMessage) {
        QueueExpertAccessValidationDmlSupport.saveDeleteResult(deleteResult, errorMessage);
    }
}
