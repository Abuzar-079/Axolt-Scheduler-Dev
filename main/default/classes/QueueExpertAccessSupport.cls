/**
 * @description Shared validation, access-check, and DML helper methods for queue expert actions.
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class QueueExpertAccessSupport {
    // commented by abuzar on 2026-03-30 for the scanning issue and added below line "Validation and object-specific access logic were split into dedicated support classes to reduce QueueExpertAccessSupport class cyclomatic complexity."
    // original validation constants and branching helper implementations moved to QueueExpertAccessValidationSupport and QueueExpertAccessEntitySupport
    //changes end here by abuzar

    public static final String ACCESS_READ = 'READ';
    public static final String ACCESS_CREATE = 'CREATE';
    public static final String ACCESS_EDIT = 'EDIT';

    /**
     * @description Request model describing which object fields should be checked for access.
     */
    public class FieldAccessRequest {
        public Schema.SObjectType sObjectType { get; private set; }
        public Set<String> fieldApiNames { get; private set; }
        public String accessType { get; private set; }
        public String errorMessage { get; private set; }

        /**
         * @description Creates a field-access request for the provided object, fields, and access type.
         * @param sObjectType Target sObject type to check.
         * @param fieldApiNames Field API names to validate.
         * @param accessType Access type to enforce.
         */
        public FieldAccessRequest(
            Schema.SObjectType sObjectType,
            Set<String> fieldApiNames,
            String accessType
        ) {
            this.sObjectType = sObjectType;
            this.fieldApiNames = fieldApiNames;
            this.accessType = accessType;
        }

        /**
         * @description Adds a custom error message to the field-access request.
         * @param errorMessage Error message to surface when access fails.
         * @return Updated field-access request instance.
         */
        public FieldAccessRequest withErrorMessage(String errorMessage) {
            this.errorMessage = errorMessage;
            return this;
        }
    }

    /**
     * @description Builds a field-access request wrapper for downstream validation.
     * @param sObjectType Target sObject type to check.
     * @param fieldApiNames Field API names to validate.
     * @param accessType Access type to enforce.
     * @return Field-access request wrapper.
     */
    public static FieldAccessRequest buildFieldAccessRequest(
        Schema.SObjectType sObjectType,
        Set<String> fieldApiNames,
        String accessType
    ) {
        return new FieldAccessRequest(sObjectType, fieldApiNames, accessType);
    }

    /**
     * @description Ensures the current request is associated with an authenticated user.
     */
    public static void assertAuthenticatedRequest() {
        // commented by abuzar on 2026-03-30 for the scanning issue and added below line "Moved authentication validation logic into a dedicated support class to reduce QueueExpertAccessSupport class cyclomatic complexity."
        // existing method body moved to QueueExpertAccessValidationSupport.assertAuthenticatedRequest()
        QueueExpertAccessValidationSupport.assertAuthenticatedRequest();
        //changes end here by abuzar
    }

    /**
     * @description Validates that the provided string contains a non-blank value.
     * @param value Input value to validate.
     * @param errorMessage Error message to throw when the value is blank.
     */
    public static void validateNotBlank(String value, String errorMessage) {
        QueueExpertAccessValidationSupport.validateNotBlank(value, errorMessage);
    }

    /**
     * @description Validates a Salesforce record identifier.
     * @param recordIdValue Raw record Id value from the client.
     * @param errorMessage Error message to throw when the value is invalid.
     * @return Parsed record Id.
     */
    public static Id validateRecordId(String recordIdValue, String errorMessage) {
        return QueueExpertAccessValidationSupport.validateRecordId(recordIdValue, errorMessage);
    }

    /**
     * @description Verifies that a record Id belongs to the expected sObject type.
     * @param recordId Record identifier to inspect.
     * @param expectedType Expected sObject type.
     * @param errorMessage Error message to throw when the type does not match.
     */
    public static void assertSObjectType(Id recordId, Schema.SObjectType expectedType, String errorMessage) {
        QueueExpertAccessValidationSupport.assertSObjectType(recordId, expectedType, errorMessage);
    }

    /**
     * @description Validates a registration identifier value.
     * @param registrationIdValue Raw registration Id value from the client.
     * @return Parsed registration Id.
     */
    public static Id validateRegistrationId(String registrationIdValue) {
        return QueueExpertAccessValidationSupport.validateRegistrationId(registrationIdValue);
    }

    /**
     * @description Validates a parent record identifier value.
     * @param parent Raw parent record Id value from the client.
     * @return Parsed parent record Id.
     */
    public static Id validateParentRecordId(String parent) {
        return QueueExpertAccessValidationSupport.validateParentRecordId(parent);
    }

    /**
     * @description Verifies object-level CRUD access for the supplied sObject type.
     * @param sObjectType Target sObject type to validate.
     * @param accessType Access type to enforce.
     * @param errorMessage Error message to throw when access is denied.
     */
    public static void checkObjectAccess(Schema.SObjectType sObjectType, String accessType, String errorMessage) {
        QueueExpertAccessValidationSupport.checkObjectAccess(sObjectType, accessType, errorMessage);
    }

    /**
     * @description Verifies field-level access using the supplied request definition.
     * @param request Field-access request wrapper to evaluate.
     */
    public static void checkFieldAccess(FieldAccessRequest request) {
        QueueExpertAccessValidationSupport.checkFieldAccess(request);
    }

    /**
     * @description Deserializes client-submitted values for record updates.
     * @param payload Serialized payload from the client.
     * @param errorMessage Error message to throw when deserialization fails.
     * @return Deserialized list of values.
     */
    public static List<String> deserializeSubmittedValues(String payload, String errorMessage) {
        return QueueExpertAccessValidationSupport.deserializeSubmittedValues(payload, errorMessage);
    }

    /**
     * @description Normalizes a client-submitted field value for DML assignment.
     * @param value Raw value from the client.
     * @return Normalized value or `null` when blank.
     */
    public static String normalizeForField(String value) {
        return QueueExpertAccessValidationSupport.normalizeForField(value);
    }

    /**
     * @description Applies approved record-update values to the target registration.
     * @param registrationToUpdate Registration record being prepared for update.
     * @param recordValues Ordered values submitted by the client.
     */
    public static void applyApprovedUpdateRecordValues(Registration_SCH__c registrationToUpdate, List<String> recordValues) {
        QueueExpertAccessValidationSupport.applyApprovedUpdateRecordValues(registrationToUpdate, recordValues);
    }

    /**
     * @description Throws an AuraHandledException when an insert result contains an error.
     * @param saveResult Database insert result to inspect.
     * @param errorMessage Base error message to include in the exception.
     */
    public static void saveInsertResult(Database.SaveResult saveResult, String errorMessage) {
        QueueExpertAccessValidationSupport.saveInsertResult(saveResult, errorMessage);
    }

    /**
     * @description Throws an AuraHandledException when an update result contains an error.
     * @param saveResult Database update result to inspect.
     * @param errorMessage Base error message to include in the exception.
     */
    public static void saveUpdateResult(Database.SaveResult saveResult, String errorMessage) {
        QueueExpertAccessValidationSupport.saveUpdateResult(saveResult, errorMessage);
    }

    /**
     * @description Throws an AuraHandledException when a delete result contains an error.
     * @param deleteResult Database delete result to inspect.
     * @param errorMessage Base error message to include in the exception.
     */
    public static void saveDeleteResult(Database.DeleteResult deleteResult, String errorMessage) {
        QueueExpertAccessValidationSupport.saveDeleteResult(deleteResult, errorMessage);
    }

    /**
     * @description Verifies that the supplied parent record is accessible.
     * @param parentId Parent record identifier to validate.
     */
    public static void assertParentRecordAccessible(Id parentId) {
        QueueExpertAccessEntitySupport.assertParentRecordAccessible(parentId);
    }

    /**
     * @description Verifies that a parent registration record is accessible.
     * @param parentId Parent registration identifier to validate.
     */
    public static void assertRegistrationParentAccess(Id parentId) {
        QueueExpertAccessEntitySupport.assertRegistrationParentAccess(parentId);
    }

    /**
     * @description Verifies requested access for the supplied registration record.
     * @param registrationId Registration identifier to validate.
     * @param accessType Access type to enforce.
     */
    public static void assertRegistrationAccess(Id registrationId, String accessType) {
        QueueExpertAccessEntitySupport.assertRegistrationAccess(registrationId, accessType);
    }

    /**
     * @description Verifies create access for attachments on the supplied parent registration.
     * @param parentId Parent registration identifier.
     */
    public static void assertAttachmentCreateAccess(Id parentId) {
        QueueExpertAccessEntitySupport.assertAttachmentCreateAccess(parentId);
    }

    /**
     * @description Verifies delete access for attachments on the supplied parent registration.
     * @param parentId Parent registration identifier.
     */
    public static void assertAttachmentDeleteAccess(Id parentId) {
        QueueExpertAccessEntitySupport.assertAttachmentDeleteAccess(parentId);
    }

    /**
     * @description Verifies read access for attachments on the supplied parent registration.
     * @param parentId Parent registration identifier.
     */
    public static void assertAttachmentReadAccess(Id parentId) {
        QueueExpertAccessEntitySupport.assertAttachmentReadAccess(parentId);
    }

    /**
     * @description Verifies create access for notes on the supplied parent registration.
     * @param parentId Parent registration identifier.
     */
    public static void assertNoteCreateAccess(Id parentId) {
        QueueExpertAccessEntitySupport.assertNoteCreateAccess(parentId);
    }

    /**
     * @description Verifies update access for notes on the supplied parent registration.
     * @param parentId Parent registration identifier.
     */
    public static void assertNoteUpdateAccess(Id parentId) {
        QueueExpertAccessEntitySupport.assertNoteUpdateAccess(parentId);
    }

    /**
     * @description Verifies read access for notes on the supplied parent registration.
     * @param parentId Parent registration identifier.
     */
    public static void assertNoteReadAccess(Id parentId) {
        QueueExpertAccessEntitySupport.assertNoteReadAccess(parentId);
    }

    /**
     * @description Verifies delete access for notes on the supplied parent registration.
     * @param parentId Parent registration identifier.
     */
    public static void assertNoteDeleteAccess(Id parentId) {
        QueueExpertAccessEntitySupport.assertNoteDeleteAccess(parentId);
    }
}
