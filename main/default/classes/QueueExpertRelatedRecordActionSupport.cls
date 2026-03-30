/**
 * @description Attachment and note actions extracted from Queue_Expert_Sch.
 */
public with sharing class QueueExpertRelatedRecordActionSupport {
    private static final Set<String> SUPPORTED_RELATED_RECORD_OBJECTS = new Set<String>{
        'Attachment',
        'Note'
    };
    private static final Integer MAX_ATTACHMENT_SIZE_BYTES = 4500000;
    private static final Set<String> ALLOWED_ATTACHMENT_EXTENSIONS = new Set<String>{
        'csv',
        'doc',
        'docx',
        'gif',
        'jpeg',
        'jpg',
        'pdf',
        'png',
        'txt',
        'xls',
        'xlsx'
    };
    private static final Set<String> ALLOWED_ATTACHMENT_CONTENT_TYPES = new Set<String>{
        'application/msword',
        'application/pdf',
        'application/vnd.ms-excel',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'image/gif',
        'image/jpeg',
        'image/png',
        'text/csv',
        'text/plain'
    };

    public static void assertParentRecordAccessible(Id parentId) {
        QueueExpertAccessSupport.assertParentRecordAccessible(parentId);
    }

    public static List<Attachment> getAttachmentsByParent(Id parentId) {
        QueueExpertAccessSupport.assertAttachmentReadAccess(parentId);
        return [
            SELECT Id, Name, ParentId, ContentType
            FROM Attachment
            WHERE ParentId = :parentId
            WITH USER_MODE
            ORDER BY CreatedDate ASC
            LIMIT 1000
        ];
    }

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

    public static List<Attachment> uploadFile(Queue_Expert_Sch.UploadFileRequest request) {
        QueueExpertAccessSupport.assertAuthenticatedRequest();
        Id parentId = QueueExpertAccessSupport.validateParentRecordId(request.parent);
        validateUploadInput(request.fileName, request.base64Data, request.contentType);
        if (!Schema.sObjectType.Registration_SCH__c.isAccessible()) {
            throw new AuraHandledException('Insufficient access to the parent registration.');
        }
        QueueExpertAccessSupport.assertAttachmentCreateAccess(parentId);
        Blob attachmentBody = decodeAttachmentBody(request.base64Data);
        Attachment attachmentRecord = new Attachment();
        attachmentRecord.ParentId = parentId;
        attachmentRecord.Body = attachmentBody;
        attachmentRecord.Name = request.fileName.trim();
        attachmentRecord.ContentType = request.contentType.trim().toLowerCase();
        QueueExpertAccessSupport.saveInsertResult(
            Database.insert(attachmentRecord, false, AccessLevel.USER_MODE),
            'Unable to upload the attachment.'
        );
        return getAttachmentsByParent(parentId);
    }

    public static List<Note> saveNotes(String nn, String regID) {
        QueueExpertAccessSupport.assertAuthenticatedRequest();
        Id parentId = QueueExpertAccessSupport.validateParentRecordId(regID);
        if (!Schema.sObjectType.Registration_SCH__c.isAccessible()) {
            throw new AuraHandledException('Insufficient access to the parent registration.');
        }
        Note requestedNote = parseNotePayload(nn);
        if (requestedNote.ParentId != null && requestedNote.ParentId != parentId) {
            throw new AuraHandledException('Mismatched note parent record.');
        }
        QueueExpertAccessSupport.validateNotBlank(requestedNote.Title, 'Note title is required.');

        if (requestedNote.Id == null) {
            QueueExpertAccessSupport.assertNoteCreateAccess(parentId);
            Note noteToInsert = new Note();
            noteToInsert.ParentId = parentId;
            noteToInsert.Title = requestedNote.Title.trim();
            noteToInsert.Body = requestedNote.Body;
            QueueExpertAccessSupport.saveInsertResult(
                Database.insert(noteToInsert, false, AccessLevel.USER_MODE),
                'Unable to save the note.'
            );
        } else {
            Note existingNote = getAccessibleNoteById(
                QueueExpertAccessSupport.validateRecordId(String.valueOf(requestedNote.Id), 'Invalid note record id.')
            );
            if (existingNote.ParentId != parentId) {
                throw new AuraHandledException('Mismatched note parent record.');
            }
            QueueExpertAccessSupport.assertNoteUpdateAccess(parentId);
            Note noteToUpdate = buildSafeNoteForUpdate(existingNote.Id, parentId, requestedNote);
            QueueExpertAccessSupport.saveUpdateResult(
                Database.update(noteToUpdate, false, AccessLevel.USER_MODE),
                'Unable to save the note.'
            );
        }
        return getNotesByParent(parentId);
    }

    public static Queue_Expert_Sch.Wrapper deleteAT(String raId, String objName) {
        Queue_Expert_Sch.Wrapper wrapper = new Queue_Expert_Sch.Wrapper();
        QueueExpertAccessSupport.assertAuthenticatedRequest();
        if (!SUPPORTED_RELATED_RECORD_OBJECTS.contains(objName)) {
            throw new AuraHandledException('Unsupported related record type.');
        }
        Id relatedRecordId = QueueExpertAccessSupport.validateRecordId(raId, 'Invalid related record id.');
        SObject relatedRecord = getAccessibleRelatedRecordForDelete(relatedRecordId, objName);
        QueueExpertAccessSupport.saveDeleteResult(
            Database.delete(relatedRecord, false, AccessLevel.USER_MODE),
            'Unable to delete the related record.'
        );
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

    private static Note getAccessibleNoteById(Id noteId) {
        QueueExpertAccessSupport.checkObjectAccess(Note.SObjectType, QueueExpertAccessSupport.AccessType.READ, 'Insufficient access to view notes.');
        QueueExpertAccessSupport.checkFieldAccess(
            QueueExpertAccessSupport.buildFieldAccessRequest(
                Note.SObjectType,
                new Set<String>{ 'Id', 'ParentId' },
                QueueExpertAccessSupport.AccessType.READ
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

    private static SObject getAccessibleRelatedRecordForDelete(Id relatedRecordId, String objName) {
        if (objName == 'Attachment') {
            QueueExpertAccessSupport.checkObjectAccess(Attachment.SObjectType, QueueExpertAccessSupport.AccessType.READ, 'Insufficient access to delete attachments.');
            QueueExpertAccessSupport.checkFieldAccess(
                QueueExpertAccessSupport.buildFieldAccessRequest(
                    Attachment.SObjectType,
                    new Set<String>{ 'Id', 'ParentId' },
                    QueueExpertAccessSupport.AccessType.READ
                ).withErrorMessage('Insufficient access to delete attachments.')
            );
            List<Attachment> attachments = [
                SELECT Id, ParentId
                FROM Attachment
                WHERE Id = :relatedRecordId
                WITH USER_MODE
                LIMIT 1
            ];
            if (attachments.isEmpty()) {
                throw new AuraHandledException('Attachment record is not accessible.');
            }
            QueueExpertAccessSupport.assertSObjectType(attachments[0].ParentId, Registration_SCH__c.SObjectType, 'Parent record must be a registration.');
            QueueExpertAccessSupport.assertAttachmentDeleteAccess(attachments[0].ParentId);
            return attachments[0];
        }
        if (objName == 'Note') {
            Note noteRecord = getAccessibleNoteById(relatedRecordId);
            QueueExpertAccessSupport.assertSObjectType(noteRecord.ParentId, Registration_SCH__c.SObjectType, 'Parent record must be a registration.');
            QueueExpertAccessSupport.assertNoteDeleteAccess(noteRecord.ParentId);
            return noteRecord;
        }
        throw new AuraHandledException('Unsupported related record type.');
    }

    private static void validateUploadInput(String fileName, String encodedPayload, String contentType) {
        QueueExpertAccessSupport.validateNotBlank(fileName, 'File name is required.');
        QueueExpertAccessSupport.validateNotBlank(encodedPayload, 'File content is required.');
        QueueExpertAccessSupport.validateNotBlank(contentType, 'File content type is required.');
        String normalizedFileName = fileName.trim();
        Integer extensionIndex = normalizedFileName.lastIndexOf('.');
        if (extensionIndex <= 0 || extensionIndex == normalizedFileName.length() - 1) {
            throw new AuraHandledException('File type is not allowed.');
        }
        String extension = normalizedFileName.substring(extensionIndex + 1).toLowerCase();
        if (!ALLOWED_ATTACHMENT_EXTENSIONS.contains(extension)) {
            throw new AuraHandledException('File type is not allowed.');
        }
        if (!ALLOWED_ATTACHMENT_CONTENT_TYPES.contains(contentType.trim().toLowerCase())) {
            throw new AuraHandledException('File content type is not allowed.');
        }
    }

    private static Blob decodeAttachmentBody(String encodedPayload) {
        try {
            String decodedPayload = EncodingUtil.urlDecode(encodedPayload, 'UTF-8');
            Blob fileBody = EncodingUtil.base64Decode(decodedPayload);
            if (fileBody == null || fileBody.size() == 0) {
                throw new AuraHandledException('File content is required.');
            }
            if (fileBody.size() > MAX_ATTACHMENT_SIZE_BYTES) {
                throw new AuraHandledException('File exceeds the maximum supported size.');
            }
            return fileBody;
        } catch (StringException ex) {
            throw new AuraHandledException('File content could not be decoded.');
        }
    }
}
