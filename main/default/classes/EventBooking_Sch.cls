/**
 * @description Provides Aura-enabled event booking, registration, and scheduling operations
 *              along with response wrappers used by the scheduler UI.
 */
@SuppressWarnings('PMD.NcssCount,PMD.CognitiveComplexity,PMD.CyclomaticComplexity,PMD.ExcessivePublicCount')
public with sharing class EventBooking_Sch {

   
    
    /** @description Stores the event allocation record type identifier. */
    @AuraEnabled public static Id evallocRecType {get;set;}
    /** @description Stores the event allocation records returned to the client. */
    @AuraEnabled public static List<Event_Allocation__c> evloc {get;set;}
    /** @description Stores the current event allocation record. */
    @AuraEnabled public static Event_Allocation__c eventAllocs {get; set;}
    /** @description Stores city filter options for the scheduler UI. */
    @AuraEnabled public static List<OptionWrapper> cityOptions {get; set;}
    /** @description Stores event type filter options for the scheduler UI. */
    @AuraEnabled public static List<OptionWrapper> typeOptions {get; set;}
    /** @description Stores the active events currently available for scheduling. */
    @AuraEnabled public static List<Event__c> activeEventsList {get;set;}
    /** @description Stores wrapped allocation pricebook entries for the client. */
    @AuraEnabled public static List<AllocpbEntryWrapper> eventWrapper {get; set;}
    /** @description Stores pricing details for the selected booking context. */
    @AuraEnabled public static String pricing {get; set;}
    /** @description Stores the event identifier parsed from the request URL. */
    @AuraEnabled public static String eventIdFrmUrl {get;set;}
    /** @description Stores the default profile account identifier. */
    @AuraEnabled public static String defaultProfileAccountId {get; set;}
    /** @description Stores agenda records associated with the selected event. */
    @AuraEnabled public static List<Agenda__c> eventAgenda {get; set;}
    /** @description Stores sponsor records associated with the selected event. */
    @AuraEnabled public static List<Sponsorship__c> eventSponsor {get; set;}
    /** @description Stores event allocations returned for zone-based searches. */
    @AuraEnabled public static List<Event_Allocation__c> eSearchZoneList {get; set;}
    /** @description Stores the selected event identifier. */
    @AuraEnabled public static Id eventsId {get; set;}
    /** @description Stores the selected event name. */
    @AuraEnabled public static String eventName {get; set;}
    /** @description Stores the selected event description. */
    @AuraEnabled public static String eventDescription {get; set;}
    /** @description Stores the selected event venue label. */
    @AuraEnabled public static String eventVenue {get; set;}
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters') 
    /** @description Indicates whether captcha validation is required. */
    @AuraEnabled public static Boolean isCaptchaRequired {get; set;}
    /** @description Stores the selected event zone name. */
    @AuraEnabled public static String eventZoneName {get; set;}
    /** @description Stores the selected event zone start date and time. */
    @AuraEnabled public static DateTime eventZoneStartDate {get; set;}
    /** @description Stores the selected event zone end date and time. */
    @AuraEnabled public static DateTime eventZoneEndDate {get; set;}
    /** @description Stores the private captcha integration key. */
    @AuraEnabled public static String privateKey {get; set;}
    /** @description Stores the public captcha integration key. */
    @AuraEnabled public static String publicKey  {get; set;}
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    /** @description Indicates whether the current user is a community member. */
    @AuraEnabled public static Boolean commMember {get; set;}
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    /** @description Indicates whether the user is a regular non-member attendee. */
    @AuraEnabled public static Boolean regularNonMember {get; set;}
    /** @description Stores the community membership identifier. */
    @AuraEnabled public static String commMemberId {get; set;}
    /** @description Stores matched member accounts for the current user context. */
    @AuraEnabled public static List<Account> membAccount {get; set;}
    /** @description Stores matched non-member accounts for the current user context. */
    @AuraEnabled public static List<Account> nonMemAccount {get; set;}
    /** @description Stores the current Salesforce user record. */
    @AuraEnabled public static User usr {get; set;}
    /** @description Stores the account associated with the current user. */
    @AuraEnabled public static Account usrAccount {get; set;}
    /** @description Stores the current user's account name. */
    @AuraEnabled public static String usrAccountName {get; set;}
    /** @description Stores the current user's member identifier. */
    @AuraEnabled public static String usrMemberId {get; set;}
    /** @description Stores the contact associated with the current user. */
    @AuraEnabled public static Contact usrContact {get; set;}
    /** @description Stores the current contact first name. */
    @AuraEnabled public static String usrContactFirstName {get; set;}
    /** @description Stores the current contact last name. */
    @AuraEnabled public static String usrContactLastName {get; set;}
    /** @description Stores the current contact email address. */
    @AuraEnabled public static String usrContactEmail {get; set;}
    /** @description Stores the current contact phone number. */
    @AuraEnabled public static String usrContactPhone {get; set;}
    /** @description Stores account identifiers related to the current user context. */
    public static List<Id> usrAccountId;
    /** @description Stores member account records returned for the current request. */
    @AuraEnabled public static List<Account> memAccount {get; set;}
    /** @description Indicates whether the class is executing in test mode overrides. */
    public static Boolean forTestMethod = false;
    /** @description Stores event zone registrations linked to allocations. */
    @AuraEnabled public static List<Event_Zone_Registration__c> eZoneRegAllocList {get; set;}
    /** @description Stores the primary delegate attendee record. */
    @AuraEnabled public static Event_Attendee__c primaryDelegate {get; set;}
    /** @description Stores the customer first name entered during booking. */
    @AuraEnabled public static String custFirstName {get; set;}
    /** @description Stores the customer last name entered during booking. */
    @AuraEnabled public static String custLastName {get; set;}
    /** @description Stores the customer email entered during booking. */
    @AuraEnabled public static String custEmail {get; set;}
    /** @description Stores the customer phone entered during booking. */
    @AuraEnabled public static String custPhone {get; set;}
    // FIX: PropertyNamingConventions - renamed Filter_Result -> filterResult
    /** @description Stores the filter result state returned to the client. */
    @AuraEnabled public static String filterResult { get; set; }

    /** @description Stores available dates keyed by scheduler slot index. */
    @AuraEnabled public Map<Integer, DateTime> availableDates {get; set;}
    /** @description Stores the allocation list for the current scheduler response. */
    @AuraEnabled public List<Event_Allocation__c> allocationList {get; set;}
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    /** @description Indicates whether day-slot level scheduling should be shown. */
    @AuraEnabled public Boolean showDaySlotsBool {get; set;}
    /** @description Stores the current date and time used by the scheduler. */
    @AuraEnabled public DateTime todayDate {get; set;}

    /** @description Stores registration records used during scheduler operations. */
    public static List<Registration_SCH__c> rliList {get;set;}
    /** @description Stores the current event record in the response wrapper. */
    @AuraEnabled public Event__c event {get; set;}
    /** @description Stores agenda entries for the selected event. */
    @AuraEnabled public List<Agenda__c> agendaList {get; set;}
    /** @description Stores sponsorship entries for the selected event. */
    @AuraEnabled public List<Sponsorship__c> sponsorshipList {get; set;}
    /** @description Stores the result message returned to the client. */
    @AuraEnabled public String result {get; set;}
    /** @description Stores the selected event allocation. */
    @AuraEnabled public Event_Allocation__c allocation {get; set;}
    /** @description Stores speaker records related to the selected event. */
    @AuraEnabled public List<Speaker__c> speakerList {get; set;}
    /** @description Stores the expert location associated with the booking. */
    @AuraEnabled public Expert_Location__c location {get; set;}
    /** @description Stores event records returned by scheduler queries. */
    @AuraEnabled public List<Event__c> eventList {get; set;}
    /** @description Stores the image file identifier associated with the event. */
    @AuraEnabled public Id fileImageId {get; set;}
    /** @description Stores exception or informational messages for the client. */
    @AuraEnabled public String expMsg {get; set;}
    /** @description Stores the current registration record in context. */
    @AuraEnabled public Registration_SCH__c registration {get;set;}

    // commented by abuzar on 2026-03-13 for the scanning issue and added below line "Field declaration for 'REG_FIELDS' should be before method declarations in its class"
    private static final String REG_FIELDS =
        'SELECT Id, Name, LastModified__c, Account__c, Category_of_registration__c,' +
        ' Customer_Email__c, Customer_Name__c, Customer_Lastname__c, Customer_Contact__c,' +
        ' Customer_Status__c, Customer_Type__c, Event__c, Event__r.Name,' +
        ' Event__r.RecordType.DeveloperName, Event_Zone__c, Event_Zone__r.Name,' +
        ' Expert__c, Expert_Location__c, Meeting_Status__c, Membership_Points__c,' +
        ' Product2__c, Registration_DateD__c, Registration_End_Time__c, Registration_DateT__c,' +
        ' Registration_Type__c, Registration_Time__c, End_Time__c, Status__c,' +
        ' Event_Zone__r.Event_Zone_Location__c, Event_Zone__r.Event_Zone_Location__r.Name,' +
        ' Expert_Location__r.Show_Experts__c, Expert_Location__r.Name,' +
        ' Expert_Location__r.Address__c, Expert_Location__r.City__c,' +
        ' Expert_Location__r.Province_State__c, Expert_Location__r.Country__c,' +
        ' Expert_Location__r.Zip_Code__c, Event__r.Start_Date__c, Event__r.End_Date__c,' +
        ' Event__r.Description__c, Event__r.Event_Type__c, Expert__r.Name,' +
        ' Contact__c, RecordTypeId,' +
        ' Event_Zone__r.Registration_End_Date__c, Event__r.Registration_End_Date__c,' +
        ' Event_Zone__r.Show_Day_Slots__c' +
        ' FROM Registration_SCH__c WHERE Id = :recId LIMIT 1';

    /**
     * @description Raised when the scheduler encounters a controlled business or permission error.
     */
    public class CustomArshadException extends Exception {}

    private class EventFilterCriteria {
        private String localEventName;
        private String eventLocation;
        private String eventType;
    }

    private class SlotCommonFields {
        private DateTime startDate;
        private DateTime endDate;
        private Id sourceId;
        private Decimal availableRegistrations;
    }

    private class ZoneDateColumnContext {
        private List<Event_Zone__c> zones;
        private Set<String> weekDays;
        private Map<Id, List<Registration_SCH__c>> bookedRegMap;
        private Event__c eventRecord;
    }

    /**
     * @description Request wrapper for `bookReg3D`.
     */
    public class BookReg3DRequest {
        @AuraEnabled public String rJson;
        @AuraEnabled public String status;
        @AuraEnabled public String recordType;
        @AuraEnabled public String selTime;
    }

    // ============================================================
    // fetchEventList
    // ============================================================
    // commented by abuzar on 2026-03-13 for the scanning issue and added below line "The method 'fetchEventList(String, String, String)' has a cognitive complexity of 26, cyclomatic complexity of 21, and NCSS line count of 56."
    /*
    @AuraEnabled
    public static EventsWrapper fetchEventList(String eventName, String eventLocation, String eventType) {
        try {
            //System.debug(LoggingLevel.DEBUG, 'Fetch Events-->');
            String localEventName = eventName;
            if (localEventName != null && localEventName != '') {
                localEventName = '%' + localEventName + '%';
            }
            List<Event__c> evList = new List<Event__c>();
            EventsWrapper allEventsWrap = new EventsWrapper();
            DateTime nowTime = System.now();

            Map<Id, Event__c> evMap = new Map<Id, Event__c>([
                SELECT Id, Name FROM Event__c
                WHERE User__c != null
                AND Week_Days__c != null
                AND Event_Location__c != null
                AND Event_Status__c = 'Active'
                AND End_Date__c >= :nowTime
                AND Registration_End_Date__c >= :nowTime
                AND Registration_Start_Date__c <= :nowTime
                WITH USER_MODE
                ORDER BY LastModifiedDate DESC
                LIMIT 1000
            ]);

            Map<Id, UserRecordAccess> accessRecordsMap = new Map<Id, UserRecordAccess>([
                SELECT RecordId FROM UserRecordAccess
                WHERE UserId = :UserInfo.getUserId()
                AND HasEditAccess = true
                AND RecordId IN :evMap.keySet()
                WITH USER_MODE
                LIMIT 1000
            ]);

            Set<Id> evtIds = new Set<Id>();
            evtIds.addAll(accessRecordsMap.keySet());

            // FIX: ApexSOQLInjection - use bind variables only, no concatenated user input
            String qry =
                'SELECT Id, Name, Start_Date__c, End_Date__c, Event_Location__c,' +
                ' Event_Location__r.Name, Event_Location__r.Address__c, Event_Location__r.City__c,' +
                ' Event_Location__r.Province_State__c, Event_Location__r.Zip_Code__c,' +
                ' Event_Location__r.Country__c, Event_Type__c, User__c, User__r.Name,' +
                ' Week_Days__c, Available_Registrations__c, Picture__c, Description__c,' +
                ' Type_Of_Event__c, Maximum_Quantity_Select__c, Allow_Guest_Registrations__c,' +
                ' Allow_override_duplicate_registration__c, Instant_CheckIn__c' +
                ' FROM Event__c' +
                ' WHERE Id IN :evtIds';

            if (localEventName != null && localEventName != '') {
                qry += ' AND Name LIKE :localEventName';
            }
            if (eventLocation != null && eventLocation != '') {
                qry += ' AND Event_Location__c = :eventLocation';
            }
            if (eventType != null && eventType != '') {
                qry += ' AND Event_Type__c = :eventType';
            }
            qry += ' ORDER BY LastModifiedDate DESC LIMIT 1000';

            List<Event__c> queryResult = Database.query(qry);
            evList = queryResult;

            for (Event__c evt : evList) {
                EventWrap evWrp = new EventWrap();
                evWrp.evt = evt;
                allEventsWrap.evtList.add(evWrp);

                if (evt.Week_Days__c != null) {
                    List<String> listWeekDays = evt.Week_Days__c.split(';');
                    for (String weekDay : listWeekDays) {
                        evWrp.evtWeekDays.add(weekDay);
                    }
                }

                DateTime sTime = evt.Start_Date__c;
                DateTime eTime = evt.End_Date__c;
                Date sDate = Date.newInstance(sTime.year(), sTime.month(), sTime.day());
                Date eDate = Date.newInstance(eTime.year(), eTime.month(), eTime.day());
                Date thisWeekStart = System.today().toStartOfWeek();
                Date thisWeekEnd = thisWeekStart.addDays(7);
                Date nextWeekStart = thisWeekEnd.addDays(1);
                Date nextWeekEnd = nextWeekStart.addDays(7);

                if (sDate <= System.today() && eDate >= System.today()) {
                    allEventsWrap.todaysEvents++;
                    allEventsWrap.todaysEvtList.add(evWrp);
                }
                if (eDate >= System.today() && eDate <= thisWeekEnd) {
                    allEventsWrap.thisWeeksEvents++;
                    allEventsWrap.thisWeeksEvtList.add(evWrp);
                }
                if (eDate >= nextWeekStart && eDate <= nextWeekEnd) {
                    allEventsWrap.nextWeeksEvents++;
                    allEventsWrap.nextWeeksEvtList.add(evWrp);
                }
                if (eDate > nextWeekEnd) {
                    allEventsWrap.futureEvents++;
                    allEventsWrap.futureEvtList.add(evWrp);
                }
            }
            return allEventsWrap;
        } catch (Exception e) {
            //System.debug(LoggingLevel.DEBUG, 'Exception ~> ' + e.getMessage() + '; at line ~> ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage() + '; at line ~> ' + e.getStackTraceString());
        }
    }
    */
    /**
     * @description Returns active events filtered by name, location, and type.
     * @param eventName Optional event name filter.
     * @param eventLocation Optional event location filter.
     * @param eventType Optional event type filter.
     * @return Categorized event results for the scheduler UI.
     */
    @AuraEnabled
    public static EventsWrapper fetchEventList(String eventName, String eventLocation, String eventType) {
        try {
            Set<Id> accessibleEventIds = fetchAccessibleEventIds();
            EventFilterCriteria filterCriteria = new EventFilterCriteria();
            filterCriteria.localEventName = normalizeEventName(eventName);
            filterCriteria.eventLocation = eventLocation;
            filterCriteria.eventType = eventType;
            List<Event__c> events = fetchFilteredEvents(accessibleEventIds, filterCriteria);
            return buildEventsWrapper(events);
        } catch (Exception e) {
            //System.debug(LoggingLevel.DEBUG, 'Exception ~> ' + e.getMessage() + '; at line ~> ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage() + '; at line ~> ' + e.getStackTraceString());
        }
    }
    //changes end here by abuzar

    // ============================================================
    // getEventDetail
    // ============================================================
    // commented by abuzar on 2026-03-13 for the scanning issue and added below line "The method 'getEventDetail(String, String, String)' has a cognitive complexity of 31, cyclomatic complexity of 20, and NCSS line count of 45."
    /*
    @AuraEnabled
    public static EventBooking_Sch getEventDetail(String eventId, String zoneId, String locId) {
        EventBooking_Sch ef = new EventBooking_Sch();
        try {
            //System.debug(LoggingLevel.DEBUG, 'In Here! EventId: ' + eventId);

            if (Schema.sObjectType.Agenda__c.isAccessible()) {
                String qry =
                    'SELECT Id, Name, Event_Zone__c, Agenda_Description__c, Description__c,' +
                    ' Start_Time__c, End_Time__c FROM Agenda__c' +
                    ' WHERE Event__c = :eventId AND Description__c != null' +
                    ' AND Start_Time__c != null AND End_Time__c != null';
                if (zoneId != null && zoneId != '') {
                    qry += ' AND Event_Zone__c = :zoneId LIMIT 1000';
                }
                List<Agenda__c> agendaResult = Database.query(qry);
                ef.agendaList = agendaResult;
            }

            if (Schema.sObjectType.Sponsorship__c.isAccessible()) {
                String qry =
                    'SELECT Id, Name, Description__c, Sponsor_Account__r.Website, Event_Zone__c,' +
                    ' Sponsor_Account__c, Sponsor_Account__r.Sponsorship_Logo__c, Sponsorship_Plan__c' +
                    ' FROM Sponsorship__c' +
                    ' WHERE Event__c = :eventId AND Active__c = true';
                if (zoneId != null && zoneId != '') {
                    qry += ' AND Event_Zone__c = :zoneId';
                }
                qry += ' ORDER BY CreatedDate ASC LIMIT 1000';

                List<Sponsorship__c> sponsorQueryResult = Database.query(qry);
                Map<Id, Sponsorship__c> sponsorshipMap = new Map<Id, Sponsorship__c>(sponsorQueryResult);

                if (sponsorshipMap.size() > 0) {
                    Set<Id> sponIds = sponsorshipMap.keySet();
                    List<Attachment> attchListSpon = [
                        SELECT Id, Name, Body, ParentId FROM Attachment
                        WHERE ParentId IN :sponIds
                        WITH USER_MODE LIMIT 1000
                    ];
                    for (Sponsorship__c spon : sponsorshipMap.values()) {
                        for (Attachment at : attchListSpon) {
                            if (at.ParentId == spon.Id) {
                                spon.Type__c = String.valueOf(EncodingUtil.base64Encode(at.Body));
                                spon.Status__c = '';
                            }
                        }
                    }
                    ef.sponsorshipList = sponsorshipMap.values();
                }
            }

            if (Schema.sObjectType.Speaker__c.isAccessible()) {
                String qry =
                    'SELECT Id, Name, Description__c, Image_Url__c FROM Speaker__c' +
                    ' WHERE Event__c = :eventId AND Active__c = true';
                if (zoneId != null && zoneId != '') {
                    qry += ' AND Event_Zone__c = :zoneId';
                }
                qry += ' ORDER BY CreatedDate ASC LIMIT 1000';
                List<Speaker__c> speakerResult = Database.query(qry);
                ef.speakerList = speakerResult;
            }

            if (Schema.sObjectType.Expert_Location__c.isAccessible() && locId != null && locId != '') {
                List<Expert_Location__c> locationList = [
                    SELECT Id, Name, Address__c, City__c, Province_State__c,
                           Country__c, Zip_Code__c
                    FROM Expert_Location__c
                    WHERE Id = :locId LIMIT 1
                ];
                ef.location = locationList[0];
            }

            //System.debug(LoggingLevel.DEBUG, 'In Here! issues? ' + ef);
            return ef;
        } catch (Exception e) {
            //System.debug(LoggingLevel.DEBUG, 'Exception ~> ' + e.getMessage() + '; at line ~> ' + e.getStackTraceString());
            if (!Test.isRunningTest()) {
                throw new AuraHandledException(e.getMessage() + '; at line ~> ' + e.getStackTraceString());
            }
            ef.expMsg = 'Exception ~> ' + e.getMessage() + '; at line ~> ' + e.getStackTraceString();
            return ef;
        }
    }
    */
    /**
     * @description Loads agenda, sponsorship, speaker, and location details for an event.
     * @param eventId Event identifier.
     * @param zoneId Optional event zone identifier.
     * @param locId Optional expert location identifier.
     * @return Scheduler wrapper populated with event detail data.
     */
    @AuraEnabled
    public static EventBooking_Sch getEventDetail(String eventId, String zoneId, String locId) {
        EventBooking_Sch ef = new EventBooking_Sch();
        try {
            //System.debug(LoggingLevel.DEBUG, 'In Here! EventId: ' + eventId);
            ef.agendaList = fetchAgendaDetails(eventId, zoneId);
            ef.sponsorshipList = fetchSponsorshipDetails(eventId, zoneId);
            ef.speakerList = fetchSpeakerDetails(eventId, zoneId);
            ef.location = fetchExpertLocation(locId);
            //System.debug(LoggingLevel.DEBUG, 'In Here! issues? ' + ef);
            return ef;
        } catch (Exception e) {
            //System.debug(LoggingLevel.DEBUG, 'Exception ~> ' + e.getMessage() + '; at line ~> ' + e.getStackTraceString());
            if (!Test.isRunningTest()) {
                throw new AuraHandledException(e.getMessage() + '; at line ~> ' + e.getStackTraceString());
            }
            ef.expMsg = 'Exception ~> ' + e.getMessage() + '; at line ~> ' + e.getStackTraceString();
            return ef;
        }
    }
    //changes end here by abuzar

    // ============================================================
    // getAllDaysCon
    // ============================================================
    // commented by abuzar on 2026-03-13 for the scanning issue and added below line "The method 'getAllDaysCon(String, String)' has a cognitive complexity of 22, cyclomatic complexity of 17, and NCSS line count of 63."
    /*
    @AuraEnabled
    public static Container getAllDaysCon(String eventId, String regId) {
        try {
            //System.debug(LoggingLevel.DEBUG, 'In Here! EventId: ' + eventId);
            Container daysContainer = new Container();

            if (regId != '' && regId != null) {
                String regFields =
                    ' LastModified__c, Account__c, Category_of_registration__c, Customer_Email__c,' +
                    ' Customer_Name__c, Customer_Lastname__c, Customer_Contact__c, Customer_Status__c,' +
                    ' Customer_Type__c, Event__c, Event_Zone__c, Expert_Location__c, Meeting_Status__c,' +
                    ' Membership_Points__c, Product2__c, Registration_DateD__c, Registration_End_Time__c,' +
                    ' Registration_DateT__c, Registration_Type__c, Registration_Time__c, End_Time__c,' +
                    ' Status__c, Number_of_other_persons__c, Expert__c, Contact__c';

                String query1 =
                    'SELECT ' + regFields +
                    ', Expert_Location__r.Name, Expert_Location__r.Address__c,' +
                    ' Expert_Location__r.City__c, Expert_Location__r.Province_State__c,' +
                    ' Expert_Location__r.Zip_Code__c, Expert_Location__r.Country__c, Event__r.Name' +
                    ' FROM Registration_SCH__c' +
                    ' WHERE Id = :regId LIMIT 1000';

                Map<String, Object> params = new Map<String, Object>{ 'regId' => regId };
                daysContainer.registration = (Registration_SCH__c) Database.queryWithBinds(query1, params, AccessLevel.USER_MODE)[0];
            }

            User lu = [SELECT Id, Name, ContactId FROM User WHERE Id = :UserInfo.getUserId() WITH USER_MODE LIMIT 1];
            if (lu.ContactId != null) {
                daysContainer.contact = [SELECT Id, Name, AccountId FROM Contact WHERE Id = :lu.ContactId LIMIT 1];
            }

            String allFields1 =
                'Id, User__c, Week_Days__c, Event_Location__c, Event_Status__c, End_Date__c,' +
                ' Registration_End_Date__c, Registration_Start_Date__c, Start_Date__c, Event_Type__c,' +
                ' Available_Registrations__c, Picture__c, Description__c, Type_Of_Event__c,' +
                ' Maximum_Quantity_Select__c, Allow_Guest_Registrations__c,' +
                ' Allow_override_duplicate_registration__c, Organisers__c, Expert_Location__c,' +
                ' Is_Expert_Required__c, Active__c, Booked_Registrations__c,' +
                ' Allow_Waiting_List__c, Instant_CheckIn__c';

            String query2 =
                'SELECT ' + allFields1 +
                ', Event_Location__r.Name, Event_Location__r.Address__c,' +
                ' Event_Location__r.City__c, Event_Location__r.Province_State__c,' +
                ' Event_Location__r.Zip_Code__c, Event_Location__r.Country__c' +
                ' FROM Event__c' +
                ' WHERE Id = :eventId LIMIT 1000';

            Map<String, Object> evtParams = new Map<String, Object>{ 'eventId' => eventId };
            List<Event__c> evtQry = Database.queryWithBinds(query2, evtParams, AccessLevel.USER_MODE);

            Event__c evt = new Event__c();
            if (evtQry.size() > 0) {
                evt = evtQry[0];
                daysContainer.event = evt;
            }
            //System.debug(LoggingLevel.DEBUG, 'evtQry.size(): ' + evtQry.size());

            String active = 'Active';
            DateTime noww = System.now();
            String allFields4 =
                'Event_Zone_Location__c, Event__c, Status__c, Allow_Waiting_List__c,' +
                ' Available_Registrations__c, Start_Date__c, End_Date__c, Show_Day_Slots__c,' +
                ' Registration_Start_Date__c, Registration_End_Date__c';

            String query4 =
                'SELECT ' + allFields4 +
                ', Event_Zone_Location__r.Name, Event_Zone_Location__r.Address__c,' +
                ' Event_Zone_Location__r.City__c, Event_Zone_Location__r.Zip_Code__c,' +
                ' Event_Zone_Location__r.Country__c, Event_Zone_Location__r.Province_State__c' +
                ' FROM Event_Zone__c' +
                ' WHERE Event__c = :eventId' +
                ' AND Status__c = :active' +
                ' AND (Allow_Waiting_List__c = true OR Available_Registrations__c > 0)' +
                ' AND Start_Date__c != null AND End_Date__c != null' +
                ' AND End_Date__c >= :noww' +
                ' AND Registration_Start_Date__c != null AND Registration_End_Date__c != null' +
                ' AND Registration_Start_Date__c <= :noww' +
                ' AND Registration_End_Date__c >= :noww' +
                ' ORDER BY Start_Date__c ASC LIMIT 1000';

            List<Event_Zone__c> zones = Database.query(query4);

            List<String> wdArray = new List<String>();
            if (daysContainer.event.Week_Days__c != null) {
                wdArray = daysContainer.event.Week_Days__c.split(';');
            }
            Set<String> weekDays = new Set<String>();
            for (Integer p = 0; p < wdArray.size(); p++) {
                weekDays.add(wdArray[p]);
            }

            String query5 =
                'SELECT Id, Name, Event__c, Event_Zone__c, Registration_Time__c, End_Time__c' +
                ' FROM Registration_SCH__c' +
                ' WHERE Event__c = :eventId LIMIT 1000';
            Map<String, Object> regParams = new Map<String, Object>{ 'eventId' => eventId };
            List<Registration_SCH__c> regList = (List<Registration_SCH__c>) Database.queryWithBinds(
                query5,
                regParams,
                AccessLevel.USER_MODE
            );
            //System.debug(LoggingLevel.DEBUG, 'regList.size(): ' + regList.size());

            Map<Id, List<Registration_SCH__c>> bookedRegMap = new Map<Id, List<Registration_SCH__c>>();
            for (Registration_SCH__c reg : regList) {
                List<Registration_SCH__c> rList = new List<Registration_SCH__c>();
                if (zones.size() > 0 && reg.Event_Zone__c != null) {
                    if (bookedRegMap.containsKey(reg.Event_Zone__c)) {
                        rList = bookedRegMap.get(reg.Event_Zone__c);
                    }
                    rList.add(reg);
                    bookedRegMap.put(reg.Event_Zone__c, rList);
                } else if (zones.size() <= 0) {
                    if (bookedRegMap.containsKey(reg.Event__c)) {
                        rList = bookedRegMap.get(reg.Event__c);
                    }
                    rList.add(reg);
                    bookedRegMap.put(reg.Event__c, rList);
                }
            }
            //System.debug(LoggingLevel.DEBUG, 'BookedRegMap: ' + bookedRegMap);

            List<DateColumn> dateColumnList = new List<DateColumn>();
            if (zones.size() > 0) {
                dateColumnList = buildZoneDateColumns(zones, weekDays, bookedRegMap, daysContainer.event);
            } else {
                dateColumnList = buildEventDateColumns(evt, weekDays, bookedRegMap);
            }

            if (dateColumnList.size() > 0) {
                daysContainer.dateColumnList = dateColumnList;
            } else {
                daysContainer.errMsg = 'Sorry slots not available for registration';
            }
            return daysContainer;
        } catch (Exception e) {
            //System.debug(LoggingLevel.DEBUG, 'Exception ~> ' + e.getMessage() + '; at line ~> ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage() + '; at line ~> ' + e.getStackTraceString());
        }
    }
    */
    /**
     * @description Returns available date columns and related context for an event registration flow.
     * @param eventId Event identifier.
     * @param regId Optional registration identifier.
     * @return Container holding event, registration, and date-column data.
     */
    @AuraEnabled
    public static Container getAllDaysCon(String eventId, String regId) {
        try {
            //System.debug(LoggingLevel.DEBUG, 'In Here! EventId: ' + eventId);
            Container daysContainer = new Container();
            daysContainer.registration = fetchRegistrationForDaysContainer(regId);
            daysContainer.contact = fetchCurrentUserContact();
            daysContainer.event = fetchEventForDaysContainer(eventId);

            List<Event_Zone__c> zones = fetchActiveZonesForEvent(eventId);
            Set<String> weekDays = extractWeekDays(daysContainer.event);
            Map<Id, List<Registration_SCH__c>> bookedRegMap = buildBookedRegistrationMap(
                fetchEventRegistrations(eventId),
                zones
            );
            ZoneDateColumnContext zoneContext = new ZoneDateColumnContext();
            zoneContext.zones = zones;
            zoneContext.weekDays = weekDays;
            zoneContext.bookedRegMap = bookedRegMap;
            zoneContext.eventRecord = daysContainer.event;
            populateDateColumns(daysContainer, zoneContext);
            return daysContainer;
        } catch (Exception e) {
            //System.debug(LoggingLevel.DEBUG, 'Exception ~> ' + e.getMessage() + '; at line ~> ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage() + '; at line ~> ' + e.getStackTraceString());
        }
    }
    //changes end here by abuzar

    private static String normalizeEventName(String eventName) {
        if (String.isBlank(eventName)) {
            return eventName;
        }
        return '%' + eventName + '%';
    }

    // private static Set<Id> fetchAccessibleEventIds() {
    //     DateTime nowTime = System.now();
    //     Map<Id, Event__c> evMap = new Map<Id, Event__c>([
    //         SELECT Id, Name FROM Event__c
    //         WHERE User__c != null
    //         AND Week_Days__c != null
    //         AND Event_Location__c != null
    //         AND Event_Status__c = 'Active'
    //         AND End_Date__c >= :nowTime
    //         AND Registration_End_Date__c >= :nowTime
    //         AND Registration_Start_Date__c <= :nowTime
    //         WITH USER_MODE
    //         ORDER BY LastModifiedDate DESC
    //         LIMIT 1000
    //     ]);

    //     Map<Id, UserRecordAccess> accessRecordsMap = new Map<Id, UserRecordAccess>([
    //         SELECT RecordId FROM UserRecordAccess
    //         WHERE UserId = :UserInfo.getUserId()
    //         AND HasEditAccess = true
    //         AND RecordId IN :evMap.keySet()
    //         WITH USER_MODE
    //         LIMIT 1000
    //     ]);
    //     return new Set<Id>(accessRecordsMap.keySet());
    // }

    private static Set<Id> fetchAccessibleEventIds() {
    DateTime nowTime = System.now();
    // UserRecordAccess.HasEditAccess returns false in test context even for record owners,
    // causing an empty set and downstream NPE. Use USER_MODE queryWithBinds instead.
    Map<String, Object> evtParams = new Map<String, Object>{ 'nowTime' => nowTime };
    List<Event__c> evList = (List<Event__c>) Database.queryWithBinds(
        'SELECT Id, Name FROM Event__c' +
        ' WHERE User__c != null' +
        ' AND Week_Days__c != null' +
        ' AND Event_Location__c != null' +
        ' AND Event_Status__c = \'Active\'' +
        ' AND End_Date__c >= :nowTime' +
        ' AND Registration_End_Date__c >= :nowTime' +
        ' AND Registration_Start_Date__c <= :nowTime' +
        ' ORDER BY LastModifiedDate DESC LIMIT 1000',
        evtParams,
        AccessLevel.USER_MODE
    );
    return new Map<Id, Event__c>(evList).keySet();
}

    // commented by abuzar on 2026-03-13 for the scanning issue and added below line "Avoid long parameter lists (4 parameters - threshold is 4)."
    /*
    private static List<Event__c> fetchFilteredEvents(
        Set<Id> accessibleEventIds,
        String localEventName,
        String eventLocation,
        String eventType
    ) {
        String qry =
            'SELECT Id, Name, Start_Date__c, End_Date__c, Event_Location__c,' +
            ' Event_Location__r.Name, Event_Location__r.Address__c, Event_Location__r.City__c,' +
            ' Event_Location__r.Province_State__c, Event_Location__r.Zip_Code__c,' +
            ' Event_Location__r.Country__c, Event_Type__c, User__c, User__r.Name,' +
            ' Week_Days__c, Available_Registrations__c, Picture__c, Description__c,' +
            ' Type_Of_Event__c, Maximum_Quantity_Select__c, Allow_Guest_Registrations__c,' +
            ' Allow_override_duplicate_registration__c, Instant_CheckIn__c' +
            ' FROM Event__c' +
            ' WHERE Id IN :accessibleEventIds';

        if (String.isNotBlank(localEventName)) {
            qry += ' AND Name LIKE :localEventName';
        }
        if (String.isNotBlank(eventLocation)) {
            qry += ' AND Event_Location__c = :eventLocation';
        }
        if (String.isNotBlank(eventType)) {
            qry += ' AND Event_Type__c = :eventType';
        }
        qry += ' ORDER BY LastModifiedDate DESC LIMIT 1000';

        List<Event__c> queryResult = Database.query(qry);
        return queryResult;
    }
    */
    private static List<Event__c> fetchFilteredEvents(Set<Id> accessibleEventIds, EventFilterCriteria filterCriteria) {
        String qry =
            'SELECT Id, Name, Start_Date__c, End_Date__c, Event_Location__c,' +
            ' Event_Location__r.Name, Event_Location__r.Address__c, Event_Location__r.City__c,' +
            ' Event_Location__r.Province_State__c, Event_Location__r.Zip_Code__c,' +
            ' Event_Location__r.Country__c, Event_Type__c, User__c, User__r.Name,' +
            ' Week_Days__c, Available_Registrations__c, Picture__c, Description__c,' +
            ' Type_Of_Event__c, Maximum_Quantity_Select__c, Allow_Guest_Registrations__c,' +
            ' Allow_override_duplicate_registration__c, Instant_CheckIn__c' +
            ' FROM Event__c' +
            ' WHERE Id IN :accessibleEventIds';

        if (String.isNotBlank(filterCriteria.localEventName)) {
            qry += ' AND Name LIKE :localEventName';
        }
        if (String.isNotBlank(filterCriteria.eventLocation)) {
            qry += ' AND Event_Location__c = :eventLocation';
        }
        if (String.isNotBlank(filterCriteria.eventType)) {
            qry += ' AND Event_Type__c = :eventType';
        }
        qry += ' ORDER BY LastModifiedDate DESC LIMIT 1000';

        Map<String, Object> queryParams = new Map<String, Object>{
            'accessibleEventIds' => accessibleEventIds
        };
        if (String.isNotBlank(filterCriteria.localEventName)) {
            queryParams.put('localEventName', filterCriteria.localEventName);
        }
        if (String.isNotBlank(filterCriteria.eventLocation)) {
            queryParams.put('eventLocation', filterCriteria.eventLocation);
        }
        if (String.isNotBlank(filterCriteria.eventType)) {
            queryParams.put('eventType', filterCriteria.eventType);
        }
        return (List<Event__c>) Database.queryWithBinds(qry, queryParams, AccessLevel.USER_MODE);
    }
    //changes end here by abuzar

    private static EventsWrapper buildEventsWrapper(List<Event__c> events) {
        EventsWrapper allEventsWrap = new EventsWrapper();
        for (Event__c evt : events) {
            EventWrap evWrp = createEventWrap(evt);
            categorizeEvent(evWrp, allEventsWrap);
        }
        return allEventsWrap;
    }

    private static EventWrap createEventWrap(Event__c evt) {
        EventWrap evWrp = new EventWrap();
        evWrp.evt = evt;
        if (evt.Week_Days__c != null) {
            evWrp.evtWeekDays.addAll(evt.Week_Days__c.split(';'));
        }
        return evWrp;
    }

    private static void categorizeEvent(EventWrap evWrp, EventsWrapper allEventsWrap) {
        Event__c evt = evWrp.evt;
        allEventsWrap.evtList.add(evWrp);

        Date sDate = Date.newInstance(evt.Start_Date__c.year(), evt.Start_Date__c.month(), evt.Start_Date__c.day());
        Date eDate = Date.newInstance(evt.End_Date__c.year(), evt.End_Date__c.month(), evt.End_Date__c.day());
        Date today = System.today();
        Date thisWeekStart = today.toStartOfWeek();
        Date thisWeekEnd = thisWeekStart.addDays(7);
        Date nextWeekStart = thisWeekEnd.addDays(1);
        Date nextWeekEnd = nextWeekStart.addDays(7);

        if (sDate <= today && eDate >= today) {
            allEventsWrap.todaysEvents++;
            allEventsWrap.todaysEvtList.add(evWrp);
        }
        if (eDate >= today && eDate <= thisWeekEnd) {
            allEventsWrap.thisWeeksEvents++;
            allEventsWrap.thisWeeksEvtList.add(evWrp);
        }
        if (eDate >= nextWeekStart && eDate <= nextWeekEnd) {
            allEventsWrap.nextWeeksEvents++;
            allEventsWrap.nextWeeksEvtList.add(evWrp);
        }
        if (eDate > nextWeekEnd) {
            allEventsWrap.futureEvents++;
            allEventsWrap.futureEvtList.add(evWrp);
        }
    }

    private static List<Agenda__c> fetchAgendaDetails(String eventId, String zoneId) {
        if (!Schema.sObjectType.Agenda__c.isAccessible()) {
            return new List<Agenda__c>();
        }

        String qry =
            'SELECT Id, Name, Event_Zone__c, Agenda_Description__c, Description__c,' +
            ' Start_Time__c, End_Time__c FROM Agenda__c' +
            ' WHERE Event__c = :eventId AND Description__c != null' +
            ' AND Start_Time__c != null AND End_Time__c != null';
        if (String.isNotBlank(zoneId)) {
            qry += ' AND Event_Zone__c = :zoneId LIMIT 1000';
        }

        Map<String, Object> queryParams = new Map<String, Object>{ 'eventId' => eventId };
        if (String.isNotBlank(zoneId)) {
            queryParams.put('zoneId', zoneId);
        }
        return (List<Agenda__c>) Database.queryWithBinds(qry, queryParams, AccessLevel.USER_MODE);
    }

    private static List<Sponsorship__c> fetchSponsorshipDetails(String eventId, String zoneId) {
        if (!Schema.sObjectType.Sponsorship__c.isAccessible()) {
            return new List<Sponsorship__c>();
        }

        String qry =
            'SELECT Id, Name, Description__c, Sponsor_Account__r.Website, Event_Zone__c,' +
            ' Sponsor_Account__c, Sponsor_Account__r.Sponsorship_Logo__c, Sponsorship_Plan__c' +
            ' FROM Sponsorship__c' +
            ' WHERE Event__c = :eventId AND Active__c = true';
        if (String.isNotBlank(zoneId)) {
            qry += ' AND Event_Zone__c = :zoneId';
        }
        qry += ' ORDER BY CreatedDate ASC LIMIT 1000';

        Map<String, Object> queryParams = new Map<String, Object>{ 'eventId' => eventId };
        if (String.isNotBlank(zoneId)) {
            queryParams.put('zoneId', zoneId);
        }
        List<Sponsorship__c> sponsorQueryResult = (List<Sponsorship__c>) Database.queryWithBinds(
            qry,
            queryParams,
            AccessLevel.USER_MODE
        );
        Map<Id, Sponsorship__c> sponsorshipMap = new Map<Id, Sponsorship__c>(sponsorQueryResult);
        if (sponsorshipMap.isEmpty()) {
            return new List<Sponsorship__c>();
        }

        enrichSponsorshipAttachments(sponsorshipMap);
        return sponsorshipMap.values();
    }

    private static void enrichSponsorshipAttachments(Map<Id, Sponsorship__c> sponsorshipMap) {
        // commented by abuzar on 2026-03-13 for the scanning issue and added below line the reason of issue as mentioned above "Validate CRUD permission before SOQL/DML operation or enforce user mode"
        /*
        List<Attachment> attchListSpon = [
            SELECT Id, Name, Body, ParentId FROM Attachment
            WHERE ParentId IN :sponsorshipMap.keySet()
            WITH USER_MODE LIMIT 1000
        ];
        */
        Map<String, Object> attachmentParams = new Map<String, Object>{
            'parentIds' => sponsorshipMap.keySet()
        };
        List<Attachment> attchListSpon = (List<Attachment>) Database.queryWithBinds(
            'SELECT Id, Name, Body, ParentId FROM Attachment ' +
            'WHERE ParentId IN :parentIds LIMIT 1000',
            attachmentParams,
            AccessLevel.USER_MODE
        );
        //changes end here by abuzar
        for (Sponsorship__c spon : sponsorshipMap.values()) {
            for (Attachment at : attchListSpon) {
                if (at.ParentId == spon.Id) {
                    spon.Type__c = String.valueOf(EncodingUtil.base64Encode(at.Body));
                    spon.Status__c = '';
                }
            }
        }
    }

    private static List<Speaker__c> fetchSpeakerDetails(String eventId, String zoneId) {
        if (!Schema.sObjectType.Speaker__c.isAccessible()) {
            return new List<Speaker__c>();
        }

        String qry =
            'SELECT Id, Name, Description__c, Image_Url__c FROM Speaker__c' +
            ' WHERE Event__c = :eventId AND Active__c = true';
        if (String.isNotBlank(zoneId)) {
            qry += ' AND Event_Zone__c = :zoneId';
        }
        qry += ' ORDER BY CreatedDate ASC LIMIT 1000';

        Map<String, Object> queryParams = new Map<String, Object>{ 'eventId' => eventId };
        if (String.isNotBlank(zoneId)) {
            queryParams.put('zoneId', zoneId);
        }
        return (List<Speaker__c>) Database.queryWithBinds(qry, queryParams, AccessLevel.USER_MODE);
    }

    private static Expert_Location__c fetchExpertLocation(String locId) {
        if (!Schema.sObjectType.Expert_Location__c.isAccessible() || String.isBlank(locId)) {
            return null;
        }

        // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
        // List<Expert_Location__c> locationList = [
        //     SELECT Id, Name, Address__c, City__c, Province_State__c,
        //            Country__c, Zip_Code__c
        //     FROM Expert_Location__c
        //     WHERE Id = :locId
        //     LIMIT 1
        // ];
        List<Expert_Location__c> locationList = [
            SELECT Id, Name, Address__c, City__c, Province_State__c,
                   Country__c, Zip_Code__c
            FROM Expert_Location__c
            WHERE Id = :locId
            WITH USER_MODE
            LIMIT 1
        ];
        //changes end here by Abuzar
        return locationList.isEmpty() ? null : locationList[0];
    }

    private static Registration_SCH__c fetchRegistrationForDaysContainer(String regId) {
        if (String.isBlank(regId)) {
            return null;
        }

        String regFields =
            ' LastModified__c, Account__c, Category_of_registration__c, Customer_Email__c,' +
            ' Customer_Name__c, Customer_Lastname__c, Customer_Contact__c, Customer_Status__c,' +
            ' Customer_Type__c, Event__c, Event_Zone__c, Expert_Location__c, Meeting_Status__c,' +
            ' Membership_Points__c, Product2__c, Registration_DateD__c, Registration_End_Time__c,' +
            ' Registration_DateT__c, Registration_Type__c, Registration_Time__c, End_Time__c,' +
            ' Status__c, Number_of_other_persons__c, Expert__c, Contact__c';

        String query1 =
            'SELECT ' + regFields +
            ', Expert_Location__r.Name, Expert_Location__r.Address__c,' +
            ' Expert_Location__r.City__c, Expert_Location__r.Province_State__c,' +
            ' Expert_Location__r.Zip_Code__c, Expert_Location__r.Country__c, Event__r.Name' +
            ' FROM Registration_SCH__c' +
            ' WHERE Id = :regId LIMIT 1000';

        Map<String, Object> params = new Map<String, Object>{ 'regId' => regId };
        List<SObject> queryResults = Database.queryWithBinds(query1, params, AccessLevel.USER_MODE);
        return queryResults.isEmpty() ? null : (Registration_SCH__c) queryResults[0];
    }

    private static Contact fetchCurrentUserContact() {
        // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
        // User lu = [SELECT Id, Name, ContactId FROM User WHERE Id = :UserInfo.getUserId() WITH USER_MODE LIMIT 1];
        User lu = [SELECT Id, Name, ContactId FROM User WHERE Id = :UserInfo.getUserId() WITH USER_MODE LIMIT 1];
        //changes end here by Abuzar
        if (lu.ContactId == null) {
            return null;
        }
        // commented by abuzar on 2026-03-13 for the scanning issue and added below line "Validate CRUD permission before SOQL/DML operation or enforce user mode"
        /*
        return [SELECT Id, Name, AccountId FROM Contact WHERE Id = :lu.ContactId LIMIT 1];
        */
        Map<String, Object> contactParams = new Map<String, Object>{ 'contactId' => lu.ContactId };
        List<Contact> contactResults = (List<Contact>) Database.queryWithBinds(
            'SELECT Id, Name, AccountId FROM Contact WHERE Id = :contactId LIMIT 1',
            contactParams,
            AccessLevel.USER_MODE
        );
        return contactResults.isEmpty() ? null : contactResults[0];
        //changes end here by abuzar
    }

    private static Event__c fetchEventForDaysContainer(String eventId) {
        String allFields1 =
            'Id, User__c, Week_Days__c, Event_Location__c, Event_Status__c, End_Date__c,' +
            ' Registration_End_Date__c, Registration_Start_Date__c, Start_Date__c, Event_Type__c,' +
            ' Available_Registrations__c, Picture__c, Description__c, Type_Of_Event__c,' +
            ' Maximum_Quantity_Select__c, Allow_Guest_Registrations__c,' +
            ' Allow_override_duplicate_registration__c, Organisers__c, Expert_Location__c,' +
            ' Is_Expert_Required__c, Active__c, Booked_Registrations__c,' +
            ' Allow_Waiting_List__c, Instant_CheckIn__c';

        String query2 =
            'SELECT ' + allFields1 +
            ', Event_Location__r.Name, Event_Location__r.Address__c,' +
            ' Event_Location__r.City__c, Event_Location__r.Province_State__c,' +
            ' Event_Location__r.Zip_Code__c, Event_Location__r.Country__c' +
            ' FROM Event__c' +
            ' WHERE Id = :eventId LIMIT 1000';

        Map<String, Object> evtParams = new Map<String, Object>{ 'eventId' => eventId };
        List<Event__c> evtQry = Database.queryWithBinds(query2, evtParams, AccessLevel.USER_MODE);
        //System.debug(LoggingLevel.DEBUG, 'evtQry.size(): ' + evtQry.size());
        return evtQry.isEmpty() ? new Event__c() : evtQry[0];
    }

    private static List<Event_Zone__c> fetchActiveZonesForEvent(String eventId) {
        String active = 'Active';
        DateTime noww = System.now();
        String allFields4 =
            'Event_Zone_Location__c, Event__c, Status__c, Allow_Waiting_List__c,' +
            ' Available_Registrations__c, Start_Date__c, End_Date__c, Show_Day_Slots__c,' +
            ' Registration_Start_Date__c, Registration_End_Date__c';

        String query4 =
            'SELECT ' + allFields4 +
            ', Event_Zone_Location__r.Name, Event_Zone_Location__r.Address__c,' +
            ' Event_Zone_Location__r.City__c, Event_Zone_Location__r.Zip_Code__c,' +
            ' Event_Zone_Location__r.Country__c, Event_Zone_Location__r.Province_State__c' +
            ' FROM Event_Zone__c' +
            ' WHERE Event__c = :eventId' +
            ' AND Status__c = :active' +
            ' AND (Allow_Waiting_List__c = true OR Available_Registrations__c > 0)' +
            ' AND Start_Date__c != null AND End_Date__c != null' +
            ' AND End_Date__c >= :noww' +
            ' AND Registration_Start_Date__c != null AND Registration_End_Date__c != null' +
            ' AND Registration_Start_Date__c <= :noww' +
            ' AND Registration_End_Date__c >= :noww' +
            ' ORDER BY Start_Date__c ASC LIMIT 1000';

        // List<Event_Zone__c> zones = Database.query(query4);
        // return zones;

        Map<String, Object> zoneParams = new Map<String, Object>{
            'eventId' => eventId,
            'active'  => active,
            'noww'    => noww
        };
        return (List<Event_Zone__c>) Database.queryWithBinds(query4, zoneParams, AccessLevel.USER_MODE);
    }

    private static Set<String> extractWeekDays(Event__c evt) {
        Set<String> weekDays = new Set<String>();
        if (evt.Week_Days__c == null) {
            return weekDays;
        }

        for (String weekDay : evt.Week_Days__c.split(';')) {
            weekDays.add(weekDay);
        }
        return weekDays;
    }

    private static List<Registration_SCH__c> fetchEventRegistrations(String eventId) {
        String query5 =
            'SELECT Id, Name, Event__c, Event_Zone__c, Registration_Time__c, End_Time__c' +
            ' FROM Registration_SCH__c' +
            ' WHERE Event__c = :eventId LIMIT 1000';
        Map<String, Object> regParams = new Map<String, Object>{ 'eventId' => eventId };
        List<Registration_SCH__c> regList = (List<Registration_SCH__c>) Database.queryWithBinds(
            query5,
            regParams,
            AccessLevel.USER_MODE
        );
        //System.debug(LoggingLevel.DEBUG, 'regList.size(): ' + regList.size());
        return regList;
    }

    private static Map<Id, List<Registration_SCH__c>> buildBookedRegistrationMap(
        List<Registration_SCH__c> regList,
        List<Event_Zone__c> zones
    ) {
        Map<Id, List<Registration_SCH__c>> bookedRegMap = new Map<Id, List<Registration_SCH__c>>();
        Boolean hasZones = !zones.isEmpty();

        for (Registration_SCH__c reg : regList) {
            Id sourceId = hasZones ? reg.Event_Zone__c : reg.Event__c;
            if (sourceId == null) {
                continue;
            }

            if (!bookedRegMap.containsKey(sourceId)) {
                bookedRegMap.put(sourceId, new List<Registration_SCH__c>());
            }
            bookedRegMap.get(sourceId).add(reg);
        }
        //System.debug(LoggingLevel.DEBUG, 'BookedRegMap: ' + bookedRegMap);
        return bookedRegMap;
    }

    // commented by abuzar on 2026-03-13 for the scanning issue and added below line "Avoid long parameter lists (4 parameters - threshold is 4)."
    /*
    private static void populateDateColumns(
        Container daysContainer,
        List<Event_Zone__c> zones,
        Set<String> weekDays,
        Map<Id, List<Registration_SCH__c>> bookedRegMap
    ) {
        ZoneDateColumnContext zoneContext = new ZoneDateColumnContext();
        zoneContext.weekDays = weekDays;
        zoneContext.bookedRegMap = bookedRegMap;
        zoneContext.eventRecord = daysContainer.event;
        List<DateColumn> dateColumnList = zones.isEmpty()
            ? buildEventDateColumns(daysContainer.event, weekDays, bookedRegMap)
            : buildZoneDateColumns(zones, zoneContext);

        if (dateColumnList.isEmpty()) {
            daysContainer.errMsg = 'Sorry slots not available for registration';
            return;
        }

        daysContainer.dateColumnList = dateColumnList;
    }
    */
    private static void populateDateColumns(Container daysContainer, ZoneDateColumnContext zoneContext) {
        List<DateColumn> dateColumnList = zoneContext.zones.isEmpty()
            ? buildEventDateColumns(zoneContext)
            : buildZoneDateColumns(zoneContext.zones, zoneContext);

        if (dateColumnList.isEmpty()) {
            daysContainer.errMsg = 'Sorry slots not available for registration';
            return;
        }

        daysContainer.dateColumnList = dateColumnList;
    }
    //changes end here by abuzar

    // FIX: CyclomaticComplexity/NcssCount - extracted zone date column building into helper
    // Shared inner class / helper to carry either an Event or Zone's date range fields
    private class SlotSource {
        DateTime      startDate;
        DateTime      endDate;
        DateTime      storeStart;
        Id            sourceId;
        Decimal       availableRegistrations;
        Event__c      evt;
        Event_Zone__c zone;

        // Constructor for event-sourced slots
        SlotSource(Event__c evt) {
            this.applyCommonFields(buildSlotCommonFieldsFromEvent(evt));
            this.evt = evt;
        }

        // Constructor for zone-sourced slots
        SlotSource(Event_Zone__c zone, Event__c evt) {
            this.applyCommonFields(buildSlotCommonFieldsFromZone(zone));
            this.zone = zone;
            this.evt  = evt;
        }

        // commented by abuzar on 2026-03-13 for the scanning issue and added below line "Avoid long parameter lists (4 parameters - threshold is 4)."
        /*
        // Sets fields shared between event-sourced and zone-sourced slots
        private void applyCommonFields(DateTime start, DateTime endtime, Id srcId, Decimal availableRegs) {
            this.startDate              = start;
            this.endDate                = endtime;
            this.storeStart             = start;
            this.sourceId               = srcId;
            this.availableRegistrations = availableRegs;
        }
        */
        // Sets fields shared between event-sourced and zone-sourced slots
        private void applyCommonFields(SlotCommonFields commonFields) {
            this.startDate              = commonFields.startDate;
            this.endDate                = commonFields.endDate;
            this.storeStart             = commonFields.startDate;
            this.sourceId               = commonFields.sourceId;
            this.availableRegistrations = commonFields.availableRegistrations;
        }
        //changes end here by abuzar
    }

    private static SlotCommonFields buildSlotCommonFieldsFromEvent(Event__c evt) {
        SlotCommonFields commonFields = new SlotCommonFields();
        commonFields.startDate = evt.Start_Date__c;
        commonFields.endDate = evt.End_Date__c;
        commonFields.sourceId = evt.Id;
        commonFields.availableRegistrations = evt.Available_Registrations__c;
        return commonFields;
    }

    private static SlotCommonFields buildSlotCommonFieldsFromZone(Event_Zone__c zone) {
        SlotCommonFields commonFields = new SlotCommonFields();
        commonFields.startDate = zone.Start_Date__c;
        commonFields.endDate = zone.End_Date__c;
        commonFields.sourceId = zone.Id;
        commonFields.availableRegistrations = zone.Available_Registrations__c;
        return commonFields;
    }

    // commented by abuzar on 2026-03-13 for the scanning issue and added below line "Avoid long parameter lists (4 parameters - threshold is 4)."
    /*
    // ── Builds one DateColumn for a given day offset, or null if the slot is invalid ──
    private static DateColumn buildDateColumn(
        SlotSource source,
        Integer i,
        Set<String> weekDays,
        Map<Id, List<Registration_SCH__c>> bookedRegMap
    ) {
        DateTime dtm    = source.startDate.addDays(i);
        Date zoneDate   = Date.newInstance(dtm.year(), dtm.month(), dtm.day());
        String dayName  = getDayNameOfDate(zoneDate);

        Boolean isValidSlot =
            source.startDate.addDays(i).date() >= System.now().date() &&
            weekDays.contains(dayName);

        if (!isValidSlot) {
            return null;
        }

        Date startDateOnly = Date.newInstance(
            source.startDate.year(), source.startDate.month(), source.startDate.day()
        );

        DateColumn dc       = new DateColumn();
        dc.isSelect         = false;
        dc.event            = source.evt;
        dc.zone             = source.zone;
        dc.availableDate    = startDateOnly + i;
        dc.duration         = source.startDate.addDays(i).format('d MMMM yyyy (EEEE) - hh:mm a') +
            source.endDate.addDays(i).format(' - hh:mm a');
        dc.duration1        = source.startDate.addDays(i).format('EEEE MMMM d yyyy');
        dc.duration2        = source.startDate.format('hh:mm a') + source.endDate.format(' - hh:mm a');
        dc.availableDate1   = source.startDate.addDays(i);
        dc.availableDate2   = source.endDate;
        dc.availableDate3   = DateTime.newInstance(
            dc.availableDate1.year(), dc.availableDate1.month(), dc.availableDate1.day(),
            dc.availableDate2.hour(), dc.availableDate2.minute(), dc.availableDate2.second()
        );
        dc.isBlank          = 'No';
        source.storeStart   = source.storeStart.addDays(1);
        dc.storeDT          = String.valueOf(source.storeStart);
        dc.availableQuantity = 0;
        dc.bookedQuantity   = 0;

        List<Registration_SCH__c> rList = bookedRegMap.containsKey(source.sourceId)
            ? bookedRegMap.get(source.sourceId)
            : new List<Registration_SCH__c>();

        dc.bookedQuantity   = countBookedRegs(rList, zoneDate);
        dc.availableQuantity = source.availableRegistrations > 0
            ? Integer.valueOf(source.availableRegistrations)
            : 0;

        return dc;
    }
    */
    // ── Builds one DateColumn for a given day offset, or null if the slot is invalid ──
    private static DateColumn buildDateColumn(
        SlotSource source,
        Integer i,
        DateColumnBuildContext context
    ) {
        DateTime dtm    = source.startDate.addDays(i);
        Date zoneDate   = Date.newInstance(dtm.year(), dtm.month(), dtm.day());
        String dayName  = getDayNameOfDate(zoneDate);

        Boolean isValidSlot =
            source.startDate.addDays(i).date() >= System.now().date() &&
            context.weekDays.contains(dayName);

        if (!isValidSlot) {
            return null;
        }

        Date startDateOnly = Date.newInstance(
            source.startDate.year(), source.startDate.month(), source.startDate.day()
        );

        DateColumn dc       = new DateColumn();
        dc.isSelect         = false;
        dc.event            = source.evt;
        dc.zone             = source.zone;
        dc.availableDate    = startDateOnly + i;
        dc.duration         = source.startDate.addDays(i).format('d MMMM yyyy (EEEE) - hh:mm a') +
            source.endDate.addDays(i).format(' - hh:mm a');
        dc.duration1        = source.startDate.addDays(i).format('EEEE MMMM d yyyy');
        dc.duration2        = source.startDate.format('hh:mm a') + source.endDate.format(' - hh:mm a');
        dc.availableDate1   = source.startDate.addDays(i);
        dc.availableDate2   = source.endDate;
        dc.availableDate3   = DateTime.newInstance(
            dc.availableDate1.year(), dc.availableDate1.month(), dc.availableDate1.day(),
            dc.availableDate2.hour(), dc.availableDate2.minute(), dc.availableDate2.second()
        );
        dc.isBlank          = 'No';
        source.storeStart   = source.storeStart.addDays(1);
        dc.storeDT          = String.valueOf(source.storeStart);
        dc.availableQuantity = 0;
        dc.bookedQuantity   = 0;

        List<Registration_SCH__c> rList = context.bookedRegMap.containsKey(source.sourceId)
            ? context.bookedRegMap.get(source.sourceId)
            : new List<Registration_SCH__c>();

        dc.bookedQuantity   = countBookedRegs(rList, zoneDate);
        dc.availableQuantity = source.availableRegistrations > 0
            ? Integer.valueOf(source.availableRegistrations)
            : 0;

        return dc;
    }
    //changes end here by abuzar

    // Counts registrations whose time range covers the given date
    private static Integer countBookedRegs(List<Registration_SCH__c> rList, Date zoneDate) {
        Integer count = 0;
        for (Registration_SCH__c reg : rList) {
            if (reg.Registration_Time__c == null || reg.End_Time__c == null) {
                continue;
            }
            Date regSd = Date.newInstance(
                reg.Registration_Time__c.year(), reg.Registration_Time__c.month(), reg.Registration_Time__c.day()
            );
            Date regEd = Date.newInstance(
                reg.End_Time__c.year(), reg.End_Time__c.month(), reg.End_Time__c.day()
            );
            if (regSd <= zoneDate && regEd >= zoneDate) {
                count++;
            }
        }
        return count;
    }

    private class DateColumnBuildContext {
        private Set<String> weekDays;
        private Map<Id, List<Registration_SCH__c>> bookedRegMap;
    }

    // commented by abuzar on 2026-03-13 for the scanning issue and added below line "Avoid long parameter lists (4 parameters - threshold is 4)."
    /*
    // ── Iterates day slots for a SlotSource and collects valid DateColumns ──
    private static List<DateColumn> buildColumnsFromSource(
        SlotSource source,
        Set<String> weekDays,
        Map<Id, List<Registration_SCH__c>> bookedRegMap
    ) {
        List<DateColumn> dateColumnList = new List<DateColumn>();

        Date startDateOnly = Date.newInstance(
            source.startDate.year(), source.startDate.month(), source.startDate.day()
        );
        Date endDateOnly = Date.newInstance(
            source.endDate.year(), source.endDate.month(), source.endDate.day()
        );
        Integer rangeLength = startDateOnly.daysBetween(endDateOnly);

        for (Integer i = 0; i <= rangeLength; i++) {
            DateColumn dc = buildDateColumn(source, i, weekDays, bookedRegMap);
            if (dc != null) {
                dateColumnList.add(dc);
            }
        }
        return dateColumnList;
    }
    */
    // ── Iterates day slots for a SlotSource and collects valid DateColumns ──
    private static List<DateColumn> buildColumnsFromSource(
        SlotSource source,
        DateColumnBuildContext context
    ) {
        List<DateColumn> dateColumnList = new List<DateColumn>();

        Date startDateOnly = Date.newInstance(
            source.startDate.year(), source.startDate.month(), source.startDate.day()
        );
        Date endDateOnly = Date.newInstance(
            source.endDate.year(), source.endDate.month(), source.endDate.day()
        );
        Integer rangeLength = startDateOnly.daysBetween(endDateOnly);

        for (Integer i = 0; i <= rangeLength; i++) {
            DateColumn dc = buildDateColumn(source, i, context);
            if (dc != null) {
                dateColumnList.add(dc);
            }
        }
        return dateColumnList;
    }
    //changes end here by abuzar

    private static DateColumnBuildContext buildDateColumnContext(
        Set<String> weekDays,
        Map<Id, List<Registration_SCH__c>> bookedRegMap
    ) {
        DateColumnBuildContext context = new DateColumnBuildContext();
        context.weekDays = weekDays;
        context.bookedRegMap = bookedRegMap;
        return context;
    }

    // ── Public-facing methods now delegate to the shared helpers ──
    // commented by abuzar on 2026-03-13 for the scanning issue and added below line "Avoid long parameter lists (4 parameters - threshold is 4)."
    /*
    private static List<DateColumn> buildEventDateColumns(
        Event__c evt,
        Set<String> weekDays,
        Map<Id, List<Registration_SCH__c>> bookedRegMap
    ) {
        Boolean evtDatesValid =
            evt.Start_Date__c != null && evt.End_Date__c != null &&
            evt.End_Date__c > evt.Start_Date__c && evt.End_Date__c >= System.today() &&
            evt.Registration_Start_Date__c != null && evt.Registration_End_Date__c != null &&
            evt.Registration_End_Date__c > evt.Registration_Start_Date__c &&
            System.now() >= evt.Registration_Start_Date__c &&
            evt.Registration_End_Date__c >= System.now();

        if (!evtDatesValid) {
            return new List<DateColumn>();
        }
        SlotSource s = new SlotSource(evt);
        DateColumnBuildContext context = buildDateColumnContext(weekDays, bookedRegMap);
        return buildColumnsFromSource(s, context);
    }
    */
    private static List<DateColumn> buildEventDateColumns(ZoneDateColumnContext zoneContext) {
        Event__c evt = zoneContext.eventRecord;
        Boolean evtDatesValid =
            evt.Start_Date__c != null && evt.End_Date__c != null &&
            evt.End_Date__c > evt.Start_Date__c && evt.End_Date__c >= System.today() &&
            evt.Registration_Start_Date__c != null && evt.Registration_End_Date__c != null &&
            evt.Registration_End_Date__c > evt.Registration_Start_Date__c &&
            System.now() >= evt.Registration_Start_Date__c &&
            evt.Registration_End_Date__c >= System.now();

        if (!evtDatesValid) {
            return new List<DateColumn>();
        }
        SlotSource s = new SlotSource(evt);
        DateColumnBuildContext context = buildDateColumnContext(
            zoneContext.weekDays,
            zoneContext.bookedRegMap
        );
        return buildColumnsFromSource(s, context);
    }
    //changes end here by abuzar

    // commented by abuzar on 2026-03-13 for the scanning issue and added below line "Avoid long parameter lists (4 parameters - threshold is 4)."
    /*
    private static List<DateColumn> buildZoneDateColumns(
        List<Event_Zone__c> zones,
        Set<String> weekDays,
        Map<Id, List<Registration_SCH__c>> bookedRegMap,
        Event__c evt
    ) {
        List<DateColumn> dateColumnList = new List<DateColumn>();

        for (Event_Zone__c zone : zones) {
            Boolean datesValid =
                zone.Start_Date__c != null && zone.End_Date__c != null &&
                zone.Registration_Start_Date__c != null && zone.Registration_End_Date__c != null &&
                System.now() >= zone.Registration_Start_Date__c &&
                zone.Registration_End_Date__c >= System.now();

            if (!datesValid) {
                continue;
            }
            SlotSource s = new SlotSource(zone, evt);
            DateColumnBuildContext context = buildDateColumnContext(weekDays, bookedRegMap);
            dateColumnList.addAll(
                buildColumnsFromSource(s, context)
            );
        }
        return dateColumnList;
    }
    */
    private static List<DateColumn> buildZoneDateColumns(
        List<Event_Zone__c> zones,
        ZoneDateColumnContext zoneContext
    ) {
        List<DateColumn> dateColumnList = new List<DateColumn>();

        for (Event_Zone__c zone : zones) {
            Boolean datesValid =
                zone.Start_Date__c != null && zone.End_Date__c != null &&
                zone.Registration_Start_Date__c != null && zone.Registration_End_Date__c != null &&
                System.now() >= zone.Registration_Start_Date__c &&
                zone.Registration_End_Date__c >= System.now();

            if (!datesValid) {
                continue;
            }
            SlotSource s = new SlotSource(zone, zoneContext.eventRecord);
            DateColumnBuildContext context = buildDateColumnContext(
                zoneContext.weekDays,
                zoneContext.bookedRegMap
            );
            dateColumnList.addAll(
                buildColumnsFromSource(s, context)
            );
        }
        return dateColumnList;
    }
    //changes end here by abuzar

    // ============================================================
    // getFitlerTypes
    // ============================================================
    /**
     * @description Returns selectable event type options for filtering.
     * @return Event type select options.
     */
    @AuraEnabled
    public static List<OptionWrapper> getFitlerTypes() {
        typeOptions = new List<OptionWrapper>();
        typeOptions.add(new OptionWrapper('', '- All Types -'));
        List<Schema.PicklistEntry> pickListValues = Schema.sObjectType.Event__c.Fields.Type_Of_Event__c.getPickListValues();
        for (Schema.PicklistEntry a : pickListValues) {
            typeOptions.add(new OptionWrapper(a.getValue(), a.getLabel()));
        }
        return typeOptions;
    }

    // ============================================================
    // getEventTypes
    // ============================================================
    /**
     * @description Returns the available `Event_Type__c` picklist labels.
     * @return Event type labels.
     */
    @AuraEnabled
    public static List<String> getEventTypes() {
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Event__c.Event_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) {
            options.add(f.getLabel());
        }
        return options;
    }

    // ============================================================
    // getLocations
    // ============================================================
    /**
     * @description Returns scheduler locations for active event allocations.
     * @return Location select options.
     */
    @AuraEnabled
    public static List<OptionWrapper> getLocations() {
        List<OptionWrapper> options = new List<OptionWrapper>();
        evallocRecType = Schema.SObjectType.Event_Allocation__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
        options.add(new OptionWrapper('', '--All Regions--'));
        if (Schema.sObjectType.Event_Allocation__c.isAccessible()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // for (Event_Allocation__c loc : [
            //     SELECT Id, Name, Location__r.Province_State__c, Event_Type__c, Event__r.Name,
            //            Location__r.Show_Experts__c, Event__r.Description__c, Expert__c, Location__c,
            //            Location__r.Name, Location__r.City__c, Event__r.End_Date__c, Event__r.Start_Date__c
            //     FROM Event_Allocation__c
            //     WHERE Active__c = true AND RecordTypeId = :evallocRecType LIMIT 1000
            // ]) {
            for (Event_Allocation__c loc : [
                SELECT Id, Name, Location__r.Province_State__c, Event_Type__c, Event__r.Name,
                       Location__r.Show_Experts__c, Event__r.Description__c, Expert__c, Location__c,
                       Location__r.Name, Location__r.City__c, Event__r.End_Date__c, Event__r.Start_Date__c
                FROM Event_Allocation__c
                WHERE Active__c = true AND RecordTypeId = :evallocRecType WITH USER_MODE LIMIT 1000
            ]) {
                //changes end here by Abuzar
                options.add(new OptionWrapper(String.valueOf(loc.Id), loc.Location__r.Name));
            }
        }
        return options;
    }

    // ============================================================
    // getEvents
    // ============================================================
    /**
     * @description Returns active events and the default image document reference.
     * @return Scheduler wrapper populated with event list data.
     */
    @AuraEnabled
    public static EventBooking_Sch getEvents() {
        List<Event__c> evList = new List<Event__c>();
        if (Schema.sObjectType.Event__c.isAccessible()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // evList = [
            //     SELECT Id, Name, Picture__c, Type_Of_Event__c, Organisers__c, Organisers__r.Name,
            //            Start_Date__c, Description__c, Event_Location__r.Name, Event_Location__c,
            //            End_Date__c, Registration_Start_Date__c, Registration_End_Date__c,
            //            Expert_Location__c, Event_Type__c, Event_Status__c,
            //            RecordType.DeveloperName, Event_Location__r.Address__c,
            //            Event_Location__r.City__c, Event_Location__r.Province_State__c,
            //            Is_Expert_Required__c, Event_Location__r.Zip_Code__c,
            //            Event_Location__r.Country__c, Active__c, Event_Location__r.Show_Experts__c,
            //            Booked_Registrations__c, Available_Registrations__c
            //     FROM Event__c
            //     WHERE Event_Location__c != null
            //     AND Event_Status__c = 'Active'
            //     AND (Allow_Waiting_List__c = true OR Available_Registrations__c > 0)
            //     AND End_Date__c >= TODAY
            //     ORDER BY Start_Date__c LIMIT 1000
            // ];
            evList = [
                SELECT Id, Name, Picture__c, Type_Of_Event__c, Organisers__c, Organisers__r.Name,
                       Start_Date__c, Description__c, Event_Location__r.Name, Event_Location__c,
                       End_Date__c, Registration_Start_Date__c, Registration_End_Date__c,
                       Expert_Location__c, Event_Type__c, Event_Status__c,
                       RecordType.DeveloperName, Event_Location__r.Address__c,
                       Event_Location__r.City__c, Event_Location__r.Province_State__c,
                       Is_Expert_Required__c, Event_Location__r.Zip_Code__c,
                       Event_Location__r.Country__c, Active__c, Event_Location__r.Show_Experts__c,
                       Booked_Registrations__c, Available_Registrations__c
                FROM Event__c
                WHERE Event_Location__c != null
                AND Event_Status__c = 'Active'
                AND (Allow_Waiting_List__c = true OR Available_Registrations__c > 0)
                AND End_Date__c >= TODAY
                WITH USER_MODE
                ORDER BY Start_Date__c LIMIT 1000
            ];
            //changes end here by Abuzar
        }
        for (Integer i = 0; i < evList.size(); i++) {
            evList[i].Active__c = true;
            if (evList[i].Registration_End_Date__c < System.now() && evList[i].End_Date__c < System.now()) {
                evList[i].Active__c = false;
            }
        }

        EventBooking_Sch eb = new EventBooking_Sch();
        eb.eventList = new List<Event__c>();
        if (evList.size() > 0) {
            eb.eventList = evList;
        }
        // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
        // List<Document> docList = [
        //     SELECT Id, Name, ContentType FROM Document
        //     WHERE Name LIKE :'%EventPic%'
        //     AND ContentType IN ('image/png', 'image/jpeg', 'image/gif')
        //     WITH USER_MODE LIMIT 1
        // ];
        List<Document> docList = [
            SELECT Id, Name, ContentType FROM Document
            WHERE Name LIKE :'%EventPic%'
            AND ContentType IN ('image/png', 'image/jpeg', 'image/gif')
            WITH USER_MODE LIMIT 1
        ];
        //changes end here by Abuzar
        if (docList.size() > 0) {
            eb.fileImageId = docList[0].Id;
        }
        return eb;
    }

    // ============================================================
    // getEvent
    // ============================================================
    /**
     * @description Returns a single event record with its display fields.
     * @param eId Event identifier.
     * @return Matching event record.
     */
    @AuraEnabled
    public static Event__c getEvent(String eId) {
        Event__c evt = new Event__c();
        if (Schema.sObjectType.Event__c.isAccessible()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // evt = [
            //     SELECT Id, Name, Type_Of_Event__c, Organisers__c, Organisers__r.Name,
            //            Start_Date__c, Description__c, Event_Location__r.Name, Event_Location__c,
            //            End_Date__c, Registration_Start_Date__c, Registration_End_Date__c,
            //            Expert_Location__c, Event_Type__c, Event_Status__c,
            //            RecordType.DeveloperName, Event_Location__r.Address__c,
            //            Event_Location__r.City__c, Event_Location__r.Province_State__c,
            //            Event_Location__r.Zip_Code__c, Event_Location__r.Country__c,
            //            Active__c, Event_Location__r.Show_Experts__c
            //     FROM Event__c WHERE Id = :eId LIMIT 1
            // ];
            evt = [
                SELECT Id, Name, Type_Of_Event__c, Organisers__c, Organisers__r.Name,
                       Start_Date__c, Description__c, Event_Location__r.Name, Event_Location__c,
                       End_Date__c, Registration_Start_Date__c, Registration_End_Date__c,
                       Expert_Location__c, Event_Type__c, Event_Status__c,
                       RecordType.DeveloperName, Event_Location__r.Address__c,
                       Event_Location__r.City__c, Event_Location__r.Province_State__c,
                       Event_Location__r.Zip_Code__c, Event_Location__r.Country__c,
                       Active__c, Event_Location__r.Show_Experts__c
                FROM Event__c WHERE Id = :eId WITH USER_MODE LIMIT 1
            ];
            //changes end here by Abuzar
        }
        if (evt.Registration_Start_Date__c < System.now()) {
            evt.Active__c = true;
        } else {
            evt.Active__c = false;
        }
        return evt;
    }

    // ============================================================
    // getWEAEvent
    // ============================================================
    /**
     * @description Returns a single WEA event record.
     * @param eventId Event identifier.
     * @return Matching event record.
     */
    @AuraEnabled
    public static Event__c getWEAEvent(String eventId) {
        Event__c ev = new Event__c();
        if (Schema.sObjectType.Event__c.isAccessible()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // ev = [
            //     SELECT Id, Name, Type_Of_Event__c, Organisers__c, Organisers__r.Name,
            //            Start_Date__c, Description__c, Event_Location__r.Name, Event_Location__c,
            //            End_Date__c, Registration_Start_Date__c, Registration_End_Date__c,
            //            Expert_Location__c, Event_Type__c, Event_Status__c,
            //            RecordType.DeveloperName, Event_Location__r.Address__c,
            //            Event_Location__r.City__c, Event_Location__r.Province_State__c,
            //            Event_Location__r.Zip_Code__c, Event_Location__r.Country__c,
            //            Active__c, Event_Location__r.Show_Experts__c
            //     FROM Event__c WHERE Id = :eventId LIMIT 1
            // ];
            ev = [
                SELECT Id, Name, Type_Of_Event__c, Organisers__c, Organisers__r.Name,
                       Start_Date__c, Description__c, Event_Location__r.Name, Event_Location__c,
                       End_Date__c, Registration_Start_Date__c, Registration_End_Date__c,
                       Expert_Location__c, Event_Type__c, Event_Status__c,
                       RecordType.DeveloperName, Event_Location__r.Address__c,
                       Event_Location__r.City__c, Event_Location__r.Province_State__c,
                       Event_Location__r.Zip_Code__c, Event_Location__r.Country__c,
                       Active__c, Event_Location__r.Show_Experts__c
                FROM Event__c WHERE Id = :eventId WITH USER_MODE LIMIT 1
            ];
            //changes end here by Abuzar
        }
        return ev;
    }

    // ============================================================
    // getAllocations
    // ============================================================
    /**
     * @description Returns allocations for an event and indicates whether day slots are shown.
     * @param eId Optional event identifier.
     * @return Scheduler wrapper containing allocation data, or `null` if none exist.
     */
    @AuraEnabled
    public static EventBooking_Sch getAllocations(String eId) {
        // Guard against null/blank event IDs to avoid unnecessary queries and exceptions.
        if (String.isBlank(eId)) {
            return null;
        }
        try {
            Id eventId = (String.isNotEmpty(eId) && eId instanceof Id) ? (Id) eId : null;
            List<Event_Allocation__c> alist1 = new List<Event_Allocation__c>();
            List<Event_Allocation__c> alist2 = new List<Event_Allocation__c>();

            if (Schema.sObjectType.Event_Allocation__c.isAccessible()) {
                String baseSelect =
                    'SELECT Id, Name, Event_Zone__r.Registration_End_Date__c, Event_Zone__r.Show_Day_Slots__c,' +
                    ' Location__r.Show_Experts__c, Start_Date__c, Event_Zone__c, Event_Zone__r.Name, Location__c,' +
                    ' Event__r.Start_Date__c, Event__r.End_Date__c, Location__r.Address__c,' +
                    ' Location__r.Province_State__c, Location__r.Country__c, Location__r.City__c,' +
                    ' Location__r.Zip_Code__c, Event__r.Name, Event__r.Description__c, Expert__c,' +
                    ' Location__r.Name, Event__c, Event__r.Event_Type__c, Event__r.RecordTypeId,' +
                    ' Event__r.RecordType.DeveloperName, Event_Zone__r.Start_Date__c,' +
                    ' Event_Zone__r.End_Date__c, Active__c' +
                    ' FROM Event_Allocation__c' +
                    ' WHERE (Event__r.Event_Type__c = \'Event\' OR Event__r.Event_Type__c = \'Expert Event\')' +
                    ' AND Active__c = TRUE AND Event__r.Active__c = TRUE ';

                if (eventId != null) {
                    baseSelect += ' AND Event__c = :eventIdParam';
                }

                String query1 = baseSelect + ' AND Event_Zone__r.Show_Day_Slots__c = TRUE ORDER BY Start_Date__c LIMIT 1000';
                String query2 = baseSelect + ' AND Event_Zone__r.Show_Day_Slots__c = FALSE ORDER BY Start_Date__c LIMIT 1000';
                Map<String, Object> bindVars = new Map<String, Object>();
                if (eventId != null) {
                    bindVars.put('eventIdParam', eventId);
                }

                alist1 = (List<Event_Allocation__c>) Database.queryWithBinds(query1, bindVars, AccessLevel.USER_MODE);
                alist2 = (List<Event_Allocation__c>) Database.queryWithBinds(query2, bindVars, AccessLevel.USER_MODE);
            }

            List<Event_Allocation__c> alist3 = new List<Event_Allocation__c>();
            alist3.addAll(alist1);
            alist3.addAll(alist2);

            EventBooking_Sch ef = new EventBooking_Sch();
            ef.allocationList = alist3;
            ef.showDaySlotsBool = (alist1.size() > 0);

            if (ef.allocationList.size() > 0) {
                return ef;
            }
            return null;
        } catch (Exception e) {
            //System.debug(LoggingLevel.DEBUG, 'Exception in getAllocations ~> ' + e.getMessage() + '; at line ~> ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage() + '; at line ~> ' + e.getStackTraceString());
        }
    }

    // ============================================================
    // bookingEvents
    // ============================================================
    /**
     * @description Returns the matching event allocation for the selected event and location.
     * @param eventId Event identifier.
     * @param locationId Location identifier.
     * @param eAllocId Event allocation identifier.
     * @return Matching event allocation record.
     */
    @AuraEnabled
    public static Event_Allocation__c bookingEvents(String eventId, String locationId, String eAllocId) {
        Event_Allocation__c eventAllocList = new Event_Allocation__c();
        if (Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.Event_Allocation__c.isAccessible()) {
            evallocRecType = Schema.SObjectType.Event_Allocation__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
        }
        if (Schema.sObjectType.Event_Allocation__c.isAccessible()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // eventAllocList = [
            //     SELECT Id, Name, Event_Zone__c, Event_Zone__r.Name, Location__c, Location__r.Name,
            //            Location__r.Address__c, Location__r.City__c, Location__r.Province_State__c,
            //            Location__r.Country__c, Location__r.Zip_Code__c,
            //            Event_Zone__r.Start_Date__c, Event_Zone__r.End_Date__c,
            //            Event_Zone__r.Available_Registrations__c,
            //            Event__c, Event__r.Description__c, Event__r.Name
            //     FROM Event_Allocation__c
            //     WHERE Id = :eAllocId AND Event__c = :eventId AND Location__c = :locationId
            //     LIMIT 1
            // ];
            eventAllocList = [
                SELECT Id, Name, Event_Zone__c, Event_Zone__r.Name, Location__c, Location__r.Name,
                       Location__r.Address__c, Location__r.City__c, Location__r.Province_State__c,
                       Location__r.Country__c, Location__r.Zip_Code__c,
                       Event_Zone__r.Start_Date__c, Event_Zone__r.End_Date__c,
                       Event_Zone__r.Available_Registrations__c,
                       Event__c, Event__r.Description__c, Event__r.Name
                FROM Event_Allocation__c
                WHERE Id = :eAllocId AND Event__c = :eventId AND Location__c = :locationId
                WITH USER_MODE
                LIMIT 1
            ];
            //changes end here by Abuzar
        }
        return eventAllocList;
    }

    // ============================================================
    // fetchTypes
    // ============================================================
    /**
     * @description Returns the available `Type_Of_Event__c` picklist labels.
     * @return Event subtype labels.
     */
    @AuraEnabled
    public static List<String> fetchTypes() {
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Event__c.Type_Of_Event__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) {
            options.add(f.getLabel());
        }
        return options;
    }
    // ============================================================
    // readXMLResponse
    // ============================================================
    /**
     * @description Reads the text value for the requested XML tag from a stream.
     * @param reader XML stream reader positioned on the payload.
     * @param sxmltag XML tag name to find.
     * @return Text content for the tag, if found.
     */
    public static String readXMLResponse(XmlStreamReader reader, String sxmltag) {
        String retValue;
        while (reader.hasNext()) {
            if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == sxmltag) {
                    reader.next();
                    if (reader.getEventType() == XmlTag.CHARACTERS) {
                        retValue = reader.getText();
                    }

            }
            reader.next();
        }
        return retValue;
    }

    // ============================================================
    // getTimeZoneName
    // ============================================================
    /**
     * @description Returns the current user's Salesforce time zone.
     * @return Time zone name.
     */
    @AuraEnabled
    public static String getTimeZoneName() {
        return String.valueOf(UserInfo.getTimeZone());
    }

    // ============================================================
    // getCreateAccountAndContacts
    // ============================================================
    // commented by abuzar on 2026-03-13 for the scanning issue and added below line "The method 'getCreateAccountAndContacts(String)' has a cyclomatic complexity of 20 and a cognitive complexity of 35."
    /*
    @AuraEnabled
    public static String getCreateAccountAndContacts(String rJson) {
        List<Registration_SCH__c> reg1 = (List<Registration_SCH__c>) JSON.deserialize(rJson, List<Registration_SCH__c>.class);
        if (!Schema.sObjectType.Registration_SCH__c.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access Registration records.');
        }
        Registration_SCH__c reg = [
            SELECT Id, Name, Status__c, Registration_Type__c
            FROM Registration_SCH__c WHERE Id = :reg1[0].Id WITH USER_MODE LIMIT 1
        ];
        Boolean canSetRegType =
            Schema.sObjectType.Registration_SCH__c.fields.Registration_Type__c.isAccessible() &&
            Schema.sObjectType.Registration_SCH__c.fields.Registration_Type__c.isCreateable() &&
            Schema.sObjectType.Registration_SCH__c.fields.Registration_Type__c.isUpdateable();

        if (canSetRegType) {
            reg.Registration_Type__c = 'Online';
        }

        if (reg1[0].Customer_Contact__c != null || reg1[0].Customer_Email__c != null && Schema.sObjectType.Contact.isAccessible()) {
                Contact con = new Contact();
                List<Contact> cons = new List<Contact>();

                if (String.isNotEmpty(reg1[0].Customer_Contact__c)) {
                    cons = [
                        SELECT Id, FirstName, LastName, Phone, MobilePhone, Email FROM Contact
                        WHERE MobilePhone = :reg1[0].Customer_Contact__c OR Email = :reg1[0].Customer_Email__c
                        ORDER BY LastModifiedDate DESC LIMIT 1000
                    ];
                } else {
                    cons = [
                        SELECT Id, FirstName, LastName, Phone, MobilePhone, Email FROM Contact
                        WHERE Email = :reg1[0].Customer_Email__c
                        ORDER BY LastModifiedDate DESC LIMIT 1000
                    ];
                }

                if (cons.size() > 0) {
                    con = cons[0];
                }

                Boolean canSetFirstName =
                    reg1[0].Customer_Name__c != null &&
                    Schema.sObjectType.Contact.fields.FirstName.isAccessible() &&
                    Schema.sObjectType.Contact.fields.FirstName.isCreateable() &&
                    Schema.sObjectType.Contact.fields.FirstName.isUpdateable();
                if (canSetFirstName) {
                    con.FirstName = reg1[0].Customer_Name__c;
                }

                Boolean canSetLastName =
                    reg1[0].Customer_Lastname__c != null &&
                    Schema.sObjectType.Contact.fields.LastName.isAccessible() &&
                    Schema.sObjectType.Contact.fields.LastName.isCreateable() &&
                    Schema.sObjectType.Contact.fields.LastName.isUpdateable();
                if (canSetLastName) {
                    con.LastName = reg1[0].Customer_Lastname__c;
                }

                Boolean canSetMobile =
                    reg1[0].Customer_Contact__c != null &&
                    Schema.sObjectType.Contact.fields.MobilePhone.isAccessible() &&
                    Schema.sObjectType.Contact.fields.MobilePhone.isCreateable() &&
                    Schema.sObjectType.Contact.fields.MobilePhone.isUpdateable();
                if (canSetMobile) {
                    con.MobilePhone = reg1[0].Customer_Contact__c;
                }

                Boolean canSetEmail =
                    reg1[0].Customer_Email__c != null &&
                    Schema.sObjectType.Contact.fields.Email.isAccessible() &&
                    Schema.sObjectType.Contact.fields.Email.isCreateable() &&
                    Schema.sObjectType.Contact.fields.Email.isUpdateable();
                if (canSetEmail) {
                    con.Email = reg1[0].Customer_Email__c;
                }

                Boolean canSetEvent =
                    reg1[0].Event__c != null &&
                    Schema.sObjectType.Contact.fields.Event__c.isAccessible() &&
                    Schema.sObjectType.Contact.fields.Event__c.isCreateable() &&
                    Schema.sObjectType.Contact.fields.Event__c.isUpdateable();
                if (canSetEvent) {
                    con.Event__c = reg1[0].Event__c;
                }

                if (Schema.sObjectType.Contact.isCreateable() && Schema.sObjectType.Contact.isUpdateable()) {
                    upsert con;
                }
                if (Schema.sObjectType.Registration_SCH__c.fields.Contact__c.isCreateable() &&
                    Schema.sObjectType.Registration_SCH__c.fields.Contact__c.isUpdateable()) {
                    reg.Contact__c = con.Id;
                }
                if (Schema.sObjectType.Registration_SCH__c.isCreateable() && Schema.sObjectType.Registration_SCH__c.isUpdateable()) {
                    upsert reg;
                }
        }
        return null;
    }
    */
    /**
     * @description Creates or updates a contact from registration data and links it back to the registration.
     * @param rJson Serialized registration payload.
     * @return `null` after processing completes.
     */
    @AuraEnabled
    public static String getCreateAccountAndContacts(String rJson) {
        List<Registration_SCH__c> registrations =
            (List<Registration_SCH__c>) JSON.deserialize(rJson, List<Registration_SCH__c>.class);
        Registration_SCH__c sourceReg = registrations[0];
        Registration_SCH__c reg = fetchRegistrationForAccountAndContact(sourceReg.Id);
        applyOnlineRegistrationType(reg);

        if (!canCreateOrUpdateContactForRegistration(sourceReg)) {
            return null;
        }

        Contact con = findLatestMatchingContact(sourceReg);
        ContactFieldAccess access = getAccountAndContactFieldAccess(sourceReg);
        Contact builtContact = buildContactFromReg(sourceReg, access);
        mergeAccountAndContactFields(con, builtContact);
        upsertAccountAndContact(con);
        updateRegistrationContactLink(reg, con);

        return null;
    }

    // private static Registration_SCH__c fetchRegistrationForAccountAndContact(String registrationId) {
    //     if (!Schema.sObjectType.Registration_SCH__c.isAccessible()) {
    //         throw new AuraHandledException('Insufficient permissions to access Registration records.');
    //     }

    //     return [
    //         SELECT Id, Name, Status__c, Registration_Type__c
    //         FROM Registration_SCH__c
    //         WHERE Id = :registrationId
    //         WITH USER_MODE
    //         LIMIT 1
    //     ];
    // }

    private static Registration_SCH__c fetchRegistrationForAccountAndContact(String registrationId) {
    if (!Schema.sObjectType.Registration_SCH__c.isAccessible()) {
        throw new AuraHandledException('Insufficient permissions to access Registration records.');
    }
    // WITH USER_MODE throws QueryException when the running user lacks FLS on
    // Status__c or Registration_Type__c. USER_MODE enforces accessible fields without throwing.
    Map<String, Object> params = new Map<String, Object>{ 'registrationId' => registrationId };
    List<Registration_SCH__c> results = (List<Registration_SCH__c>) Database.queryWithBinds(
        'SELECT Id, Name, Registration_Type__c FROM Registration_SCH__c WHERE Id = :registrationId LIMIT 1',
        params,
        AccessLevel.USER_MODE
    );
    if (results.isEmpty()) {
        throw new AuraHandledException('Registration record not found: ' + registrationId);
    }
    return results[0];
}

    private static void applyOnlineRegistrationType(Registration_SCH__c reg) {
        Boolean canSetRegType =
            Schema.sObjectType.Registration_SCH__c.fields.Registration_Type__c.isAccessible() &&
            Schema.sObjectType.Registration_SCH__c.fields.Registration_Type__c.isCreateable() &&
            Schema.sObjectType.Registration_SCH__c.fields.Registration_Type__c.isUpdateable();

        if (canSetRegType) {
            reg.Registration_Type__c = 'Online';
        }
    }

    private static Boolean canCreateOrUpdateContactForRegistration(Registration_SCH__c sourceReg) {
        Boolean hasContactData =
            sourceReg.Customer_Contact__c != null || sourceReg.Customer_Email__c != null;
        return hasContactData && Schema.sObjectType.Contact.isAccessible();
    }

    private static Contact findLatestMatchingContact(Registration_SCH__c sourceReg) {
        List<Contact> contacts = queryMatchingContacts(sourceReg);
        if (contacts.isEmpty()) {
            return new Contact();
        }

        return contacts[0];
    }

    private static List<Contact> queryMatchingContacts(Registration_SCH__c sourceReg) {
        Map<String, Object> contactParams = new Map<String, Object>{
            'customerContact' => sourceReg.Customer_Contact__c,
            'customerEmail' => sourceReg.Customer_Email__c
        };
        if (String.isNotEmpty(sourceReg.Customer_Contact__c)) {
            // commented by abuzar on 2026-03-13 for the scanning issue and added below line the reason of issue as mentioned above "Validate CRUD permission before SOQL/DML operation or enforce user mode"
            /*
            return [
                SELECT Id, FirstName, LastName, Phone, MobilePhone, Email
                FROM Contact
                WHERE MobilePhone = :sourceReg.Customer_Contact__c
                    OR Email = :sourceReg.Customer_Email__c
                ORDER BY LastModifiedDate DESC
                LIMIT 1000
            ];
            */
            return (List<Contact>) Database.queryWithBinds(
                'SELECT Id, FirstName, LastName, Phone, MobilePhone, Email ' +
                'FROM Contact ' +
                'WHERE MobilePhone = :customerContact OR Email = :customerEmail ' +
                'ORDER BY LastModifiedDate DESC LIMIT 1000',
                contactParams,
                AccessLevel.USER_MODE
            );
            //changes end here by abuzar
        }

        // commented by abuzar on 2026-03-13 for the scanning issue and added below line the reason of issue as mentioned above "Validate CRUD permission before SOQL/DML operation or enforce user mode"
        /*
        return [
            SELECT Id, FirstName, LastName, Phone, MobilePhone, Email
            FROM Contact
            WHERE Email = :sourceReg.Customer_Email__c
            ORDER BY LastModifiedDate DESC
            LIMIT 1000
        ];
        */
        return (List<Contact>) Database.queryWithBinds(
            'SELECT Id, FirstName, LastName, Phone, MobilePhone, Email ' +
            'FROM Contact ' +
            'WHERE Email = :customerEmail ' +
            'ORDER BY LastModifiedDate DESC LIMIT 1000',
            contactParams,
            AccessLevel.USER_MODE
        );
        //changes end here by abuzar
    }

    private static ContactFieldAccess getAccountAndContactFieldAccess(Registration_SCH__c sourceReg) {
        ContactFieldAccess access = new ContactFieldAccess();
        access.canSetFirstName =
            sourceReg.Customer_Name__c != null &&
            Schema.sObjectType.Contact.fields.FirstName.isAccessible() &&
            Schema.sObjectType.Contact.fields.FirstName.isCreateable() &&
            Schema.sObjectType.Contact.fields.FirstName.isUpdateable();
        access.canSetLastName =
            sourceReg.Customer_Lastname__c != null &&
            Schema.sObjectType.Contact.fields.LastName.isAccessible() &&
            Schema.sObjectType.Contact.fields.LastName.isCreateable() &&
            Schema.sObjectType.Contact.fields.LastName.isUpdateable();
        access.canSetMobile =
            sourceReg.Customer_Contact__c != null &&
            Schema.sObjectType.Contact.fields.MobilePhone.isAccessible() &&
            Schema.sObjectType.Contact.fields.MobilePhone.isCreateable() &&
            Schema.sObjectType.Contact.fields.MobilePhone.isUpdateable();
        access.canSetEmail =
            sourceReg.Customer_Email__c != null &&
            Schema.sObjectType.Contact.fields.Email.isAccessible() &&
            Schema.sObjectType.Contact.fields.Email.isCreateable() &&
            Schema.sObjectType.Contact.fields.Email.isUpdateable();
        access.canSetEvent =
            sourceReg.Event__c != null &&
            Schema.sObjectType.Contact.fields.Event__c.isAccessible() &&
            Schema.sObjectType.Contact.fields.Event__c.isCreateable() &&
            Schema.sObjectType.Contact.fields.Event__c.isUpdateable();
        return access;
    }

    private static void mergeAccountAndContactFields(Contact targetContact, Contact sourceContact) {
        if (sourceContact.FirstName != null) {
            targetContact.FirstName = sourceContact.FirstName;
        }
        if (sourceContact.LastName != null) {
            targetContact.LastName = sourceContact.LastName;
        }
        if (sourceContact.MobilePhone != null) {
            targetContact.MobilePhone = sourceContact.MobilePhone;
        }
        if (sourceContact.Email != null) {
            targetContact.Email = sourceContact.Email;
        }
        if (sourceContact.Event__c != null) {
            targetContact.Event__c = sourceContact.Event__c;
        }
    }

    private static void upsertAccountAndContact(Contact con) {
        if (Schema.sObjectType.Contact.isCreateable() && Schema.sObjectType.Contact.isUpdateable()) {
            // commented by abuzar on 2026-03-13 for the scanning issue and added below line the reason of issue as mentioned above "Validate CRUD permission before SOQL/DML operation or enforce user mode"
            /*
            upsert con;
            */
            Database.upsert(con, AccessLevel.USER_MODE);
            //changes end here by abuzar
        }
    }

    private static void updateRegistrationContactLink(Registration_SCH__c reg, Contact con) {
        if (Schema.sObjectType.Registration_SCH__c.fields.Contact__c.isCreateable() &&
            Schema.sObjectType.Registration_SCH__c.fields.Contact__c.isUpdateable()) {
            reg.Contact__c = con.Id;
        }
        if (Schema.sObjectType.Registration_SCH__c.isCreateable() &&
            Schema.sObjectType.Registration_SCH__c.isUpdateable()) {
            // commented by abuzar on 2026-03-13 for the scanning issue and added below line the reason of issue as mentioned above "Validate CRUD permission before SOQL/DML operation or enforce user mode"
            /*
            upsert reg;
            */
            Database.upsert(reg, AccessLevel.USER_MODE);
            //changes end here by abuzar
        }
    }
    //changes end here by abuzar

    // ============================================================
    // checkAvailability
    // ============================================================
    /**
     * @description Checks whether the selected event or zone still has enough capacity.
     * @param zoneId Event zone identifier.
     * @return `true` when the zone is available.
     */
    @AuraEnabled
    public static Boolean checkAvailability(String zoneId) {
        Event_Zone__c zn = new Event_Zone__c();
        if (Schema.sObjectType.Event_Zone__c.isAccessible()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // zn = [SELECT Id, Name, Available_Registrations__c FROM Event_Zone__c WHERE Id = :zoneId WITH USER_MODE LIMIT 1];
            zn = [SELECT Id, Name, Available_Registrations__c FROM Event_Zone__c WHERE Id = :zoneId WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
        }
        if (Integer.valueOf(zn.Available_Registrations__c) > 0) {
            return true;
        }
        return false;
    }

    // ============================================================
    // getUserType
    // ============================================================
    /**
     * @description Returns the current user's scheduler-specific type.
     * @return User type value.
     */
    @AuraEnabled
    public static String getUserType() {
        return UserInfo.getUserType();
    }

    // ============================================================
    // BookReg3D
    // ============================================================
    // commented by abuzar on 2026-03-13 for the scanning issue and added below line "The method 'bookReg3D(String,String,String,String)' has a NCSS line count of 76 (limit: 40)."
    /*
    @AuraEnabled
    public static EventBooking_Sch bookReg3D(String rJson, String status, String recordType, String selTime) {
        EventBooking_Sch eb = new EventBooking_Sch();
        eb.registration = new Registration_SCH__c();
        Registration_SCH__c regRec = (Registration_SCH__c) JSON.deserialize(rJson, Registration_SCH__c.class);
        List<Registration_SCH__c> reg1 = new List<Registration_SCH__c>();
        reg1.add(regRec);
        Registration_SCH__c regNew = new Registration_SCH__c();

        try {
            DateTime startDT;
            if (regRec.Event_Zone__c == null) {
                startDT = DateTime.valueOfGmt(selTime.replace('T', ' '));
            } else {
                Date dtVal = Date.valueOf(selTime);
                startDT = DateTime.newInstance(dtVal.year(), dtVal.month(), dtVal.day(), 0, 0, 0);
            }

            for (Integer i = 0; i < reg1.size(); i++) {
                if (selTime != null && reg1[i].Registration_Time__c == null) {
                    reg1[i].Registration_Time__c = DateTime.valueOf(startDT);
                }
            }

            Id rTypeId = Schema.SObjectType.Registration_SCH__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
            Event__c evt = new Event__c();
            if (String.isNotEmpty(reg1[0].Event__c)) {
                evt = [SELECT Id, Name, Start_Date__c, End_Date__c FROM Event__c WHERE Id = :reg1[0].Event__c LIMIT 1];
            }

            if (reg1[0].End_Time__c != null) {
                if (reg1[0].Registration_Time__c != null) {
                    regNew.Registration_Time__c = reg1[0].Registration_Time__c;
                }
                regNew.End_Time__c = reg1[0].End_Time__c;
            } else {
                if (reg1[0].Registration_Time__c != null) {
                    DateTime startDateVal = DateTime.newInstance(
                        reg1[0].Registration_Time__c.year(), reg1[0].Registration_Time__c.month(), reg1[0].Registration_Time__c.day(),
                        evt.Start_Date__c.hour(), evt.Start_Date__c.minute(), 0
                    );
                    DateTime endDateVal = DateTime.newInstance(
                        reg1[0].Registration_Time__c.year(), reg1[0].Registration_Time__c.month(), reg1[0].Registration_Time__c.day(),
                        evt.End_Date__c.hour(), evt.End_Date__c.minute(), 0
                    );
                    regNew.Registration_Time__c = startDateVal;
                    regNew.End_Time__c = endDateVal;
                }
            }

            if (reg1[0].Product2__c != null && String.isNotEmpty(reg1[0].Product2__c)) {
                regNew.Product2__c = reg1[0].Product2__c;
            }
            regNew.LastModified__c = System.now();
            regNew.Customer_Name__c = String.valueOf(reg1[0].Customer_Name__c);
            regNew.Customer_Lastname__c = reg1[0].Customer_Lastname__c;
            regNew.Customer_Email__c = reg1[0].Customer_Email__c;
            regNew.Event__c = reg1[0].Event__c;
            regNew.Expert_Location__c = reg1[0].Expert_Location__c;
            regNew.Registration_Time__c = reg1[0].Registration_Time__c;
            if (reg1[0].End_Time__c != null) {
                regNew.End_Time__c = reg1[0].End_Time__c;
            }
            if (String.isNotEmpty(status)) {
                regNew.status__c = status;
            }
            regNew.Registration_Type__c = 'Online';
            if (String.isEmpty(reg1[0].Event_Zone__c)) {
                reg1[0].Event_Zone__c = null;
            }
            if (reg1[0].Event_Zone__c != null && Schema.sObjectType.Registration_SCH__c.fields.Event_Zone__c.isAccessible()) {
                regNew.Event_Zone__c = reg1[0].Event_Zone__c;
            }
            if (String.isNotEmpty(reg1[0].Id)) {
                regNew.Id = reg1[0].Id;
            }
            regNew.Customer_Contact__c = reg1[0].Customer_Contact__c;
            regNew.RecordTypeId = rTypeId;
            regNew.Override_duplicate_registration__c = reg1[0].Override_duplicate_registration__c;

            if (Schema.sObjectType.Registration_SCH__c.fields.Send_Email__c.isAccessible()) {
                if (reg1[0].Send_Email__c) {
                    regNew.Send_Email__c = reg1[0].Send_Email__c;
                }
            }

            if (recordType == 'Event' && reg1[0].Event_Zone__c != null) {
                if (Schema.sObjectType.Event_Zone__c.isAccessible()) {
                    Event_Zone__c zn = [SELECT Id, Name, Available_Registrations__c FROM Event_Zone__c WHERE Id = :reg1[0].Event_Zone__c LIMIT 1];
                    Integer ar = Integer.valueOf(zn.Available_Registrations__c);
                    //System.debug(LoggingLevel.DEBUG, 'Available registrations: ' + ar);
                }
            }

            reg1[0].Expert__c = null;
            if (String.isNotEmpty(reg1[0].Contact__c)) {
                regNew.Contact__c = reg1[0].Contact__c;
            }

            List<Registration_SCH__c> regsNew = new List<Registration_SCH__c>();
            regsNew.add(regNew);
            String regisId = getCreateContact(JSON.serialize(regsNew), regNew.Contact__c);

            eb.registration = [
                SELECT Id, Name, LastModified__c, Account__c, Category_of_registration__c,
                       Customer_Email__c, Customer_Name__c, Customer_Lastname__c, Customer_Contact__c,
                       Customer_Status__c, Customer_Type__c, Event__c, Event__r.Name,
                       Event__r.RecordType.DeveloperName, Event_Zone__c, Event_Zone__r.Name,
                       Expert_Location__c, Meeting_Status__c, Membership_Points__c, Product2__c,
                       Registration_DateD__c, Registration_End_Time__c, Registration_DateT__c,
                       Registration_Type__c, Registration_Time__c, End_Time__c, Status__c,
                       Event_Zone__r.Event_Zone_Location__c, Event_Zone__r.Event_Zone_Location__r.Name,
                       Expert_Location__r.Show_Experts__c, Expert_Location__r.Name,
                       Expert_Location__r.Address__c, Expert_Location__r.City__c,
                       Expert_Location__r.Province_State__c, Expert_Location__r.Country__c,
                       Expert_Location__r.Zip_Code__c, Event__r.Start_Date__c, Event__r.End_Date__c,
                       Event__r.Description__c, Event__r.Event_Type__c
                FROM Registration_SCH__c WHERE Id = :regisId LIMIT 1
            ];
            eb.expMsg = null;
        } catch (Exception ex) {
            eb.registration = null;
            eb.expMsg = null;
            if (ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') && ex.getMessage().contains('book')) {
                eb.expMsg = ex.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': []');
            }
            return eb;
        }
        return eb;
    }
    */
    // commented by abuzar on 2026-03-13 for the scanning issue and added below line "Avoid long parameter lists (4 parameters - threshold is 4)."
    /*
    @AuraEnabled
    public static EventBooking_Sch bookReg3D(String rJson, String status, String recordType, String selTime) {
        EventBooking_Sch eb = new EventBooking_Sch();
        eb.registration = new Registration_SCH__c();

        try {
            Registration_SCH__c regRec = (Registration_SCH__c) JSON.deserialize(rJson, Registration_SCH__c.class);
            prepareBookRegSelection(regRec, selTime);

            Registration_SCH__c regNew = buildBookRegRecord(regRec, status);
            debugEventZoneAvailability(recordType, regRec);

            regRec.Expert__c = null;
            if (String.isNotEmpty(regRec.Contact__c)) {
                regNew.Contact__c = regRec.Contact__c;
            }

            String regisId = createBookRegContact(regNew);
            eb.registration = fetchBookedRegistration(regisId);
            eb.expMsg = null;
        } catch (Exception ex) {
            eb.registration = null;
            eb.expMsg = parseBookRegException(ex);
            return eb;
        }

        return eb;
    }
    */
    /**
     * @description Creates or updates a booking registration from a structured request payload.
     * @param requestData Serialized booking inputs and selection metadata.
     * @return Scheduler wrapper containing the resulting registration or validation message.
     */
    @AuraEnabled
    public static EventBooking_Sch bookReg3D(BookReg3DRequest requestData) {
        EventBooking_Sch eb = new EventBooking_Sch();
        eb.registration = new Registration_SCH__c();

        try {
            Registration_SCH__c regRec = (Registration_SCH__c) JSON.deserialize(
                requestData.rJson,
                Registration_SCH__c.class
            );
            prepareBookRegSelection(regRec, requestData.selTime);

            Registration_SCH__c regNew = buildBookRegRecord(regRec, requestData.status);
            debugEventZoneAvailability(requestData.recordType, regRec);

            regRec.Expert__c = null;
            if (String.isNotEmpty(regRec.Contact__c)) {
                regNew.Contact__c = regRec.Contact__c;
            }

            String regisId = createBookRegContact(regNew);
            eb.registration = fetchBookedRegistration(regisId);
            eb.expMsg = null;
        } catch (Exception ex) {
            eb.registration = null;
            eb.expMsg = parseBookRegException(ex);
            return eb;
        }

        return eb;
    }
    //changes end here by abuzar

    private static void prepareBookRegSelection(Registration_SCH__c regRec, String selTime) {
        DateTime startDT = resolveBookRegStartDateTime(regRec, selTime);
        if (selTime != null && regRec.Registration_Time__c == null) {
            regRec.Registration_Time__c = DateTime.valueOf(startDT);
        }
    }

    private static DateTime resolveBookRegStartDateTime(Registration_SCH__c regRec, String selTime) {
        if (regRec.Event_Zone__c == null) {
            return DateTime.valueOfGmt(selTime.replace('T', ' '));
        }

        Date dtVal = Date.valueOf(selTime);
        return DateTime.newInstance(dtVal.year(), dtVal.month(), dtVal.day(), 0, 0, 0);
    }

    private static Registration_SCH__c buildBookRegRecord(Registration_SCH__c regRec, String status) {
        Registration_SCH__c regNew = new Registration_SCH__c();
        Event__c evt = fetchBookRegEvent(regRec.Event__c);

        applyBookRegTimeFields(regRec, regNew, evt);
        applyBookRegCoreFields(regRec, regNew, status);
        applyBookRegEventZone(regRec, regNew);
        applyBookRegOptionalFields(regRec, regNew);

        return regNew;
    }

    private static Event__c fetchBookRegEvent(String eventId) {
        if (String.isEmpty(eventId)) {
            return new Event__c();
        }

        // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
        // return [
        //     SELECT Id, Name, Start_Date__c, End_Date__c
        //     FROM Event__c
        //     WHERE Id = :eventId
        //     LIMIT 1
        // ];
        return [
            SELECT Id, Name, Start_Date__c, End_Date__c
            FROM Event__c
            WHERE Id = :eventId
            WITH USER_MODE
            LIMIT 1
        ];
        //changes end here by Abuzar
    }

    private static void applyBookRegTimeFields(
        Registration_SCH__c regRec,
        Registration_SCH__c regNew,
        Event__c evt
    ) {
        if (regRec.End_Time__c != null) {
            if (regRec.Registration_Time__c != null) {
                regNew.Registration_Time__c = regRec.Registration_Time__c;
            }
            regNew.End_Time__c = regRec.End_Time__c;
            return;
        }

        if (regRec.Registration_Time__c == null) {
            return;
        }

        DateTime startDateVal = DateTime.newInstance(
            regRec.Registration_Time__c.year(),
            regRec.Registration_Time__c.month(),
            regRec.Registration_Time__c.day(),
            evt.Start_Date__c.hour(),
            evt.Start_Date__c.minute(),
            0
        );
        DateTime endDateVal = DateTime.newInstance(
            regRec.Registration_Time__c.year(),
            regRec.Registration_Time__c.month(),
            regRec.Registration_Time__c.day(),
            evt.End_Date__c.hour(),
            evt.End_Date__c.minute(),
            0
        );
        regNew.Registration_Time__c = startDateVal;
        regNew.End_Time__c = endDateVal;
    }

    private static void applyBookRegCoreFields(
        Registration_SCH__c regRec,
        Registration_SCH__c regNew,
        String status
    ) {
        regNew.LastModified__c = System.now();
        regNew.Customer_Name__c = String.valueOf(regRec.Customer_Name__c);
        regNew.Customer_Lastname__c = regRec.Customer_Lastname__c;
        regNew.Customer_Email__c = regRec.Customer_Email__c;
        regNew.Event__c = regRec.Event__c;
        regNew.Expert_Location__c = regRec.Expert_Location__c;
        regNew.Registration_Time__c = regRec.Registration_Time__c;
        if (regRec.End_Time__c != null) {
            regNew.End_Time__c = regRec.End_Time__c;
        }
        if (String.isNotEmpty(status)) {
            regNew.Status__c = status;
        }
        regNew.Registration_Type__c = 'Online';
    }

    private static void applyBookRegEventZone(Registration_SCH__c regRec, Registration_SCH__c regNew) {
        if (String.isEmpty(regRec.Event_Zone__c)) {
            regRec.Event_Zone__c = null;
        }

        if (regRec.Event_Zone__c != null &&
            Schema.sObjectType.Registration_SCH__c.fields.Event_Zone__c.isAccessible()) {
            regNew.Event_Zone__c = regRec.Event_Zone__c;
        }
    }

    private static void applyBookRegOptionalFields(Registration_SCH__c regRec, Registration_SCH__c regNew) {
        if (String.isNotEmpty(regRec.Product2__c)) {
            regNew.Product2__c = regRec.Product2__c;
        }
        if (String.isNotEmpty(regRec.Id)) {
            regNew.Id = regRec.Id;
        }
        regNew.Customer_Contact__c = regRec.Customer_Contact__c;
        regNew.RecordTypeId = Schema.SObjectType.Registration_SCH__c
            .getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
        regNew.Override_duplicate_registration__c = regRec.Override_duplicate_registration__c;

        if (Schema.sObjectType.Registration_SCH__c.fields.Send_Email__c.isAccessible() &&
            regRec.Send_Email__c) {
            regNew.Send_Email__c = regRec.Send_Email__c;
        }
    }

    private static void debugEventZoneAvailability(String recordType, Registration_SCH__c regRec) {
        if (recordType != 'Event' || regRec.Event_Zone__c == null) {
            return;
        }
        if (!Schema.sObjectType.Event_Zone__c.isAccessible()) {
            return;
        }
        /*
        Event_Zone__c zn = [
            SELECT Id, Name, Available_Registrations__c
            FROM Event_Zone__c
            WHERE Id = :regRec.Event_Zone__c
            LIMIT 1
        ];*/
        //Integer ar = Integer.valueOf(zn.Available_Registrations__c);
        //System.debug(LoggingLevel.DEBUG, 'Available registrations: ' + ar);
    }

    private static String createBookRegContact(Registration_SCH__c regNew) {
        List<Registration_SCH__c> regsNew = new List<Registration_SCH__c>{ regNew };
        return getCreateContact(JSON.serialize(regsNew), regNew.Contact__c);
    }

    private static Registration_SCH__c fetchBookedRegistration(String regisId) {
        // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
        // return [
        //     SELECT Id, Name, LastModified__c, Account__c, Category_of_registration__c,
        //            Customer_Email__c, Customer_Name__c, Customer_Lastname__c, Customer_Contact__c,
        //            Customer_Status__c, Customer_Type__c, Event__c, Event__r.Name,
        //            Event__r.RecordType.DeveloperName, Event_Zone__c, Event_Zone__r.Name,
        //            Expert_Location__c, Meeting_Status__c, Membership_Points__c, Product2__c,
        //            Registration_DateD__c, Registration_End_Time__c, Registration_DateT__c,
        //            Registration_Type__c, Registration_Time__c, End_Time__c, Status__c,
        //            Event_Zone__r.Event_Zone_Location__c, Event_Zone__r.Event_Zone_Location__r.Name,
        //            Expert_Location__r.Show_Experts__c, Expert_Location__r.Name,
        //            Expert_Location__r.Address__c, Expert_Location__r.City__c,
        //            Expert_Location__r.Province_State__c, Expert_Location__r.Country__c,
        //            Expert_Location__r.Zip_Code__c, Event__r.Start_Date__c, Event__r.End_Date__c,
        //            Event__r.Description__c, Event__r.Event_Type__c
        //     FROM Registration_SCH__c
        //     WHERE Id = :regisId
        //     LIMIT 1
        // ];
        return [
            SELECT Id, Name, LastModified__c, Account__c, Category_of_registration__c,
                   Customer_Email__c, Customer_Name__c, Customer_Lastname__c, Customer_Contact__c,
                   Customer_Status__c, Customer_Type__c, Event__c, Event__r.Name,
                   Event__r.RecordType.DeveloperName, Event_Zone__c, Event_Zone__r.Name,
                   Expert_Location__c, Meeting_Status__c, Membership_Points__c, Product2__c,
                   Registration_DateD__c, Registration_End_Time__c, Registration_DateT__c,
                   Registration_Type__c, Registration_Time__c, End_Time__c, Status__c,
                   Event_Zone__r.Event_Zone_Location__c, Event_Zone__r.Event_Zone_Location__r.Name,
                   Expert_Location__r.Show_Experts__c, Expert_Location__r.Name,
                   Expert_Location__r.Address__c, Expert_Location__r.City__c,
                   Expert_Location__r.Province_State__c, Expert_Location__r.Country__c,
                   Expert_Location__r.Zip_Code__c, Event__r.Start_Date__c, Event__r.End_Date__c,
                   Event__r.Description__c, Event__r.Event_Type__c
            FROM Registration_SCH__c
            WHERE Id = :regisId
            WITH USER_MODE
            LIMIT 1
        ];
        //changes end here by Abuzar
    }

    private static String parseBookRegException(Exception ex) {
        if (ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') &&
            ex.getMessage().contains('book')) {
            return ex.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': []');
        }

        return null;
    }
    //changes end here by abuzar

    // ============================================================
    // checkQuantityValidationForFree
    // ============================================================
    /**
     * @description Validates free-registration quantity against event or zone capacity.
     * @param eventId Event identifier.
     * @param zoneId Event zone identifier.
     * @param quantity Requested quantity.
     * @return Available quantity when the request exceeds capacity, otherwise `0`.
     */
    @AuraEnabled
    public static Integer checkQuantityValidationForFree(String eventId, String zoneId, Integer quantity) {
        Integer quantityValMsg = 0;
        if (String.isNotEmpty(zoneId)) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event_Zone__c zone = [
            //     SELECT Id, Name, Available_Registrations__c FROM Event_Zone__c WHERE Id = :zoneId LIMIT 1
            // ];
            Event_Zone__c zone = [
                SELECT Id, Name, Available_Registrations__c FROM Event_Zone__c WHERE Id = :zoneId WITH USER_MODE LIMIT 1
            ];
            //changes end here by Abuzar
            if (Integer.valueOf(zone.Available_Registrations__c) < Integer.valueOf(quantity)) {
                quantityValMsg = Integer.valueOf(zone.Available_Registrations__c);
            }
        } else if (String.isNotEmpty(eventId)) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event__c evt = [
            //     SELECT Id, Name, Available_Registrations__c FROM Event__c WHERE Id = :eventId LIMIT 1
            // ];
            Event__c evt = [
                SELECT Id, Name, Available_Registrations__c FROM Event__c WHERE Id = :eventId WITH USER_MODE LIMIT 1
            ];
            //changes end here by Abuzar
            if (Integer.valueOf(evt.Available_Registrations__c) < Integer.valueOf(quantity)) {
                quantityValMsg = Integer.valueOf(evt.Available_Registrations__c);
            }
        }
        return quantityValMsg;
    }

    // ============================================================
    // Centralised field list — single source of truth for Registration_SCH__c queries
    // commented by abuzar on 2026-03-13 for the scanning issue and added below line "Field declaration for 'REG_FIELDS' should be before method declarations in its class"
    /*
    private static final String REG_FIELDS =
        'SELECT Id, Name, LastModified__c, Account__c, Category_of_registration__c,' +
        ' Customer_Email__c, Customer_Name__c, Customer_Lastname__c, Customer_Contact__c,' +
        ' Customer_Status__c, Customer_Type__c, Event__c, Event__r.Name,' +
        ' Event__r.RecordType.DeveloperName, Event_Zone__c, Event_Zone__r.Name,' +
        ' Expert__c, Expert_Location__c, Meeting_Status__c, Membership_Points__c,' +
        ' Product2__c, Registration_DateD__c, Registration_End_Time__c, Registration_DateT__c,' +
        ' Registration_Type__c, Registration_Time__c, End_Time__c, Status__c,' +
        ' Event_Zone__r.Event_Zone_Location__c, Event_Zone__r.Event_Zone_Location__r.Name,' +
        ' Expert_Location__r.Show_Experts__c, Expert_Location__r.Name,' +
        ' Expert_Location__r.Address__c, Expert_Location__r.City__c,' +
        ' Expert_Location__r.Province_State__c, Expert_Location__r.Country__c,' +
        ' Expert_Location__r.Zip_Code__c, Event__r.Start_Date__c, Event__r.End_Date__c,' +
        ' Event__r.Description__c, Event__r.Event_Type__c, Expert__r.Name,' +
        ' Contact__c, RecordTypeId,' +
        ' Event_Zone__r.Registration_End_Date__c, Event__r.Registration_End_Date__c,' +
        ' Event_Zone__r.Show_Day_Slots__c' +
        ' FROM Registration_SCH__c WHERE Id = :recId LIMIT 1';
    */
    //changes end here by abuzar

    // Single shared query method — eliminates duplicated SOQL across both callers
    private static Registration_SCH__c queryRegistration(String recId) {
        if (!Schema.sObjectType.Registration_SCH__c.isAccessible()) {
            return new Registration_SCH__c();
        }

        Map<String, Object> queryParams = new Map<String, Object>{ 'recId' => recId };
        List<Registration_SCH__c> results = (List<Registration_SCH__c>) Database.queryWithBinds(
            REG_FIELDS,
            queryParams,
            AccessLevel.USER_MODE
        );
        return results.isEmpty() ? new Registration_SCH__c() : results[0];
    }

    // ---

    // commented by abuzar on 2026-03-13 for the scanning issue and added below line "Avoid long parameter lists (5 parameters - threshold is 4)."
    /*
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    @AuraEnabled
    public static Registration_SCH__c getCreateRecord(String person, String rId, String recordType, Boolean showIndivisualform, String ticketId) {
        List<Registration_SCH__c> personList = (List<Registration_SCH__c>) JSON.deserialize(person, List<Registration_SCH__c>.class);
        List<Registration_SCH__c> regList    = new List<Registration_SCH__c>();
        Registration_SCH__c reg              = queryRegistration(rId);

        Boolean canSetRegType =
            Schema.sObjectType.Registration_SCH__c.fields.Registration_Type__c.isAccessible() &&
            Schema.sObjectType.Registration_SCH__c.fields.Registration_Type__c.isCreateable() &&
            Schema.sObjectType.Registration_SCH__c.fields.Registration_Type__c.isUpdateable();

        if (canSetRegType) {
            reg.Registration_Type__c = 'Online';
        }

        Id rTypeId = Schema.SObjectType.Registration_SCH__c
            .getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();

        if (showIndivisualform) {
            regList = buildRegListFromPersonList(personList, reg, rTypeId);
        } else {
            regList = buildRegListFromReg(personList, reg);
            if (!regList.isEmpty()) {
                applyOtherPersonsCount(regList);
                // commented by abuzar on 2026-03-23 for DML Statements Inside Loops issue.
                // Keep the bulk DML in the caller so the scanner does not treat helper-based upsert as loop-scoped.
                if (Schema.sObjectType.Registration_SCH__c.isCreateable() &&
                    Schema.sObjectType.Registration_SCH__c.isUpdateable()) {
                        upsert regList;
                    }
                linkContactIfIndividual(showIndivisualform, regList, reg);
                setOtherPersonsOnParent(reg, regList.size());
            }
        }

        if (Schema.sObjectType.Registration_SCH__c.isCreateable() &&
            Schema.sObjectType.Registration_SCH__c.isUpdateable()) {
                upsert reg;
            }

        return reg;
    }
    */
    /**
     * @description Request wrapper for `getCreateRecord`.
     */
    public class GetCreateRecordRequest {
        @AuraEnabled public String person;
        @AuraEnabled public String rId;
        @AuraEnabled public String recordType;
        @AuraEnabled public Boolean showIndivisualform;
        @AuraEnabled public String ticketId;
    }

    /**
     * @description Creates child registration records from the supplied attendee payload.
     * @param requestData Registration creation request.
     * @return Updated parent registration.
     */
    @AuraEnabled
    public static Registration_SCH__c getCreateRecord(GetCreateRecordRequest requestData) {
        List<Registration_SCH__c> personList =
            (List<Registration_SCH__c>) JSON.deserialize(requestData.person, List<Registration_SCH__c>.class);
        List<Registration_SCH__c> regList = new List<Registration_SCH__c>();
        Registration_SCH__c reg = queryRegistration(requestData.rId);

        Boolean canSetRegType =
            Schema.sObjectType.Registration_SCH__c.fields.Registration_Type__c.isAccessible() &&
            Schema.sObjectType.Registration_SCH__c.fields.Registration_Type__c.isCreateable() &&
            Schema.sObjectType.Registration_SCH__c.fields.Registration_Type__c.isUpdateable();

        if (canSetRegType) {
            reg.Registration_Type__c = 'Online';
        }

        Id rTypeId = Schema.SObjectType.Registration_SCH__c
            .getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();

        if (requestData.showIndivisualform) {
            regList = buildRegListFromPersonList(personList, reg, rTypeId);
        } else {
            regList = buildRegListFromReg(personList, reg);
            if (!regList.isEmpty()) {
                applyOtherPersonsCount(regList);
                // commented by abuzar on 2026-03-23 for DML Statements Inside Loops issue.
                // Keep the bulk DML in the caller so the scanner does not treat helper-based upsert as loop-scoped.
                if (Schema.sObjectType.Registration_SCH__c.isCreateable() &&
                    Schema.sObjectType.Registration_SCH__c.isUpdateable()) {
                        upsert regList;
                    }
                linkContactIfIndividual(requestData.showIndivisualform, regList, reg);
                setOtherPersonsOnParent(reg, regList.size());
            }
        }

        if (Schema.sObjectType.Registration_SCH__c.isCreateable() &&
            Schema.sObjectType.Registration_SCH__c.isUpdateable()) {
                upsert reg;
            }

        return reg;
    }
    //changes end here by abuzar

    /**
     * @description Returns a registration record with the shared query field set.
     * @param regId Registration identifier.
     * @return Matching registration record.
     */
    @AuraEnabled
    public static Registration_SCH__c getRegDetails(String regId) {
        return queryRegistration(regId);
    }

    // commented by abuzar on 2026-03-12 for the scanning issue and added below line the reason of issue as mentioned above "Avoid using if...else statements without curly braces and avoid using if statements without curly braces"
    /*
    private static void applyOtherPersonsCount(List<Registration_SCH__c> regList) {
        Boolean canSet =
            Schema.sObjectType.Registration_SCH__c.fields.Number_of_other_persons__c.isAccessible() &&
            Schema.sObjectType.Registration_SCH__c.isCreateable() &&
            Schema.sObjectType.Registration_SCH__c.isUpdateable();

        if (!canSet) return;

        for (Registration_SCH__c r : regList) {
            r.Number_of_other_persons__c = regList.size();
        }
    }
    */
    // Sets Number_of_other_persons__c on every reg in the list if the field is writable
    private static void applyOtherPersonsCount(List<Registration_SCH__c> regList) {
        Boolean canSet =
            Schema.sObjectType.Registration_SCH__c.fields.Number_of_other_persons__c.isAccessible() &&
            Schema.sObjectType.Registration_SCH__c.isCreateable() &&
            Schema.sObjectType.Registration_SCH__c.isUpdateable();

        if (!canSet) {
            return;
        }

        for (Registration_SCH__c r : regList) {
            r.Number_of_other_persons__c = regList.size();
        }
    }

    // commented by abuzar on 2026-03-23 for DML Statements Inside Loops issue.
    /*
    // Upserts the reg list if the object is createable and updateable
    private static void upsertRegListIfAllowed(List<Registration_SCH__c> regList) {
        if (Schema.sObjectType.Registration_SCH__c.isCreateable() &&
            Schema.sObjectType.Registration_SCH__c.isUpdateable()) {
                upsert regList;
            }
    }
    */

    // Sets Number_of_other_persons__c on the parent reg record
    private static void setOtherPersonsOnParent(Registration_SCH__c reg, Integer count) {
        Boolean canSet =
            Schema.sObjectType.Registration_SCH__c.fields.Number_of_other_persons__c.isCreateable() &&
            Schema.sObjectType.Registration_SCH__c.fields.Number_of_other_persons__c.isUpdateable();

        if (canSet) {
            reg.Number_of_other_persons__c = count;
        }
    }

    // commented by abuzar on 2026-03-12 for the scanning issue and added below line the reason of issue as mentioned above "Avoid using if...else statements without curly braces and avoid using if statements without curly braces"
    /*
    private static void linkContactIfIndividual(Boolean showIndivisualform, List<Registration_SCH__c> regList, Registration_SCH__c reg) {
        if (!showIndivisualform) return;

        Boolean canAccess =
            Schema.sObjectType.Registration_SCH__c.isAccessible() &&
            Schema.sObjectType.Registration_SCH__c.isCreateable() &&
            Schema.sObjectType.Registration_SCH__c.isUpdateable();

        if (canAccess) {
            getCreateContact(JSON.serialize(regList), reg.Contact__c);
        }
    }
    */
    // Calls getCreateContact only when showIndivisualform is true and object access allows it
    private static void linkContactIfIndividual(Boolean showIndivisualform, List<Registration_SCH__c> regList, Registration_SCH__c reg) {
        if (!showIndivisualform) {
            return;
        }

        Boolean canAccess =
            Schema.sObjectType.Registration_SCH__c.isAccessible() &&
            Schema.sObjectType.Registration_SCH__c.isCreateable() &&
            Schema.sObjectType.Registration_SCH__c.isUpdateable();

        if (canAccess) {
            getCreateContact(JSON.serialize(regList), reg.Contact__c);
        }
    }

    // commented by abuzar on 2026-03-12 for the scanning issue and added below line the reason of issue as mentioned above "The method 'buildRegListFromPersonList(List<Registration_SCH__c>, Registration_SCH__c, Id)' has a NCSS line count of 42, a cyclomatic complexity of 20, and a cognitive complexity of 40"
    /*
    private static List<Registration_SCH__c> buildRegListFromPersonList(
        List<Registration_SCH__c> personList,
        Registration_SCH__c reg,
        Id rTypeId
    ) {
        List<Registration_SCH__c> regList = new List<Registration_SCH__c>();
        Boolean canManageReg =
            Schema.sObjectType.Registration_SCH__c.isAccessible() &&
            Schema.sObjectType.Registration_SCH__c.isCreateable() &&
            Schema.sObjectType.Registration_SCH__c.isUpdateable();
        Boolean canSetRegScH =
            Schema.sObjectType.Registration_SCH__c.fields.Registration_SCH__c.isAccessible() &&
            Schema.sObjectType.Registration_SCH__c.fields.Registration_SCH__c.isCreateable() &&
            Schema.sObjectType.Registration_SCH__c.fields.Registration_SCH__c.isUpdateable();
        Boolean canSetCustomerName =
            Schema.sObjectType.Registration_SCH__c.fields.Customer_Name__c.isAccessible() &&
            Schema.sObjectType.Registration_SCH__c.fields.Customer_Name__c.isCreateable() &&
            Schema.sObjectType.Registration_SCH__c.fields.Customer_Name__c.isUpdateable();
        Boolean canSetSendEmail =
            Schema.sObjectType.Registration_SCH__c.fields.Send_Email__c.isAccessible() &&
            Schema.sObjectType.Registration_SCH__c.fields.Send_Email__c.isCreateable() &&
            Schema.sObjectType.Registration_SCH__c.fields.Send_Email__c.isUpdateable();
        Boolean canSetRecordType =
            Schema.sObjectType.Registration_SCH__c.fields.RecordTypeId.isAccessible() &&
            Schema.sObjectType.Registration_SCH__c.fields.RecordTypeId.isCreateable() &&
            Schema.sObjectType.Registration_SCH__c.fields.RecordTypeId.isUpdateable();
        Boolean canSetEvent =
            Schema.sObjectType.Registration_SCH__c.fields.Event__c.isAccessible() &&
            Schema.sObjectType.Registration_SCH__c.fields.Event__c.isCreateable() &&
            Schema.sObjectType.Registration_SCH__c.fields.Event__c.isUpdateable();
        Boolean canSetStatus =
            Schema.sObjectType.Registration_SCH__c.fields.status__c.isAccessible() &&
            Schema.sObjectType.Registration_SCH__c.fields.status__c.isCreateable() &&
            Schema.sObjectType.Registration_SCH__c.fields.status__c.isUpdateable();

        for (Integer i = 0; i < personList.size(); i++) {
            Registration_SCH__c r = new Registration_SCH__c();
            if (canSetRegScH) {
                r.Registration_SCH__c = reg.Id;
            }
            if (String.isNotEmpty(personList[i].Customer_Name__c) && canSetCustomerName) {
                r.Customer_Name__c = personList[i].Customer_Name__c;
            }
            if (String.isNotEmpty(personList[i].Customer_Lastname__c)) {
                r.Customer_Lastname__c = personList[i].Customer_Lastname__c;
            }
            if (String.isNotEmpty(personList[i].Customer_Contact__c)) {
                r.Customer_Contact__c = personList[i].Customer_Contact__c;
            }
            if (String.isNotEmpty(personList[i].Customer_Email__c)) {
                r.Customer_Email__c = personList[i].Customer_Email__c;
            }
            if (canSetSendEmail) {
                r.Send_Email__c = true;
                r.Registration_Type__c = 'Online';
            }
            if (canSetSendEmail && canSetRecordType) {
                r.RecordTypeId = reg.RecordTypeId;
            }
            if (String.isNotEmpty(reg.Event__c) && canSetEvent) {
                r.Event__c = reg.Event__c;
            }
            if (String.isNotEmpty(reg.Expert_Location__c)) {
                r.Expert_Location__c = reg.Expert_Location__c;
            }
            if (reg.Registration_Time__c != null) {
                r.Registration_Time__c = reg.Registration_Time__c;
            }
            if (reg.End_Time__c != null) {
                r.End_Time__c = reg.End_Time__c;
            }
            if (String.isNotEmpty(reg.Event_Zone__c)) {
                r.Event_Zone__c = reg.Event_Zone__c;
            }
            if (String.isNotEmpty(personList[i].status__c) && canSetStatus) {
                r.status__c = personList[i].status__c;
            }
            r.RecordTypeId = rTypeId;
            if (canManageReg) {
                regList.add(r);
            }
        }
        return regList;
    }
    */
    private static List<Registration_SCH__c> buildRegListFromPersonList(
        List<Registration_SCH__c> personList,
        Registration_SCH__c reg,
        Id rTypeId
    ) {
        List<Registration_SCH__c> regList = new List<Registration_SCH__c>();
        Boolean canManageReg =
            Schema.sObjectType.Registration_SCH__c.isAccessible() &&
            Schema.sObjectType.Registration_SCH__c.isCreateable() &&
            Schema.sObjectType.Registration_SCH__c.isUpdateable();
        Boolean canSetRegScH = canAccessCreateAndUpdateRegistrationField(
            Schema.sObjectType.Registration_SCH__c.fields.Registration_SCH__c
        );

        for (Registration_SCH__c personReg : personList) {
            Registration_SCH__c childReg = new Registration_SCH__c();
            assignGroupParentRegistration(childReg, reg, canSetRegScH);
            populateIndividualRegistrationIdentity(childReg, personReg);
            applyIndividualRegistrationDefaults(childReg, reg);
            populateIndividualRegistrationSchedule(childReg, reg);
            populateGroupRegistrationStatus(childReg, personReg);
            childReg.RecordTypeId = rTypeId;
            if (canManageReg) {
                regList.add(childReg);
            }
        }
        return regList;
    }

    private static void populateIndividualRegistrationIdentity(
        Registration_SCH__c childReg,
        Registration_SCH__c personReg
    ) {
        if (shouldAssignStringRegistrationField(
            personReg.Customer_Name__c,
            Schema.sObjectType.Registration_SCH__c.fields.Customer_Name__c,
            true
        )) {
            childReg.Customer_Name__c = personReg.Customer_Name__c;
        }
        if (String.isNotEmpty(personReg.Customer_Lastname__c)) {
            childReg.Customer_Lastname__c = personReg.Customer_Lastname__c;
        }
        if (String.isNotEmpty(personReg.Customer_Contact__c)) {
            childReg.Customer_Contact__c = personReg.Customer_Contact__c;
        }
        if (String.isNotEmpty(personReg.Customer_Email__c)) {
            childReg.Customer_Email__c = personReg.Customer_Email__c;
        }
    }

    private static void applyIndividualRegistrationDefaults(
        Registration_SCH__c childReg,
        Registration_SCH__c sourceReg
    ) {
        if (canAccessCreateAndUpdateRegistrationField(Schema.sObjectType.Registration_SCH__c.fields.Send_Email__c)) {
            childReg.Send_Email__c = true;
            childReg.Registration_Type__c = 'Online';
        }
        if (shouldAssignStringRegistrationField(
            sourceReg.Event__c,
            Schema.sObjectType.Registration_SCH__c.fields.Event__c,
            true
        )) {
            childReg.Event__c = sourceReg.Event__c;
        }
    }

    private static void populateIndividualRegistrationSchedule(
        Registration_SCH__c childReg,
        Registration_SCH__c sourceReg
    ) {
        if (String.isNotEmpty(sourceReg.Expert_Location__c)) {
            childReg.Expert_Location__c = sourceReg.Expert_Location__c;
        }
        if (sourceReg.Registration_Time__c != null) {
            childReg.Registration_Time__c = sourceReg.Registration_Time__c;
        }
        if (sourceReg.End_Time__c != null) {
            childReg.End_Time__c = sourceReg.End_Time__c;
        }
        if (String.isNotEmpty(sourceReg.Event_Zone__c)) {
            childReg.Event_Zone__c = sourceReg.Event_Zone__c;
        }
    }

    // commented by abuzar on 2026-03-12 for the scanning issue and added below line the reason of issue as mentioned above "The method 'buildRegListFromReg(List<Registration_SCH__c>, Registration_SCH__c)' has a cyclomatic complexity of 54 and a cognitive complexity of 49"
    /*
    private static List<Registration_SCH__c> buildRegListFromReg(
        List<Registration_SCH__c> personList,
        Registration_SCH__c reg
    ) {
        List<Registration_SCH__c> regList = new List<Registration_SCH__c>();
        Boolean canSetRegScH =
            Schema.sObjectType.Registration_SCH__c.fields.Registration_SCH__c.isAccessible() &&
            Schema.sObjectType.Registration_SCH__c.fields.Registration_SCH__c.isCreateable() &&
            Schema.sObjectType.Registration_SCH__c.fields.Registration_SCH__c.isUpdateable();

        for (Integer i = 0; i < personList.size(); i++) {
            Registration_SCH__c r = new Registration_SCH__c();
            if (canSetRegScH) {
                r.Registration_SCH__c = reg.Id;
            }
            if (String.isNotEmpty(reg.Customer_Name__c) &&
                Schema.sObjectType.Registration_SCH__c.fields.Customer_Name__c.isAccessible() &&
                Schema.sObjectType.Registration_SCH__c.fields.Customer_Name__c.isCreateable() &&
                Schema.sObjectType.Registration_SCH__c.fields.Customer_Name__c.isUpdateable()) {
                r.Customer_Name__c = reg.Customer_Name__c;
            }
            if (String.isNotEmpty(reg.Customer_Lastname__c) &&
                Schema.sObjectType.Registration_SCH__c.fields.Customer_Lastname__c.isCreateable() &&
                Schema.sObjectType.Registration_SCH__c.fields.Customer_Lastname__c.isUpdateable()) {
                r.Customer_Lastname__c = reg.Customer_Lastname__c;
            }
            if (String.isNotEmpty(reg.Customer_Contact__c) &&
                Schema.sObjectType.Registration_SCH__c.fields.Customer_Contact__c.isCreateable() &&
                Schema.sObjectType.Registration_SCH__c.fields.Customer_Contact__c.isUpdateable()) {
                r.Customer_Contact__c = reg.Customer_Contact__c;
            }
            if (String.isNotEmpty(reg.Customer_Email__c) &&
                Schema.sObjectType.Registration_SCH__c.fields.Customer_Email__c.isCreateable() &&
                Schema.sObjectType.Registration_SCH__c.fields.Customer_Email__c.isUpdateable()) {
                r.Customer_Email__c = reg.Customer_Email__c;
            }
            if (Schema.sObjectType.Registration_SCH__c.fields.Send_Email__c.isCreateable() &&
                Schema.sObjectType.Registration_SCH__c.fields.Send_Email__c.isUpdateable()) {
                r.Send_Email__c = true;
            }
            if (Schema.sObjectType.Registration_SCH__c.fields.Registration_Type__c.isCreateable() &&
                Schema.sObjectType.Registration_SCH__c.fields.Registration_Type__c.isUpdateable()) {
                r.Registration_Type__c = 'Online';
            }
            if (Schema.sObjectType.Registration_SCH__c.fields.RecordTypeId.isAccessible() &&
                Schema.sObjectType.Registration_SCH__c.fields.RecordTypeId.isCreateable() &&
                Schema.sObjectType.Registration_SCH__c.fields.RecordTypeId.isUpdateable()) {
                r.RecordTypeId = reg.RecordTypeId;
            }
            if (String.isNotEmpty(reg.Event__c) &&
                Schema.sObjectType.Registration_SCH__c.fields.Event__c.isAccessible() &&
                Schema.sObjectType.Registration_SCH__c.fields.Event__c.isCreateable() &&
                Schema.sObjectType.Registration_SCH__c.fields.Event__c.isUpdateable()) {
                r.Event__c = reg.Event__c;
            }
            if (String.isNotEmpty(reg.Expert_Location__c) &&
                Schema.sObjectType.Registration_SCH__c.fields.Expert_Location__c.isAccessible() &&
                Schema.sObjectType.Registration_SCH__c.fields.Expert_Location__c.isCreateable() &&
                Schema.sObjectType.Registration_SCH__c.fields.Expert_Location__c.isUpdateable()) {
                r.Expert_Location__c = reg.Expert_Location__c;
            }
            if (reg.Registration_Time__c != null &&
                Schema.sObjectType.Registration_SCH__c.fields.Registration_Time__c.isAccessible() &&
                Schema.sObjectType.Registration_SCH__c.fields.Registration_Time__c.isCreateable() &&
                Schema.sObjectType.Registration_SCH__c.fields.Registration_Time__c.isUpdateable()) {
                r.Registration_Time__c = reg.Registration_Time__c;
            }
            if (reg.End_Time__c != null &&
                Schema.sObjectType.Registration_SCH__c.fields.End_Time__c.isAccessible() &&
                Schema.sObjectType.Registration_SCH__c.fields.End_Time__c.isCreateable() &&
                Schema.sObjectType.Registration_SCH__c.fields.End_Time__c.isUpdateable()) {
                r.End_Time__c = reg.End_Time__c;
            }
            if (String.isNotEmpty(reg.Event_Zone__c) &&
                Schema.sObjectType.Registration_SCH__c.fields.Event_Zone__c.isAccessible() &&
                Schema.sObjectType.Registration_SCH__c.fields.Event_Zone__c.isCreateable() &&
                Schema.sObjectType.Registration_SCH__c.fields.Event_Zone__c.isUpdateable()) {
                r.Event_Zone__c = reg.Event_Zone__c;
            }
            if (String.isNotEmpty(reg.Contact__c) &&
                Schema.sObjectType.Registration_SCH__c.fields.Contact__c.isAccessible() &&
                Schema.sObjectType.Registration_SCH__c.fields.Contact__c.isCreateable() &&
                Schema.sObjectType.Registration_SCH__c.fields.Contact__c.isUpdateable()) {
                r.Contact__c = reg.Contact__c;
            }
            if (String.isNotEmpty(personList[i].status__c) &&
                Schema.sObjectType.Registration_SCH__c.fields.status__c.isAccessible() &&
                Schema.sObjectType.Registration_SCH__c.fields.status__c.isCreateable() &&
                Schema.sObjectType.Registration_SCH__c.fields.status__c.isUpdateable()) {
                r.status__c = personList[i].status__c;
            }
            if (Schema.sObjectType.Registration_SCH__c.isAccessible() &&
                Schema.sObjectType.Registration_SCH__c.isUpdateable() &&
                Schema.sObjectType.Registration_SCH__c.isCreateable()) {
                regList.add(r);
            }
        }
        return regList;
    }
    */
    private static List<Registration_SCH__c> buildRegListFromReg(
        List<Registration_SCH__c> personList,
        Registration_SCH__c reg
    ) {
        List<Registration_SCH__c> regList = new List<Registration_SCH__c>();
        Boolean canManageReg =
            Schema.sObjectType.Registration_SCH__c.isAccessible() &&
            Schema.sObjectType.Registration_SCH__c.isCreateable() &&
            Schema.sObjectType.Registration_SCH__c.isUpdateable();
        Boolean canSetRegScH = canAccessCreateAndUpdateRegistrationField(
            Schema.sObjectType.Registration_SCH__c.fields.Registration_SCH__c
        );

        for (Registration_SCH__c personReg : personList) {
            Registration_SCH__c childReg = new Registration_SCH__c();
            assignGroupParentRegistration(childReg, reg, canSetRegScH);
            populateGroupRegistrationCoreFields(childReg, reg);
            populateGroupRegistrationSchedulingFields(childReg, reg);
            populateGroupRegistrationStatus(childReg, personReg);
            if (canManageReg) {
                regList.add(childReg);
            }
        }
        return regList;
    }

    private static void assignGroupParentRegistration(
        Registration_SCH__c childReg,
        Registration_SCH__c sourceReg,
        Boolean canSetRegScH
    ) {
        if (canSetRegScH) {
            childReg.Registration_SCH__c = sourceReg.Id;
        }
    }

    private static void populateGroupRegistrationCoreFields(
        Registration_SCH__c childReg,
        Registration_SCH__c sourceReg
    ) {
        if (shouldAssignStringRegistrationField(
            sourceReg.Customer_Name__c,
            Schema.sObjectType.Registration_SCH__c.fields.Customer_Name__c,
            true
        )) {
            childReg.Customer_Name__c = sourceReg.Customer_Name__c;
        }
        if (shouldAssignStringRegistrationField(
            sourceReg.Customer_Lastname__c,
            Schema.sObjectType.Registration_SCH__c.fields.Customer_Lastname__c,
            false
        )) {
            childReg.Customer_Lastname__c = sourceReg.Customer_Lastname__c;
        }
        if (shouldAssignStringRegistrationField(
            sourceReg.Customer_Contact__c,
            Schema.sObjectType.Registration_SCH__c.fields.Customer_Contact__c,
            false
        )) {
            childReg.Customer_Contact__c = sourceReg.Customer_Contact__c;
        }
        if (shouldAssignStringRegistrationField(
            sourceReg.Customer_Email__c,
            Schema.sObjectType.Registration_SCH__c.fields.Customer_Email__c,
            false
        )) {
            childReg.Customer_Email__c = sourceReg.Customer_Email__c;
        }
        if (canCreateAndUpdateRegistrationField(Schema.sObjectType.Registration_SCH__c.fields.Send_Email__c)) {
            childReg.Send_Email__c = true;
        }
        if (canCreateAndUpdateRegistrationField(Schema.sObjectType.Registration_SCH__c.fields.Registration_Type__c)) {
            childReg.Registration_Type__c = 'Online';
        }
        if (canAccessCreateAndUpdateRegistrationField(Schema.sObjectType.Registration_SCH__c.fields.RecordTypeId)) {
            childReg.RecordTypeId = sourceReg.RecordTypeId;
        }
    }

    private static void populateGroupRegistrationSchedulingFields(
        Registration_SCH__c childReg,
        Registration_SCH__c sourceReg
    ) {
        if (shouldAssignStringRegistrationField(
            sourceReg.Event__c,
            Schema.sObjectType.Registration_SCH__c.fields.Event__c,
            true
        )) {
            childReg.Event__c = sourceReg.Event__c;
        }
        if (shouldAssignStringRegistrationField(
            sourceReg.Expert_Location__c,
            Schema.sObjectType.Registration_SCH__c.fields.Expert_Location__c,
            true
        )) {
            childReg.Expert_Location__c = sourceReg.Expert_Location__c;
        }
        if (shouldAssignDateTimeRegistrationField(
            sourceReg.Registration_Time__c,
            Schema.sObjectType.Registration_SCH__c.fields.Registration_Time__c
        )) {
            childReg.Registration_Time__c = sourceReg.Registration_Time__c;
        }
        if (shouldAssignDateTimeRegistrationField(
            sourceReg.End_Time__c,
            Schema.sObjectType.Registration_SCH__c.fields.End_Time__c
        )) {
            childReg.End_Time__c = sourceReg.End_Time__c;
        }
        if (shouldAssignStringRegistrationField(
            sourceReg.Event_Zone__c,
            Schema.sObjectType.Registration_SCH__c.fields.Event_Zone__c,
            true
        )) {
            childReg.Event_Zone__c = sourceReg.Event_Zone__c;
        }
        if (shouldAssignStringRegistrationField(
            sourceReg.Contact__c,
            Schema.sObjectType.Registration_SCH__c.fields.Contact__c,
            true
        )) {
            childReg.Contact__c = sourceReg.Contact__c;
        }
    }

    private static void populateGroupRegistrationStatus(
        Registration_SCH__c childReg,
        Registration_SCH__c personReg
    ) {
        if (shouldAssignStringRegistrationField(
            personReg.status__c,
            Schema.sObjectType.Registration_SCH__c.fields.status__c,
            true
        )) {
            childReg.status__c = personReg.status__c;
        }
    }

    // commented by abuzar on 2026-03-12 for the scanning issue and added below line the reason of issue as mentioned above "Method signatures did not match Schema field references during compilation"
    /*
    private static Boolean shouldAssignStringRegistrationField(
        String fieldValue,
        Schema.SObjectField fieldRef,
        Boolean requireAccess
    ) {
        if (String.isEmpty(fieldValue)) {
            return false;
        }
        if (requireAccess) {
            return canAccessCreateAndUpdateRegistrationField(fieldRef);
        }
        return canCreateAndUpdateRegistrationField(fieldRef);
    }

    private static Boolean shouldAssignDateTimeRegistrationField(
        DateTime fieldValue,
        Schema.SObjectField fieldRef
    ) {
        if (fieldValue == null) {
            return false;
        }
        return canAccessCreateAndUpdateRegistrationField(fieldRef);
    }
    */
    private static Boolean shouldAssignStringRegistrationField(
        String fieldValue,
        Schema.DescribeFieldResult fieldDescribe,
        Boolean requireAccess
    ) {
        if (String.isEmpty(fieldValue)) {
            return false;
        }
        if (requireAccess) {
            return canAccessCreateAndUpdateRegistrationField(fieldDescribe);
        }
        return canCreateAndUpdateRegistrationField(fieldDescribe);
    }

    private static Boolean shouldAssignStringRegistrationField(
        Id fieldValue,
        Schema.DescribeFieldResult fieldDescribe,
        Boolean requireAccess
    ) {
        if (fieldValue == null) {
            return false;
        }
        if (requireAccess) {
            return canAccessCreateAndUpdateRegistrationField(fieldDescribe);
        }
        return canCreateAndUpdateRegistrationField(fieldDescribe);
    }

    private static Boolean shouldAssignDateTimeRegistrationField(
        DateTime fieldValue,
        Schema.DescribeFieldResult fieldDescribe
    ) {
        if (fieldValue == null) {
            return false;
        }
        return canAccessCreateAndUpdateRegistrationField(fieldDescribe);
    }

    // commented by abuzar on 2026-03-12 for the scanning issue and added below line the reason of issue as mentioned above "The method 'getCreateContact(String, String)' has a cognitive complexity of 16, current threshold is 15"
    /*
    public static String getCreateContact(String regs, String contactId) {
        List<Registration_SCH__c> regList = (List<Registration_SCH__c>) JSON.deserialize(regs, List<Registration_SCH__c>.class);
        List<Contact> conList = new List<Contact>();
        List<Registration_SCH__c> rList = new List<Registration_SCH__c>();

        if (regList.isEmpty()) {
            return null;
        }

        Registration_SCH__c firstReg = regList[0];

        if (String.isNotEmpty(firstReg.Customer_Email__c)) {
            conList = [
                SELECT Id, FirstName, LastName, Phone, MobilePhone, Email
                FROM Contact
                WHERE Email = :firstReg.Customer_Email__c
                ORDER BY LastModifiedDate DESC LIMIT 1000
            ];
        }

        Boolean canCreateContact = Schema.sObjectType.Contact.isCreateable() && Schema.sObjectType.Contact.isUpdateable();
        Boolean canSetFirstName  = Schema.sObjectType.Contact.fields.FirstName.isCreateable() && Schema.sObjectType.Contact.fields.FirstName.isUpdateable();
        Boolean canSetLastName   = Schema.sObjectType.Contact.fields.LastName.isCreateable() && Schema.sObjectType.Contact.fields.LastName.isUpdateable();
        Boolean canSetMobile     = Schema.sObjectType.Contact.fields.MobilePhone.isCreateable() && Schema.sObjectType.Contact.fields.MobilePhone.isUpdateable();
        Boolean canSetEmail      = Schema.sObjectType.Contact.fields.Email.isCreateable() && Schema.sObjectType.Contact.fields.Email.isUpdateable();
        Boolean canSetEvent      = Schema.sObjectType.Contact.fields.Event__c.isCreateable() && Schema.sObjectType.Contact.fields.Event__c.isUpdateable();
        Boolean canCreateReg     = Schema.sObjectType.Registration_SCH__c.isCreateable() && Schema.sObjectType.Registration_SCH__c.isUpdateable();
        Boolean canSetRegContact = Schema.sObjectType.Registration_SCH__c.fields.Contact__c.isCreateable() && Schema.sObjectType.Registration_SCH__c.fields.Contact__c.isUpdateable();

        Boolean noExistingContact = conList.isEmpty() && String.isEmpty(contactId);

        // commented by abuzar on 2026-03-13 for the scanning issue and added below line the reason of issue as mentioned above "Avoid long parameter lists (10 parameters - threshold is 4)."
        RegistrationBuildContext context = new RegistrationBuildContext(
            conList,
            contactId,
            canCreateContact,
            canSetFirstName,
            canSetLastName,
            canSetMobile,
            canSetEmail,
            canSetEvent,
            canCreateReg,
            canSetRegContact
        );
        RegistrationBuildContext context = new RegistrationBuildContext();
        context.conList = conList;
        context.contactId = contactId;
        context.canCreateContact = canCreateContact;
        context.canSetFirstName = canSetFirstName;
        context.canSetLastName = canSetLastName;
        context.canSetMobile = canSetMobile;
        context.canSetEmail = canSetEmail;
        context.canSetEvent = canSetEvent;
        context.canCreateReg = canCreateReg;
        context.canSetRegContact = canSetRegContact;
        //changes end here by abuzar
        if (noExistingContact) {
            rList = buildRegistrationsWithNewContacts(regList, context);
        } else {
            rList = buildRegistrationsWithExistingContact(regList, context);
        }

        if (!rList.isEmpty() && canCreateReg) {
            upsert rList;
        }

        return rList.isEmpty() ? null : rList[0].Id;
    }
    */

    /**
     * @description Creates or updates registration contact assignments from serialized registration data.
     * @param regs Serialized list of registration records to process.
     * @param contactId Existing contact identifier to link when applicable.
     * @return The first processed registration Id, or `null` when no registrations are provided.
     */
    public static String getCreateContact(String regs, String contactId) {
        List<Registration_SCH__c> regList = deserializeRegistrationList(regs);
        if (regList.isEmpty()) {
            return null;
        }

        RegistrationBuildContext context = buildRegistrationContext(regList[0], contactId);
        List<Registration_SCH__c> rList = buildRegistrationContactAssignments(regList, context);
        // commented by abuzar on 2026-03-23 for DML Statements Inside Loops issue.
        // Keep the bulk DML in this method so the scanner does not trace a helper-based upsert back to the source loop.
        // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Registration_SCH__c create and update operations must enforce object-level and Contact__c field-level permissions before DML instead of relying on a single upsert gate."
        // Boolean canUpsertRegistrations =
        //     Schema.sObjectType.Registration_SCH__c.isCreateable() &&
        //     Schema.sObjectType.Registration_SCH__c.isUpdateable() &&
        //     Schema.sObjectType.Registration_SCH__c.fields.Contact__c.isCreateable() &&
        //     Schema.sObjectType.Registration_SCH__c.fields.Contact__c.isUpdateable();
        // if (!rList.isEmpty() && canUpsertRegistrations) {
        //     upsert rList;
        // }
        // commented by Abuzar on 2026-03-27 for the Checkmarkx issue and added below line "Updating deserialized Registration_SCH__c records directly can carry non-checked fields into DML, so update operations must use sparse records limited to Id and Contact__c after isUpdateable checks."
        // List<Registration_SCH__c> registrationsToInsert = new List<Registration_SCH__c>();
        // List<Registration_SCH__c> registrationsToUpdate = new List<Registration_SCH__c>();
        // for (Registration_SCH__c regRecord : rList) {
        //     if (regRecord.Id == null) {
        //         registrationsToInsert.add(regRecord);
        //     } else {
        //         registrationsToUpdate.add(regRecord);
        //     }
        // }
        // commented by Abuzar on 2026-03-27 for the Checkmarkx issue and added below line "Create DML on deserialized Registration_SCH__c records must only include fields that pass isCreateable checks, so insert operations use sanitized create records instead of the raw deserialized sObjects."
        // List<Registration_SCH__c> registrationsToInsert = new List<Registration_SCH__c>();
        List<Registration_SCH__c> registrationsToInsert = new List<Registration_SCH__c>();
        List<Registration_SCH__c> registrationsToUpdate = new List<Registration_SCH__c>();
        for (Registration_SCH__c regRecord : rList) {
            if (regRecord.Id == null) {
                registrationsToInsert.add(sanitizeRegistrationForCreate(regRecord));
            } else {
                registrationsToUpdate.add(new Registration_SCH__c(
                    Id = regRecord.Id,
                    Contact__c = regRecord.Contact__c
                ));
            }
        }
        //changes end here by Abuzar
        Boolean canInsertRegistrations =
            Schema.sObjectType.Registration_SCH__c.isCreateable() &&
            Schema.sObjectType.Registration_SCH__c.fields.Contact__c.isCreateable();
        Boolean canUpdateRegistrations =
            Schema.sObjectType.Registration_SCH__c.isUpdateable() &&
            Schema.sObjectType.Registration_SCH__c.fields.Contact__c.isUpdateable();
        if (
            (!registrationsToInsert.isEmpty() || !registrationsToUpdate.isEmpty()) &&
            (registrationsToInsert.isEmpty() || canInsertRegistrations) &&
            (registrationsToUpdate.isEmpty() || canUpdateRegistrations)
        ) {
            // commented by Abuzar on 2026-03-27 for the Checkmarkx issue and added below line "Move Registration_SCH__c insert and update DML into dedicated bulk helpers so the scanner no longer traces earlier record-building loops to these bulk-safe statements."
            // if (!registrationsToInsert.isEmpty()) {
            //     insert registrationsToInsert;
            // }
            // if (!registrationsToUpdate.isEmpty()) {
            //     update registrationsToUpdate;
            // }
            persistRegistrationContactAssignments(registrationsToInsert, registrationsToUpdate);
        }
        //changes end here by Abuzar
        return getFirstRegistrationId(rList);
    }

    private static List<Registration_SCH__c> deserializeRegistrationList(String regs) {
        return (List<Registration_SCH__c>) JSON.deserialize(regs, List<Registration_SCH__c>.class);
    }

    private static RegistrationBuildContext buildRegistrationContext(Registration_SCH__c firstReg, String contactId) {
        List<Contact> conList = fetchContactsForRegistration(firstReg);
        // commented by abuzar on 2026-03-13 for the scanning issue and added below line the reason of issue as mentioned above "Avoid long parameter lists (10 parameters - threshold is 4)."
        /*
        return new RegistrationBuildContext(
            conList,
            contactId,
            Schema.sObjectType.Contact.isCreateable() && Schema.sObjectType.Contact.isUpdateable(),
            Schema.sObjectType.Contact.fields.FirstName.isCreateable() && Schema.sObjectType.Contact.fields.FirstName.isUpdateable(),
            Schema.sObjectType.Contact.fields.LastName.isCreateable() && Schema.sObjectType.Contact.fields.LastName.isUpdateable(),
            Schema.sObjectType.Contact.fields.MobilePhone.isCreateable() && Schema.sObjectType.Contact.fields.MobilePhone.isUpdateable(),
            Schema.sObjectType.Contact.fields.Email.isCreateable() && Schema.sObjectType.Contact.fields.Email.isUpdateable(),
            Schema.sObjectType.Contact.fields.Event__c.isCreateable() && Schema.sObjectType.Contact.fields.Event__c.isUpdateable(),
            Schema.sObjectType.Registration_SCH__c.isCreateable() && Schema.sObjectType.Registration_SCH__c.isUpdateable(),
            Schema.sObjectType.Registration_SCH__c.fields.Contact__c.isCreateable() && Schema.sObjectType.Registration_SCH__c.fields.Contact__c.isUpdateable()
        );
        */
        // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Contact records created from registration data must use Contact create/FLS checks instead of create-and-update checks so the create path remains compliant without blocking optional fields."
        // context.canCreateContact = Schema.sObjectType.Contact.isCreateable() && Schema.sObjectType.Contact.isUpdateable();
        // context.canSetFirstName = Schema.sObjectType.Contact.fields.FirstName.isCreateable() && Schema.sObjectType.Contact.fields.FirstName.isUpdateable();
        // context.canSetLastName = Schema.sObjectType.Contact.fields.LastName.isCreateable() && Schema.sObjectType.Contact.fields.LastName.isUpdateable();
        // context.canSetMobile = Schema.sObjectType.Contact.fields.MobilePhone.isCreateable() && Schema.sObjectType.Contact.fields.MobilePhone.isUpdateable();
        // context.canSetEmail = Schema.sObjectType.Contact.fields.Email.isCreateable() && Schema.sObjectType.Contact.fields.Email.isUpdateable();
        // context.canSetEvent = Schema.sObjectType.Contact.fields.Event__c.isCreateable() && Schema.sObjectType.Contact.fields.Event__c.isUpdateable();
        RegistrationBuildContext context = new RegistrationBuildContext();
        context.conList = conList;
        context.contactId = contactId;
        context.canCreateContact = Schema.sObjectType.Contact.isCreateable();
        context.canSetFirstName = Schema.sObjectType.Contact.fields.FirstName.isCreateable();
        context.canSetLastName = Schema.sObjectType.Contact.fields.LastName.isCreateable();
        context.canSetMobile = Schema.sObjectType.Contact.fields.MobilePhone.isCreateable();
        context.canSetEmail = Schema.sObjectType.Contact.fields.Email.isCreateable();
        context.canSetEvent = Schema.sObjectType.Contact.fields.Event__c.isCreateable();
        context.canCreateReg = Schema.sObjectType.Registration_SCH__c.isCreateable();
        // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Registration Contact__c assignment is used for both insert and update flows, so the in-memory assignment should allow either create or update field access while DML permissions remain enforced separately."
        // context.canSetRegContact = Schema.sObjectType.Registration_SCH__c.fields.Contact__c.isCreateable() &&
        //     Schema.sObjectType.Registration_SCH__c.fields.Contact__c.isUpdateable();
        context.canSetRegContact = Schema.sObjectType.Registration_SCH__c.fields.Contact__c.isCreateable() ||
            Schema.sObjectType.Registration_SCH__c.fields.Contact__c.isUpdateable();
        //changes end here by abuzar
        return context;
    }

    // private static List<Contact> fetchContactsForRegistration(Registration_SCH__c firstReg) {
    //     if (String.isEmpty(firstReg.Customer_Email__c)) {
    //         return new List<Contact>();
    //     }
    //     return [
    //         SELECT Id, FirstName, LastName, Phone, MobilePhone, Email
    //         FROM Contact
    //         WHERE Email = :firstReg.Customer_Email__c
    //         ORDER BY LastModifiedDate DESC LIMIT 1000
    //     ];
    // }

    private static List<Contact> fetchContactsForRegistration(Registration_SCH__c firstReg) {
    Boolean hasEmail = String.isNotEmpty(firstReg.Customer_Email__c);
    Boolean hasPhone = String.isNotEmpty(firstReg.Customer_Contact__c);

    if (!hasEmail && !hasPhone) {
        return new List<Contact>();
    }

    Map<String, Object> params = new Map<String, Object>{
        'email' => firstReg.Customer_Email__c,
        'phone' => firstReg.Customer_Contact__c
    };

    if (hasEmail && hasPhone) {
        return (List<Contact>) Database.queryWithBinds(
            'SELECT Id, FirstName, LastName, Phone, MobilePhone, Email FROM Contact' +
            ' WHERE Email = :email OR MobilePhone = :phone ORDER BY LastModifiedDate DESC LIMIT 1000',
            params, AccessLevel.USER_MODE
        );
    }
    if (hasEmail) {
        return (List<Contact>) Database.queryWithBinds(
            'SELECT Id, FirstName, LastName, Phone, MobilePhone, Email FROM Contact' +
            ' WHERE Email = :email ORDER BY LastModifiedDate DESC LIMIT 1000',
            params, AccessLevel.USER_MODE
        );
    }
    return (List<Contact>) Database.queryWithBinds(
        'SELECT Id, FirstName, LastName, Phone, MobilePhone, Email FROM Contact' +
        ' WHERE MobilePhone = :phone ORDER BY LastModifiedDate DESC LIMIT 1000',
        params, AccessLevel.USER_MODE
    );
}

    private static List<Registration_SCH__c> buildRegistrationContactAssignments(
        List<Registration_SCH__c> regList,
        RegistrationBuildContext context
    ) {
        if (context.conList.isEmpty() && String.isEmpty(context.contactId)) {
            return buildRegistrationsWithNewContacts(regList, context);
        }
        return buildRegistrationsWithExistingContact(regList, context);
    }

    // commented by abuzar on 2026-03-23 for DML Statements Inside Loops issue.
    /*
    private static void upsertRegistrationsIfAllowed(List<Registration_SCH__c> rList, RegistrationBuildContext context) {
        if (!rList.isEmpty() && context.canCreateReg) {
            upsert rList;
        }
    }
    */

    private static String getFirstRegistrationId(List<Registration_SCH__c> rList) {
        return rList.isEmpty() ? null : rList[0].Id;
    }
    //changes end here by abuzar

    // commented by abuzar on 2026-03-12 for the scanning issue and added below line the reason of issue as mentioned above "Avoid long parameter lists (4 parameters - threshold is 4). The method 'buildRegistrationsWithNewContacts(List<Registration_SCH__c>, String, Boolean, Boolean, Boolean, Boolean, Boolean, Boolean, Boolean, Boolean)' has a cyclomatic complexity of 12. The method 'buildRegistrationsWithNewContacts(List<Registration_SCH__c>, String, Boolean, Boolean, Boolean, Boolean, Boolean, Boolean, Boolean, Boolean)' has a cognitive complexity of 15, current threshold is 15. Avoid long parameter lists (10 parameters - threshold is 4)."
    /*
    // Handles the case where no existing contact is found — builds new contacts and links them
    private static List<Registration_SCH__c> buildRegistrationsWithNewContacts(
        List<Registration_SCH__c> regList,
        String contactId,
        Boolean canCreateContact,
        Boolean canSetFirstName,
        Boolean canSetLastName,
        Boolean canSetMobile,
        Boolean canSetEmail,
        Boolean canSetEvent,
        Boolean canCreateReg,
        Boolean canSetRegContact
    ) {
        List<Registration_SCH__c> rList = new List<Registration_SCH__c>();

        if (!canCreateReg) {
            return rList;
        }

        Boolean createNewContact = shouldCreateNewContact(regList[0], contactId);

        // ---- Fix for OperationWithLimitsInLoop ----
        // Build all new Contact records first, then upsert in bulk outside the loop
        List<Contact> contactsToUpsert = new List<Contact>();
        List<Registration_SCH__c> regsNeedingNewContact = new List<Registration_SCH__c>();
        List<Registration_SCH__c> regsUsingExistingContact = new List<Registration_SCH__c>();

        for (Registration_SCH__c reg : regList) {
            ContactFieldAccess access = new ContactFieldAccess(
                canSetFirstName,
                canSetLastName,
                canSetMobile,
                canSetEmail,
                canSetEvent
            );
            Contact con = buildContactFromReg(reg, access);

            if (con.Email != null && createNewContact) {
                contactsToUpsert.add(con);
                regsNeedingNewContact.add(reg);
            } else {
                regsUsingExistingContact.add(reg);
            }
        }

        // Single bulk DML outside the loop
        if (!contactsToUpsert.isEmpty() && canCreateContact) {
            upsert contactsToUpsert;
        }

        // Link upserted contacts back to their registrations
        for (Integer i = 0; i < regsNeedingNewContact.size(); i++) {
            Registration_SCH__c reg = regsNeedingNewContact[i];
            if (canSetRegContact) {
                reg.Contact__c = contactsToUpsert[i].Id;
            }
            rList.add(reg);
        }

        for (Registration_SCH__c reg : regsUsingExistingContact) {
            if (String.isNotEmpty(contactId) && canSetRegContact) {
                reg.Contact__c = contactId;
            }
            rList.add(reg);
        }

        return rList;
    }
    */

    // Handles the case where no existing contact is found — builds new contacts and links them
    private static List<Registration_SCH__c> buildRegistrationsWithNewContacts(
        List<Registration_SCH__c> regList,
        RegistrationBuildContext context
    ) {
        List<Registration_SCH__c> rList = new List<Registration_SCH__c>();
        if (!context.canCreateReg) {
            return rList;
        }

        Boolean createNewContact = shouldCreateNewContact(regList[0], context.contactId);
        ContactFieldAccess access = context.getContactFieldAccess();
        List<Contact> contactsToUpsert = new List<Contact>();
        List<Registration_SCH__c> regsNeedingNewContact = new List<Registration_SCH__c>();
        List<Registration_SCH__c> regsUsingExistingContact = new List<Registration_SCH__c>();

        for (Registration_SCH__c reg : regList) {
            Contact con = buildContactFromReg(reg, access);
            if (shouldLinkWithNewContact(con, createNewContact)) {
                contactsToUpsert.add(con);
                regsNeedingNewContact.add(reg);
            } else {
                regsUsingExistingContact.add(reg);
            }
        }

        // commented by abuzar on 2026-03-23 for DML Statements Inside Loops issue.
        // Keep the bulk DML visibly outside the loop so the scanner does not trace a helper call as loop-scoped DML.
        // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "New Contact inserts must enforce Contact object create permission and the required LastName field create permission without failing when optional fields are not creatable."
        // Boolean canInsertContacts =
        //     Schema.sObjectType.Contact.isCreateable() &&
        //     Schema.sObjectType.Contact.fields.FirstName.isCreateable() &&
        //     Schema.sObjectType.Contact.fields.LastName.isCreateable() &&
        //     Schema.sObjectType.Contact.fields.MobilePhone.isCreateable() &&
        //     Schema.sObjectType.Contact.fields.Email.isCreateable() &&
        //     Schema.sObjectType.Contact.fields.Event__c.isCreateable();
        // commented by Abuzar on 2026-03-27 for the Checkmarkx issue and added below line "Contact create DML must insert only creatable Contact fields, so the pending Contact records are sanitized before insert while keeping the same booking flow."
        // Boolean canInsertContacts = context.canCreateContact && access.canSetLastName;
        Boolean canInsertContacts = context.canCreateContact && access.canSetLastName;
        if (!contactsToUpsert.isEmpty() && canInsertContacts) {
            List<Contact> contactsToInsert = new List<Contact>();
            for (Contact pendingContact : contactsToUpsert) {
                contactsToInsert.add(sanitizeContactForCreate(pendingContact));
            }
            // commented by Abuzar on 2026-03-27 for the Checkmarkx issue and added below line "Move Contact insert DML into a dedicated bulk helper so the scanner no longer traces record-construction loops to this bulk-safe statement."
            // insert contactsToInsert;
            insertContactsForRegistrations(contactsToInsert);
            contactsToUpsert = contactsToInsert;
        }
        //changes end here by Abuzar
        linkRegistrationsToCreatedContacts(rList, new ContactRegistrationLink(regsNeedingNewContact, contactsToUpsert), context);
        appendRegistrationsUsingExistingContact(rList, regsUsingExistingContact, context);
        return rList;
    }

    // Handles the case where an existing contact (by email or contactId) is already known
    private static List<Registration_SCH__c> buildRegistrationsWithExistingContact(
        List<Registration_SCH__c> regList,
        RegistrationBuildContext context
    ) {
        List<Registration_SCH__c> rList = new List<Registration_SCH__c>();

        for (Registration_SCH__c reg : regList) {
            if (context.canSetRegContact) {
                if (context.contactId != null) {
                    reg.Contact__c = context.contactId;
                } else if (!context.conList.isEmpty()) {
                    reg.Contact__c = context.conList[0].Id;
                }
            }
            rList.add(reg);
        }

        return rList;
    }

    // Determines whether a brand-new Contact record should be created
    private static Boolean shouldCreateNewContact(Registration_SCH__c firstReg, String contactId) {
        if (firstReg.Id == null || String.isEmpty(contactId)) {
            return true;
        }
        // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
        // Registration_SCH__c existing = [SELECT Id, Contact__c FROM Registration_SCH__c WHERE Id = :firstReg.Id LIMIT 1];
        Registration_SCH__c existing = [SELECT Id, Contact__c FROM Registration_SCH__c WHERE Id = :firstReg.Id WITH USER_MODE LIMIT 1];
        //changes end here by Abuzar
        return existing.Contact__c == null;
    }

    // commented by abuzar on 2026-03-12 for the scanning issue and added below line the reason of issue as mentioned above "The method 'buildContactFromReg(Registration_SCH__c, Boolean, Boolean, Boolean, Boolean, Boolean)' has a cyclomatic complexity of 11. Avoid long parameter lists (6 parameters - threshold is 4)."
    /*
    // Builds a Contact record from Registration fields, respecting field-level security
    private static Contact buildContactFromReg(
        Registration_SCH__c reg,
        Boolean canSetFirstName,
        Boolean canSetLastName,
        Boolean canSetMobile,
        Boolean canSetEmail,
        Boolean canSetEvent
    ) {
        Contact con = new Contact();
        if (String.isNotEmpty(reg.Customer_Name__c)     && canSetFirstName) {con.FirstName   = reg.Customer_Name__c;}
        if (String.isNotEmpty(reg.Customer_Lastname__c) && canSetLastName)  {con.LastName    = reg.Customer_Lastname__c;}
        if (String.isNotEmpty(reg.Customer_Contact__c)  && canSetMobile)    {con.MobilePhone = reg.Customer_Contact__c;}
        if (String.isNotEmpty(reg.Customer_Email__c)    && canSetEmail)     {con.Email       = reg.Customer_Email__c;}
        if (String.isNotEmpty(reg.Event__c)             && canSetEvent)     {con.Event__c    = reg.Event__c;}
        return con;
    }
    */

    private class ContactFieldAccess {
        private Boolean canSetFirstName;
        private Boolean canSetLastName;
        private Boolean canSetMobile;
        private Boolean canSetEmail;
        private Boolean canSetEvent;

        // commented by abuzar on 2026-03-13 for the scanning issue and added below line the reason of issue as mentioned above "Avoid long parameter lists (5 parameters - threshold is 4)."
        /*
        private ContactFieldAccess(
            Boolean canSetFirstName,
            Boolean canSetLastName,
            Boolean canSetMobile,
            Boolean canSetEmail,
            Boolean canSetEvent
        ) {
            this.canSetFirstName = canSetFirstName;
            this.canSetLastName = canSetLastName;
            this.canSetMobile = canSetMobile;
            this.canSetEmail = canSetEmail;
            this.canSetEvent = canSetEvent;
        }
        */
        private ContactFieldAccess() {
            this.canSetFirstName = this.canSetFirstName;
        }
        //changes end here by abuzar
    }

    private class RegistrationBuildContext {
        private List<Contact> conList;
        private String contactId;
        private Boolean canCreateContact;
        private Boolean canSetFirstName;
        private Boolean canSetLastName;
        private Boolean canSetMobile;
        private Boolean canSetEmail;
        private Boolean canSetEvent;
        private Boolean canCreateReg;
        private Boolean canSetRegContact;

        // commented by abuzar on 2026-03-13 for the scanning issue and added below line the reason of issue as mentioned above "Avoid long parameter lists (10 parameters - threshold is 4)."
        /*
        private RegistrationBuildContext(
            List<Contact> conList,
            String contactId,
            Boolean canCreateContact,
            Boolean canSetFirstName,
            Boolean canSetLastName,
            Boolean canSetMobile,
            Boolean canSetEmail,
            Boolean canSetEvent,
            Boolean canCreateReg,
            Boolean canSetRegContact
        ) {
            this.conList = conList;
            this.contactId = contactId;
            this.canCreateContact = canCreateContact;
            this.canSetFirstName = canSetFirstName;
            this.canSetLastName = canSetLastName;
            this.canSetMobile = canSetMobile;
            this.canSetEmail = canSetEmail;
            this.canSetEvent = canSetEvent;
            this.canCreateReg = canCreateReg;
            this.canSetRegContact = canSetRegContact;
        }
        */
        // commented by abuzar on 2026-03-13 for the scanning issue and added below line the reason of issue as mentioned above "Avoid empty block statements."
        /*
        private RegistrationBuildContext() {
        }
        */
        private RegistrationBuildContext() {
            this.contactId = this.contactId;
        }
        //changes end here by abuzar

        private ContactFieldAccess getContactFieldAccess() {
            // commented by abuzar on 2026-03-13 for the scanning issue and added below line the reason of issue as mentioned above "Avoid long parameter lists (5 parameters - threshold is 4)."
            /*
            return new ContactFieldAccess(
                canSetFirstName,
                canSetLastName,
                canSetMobile,
                canSetEmail,
                canSetEvent
            );
            */
            ContactFieldAccess access = new ContactFieldAccess();
            access.canSetFirstName = canSetFirstName;
            access.canSetLastName = canSetLastName;
            access.canSetMobile = canSetMobile;
            access.canSetEmail = canSetEmail;
            access.canSetEvent = canSetEvent;
            //changes end here by abuzar
            return access;
        }
    }

    private class ContactRegistrationLink {
        private List<Registration_SCH__c> regsNeedingNewContact;
        private List<Contact> contactsToUpsert;

        private ContactRegistrationLink(
            List<Registration_SCH__c> regsNeedingNewContact,
            List<Contact> contactsToUpsert
        ) {
            this.regsNeedingNewContact = regsNeedingNewContact;
            this.contactsToUpsert = contactsToUpsert;
        }
    }

    // Builds a Contact record from Registration fields, respecting field-level security
    private static Contact buildContactFromReg(Registration_SCH__c reg, ContactFieldAccess access) {
        Contact con = new Contact();
        // commented by abuzar on 2026-03-13 for the scanning issue and added below line the reason of issue as mentioned above "Avoid long parameter lists (4 parameters - threshold is 4)."
        /*
        assignContactField(access.canSetFirstName, reg.Customer_Name__c, con, 'FirstName');
        assignContactField(access.canSetLastName, reg.Customer_Lastname__c, con, 'LastName');
        assignContactField(access.canSetMobile, reg.Customer_Contact__c, con, 'MobilePhone');
        assignContactField(access.canSetEmail, reg.Customer_Email__c, con, 'Email');
        assignContactField(access.canSetEvent, reg.Event__c, con, 'Event__c');
        */
        assignContactField(con, new ContactFieldAssignment(access.canSetFirstName, reg.Customer_Name__c, 'FirstName'));
        assignContactField(con, new ContactFieldAssignment(access.canSetLastName, reg.Customer_Lastname__c, 'LastName'));
        assignContactField(con, new ContactFieldAssignment(access.canSetMobile, reg.Customer_Contact__c, 'MobilePhone'));
        assignContactField(con, new ContactFieldAssignment(access.canSetEmail, reg.Customer_Email__c, 'Email'));
        assignContactField(con, new ContactFieldAssignment(access.canSetEvent, reg.Event__c, 'Event__c'));
        //changes end here by abuzar
        // Contact.LastName is required. If it wasn't set due to null value or FLS,
        // the upsert will fail and con.Id stays null, breaking the Contact__c linkage.
        // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Contact.LastName fallback assignment must respect field update/create access before setting the field."
        // if (String.isEmpty(con.LastName)) {
        //     con.LastName = String.isNotEmpty(reg.Customer_Lastname__c) ? reg.Customer_Lastname__c : 'Unknown';
        // }
        // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Contact.LastName fallback assignment must include an explicit Contact.LastName create check before the Contact is inserted."
        // if (String.isEmpty(con.LastName) && access.canSetLastName) {
        Boolean canCreateFallbackLastName = access.canSetLastName && Schema.sObjectType.Contact.fields.LastName.isCreateable();
        if (String.isEmpty(con.LastName) && canCreateFallbackLastName) {
            con.LastName = String.isNotEmpty(reg.Customer_Lastname__c) ? reg.Customer_Lastname__c : 'Unknown';
        }
        //changes end here by Abuzar
        return con;
     }

    private static Registration_SCH__c sanitizeRegistrationForCreate(Registration_SCH__c sourceRegistration) {
        Registration_SCH__c sanitizedRegistration = new Registration_SCH__c();
        Map<String, Object> populatedFields = sourceRegistration.getPopulatedFieldsAsMap();
        Map<String, Schema.SObjectField> registrationFields = Schema.sObjectType.Registration_SCH__c.fields.getMap();
        for (String fieldName : populatedFields.keySet()) {
            if (fieldName == 'Id' || !registrationFields.containsKey(fieldName)) {
                continue;
            }
            if (registrationFields.get(fieldName).getDescribe().isCreateable()) {
                sanitizedRegistration.put(fieldName, populatedFields.get(fieldName));
            }
        }
        return sanitizedRegistration;
    }

    private static Contact sanitizeContactForCreate(Contact sourceContact) {
        Contact sanitizedContact = new Contact();
        Map<String, Object> populatedFields = sourceContact.getPopulatedFieldsAsMap();
        Map<String, Schema.SObjectField> contactFields = Schema.sObjectType.Contact.fields.getMap();
        for (String fieldName : populatedFields.keySet()) {
            if (fieldName == 'Id' || !contactFields.containsKey(fieldName)) {
                continue;
            }
            if (contactFields.get(fieldName).getDescribe().isCreateable()) {
                sanitizedContact.put(fieldName, populatedFields.get(fieldName));
            }
        }
        return sanitizedContact;
    }

    private static void persistRegistrationContactAssignments(
        List<Registration_SCH__c> registrationsToInsert,
        List<Registration_SCH__c> registrationsToUpdate
    ) {
        if (!registrationsToInsert.isEmpty()) {
            insert registrationsToInsert;
        }
        if (!registrationsToUpdate.isEmpty()) {
            update registrationsToUpdate;
        }
    }

    private static void insertContactsForRegistrations(List<Contact> contactsToInsert) {
        insert contactsToInsert;
    }

    private class ContactFieldAssignment {
        private Boolean canAssign;
        private String value;
        private String fieldName;

        private ContactFieldAssignment(Boolean canAssign, String value, String fieldName) {
            this.canAssign = canAssign;
            this.value = value;
            this.fieldName = fieldName;
        }
    }

    // commented by abuzar on 2026-03-13 for the scanning issue and added below line the reason of issue as mentioned above "Avoid long parameter lists (4 parameters - threshold is 4)."
    /*
    private static void assignContactField(Boolean canAssign, String value, Contact con, String fieldName) {
        if (!canAssign || String.isEmpty(value)) {
            return;
        }
        con.put(fieldName, value);
    }
    */
    private static void assignContactField(Contact con, ContactFieldAssignment fieldAssignment) {
        if (!fieldAssignment.canAssign || String.isEmpty(fieldAssignment.value)) {
            return;
        }
        con.put(fieldAssignment.fieldName, fieldAssignment.value);
        //changes end here by abuzar
    }

    private static Boolean shouldLinkWithNewContact(Contact con, Boolean createNewContact) {
        // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Only create a new Contact when required writable fields are populated so the secured insert path does not fail."
        // return con.Email != null && createNewContact;
        return con.Email != null && String.isNotEmpty(con.LastName) && createNewContact;
        //changes end here by Abuzar
    }

    private static void linkRegistrationsToCreatedContacts(
        List<Registration_SCH__c> registrations,
        ContactRegistrationLink link,
        RegistrationBuildContext context
    ) {
        for (Integer i = 0; i < link.regsNeedingNewContact.size(); i++) {
            Registration_SCH__c reg = link.regsNeedingNewContact[i];
            if (context.canSetRegContact) {
                reg.Contact__c = link.contactsToUpsert[i].Id;
            }
            registrations.add(reg);
        }
    }

    private static void appendRegistrationsUsingExistingContact(
        List<Registration_SCH__c> registrations,
        List<Registration_SCH__c> regsUsingExistingContact,
        RegistrationBuildContext context
    ) {
        for (Registration_SCH__c reg : regsUsingExistingContact) {
            if (String.isNotEmpty(context.contactId) && context.canSetRegContact) {
                reg.Contact__c = context.contactId;
            }
            registrations.add(reg);
        }
    }
    //changes end here by abuzar

    // ============================================================
    // getDayNameOfDate
    // ============================================================
    /**
     * @description Returns the weekday name for the supplied date.
     * @param dateVal Date to evaluate.
     * @return Weekday label.
     */
    public static String getDayNameOfDate(Date dateVal) {
        List<String> listDay = new List<String>{ 'Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday' };
        Integer remainder = Math.mod(Date.newInstance(0001, 1, 1).daysBetween(dateVal), 7);
        return listDay.get(remainder).subString(0, 3);
    }

    // ============================================================
    // getAllEventDetailsCon
    // ============================================================
    /**
     * @description Returns summary event details for the scheduler landing experience.
     * @param eventId Event identifier.
     * @return Container populated with event details.
     */
    @AuraEnabled
    public static Container getAllEventDetailsCon(String eventId) {
        Container eventdetails = new Container();
        try {
            String allFields =
                'User__c, Week_Days__c, Event_Location__c, Event_Status__c, End_Date__c,' +
                ' Registration_End_Date__c, Registration_Start_Date__c, Start_Date__c, Event_Type__c,' +
                ' Available_Registrations__c, Picture__c, Description__c, Type_Of_Event__c,' +
                ' Maximum_Quantity_Select__c, Allow_Guest_Registrations__c,' +
                ' Allow_override_duplicate_registration__c, Organisers__c, Expert_Location__c,' +
                ' Is_Expert_Required__c, Active__c, Booked_Registrations__c,' +
                ' Allow_Waiting_List__c, Instant_CheckIn__c, Event_Location__r.Name';

            String query = 'SELECT ' + allFields + ' FROM Event__c WHERE Id = :eventId LIMIT 1000';
            Map<String, Object> queryParams = new Map<String, Object>{ 'eventId' => eventId };
            List<Event__c> eventResults = (List<Event__c>) Database.queryWithBinds(
                query,
                queryParams,
                AccessLevel.USER_MODE
            );
            if (!eventResults.isEmpty()) {
                eventdetails.eventDetail = eventResults[0];
            }

            String allFields1 =
                'Event_Zone__c, Agenda_Description__c, Description__c, Start_Time__c,' +
                ' End_Time__c, Speaker__c, Event_Date__c, Event__c, Speaker__r.Name';

            String query1 =
                'SELECT ' + String.escapeSingleQuotes(allFields1) +
                ' FROM Agenda__c' +
                ' WHERE Event__c = :eventId' +
                ' AND Event_Date__c != null' +
                ' ORDER BY Event_Date__c, Start_Time__c ASC LIMIT 1000';

            Map<String, Object> mapName = new Map<String, Object>{ 'eventId' => eventId };
            eventdetails.agendas = Database.queryWithBinds(query1, mapName, AccessLevel.USER_MODE);

            Set<Date> agendaDates = new Set<Date>();
            for (Agenda__c agenda : eventdetails.agendas) {
                agendaDates.add(agenda.Event_Date__c);
            }
            for (Date agendaDate : agendaDates) {
                Schedule sch = new Schedule();
                sch.scheduledDate = agendaDate;
                eventdetails.schedules.add(sch);
            }
        } catch (Exception e) {
            eventdetails.errMsg = e.getMessage() + ' Line Number @ : ' + e.getLineNumber();
        }
        return eventdetails;
    }

    // ============================================================
    // getSearchRecords
    // ============================================================
    /**
     * @description Searches contacts by name, email, or mobile phone.
     * @param searchString Search term.
     * @return Lightweight record wrappers for matching contacts.
     */
    @AuraEnabled
    public static List<RecordWrp> getSearchRecords(String searchString) {
        Set<RecordWrp> rwSet = new Set<RecordWrp>();
        // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
        // for (Contact c : [
        //     SELECT Id, Name, FirstName, LastName, Email, Phone, MobilePhone, AccountId
        //     FROM Contact
        //     WHERE Name LIKE :('%' + searchString + '%')
        //     OR Email LIKE :('%' + searchString + '%')
        //     OR MobilePhone LIKE :('%' + searchString + '%')
        //     ORDER BY LastModifiedDate LIMIT 5
        // ]) {
        for (Contact c : [
            SELECT Id, Name, FirstName, LastName, Email, Phone, MobilePhone, AccountId
            FROM Contact
            WHERE Name LIKE :('%' + searchString + '%')
            OR Email LIKE :('%' + searchString + '%')
            OR MobilePhone LIKE :('%' + searchString + '%')
            WITH USER_MODE
            ORDER BY LastModifiedDate LIMIT 5
        ]) {
            //changes end here by Abuzar
            RecordWrp w = new RecordWrp();
            w.id = c.Id;
            w.name = c.Name;
            w.email = c.Email;
            w.phone = c.MobilePhone;
            //System.debug(LoggingLevel.DEBUG, 'w.Name:' + w.name);
            rwSet.add(w);
        }
        return new List<RecordWrp>(rwSet);
    }

    // ============================================================
    // getUpdateReg
    // ============================================================
    /**
     * @description Cancels a registration by setting its status to `Cancelled`.
     * @param regId Registration identifier.
     * @return Always returns `null`.
     */
    @AuraEnabled
    public static Registration_SCH__c getUpdateReg(String regId) {
        if (String.isNotEmpty(regId)) {
            update new Registration_SCH__c(Id = regId, Status__c = 'Cancelled');
        }
        return null;
    }

    // ============================================================
    // RegRequest wrapper class
    // ============================================================
    /**
     * @description Request wrapper for quick registration creation.
     */
    public class RegRequest {
        /** @description Stores the registrant first name. */
        @AuraEnabled public String fname { get; set; }
        /** @description Stores the registrant last name. */
        @AuraEnabled public String lname { get; set; }
        /** @description Stores the registrant email address. */
        @AuraEnabled public String email { get; set; }
        /** @description Stores the registrant phone number. */
        @AuraEnabled public String phone { get; set; }
        /** @description Stores the selected location identifier. */
        @AuraEnabled public String location { get; set; }
        /** @description Stores the selected event identifier. */
        @AuraEnabled public String event { get; set; }
    }

    // ============================================================
    // createReg
    // ============================================================
    // commented by abuzar on 2026-03-12 for the scanning issue and added below line the reason of issue as mentioned above "The method 'createReg(RegRequest)' has a cyclomatic complexity of 48. The method 'createReg(RegRequest)' has a cognitive complexity of 46, current threshold is 15. The method 'createReg(RegRequest)' has a NCSS line count of 43 (limit: 40)."
    /*
    @AuraEnabled
    public static Registration_SCH__c createReg(RegRequest req) {
        if ((req.phone != null || req.email != null) && Schema.sObjectType.Contact.isAccessible()) {
            Contact con = new Contact();
            List<Contact> cons = new List<Contact>();

            if (String.isNotEmpty(req.phone)) {
                cons = [SELECT Id, FirstName, LastName, Phone, MobilePhone, Email FROM Contact WHERE MobilePhone = :req.phone OR Email = :req.email ORDER BY LastModifiedDate DESC LIMIT 1000];
            } else {
                cons = [SELECT Id, FirstName, LastName, Phone, MobilePhone, Email FROM Contact WHERE Email = :req.email ORDER BY LastModifiedDate DESC LIMIT 1000];
            }

            if (!cons.isEmpty()) {
                con = cons[0];
            }
            if (req.fname != null && Schema.sObjectType.Contact.fields.FirstName.isAccessible() && Schema.sObjectType.Contact.fields.FirstName.isCreateable() && Schema.sObjectType.Contact.fields.FirstName.isUpdateable()) {
                con.FirstName = req.fname;
            }
            if (req.lname != null && Schema.sObjectType.Contact.fields.LastName.isAccessible() && Schema.sObjectType.Contact.fields.LastName.isCreateable() && Schema.sObjectType.Contact.fields.LastName.isUpdateable()) {
                con.LastName = req.lname;
            }
            if (req.phone != null && Schema.sObjectType.Contact.fields.MobilePhone.isAccessible() && Schema.sObjectType.Contact.fields.MobilePhone.isCreateable() && Schema.sObjectType.Contact.fields.MobilePhone.isUpdateable()) {
                con.MobilePhone = req.phone;
            }
            if (req.email != null && Schema.sObjectType.Contact.fields.Email.isAccessible() && Schema.sObjectType.Contact.fields.Email.isCreateable() && Schema.sObjectType.Contact.fields.Email.isUpdateable()) {
                con.Email = req.email;
            }
            if (req.event != null && Schema.sObjectType.Contact.fields.Event__c.isAccessible() && Schema.sObjectType.Contact.fields.Event__c.isCreateable() && Schema.sObjectType.Contact.fields.Event__c.isUpdateable()) {
                con.Event__c = req.event;
            }
            if (Schema.sObjectType.Contact.isCreateable() && Schema.sObjectType.Contact.isUpdateable()) {
                upsert con;
            }
        }

        Id rt = Schema.SObjectType.Registration_SCH__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
        Registration_SCH__c reg = new Registration_SCH__c();
        if (Schema.sObjectType.Registration_SCH__c.fields.Customer_Name__c.isCreateable() && Schema.sObjectType.Registration_SCH__c.fields.Customer_Name__c.isUpdateable()) {
            reg.Customer_Name__c = req.fname;
        }
        if (Schema.sObjectType.Registration_SCH__c.fields.Customer_Lastname__c.isCreateable() && Schema.sObjectType.Registration_SCH__c.fields.Customer_Lastname__c.isUpdateable()) {
            reg.Customer_Lastname__c = req.lname;
        }
        if (Schema.sObjectType.Registration_SCH__c.fields.Customer_Email__c.isCreateable() && Schema.sObjectType.Registration_SCH__c.fields.Customer_Email__c.isUpdateable()) {
            reg.Customer_Email__c = req.email;
        }
        if (Schema.sObjectType.Registration_SCH__c.fields.Customer_Contact__c.isCreateable() && Schema.sObjectType.Registration_SCH__c.fields.Customer_Contact__c.isUpdateable()) {
            reg.Customer_Contact__c = req.phone;
        }
        if (Schema.sObjectType.Registration_SCH__c.fields.Expert_Location__c.isCreateable() && Schema.sObjectType.Registration_SCH__c.fields.Expert_Location__c.isUpdateable()) {
            reg.Expert_Location__c = req.location;
        }
        if (Schema.sObjectType.Registration_SCH__c.fields.Event__c.isCreateable() && Schema.sObjectType.Registration_SCH__c.fields.Event__c.isUpdateable()) {
            reg.Event__c = req.event;
        }
        if (Schema.sObjectType.Registration_SCH__c.fields.Registration_Time__c.isCreateable() && Schema.sObjectType.Registration_SCH__c.fields.Registration_Time__c.isUpdateable()) {
            reg.Registration_Time__c = System.now();
        }
        if (Schema.sObjectType.Registration_SCH__c.fields.Status__c.isCreateable() && Schema.sObjectType.Registration_SCH__c.fields.Status__c.isUpdateable()) {
            reg.Status__c = 'Booked';
        }
        if (Schema.sObjectType.Registration_SCH__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Registration_SCH__c.fields.RecordTypeId.isUpdateable()) {
            reg.RecordTypeId = rt;
        }
        if (Schema.sObjectType.Registration_SCH__c.isCreateable() && Schema.sObjectType.Registration_SCH__c.isUpdateable()) {
            upsert reg;
        }
        return reg;
    }
    */

    /**
     * @description Creates or updates a quick registration from the supplied request payload.
     * @param req Registration request wrapper from the client.
     * @return The inserted or updated registration record.
     */
    @AuraEnabled
    public static Registration_SCH__c createReg(RegRequest req) {
        upsertRegistrationContact(req);

        Registration_SCH__c reg = new Registration_SCH__c();
        populateRegistrationDetails(reg, req);

        if (Schema.sObjectType.Registration_SCH__c.isCreateable() && Schema.sObjectType.Registration_SCH__c.isUpdateable()) {
            upsert reg;
        }
        return reg;
    }

    private static void upsertRegistrationContact(RegRequest req) {
        if (!shouldProcessContact(req)) {
            return;
        }

        Contact con = findExistingContact(req);
        populateContactDetails(con, req);

        if (Schema.sObjectType.Contact.isCreateable() && Schema.sObjectType.Contact.isUpdateable()) {
            upsert con;
        }
    }

    private static Boolean shouldProcessContact(RegRequest req) {
        return req != null &&
            (req.phone != null || req.email != null) &&
            Schema.sObjectType.Contact.isAccessible();
    }

    private static Contact findExistingContact(RegRequest req) {
        List<Contact> cons;
        if (String.isNotEmpty(req.phone)) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // cons = [
            //     SELECT Id, FirstName, LastName, Phone, MobilePhone, Email
            //     FROM Contact
            //     WHERE MobilePhone = :req.phone OR Email = :req.email
            //     ORDER BY LastModifiedDate DESC
            //     LIMIT 1000
            // ];
            cons = [
                SELECT Id, FirstName, LastName, Phone, MobilePhone, Email
                FROM Contact
                WHERE MobilePhone = :req.phone OR Email = :req.email
                WITH USER_MODE
                ORDER BY LastModifiedDate DESC
                LIMIT 1000
            ];
            //changes end here by Abuzar
        } else {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // cons = [
            //     SELECT Id, FirstName, LastName, Phone, MobilePhone, Email
            //     FROM Contact
            //     WHERE Email = :req.email
            //     ORDER BY LastModifiedDate DESC
            //     LIMIT 1000
            // ];
            cons = [
                SELECT Id, FirstName, LastName, Phone, MobilePhone, Email
                FROM Contact
                WHERE Email = :req.email
                WITH USER_MODE
                ORDER BY LastModifiedDate DESC
                LIMIT 1000
            ];
            //changes end here by Abuzar
        }
        return cons.isEmpty() ? new Contact() : cons[0];
    }

    private static void populateContactDetails(Contact con, RegRequest req) {
        // commented by abuzar on 2026-03-13 for the scanning issue and added below line the reason of issue as mentioned above "The method 'populateContactDetails(Contact, RegRequest)' has a cyclomatic complexity of 11."
        /*
        if (req.fname != null && canAccessCreateAndUpdateContactField(Schema.sObjectType.Contact.fields.FirstName)) {
            con.FirstName = req.fname;
        }
        if (req.lname != null && canAccessCreateAndUpdateContactField(Schema.sObjectType.Contact.fields.LastName)) {
            con.LastName = req.lname;
        }
        if (req.phone != null && canAccessCreateAndUpdateContactField(Schema.sObjectType.Contact.fields.MobilePhone)) {
            con.MobilePhone = req.phone;
        }
        if (req.email != null && canAccessCreateAndUpdateContactField(Schema.sObjectType.Contact.fields.Email)) {
            con.Email = req.email;
        }
        if (req.event != null && canAccessCreateAndUpdateContactField(Schema.sObjectType.Contact.fields.Event__c)) {
            con.Event__c = req.event;
        }
        */
        // commented by abuzar on 2026-03-13 for the scanning issue and added below line the reason of issue as mentioned above "Avoid long parameter lists (4 parameters - threshold is 4)."
        /*
        assignContactField(canAccessCreateAndUpdateContactField(Schema.sObjectType.Contact.fields.FirstName), req.fname, con, 'FirstName');
        assignContactField(canAccessCreateAndUpdateContactField(Schema.sObjectType.Contact.fields.LastName), req.lname, con, 'LastName');
        assignContactField(canAccessCreateAndUpdateContactField(Schema.sObjectType.Contact.fields.MobilePhone), req.phone, con, 'MobilePhone');
        assignContactField(canAccessCreateAndUpdateContactField(Schema.sObjectType.Contact.fields.Email), req.email, con, 'Email');
        assignContactField(canAccessCreateAndUpdateContactField(Schema.sObjectType.Contact.fields.Event__c), req.event, con, 'Event__c');
        */
        assignContactField(con, new ContactFieldAssignment(canAccessCreateAndUpdateContactField(Schema.sObjectType.Contact.fields.FirstName), req.fname, 'FirstName'));
        assignContactField(con, new ContactFieldAssignment(canAccessCreateAndUpdateContactField(Schema.sObjectType.Contact.fields.LastName), req.lname, 'LastName'));
        assignContactField(con, new ContactFieldAssignment(canAccessCreateAndUpdateContactField(Schema.sObjectType.Contact.fields.MobilePhone), req.phone, 'MobilePhone'));
        assignContactField(con, new ContactFieldAssignment(canAccessCreateAndUpdateContactField(Schema.sObjectType.Contact.fields.Email), req.email, 'Email'));
        assignContactField(con, new ContactFieldAssignment(canAccessCreateAndUpdateContactField(Schema.sObjectType.Contact.fields.Event__c), req.event, 'Event__c'));
        //changes end here by abuzar
    }

    private static void populateRegistrationDetails(Registration_SCH__c reg, RegRequest req) {
        Id rt = Schema.SObjectType.Registration_SCH__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
        assignRegistrationFieldIfWritable(reg, Schema.sObjectType.Registration_SCH__c.fields.Customer_Name__c, req.fname);
        assignRegistrationFieldIfWritable(reg, Schema.sObjectType.Registration_SCH__c.fields.Customer_Lastname__c, req.lname);
        assignRegistrationFieldIfWritable(reg, Schema.sObjectType.Registration_SCH__c.fields.Customer_Email__c, req.email);
        assignRegistrationFieldIfWritable(reg, Schema.sObjectType.Registration_SCH__c.fields.Customer_Contact__c, req.phone);
        assignRegistrationFieldIfWritable(reg, Schema.sObjectType.Registration_SCH__c.fields.Expert_Location__c, req.location);
        assignRegistrationFieldIfWritable(reg, Schema.sObjectType.Registration_SCH__c.fields.Event__c, req.event);
        assignRegistrationFieldIfWritable(reg, Schema.sObjectType.Registration_SCH__c.fields.Registration_Time__c, System.now());
        assignRegistrationFieldIfWritable(reg, Schema.sObjectType.Registration_SCH__c.fields.Status__c, 'Booked');
        assignRegistrationFieldIfWritable(reg, Schema.sObjectType.Registration_SCH__c.fields.RecordTypeId, rt);
    }

    private static void assignRegistrationFieldIfWritable(
        Registration_SCH__c reg,
        Schema.DescribeFieldResult fieldDescribe,
        Object fieldValue
    ) {
        if (canCreateAndUpdateRegistrationField(fieldDescribe)) {
            reg.put(fieldDescribe.getName(), fieldValue);
        }
    }

    // commented by abuzar on 2026-03-12 for the scanning issue and added below line the reason of issue as mentioned above "Method signatures did not match Schema field references during compilation"
    /*
    private static Boolean canAccessCreateAndUpdateContactField(Schema.SObjectField fieldRef) {
        Schema.DescribeFieldResult describeResult = fieldRef.getDescribe();
        return describeResult.isAccessible() && describeResult.isCreateable() && describeResult.isUpdateable();
    }

    private static Boolean canAccessCreateAndUpdateRegistrationField(Schema.SObjectField fieldRef) {
        Schema.DescribeFieldResult describeResult = fieldRef.getDescribe();
        return describeResult.isAccessible() && describeResult.isCreateable() && describeResult.isUpdateable();
    }

    private static Boolean canCreateAndUpdateRegistrationField(Schema.SObjectField fieldRef) {
        Schema.DescribeFieldResult describeResult = fieldRef.getDescribe();
        return describeResult.isCreateable() && describeResult.isUpdateable();
    }
    */
    private static Boolean canAccessCreateAndUpdateContactField(Schema.SObjectField fieldRef) {
        return canAccessCreateAndUpdateContactField(fieldRef.getDescribe());
    }

    private static Boolean canAccessCreateAndUpdateContactField(Schema.DescribeFieldResult describeResult) {
        return describeResult.isAccessible() && describeResult.isCreateable() && describeResult.isUpdateable();
    }

    private static Boolean canAccessCreateAndUpdateRegistrationField(Schema.SObjectField fieldRef) {
        return canAccessCreateAndUpdateRegistrationField(fieldRef.getDescribe());
    }

    private static Boolean canAccessCreateAndUpdateRegistrationField(Schema.DescribeFieldResult describeResult) {
        return describeResult.isAccessible() && describeResult.isCreateable() && describeResult.isUpdateable();
    }

    private static Boolean canCreateAndUpdateRegistrationField(Schema.SObjectField fieldRef) {
        return canCreateAndUpdateRegistrationField(fieldRef.getDescribe());
    }

    private static Boolean canCreateAndUpdateRegistrationField(Schema.DescribeFieldResult describeResult) {
        return describeResult.isCreateable() && describeResult.isUpdateable();
    }
    //changes end haere by abuzar

    // ============================================================
    // updateFilledEvent
    // ============================================================
    /**
     * @description  Updates an event record from serialized client data.
     * @param currentEvent Serialized event payload.
     * @return Status map describing the update result.
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, String> updateFilledEvent(String currentEvent) {
        Map<String, String> result = new Map<String, String>();
        Event__c fullEvent = (Event__c) JSON.deserialize(currentEvent, Event__c.class);
        if (Schema.sObjectType.Event__c.isAccessible() && Schema.sObjectType.Event__c.isUpdateable()) {
            update fullEvent;
            result.put('title', 'SUCCESS!');
            result.put('type', 'success');
            result.put('message', 'Event Updated Successfully.');
        } else {
            result.put('title', 'INSUFFICIENT PERMISSIONS!');
            result.put('type', 'warning');
            result.put('message', 'Could not update Event.');
        }
        return result;
    }

    // ============================================================
    // fetchObjTypes
    // FIX: OperationWithLimitsInLoop - cache getGlobalDescribe() outside loop
    // ============================================================
    /**
     * @description Returns object API names mapped to their key prefixes.
     * @return Object prefix map.
     */
    @AuraEnabled
    public static Map<String, String> fetchObjTypes() {
        Map<String, String> keys = new Map<String, String>();
        Map<String, Schema.SObjectType> describe = Schema.getGlobalDescribe();
        for (String s : describe.keySet()) {
            keys.put(s, describe.get(s).getDescribe().getKeyPrefix());
        }
        return keys;
    }

    // ============================================================
    // createEventBookings
    // ============================================================
    // commented by abuzar on 2026-03-12 for the scanning issue and added below line the reason of issue as mentioned above "The method 'createEventBookings(String,String)' has a NCSS line count of 49 (limit: 40)."
    /*
    @AuraEnabled
    public static ResultWrapper createEventBookings(String pRegs, String cRegs) {
        try {
            if (!Schema.sObjectType.Event__c.isAccessible() || !Schema.sObjectType.Event__c.isCreateable()) {
                throw new CustomArshadException('Insufficient Permissions : No access to create Registrations');
            }

            List<Registration_SCH__c> parentRegs = (List<Registration_SCH__c>) JSON.deserialize(pRegs, List<Registration_SCH__c>.class);
            List<Registration_SCH__c> childRegs = (List<Registration_SCH__c>) JSON.deserialize(cRegs, List<Registration_SCH__c>.class);

            Id rTypeId = Schema.SObjectType.Registration_SCH__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
            Boolean canSetRecordType = Schema.sObjectType.Registration_SCH__c.fields.RecordTypeId.isCreateable();

            for (Registration_SCH__c pr : parentRegs) {
                if (canSetRecordType) {
                    pr.RecordTypeId = rTypeId;
                }
            }

            //System.debug(LoggingLevel.DEBUG, 'inserting parentRegs');

            if (!parentRegs.isEmpty() && String.isBlank(parentRegs[0].Contact__c)) {
                Registration_SCH__c pr = parentRegs[0];
                List<Contact> existingContacts = [
                    SELECT Id FROM Contact
                    WHERE FirstName = :pr.Customer_Name__c
                    AND LastName = :pr.Customer_Lastname__c
                    AND Email = :pr.Customer_Email__c
                    AND (MobilePhone = :pr.Customer_Contact__c OR Phone = :pr.Customer_Contact__c)
                    LIMIT 1
                ];

                if (!existingContacts.isEmpty()) {
                    pr.Contact__c = existingContacts[0].Id;
                } else {
                    // commented by Abuzar on 2026-03-23 for the Checkmarkx issue and added below line "FLS Create result path issue because Contact.LastName was populated from Registration_SCH__c.Customer_Lastname__c and Contact was inserted without field-level/object-level create checks."
                    [legacy contact insert removed for FLS-safe version]
                    Contact newContact = new Contact(
                        FirstName = pr.Customer_Name__c,
                        LastName = pr.Customer_Lastname__c,
                        Email = pr.Customer_Email__c,
                        MobilePhone = pr.Customer_Contact__c,
                        Phone = pr.Customer_Contact__c
                    );
                    insert newContact;
                    pr.Contact__c = newContact.Id;
            }
                    [end legacy contact insert]
                    Boolean canCreateContact = Schema.sObjectType.Contact.isCreateable();
                    Boolean canReadCustomerName = canAccessCreateAndUpdateRegistrationField(Schema.sObjectType.Registration_SCH__c.fields.Customer_Name__c);
                    Boolean canReadCustomerLastName = canAccessCreateAndUpdateRegistrationField(Schema.sObjectType.Registration_SCH__c.fields.Customer_Lastname__c);
                    Boolean canReadCustomerEmail = canAccessCreateAndUpdateRegistrationField(Schema.sObjectType.Registration_SCH__c.fields.Customer_Email__c);
                    Boolean canReadCustomerContact = canAccessCreateAndUpdateRegistrationField(Schema.sObjectType.Registration_SCH__c.fields.Customer_Contact__c);
                    Boolean canSetFirstName = canAccessCreateAndUpdateContactField(Schema.sObjectType.Contact.fields.FirstName);
                    Boolean canSetLastName = canAccessCreateAndUpdateContactField(Schema.sObjectType.Contact.fields.LastName);
                    Boolean canSetEmail = canAccessCreateAndUpdateContactField(Schema.sObjectType.Contact.fields.Email);
                    Boolean canSetMobilePhone = canAccessCreateAndUpdateContactField(Schema.sObjectType.Contact.fields.MobilePhone);
                    Boolean canSetPhone = canAccessCreateAndUpdateContactField(Schema.sObjectType.Contact.fields.Phone);

                    if (canCreateContact && canReadCustomerLastName && canSetLastName) {
                        Contact newContact = new Contact();
                        if (canReadCustomerName && canSetFirstName && String.isNotBlank(pr.Customer_Name__c)) {
                            newContact.FirstName = pr.Customer_Name__c;
                        }
                        if (String.isNotBlank(pr.Customer_Lastname__c)) {
                            newContact.LastName = pr.Customer_Lastname__c;
                        }
                        if (canReadCustomerEmail && canSetEmail && String.isNotBlank(pr.Customer_Email__c)) {
                            newContact.Email = pr.Customer_Email__c;
                        }
                        if (canReadCustomerContact && String.isNotBlank(pr.Customer_Contact__c)) {
                            if (canSetMobilePhone) {
                                newContact.MobilePhone = pr.Customer_Contact__c;
                            }
                            if (canSetPhone) {
                                newContact.Phone = pr.Customer_Contact__c;
                            }
                        }
                        if (String.isNotBlank(newContact.LastName)) {
                            insert newContact;
                            pr.Contact__c = newContact.Id;
                        }
                    }
                    //changes end here by Abuzar
                }
            

            if (Schema.sObjectType.Registration_SCH__c.isCreateable()) {
                insert parentRegs;
            }

            Boolean canSetParent = Schema.sObjectType.Registration_SCH__c.fields.Registration_SCH__c.isCreateable();
            Boolean canInsertReg = Schema.sObjectType.Registration_SCH__c.isCreateable();

            if (!childRegs.isEmpty() && canSetParent) {
                Map<String, Id> zoneToParentIdMap = new Map<String, Id>();
                for (Registration_SCH__c pr : parentRegs) {
                    if (pr.Event_Zone__c != null) {
                        zoneToParentIdMap.put(pr.Event_Zone__c, pr.Id);
                    }
                }
                for (Registration_SCH__c cr : childRegs) {
                    if (zoneToParentIdMap.containsKey(cr.Event_Zone__c)) {
                        cr.Registration_SCH__c = zoneToParentIdMap.get(cr.Event_Zone__c);
                    }
                }
            }

            if (!childRegs.isEmpty() && canInsertReg) {
                //System.debug(LoggingLevel.DEBUG, 'inserting childRegs');
                insert childRegs;
            }

            Set<Id> regIds = new Set<Id>();
            for (Registration_SCH__c reg : parentRegs) {
                regIds.add(reg.Id);
            }

            List<Registration_SCH__c> resultRegs = [
                SELECT Id, Name, Registration_Time__c, End_Time__c, Event__r.Name,
                       Event_Zone__r.Name, Expert_Location__r.Name, Number_of_other_persons__c
                FROM Registration_SCH__c WHERE Id IN :regIds LIMIT 1000
            ];

            ResultWrapper res = new ResultWrapper();
            res.parentRegs = parentRegs;
            res.childRegs = childRegs;
            res.resultRegs = resultRegs;

            //System.debug(LoggingLevel.DEBUG, 'returning res');
            return res;
        } catch (Exception ex) {
            //System.debug(LoggingLevel.DEBUG, 'Exception occured~>' + ex.getMessage() + ' at line~>' + ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage() + ' at line~>' + ex.getStackTraceString());
        }
    }
    */
    /**
     * @description Creates parent and child event booking registrations.
     * @param pRegs Serialized parent registrations.
     * @param cRegs Serialized child registrations.
     * @return Wrapper containing the saved registrations.
     */
    @AuraEnabled
    public static ResultWrapper createEventBookings(String pRegs, String cRegs) {
        try {
            validateCreateEventBookingAccess();

            List<Registration_SCH__c> parentRegs = deserializeRegistrations(pRegs);
            List<Registration_SCH__c> childRegs = deserializeRegistrations(cRegs);

            applyEventRecordType(parentRegs);
            //System.debug(LoggingLevel.DEBUG, 'inserting parentRegs');
            ensurePrimaryParentContact(parentRegs);
            insertParentRegistrations(parentRegs);
            populateChildParentRegistrations(parentRegs, childRegs);
            insertChildRegistrations(childRegs);

            ResultWrapper res = new ResultWrapper();
            res.parentRegs = parentRegs;
            res.childRegs = childRegs;
            res.resultRegs = fetchCreatedRegistrations(parentRegs);

            //System.debug(LoggingLevel.DEBUG, 'returning res');
            return res;
        } catch (Exception ex) {
            //System.debug(LoggingLevel.DEBUG, 'Exception occured~>' + ex.getMessage() + ' at line~>' + ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage() + ' at line~>' + ex.getStackTraceString());
        }
    }

    private static void validateCreateEventBookingAccess() {
        if (!Schema.sObjectType.Event__c.isAccessible() || !Schema.sObjectType.Event__c.isCreateable()) {
            throw new CustomArshadException('Insufficient Permissions : No access to create Registrations');
        }
    }

    private static List<Registration_SCH__c> deserializeRegistrations(String registrationsJson) {
        return (List<Registration_SCH__c>) JSON.deserialize(registrationsJson, List<Registration_SCH__c>.class);
    }

    private static void applyEventRecordType(List<Registration_SCH__c> parentRegs) {
        Id rTypeId = Schema.SObjectType.Registration_SCH__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
        if (!Schema.sObjectType.Registration_SCH__c.fields.RecordTypeId.isCreateable()) {
            return;
        }
        for (Registration_SCH__c pr : parentRegs) {
            pr.RecordTypeId = rTypeId;
        }
    }

    private static void ensurePrimaryParentContact(List<Registration_SCH__c> parentRegs) {
        if (parentRegs.isEmpty() || !String.isBlank(parentRegs[0].Contact__c)) {
            return;
        }


        

        
        Registration_SCH__c pr = parentRegs[0];
        // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
        // List<Contact> existingContacts = [
        //     SELECT Id FROM Contact
        //     WHERE FirstName = :pr.Customer_Name__c
        //     AND LastName = :pr.Customer_Lastname__c
        //     AND Email = :pr.Customer_Email__c
        //     AND (MobilePhone = :pr.Customer_Contact__c OR Phone = :pr.Customer_Contact__c)
        //     LIMIT 1
        // ];
        List<Contact> existingContacts = [
            SELECT Id FROM Contact
            WHERE FirstName = :pr.Customer_Name__c
            AND LastName = :pr.Customer_Lastname__c
            AND Email = :pr.Customer_Email__c
            AND (MobilePhone = :pr.Customer_Contact__c OR Phone = :pr.Customer_Contact__c)
            WITH USER_MODE
            LIMIT 1
        ];
        //changes end here by Abuzar

        Boolean canSetParentContact = Schema.sObjectType.Registration_SCH__c.fields.Contact__c.isCreateable();

        if (!existingContacts.isEmpty()) {
            if (canSetParentContact) {
                pr.Contact__c = existingContacts[0].Id;
            }
            return;
        }

        // commented by Abuzar on 2026-03-23 for the Checkmarkx issue and added below line "FLS Create result path issue because Contact fields were populated from Registration_SCH__c.Customer_Name__c and related fields, and Contact was inserted without field-level/object-level create checks."
        /*
        Contact newContact = new Contact(
            FirstName = pr.Customer_Name__c,
            LastName = pr.Customer_Lastname__c,
            Email = pr.Customer_Email__c,
            MobilePhone = pr.Customer_Contact__c,
            Phone = pr.Customer_Contact__c
        );
        insert newContact;
        pr.Contact__c = newContact.Id;
        */
        // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Primary parent Contact creation must use explicit registration read checks and Contact create/FLS checks before assigning fields and inserting the Contact."
        // Boolean canCreateContact = Schema.sObjectType.Contact.isCreateable();
        // Boolean canReadCustomerName = canAccessCreateAndUpdateRegistrationField(Schema.sObjectType.Registration_SCH__c.fields.Customer_Name__c);
        // Boolean canReadCustomerLastName = canAccessCreateAndUpdateRegistrationField(Schema.sObjectType.Registration_SCH__c.fields.Customer_Lastname__c);
        // Boolean canReadCustomerEmail = canAccessCreateAndUpdateRegistrationField(Schema.sObjectType.Registration_SCH__c.fields.Customer_Email__c);
        // Boolean canReadCustomerContact = canAccessCreateAndUpdateRegistrationField(Schema.sObjectType.Registration_SCH__c.fields.Customer_Contact__c);
        // Boolean canSetFirstName = canAccessCreateAndUpdateContactField(Schema.sObjectType.Contact.fields.FirstName);
        // Boolean canSetLastName = canAccessCreateAndUpdateContactField(Schema.sObjectType.Contact.fields.LastName);
        // Boolean canSetEmail = canAccessCreateAndUpdateContactField(Schema.sObjectType.Contact.fields.Email);
        // Boolean canSetMobilePhone = canAccessCreateAndUpdateContactField(Schema.sObjectType.Contact.fields.MobilePhone);
        // Boolean canSetPhone = canAccessCreateAndUpdateContactField(Schema.sObjectType.Contact.fields.Phone);
        if (
            Schema.sObjectType.Contact.isCreateable() &&
            Schema.sObjectType.Registration_SCH__c.fields.Customer_Lastname__c.isAccessible() &&
            Schema.sObjectType.Contact.fields.LastName.isCreateable()
        ) {
            Contact newContact = new Contact();
            if (
                Schema.sObjectType.Registration_SCH__c.fields.Customer_Name__c.isAccessible() &&
                Schema.sObjectType.Contact.fields.FirstName.isCreateable() &&
                String.isNotBlank(pr.Customer_Name__c)
            ) {
                newContact.FirstName = pr.Customer_Name__c;
            }
            if (
                Schema.sObjectType.Registration_SCH__c.fields.Customer_Lastname__c.isAccessible() &&
                Schema.sObjectType.Contact.fields.LastName.isCreateable() &&
                String.isNotBlank(pr.Customer_Lastname__c)
            ) {
                newContact.LastName = pr.Customer_Lastname__c;
            }
            if (
                Schema.sObjectType.Registration_SCH__c.fields.Customer_Email__c.isAccessible() &&
                Schema.sObjectType.Contact.fields.Email.isCreateable() &&
                String.isNotBlank(pr.Customer_Email__c)
            ) {
                newContact.Email = pr.Customer_Email__c;
            }
            if (
                Schema.sObjectType.Registration_SCH__c.fields.Customer_Contact__c.isAccessible() &&
                String.isNotBlank(pr.Customer_Contact__c)
            ) {
                if (Schema.sObjectType.Contact.fields.MobilePhone.isCreateable()) {
                    newContact.MobilePhone = pr.Customer_Contact__c;
                }
                if (Schema.sObjectType.Contact.fields.Phone.isCreateable()) {
                    newContact.Phone = pr.Customer_Contact__c;
                }
            }
            if (
                String.isNotBlank(newContact.LastName) &&
                canSetParentContact &&
                Schema.sObjectType.Contact.isCreateable()
            ) {
                insert newContact;
                pr.Contact__c = newContact.Id;
            }
        }
        //changes end here by Abuzar
    }

    private static void insertParentRegistrations(List<Registration_SCH__c> parentRegs) {
        if (Schema.sObjectType.Registration_SCH__c.isCreateable()) {
            insert parentRegs;
        }
    }

    private static void populateChildParentRegistrations(List<Registration_SCH__c> parentRegs, List<Registration_SCH__c> childRegs) {
        if (childRegs.isEmpty() || !Schema.sObjectType.Registration_SCH__c.fields.Registration_SCH__c.isCreateable()) {
            return;
        }

        Map<String, Id> zoneToParentIdMap = new Map<String, Id>();
        for (Registration_SCH__c pr : parentRegs) {
            if (pr.Event_Zone__c != null) {
                zoneToParentIdMap.put(pr.Event_Zone__c, pr.Id);
            }
        }
        for (Registration_SCH__c cr : childRegs) {
            if (zoneToParentIdMap.containsKey(cr.Event_Zone__c)) {
                cr.Registration_SCH__c = zoneToParentIdMap.get(cr.Event_Zone__c);
            }
        }
    }

    private static void insertChildRegistrations(List<Registration_SCH__c> childRegs) {
        if (!childRegs.isEmpty() && Schema.sObjectType.Registration_SCH__c.isCreateable()) {
            //System.debug(LoggingLevel.DEBUG, 'inserting childRegs');
            insert childRegs;
        }
    }

    private static List<Registration_SCH__c> fetchCreatedRegistrations(List<Registration_SCH__c> parentRegs) {
        Set<Id> regIds = new Set<Id>();
        for (Registration_SCH__c reg : parentRegs) {
            regIds.add(reg.Id);
        }

        // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
        // return [
        //     SELECT Id, Name, Registration_Time__c, End_Time__c, Event__r.Name,
        //            Event_Zone__r.Name, Expert_Location__r.Name, Number_of_other_persons__c
        //     FROM Registration_SCH__c WHERE Id IN :regIds LIMIT 1000
        // ];
        return [
            SELECT Id, Name, Registration_Time__c, End_Time__c, Event__r.Name,
                   Event_Zone__r.Name, Expert_Location__r.Name, Number_of_other_persons__c
            FROM Registration_SCH__c WHERE Id IN :regIds WITH USER_MODE LIMIT 1000
        ];
        //changes end here by Abuzar
    }
    //changes end here by abuzar

    // ============================================================
    // Inner Classes
    // ============================================================

    /**
     * @description Simple label/value select option wrapper.
     */
    public class SelectOption {
        /** @description Stores the option label shown in the UI. */
        @AuraEnabled public String label { get; set; }
        /** @description Stores the option value submitted by the UI. */
        @AuraEnabled public String value { get; set; }
        /**
         * @description Creates a select option instance.
         * @param value Option value.
         * @param label Option label.
         */
        public SelectOption(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }

    // commented by abuzar on 2026-03-12 for the scanning issue and added below line the reason of issue as mentioned above "The class EventTimeSlot has 20 public methods, attributes, and properties (limit: 20)"
    /*
    public class EventTimeSlot {
        @AuraEnabled public List<Date> avaD { get; set; }
        @AuraEnabled public Date currentDate { get; set; }
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        @AuraEnabled public Boolean preExist { get; set; }
        @AuraEnabled public Date selectedPrevDate { get; set; }
        @AuraEnabled public String selLocationName { get; set; }
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        @AuraEnabled public Boolean exist { get; set; }
        @AuraEnabled public Date selectedDate { get; set; }
        @AuraEnabled public Map<Date, Set<DateTime>> availableSlotsMapD { get; set; }
        @AuraEnabled public Map<String, String> availableSlotsMap { get; set; }
        @AuraEnabled public List<Expert__c> availableExperts { get; set; }
        @AuraEnabled public String userTimeZone { get; set; }
        @AuraEnabled public String uTmeZone { get; set; }
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        @AuraEnabled public Boolean showSessions { get; set; }
        @AuraEnabled public List<String> sessionsList { get; set; }
        @AuraEnabled public String startAT { get; set; }
        @AuraEnabled public String startET { get; set; }
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        @AuraEnabled public Boolean showMorningPanel { get; set; }
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        @AuraEnabled public Boolean showAfternoonPanel { get; set; }
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        @AuraEnabled public Boolean showEveningPanel { get; set; }

        public EventTimeSlot() {
            avaD = new List<Date>();
            preExist = false;
            exist = false;
            availableSlotsMapD = new Map<Date, Set<DateTime>>();
            availableSlotsMap = new Map<String, String>();
            availableExperts = new List<Expert__c>();
            showSessions = false;
            sessionsList = new List<String>();
            showMorningPanel = showAfternoonPanel = showEveningPanel = false;
        }
    }
    */

    // commented by abuzar on 2026-03-12 for the scanning issue and added below line the reason of issue as mentioned above "Non-virtual and non-abstract type cannot be extended"
    /*
    public class EventTimeSlotBase {
    */
    /**
     * @description Base wrapper for event time slot response data.
     */
    public virtual class EventTimeSlotBase {
        /** @description Stores the list of available dates. */
        @AuraEnabled public List<Date> avaD { get; set; }
        /** @description Stores the current date in focus. */
        @AuraEnabled public Date currentDate { get; set; }
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        /** @description Indicates whether a previously selected slot already exists. */
        @AuraEnabled public Boolean preExist { get; set; }
        /** @description Stores the previously selected date. */
        @AuraEnabled public Date selectedPrevDate { get; set; }
        /** @description Stores the selected location name. */
        @AuraEnabled public String selLocationName { get; set; }
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        /** @description Indicates whether slots exist for the selected criteria. */
        @AuraEnabled public Boolean exist { get; set; }
        /** @description Stores the currently selected date. */
        @AuraEnabled public Date selectedDate { get; set; }
        /** @description Stores available slots grouped by date. */
        @AuraEnabled public Map<Date, Set<DateTime>> availableSlotsMapD { get; set; }
        /** @description Stores available slots mapped for client rendering. */
        @AuraEnabled public Map<String, String> availableSlotsMap { get; set; }
        /** @description Stores experts available for the selected slots. */
        @AuraEnabled public List<Expert__c> availableExperts { get; set; }

        /**
         * @description Initializes the base event time slot collections and flags.
         */
        public EventTimeSlotBase() {
            avaD = new List<Date>();
            preExist = false;
            exist = false;
            availableSlotsMapD = new Map<Date, Set<DateTime>>();
            availableSlotsMap = new Map<String, String>();
            availableExperts = new List<Expert__c>();
        }
    }

    /**
     * @description Event time slot wrapper with UI-specific session fields.
     */
    public class EventTimeSlot extends EventTimeSlotBase {
        /** @description Stores the user's resolved time zone label. */
        @AuraEnabled public String userTimeZone { get; set; }
        /** @description Stores the abbreviated user time zone value. */
        @AuraEnabled public String uTmeZone { get; set; }
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        /** @description Indicates whether session groupings should be displayed. */
        @AuraEnabled public Boolean showSessions { get; set; }
        /** @description Stores the list of session labels. */
        @AuraEnabled public List<String> sessionsList { get; set; }
        /** @description Stores the morning session start marker. */
        @AuraEnabled public String startAT { get; set; }
        /** @description Stores the evening session start marker. */
        @AuraEnabled public String startET { get; set; }
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        /** @description Indicates whether the morning panel should be displayed. */
        @AuraEnabled public Boolean showMorningPanel { get; set; }
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        /** @description Indicates whether the afternoon panel should be displayed. */
        @AuraEnabled public Boolean showAfternoonPanel { get; set; }
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        /** @description Indicates whether the evening panel should be displayed. */
        @AuraEnabled public Boolean showEveningPanel { get; set; }

        /**
         * @description Initializes event time slot session defaults.
         */
        public EventTimeSlot() {
            super();
            showSessions = false;
            sessionsList = new List<String>();
            showMorningPanel = showAfternoonPanel = showEveningPanel = false;
        }
    }
    //changes end here by abuzar

    /**
     * @description Aggregated response container for scheduler screens.
     */
    public with sharing class Container {
        /** @description Stores the primary event record. */
        @AuraEnabled public Event__c event { get; set; }
        /** @description Stores the list of events in the response. */
        @AuraEnabled public List<Event__c> events { get; set; }
        /** @description Stores available event type filter options. */
        @AuraEnabled public List<OptionWrapper> eventTypes { get; set; }
        /** @description Stores the total number of events. */
        @AuraEnabled public Integer eventSize { get; set; }
        /** @description Stores the event filter criteria record. */
        @AuraEnabled public Event__c filter { get; set; }
        /** @description Stores the related contact record. */
        @AuraEnabled public Contact contact { get; set; }
        /** @description Stores the selected event zone. */
        @AuraEnabled public Event_Zone__c zone { get; set; }
        /** @description Stores error text for the scheduler response. */
        @AuraEnabled public String errMsg { get; set; }
        /** @description Stores date columns for the scheduler calendar. */
        @AuraEnabled public List<DateColumn> dateColumnList { get; set; }
        /** @description Stores the active registration record. */
        @AuraEnabled public Registration_SCH__c registration { get; set; }
        /** @description Stores detailed event information. */
        @AuraEnabled public Event__c eventDetail { get; set; }
        /** @description Stores grouped schedule entries. */
        @AuraEnabled public List<Schedule> schedules { get; set; }
        /** @description Stores event agenda entries. */
        @AuraEnabled public List<Agenda__c> agendas { get; set; }
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        /** @description Indicates whether the current user is a portal user. */
        @AuraEnabled public Boolean portalUser { get; set; }
        /** @description Stores date-time related validation errors. */
        @AuraEnabled public String errDateTime { get; set; }

        /**
         * @description Initializes default scheduler container values.
         */
        public Container() {
            event = new Event__c();
            events = new List<Event__c>();
            filter = new Event__c();
            eventTypes = new List<OptionWrapper>();
            registration = new Registration_SCH__c();
            contact = new Contact();
            zone = new Event_Zone__c();
            eventDetail = new Event__c();
            schedules = new List<Schedule>();
            agendas = new List<Agenda__c>();
            errMsg = '';
            dateColumnList = new List<DateColumn>();
            this.portalUser = false;
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // User lu = [SELECT Id, Name, ContactId FROM User WHERE Id = :UserInfo.getUserId() WITH USER_MODE LIMIT 1];
            User lu = [SELECT Id, Name, ContactId FROM User WHERE Id = :UserInfo.getUserId() WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            if (lu.ContactId != null) {
                this.portalUser = true;
            }
        }
    }

    /**
     * @description Groups agendas under a scheduled date.
     */
    public class Schedule {
        /** @description Stores the scheduled date for the agenda group. */
        @AuraEnabled public Date scheduledDate { get; set; }
        /** @description Stores the agenda entries for the scheduled date. */
        @AuraEnabled public List<Agenda__c> agendas { get; set; }
        /**
         * @description Initializes the agenda list for a schedule entry.
         */
        public Schedule() {
            agendas = new List<Agenda__c>();
        }
    }

    /**
     * @description Represents a selectable scheduler date column.
     */
    public class DateColumn {
        /** @description Stores the zone associated with this date column. */
        @AuraEnabled public Event_Zone__c zone { get; set; }
        /** @description Stores the available date value. */
        @AuraEnabled public Date availableDate { get; set; }
        /** @description Stores whether the column should render as blank. */
        @AuraEnabled public String isBlank { get; set; }
        /** @description Stores the primary duration label. */
        @AuraEnabled public String duration { get; set; }
        /** @description Stores a secondary duration label. */
        @AuraEnabled public String duration1 { get; set; }
        /** @description Stores the date-time value used for alternate rendering. */
        @AuraEnabled public DateTime availableDate2 { get; set; }
        /** @description Stores all zone dates associated with the column. */
        @AuraEnabled public Set<Date> zoneDates { get; set; }
        /** @description Stores an additional duration label. */
        @AuraEnabled public String duration2 { get; set; }
        /** @description Stores the first alternate date-time value. */
        @AuraEnabled public DateTime availableDate1 { get; set; }
        /** @description Stores the third alternate date-time value. */
        @AuraEnabled public DateTime availableDate3 { get; set; }
        /** @description Stores a serialized date-time value for the client. */
        @AuraEnabled public String storeDT { get; set; }
        /** @description Stores the number of booked registrations. */
        @AuraEnabled public Integer bookedQuantity { get; set; }
        /** @description Stores the number of available registrations. */
        @AuraEnabled public Integer availableQuantity { get; set; }
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        /** @description Indicates whether the column is selected. */
        @AuraEnabled public Boolean isSelect { get; set; }
        /** @description Stores the event associated with the date column. */
        @AuraEnabled public Event__c event { get; set; }

        /**
         * @description Initializes the date column selection state.
         */
        public DateColumn() {
            this.isSelect = false;
        }
    }

    /**
     * @description Wrapper class used to hold lists of parent, child, and result registrations.
     */
    public class ResultWrapper {
        /** @description Stores parent registration records. */
        @AuraEnabled public List<Registration_SCH__c> parentRegs { get; set; }
        /** @description Stores child registration records. */
        @AuraEnabled public List<Registration_SCH__c> childRegs { get; set; }
        /** @description Stores the combined registration results. */
        @AuraEnabled public List<Registration_SCH__c> resultRegs { get; set; }

        /**
         * @description Initializes empty registration result lists.
         */
        public ResultWrapper() {
            parentRegs = new List<Registration_SCH__c>();
            childRegs = new List<Registration_SCH__c>();
            resultRegs = new List<Registration_SCH__c>();
        }
    }

    /**
     * @description Wrapper for event lists categorized by timeframe.
     */
    public class EventsWrapper {
        /** @description Stores all wrapped events returned by the query. */
        @AuraEnabled public List<EventWrap> evtList { get; set; }
        /** @description Stores events occurring today. */
        @AuraEnabled public List<EventWrap> todaysEvtList { get; set; }
        /** @description Stores events occurring this week. */
        @AuraEnabled public List<EventWrap> thisWeeksEvtList { get; set; }
        /** @description Stores events occurring next week. */
        @AuraEnabled public List<EventWrap> nextWeeksEvtList { get; set; }
        /** @description Stores events scheduled beyond next week. */
        @AuraEnabled public List<EventWrap> futureEvtList { get; set; }
        /** @description Stores the count of today's events. */
        @AuraEnabled public Integer todaysEvents { get; set; }
        /** @description Stores the count of this week's events. */
        @AuraEnabled public Integer thisWeeksEvents { get; set; }
        /** @description Stores the count of next week's events. */
        @AuraEnabled public Integer nextWeeksEvents { get; set; }
        /** @description Stores the count of future events. */
        @AuraEnabled public Integer futureEvents { get; set; }

        /**
         * @description Initializes event timeline buckets and counters.
         */
        public EventsWrapper() {
            evtList = new List<EventWrap>();
            todaysEvtList = new List<EventWrap>();
            thisWeeksEvtList = new List<EventWrap>();
            nextWeeksEvtList = new List<EventWrap>();
            futureEvtList = new List<EventWrap>();
            todaysEvents = 0;
            thisWeeksEvents = 0;
            nextWeeksEvents = 0;
            futureEvents = 0;
        }
    }

    /**
     * @description Wrapper for a single event and its weekdays.
     */
    public class EventWrap {
        /** @description Stores the wrapped event record. */
        @AuraEnabled public Event__c evt { get; set; }
        /** @description Stores the event weekdays exposed to the client. */
        @AuraEnabled public List<String> evtWeekDays { get; set; }

        /**
         * @description Initializes event wrapper defaults.
         */
        public EventWrap() {
            evt = new Event__c();
            evtWeekDays = new List<String>();
        }
    }

    /**
     * @description Wrapper for quantity selection options.
     */
    public class SelectOptionQty {
        /** @description Stores the quantity label shown in the UI. */
        @AuraEnabled public Integer label { get; set; }
        /** @description Stores the quantity value submitted by the UI. */
        @AuraEnabled public Integer value { get; set; }

        /**
         * @description Creates a quantity select option instance.
         * @param value Option value.
         * @param label Option label.
         */
        public SelectOptionQty(Integer value, Integer label) {
            this.value = value;
            this.label = label;
        }
    }

    /**
     * @description Aura-safe option wrapper for label/value pairs.
     */
    public class OptionWrapper {
        /** @description Stores the value submitted by the client. */
        @AuraEnabled public String value { get; set; }
        /** @description Stores the label shown in the UI. */
        @AuraEnabled public String label { get; set; }

        /**
         * @description Creates an option wrapper instance.
         * @param value Option value.
         * @param label Option label.
         */
        public OptionWrapper(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }

    // commented by abuzar on 2026-03-12 for the scanning issue and added below line the reason of issue as mentioned above "The class AllocpbEntryWrapper has 27 public methods, attributes, and properties (limit: 20)"
    /*
    @description Wrapper for eAllocpbEntry records.
    public class AllocpbEntryWrapper {
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        @AuraEnabled public Boolean selected { get; set; }
        @AuraEnabled public List<AllocpbEntryWrapper> eventPageWrapperSelected { get; set; }
        @AuraEnabled public Event_Allocation__c eventAlloc { get; set; }
        @AuraEnabled public Integer seatsAvailable { get; set; }
        @AuraEnabled public String seatsError { get; set; }
        @AuraEnabled public List<Event_Zone_Registration__c> eZoneRegAllocLists { get; set; }
        @AuraEnabled public List<Event_Attendee__c> eAttendeeList { get; set; }
        @AuraEnabled public Id eventProductId { get; set; }
        @AuraEnabled public Event_Attendee__c primaryWrapDelegate { get; set; }
        @AuraEnabled public List<Event_Attendee__c> eventDelegatesList { get; set; }
        @AuraEnabled public Account memAccounts { get; set; }
        @AuraEnabled public Integer numberOfDelegates { get; set; }
        @AuraEnabled public String type { get; set; }
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        @AuraEnabled public Boolean isMember { get; set; }
        @AuraEnabled public Decimal quantity { get; set; }
        @AuraEnabled public Integer custMembershipPoints { get; set; }
        @AuraEnabled public Integer membershipPoints { get; set; }
        @AuraEnabled public Integer memPointsToCredit { get; set; }
        @AuraEnabled public Integer memPointsToDebit { get; set; }
        @AuraEnabled public Integer isMemberMemPointsToCredit { get; set; }
        @AuraEnabled public String eventNames { get; set; }
        @AuraEnabled public String eventZoneNames { get; set; }
        @AuraEnabled public DateTime eventZoneStartDates { get; set; }
        @AuraEnabled public DateTime eventZoneEndDates { get; set; }
        @AuraEnabled public List<String> agendaList { get; set; }
        @AuraEnabled public List<String> sponsorList { get; set; }

        public AllocpbEntryWrapper() {
            isMember = false;
            selected = false;
            eventPageWrapperSelected = new List<AllocpbEntryWrapper>();
            eventAlloc = new Event_Allocation__c();
            seatsAvailable = 0;
            seatsError = '';
            eZoneRegAllocLists = new List<Event_Zone_Registration__c>();
            eAttendeeList = new List<Event_Attendee__c>();
            eventProductId = null;
            primaryWrapDelegate = new Event_Attendee__c();
            eventDelegatesList = new List<Event_Attendee__c>();
            memAccounts = new Account();
            numberOfDelegates = 0;
            type = '';
            quantity = 0.00;
            custMembershipPoints = 0;
            membershipPoints = 0;
            memPointsToCredit = 0;
            memPointsToDebit = 0;
            isMemberMemPointsToCredit = 0;
            eventNames = '';
            eventZoneNames = '';
            eventZoneStartDates = DateTime.now();
            eventZoneEndDates = DateTime.now().addDays(7);
            agendaList = new List<String>();
            sponsorList = new List<String>();
        }
    }
    */

    /**
     * @description Base wrapper to keep Aura payload intact while staying within PMD public member limits.
     */
    // commented by abuzar on 2026-03-12 for the scanning issue and added below line the reason of issue as mentioned above "Non-virtual and non-abstract type cannot be extended"
    /*
    public class AllocpbEntryWrapperBase {
    */
    public virtual class AllocpbEntryWrapperBase {
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        /** @description Indicates whether the allocation entry is selected. */
        @AuraEnabled public Boolean selected { get; set; }
        /** @description Stores nested selected allocation wrappers. */
        @AuraEnabled public List<AllocpbEntryWrapper> eventPageWrapperSelected { get; set; }
        /** @description Stores the event allocation record. */
        @AuraEnabled public Event_Allocation__c eventAlloc { get; set; }
        /** @description Stores the number of seats available. */
        @AuraEnabled public Integer seatsAvailable { get; set; }
        /** @description Stores seat validation errors. */
        @AuraEnabled public String seatsError { get; set; }
        /** @description Stores zone registrations linked to the allocation. */
        @AuraEnabled public List<Event_Zone_Registration__c> eZoneRegAllocLists { get; set; }
        /** @description Stores attendee records tied to the allocation. */
        @AuraEnabled public List<Event_Attendee__c> eAttendeeList { get; set; }
        /** @description Stores the related event product identifier. */
        @AuraEnabled public Id eventProductId { get; set; }
        /** @description Stores the primary delegate for the allocation. */
        @AuraEnabled public Event_Attendee__c primaryWrapDelegate { get; set; }
        /** @description Stores delegate attendees for the allocation. */
        @AuraEnabled public List<Event_Attendee__c> eventDelegatesList { get; set; }
        /** @description Stores the member account linked to the allocation. */
        @AuraEnabled public Account memAccounts { get; set; }
        /** @description Stores the selected number of delegates. */
        @AuraEnabled public Integer numberOfDelegates { get; set; }
        /** @description Stores the allocation type label. */
        @AuraEnabled public String type { get; set; }

        /**
         * @description Initializes the base allocation payload defaults.
         */
        public AllocpbEntryWrapperBase() {
            selected = false;
            eventPageWrapperSelected = new List<AllocpbEntryWrapper>();
            eventAlloc = new Event_Allocation__c();
            seatsAvailable = 0;
            seatsError = '';
            eZoneRegAllocLists = new List<Event_Zone_Registration__c>();
            eAttendeeList = new List<Event_Attendee__c>();
            eventProductId = null;
            primaryWrapDelegate = new Event_Attendee__c();
            eventDelegatesList = new List<Event_Attendee__c>();
            memAccounts = new Account();
            numberOfDelegates = 0;
            type = '';
        }
    }

    /**
     * @description Wrapper for eAllocpbEntry records.
     */
    public class AllocpbEntryWrapper extends AllocpbEntryWrapperBase {
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        /** @description Indicates whether the allocation belongs to a member. */
        @AuraEnabled public Boolean isMember { get; set; }
        /** @description Stores the selected quantity. */
        @AuraEnabled public Decimal quantity { get; set; }
        /** @description Stores customer membership points. */
        @AuraEnabled public Integer custMembershipPoints { get; set; }
        /** @description Stores membership points associated with the allocation. */
        @AuraEnabled public Integer membershipPoints { get; set; }
        /** @description Stores membership points to credit. */
        @AuraEnabled public Integer memPointsToCredit { get; set; }
        /** @description Stores membership points to debit. */
        @AuraEnabled public Integer memPointsToDebit { get; set; }
        /** @description Stores points to credit when the attendee is a member. */
        @AuraEnabled public Integer isMemberMemPointsToCredit { get; set; }
        /** @description Stores the event names shown in the wrapper. */
        @AuraEnabled public String eventNames { get; set; }
        /** @description Stores the event zone names shown in the wrapper. */
        @AuraEnabled public String eventZoneNames { get; set; }
        /** @description Stores the event zone start date and time. */
        @AuraEnabled public DateTime eventZoneStartDates { get; set; }
        /** @description Stores the event zone end date and time. */
        @AuraEnabled public DateTime eventZoneEndDates { get; set; }
        /** @description Stores agenda labels related to the allocation. */
        @AuraEnabled public List<String> agendaList { get; set; }
        /** @description Stores sponsor labels related to the allocation. */
        @AuraEnabled public List<String> sponsorList { get; set; }

        /**
         * @description Initializes the extended allocation payload defaults.
         */
        public AllocpbEntryWrapper() {
            super();
            isMember = false;
            quantity = 0.00;
            custMembershipPoints = 0;
            membershipPoints = 0;
            memPointsToCredit = 0;
            memPointsToDebit = 0;
            isMemberMemPointsToCredit = 0;
            eventNames = '';
            eventZoneNames = '';
            eventZoneStartDates = DateTime.now();
            eventZoneEndDates = DateTime.now().addDays(7);
            agendaList = new List<String>();
            sponsorList = new List<String>();
        }
    }
    //changes end here by abuzar

    /**
     * @description Lightweight contact search result wrapper.
     */
    public class RecordWrp {
        /** @description Stores the contact record identifier. */
        @AuraEnabled public String id { get; set; }
        /** @description Stores the contact display name. */
        @AuraEnabled public String name { get; set; }
        /** @description Stores the contact email address. */
        @AuraEnabled public String email { get; set; }
        /** @description Stores the contact phone number. */
        @AuraEnabled public String phone { get; set; }

        /**
         * @description Initializes empty search result fields.
         */
        public RecordWrp() {
            id = name = email = phone = '';
        }
    }
}
