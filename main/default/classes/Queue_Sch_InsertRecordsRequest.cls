/**
 * @description Request wrapper for inserting queue scheduler registration records.
 */
public class Queue_Sch_InsertRecordsRequest {
    /**
     * @description Customer first name.
     */
    @AuraEnabled public String fname { get; set; }
    /**
     * @description Customer last name.
     */
    @AuraEnabled public String lname { get; set; }
    /**
     * @description Customer email address.
     */
    @AuraEnabled public String email { get; set; }
    /**
     * @description Customer phone number.
     */
    @AuraEnabled public String phone { get; set; }
    /**
     * @description Selected location identifier.
     */
    @AuraEnabled public String location { get; set; }
    /**
     * @description Selected service value.
     */
    @AuraEnabled public String service { get; set; }
    /**
     * @description Existing registration records keyed by index.
     */
    @AuraEnabled public Map<Integer, Registration_SCH__c> existMap { get; set; }
    /**
     * @description Selected event identifier.
     */
    @AuraEnabled public String event { get; set; }
    /**
     * @description Selected queue identifier.
     */
    @AuraEnabled public String queueId { get; set; }
    /**
     * @description Selected slot start date and time.
     */
    @AuraEnabled public DateTime selSlotST { get; set; }
    /**
     * @description Selected slot end date and time.
     */
    @AuraEnabled public DateTime selSlotET { get; set; }
    /**
     * @description Selected service identifier.
     */
    @AuraEnabled public String serviceId { get; set; }
    /**
     * @description Selected resource identifier.
     */
    @AuraEnabled public String res { get; set; }
    /**
     * @description Initializes the request with an empty existing-record map.
     */
    public Queue_Sch_InsertRecordsRequest() {
        existMap = new Map<Integer, Registration_SCH__c>();
    }
}
