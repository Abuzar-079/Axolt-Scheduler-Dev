/**
 * @description Time-slot model used by the queue scheduler.
 */
public class Queue_Sch_TimeSlot {
    /**
     * @description Slot start date and time.
     */
    @AuraEnabled public DateTime slot { set; get; }
    /**
     * @description Assigned user identifier.
     */
    @AuraEnabled public String userId { set; get; }
    /**
     * @description Assigned user display name.
     */
    @AuraEnabled public String userName { set; get; }
    /**
     * @description Number of registrations represented by the slot.
     */
    @AuraEnabled public Integer slotCount { get; set; }
    /**
     * @description Formatted slot label shown in the UI.
     */
    @AuraEnabled public String slotStr { get; set; }
    /**
     * @description Slot end date and time.
     */
    @AuraEnabled public DateTime slotET { set; get; }

    /**
     * @description Initializes a time-slot wrapper with empty default values.
     */
    public Queue_Sch_TimeSlot() {
        slot = null;
        slotET = null;
        userId = '';
        userName = '';
        slotStr = '';
    }
}