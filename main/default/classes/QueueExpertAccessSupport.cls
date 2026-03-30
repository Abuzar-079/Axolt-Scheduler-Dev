/**
 * @description Shared validation, access-check, and DML helper methods for queue expert actions.
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class QueueExpertAccessSupport {
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

    public enum AccessType {
        READ,
        CREATE,
        EDIT
    }

    public class FieldAccessRequest {
        public Schema.SObjectType sObjectType { get; private set; }
        public Set<String> fieldApiNames { get; private set; }
        public AccessType accessType { get; private set; }
        public String errorMessage { get; private set; }

        public FieldAccessRequest(
            Schema.SObjectType sObjectType,
            Set<String> fieldApiNames,
            AccessType accessType
        ) {
            this.sObjectType = sObjectType;
            this.fieldApiNames = fieldApiNames;
            this.accessType = accessType;
        }

        public FieldAccessRequest withErrorMessage(String errorMessage) {
            this.errorMessage = errorMessage;
            return this;
        }
    }

    public static FieldAccessRequest buildFieldAccessRequest(
        Schema.SObjectType sObjectType,
        Set<String> fieldApiNames,
        AccessType accessType
    ) {
        return new FieldAccessRequest(sObjectType, fieldApiNames, accessType);
    }

    public static void assertAuthenticatedRequest() {
        if (String.isBlank(UserInfo.getUserId())) {
            throw new AuraHandledException('Authentication is required for this action.');
        }
    }

    public static void validateNotBlank(String value, String errorMessage) {
        if (String.isBlank(value)) {
            throw new AuraHandledException(errorMessage);
        }
    }

    public static Id validateRecordId(String recordIdValue, String errorMessage) {
        validateNotBlank(recordIdValue, errorMessage);
        try {
            return (Id)recordIdValue.trim();
        } catch (TypeException ex) {
            throw new AuraHandledException(errorMessage);
        }
    }

    public static void assertSObjectType(Id recordId, Schema.SObjectType expectedType, String errorMessage) {
        if (recordId.getSObjectType() != expectedType) {
            throw new AuraHandledException(errorMessage);
        }
    }

    public static Id validateRegistrationId(String registrationIdValue) {
        Id registrationId = validateRecordId(registrationIdValue, 'Invalid registration record id.');
        assertSObjectType(registrationId, Registration_SCH__c.SObjectType, 'The target record must be a registration.');
        return registrationId;
    }

    public static Id validateParentRecordId(String parent) {
        Id parentId = validateRecordId(parent, 'Invalid parent record id.');
        assertSObjectType(parentId, Registration_SCH__c.SObjectType, 'Parent record must be a registration.');
        return parentId;
    }

    public static void checkObjectAccess(Schema.SObjectType sObjectType, AccessType accessType, String errorMessage) {
        Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED);
        Boolean hasAccess = accessType == AccessType.READ
            ? describeResult.isAccessible()
            : accessType == AccessType.CREATE
                ? describeResult.isCreateable()
                : describeResult.isUpdateable();
        if (!hasAccess) {
            throw new AuraHandledException(errorMessage);
        }
    }

    public static void checkFieldAccess(FieldAccessRequest request) {
        Map<String, Schema.SObjectField> fieldMap = request.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).fields.getMap();
        for (String fieldApiName : request.fieldApiNames) {
            if (!fieldMap.containsKey(fieldApiName)) {
                throw new AuraHandledException('Unsupported field requested: ' + fieldApiName);
            }
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldApiName).getDescribe();
            Boolean hasAccess = request.accessType == AccessType.READ
                ? fieldDescribe.isAccessible()
                : request.accessType == AccessType.CREATE
                    ? fieldDescribe.isCreateable()
                    : fieldDescribe.isUpdateable();
            if (!hasAccess) {
                throw new AuraHandledException(request.errorMessage);
            }
        }
    }

    public static List<String> deserializeSubmittedValues(String payload, String errorMessage) {
        validateNotBlank(payload, errorMessage);
        try {
            List<String> submittedValues = (List<String>)JSON.deserialize(payload, List<String>.class);
            return submittedValues == null ? new List<String>() : submittedValues;
        } catch (JSONException ex) {
            throw new AuraHandledException(errorMessage);
        }
    }

    public static String normalizeForField(String value) {
        return String.isBlank(value) ? null : value.trim();
    }

    public static void applyApprovedUpdateRecordValues(Registration_SCH__c registrationToUpdate, List<String> recordValues) {
        for (Integer indexValue : UPDATE_RECORD_FIELDS_BY_INDEX.keySet()) {
            if (recordValues.size() <= indexValue) {
                continue;
            }
            registrationToUpdate.put(
                UPDATE_RECORD_FIELDS_BY_INDEX.get(indexValue),
                normalizeForField(recordValues[indexValue])
            );
        }
        if (recordValues.size() >= 15) {
            registrationToUpdate.Status__c = 'Completed';
        }
    }

    public static void saveInsertResult(Database.SaveResult saveResult, String errorMessage) {
        if (saveResult == null || !saveResult.isSuccess()) {
            throw buildDmlException(errorMessage, saveResult == null ? null : saveResult.getErrors());
        }
    }

    public static void saveUpdateResult(Database.SaveResult saveResult, String errorMessage) {
        if (saveResult == null || !saveResult.isSuccess()) {
            throw buildDmlException(errorMessage, saveResult == null ? null : saveResult.getErrors());
        }
    }

    public static void saveDeleteResult(Database.DeleteResult deleteResult, String errorMessage) {
        if (deleteResult == null || !deleteResult.isSuccess()) {
            throw buildDmlException(errorMessage, deleteResult == null ? null : deleteResult.getErrors());
        }
    }

    private static AuraHandledException buildDmlException(String errorMessage, Database.Error[] errors) {
        String finalMessage = errorMessage;
        if (errors != null && !errors.isEmpty() && !String.isBlank(errors[0].getMessage())) {
            finalMessage += ' ' + errors[0].getMessage();
        }
        return new AuraHandledException(finalMessage);
    }

    private static void checkDeleteAccess(Schema.SObjectType sObjectType, String errorMessage) {
        if (!sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isDeletable()) {
            throw new AuraHandledException(errorMessage);
        }
    }

    private static String getParentObjectApiName(Id parentId) {
        return parentId.getSObjectType().getDescribe(SObjectDescribeOptions.DEFERRED).getName();
    }

    public static void assertParentRecordAccessible(Id parentId) {
        checkObjectAccess(parentId.getSObjectType(), AccessType.READ, 'Insufficient access to the parent record.');
        Map<String, Object> bindVars = new Map<String, Object>{
            'parentId' => parentId
        };
        List<SObject> parentRecords = Database.queryWithBinds(
            'SELECT Id FROM ' + getParentObjectApiName(parentId) + ' WHERE Id = :parentId LIMIT 1',
            bindVars,
            AccessLevel.USER_MODE
        );
        if (parentRecords.isEmpty()) {
            throw new AuraHandledException('Parent record is not accessible.');
        }
    }

    public static void assertRegistrationParentAccess(Id parentId) {
        assertSObjectType(parentId, Registration_SCH__c.SObjectType, 'Parent record must be a registration.');
        if (!Schema.sObjectType.Registration_SCH__c.isAccessible()) {
            throw new AuraHandledException('Insufficient access to the parent registration.');
        }
        List<Registration_SCH__c> parentRegistrations = [
            SELECT Id
            FROM Registration_SCH__c
            WHERE Id = :parentId
            WITH USER_MODE
            LIMIT 1
        ];
        if (parentRegistrations.isEmpty()) {
            throw new AuraHandledException('Parent registration is not accessible.');
        }
    }

    public static void assertRegistrationAccess(Id registrationId, AccessType accessType) {
        checkObjectAccess(
            Registration_SCH__c.SObjectType,
            accessType,
            accessType == AccessType.EDIT ? 'Insufficient access to update registrations.' : 'Insufficient access to view registrations.'
        );
        List<Registration_SCH__c> registrations = [
            SELECT Id
            FROM Registration_SCH__c
            WHERE Id = :registrationId
            WITH USER_MODE
            LIMIT 1
        ];
        if (registrations.isEmpty()) {
            throw new AuraHandledException('Registration record is not accessible.');
        }
    }

    public static void assertAttachmentCreateAccess(Id parentId) {
        assertRegistrationParentAccess(parentId);
        if (!Schema.sObjectType.Attachment.isCreateable()) {
            throw new AuraHandledException('Insufficient access to upload attachments.');
        }
        checkFieldAccess(
            buildFieldAccessRequest(
                Attachment.SObjectType,
                new Set<String>{ 'ParentId', 'Body', 'Name', 'ContentType' },
                AccessType.CREATE
            ).withErrorMessage('Insufficient field access to upload attachments.')
        );
    }

    public static void assertAttachmentDeleteAccess(Id parentId) {
        assertRegistrationParentAccess(parentId);
        checkDeleteAccess(Attachment.SObjectType, 'Insufficient access to delete attachments.');
        checkFieldAccess(
            buildFieldAccessRequest(
                Attachment.SObjectType,
                new Set<String>{ 'ParentId' },
                AccessType.READ
            ).withErrorMessage('Insufficient access to delete attachments.')
        );
    }

    public static void assertAttachmentReadAccess(Id parentId) {
        assertRegistrationParentAccess(parentId);
        checkObjectAccess(Attachment.SObjectType, AccessType.READ, 'Insufficient access to view attachments.');
        checkFieldAccess(
            buildFieldAccessRequest(
                Attachment.SObjectType,
                new Set<String>{ 'Id', 'Name', 'ParentId', 'ContentType' },
                AccessType.READ
            ).withErrorMessage('Insufficient access to view attachments.')
        );
    }

    public static void assertNoteCreateAccess(Id parentId) {
        assertRegistrationParentAccess(parentId);
        checkObjectAccess(Note.SObjectType, AccessType.CREATE, 'Insufficient access to create notes.');
        checkFieldAccess(
            buildFieldAccessRequest(
                Note.SObjectType,
                new Set<String>{ 'ParentId', 'Title', 'Body' },
                AccessType.CREATE
            ).withErrorMessage('Insufficient field access to create notes.')
        );
    }

    public static void assertNoteUpdateAccess(Id parentId) {
        assertRegistrationParentAccess(parentId);
        checkObjectAccess(Note.SObjectType, AccessType.EDIT, 'Insufficient access to update notes.');
        checkFieldAccess(
            buildFieldAccessRequest(
                Note.SObjectType,
                new Set<String>{ 'ParentId', 'Title', 'Body' },
                AccessType.EDIT
            ).withErrorMessage('Insufficient field access to update notes.')
        );
    }

    public static void assertNoteReadAccess(Id parentId) {
        assertRegistrationParentAccess(parentId);
        checkObjectAccess(Note.SObjectType, AccessType.READ, 'Insufficient access to view notes.');
        checkFieldAccess(
            buildFieldAccessRequest(
                Note.SObjectType,
                new Set<String>{ 'Id', 'ParentId', 'Title' },
                AccessType.READ
            ).withErrorMessage('Insufficient access to view notes.')
        );
    }

    public static void assertNoteDeleteAccess(Id parentId) {
        assertRegistrationParentAccess(parentId);
        checkDeleteAccess(Note.SObjectType, 'Insufficient access to delete notes.');
        checkFieldAccess(
            buildFieldAccessRequest(
                Note.SObjectType,
                new Set<String>{ 'ParentId' },
                AccessType.READ
            ).withErrorMessage('Insufficient access to delete notes.')
        );
    }
}
