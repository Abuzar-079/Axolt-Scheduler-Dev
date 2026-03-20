/**
 * @description Select-option model used by the queue scheduler UI.
 */
public class Queue_Sch_SelectOption {
    /**
     * @description Display label shown to the user.
     */
    @AuraEnabled public String label { get; set; }
    /**
     * @description Backing value submitted by the client.
     */
    @AuraEnabled public String value { get; set; }
    /**
     * @description Indicates whether the option should be disabled.
     */
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    @AuraEnabled public Boolean disabled { get; set; }
    /**
     * @description Indicates whether the option label should be escaped.
     */
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    @AuraEnabled public Boolean escapeItem { get; set; }

    /**
     * @description Initializes a select option with default display flags.
     * @param value Backing value for the option.
     * @param label Display label for the option.
     * @param isDisabled Whether the option should start disabled.
     */
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    public Queue_Sch_SelectOption(String value, String label, Boolean isDisabled) {
        this.value = value;
        this.label = label;
        this.disabled = false;
        this.escapeItem = false;
    }
}