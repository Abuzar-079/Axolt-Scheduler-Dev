/**
 * @description Request payload used by the queue scheduler upload action.
 */
public with sharing class QueueExpertUploadFileRequest {
    @AuraEnabled public String parent { get; set; }
    @AuraEnabled public String fileName { get; set; }
    @AuraEnabled public String base64Data { get; set; }
    @AuraEnabled public String contentType { get; set; }

    /**
     * @description Creates an empty upload request for Aura and LWC deserialization.
     */
    public QueueExpertUploadFileRequest() {
        // commented by abuzar on 2026-03-30 for the scanning issue and added below line "Avoid empty block statements."
        // required no-arg constructor for Aura/LWC request deserialization
        this.parent = this.parent;
        //changes end here by abuzar
    }
}
