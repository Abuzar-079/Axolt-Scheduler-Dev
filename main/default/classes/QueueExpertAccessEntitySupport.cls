/**
 * @description Object-specific access assertions for queue expert actions.
 */
public with sharing class QueueExpertAccessEntitySupport {
    /**
     * @description Verifies that the supplied parent record is visible in user mode.
     * @param parentId Parent record identifier to validate.
     */
    public static void assertParentRecordAccessible(Id parentId) {
        QueueExpertAccessValidationSupport.checkObjectAccess(parentId.getSObjectType(), QueueExpertAccessSupport.ACCESS_READ, 'Insufficient access to the parent record.');
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

    /**
     * @description Verifies that the supplied parent Id belongs to an accessible registration.
     * @param parentId Parent registration identifier to validate.
     */
    public static void assertRegistrationParentAccess(Id parentId) {
        if (!Schema.sObjectType.Registration_SCH__c.isAccessible()) {
            throw new System.NoAccessException();
        }
        QueueExpertAccessValidationSupport.assertSObjectType(parentId, Registration_SCH__c.SObjectType, 'Parent record must be a registration.');
        QueueExpertAccessValidationSupport.checkObjectAccess(
            Registration_SCH__c.SObjectType,
            QueueExpertAccessSupport.ACCESS_READ,
            'Insufficient access to the parent registration.'
        );
        QueueExpertAccessValidationSupport.checkFieldAccess(
            QueueExpertAccessSupport.buildFieldAccessRequest(
                Registration_SCH__c.SObjectType,
                new Set<String>{ 'Id' },
                QueueExpertAccessSupport.ACCESS_READ
            ).withErrorMessage('Insufficient access to the parent registration.')
        );
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

    /**
     * @description Verifies requested access for the supplied registration record.
     * @param registrationId Registration identifier to validate.
     * @param accessType Access type to enforce.
     */
    public static void assertRegistrationAccess(Id registrationId, String accessType) {
        QueueExpertAccessValidationSupport.checkObjectAccess(
            Registration_SCH__c.SObjectType,
            accessType,
            accessType == QueueExpertAccessSupport.ACCESS_EDIT ? 'Insufficient access to update registrations.' : 'Insufficient access to view registrations.'
        );
        QueueExpertAccessValidationSupport.checkFieldAccess(
            QueueExpertAccessSupport.buildFieldAccessRequest(
                Registration_SCH__c.SObjectType,
                new Set<String>{ 'Id' },
                QueueExpertAccessSupport.ACCESS_READ
            ).withErrorMessage(
                accessType == QueueExpertAccessSupport.ACCESS_EDIT
                    ? 'Insufficient access to update registrations.'
                    : 'Insufficient access to view registrations.'
            )
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

    /**
     * @description Verifies create access for attachments under the supplied registration.
     * @param parentId Parent registration identifier.
     */
    public static void assertAttachmentCreateAccess(Id parentId) {
        assertRegistrationParentAccess(parentId);
        if (!Schema.sObjectType.Attachment.isCreateable()) {
            throw new AuraHandledException('Insufficient access to upload attachments.');
        }
        QueueExpertAccessValidationSupport.checkFieldAccess(
            QueueExpertAccessSupport.buildFieldAccessRequest(
                Attachment.SObjectType,
                new Set<String>{ 'ParentId', 'Body', 'Name', 'ContentType' },
                QueueExpertAccessSupport.ACCESS_CREATE
            ).withErrorMessage('Insufficient field access to upload attachments.')
        );
    }

    /**
     * @description Verifies delete access for attachments under the supplied registration.
     * @param parentId Parent registration identifier.
     */
    public static void assertAttachmentDeleteAccess(Id parentId) {
        assertRegistrationParentAccess(parentId);
        checkDeleteAccess(Attachment.SObjectType, 'Insufficient access to delete attachments.');
        QueueExpertAccessValidationSupport.checkFieldAccess(
            QueueExpertAccessSupport.buildFieldAccessRequest(
                Attachment.SObjectType,
                new Set<String>{ 'ParentId' },
                QueueExpertAccessSupport.ACCESS_READ
            ).withErrorMessage('Insufficient access to delete attachments.')
        );
    }

    /**
     * @description Verifies read access for attachments under the supplied registration.
     * @param parentId Parent registration identifier.
     */
    public static void assertAttachmentReadAccess(Id parentId) {
        assertRegistrationParentAccess(parentId);
        QueueExpertAccessValidationSupport.checkObjectAccess(Attachment.SObjectType, QueueExpertAccessSupport.ACCESS_READ, 'Insufficient access to view attachments.');
        QueueExpertAccessValidationSupport.checkFieldAccess(
            QueueExpertAccessSupport.buildFieldAccessRequest(
                Attachment.SObjectType,
                new Set<String>{ 'Id', 'Name', 'ParentId', 'ContentType' },
                QueueExpertAccessSupport.ACCESS_READ
            ).withErrorMessage('Insufficient access to view attachments.')
        );
    }

    /**
     * @description Verifies create access for notes under the supplied registration.
     * @param parentId Parent registration identifier.
     */
    public static void assertNoteCreateAccess(Id parentId) {
        assertRegistrationParentAccess(parentId);
        QueueExpertAccessValidationSupport.checkObjectAccess(Note.SObjectType, QueueExpertAccessSupport.ACCESS_CREATE, 'Insufficient access to create notes.');
        QueueExpertAccessValidationSupport.checkFieldAccess(
            QueueExpertAccessSupport.buildFieldAccessRequest(
                Note.SObjectType,
                new Set<String>{ 'ParentId', 'Title', 'Body' },
                QueueExpertAccessSupport.ACCESS_CREATE
            ).withErrorMessage('Insufficient field access to create notes.')
        );
    }

    /**
     * @description Verifies update access for notes under the supplied registration.
     * @param parentId Parent registration identifier.
     */
    public static void assertNoteUpdateAccess(Id parentId) {
        assertRegistrationParentAccess(parentId);
        QueueExpertAccessValidationSupport.checkObjectAccess(Note.SObjectType, QueueExpertAccessSupport.ACCESS_EDIT, 'Insufficient access to update notes.');
        QueueExpertAccessValidationSupport.checkFieldAccess(
            QueueExpertAccessSupport.buildFieldAccessRequest(
                Note.SObjectType,
                new Set<String>{ 'ParentId', 'Title', 'Body' },
                QueueExpertAccessSupport.ACCESS_EDIT
            ).withErrorMessage('Insufficient field access to update notes.')
        );
    }

    /**
     * @description Verifies read access for notes under the supplied registration.
     * @param parentId Parent registration identifier.
     */
    public static void assertNoteReadAccess(Id parentId) {
        assertRegistrationParentAccess(parentId);
        QueueExpertAccessValidationSupport.checkObjectAccess(Note.SObjectType, QueueExpertAccessSupport.ACCESS_READ, 'Insufficient access to view notes.');
        QueueExpertAccessValidationSupport.checkFieldAccess(
            QueueExpertAccessSupport.buildFieldAccessRequest(
                Note.SObjectType,
                new Set<String>{ 'Id', 'ParentId', 'Title' },
                QueueExpertAccessSupport.ACCESS_READ
            ).withErrorMessage('Insufficient access to view notes.')
        );
    }

    /**
     * @description Verifies delete access for notes under the supplied registration.
     * @param parentId Parent registration identifier.
     */
    public static void assertNoteDeleteAccess(Id parentId) {
        assertRegistrationParentAccess(parentId);
        checkDeleteAccess(Note.SObjectType, 'Insufficient access to delete notes.');
        QueueExpertAccessValidationSupport.checkFieldAccess(
            QueueExpertAccessSupport.buildFieldAccessRequest(
                Note.SObjectType,
                new Set<String>{ 'ParentId' },
                QueueExpertAccessSupport.ACCESS_READ
            ).withErrorMessage('Insufficient access to delete notes.')
        );
    }

    private static void checkDeleteAccess(Schema.SObjectType sObjectType, String errorMessage) {
        if (!sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isDeletable()) {
            throw new AuraHandledException(errorMessage);
        }
    }

    private static String getParentObjectApiName(Id parentId) {
        return parentId.getSObjectType().getDescribe(SObjectDescribeOptions.DEFERRED).getName();
    }
}
