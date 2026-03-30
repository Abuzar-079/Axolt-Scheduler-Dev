/**
 * @description Select-option model used by the scheduler picklists.
 */
public with sharing class QueueExpertSelectOptions {
    /**
     * Display label shown to the user.
     */
    @AuraEnabled public String label { get; set; }
    /**
     * Backing value submitted by the client.
     */
    @AuraEnabled public String value { get; set; }
    /**
     * Indicates whether the option is preselected.
     */
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    @AuraEnabled public Boolean selected { get; set; }

    /**
     * Creates an unselected option entry.
     * @param lab Label shown to the user.
     * @param val Stored option value.
     */
    public QueueExpertSelectOptions(String lab, String val) {
        label = lab;
        value = val;
    }

    /**
     * Creates an option entry with an explicit selected state.
     * @param lab Label shown to the user.
     * @param val Stored option value.
     * @param sel Whether the option is selected.
     */
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    public QueueExpertSelectOptions(String lab, String val, Boolean sel) {
        label = lab;
        value = val;
        selected = sel;
    }
}
