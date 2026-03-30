/**
 * @description Response wrapper shared across queue scheduler Aura/LWC actions.
 */
// commented by abuzar on 2026-03-30 for the scanning issue and added below line "The Wrapper class is a serialized Aura/LWC transport model with many required @AuraEnabled members, which triggers the ExcessivePublicCount PMD violation."
// public with sharing class QueueExpertWrapper {
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class QueueExpertWrapper {
//changes end here by abuzar
    @AuraEnabled public List<QueueExpertSelectOptions> allCategory { get; set; }
    @AuraEnabled public List<Registration_SCH__c> records { get; set; }
    @AuraEnabled public String errorMsg { get; set; }
    @AuraEnabled public Set<String> allLocations { get; set; }
    @AuraEnabled public String locationId { get; set; }
    @AuraEnabled public Map<String, Object> mapOfRecords { get; set; }
    @AuraEnabled public String serviceId { get; set; }
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    @AuraEnabled public Boolean existLocation { get; set; }
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    @AuraEnabled public Boolean inProgress { get; set; }
    @AuraEnabled public List<Registration_SCH__c> objectValues { get; set; }
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    @AuraEnabled public Boolean updateStatus { get; set; }
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    @AuraEnabled public Boolean updateStatusForCancel { get; set; }
    @AuraEnabled public List<User> userName { get; set; }
    @AuraEnabled public List<RecordType> recordTypeName { get; set; }
    @AuraEnabled public List<Registration_SCH__c> getReschudle { get; set; }
    @AuraEnabled public String bookedTime { get; set; }
    @AuraEnabled public List<String> slots { get; set; }
    @AuraEnabled public List<DateTime> dslots { get; set; }
    @AuraEnabled public DateTime resDate { get; set; }
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    @AuraEnabled public Boolean updateTimeSlot { get; set; }
    @AuraEnabled public Date sDay { get; set; }
    @AuraEnabled public Map<Date, List<DateTime>> mapOfslots { get; set; }
    @AuraEnabled public String expertName { get; set; }
    @AuraEnabled public DateTime todaysDate { get; set; }
    @AuraEnabled public List<Registration_SCH__c> updateSlotReg { get; set; }
    @AuraEnabled public Map<Date, Map<String, String>> mapOfslots2 { get; set; }
    @AuraEnabled public List<DateTime> dateExist { get; set; }
    @AuraEnabled public Set<String> expertIds { get; set; }
    @AuraEnabled public Set<String> serviceIds { get; set; }
    @AuraEnabled public Set<String> locationIds { get; set; }
    @AuraEnabled public Set<String> programs { get; set; }
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    @AuraEnabled public Boolean dis { get; set; }
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    @AuraEnabled public Boolean disl { get; set; }
    @AuraEnabled public Set<String> allService { get; set; }
    @AuraEnabled public List<Queue__c> queue { get; set; }
    @AuraEnabled public Set<String> allresources { get; set; }
    @AuraEnabled public Set<String> allServices { get; set; }
    @AuraEnabled public List<Queue__c> getLocation { get; set; }
    @AuraEnabled public String fser { get; set; }
    @AuraEnabled public String fres { get; set; }
    @AuraEnabled public String floc { get; set; }
    @AuraEnabled public String locName { get; set; }
    @AuraEnabled public List<Attachment> attachments { get; set; }
    @AuraEnabled public List<Note> notes { get; set; }
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    @AuraEnabled public Boolean showTeam { get; set; }
    @AuraEnabled public String resName { get; set; }
    @AuraEnabled public String selectedTeamID { get; set; }
    @AuraEnabled public List<QueueExpertRecords> regRecords { get; set; }
    @AuraEnabled public String currentProgram { get; set; }
    @AuraEnabled public String errmsg { get; set; }
    @AuraEnabled public String selRG { get; set; }
    @AuraEnabled public String selRes { get; set; }
    @AuraEnabled public List<String> queueFields { get; set; }
    @AuraEnabled public List<String> appointmentFields { get; set; }
    @AuraEnabled public List<String> customerFields { get; set; }
    @AuraEnabled public List<String> meetingFields { get; set; }
    @AuraEnabled public List<String> schudlarFields { get; set; }
    @AuraEnabled public Integer wbRefresh { get; set; }
    @AuraEnabled public String selectedUserName { get; set; }
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
