/**
 * @description Attachment and note actions extracted from Queue_Expert_Sch.
 */
public with sharing class QueueExpertRelatedRecordActionSupport {
    // commented by abuzar on 2026-03-30 for the scanning issue and added below line "Attachment and note responsibilities were split into dedicated support classes to reduce QueueExpertRelatedRecordActionSupport class cyclomatic complexity."
    // original attachment/note constants and helper implementations moved to QueueExpertAttachmentActionSupport and QueueExpertNoteActionSupport
    //changes end here by abuzar

    /**
     * @description Verifies that the supplied parent record is accessible to the running user.
     * @param parentId Parent record identifier to validate.
     */
    public static void assertParentRecordAccessible(Id parentId) {
        QueueExpertAccessSupport.assertParentRecordAccessible(parentId);
    }

    /**
     * @description Returns attachments related to the provided parent record.
     * @param parentId Parent record identifier whose attachments should be returned.
     * @return Attachments associated with the parent record.
     */
    public static List<Attachment> getAttachmentsByParent(Id parentId) {
        // commented by abuzar on 2026-03-30 for the scanning issue and added below line "Moved attachment query logic into a dedicated support class to reduce QueueExpertRelatedRecordActionSupport class cyclomatic complexity."
        // existing method body moved to QueueExpertAttachmentActionSupport.getAttachmentsByParent(...)
        return QueueExpertAttachmentActionSupport.getAttachmentsByParent(parentId);
        //changes end here by abuzar
    }

    /**
     * @description Returns notes related to the provided parent record.
     * @param parentId Parent record identifier whose notes should be returned.
     * @return Notes associated with the parent record.
     */
    public static List<Note> getNotesByParent(Id parentId) {
        // commented by abuzar on 2026-03-30 for the scanning issue and added below line "Moved note query logic into a dedicated support class to reduce QueueExpertRelatedRecordActionSupport class cyclomatic complexity."
        // existing method body moved to QueueExpertNoteActionSupport.getNotesByParent(...)
        return QueueExpertNoteActionSupport.getNotesByParent(parentId);
        //changes end here by abuzar
    }

    /**
     * @description Uploads an attachment for the provided queue-expert request payload.
     * @param request Upload request payload containing parent and file details.
     * @return Refreshed list of attachments for the parent record.
     */
    public static List<Attachment> uploadFile(QueueExpertUploadFileRequest request) {
        // commented by abuzar on 2026-03-30 for the scanning issue and added below line "Moved attachment upload logic into a dedicated support class to reduce QueueExpertRelatedRecordActionSupport class cyclomatic complexity."
        // existing method body moved to QueueExpertAttachmentActionSupport.uploadFile(...)
        return QueueExpertAttachmentActionSupport.uploadFile(request);
        //changes end here by abuzar
    }

    /**
     * @description Saves a note for the provided registration.
     * @param nn Serialized note payload from the client.
     * @param regID Registration identifier that owns the note.
     * @return Refreshed list of notes for the registration.
     */
    public static List<Note> saveNotes(String nn, String regID) {
        // commented by abuzar on 2026-03-30 for the scanning issue and added below line "Moved note save logic into a dedicated support class to reduce QueueExpertRelatedRecordActionSupport class cyclomatic complexity."
        // existing method body moved to QueueExpertNoteActionSupport.saveNotes(...)
        return QueueExpertNoteActionSupport.saveNotes(nn, regID);
        //changes end here by abuzar
    }

    /**
     * @description Deletes a supported related record and returns an action wrapper.
     * @param raId Related record identifier to delete.
     * @param objName API name of the related record object.
     * @return Wrapper describing the delete outcome.
     */
    public static QueueExpertWrapper deleteAT(String raId, String objName) {
        // commented by abuzar on 2026-03-30 for the scanning issue and added below line "Moved related-record delete logic into a dedicated support class to reduce QueueExpertRelatedRecordActionSupport class cyclomatic complexity."
        // existing method body moved to QueueExpertNoteActionSupport.deleteAT(...)
        return QueueExpertNoteActionSupport.deleteAT(raId, objName);
        //changes end here by abuzar
    }
}
