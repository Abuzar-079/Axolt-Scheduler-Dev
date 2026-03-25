// commented by abuzar on 2026-03-13 for the scanning issue and added below line "Apex classes should declare a sharing model if DML or SOQL/SOSL is used"
// public class QueueExpertSchSupport {
/**
 * @description Shared helper methods for queue expert scheduler operations.
 */
public inherited sharing class QueueExpertSchSupport {
    private static final String TODAYS_APPOINTMENTS = 'Todays Appointments';
    private static final String CHECK_IN_APPOINTMENTS = 'Check In Appointments';
    private static final String FUTURE_APPOINTMENTS = 'Future Appointments';
    private static final String PAST_APPOINTMENTS = 'Past Appointments';
    private static final String COMPLETED_APPOINTMENTS = 'Completed Appointments';
    private static final List<String> INITIAL_APPOINTMENT_FILTERS = new List<String>{
        CHECK_IN_APPOINTMENTS,
        TODAYS_APPOINTMENTS
    };
    private static final List<Queue_Expert_Sch.SelectOptions> CATEGORY_OPTIONS = new List<Queue_Expert_Sch.SelectOptions>{
        new Queue_Expert_Sch.SelectOptions(TODAYS_APPOINTMENTS, TODAYS_APPOINTMENTS),
        new Queue_Expert_Sch.SelectOptions(CHECK_IN_APPOINTMENTS, CHECK_IN_APPOINTMENTS),
        new Queue_Expert_Sch.SelectOptions(FUTURE_APPOINTMENTS, FUTURE_APPOINTMENTS),
        new Queue_Expert_Sch.SelectOptions(PAST_APPOINTMENTS, PAST_APPOINTMENTS),
        new Queue_Expert_Sch.SelectOptions(COMPLETED_APPOINTMENTS, COMPLETED_APPOINTMENTS)
    };
    private static final Set<String> ALLOWED_CAT_VALUES = new Set<String>{
        CHECK_IN_APPOINTMENTS,
        TODAYS_APPOINTMENTS,
        PAST_APPOINTMENTS,
        COMPLETED_APPOINTMENTS,
        FUTURE_APPOINTMENTS
    };
    private static final Map<String, String> CATEGORY_QUERY_FILTERS = new Map<String, String>{
        CHECK_IN_APPOINTMENTS => ' AND Appointment_DateDt__c = TODAY AND Status__c = \'Booked\' AND Check_In__c = TRUE',
        TODAYS_APPOINTMENTS => ' AND Appointment_DateDt__c = TODAY AND Status__c = \'Booked\' AND Registration_Time__c >= :nowTime',
        PAST_APPOINTMENTS => ' AND Check_In__c = FALSE AND Registration_Time__c <= :nowTime',
        COMPLETED_APPOINTMENTS => ' AND Status__c = \'Completed\'',
        FUTURE_APPOINTMENTS => ' AND Appointment_DateDt__c > TODAY AND Status__c = \'Booked\' AND Registration_Time__c >= :nowTime'
    };
    private static final String LOCATION_LOAD_FIELDS =
        'Id, Name, OwnerId, RecordTypeId, Status__c, Appointment_DateDt__c, Check_In__c, '
        + 'Registration_Time__c, Booked_Date__c, Expert_Location__c, Product2__c, User__c, '
        + 'Account__r.Flagged__c, Contact__r.Flagged__c, Product2__r.SCH_Wait_Threshold__c, '
        + 'Contact__r.Name, Booked_Current_Status__c, Checked_in_Date_Time__c';

    /**
     * @description Builds a location-load request from ordered request values.
     * @param requestValues Ordered list of location, resource, service, and category values.
     * @return Parsed location-load request wrapper.
     */
    public static QueueExpertLocationLoadRequest buildLocationLoadRequest(List<String> requestValues) {
        QueueExpertLocationLoadRequest request = new QueueExpertLocationLoadRequest();
        request.locationId = normalizeInput(QueueExpertSchSupportHelper.getRequestValue(requestValues, 0));
        request.resourceId = normalizeInput(QueueExpertSchSupportHelper.getRequestValue(requestValues, 1));
        request.serviceId = normalizeInput(QueueExpertSchSupportHelper.getRequestValue(requestValues, 2));
        request.category = normalizeInput(QueueExpertSchSupportHelper.getRequestValue(requestValues, 3));
        return request;
    }

    /**
     * @description Converts blank string input values to `null`.
     * @param value Raw input value.
     * @return Trimmed input value or `null` when blank.
     */
    public static String normalizeInput(String value) {
        return String.isBlank(value) ? null : value;
    }

    /**
     * @description Returns the user name for the provided user Id.
     * @param userId Salesforce user identifier.
     * @return User name, or `null` when no matching user is found.
     */
    public static String getUserName(String userId) {
        if (String.isBlank(userId)) {
            return null;
        }
        // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
        // List<User> users = [SELECT Id, Name FROM User WHERE Id = :userId WITH USER_MODE LIMIT 1];
        List<User> users = [SELECT Id, Name FROM User WHERE Id = :userId WITH USER_MODE LIMIT 1];
        //changes end here by Abuzar
        return users.isEmpty() ? null : users[0].Name;
    }

    /**
     * @description Builds the initial queue expert wrapper for the current user.
     * @param userId Salesforce user identifier.
     * @return Initial wrapper populated with appointment data.
     */
    public static Queue_Expert_Sch.Wrapper getInitialWrapper(String userId) {
        for (String category : INITIAL_APPOINTMENT_FILTERS) {
            Queue_Expert_Sch.Wrapper initialWrapper = Queue_Expert_Sch.getRecordsOfLocationsonLoad(null, userId, null, null, category);
            initialWrapper.appointmentFiler = category;
            if (!initialWrapper.records.isEmpty() || category == TODAYS_APPOINTMENTS) {
                return initialWrapper;
            }
        }
        return new Queue_Expert_Sch.Wrapper();
    }

    /**
     * @description Assigns appointment, customer, and meeting field-set metadata to the wrapper.
     * @param wrapper Wrapper to enrich with field-set metadata.
     */
    public static void assignFieldSetMetadata(Queue_Expert_Sch.Wrapper wrapper) {
        wrapper.appointmentFields = Queue_Expert_Sch.getFieldsSetApiName('Registration_SCH__c', 'WB_Appointment_Details');
        wrapper.customerFields = Queue_Expert_Sch.getFieldsSetApiName('Registration_SCH__c', 'WB_Customer_Details');
        wrapper.meetingFields = Queue_Expert_Sch.getFieldsSetApiName('Registration_SCH__c', 'WB_Meeting_Details');
    }

    /**
     * @description Copies available category options into the wrapper.
     * @param wrapper Wrapper to enrich with category options.
     */
    public static void assignCategoryOptions(Queue_Expert_Sch.Wrapper wrapper) {
        wrapper.allCategory = new List<Queue_Expert_Sch.SelectOptions>();
        wrapper.allCategory.addAll(CATEGORY_OPTIONS);
    }

    /**
     * @description Validates the requested appointment category.
     * @param category Category value to validate.
     */
    public static void validateCategory(String category) {
        if (category != null && !ALLOWED_CAT_VALUES.contains(category)) {
            throw new AuraHandledException('Invalid category: ' + category);
        }
    }

    /**
     * @description Queries registration records for the supplied location-load request.
     * @param request Location-load request containing selected filters.
     * @return Matching registration records.
     */
    public static List<Registration_SCH__c> queryLocationRecords(QueueExpertLocationLoadRequest request) {
        DateTime nowTime = System.now();
        Map<String, Object> bindVars = new Map<String, Object>{
            'nowTime' => nowTime,
            'currentUserId' => UserInfo.getUserId()
        };
        String query = 'SELECT ' + LOCATION_LOAD_FIELDS + ' FROM Registration_SCH__c WHERE Product2__c != null';
        query += CATEGORY_QUERY_FILTERS.containsKey(request.category) ? CATEGORY_QUERY_FILTERS.get(request.category) : '';
        query = QueueExpertSchSupportHelper.addLocationFilter(query, bindVars, request.locationId);
        query = QueueExpertSchSupportHelper.addServiceFilter(query, bindVars, request.serviceId);
        query = QueueExpertSchSupportHelper.addResourceFilter(query, bindVars, request.resourceId);
        query += ' ORDER BY Booked_Date__c ASC LIMIT 1000';
        return (List<Registration_SCH__c>)Database.queryWithBinds(query, bindVars, AccessLevel.USER_MODE);
    }

    /**
     * @description Populates the queue expert wrapper from queried registration records.
     * @param wrapper Wrapper to populate.
     * @param records Registration records to add to the wrapper.
     */
    public static void populateWrapperFromRecords(Queue_Expert_Sch.Wrapper wrapper, List<Registration_SCH__c> records) {
        Integer index = 0;
        for (Registration_SCH__c recordItem : records) {
            QueueExpertSchSupportHelper.addInProgressRecord(wrapper, recordItem);
            wrapper.mapOfRecords.put(String.valueOf(index), recordItem);
            wrapper.regRecords.add(QueueExpertSchSupportHelper.buildRecordWrapper(recordItem));
            index++;
        }
        loadPrimaryRecordRelatedData(wrapper);
    }

    /**
     * @description Loads related data for the wrapper's primary registration record.
     * @param wrapper Wrapper to enrich with related data.
     */
    public static void loadPrimaryRecordRelatedData(Queue_Expert_Sch.Wrapper wrapper) {
        QueueExpertSchSupportHelper.loadPrimaryRecordRelatedData(wrapper);
    }

    /**
     * @description Deserializes client-submitted record values for queue updates.
     * @param recValues Serialized list of record values.
     * @param wrapper Wrapper used to store error details on failure.
     * @return Deserialized record values, or an empty list when parsing fails.
     */
    public static List<String> deserializeRecordValues(String recValues, Queue_Expert_Sch.Wrapper wrapper) {
        try {
            return (List<String>)JSON.deserialize(recValues, List<String>.class);
        } catch (Exception e) {
            wrapper.errmsg = e.getMessage() + ' 1@' + e.getLineNumber();
            //System.debug(LoggingLevel.DEBUG, 'getRecordUpdate Exception' + e.getMessage() + ' @@' + e.getLineNumber() + ' ST=>' + e.getStackTraceString());
            return new List<String>();
        }
    }

    /**
     * @description Applies shared customer and meeting field values to a registration.
     * @param registrationToUpdate Registration record being updated.
     * @param recordValues Ordered client-submitted record values.
     */
    public static void applyCommonRecordValues(Registration_SCH__c registrationToUpdate, List<String> recordValues) {
        registrationToUpdate.Customer_Type__c = getRecordValue(recordValues, 1);
        registrationToUpdate.Registration_Type__c = getRecordValue(recordValues, 2);
        registrationToUpdate.Meeting_Status__c = getRecordValue(recordValues, 3);
        registrationToUpdate.Meeting_outcome__c = getRecordValue(recordValues, 4);
        registrationToUpdate.Purpose__c = getRecordValue(recordValues, 5);
        registrationToUpdate.Customer_Name__c = getRecordValue(recordValues, 6);
        registrationToUpdate.Customer_Lastname__c = getRecordValue(recordValues, 7);
        registrationToUpdate.Customer_Email__c = getRecordValue(recordValues, 8);
        registrationToUpdate.Customer_Contact__c = getRecordValue(recordValues, 9);
    }

    /**
     * @description Returns a record value at the requested index when present.
     * @param recordValues Ordered client-submitted record values.
     * @param index Zero-based index to read.
     * @return Requested value, or `null` when the index is unavailable.
     */
    public static String getRecordValue(List<String> recordValues, Integer index) {
        return recordValues.size() > index ? recordValues[index] : null;
    }

    /**
     * @description Applies completion state updates derived from the submitted record values.
     * @param registrationToUpdate Registration record being updated.
     * @param recordValues Ordered client-submitted record values.
     */
    public static void applyUpdateRecordValuesState(Registration_SCH__c registrationToUpdate, List<String> recordValues) {
        if (recordValues.size() >= 15) {
            registrationToUpdate.Status__c = 'Completed';
        }
        if (recordValues.size() >= 16) {
            registrationToUpdate.Contact__c = QueueExpertSchSupportHelper.getNormalizedContactValue(recordValues[15]);
        }
    }

    /**
     * @description Loads full registration details and related data into the wrapper.
     * @param wrapper Wrapper to populate.
     * @param regId Registration identifier to load.
     */
    public static void loadWrapperDetailsForRegistration(Queue_Expert_Sch.Wrapper wrapper, String regId) {
        // commented by abuzar on 2026-03-14 for the scanning issue and added below line "duplicate registration detail queries should be centralized to avoid DetectCopyPasteForApex violations"
        // wrapper.objectValues = [SELECT id, Name, OwnerId, RecordTypeId, Account__r.Flagged__c,Account__c,Account__r.Name, Expert_Location__c,Company__c, Customer_Status__c,Is_Amount_Refunded__c,
        //                         Twilio_Message__c, Queue__c,Queue__r.Name,Customer_Type__c, Status__c, Registration_Type__c,Registration_Time__c,Registration_End_Time__c,Product2__r.SCH_Wait_Threshold__c,End_Time__c,Wait_Time_Exceeded__c,
        //                         Meeting_Status__c, Meeting_outcome__c,  Purpose__c,Customer_Name__c, Customer_Lastname__c, Customer_Email__c,Customer_Contact__c, Registration_Price__c,waiting_Time__c, Total_Tax_Amount__c, Discount__c,Booked_Current_Status__c
        //                         FROM Registration_SCH__c WHERE id=:regId LIMIT 1000];
        // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
        // wrapper.objectValues = [SELECT id, User__c, Name, OwnerId, RecordTypeId, Wait_Time_Exceeded__c, Contact__c, Account__c, Account__r.Flagged__c, Account__r.Name, Expert_Location__c,
        //                         Company__c, Customer_Status__c, Is_Amount_Refunded__c, Twilio_Message__c, Queue__c, Queue__r.Name, Customer_Type__c, Status__c, Registration_Type__c,
        //                         Registration_Time__c, Registration_End_Time__c, Product2__r.SCH_Wait_Threshold__c, End_Time__c, Meeting_Status__c, Meeting_outcome__c, Purpose__c,
        //                         Customer_Name__c, Customer_Lastname__c, Customer_Email__c, Customer_Contact__c, waiting_Time__c, Registration_Price__c, Total_Tax_Amount__c, Discount__c,
        //                         Booked_Current_Status__c, LastModifiedDate
        //                         FROM Registration_SCH__c WHERE id = :regId LIMIT 1000];
        wrapper.objectValues = [SELECT id, User__c, Name, OwnerId, RecordTypeId, Wait_Time_Exceeded__c, Contact__c, Account__c, Account__r.Flagged__c, Account__r.Name, Expert_Location__c,
                                Company__c, Customer_Status__c, Is_Amount_Refunded__c, Twilio_Message__c, Queue__c, Queue__r.Name, Customer_Type__c, Status__c, Registration_Type__c,
                                Registration_Time__c, Registration_End_Time__c, Product2__r.SCH_Wait_Threshold__c, End_Time__c, Meeting_Status__c, Meeting_outcome__c, Purpose__c,
                                Customer_Name__c, Customer_Lastname__c, Customer_Email__c, Customer_Contact__c, waiting_Time__c, Registration_Price__c, Total_Tax_Amount__c, Discount__c,
                                Booked_Current_Status__c, LastModifiedDate
                                FROM Registration_SCH__c WHERE id = :regId WITH USER_MODE LIMIT 1000];
        //changes end here by Abuzar
        //changes end here by abuzar
        loadPrimaryRecordRelatedData(wrapper);
    }

}
//changes end here by abuzar
