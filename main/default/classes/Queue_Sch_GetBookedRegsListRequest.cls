/**
 * @description Request wrapper for fetching booked queue registrations.
 */
public class Queue_Sch_GetBookedRegsListRequest {
    /**
     * @description Location filter identifier.
     */
    @AuraEnabled public String location { get; set; }
    /**
     * @description Service filter identifier.
     */
    @AuraEnabled public String service { get; set; }
    /**
     * @description Date filter value used to scope the results.
     */
    @AuraEnabled public String datefilterby { get; set; }
    /**
     * @description Search filter text used to narrow the results.
     */
    @AuraEnabled public String searchfilterby { get; set; }
}