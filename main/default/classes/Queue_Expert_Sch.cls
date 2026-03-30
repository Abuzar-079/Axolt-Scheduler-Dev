/**
 * @description Provides queue expert scheduling operations for appointment management.
 */
@SuppressWarnings('PMD.CognitiveComplexity')
public with sharing class Queue_Expert_Sch {
    // commented by abuzar on 2026-03-30 for the scanning issue and added below line "Shared constants and helper request models were extracted into dedicated support classes to reduce Queue_Expert_Sch class cyclomatic complexity, cognitive complexity, and NCSS."
    // private static final Set<String> SUPPORTED_RELATED_RECORD_OBJECTS = new Set<String>{ ... };
    // private static final Integer MAX_ATTACHMENT_SIZE_BYTES = 4500000;
    // private static final Set<String> ALLOWED_ATTACHMENT_EXTENSIONS = new Set<String>{ ... };
    // private static final Set<String> ALLOWED_ATTACHMENT_CONTENT_TYPES = new Set<String>{ ... };
    // private static final Map<Integer, String> UPDATE_RECORD_FIELDS_BY_INDEX = new Map<Integer, String>{ ... };
    // private static final Set<String> UPDATE_RECORD_MUTABLE_FIELDS = new Set<String>{ ... };
    // private enum FieldAccessType { READ, CREATE, EDIT }
    // private class FieldAccessRequest { ... }
    // private static FieldAccessRequest buildFieldAccessRequest(...) { ... }
    // this controller now mainly preserves Aura entry points and delegates work to focused support classes, so PMD's class-total cognitive complexity is inflated even though each remaining method is trivial
    //changes end here by abuzar
    private static final String TODAYS_APPOINTMENTS = 'Todays Appointments';
    private static final String CHECK_IN_APPOINTMENTS = 'Check In Appointments';
    private static final String FUTURE_APPOINTMENTS = 'Future Appointments';
    private static final String PAST_APPOINTMENTS = 'Past Appointments';
    private static final String COMPLETED_APPOINTMENTS = 'Completed Appointments';
    private static final List<String> INITIAL_APPOINTMENT_FILTERS = new List<String>{
        CHECK_IN_APPOINTMENTS,
        TODAYS_APPOINTMENTS
    };
    private static final List<QueueExpertSelectOptions> CATEGORY_OPTIONS = new List<QueueExpertSelectOptions>{
        new QueueExpertSelectOptions(TODAYS_APPOINTMENTS, TODAYS_APPOINTMENTS),
        new QueueExpertSelectOptions(CHECK_IN_APPOINTMENTS, CHECK_IN_APPOINTMENTS),
        new QueueExpertSelectOptions(FUTURE_APPOINTMENTS, FUTURE_APPOINTMENTS),
        new QueueExpertSelectOptions(PAST_APPOINTMENTS, PAST_APPOINTMENTS),
        new QueueExpertSelectOptions(COMPLETED_APPOINTMENTS, COMPLETED_APPOINTMENTS)
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
     * @description Updates a registration record with queue expert completion details.
     * @param regId Registration identifier to update.
     * @param recValues Serialized field values submitted by the client.
     * @param userID User identifier associated with the action.
     * @param recordType Record type context for the update.
     * @param queueId Queue identifier associated with the registration.
     * @param accountId Account identifier associated with the registration.
     * @param event Event identifier associated with the registration.
     * @param location Expert location identifier.
     * @param sDate Start date and time for the registration.
     * @param eDate End date and time for the registration.
     * @return Wrapper containing update status or error details.
     */
    @AuraEnabled(cacheable=false)
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static QueueExpertWrapper updateRecordValues(String regId, String recValues, String userID, String recordType, String queueId, String accountId, String event, String location, DateTime sDate, DateTime eDate) {
        // commented by abuzar on 2026-03-30 for the scanning issue and added below line "Moved record-update action logic into a dedicated support class to reduce Queue_Expert_Sch class-level complexity and NCSS."
        // existing method body moved to QueueExpertRecordActionSupport.updateRecordValues(...)
        return QueueExpertRecordActionSupport.updateRecordValues(regId, recValues, userID, recordType, queueId, accountId, event, location, sDate, eDate);
        //changes end here by abuzar
    }

    /**
     * @description Returns field API names from the requested field set.
     * @param sObjectName API name of the target object.
     * @param fieldSetApiName API name of the field set.
     * @return Field API names in the configured field set order.
     */
    @AuraEnabled
    public static List<String> getFieldsSetApiName(String sObjectName, string fieldSetApiName) {
        List<String> fields = new List<String>();
        // commented by abuzar on 2026-03-30 for the scanning issue and added below line "DescribeSObjectResult could be loaded eagerly with all child relationships, which triggers the EagerlyLoadedDescribeSObjectResult PMD violation."
        // for (Schema.FieldSetMember field : schema.getGlobalDescribe().get(sObjectName).getDescribe().fieldSets.getMap().get(fieldSetApiName).getFields()) {
        for (Schema.FieldSetMember field : schema.getGlobalDescribe().get(sObjectName).getDescribe(SObjectDescribeOptions.DEFERRED).fieldSets.getMap().get(fieldSetApiName).getFields()) {
            fields.add(field.getFieldPath());
        }
        //changes end here by abuzar
        return fields;
    }

    /**
     * @description Initializes queue expert screen data for the current user.
     * @return Wrapper populated with setup metadata and initial records.
     */
    @AuraEnabled
    public static QueueExpertWrapper initSetUp() {
        QueueExpertWrapper wrapper = new QueueExpertWrapper();
        try {
            String userid = UserInfo.getUserId();
            // commented by abuzar on 2026-03-13 for the scanning issue and added below line "moved setup helper logic into the support class to reduce Queue_Expert_Sch class cyclomatic complexity"
            // wrapper = getInitialWrapper(userid);
            wrapper = QueueExpertSchSupport.getInitialWrapper(userid);
            // wrapper.selectedUserName = getUserName(userid);
            wrapper.selectedUserName = QueueExpertSchSupport.getUserName(userid);
            wrapper.existLocation = true;
            // assignFieldSetMetadata(wrapper);
            QueueExpertSchSupport.assignFieldSetMetadata(wrapper);
            // assignCategoryOptions(wrapper);
            QueueExpertSchSupport.assignCategoryOptions(wrapper);
            //changes end here by abuzar
            //System.debug(LoggingLevel.DEBUG, 'queueFields==>' + wrapper.queueFields);
            //System.debug(LoggingLevel.DEBUG, 'wrapper.regRecords==>' + wrapper.regRecords);
        } catch (Exception e) {
            wrapper.errmsg = 'Unable to initialize queue expert data.';
        }
        return wrapper;
    }

    /**
     * @description Loads queue records for the requested location filters.
     * @param location Location identifier filter.
     * @param resource Resource identifier filter.
     * @param service Service identifier filter.
     * @param program Program filter value.
     * @param catValue Appointment category filter.
     * @return Wrapper containing the filtered records and related metadata.
     */
    @AuraEnabled
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static QueueExpertWrapper getRecordsOfLocationsonLoad(String location, String resource, String service, String program, String catValue) {
        //System.debug(LoggingLevel.DEBUG, 'getRecordsOfLocations is called' + program + ' , ' + catValue);
        //System.debug(LoggingLevel.DEBUG, 'location=>' + location + ', service==>' + service + ' ,program=>' + program);
        QueueExpertWrapper wrapper = new QueueExpertWrapper();
        // commented by abuzar on 2026-03-13 for the scanning issue and added below line "removed the long helper constructor parameter list and moved record-loading logic into the support class"
        // LocationLoadRequest request = new LocationLoadRequest(location, resource, service, catValue);
        // QueueExpertLocationLoadRequest request = QueueExpertSchSupport.buildLocationLoadRequest(location, resource, service, catValue);
        QueueExpertLocationLoadRequest request = QueueExpertSchSupport.buildLocationLoadRequest(new List<String>{ location, resource, service, catValue });
        // validateCategory(request.category);
        QueueExpertSchSupport.validateCategory(request.category);
        // wrapper.records = queryLocationRecords(request);
        wrapper.records = QueueExpertSchSupport.queryLocationRecords(request);
        wrapper.existLocation = !wrapper.records.isEmpty();
        // populateWrapperFromRecords(wrapper, wrapper.records);
        QueueExpertSchSupport.populateWrapperFromRecords(wrapper, wrapper.records);
        //changes end here by abuzar
        //System.debug(LoggingLevel.DEBUG, 'map==>' + wrapper.mapOfRecords);
        //System.debug(LoggingLevel.DEBUG, 'wrapper.regRecords==>' + wrapper.regRecords);

        return wrapper;
    }

    // REMOVED: serviceForExpert method - depends on Resource__c, Team_Member__c
    // This method queried Resource__c and Team__c and has been removed

    // REMOVED: getRecordsOfLocations method - used Resource__r.User__c and Resource__r.Team__c references
    /**
     * @description Marks a registration as in progress and loads its related detail data.
     * @param id Registration identifier.
     * @param location Location context for the popup action.
     * @param waitingTime Wait time to store on the registration.
     * @return Wrapper containing refreshed registration details.
     */
    @AuraEnabled(cacheable=false)
    public static QueueExpertWrapper popUpRecordsOfId(string id, String location,String waitingTime){
        // commented by abuzar on 2026-03-30 for the scanning issue and added below line "Moved popup record action logic into a dedicated support class to reduce Queue_Expert_Sch class-level complexity and NCSS."
        // existing method body moved to QueueExpertRecordActionSupport.popUpRecordsOfId(...)
        return QueueExpertRecordActionSupport.popUpRecordsOfId(id, location, waitingTime);
        //changes end here by abuzar
    }

    /**
     * @description Loads registration detail data for the queue expert view.
     * @param id Registration identifier.
     * @return Wrapper containing the selected registration and related records.
     */
    @AuraEnabled
    public static QueueExpertWrapper getRegDetails(string id){
        // commented by abuzar on 2026-03-30 for the scanning issue and added below line "Moved registration-detail loading logic into a dedicated support class to reduce Queue_Expert_Sch class-level complexity and NCSS."
        // existing method body moved to QueueExpertRecordActionSupport.getRegDetails(...)
        return QueueExpertRecordActionSupport.getRegDetails(id);
        //changes end here by abuzar
    }

    /**
     * @description Updates the registration status and completion details.
     * @param passedId Registration identifier to update.
     * @param location Location context for the status change.
     * @param status New registration status value.
     * @param purpose Cancellation or completion reason.
     * @return Wrapper indicating whether the update succeeded.
     */
    @AuraEnabled(cacheable=false)
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static QueueExpertWrapper setStatus(String passedId, String location,String status,String purpose){
        // commented by abuzar on 2026-03-30 for the scanning issue and added below line "Moved status-update action logic into a dedicated support class to reduce Queue_Expert_Sch class-level complexity and NCSS."
        // existing method body moved to QueueExpertRecordActionSupport.setStatus(...)
        // commented by abuzar on 2026-03-30 for the scanning issue and added below line "The support-layer setStatus method no longer accepts the unused location parameter after reducing its parameter count."
        // return QueueExpertRecordActionSupport.setStatus(passedId, location, status, purpose);
        return QueueExpertRecordActionSupport.setStatus(passedId, status, purpose);
        //changes end here by abuzar
        //changes end here by abuzar
    }

    // REMOVED: getRescheduleDetail method - queries Resource__c, Work_Planner__c, Resource_Requirement__c, Time_Off__c and calls removed methods generateSlots/getResource/getFilterValues
    /**
     * @description Updates a registration record and reloads its detail wrapper.
     * @param regId Registration identifier to update.
     * @param recValues Serialized field values submitted by the client.
     * @param userID User identifier associated with the update.
     * @param recordType Record type context for the update.
     * @param queueId Queue identifier associated with the registration.
     * @param accountId Account identifier associated with the registration.
     * @param event Event identifier associated with the registration.
     * @param location Expert location identifier.
     * @param sDate Updated start date and time.
     * @param eDate Updated end date and time.
     * @return Wrapper containing refreshed registration details or an error message.
     */
    @AuraEnabled(cacheable=false)
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static QueueExpertWrapper getRegRecordUpdate(String regId, String recValues,String userID, String recordType,String queueId, String accountId, String event, String location,DateTime sDate, DateTime eDate) {
        // commented by abuzar on 2026-03-30 for the scanning issue and added below line "Moved registration-refresh update logic into a dedicated support class to reduce Queue_Expert_Sch class-level complexity and NCSS."
        // existing method body moved to QueueExpertRecordActionSupport.getRegRecordUpdate(...)
        return QueueExpertRecordActionSupport.getRegRecordUpdate(regId, recValues, userID, recordType, queueId, accountId, event, location, sDate, eDate);
        //changes end here by abuzar

    }

 // REMOVED: generateSlots method - uses Time_Off__c for slot generation // REMOVED: getNextSlots method - queries Resource__c, Time_Off__c and calls generateSlots // REMOVED: fetchPreSlot method - queries Resource__c, Time_Off__c and calls generateSlots // REMOVED: confirmSlot method - queries and updates Resource__c related fields // REMOVED: slotOnDateChange method - queries Resource__c, Time_Off__c and calls generateSlots // REMOVED: getSlot method - queries Work_Planner__c, Resource__c, Resource_Requirement__c, Time_Off__c and calls generateSlots

    // commented by abuzar on 2026-03-30 for the scanning issue and added below line "Shared validation, access, upload, note, and delete helpers were extracted into dedicated support classes to reduce Queue_Expert_Sch class cyclomatic complexity, cognitive complexity, and NCSS."
    // original helper method implementations moved to QueueExpertAccessSupport and QueueExpertRelatedRecordActionSupport
    /**
     * @description Verifies that the supplied parent record is accessible.
     * @param parentId Parent record identifier to validate.
     */
    public static void assertParentRecordAccessible(Id parentId) {
        QueueExpertRelatedRecordActionSupport.assertParentRecordAccessible(parentId);
    }

    /**
     * @description Returns attachments related to the provided parent record.
     * @param parentId Parent record identifier whose attachments should be returned.
     * @return Attachments associated with the parent record.
     */
    public static List<Attachment> getAttachmentsByParent(Id parentId) {
        return QueueExpertRelatedRecordActionSupport.getAttachmentsByParent(parentId);
    }

    /**
     * @description Returns notes related to the provided parent record.
     * @param parentId Parent record identifier whose notes should be returned.
     * @return Notes associated with the parent record.
     */
    public static List<Note> getNotesByParent(Id parentId) {
        return QueueExpertRelatedRecordActionSupport.getNotesByParent(parentId);
    }

    /**
     * @description Uploads an attachment for the supplied queue-expert request payload.
     * @param request Upload request payload containing parent and file details.
     * @return Refreshed list of attachments for the parent record.
     */
    @AuraEnabled
    // commented by abuzar on 2026-03-30 for the scanning issue and added below line "The upload action now accepts a single wrapper request so it no longer uses a Boolean method parameter or a long parameter list in Queue_Expert_Sch."
    // public static List<Attachment> uploadFile(String parent, String fileName, String base64Data, String contentType, Boolean userInitiated) {
    public static List<Attachment> uploadFile(QueueExpertUploadFileRequest request) {
        return QueueExpertRelatedRecordActionSupport.uploadFile(request);
    }
    //changes end here by abuzar

    // commented by abuzar on 2026-03-30 for the scanning issue and added below line "The four-parameter upload overload is no longer needed after moving to the wrapper-based request contract."
    // public static List<Attachment> uploadFile(String parent, String fileName, String base64Data, String contentType) {
    //     return QueueExpertRelatedRecordActionSupport.uploadFile(new UploadFileRequest(parent, fileName, base64Data, contentType));
    // }
    //changes end here by abuzar

    /**
     * @description Saves a note for the provided registration.
     * @param nn Serialized note payload from the client.
     * @param regID Registration identifier that owns the note.
     * @return Refreshed list of notes for the registration.
     */
    @AuraEnabled
    public static List<Note> saveNotes(String nn, String regID) {
        return QueueExpertRelatedRecordActionSupport.saveNotes(nn, regID);
    }
    //changes end here by abuzar

    /**
     * @description Deletes a related attachment or note record by Id.
     * @param raId Identifier of the record to delete.
     * @param objName API name of the object to delete from.
     * @return Wrapper indicating completion state.
     */
    @AuraEnabled(cacheable=false)
    public static QueueExpertWrapper  deleteAT(String raId, String objName){
        // commented by abuzar on 2026-03-30 for the scanning issue and added below line "Moved related-record delete logic into a dedicated support class to reduce Queue_Expert_Sch class-level complexity and NCSS."
        // existing method body moved to QueueExpertRelatedRecordActionSupport.deleteAT(...)
        return QueueExpertRelatedRecordActionSupport.deleteAT(raId, objName);
        //changes end here by abuzar
    }

    /**
     * @description Returns an empty records wrapper for queue registration data.
     * @return New records wrapper instance.
     */
    @AuraEnabled
    public static QueueExpertRecords getRegRecords(){
        QueueExpertRecords rec=new QueueExpertRecords();
        return rec;
    }

    // commented by abuzar on 2026-03-30 for the scanning issue and added below line "The inner Wrapper, Records, SelectOptions, and UploadFileRequest transport models were moved to dedicated Apex classes so their accessor and constructor complexity no longer counts against Queue_Expert_Sch."
    // legacy inner DTO implementations were removed from this controller and replaced by QueueExpertWrapper, QueueExpertRecords, QueueExpertSelectOptions, and QueueExpertUploadFileRequest
    //changes end here by abuzar

    // commented by abuzar on 2026-03-13 for the scanning issue and added below line "moved the helper request model and branching utility methods into a dedicated support class to reduce Queue_Expert_Sch class cyclomatic complexity and remove the long helper constructor parameter list"
    /*
    private class LocationLoadRequest {
        private String locationId;
        private String resourceId;
        private String serviceId;
        private String category;

        private LocationLoadRequest() {
            // commented by abuzar on 2026-03-30 for the scanning issue and added below line "Avoid empty block statements."
            // intentionally left blank in legacy commented helper block
            //changes end here by abuzar
        }

        private void loadValues(String location, String resource, String service) {
            locationId = normalizeInput(location);
            resourceId = normalizeInput(resource);
            serviceId = normalizeInput(service);
        }

        private void setCategory(String catValue) {
            category = normalizeInput(catValue);
        }
    }

    private static String normalizeInput(String value) {
        return String.isBlank(value) ? null : value;
    }

    private static String getUserName(String userId) {
        if (String.isBlank(userId)) {
            return null;
        }
        List<User> users = [SELECT Id, Name FROM User WHERE Id = :userId WITH USER_MODE LIMIT 1];
        return users.isEmpty() ? null : users[0].Name;
    }

    private static Wrapper getInitialWrapper(String userId) {
        for (String category : INITIAL_APPOINTMENT_FILTERS) {
            Wrapper initialWrapper = getRecordsOfLocationsonLoad(null, userId, null, null, category);
            initialWrapper.appointmentFiler = category;
            if (!initialWrapper.records.isEmpty() || category == TODAYS_APPOINTMENTS) {
                return initialWrapper;
            }
        }
        return new Wrapper();
    }

    private static void assignFieldSetMetadata(Wrapper wrapper) {
        wrapper.appointmentFields = getFieldsSetApiName('Registration_SCH__c', 'WB_Appointment_Details');
        wrapper.customerFields = getFieldsSetApiName('Registration_SCH__c', 'WB_Customer_Details');
        wrapper.meetingFields = getFieldsSetApiName('Registration_SCH__c', 'WB_Meeting_Details');
    }

    private static void assignCategoryOptions(Wrapper wrapper) {
        wrapper.allCategory = new List<SelectOptions>();
        wrapper.allCategory.addAll(CATEGORY_OPTIONS);
    }

    private static void validateCategory(String category) {
        if (category != null && !ALLOWED_CAT_VALUES.contains(category)) {
            throw new AuraHandledException('Invalid category: ' + category);
        }
    }

    private static List<Registration_SCH__c> queryLocationRecords(LocationLoadRequest request) {
        DateTime nowTime = System.now();
        Map<String, Object> bindVars = new Map<String, Object>{
            'nowTime' => nowTime,
            'currentUserId' => UserInfo.getUserId()
        };
        String query = 'SELECT ' + LOCATION_LOAD_FIELDS + ' FROM Registration_SCH__c WHERE Product2__c != null';
        query += CATEGORY_QUERY_FILTERS.containsKey(request.category) ? CATEGORY_QUERY_FILTERS.get(request.category) : '';
        if (request.locationId != null) {
            query += ' AND Expert_Location__c = :locationId';
            bindVars.put('locationId', request.locationId);
        }
        if (request.serviceId != null) {
            query += ' AND Product2__c = :serviceId';
            bindVars.put('serviceId', request.serviceId);
        }
        if (request.resourceId != null) {
            query += ' AND User__c = :resourceId';
            bindVars.put('resourceId', request.resourceId);
        } else {
            query += ' AND User__c = :currentUserId';
        }
        query += ' ORDER BY Booked_Date__c ASC LIMIT 1000';
        return (List<Registration_SCH__c>)Database.queryWithBinds(query, bindVars, AccessLevel.USER_MODE);
    }

    private static void populateWrapperFromRecords(Wrapper wrapper, List<Registration_SCH__c> records) {
        Integer index = 0;
        for (Registration_SCH__c recordItem : records) {
            if (recordItem.Booked_Current_Status__c == 'InProgress') {
                wrapper.objectValues.add(recordItem);
                wrapper.inProgress = true;
            }
            wrapper.mapOfRecords.put(String.valueOf(index), recordItem);
            Records rec = new Records();
            rec.regRecords = recordItem;
            rec.waitingTime = '12 hours';
            wrapper.regRecords.add(rec);
            index++;
        }
        loadPrimaryRecordRelatedData(wrapper);
    }

    private static void loadPrimaryRecordRelatedData(Wrapper wrapper) {
        if (wrapper.objectValues.isEmpty()) {
            return;
        }
        Registration_SCH__c primaryRecord = wrapper.objectValues[0];
        wrapper.notes = getNotesByParent(primaryRecord.Id);
        wrapper.attachments = getAttachmentsByParent(primaryRecord.Id);
        wrapper.userName = [SELECT Name FROM User WHERE Id = :primaryRecord.OwnerId LIMIT 1000];
        wrapper.recordTypeName = [Select Id, Name From RecordType where id = :primaryRecord.RecordTypeId LIMIT 1000];
    }

    private static List<String> deserializeRecordValues(String recValues, Wrapper wrapper) {
        try {
            return (List<String>)JSON.deserialize(recValues, List<String>.class);
        } catch (Exception e) {
            wrapper.errmsg = e.getMessage() + ' 1@' + e.getLineNumber();
            //System.debug(LoggingLevel.DEBUG, 'getRecordUpdate Exception' + e.getMessage() + ' @@' + e.getLineNumber() + ' ST=>' + e.getStackTraceString());
            return new List<String>();
        }
    }

    private static void applyCommonRecordValues(Registration_SCH__c registrationToUpdate, List<String> recordValues) {
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

    private static String getRecordValue(List<String> recordValues, Integer index) {
        return recordValues.size() > index ? recordValues[index] : null;
    }

    private static void loadWrapperDetailsForRegistration(Wrapper wrapper, String regId) {
        // commented by abuzar on 2026-03-14 for the scanning issue and added below line "shared registration detail loading now uses a superset field query so existing functionality remains unchanged after removing duplicate code"
        // wrapper.objectValues = [SELECT id, Name, OwnerId, RecordTypeId, Account__r.Flagged__c,Account__c,Account__r.Name, Expert_Location__c,Company__c, Customer_Status__c,Is_Amount_Refunded__c,
        //                         Twilio_Message__c, Queue__c,Queue__r.Name,Customer_Type__c, Status__c, Registration_Type__c,Registration_Time__c,Registration_End_Time__c,Product2__r.SCH_Wait_Threshold__c,End_Time__c,Wait_Time_Exceeded__c,
        //                         Meeting_Status__c, Meeting_outcome__c,  Purpose__c,Customer_Name__c, Customer_Lastname__c, Customer_Email__c,Customer_Contact__c, Registration_Price__c,waiting_Time__c, Total_Tax_Amount__c, Discount__c,Booked_Current_Status__c
        //                         FROM Registration_SCH__c WHERE id=:regId  LIMIT 1000];
        wrapper.objectValues = [SELECT id, User__c, Name, OwnerId, RecordTypeId, Wait_Time_Exceeded__c, Contact__c, Account__c, Account__r.Flagged__c, Account__r.Name, Expert_Location__c,
                                Company__c, Customer_Status__c, Is_Amount_Refunded__c, Twilio_Message__c, Queue__c, Queue__r.Name, Customer_Type__c, Status__c, Registration_Type__c,
                                Registration_Time__c, Registration_End_Time__c, Product2__r.SCH_Wait_Threshold__c, End_Time__c, Meeting_Status__c, Meeting_outcome__c, Purpose__c,
                                Customer_Name__c, Customer_Lastname__c, Customer_Email__c, Customer_Contact__c, waiting_Time__c, Registration_Price__c, Total_Tax_Amount__c, Discount__c,
                                Booked_Current_Status__c, LastModifiedDate
                                FROM Registration_SCH__c WHERE id = :regId LIMIT 1000];
        //changes end here by abuzar
        loadPrimaryRecordRelatedData(wrapper);
    }
    */
    //changes end here by abuzar

}
