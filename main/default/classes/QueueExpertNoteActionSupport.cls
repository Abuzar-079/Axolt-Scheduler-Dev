/**
 * @description Note and related-record delete actions for queue expert.
 */
public with sharing class QueueExpertNoteActionSupport {
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
        Id parentId = validateParentRegistration(regID);
        Note requestedNote = parseNotePayload(nn);
        validateRequestedNote(parentId, requestedNote);

        if (requestedNote.Id == null) {
            insertRequestedNote(parentId, requestedNote);
        } else {
            updateRequestedNote(parentId, requestedNote);
        }
        return getNotesByParent(parentId);
    }

    private static Id validateParentRegistration(String registrationIdValue) {
        Id parentId = QueueExpertAccessSupport.validateRecordId(registrationIdValue, 'Invalid parent record id.');
        QueueExpertAccessSupport.assertSObjectType(parentId, Registration_SCH__c.SObjectType, 'Parent record must be a registration.');
        QueueExpertAccessSupport.assertRegistrationParentAccess(parentId);
        return parentId;
    }

    private static void validateRequestedNote(Id parentId, Note requestedNote) {
        if (requestedNote.ParentId != null && requestedNote.ParentId != parentId) {
            throw new AuraHandledException('Mismatched note parent record.');
        }
        QueueExpertAccessSupport.validateNotBlank(requestedNote.Title, 'Note title is required.');
    }

    private static void insertRequestedNote(Id parentId, Note requestedNote) {
        QueueExpertAccessSupport.assertNoteCreateAccess(parentId);
        List<Note> safeNotes = getSafeNotes(
            buildNoteForInsert(parentId, requestedNote),
            AccessType.CREATABLE,
            parentId
        );
        if (!safeNotes.isEmpty()) {
            QueueExpertAccessSupport.saveInsertResult(
                Database.insert(safeNotes[0], false, AccessLevel.USER_MODE),
                'Unable to save the note.'
            );
        }
    }

    private static void updateRequestedNote(Id parentId, Note requestedNote) {
        Note existingNote = QueueExpertNoteRecordAccessSupport.getAccessibleNoteById(
            QueueExpertAccessSupport.validateRecordId(String.valueOf(requestedNote.Id), 'Invalid note record id.')
        );
        if (existingNote.ParentId != parentId) {
            throw new AuraHandledException('Mismatched note parent record.');
        }
        QueueExpertAccessSupport.assertNoteUpdateAccess(parentId);

        List<Note> safeNotes = getSafeNotes(
            buildSafeNoteForUpdate(existingNote.Id, parentId, requestedNote),
            AccessType.UPDATABLE,
            parentId
        );
        if (!safeNotes.isEmpty()) {
            QueueExpertAccessSupport.saveUpdateResult(
                Database.update(safeNotes[0], false, AccessLevel.USER_MODE),
                'Unable to save the note.'
            );
        }
    }

    private static Note buildNoteForInsert(Id parentId, Note requestedNote) {
        return new Note(
            ParentId = parentId,
            Title = requestedNote.Title.trim(),
            Body = requestedNote.Body
        );
    }

    private static List<Note> getSafeNotes(Note noteRecord, AccessType accessType, Id parentId) {
        List<SObject> safeList = FLSHelperSch.getSafeRecords(
            new List<Note>{ noteRecord },
            'Note',
            accessType
        );
        List<Note> typedList = new List<Note>();
        for (SObject safeRecord : safeList) {
            typedList.add(restoreRequiredNoteFields((Note)safeRecord, noteRecord.Title, parentId));
        }
        return typedList;
    }

    private static Note restoreRequiredNoteFields(Note safeNote, String title, Id parentId) {
        restoreRequiredNoteField(safeNote, 'ParentId', parentId);
        restoreRequiredNoteField(safeNote, 'Title', title);
        return safeNote;
    }

    private static void restoreRequiredNoteField(Note safeNote, String fieldName, Object fieldValue) {
        if (fieldValue != null && !safeNote.getPopulatedFieldsAsMap().containsKey(fieldName)) {
            safeNote.put(fieldName, fieldValue);
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

        Id relatedRecordId = QueueExpertAccessSupport.validateRecordId(raId, 'Invalid related record id.');
        QueueExpertNoteRecordAccessSupport.deleteRelatedRecord(relatedRecordId, objName);
        return wrapper;
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
