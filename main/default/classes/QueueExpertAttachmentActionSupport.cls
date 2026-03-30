/**
 * @description Attachment-specific queue expert actions.
 */
public with sharing class QueueExpertAttachmentActionSupport {
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

    /**
     * @description Returns attachments related to the provided parent registration.
     * @param parentId Parent registration identifier whose attachments should be returned.
     * @return Attachments associated with the parent registration.
     */
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

    /**
     * @description Uploads an attachment and returns the refreshed attachment list.
     * @param request Upload request payload containing parent and file details.
     * @return Attachments associated with the parent registration after upload.
     */
    public static List<Attachment> uploadFile(QueueExpertUploadFileRequest request) {
        QueueExpertAccessSupport.assertAuthenticatedRequest();
        Id parentId = QueueExpertAccessSupport.validateRecordId(request.parent, 'Invalid parent record id.');
        QueueExpertAccessSupport.assertSObjectType(parentId, Registration_SCH__c.SObjectType, 'Parent record must be a registration.');
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
        if (!Schema.sObjectType.Attachment.isCreateable()) {
            throw new AuraHandledException('Insufficient access to upload attachments.');
        }
        if (!Schema.sObjectType.Attachment.fields.ParentId.isCreateable()) {
            throw new AuraHandledException('Insufficient field access to upload attachments.');
        }
        if (!Schema.sObjectType.Attachment.fields.Body.isCreateable()) {
            throw new AuraHandledException('Insufficient field access to upload attachments.');
        }
        if (!Schema.sObjectType.Attachment.fields.Name.isCreateable()) {
            throw new AuraHandledException('Insufficient field access to upload attachments.');
        }
        if (!Schema.sObjectType.Attachment.fields.ContentType.isCreateable()) {
            throw new AuraHandledException('Insufficient field access to upload attachments.');
        }
        QueueExpertAccessSupport.assertRegistrationParentAccess(parentId);
        validateUploadInput(request.fileName, request.base64Data, request.contentType);
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

    /**
     * @description Returns an attachment that is accessible for deletion.
     * @param relatedRecordId Attachment identifier to validate.
     * @return Accessible attachment record.
     */
    public static Attachment getAccessibleAttachmentForDelete(Id relatedRecordId) {
        QueueExpertAccessSupport.checkObjectAccess(Attachment.SObjectType, QueueExpertAccessSupport.ACCESS_READ, 'Insufficient access to delete attachments.');
        QueueExpertAccessSupport.checkFieldAccess(
            QueueExpertAccessSupport.buildFieldAccessRequest(
                Attachment.SObjectType,
                new Set<String>{ 'Id', 'ParentId' },
                QueueExpertAccessSupport.ACCESS_READ
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
