/**
 * @description Select-options model used by queue scheduler picklists.
 */
public class Queue_Sch_SelectOptions {
    /**
     * @description Display label shown to the user.
     */
    @AuraEnabled public String label { get; set; }
    /**
     * @description Backing value submitted by the client.
     */
    @AuraEnabled public String value { get; set; }
    /**
     * @description Indicates whether the option is selected.
     */
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    @AuraEnabled public Boolean selected { get; set; }

    /**
     * @description Initializes a picklist option with an explicit selected state.
     * @param lab Display label for the option.
     * @param val Backing value for the option.
     * @param sel Indicates whether the option is selected.
     */
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    public Queue_Sch_SelectOptions(String lab, String val, Boolean sel) {
        label = lab;
        value = val;
        selected = sel;
    }
}