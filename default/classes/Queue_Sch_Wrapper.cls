/**
 * @description Wrapper payload for queue scheduler data returned to the client.
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public class Queue_Sch_Wrapper {
    /**
     * @description Token registration record used by the scheduler flow.
     */
    @AuraEnabled public Registration_SCH__c tokenReg { get; set; }
    /**
     * @description All record identifiers or labels shown in the UI.
     */
    @AuraEnabled @TestVisible public List<String> allrecords { get; set; }
    /**
     * @description Registration records keyed by client-side identifier.
     */
    @AuraEnabled @TestVisible public Map<String, Registration_SCH__c> mapOfRecords { get; set; }
    /**
     * @description Booked appointments returned for the selected filters.
     */
    @AuraEnabled @TestVisible public List<Registration_SCH__c> bookedAppointment { get; set; }
    /**
     * @description Registration updates keyed by client-side identifier.
     */
    @AuraEnabled @TestVisible public Map<String, Registration_SCH__c> updateMap { get; set; }
    /**
     * @description Queue registration records displayed in the scheduler.
     */
    @AuraEnabled @TestVisible public List<Registration_SCH__c> records { get; set; }
    /**
     * @description Available queue locations for selection.
     */
    @AuraEnabled @TestVisible public List<Queue__c> getLocation { get; set; }
    /**
     * @description Selected service value.
     */
    @AuraEnabled @TestVisible public String service { get; set; }
    /**
     * @description Selected service display name.
     */
    @AuraEnabled @TestVisible public String serviceName { get; set; }
    /**
     * @description Last modified timestamp label.
     */
    @AuraEnabled @TestVisible public String lastmodified { get; set; }
    /**
     * @description Available time-slot values.
     */
    @AuraEnabled @TestVisible public List<Integer> timeSlot { get; set; }
    /**
     * @description Indicates whether matching locations were found.
     */
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    @AuraEnabled @TestVisible public Boolean existLocation { get; set; }
    /**
     * @description Indicates whether a status update succeeded.
     */
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    @AuraEnabled @TestVisible public Boolean updateStatus { get; set; }
    /**
     * @description Indicates whether a cancel-related status update succeeded.
     */
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    @AuraEnabled @TestVisible public Boolean updateStatusForCancel { get; set; }
    /**
     * @description All available location identifiers.
     */
    @AuraEnabled @TestVisible public List<Id> allLocations { get; set; }
    /**
     * @description Available service identifiers.
     */
    @AuraEnabled @TestVisible public Set<Id> serviceIds { get; set; }
    /**
     * @description Available expert identifiers.
     */
    @AuraEnabled @TestVisible public Set<Id> expertIds { get; set; }
    /**
     * @description Available expert names.
     */
    @AuraEnabled @TestVisible public Set<String> allExperts { get; set; }
    /**
     * @description Available service names.
     */
    @AuraEnabled @TestVisible public Set<String> allServices { get; set; }
    /**
     * @description Available event names.
     */
    @AuraEnabled @TestVisible public Set<String> allEvents { get; set; }
    /**
     * @description Available appointment categories.
     */
    @AuraEnabled @TestVisible public Set<String> allCategories { get; set; }
    /**
     * @description Selected record type name.
     */
    @AuraEnabled @TestVisible public String recType { get; set; }
    /**
     * @description Selected appointment type.
     */
    @AuraEnabled @TestVisible public String type { get; set; }
    /**
     * @description Registration record type value.
     */
    @AuraEnabled public String recTypeReg { get; set; }
    /**
     * @description Selected event service value.
     */
    @AuraEnabled @TestVisible public String eventService { get; set; }
    /**
     * @description Filtered service selection.
     */
    @AuraEnabled @TestVisible public String fser { get; set; }
    /**
     * @description Filtered location selection.
     */
    @AuraEnabled @TestVisible public String floc { get; set; }
    /**
     * @description Available program names.
     */
    @AuraEnabled @TestVisible public Set<String> allPrograms { get; set; }
    /**
     * @description Filtered resource selection.
     */
    @AuraEnabled @TestVisible public String fres { get; set; }
    /**
     * @description Current program selection.
     */
    @AuraEnabled @TestVisible public String currentProgram { get; set; }
    /**
     * @description Category options for scheduler picklists.
     */
    @AuraEnabled @TestVisible public List<Queue_Sch_SelectOptions> allCategory { get; set; }
    /**
     * @description Type options for scheduler picklists.
     */
    @AuraEnabled @TestVisible public List<Queue_Sch_SelectOptions> allType { get; set; }
    /**
     * @description Subtype options for scheduler picklists.
     */
    @AuraEnabled @TestVisible public List<Queue_Sch_SelectOptions> allSubType { get; set; }
    /**
     * @description Error message returned to the client.
     */
    @AuraEnabled @TestVisible public String errMsg { get; set; }
    /**
     * @description Attachments related to the selected registration.
     */
    @AuraEnabled @TestVisible public List<Attachment> attachments { get; set; }
    /**
     * @description Available product records for selection.
     */
    @AuraEnabled @TestVisible public List<Product2> products { get; set; }
    /**
     * @description Workbench refresh counter.
     */
    @AuraEnabled @TestVisible public Integer wbRefresh { get; set; }
    /**
     * @description Selected location display name.
     */
    @AuraEnabled @TestVisible public String locationName { get; set; }

    /**
     * @description Initializes the scheduler wrapper with empty collections and default values.
     */
    public Queue_Sch_Wrapper() {
        attachments = new List<Attachment>();
        errMsg = null;
        locationName = null;
        records = new List<Registration_SCH__c>();
        bookedAppointment = new List<Registration_SCH__c>();
        getLocation = new List<Queue__c>();
        timeSlot = new List<Integer>();
        allrecords = new List<String>();
        mapOfRecords = new Map<String, Registration_SCH__c>();
        updateMap = new Map<String, Registration_SCH__c>();
        updateStatus = false;
        wbRefresh = 0;
        updateStatusForCancel = false;
        service = '';
        floc = '';
        existLocation = false;
        allLocations = new List<Id>();
        serviceIds = new Set<Id>();
        expertIds = new Set<Id>();
        allExperts = new Set<String>();
        allServices = new Set<String>();
        allEvents = new Set<String>();
        allPrograms = new Set<String>();
        allCategories = new Set<String>();
        allCategory = new List<Queue_Sch_SelectOptions>();
        allType = new List<Queue_Sch_SelectOptions>();
        allSubType = new List<Queue_Sch_SelectOptions>();
        tokenReg = new Registration_SCH__c();
    }
}