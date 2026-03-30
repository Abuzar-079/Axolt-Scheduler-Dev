/**
 * @description Response wrapper shared across queue scheduler Aura/LWC actions.
 */
// commented by abuzar on 2026-03-30 for the scanning issue and added below line "The Wrapper class is a serialized Aura/LWC transport model with many required @AuraEnabled members, which triggers the ExcessivePublicCount PMD violation."
// public with sharing class QueueExpertWrapper {
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class QueueExpertWrapper {
//changes end here by abuzar
    /** @description Category options returned to the client. */
    @AuraEnabled public List<QueueExpertSelectOptions> allCategory { get; set; }
    /** @description Registration records included in the response. */
    @AuraEnabled public List<Registration_SCH__c> records { get; set; }
    /** @description Primary error message returned to the client. */
    @AuraEnabled public String errorMsg { get; set; }
    /** @description Location names available for filtering. */
    @AuraEnabled public Set<String> allLocations { get; set; }
    /** @description Selected location identifier. */
    @AuraEnabled public String locationId { get; set; }
    /** @description Generic map payload for dynamic response data. */
    @AuraEnabled public Map<String, Object> mapOfRecords { get; set; }
    /** @description Selected service identifier. */
    @AuraEnabled public String serviceId { get; set; }
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    /** @description Whether a matching location exists. */
    @AuraEnabled public Boolean existLocation { get; set; }
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    /** @description Whether the related process is currently in progress. */
    @AuraEnabled public Boolean inProgress { get; set; }
    /** @description Registration values used in update flows. */
    @AuraEnabled public List<Registration_SCH__c> objectValues { get; set; }
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    /** @description Whether a status update succeeded. */
    @AuraEnabled public Boolean updateStatus { get; set; }
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    /** @description Whether a cancellation status update succeeded. */
    @AuraEnabled public Boolean updateStatusForCancel { get; set; }
    /** @description Users returned for assignment or display. */
    @AuraEnabled public List<User> userName { get; set; }
    /** @description Record types returned for the client view. */
    @AuraEnabled public List<RecordType> recordTypeName { get; set; }
    /** @description Reschedule-related registration records. */
    @AuraEnabled public List<Registration_SCH__c> getReschudle { get; set; }
    /** @description Booked appointment time value. */
    @AuraEnabled public String bookedTime { get; set; }
    /** @description Available slot labels for scheduling. */
    @AuraEnabled public List<String> slots { get; set; }
    /** @description Available slot date-time values for scheduling. */
    @AuraEnabled public List<DateTime> dslots { get; set; }
    /** @description Selected reschedule date-time value. */
    @AuraEnabled public DateTime resDate { get; set; }
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    /** @description Whether a time slot update succeeded. */
    @AuraEnabled public Boolean updateTimeSlot { get; set; }
    /** @description Selected schedule day. */
    @AuraEnabled public Date sDay { get; set; }
    /** @description Schedule slots grouped by day. */
    @AuraEnabled public Map<Date, List<DateTime>> mapOfslots { get; set; }
    /** @description Selected or resolved expert name. */
    @AuraEnabled public String expertName { get; set; }
    /** @description Current date-time value returned to the client. */
    @AuraEnabled public DateTime todaysDate { get; set; }
    /** @description Registrations updated during slot reassignment. */
    @AuraEnabled public List<Registration_SCH__c> updateSlotReg { get; set; }
    /** @description Alternate slot mapping returned for the scheduler UI. */
    @AuraEnabled public Map<Date, Map<String, String>> mapOfslots2 { get; set; }
    /** @description Date-times that already contain bookings. */
    @AuraEnabled public List<DateTime> dateExist { get; set; }
    /** @description Expert identifiers available in the response. */
    @AuraEnabled public Set<String> expertIds { get; set; }
    /** @description Service identifiers available in the response. */
    @AuraEnabled public Set<String> serviceIds { get; set; }
    /** @description Location identifiers available in the response. */
    @AuraEnabled public Set<String> locationIds { get; set; }
    /** @description Program values available in the response. */
    @AuraEnabled public Set<String> programs { get; set; }
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    /** @description Generic disabled-state flag used by the client. */
    @AuraEnabled public Boolean dis { get; set; }
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    /** @description Secondary disabled-state flag used by the client. */
    @AuraEnabled public Boolean disl { get; set; }
    /** @description Service names available for selection. */
    @AuraEnabled public Set<String> allService { get; set; }
    /** @description Queue records returned to the client. */
    @AuraEnabled public List<Queue__c> queue { get; set; }
    /** @description Resource names available for selection. */
    @AuraEnabled public Set<String> allresources { get; set; }
    /** @description Alternate service collection returned to the client. */
    @AuraEnabled public Set<String> allServices { get; set; }
    /** @description Queue records used for location selection. */
    @AuraEnabled public List<Queue__c> getLocation { get; set; }
    /** @description Selected filter service value. */
    @AuraEnabled public String fser { get; set; }
    /** @description Selected filter resource value. */
    @AuraEnabled public String fres { get; set; }
    /** @description Selected filter location value. */
    @AuraEnabled public String floc { get; set; }
    /** @description Selected location display name. */
    @AuraEnabled public String locName { get; set; }
    /** @description Attachments associated with the current registration. */
    @AuraEnabled public List<Attachment> attachments { get; set; }
    /** @description Notes associated with the current registration. */
    @AuraEnabled public List<Note> notes { get; set; }
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    /** @description Whether team-related UI should be displayed. */
    @AuraEnabled public Boolean showTeam { get; set; }
    /** @description Selected resource display name. */
    @AuraEnabled public String resName { get; set; }
    /** @description Selected team identifier. */
    @AuraEnabled public String selectedTeamID { get; set; }
    /** @description Queue expert record wrappers returned to the client. */
    @AuraEnabled public List<QueueExpertRecords> regRecords { get; set; }
    /** @description Currently selected program. */
    @AuraEnabled public String currentProgram { get; set; }
    /** @description Secondary error message value returned to the client. */
    @AuraEnabled public String errmsg { get; set; }
    /** @description Selected registration-group value. */
    @AuraEnabled public String selRG { get; set; }
    /** @description Selected resource value. */
    @AuraEnabled public String selRes { get; set; }
    /** @description Queue field labels or values returned to the client. */
    @AuraEnabled public List<String> queueFields { get; set; }
    /** @description Appointment field labels or values returned to the client. */
    @AuraEnabled public List<String> appointmentFields { get; set; }
    /** @description Customer field labels or values returned to the client. */
    @AuraEnabled public List<String> customerFields { get; set; }
    /** @description Meeting field labels or values returned to the client. */
    @AuraEnabled public List<String> meetingFields { get; set; }
    /** @description Scheduler field labels or values returned to the client. */
    @AuraEnabled public List<String> schudlarFields { get; set; }
    /** @description Workbench refresh counter. */
    @AuraEnabled public Integer wbRefresh { get; set; }
    /** @description Selected user display name. */
    @AuraEnabled public String selectedUserName { get; set; }
    /** @description Appointment filter label used by the client. */
    @AuraEnabled public String appointmentFiler { get; set; }

    /**
     * @description Initializes the wrapper with default collection and flag values.
     */
    public QueueExpertWrapper() {
        queueFields = new List<String>();
        appointmentFields = new List<String>();
        customerFields = new List<String>();
        meetingFields = new List<String>();
        schudlarFields = new List<String>();
        allService = new Set<String>();
        queue = new List<Queue__c>();
        allresources = new Set<String>();
        allServices = new Set<String>();
        getLocation = new List<Queue__c>();
        attachments = new List<Attachment>();
        notes = new List<Note>();
        showTeam = false;
        allCategory = new List<QueueExpertSelectOptions>();
        selectedUserName = '';
        appointmentFiler = 'Todays Appointments';
        dateExist = new List<DateTime>();
        expertIds = new Set<String>();
        serviceIds = new Set<String>();
        locationIds = new Set<String>();
        programs = new Set<String>();
        dis = false;
        disl = false;
        objectValues = new List<Registration_SCH__c>();
        records = new List<Registration_SCH__c>();
        regRecords = new List<QueueExpertRecords>();
        mapOfRecords = new Map<String, Object>();
        userName = new List<User>();
        recordTypeName = new List<RecordType>();
        existLocation = false;
        inProgress = false;
        updateStatus = false;
        updateStatusForCancel = false;
    }
}
