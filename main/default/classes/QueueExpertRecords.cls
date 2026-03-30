/**
 * @description Wrapper for registration details shown in the queue scheduler UI.
 */
public with sharing class QueueExpertRecords {
    /**
     * Registration record returned to the client.
     */
    @AuraEnabled public Registration_SCH__c regRecords { get; set; }
    /**
     * Calculated wait time label for the registration.
     */
    @AuraEnabled public String waitingTime { get; set; }
    /**
     * Initializes the records wrapper with an empty registration instance.
     */
    public QueueExpertRecords() {
        regRecords = new Registration_SCH__c();
    }
}
