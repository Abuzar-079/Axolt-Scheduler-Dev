/**
 * @description Record access and delete helpers for queue expert notes and attachments.
 */
public with sharing class QueueExpertNoteRecordAccessSupport {
    private static final Set<String> SUPPORTED_RELATED_RECORD_OBJECTS = new Set<String>{
        'Attachment',
        'Note'
    };

    /**
     * @description Deletes a supported related record in user mode after access checks.
     * @param relatedRecordId Related record identifier to delete.
     * @param objName API name of the related record object.
     */
    public static void deleteRelatedRecord(Id relatedRecordId, String objName) {
        validateSupportedRelatedRecordType(objName);
        if (objName == 'Attachment') {
            deleteAttachmentRecord(relatedRecordId);
            return;
        }
        deleteNoteRecord(relatedRecordId);
    }

    /**
     * @description Returns a note that is accessible to the running user.
     * @param noteId Note identifier to validate.
     * @return Accessible note record.
     */
    public static Note getAccessibleNoteById(Id noteId) {
        if (!Schema.sObjectType.Note.isAccessible()) {
            throw new AuraHandledException('Insufficient access to view notes.');
        }
        if (!Schema.sObjectType.Note.fields.Id.isAccessible()) {
            throw new AuraHandledException('Insufficient access to view notes.');
        }
        if (!Schema.sObjectType.Note.fields.ParentId.isAccessible()) {
            throw new AuraHandledException('Insufficient access to view notes.');
        }
        QueueExpertAccessSupport.checkObjectAccess(Note.SObjectType, QueueExpertAccessSupport.ACCESS_READ, 'Insufficient access to view notes.');
        QueueExpertAccessSupport.checkFieldAccess(
            QueueExpertAccessSupport.buildFieldAccessRequest(
                Note.SObjectType,
                new Set<String>{ 'Id', 'ParentId' },
                QueueExpertAccessSupport.ACCESS_READ
            ).withErrorMessage('Insufficient access to view notes.')
        );
        List<Note> notes = [
            SELECT Id, ParentId
            FROM Note
            WHERE Id = :noteId
            WITH USER_MODE
            LIMIT 1
        ];
        if (notes.isEmpty()) {
            throw new AuraHandledException('Note record is not accessible.');
        }
        return notes[0];
    }

    private static void deleteAttachmentRecord(Id relatedRecordId) {
        QueueExpertAccessSupport.assertSObjectType(relatedRecordId, Attachment.SObjectType, 'Related record must be an attachment.');
        Attachment attachmentRecord = QueueExpertAttachmentActionSupport.getAccessibleAttachmentForDelete(relatedRecordId);
        assertParentRegistrationAccessFromRelatedRecord(attachmentRecord.ParentId);
        QueueExpertAccessSupport.assertAttachmentDeleteAccess(attachmentRecord.ParentId);
        QueueExpertAccessSupport.saveDeleteResult(
            Database.delete(attachmentRecord, false, AccessLevel.USER_MODE),
            'Unable to delete the related record.'
        );
    }

    private static void deleteNoteRecord(Id relatedRecordId) {
        QueueExpertAccessSupport.assertSObjectType(relatedRecordId, Note.SObjectType, 'Related record must be a note.');
        Note noteRecord = getAccessibleNoteById(relatedRecordId);
        QueueExpertAccessSupport.assertSObjectType(noteRecord.ParentId, Registration_SCH__c.SObjectType, 'Parent record must be a registration.');
        assertParentRegistrationAccessFromRelatedRecord(noteRecord.ParentId);
        QueueExpertAccessSupport.assertNoteDeleteAccess(noteRecord.ParentId);
        QueueExpertAccessSupport.saveDeleteResult(
            Database.delete(noteRecord, false, AccessLevel.USER_MODE),
            'Unable to delete the related record.'
        );
    }

    private static void assertParentRegistrationAccessFromRelatedRecord(Id parentId) {
        QueueExpertAccessSupport.checkObjectAccess(
            Registration_SCH__c.SObjectType,
            QueueExpertAccessSupport.ACCESS_READ,
            'Insufficient access to the parent registration.'
        );
        QueueExpertAccessSupport.checkFieldAccess(
            QueueExpertAccessSupport.buildFieldAccessRequest(
                Registration_SCH__c.SObjectType,
                new Set<String>{ 'Id' },
                QueueExpertAccessSupport.ACCESS_READ
            ).withErrorMessage('Insufficient access to the parent registration.')
        );
        if (!Schema.sObjectType.Registration_SCH__c.isAccessible()) {
            throw new System.NoAccessException();
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

    private static void validateSupportedRelatedRecordType(String objName) {
        if (!SUPPORTED_RELATED_RECORD_OBJECTS.contains(objName)) {
            throw new AuraHandledException('Unsupported related record type.');
        }
    }
}
