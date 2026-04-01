/**
 * @description Note and related-record delete actions for queue expert.
 */
public with sharing class QueueExpertNoteActionSupport {
    private static final Set<String> SUPPORTED_RELATED_RECORD_OBJECTS = new Set<String>{
        'Attachment',
        'Note'
    };

    /**
     * @description Returns notes related to the provided parent registration.
     * @param parentId Parent registration identifier whose notes should be returned.
     * @return Notes associated with the parent registration.
     */
    public static List<Note> getNotesByParent(Id parentId) {
        QueueExpertAccessSupport.assertNoteReadAccess(parentId);
        return [
            SELECT Id, Title, ParentId
            FROM Note
            WHERE ParentId = :parentId
            WITH USER_MODE
            ORDER BY CreatedDate ASC
            LIMIT 1000
        ];
    }

    /**
 * @description Saves a note for the provided registration and returns the refreshed note list.
 * @param nn Serialized note payload from the client.
 * @param regID Registration identifier that owns the note.
 * @return Notes associated with the registration after save.
 */
public static List<Note> saveNotes(String nn, String regID) {
    QueueExpertAccessSupport.assertAuthenticatedRequest();
    Id parentId = QueueExpertAccessSupport.validateRecordId(regID, 'Invalid parent record id.');
    QueueExpertAccessSupport.assertSObjectType(parentId, Registration_SCH__c.SObjectType, 'Parent record must be a registration.');
    QueueExpertAccessSupport.assertRegistrationParentAccess(parentId);
    Note requestedNote = parseNotePayload(nn);
    if (requestedNote.ParentId != null && requestedNote.ParentId != parentId) {
        throw new AuraHandledException('Mismatched note parent record.');
    }
    QueueExpertAccessSupport.validateNotBlank(requestedNote.Title, 'Note title is required.');

    if (requestedNote.Id == null) {
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
        if (!Schema.sObjectType.Note.isCreateable()) {
            throw new AuraHandledException('Insufficient access to create notes.');
        }
        if (!Schema.sObjectType.Note.fields.ParentId.isCreateable()) {
            throw new AuraHandledException('Insufficient field access to create notes.');
        }
        if (!Schema.sObjectType.Note.fields.Title.isCreateable()) {
            throw new AuraHandledException('Insufficient field access to create notes.');
        }
        if (!Schema.sObjectType.Note.fields.Body.isCreateable()) {
            throw new AuraHandledException('Insufficient field access to create notes.');
        }
        QueueExpertAccessSupport.assertNoteCreateAccess(parentId);

        Note noteToInsert = new Note();
        noteToInsert.ParentId = parentId;
        noteToInsert.Title = requestedNote.Title.trim();
        noteToInsert.Body = requestedNote.Body;

        // ✅ FLS-Compliant Insert using FLSHelperSch
        List<SObject> safeList = FLSHelperSch.getSafeRecords(
            new List<Note>{ noteToInsert },
            'Note',
            AccessType.CREATABLE
        );
        List<Note> typedList = new List<Note>();
        for (SObject s : safeList) {
            Note safeNote = (Note) s;
            // Restore required master-detail ParentId field if stripped by FLS
            if (!safeNote.getPopulatedFieldsAsMap().containsKey('ParentId') && parentId != null) {
                safeNote.ParentId = parentId;
            }
            // Restore Title if stripped by FLS
            if (!safeNote.getPopulatedFieldsAsMap().containsKey('Title') && noteToInsert.Title != null) {
                safeNote.Title = noteToInsert.Title;
            }
            typedList.add(safeNote);
        }
        if (!typedList.isEmpty()) {
            if (Schema.sObjectType.Note.isCreateable()) {
                QueueExpertAccessSupport.saveInsertResult(
                    Database.insert(typedList[0], false, AccessLevel.USER_MODE),
                    'Unable to save the note.'
                );
            } else {
                throw new AuraHandledException('Insufficient access to create notes.');
            }
        }

    } else {
        Note existingNote = getAccessibleNoteById(
            QueueExpertAccessSupport.validateRecordId(String.valueOf(requestedNote.Id), 'Invalid note record id.')
        );
        if (existingNote.ParentId != parentId) {
            throw new AuraHandledException('Mismatched note parent record.');
        }
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
        if (!Schema.sObjectType.Note.isUpdateable()) {
            throw new AuraHandledException('Insufficient access to update notes.');
        }
        if (!Schema.sObjectType.Note.fields.ParentId.isUpdateable()) {
            throw new AuraHandledException('Insufficient field access to update notes.');
        }
        if (!Schema.sObjectType.Note.fields.Title.isUpdateable()) {
            throw new AuraHandledException('Insufficient field access to update notes.');
        }
        if (!Schema.sObjectType.Note.fields.Body.isUpdateable()) {
            throw new AuraHandledException('Insufficient field access to update notes.');
        }
        QueueExpertAccessSupport.assertNoteUpdateAccess(parentId);

        Note noteToUpdate = buildSafeNoteForUpdate(existingNote.Id, parentId, requestedNote);

        // ✅ FLS-Compliant Update using FLSHelperSch
        List<SObject> safeList = FLSHelperSch.getSafeRecords(
            new List<Note>{ noteToUpdate },
            'Note',
            AccessType.UPDATABLE
        );
        List<Note> typedList = new List<Note>();
        for (SObject s : safeList) {
            Note safeNote = (Note) s;
            // Restore required master-detail ParentId field if stripped by FLS
            if (!safeNote.getPopulatedFieldsAsMap().containsKey('ParentId') && parentId != null) {
                safeNote.ParentId = parentId;
            }
            // Restore Title if stripped by FLS
            if (!safeNote.getPopulatedFieldsAsMap().containsKey('Title') && noteToUpdate.Title != null) {
                safeNote.Title = noteToUpdate.Title;
            }
            typedList.add(safeNote);
        }
        if (!typedList.isEmpty()) {
            if (Schema.sObjectType.Note.isUpdateable()) {
                QueueExpertAccessSupport.saveUpdateResult(
                    Database.update(typedList[0], false, AccessLevel.USER_MODE),
                    'Unable to save the note.'
                );
            } else {
                throw new AuraHandledException('Insufficient access to update notes.');
            }
        }
    }
    return getNotesByParent(parentId);
}
    /**
 * @description Saves a note for the provided registration and returns the refreshed note list.
 * @param nn Serialized note payload from the client.
 * @param regID Registration identifier that owns the note.
 * @return Notes associated with the registration after save.
 */
public static void assertNoteCreateAccess(Id parentId) {
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

    if (!Schema.sObjectType.Note.isCreateable()) {
        throw new AuraHandledException('Insufficient access to create notes.');
    }
    if (!Schema.sObjectType.Note.fields.ParentId.isCreateable()) {
        throw new AuraHandledException('Insufficient field access to Note.ParentId.');
    }
    if (!Schema.sObjectType.Note.fields.Title.isCreateable()) {
        throw new AuraHandledException('Insufficient field access to Note.Title.');
    }
    if (!Schema.sObjectType.Note.fields.Body.isCreateable()) {
        throw new AuraHandledException('Insufficient field access to Note.Body.');
    }
}
/**
 * @description Saves a note for the provided registration and returns the refreshed note list.
 * @param nn Serialized note payload from the client.
 * @param regID Registration identifier that owns the note.
 * @return Notes associated with the registration after save.
 */
public static void assertNoteUpdateAccess(Id parentId) {
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

    if (!Schema.sObjectType.Note.isUpdateable()) {
        throw new AuraHandledException('Insufficient access to update notes.');
    }
    if (!Schema.sObjectType.Note.fields.ParentId.isUpdateable()) {
        throw new AuraHandledException('Insufficient field access to Note.ParentId.');
    }
    if (!Schema.sObjectType.Note.fields.Title.isUpdateable()) {
        throw new AuraHandledException('Insufficient field access to Note.Title.');
    }
    if (!Schema.sObjectType.Note.fields.Body.isUpdateable()) {
        throw new AuraHandledException('Insufficient field access to Note.Body.');
    }
}
    /**
     * @description Deletes a supported related record and returns an action wrapper.
     * @param raId Related record identifier to delete.
     * @param objName API name of the related record object.
     * @return Wrapper describing the delete outcome.
     */
    public static QueueExpertWrapper deleteAT(String raId, String objName) {
        QueueExpertWrapper wrapper = new QueueExpertWrapper();
        QueueExpertAccessSupport.assertAuthenticatedRequest();
        if (!SUPPORTED_RELATED_RECORD_OBJECTS.contains(objName)) {
            throw new AuraHandledException('Unsupported related record type.');
        }
        Id relatedRecordId = QueueExpertAccessSupport.validateRecordId(raId, 'Invalid related record id.');
        if (objName == 'Attachment') {
            QueueExpertAccessSupport.assertSObjectType(relatedRecordId, Attachment.SObjectType, 'Related record must be an attachment.');
            Attachment attachmentRecord = QueueExpertAttachmentActionSupport.getAccessibleAttachmentForDelete(relatedRecordId);
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
                throw new AuraHandledException('Insufficient access to the parent registration.');
            }
            List<Registration_SCH__c> parentRegistrations = [
                SELECT Id
                FROM Registration_SCH__c
                WHERE Id = :attachmentRecord.ParentId
                WITH USER_MODE
                LIMIT 1
            ];
            if (parentRegistrations.isEmpty()) {
                throw new AuraHandledException('Parent registration is not accessible.');
            }
            if (!Schema.sObjectType.Attachment.isDeletable()) {
                throw new AuraHandledException('Insufficient access to delete attachments.');
            }
            QueueExpertAccessSupport.assertRegistrationParentAccess(attachmentRecord.ParentId);
            QueueExpertAccessSupport.assertAttachmentDeleteAccess(attachmentRecord.ParentId);
            QueueExpertAccessSupport.saveDeleteResult(
                Database.delete(attachmentRecord, false, AccessLevel.USER_MODE),
                'Unable to delete the related record.'
            );
            return wrapper;
        }

        QueueExpertAccessSupport.assertSObjectType(relatedRecordId, Note.SObjectType, 'Related record must be a note.');
        Note noteRecord = getAccessibleNoteById(relatedRecordId);
        QueueExpertAccessSupport.assertSObjectType(noteRecord.ParentId, Registration_SCH__c.SObjectType, 'Parent record must be a registration.');
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
            throw new AuraHandledException('Insufficient access to the parent registration.');
        }
        List<Registration_SCH__c> parentRegistrations = [
            SELECT Id
            FROM Registration_SCH__c
            WHERE Id = :noteRecord.ParentId
            WITH USER_MODE
            LIMIT 1
        ];
        if (parentRegistrations.isEmpty()) {
            throw new AuraHandledException('Parent registration is not accessible.');
        }
        if (!Schema.sObjectType.Note.isDeletable()) {
            throw new AuraHandledException('Insufficient access to delete notes.');
        }
        QueueExpertAccessSupport.assertRegistrationParentAccess(noteRecord.ParentId);
        QueueExpertAccessSupport.assertNoteDeleteAccess(noteRecord.ParentId);
        QueueExpertAccessSupport.saveDeleteResult(
            Database.delete(noteRecord, false, AccessLevel.USER_MODE),
            'Unable to delete the related record.'
        );
        return wrapper;
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

    private static Note parseNotePayload(String noteJson) {
        QueueExpertAccessSupport.validateNotBlank(noteJson, 'Invalid note payload.');
        try {
            return (Note)JSON.deserialize(noteJson, Note.class);
        } catch (JSONException ex) {
            throw new AuraHandledException('Invalid note payload.');
        }
    }

    private static Note buildSafeNoteForUpdate(Id noteId, Id parentId, Note requestedNote) {
        Note noteToUpdate = new Note(Id = noteId);
        if (Schema.sObjectType.Note.fields.ParentId.isUpdateable()) {
            noteToUpdate.ParentId = parentId;
        }
        if (Schema.sObjectType.Note.fields.Title.isUpdateable()) {
            noteToUpdate.Title = requestedNote.Title.trim();
        }
        if (Schema.sObjectType.Note.fields.Body.isUpdateable()) {
            noteToUpdate.Body = requestedNote.Body;
        }
        return noteToUpdate;
    }

}
