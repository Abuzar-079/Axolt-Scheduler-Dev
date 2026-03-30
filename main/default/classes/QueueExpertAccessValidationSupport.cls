/**
 * @description Generic validation, field-access, and DML helpers for queue expert actions.
 */
public with sharing class QueueExpertAccessValidationSupport {
    private static final Map<Integer, String> UPDATE_RECORD_FIELDS_BY_INDEX = new Map<Integer, String>{
        0 => 'Customer_Status__c',
        1 => 'Customer_Type__c',
        2 => 'Registration_Type__c',
        3 => 'Meeting_Status__c',
        4 => 'Meeting_outcome__c',
        5 => 'Purpose__c',
        6 => 'Customer_Name__c',
        7 => 'Customer_Lastname__c',
        8 => 'Customer_Email__c',
        9 => 'Customer_Contact__c',
        15 => 'Contact__c'
    };

    /**
     * @description Ensures the current request is associated with an authenticated user.
     */
    public static void assertAuthenticatedRequest() {
        if (String.isBlank(UserInfo.getUserId())) {
            throw new AuraHandledException('Authentication is required for this action.');
        }
    }

    /**
     * @description Validates that the provided string contains a non-blank value.
     * @param value Input value to validate.
     * @param errorMessage Error message to throw when the value is blank.
     */
    public static void validateNotBlank(String value, String errorMessage) {
        if (String.isBlank(value)) {
            throw new AuraHandledException(errorMessage);
        }
    }

    /**
     * @description Validates a Salesforce record identifier.
     * @param recordIdValue Raw record Id value from the client.
     * @param errorMessage Error message to throw when the value is invalid.
     * @return Parsed record Id.
     */
    public static Id validateRecordId(String recordIdValue, String errorMessage) {
        validateNotBlank(recordIdValue, errorMessage);
        try {
            return (Id)recordIdValue.trim();
        } catch (TypeException ex) {
            throw new AuraHandledException(errorMessage);
        }
    }

    /**
     * @description Verifies that a record Id belongs to the expected sObject type.
     * @param recordId Record identifier to inspect.
     * @param expectedType Expected sObject type.
     * @param errorMessage Error message to throw when the type does not match.
     */
    public static void assertSObjectType(Id recordId, Schema.SObjectType expectedType, String errorMessage) {
        if (recordId.getSObjectType() != expectedType) {
            throw new AuraHandledException(errorMessage);
        }
    }

    /**
     * @description Validates a registration identifier value.
     * @param registrationIdValue Raw registration Id value from the client.
     * @return Parsed registration Id.
     */
    public static Id validateRegistrationId(String registrationIdValue) {
        Id registrationId = validateRecordId(registrationIdValue, 'Invalid registration record id.');
        assertSObjectType(registrationId, Registration_SCH__c.SObjectType, 'The target record must be a registration.');
        return registrationId;
    }

    /**
     * @description Validates a parent record identifier value.
     * @param parent Raw parent record Id value from the client.
     * @return Parsed parent record Id.
     */
    public static Id validateParentRecordId(String parent) {
        Id parentId = validateRecordId(parent, 'Invalid parent record id.');
        assertSObjectType(parentId, Registration_SCH__c.SObjectType, 'Parent record must be a registration.');
        return parentId;
    }

    /**
     * @description Validates a parent record identifier and confirms the registration is accessible.
     * @param parent Raw parent record Id value from the client.
     * @return Parsed and accessible parent record Id.
     */
    public static Id validateAccessibleParentRecordId(String parent) {
        Id parentId = validateParentRecordId(parent);
        QueueExpertAccessEntitySupport.assertRegistrationParentAccess(parentId);
        return parentId;
    }

    /**
     * @description Verifies object-level CRUD access for the supplied sObject type.
     * @param sObjectType Target sObject type to validate.
     * @param accessType Access type to enforce.
     * @param errorMessage Error message to throw when access is denied.
     */
    public static void checkObjectAccess(Schema.SObjectType sObjectType, String accessType, String errorMessage) {
        QueueExpertAccessValidationCrudSupport.checkObjectAccess(sObjectType, accessType, errorMessage);
    }

    /**
     * @description Verifies field-level access using the supplied request definition.
     * @param request Field-access request wrapper to evaluate.
     */
    public static void checkFieldAccess(QueueExpertAccessSupport.FieldAccessRequest request) {
        QueueExpertAccessValidationCrudSupport.checkFieldAccess(request);
    }

    /**
     * @description Deserializes client-submitted values for record updates.
     * @param payload Serialized payload from the client.
     * @param errorMessage Error message to throw when deserialization fails.
     * @return Deserialized list of values.
     */
    public static List<String> deserializeSubmittedValues(String payload, String errorMessage) {
        return QueueExpertAccessValidationCrudSupport.deserializeSubmittedValues(payload, errorMessage);
    }

    /**
     * @description Normalizes a client-submitted field value for DML assignment.
     * @param value Raw value from the client.
     * @return Normalized value or `null` when blank.
     */
    public static String normalizeForField(String value) {
        return String.isBlank(value) ? null : value.trim();
    }

    /**
     * @description Applies approved record-update values to the target registration.
     * @param registrationToUpdate Registration record being prepared for update.
     * @param recordValues Ordered values submitted by the client.
     */
    public static void applyApprovedUpdateRecordValues(Registration_SCH__c registrationToUpdate, List<String> recordValues) {
        QueueExpertAccessValidationCrudSupport.applyApprovedUpdateRecordValues(
            registrationToUpdate,
            recordValues,
            UPDATE_RECORD_FIELDS_BY_INDEX
        );
    }

    /**
     * @description Throws an AuraHandledException when an insert result contains an error.
     * @param saveResult Database insert result to inspect.
     * @param errorMessage Base error message to include in the exception.
     */
    public static void saveInsertResult(Database.SaveResult saveResult, String errorMessage) {
        QueueExpertAccessValidationCrudSupport.saveInsertResult(saveResult, errorMessage);
    }

    /**
     * @description Throws an AuraHandledException when an update result contains an error.
     * @param saveResult Database update result to inspect.
     * @param errorMessage Base error message to include in the exception.
     */
    public static void saveUpdateResult(Database.SaveResult saveResult, String errorMessage) {
        QueueExpertAccessValidationCrudSupport.saveUpdateResult(saveResult, errorMessage);
    }

    /**
     * @description Throws an AuraHandledException when a delete result contains an error.
     * @param deleteResult Database delete result to inspect.
     * @param errorMessage Base error message to include in the exception.
     */
    public static void saveDeleteResult(Database.DeleteResult deleteResult, String errorMessage) {
        QueueExpertAccessValidationCrudSupport.saveDeleteResult(deleteResult, errorMessage);
    }
}
