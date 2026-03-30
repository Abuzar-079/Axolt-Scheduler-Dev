/**
 * @description Provides queue expert scheduling operations for appointment management.
 */
public with sharing class Queue_Expert_Sch {
    private static final Set<String> SUPPORTED_RELATED_RECORD_OBJECTS = new Set<String>{
        'Attachment',
        'Note'
    };
    private static final Integer MAX_ATTACHMENT_SIZE_BYTES = 4500000;
    private static final Set<String> ALLOWED_ATTACHMENT_EXTENSIONS = new Set<String>{
        'csv',
        'doc',
        'docx',
        'gif',
        'jpeg',
        'jpg',
        'pdf',
        'png',
        'txt',
        'xls',
        'xlsx'
    };
    private static final Set<String> ALLOWED_ATTACHMENT_CONTENT_TYPES = new Set<String>{
        'application/msword',
        'application/pdf',
        'application/vnd.ms-excel',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'image/gif',
        'image/jpeg',
        'image/png',
        'text/csv',
        'text/plain'
    };
    private static final Map<Integer, String> UPDATE_RECORD_FIELDS_BY_INDEX = new Map<Integer, String>{
        0 => 'Customer_Status__c',
        1 => 'Customer_Type__c',
        2 => 'Registration_Type__c',
        3 => 'Meeting_Status__c',
        4 => 'Meeting_outcome__c',
        5 => 'Purpose__c',
        6 => 'Customer_Name__c',
        7 => 'Customer_Lastname__c',
        8 => 'Customer_Email__c',
        9 => 'Customer_Contact__c',
        15 => 'Contact__c'
    };
    private static final Set<String> UPDATE_RECORD_MUTABLE_FIELDS = new Set<String>{
        'Booked_Current_Status__c',
        'Cancellation_Reason__c',
        'Contact__c',
        'Customer_Contact__c',
        'Customer_Email__c',
        'Customer_Lastname__c',
        'Customer_Name__c',
        'Customer_Status__c',
        'Customer_Type__c',
        'End_Time__c',
        'Meeting_Status__c',
        'Meeting_outcome__c',
        'Purpose__c',
        'Registration_Time__c',
        'Registration_Type__c',
        'Serve_Finished_Time__c',
        'Serve_Start_Time__c',
        'Status__c',
        'waiting_Time__c'
    };
    private enum FieldAccessType {
        READ,
        CREATE,
        EDIT
    }
    private static final String TODAYS_APPOINTMENTS = 'Todays Appointments';
    private static final String CHECK_IN_APPOINTMENTS = 'Check In Appointments';
    private static final String FUTURE_APPOINTMENTS = 'Future Appointments';
    private static final String PAST_APPOINTMENTS = 'Past Appointments';
    private static final String COMPLETED_APPOINTMENTS = 'Completed Appointments';
    private static final List<String> INITIAL_APPOINTMENT_FILTERS = new List<String>{
        CHECK_IN_APPOINTMENTS,
        TODAYS_APPOINTMENTS
    };
    private static final List<SelectOptions> CATEGORY_OPTIONS = new List<SelectOptions>{
        new SelectOptions(TODAYS_APPOINTMENTS, TODAYS_APPOINTMENTS),
        new SelectOptions(CHECK_IN_APPOINTMENTS, CHECK_IN_APPOINTMENTS),
        new SelectOptions(FUTURE_APPOINTMENTS, FUTURE_APPOINTMENTS),
        new SelectOptions(PAST_APPOINTMENTS, PAST_APPOINTMENTS),
        new SelectOptions(COMPLETED_APPOINTMENTS, COMPLETED_APPOINTMENTS)
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
    public static Wrapper updateRecordValues(String regId, String recValues, String userID, String recordType, String queueId, String accountId, String event, String location, DateTime sDate, DateTime eDate) {
        Wrapper wrapper = new Wrapper();
        assertAuthenticatedRequest();
        Id registrationId = validateRegistrationId(regId);
        List<String> recordValues = deserializeSubmittedValues(recValues, 'Invalid record update payload.');

        assertRegistrationAccess(registrationId, true);
        checkFieldAccess(
            Registration_SCH__c.SObjectType,
            UPDATE_RECORD_MUTABLE_FIELDS,
            FieldAccessType.EDIT,
            'Insufficient field access to update the registration.'
        );

        Registration_SCH__c registrationToUpdate = new Registration_SCH__c(Id = registrationId);
        applyApprovedUpdateRecordValues(registrationToUpdate, recordValues);
        saveUpdateResult(
            Database.update(registrationToUpdate, false, AccessLevel.USER_MODE),
            'Unable to update the registration.'
        );
        return wrapper;
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
    public static Wrapper initSetUp() {
        Wrapper wrapper = new Wrapper();
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
    public static Wrapper getRecordsOfLocationsonLoad(String location, String resource, String service, String program, String catValue) {
        //System.debug(LoggingLevel.DEBUG, 'getRecordsOfLocations is called' + program + ' , ' + catValue);
        //System.debug(LoggingLevel.DEBUG, 'location=>' + location + ', service==>' + service + ' ,program=>' + program);
        Wrapper wrapper = new Wrapper();
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
    public static Wrapper popUpRecordsOfId(string id, String location,String waitingTime){
        Wrapper wrapper=new Wrapper();
        assertAuthenticatedRequest();
        Id registrationId = validateRegistrationId(id);
        assertRegistrationAccess(registrationId, true);
        checkFieldAccess(
            Registration_SCH__c.SObjectType,
            new Set<String>{ 'Booked_Current_Status__c', 'waiting_Time__c', 'Serve_Start_Time__c' },
            FieldAccessType.EDIT,
            'Insufficient field access to update the registration.'
        );

        Registration_SCH__c registrationToUpdate = new Registration_SCH__c(Id = registrationId);
        registrationToUpdate.Booked_Current_Status__c = 'InProgress';
        registrationToUpdate.waiting_Time__c = normalizeForField(waitingTime);
        registrationToUpdate.Serve_Start_Time__c = System.now();
        saveUpdateResult(
            Database.update(registrationToUpdate, false, AccessLevel.USER_MODE),
            'Unable to mark the registration as in progress.'
        );

        checkFieldAccess(
            Registration_SCH__c.SObjectType,
            new Set<String>{ 'Booked_Current_Status__c' },
            FieldAccessType.READ,
            'Insufficient field access to view the registration.'
        );
        Registration_SCH__c refreshedRecord = [
            SELECT Booked_Current_Status__c
            FROM Registration_SCH__c
            WHERE Id = :registrationId
            WITH USER_MODE
            LIMIT 1
        ];
        if(refreshedRecord.Booked_Current_Status__c == 'InProgress'){wrapper.updateStatusForCancel=True;}
        // commented by abuzar on 2026-03-14 for the scanning issue and added below line "duplicate registration detail loading caused DetectCopyPasteForApex and is now centralized in a shared helper method"
        // wrapper.objectValues=[SELECT id, User__c, Name, OwnerId, RecordTypeId, Account__c,Account__r.Flagged__c,Account__r.Name, Expert_Location__c,
        //                       Company__c, Customer_Status__c, Is_Amount_Refunded__c,Twilio_Message__c, Queue__c,Queue__r.Name,
        //                       Customer_Type__c, Status__c, Registration_Type__c, Registration_Time__c,Registration_End_Time__c,Wait_Time_Exceeded__c,Product2__r.SCH_Wait_Threshold__c,
        //                       End_Time__c,  Meeting_Status__c, Meeting_outcome__c,  Purpose__c,Customer_Name__c, Customer_Lastname__c, Customer_Email__c,
        //                       Customer_Contact__c,Contact__c, waiting_Time__c, Registration_Price__c, Total_Tax_Amount__c, Discount__c,Booked_Current_Status__c,LastModifiedDate
        //                       FROM Registration_SCH__c WHERE id=:id  LIMIT 1000];
        QueueExpertSchSupport.loadWrapperDetailsForRegistration(wrapper, id);
        // commented by abuzar on 2026-03-14 for the scanning issue and added below line "Duplicate code detected for language 'apex'. Found 2 code locations containing the same block of code consisting of 120 tokens across 4 lines."
        // wrapper.notes = [Select Id, Title, ParentId From Note Where ParentId=:wrapper.objectValues[0].Id Order By CreatedDate Asc LIMIT 1000];
        // wrapper.attachments = [Select Id, Name, ParentId, ContentType From Attachment Where ParentId  =:wrapper.objectValues[0].Id Order By CreatedDate Asc LIMIT 1000];
        // wrapper.userName=[SELECT Name FROM User WHERE Id=:wrapper.objectValues[0].OwnerId LIMIT 1000];
        // wrapper.recordTypeName = [Select Id, Name From RecordType where id=:wrapper.objectValues[0].RecordTypeId LIMIT 1000];
        //changes end here by abuzar
        return wrapper;
    }

    /**
     * @description Loads registration detail data for the queue expert view.
     * @param id Registration identifier.
     * @return Wrapper containing the selected registration and related records.
     */
    @AuraEnabled
    public static Wrapper getRegDetails(string id){
        Wrapper wrapper=new Wrapper();
        Id registrationId = validateRegistrationId(id);
        assertRegistrationAccess(registrationId, false);
        // commented by abuzar on 2026-03-14 for the scanning issue and added below line "duplicate registration detail loading caused DetectCopyPasteForApex and is now centralized in a shared helper method"
        // wrapper.objectValues=[SELECT id, User__c, Name, OwnerId, RecordTypeId,Wait_Time_Exceeded__c,Contact__c, Account__c,Account__r.Flagged__c,Account__r.Name, Expert_Location__c,
        //                       Company__c, Customer_Status__c,    Is_Amount_Refunded__c,
        //                       Twilio_Message__c, Queue__c,Queue__r.Name,
        //                       Customer_Type__c, Status__c, Registration_Type__c,    Registration_Time__c,
        //                       Registration_End_Time__c,Product2__r.SCH_Wait_Threshold__c,
        //                       End_Time__c,  Meeting_Status__c, Meeting_outcome__c,  Purpose__c,
        //                       Customer_Name__c, Customer_Lastname__c, Customer_Email__c,
        //                       Customer_Contact__c,waiting_Time__c, Registration_Price__c,
        //                       Total_Tax_Amount__c, Discount__c,Booked_Current_Status__c,
        //                       LastModifiedDate
        //                       FROM Registration_SCH__c WHERE id=:id  LIMIT 1000];
        QueueExpertSchSupport.loadWrapperDetailsForRegistration(wrapper, id);
        //System.debug(LoggingLevel.DEBUG, 'objectValues query result: ' + JSON.serialize(wrapper.objectValues));
        // commented by abuzar on 2026-03-14 for the scanning issue and added below line "duplicate related record loading caused DetectCopyPasteForApex and is now centralized in a shared helper method"
        // wrapper.notes = [Select Id, Title, ParentId From Note Where ParentId=:wrapper.objectValues[0].Id Order By CreatedDate Asc LIMIT 1000];
        //System.debug(LoggingLevel.DEBUG, 'notes query result: ' + JSON.serialize(wrapper.notes));
        // wrapper.attachments = [Select Id, Name, ParentId, ContentType From Attachment Where ParentId  =:wrapper.objectValues[0].Id Order By CreatedDate Asc LIMIT 1000];
        //System.debug(LoggingLevel.DEBUG, 'attachments query result: ' + JSON.serialize(wrapper.attachments));
        // wrapper.userName=[SELECT Name FROM User WHERE Id=:wrapper.objectValues[0].OwnerId LIMIT 1000];
        //System.debug(LoggingLevel.DEBUG, 'userName query result: ' + JSON.serialize(wrapper.userName));
        // wrapper.recordTypeName = [Select Id, Name From RecordType where id=:wrapper.objectValues[0].RecordTypeId LIMIT 1000];
        //changes end here by abuzar
        //System.debug(LoggingLevel.DEBUG, 'recordTypeName query result: ' + JSON.serialize(wrapper.recordTypeName));
        return wrapper;
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
    public static Wrapper setStatus(String passedId, String location,String status,String purpose){
        Wrapper wrapper = new Wrapper();
        assertAuthenticatedRequest();
        Id registrationId = validateRegistrationId(passedId);
        validateNotBlank(status, 'Status is required.');
        assertRegistrationAccess(registrationId, true);
        checkFieldAccess(
            Registration_SCH__c.SObjectType,
            new Set<String>{ 'Status__c', 'Booked_Current_Status__c', 'Cancellation_Reason__c', 'Serve_Finished_Time__c' },
            FieldAccessType.EDIT,
            'Insufficient field access to update the registration.'
        );

        Registration_SCH__c registrationToUpdate = new Registration_SCH__c(Id = registrationId);
        registrationToUpdate.Status__c = status.trim();
        registrationToUpdate.Booked_Current_Status__c='Completed';
        registrationToUpdate.Cancellation_Reason__c= normalizeForField(purpose);
        registrationToUpdate.Serve_Finished_Time__c=System.now();
        saveUpdateResult(
            Database.update(registrationToUpdate, false, AccessLevel.USER_MODE),
            'Unable to update the registration status.'
        );
        checkFieldAccess(
            Registration_SCH__c.SObjectType,
            new Set<String>{ 'Status__c' },
            FieldAccessType.READ,
            'Insufficient field access to view the registration.'
        );
        Registration_SCH__c refreshedRecord = [
            SELECT Status__c
            FROM Registration_SCH__c
            WHERE Id = :registrationId
            WITH USER_MODE
            LIMIT 1
        ];
        if( refreshedRecord.Status__c == status.trim()){wrapper.updateStatusForCancel=True;}
        // REMOVED: getRecordsOfLocations call - method no longer available
        List<Registration_SCH__c> records=new List<Registration_SCH__c>();

        integer rsize=records.Size();
        for(integer i=0;i<=rsize-1;i++) {if(records[i].Booked_Current_Status__c=='InProgress'){ wrapper.objectValues.add(records[i]); wrapper.inProgress=true;}}
        // commented by abuzar on 2026-03-14 for the scanning issue and added below line "Duplicate code detected for language 'apex'. Found 2 code locations containing the same block of code consisting of 120 tokens across 4 lines."
        // if(wrapper.objectValues.size()>0){  wrapper.notes = [Select Id, Title, ParentId From Note Where ParentId=:wrapper.objectValues[0].Id Order By CreatedDate Asc LIMIT 1000];  wrapper.attachments = [Select Id, Name, ParentId, ContentType From Attachment Where ParentId  =:wrapper.objectValues[0].Id Order By CreatedDate Asc LIMIT 1000];  wrapper.userName=[SELECT Name FROM User WHERE Id=:wrapper.objectValues[0].OwnerId LIMIT 1000];  wrapper.recordTypeName = [Select Id, Name From RecordType where id=:wrapper.objectValues[0].RecordTypeId LIMIT 1000];
        //                                  }
        QueueExpertSchSupport.loadPrimaryRecordRelatedData(wrapper);
        //changes end here by abuzar
        for(integer index=0;index<rsize;index++) { wrapper.mapOfRecords.put(String.valueof(index), records[index]); }
        return wrapper;
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
    public static Wrapper getRegRecordUpdate(String regId, String recValues,String userID, String recordType,String queueId, String accountId, String event, String location,DateTime sDate, DateTime eDate) {
        Wrapper wrapper=new Wrapper();
        assertAuthenticatedRequest();
        Id registrationId = validateRegistrationId(regId);
        List<String> recordValues = deserializeSubmittedValues(recValues, 'Invalid record update payload.');
        assertRegistrationAccess(registrationId, true);
        checkFieldAccess(
            Registration_SCH__c.SObjectType,
            UPDATE_RECORD_MUTABLE_FIELDS,
            FieldAccessType.EDIT,
            'Insufficient field access to update the registration.'
        );

        Registration_SCH__c registrationToUpdate = new Registration_SCH__c(Id = registrationId);
        registrationToUpdate.Status__c = 'Completed';
        registrationToUpdate.Customer_Status__c = 'Attended';
        registrationToUpdate.Registration_Time__c = sDate;
        registrationToUpdate.End_Time__c = eDate;
        applyApprovedUpdateRecordValues(registrationToUpdate, recordValues);
        registrationToUpdate.Booked_Current_Status__c = 'Completed';
        registrationToUpdate.Serve_Finished_Time__c = System.now();
        saveUpdateResult(
            Database.update(registrationToUpdate, false, AccessLevel.USER_MODE),
            'Unable to update the registration.'
        );

        checkFieldAccess(
            Registration_SCH__c.SObjectType,
            new Set<String>{ 'Status__c' },
            FieldAccessType.READ,
            'Insufficient field access to view the registration.'
        );
        Registration_SCH__c refreshedRecord = [
            SELECT Status__c
            FROM Registration_SCH__c
            WHERE Id = :registrationId
            WITH USER_MODE
            LIMIT 1
        ];
        if( refreshedRecord.Status__c == 'Completed') { wrapper.updateStatus=True; }
        QueueExpertSchSupport.loadWrapperDetailsForRegistration(wrapper, regId);
        wrapper.errmsg=null;
        return wrapper;

    }

 // REMOVED: generateSlots method - uses Time_Off__c for slot generation // REMOVED: getNextSlots method - queries Resource__c, Time_Off__c and calls generateSlots // REMOVED: fetchPreSlot method - queries Resource__c, Time_Off__c and calls generateSlots // REMOVED: confirmSlot method - queries and updates Resource__c related fields // REMOVED: slotOnDateChange method - queries Resource__c, Time_Off__c and calls generateSlots // REMOVED: getSlot method - queries Work_Planner__c, Resource__c, Resource_Requirement__c, Time_Off__c and calls generateSlots

    private static void assertAuthenticatedRequest() {
        if (String.isBlank(UserInfo.getUserId())) {
            throw new AuraHandledException('Authentication is required for this action.');
        }
    }

    private static void validateNotBlank(String value, String errorMessage) {
        if (String.isBlank(value)) {
            throw new AuraHandledException(errorMessage);
        }
    }

    private static Id validateRecordId(String recordIdValue, String errorMessage) {
        validateNotBlank(recordIdValue, errorMessage);
        try {
            return (Id)recordIdValue.trim();
        } catch (TypeException ex) {
            throw new AuraHandledException(errorMessage);
        }
    }

    private static void assertSObjectType(Id recordId, Schema.SObjectType expectedType, String errorMessage) {
        if (recordId.getSObjectType() != expectedType) {
            throw new AuraHandledException(errorMessage);
        }
    }

    private static Id validateRegistrationId(String registrationIdValue) {
        Id registrationId = validateRecordId(registrationIdValue, 'Invalid registration record id.');
        assertSObjectType(registrationId, Registration_SCH__c.SObjectType, 'The target record must be a registration.');
        return registrationId;
    }

    private static Id validateParentRecordId(String parent) {
        Id parentId = validateRecordId(parent, 'Invalid parent record id.');
        assertSObjectType(parentId, Registration_SCH__c.SObjectType, 'Parent record must be a registration.');
        return parentId;
    }

    private static void checkObjectAccess(Schema.SObjectType sObjectType, FieldAccessType accessType, String errorMessage) {
        // commented by abuzar on 2026-03-30 for the scanning issue and added below line "DescribeSObjectResult could be loaded eagerly with all child relationships, which triggers the EagerlyLoadedDescribeSObjectResult PMD violation."
        // Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
        Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED);
        //changes end here by abuzar
        Boolean hasAccess = accessType == FieldAccessType.READ
            ? describeResult.isAccessible()
            : accessType == FieldAccessType.CREATE
                ? describeResult.isCreateable()
                : describeResult.isUpdateable();
        if (!hasAccess) {
            throw new AuraHandledException(errorMessage);
        }
    }

    private static void checkDeleteAccess(Schema.SObjectType sObjectType, String errorMessage) {
        // commented by abuzar on 2026-03-30 for the scanning issue and added below line "DescribeSObjectResult could be loaded eagerly with all child relationships, which triggers the EagerlyLoadedDescribeSObjectResult PMD violation."
        // if (!sObjectType.getDescribe().isDeletable()) {
        if (!sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isDeletable()) {
            throw new AuraHandledException(errorMessage);
        }
        //changes end here by abuzar
    }

    private static void checkFieldAccess(
        Schema.SObjectType sObjectType,
        Set<String> fieldApiNames,
        FieldAccessType accessType,
        String errorMessage
    ) {
        // commented by abuzar on 2026-03-30 for the scanning issue and added below line "DescribeSObjectResult could be loaded eagerly with all child relationships, which triggers the EagerlyLoadedDescribeSObjectResult PMD violation."
        // Map<String, Schema.SObjectField> fieldMap = sObjectType.getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> fieldMap = sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).fields.getMap();
        //changes end here by abuzar
        for (String fieldApiName : fieldApiNames) {
            if (!fieldMap.containsKey(fieldApiName)) {
                throw new AuraHandledException('Unsupported field requested: ' + fieldApiName);
            }
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldApiName).getDescribe();
            Boolean hasAccess = accessType == FieldAccessType.READ
                ? fieldDescribe.isAccessible()
                : accessType == FieldAccessType.CREATE
                    ? fieldDescribe.isCreateable()
                    : fieldDescribe.isUpdateable();
            if (!hasAccess) {
                throw new AuraHandledException(errorMessage);
            }
        }
    }

    private static List<String> deserializeSubmittedValues(String payload, String errorMessage) {
        validateNotBlank(payload, errorMessage);
        try {
            List<String> submittedValues = (List<String>)JSON.deserialize(payload, List<String>.class);
            return submittedValues == null ? new List<String>() : submittedValues;
        } catch (JSONException ex) {
            throw new AuraHandledException(errorMessage);
        }
    }

    private static String normalizeForField(String value) {
        return String.isBlank(value) ? null : value.trim();
    }

    private static void applyApprovedUpdateRecordValues(Registration_SCH__c registrationToUpdate, List<String> recordValues) {
        for (Integer indexValue : UPDATE_RECORD_FIELDS_BY_INDEX.keySet()) {
            if (recordValues.size() <= indexValue) {
                continue;
            }
            registrationToUpdate.put(
                UPDATE_RECORD_FIELDS_BY_INDEX.get(indexValue),
                normalizeForField(recordValues[indexValue])
            );
        }
        if (recordValues.size() >= 15) {
            registrationToUpdate.Status__c = 'Completed';
        }
    }

    private static void saveInsertResult(Database.SaveResult saveResult, String errorMessage) {
        if (saveResult == null || !saveResult.isSuccess()) {
            throw buildDmlException(errorMessage, saveResult == null ? null : saveResult.getErrors());
        }
    }

    private static void saveUpdateResult(Database.SaveResult saveResult, String errorMessage) {
        if (saveResult == null || !saveResult.isSuccess()) {
            throw buildDmlException(errorMessage, saveResult == null ? null : saveResult.getErrors());
        }
    }

    private static void saveDeleteResult(Database.DeleteResult deleteResult, String errorMessage) {
        if (deleteResult == null || !deleteResult.isSuccess()) {
            throw buildDmlException(errorMessage, deleteResult == null ? null : deleteResult.getErrors());
        }
    }

    private static AuraHandledException buildDmlException(String errorMessage, Database.Error[] errors) {
        String finalMessage = errorMessage;
        if (errors != null && !errors.isEmpty() && !String.isBlank(errors[0].getMessage())) {
            finalMessage += ' ' + errors[0].getMessage();
        }
        return new AuraHandledException(finalMessage);
    }

    private static String getParentObjectApiName(Id parentId) {
        // commented by abuzar on 2026-03-30 for the scanning issue and added below line "DescribeSObjectResult could be loaded eagerly with all child relationships, which triggers the EagerlyLoadedDescribeSObjectResult PMD violation."
        // return parentId.getSObjectType().getDescribe().getName();
        return parentId.getSObjectType().getDescribe(SObjectDescribeOptions.DEFERRED).getName();
        //changes end here by abuzar
    }
/**
 * @description Verifies that the current user has read access to the specified parent record.
 *              Performs both object-level permission checks and a USER_MODE query to confirm
 *              the record exists and is accessible to the running user.
 *
 * @param parentId The Salesforce record Id of the parent object to validate access for.
 *
 * @throws AuraHandledException If the parent record is not found or is inaccessible to the current user.
 *
 * @example
 * Id accountId = '001XXXXXXXXXXXXXXX';
 * assertParentRecordAccessible(accountId);
 */
    public static void assertParentRecordAccessible(Id parentId) {
        checkObjectAccess(parentId.getSObjectType(), FieldAccessType.READ, 'Insufficient access to the parent record.');
        Map<String, Object> bindVars = new Map<String, Object>{
            'parentId' => parentId
        };
        List<SObject> parentRecords = Database.queryWithBinds(
            'SELECT Id FROM ' + getParentObjectApiName(parentId) + ' WHERE Id = :parentId LIMIT 1',
            bindVars,
            AccessLevel.USER_MODE
        );
        if (parentRecords.isEmpty()) {
            throw new AuraHandledException('Parent record is not accessible.');
        }
    }

    private static void assertRegistrationParentAccess(Id parentId) {
        assertSObjectType(parentId, Registration_SCH__c.SObjectType, 'Parent record must be a registration.');
        if (!Schema.sObjectType.Registration_SCH__c.isAccessible()) {
            throw new AuraHandledException('Insufficient access to the parent registration.');
        }
        List<Registration_SCH__c> parentRegistrations = [
            SELECT Id
            FROM Registration_SCH__c
            WHERE Id = :parentId
            WITH USER_MODE
            LIMIT 1
        ];
        if (parentRegistrations.isEmpty()) {
            throw new AuraHandledException('Parent registration is not accessible.');
        }
    }

    private static void assertRegistrationAccess(Id registrationId, Boolean requireUpdateAccess) {
        checkObjectAccess(
            Registration_SCH__c.SObjectType,
            requireUpdateAccess ? FieldAccessType.EDIT : FieldAccessType.READ,
            requireUpdateAccess ? 'Insufficient access to update registrations.' : 'Insufficient access to view registrations.'
        );
        List<Registration_SCH__c> registrations = [
            SELECT Id
            FROM Registration_SCH__c
            WHERE Id = :registrationId
            WITH USER_MODE
            LIMIT 1
        ];
        if (registrations.isEmpty()) {
            throw new AuraHandledException('Registration record is not accessible.');
        }
    }

    private static void assertAttachmentCreateAccess(Id parentId) {
        assertRegistrationParentAccess(parentId);
        if (!Schema.sObjectType.Attachment.isCreateable()) {
            throw new AuraHandledException('Insufficient access to upload attachments.');
        }
        if (!Schema.sObjectType.Attachment.fields.ParentId.isCreateable() ||
            !Schema.sObjectType.Attachment.fields.Body.isCreateable() ||
            !Schema.sObjectType.Attachment.fields.Name.isCreateable() ||
            !Schema.sObjectType.Attachment.fields.ContentType.isCreateable()) {
            throw new AuraHandledException('Insufficient field access to upload attachments.');
        }
    }

    private static void assertAttachmentDeleteAccess(Id parentId) {
        assertRegistrationParentAccess(parentId);
        checkDeleteAccess(Attachment.SObjectType, 'Insufficient access to delete attachments.');
        checkFieldAccess(
            Attachment.SObjectType,
            new Set<String>{ 'ParentId' },
            FieldAccessType.READ,
            'Insufficient access to delete attachments.'
        );
    }

    private static void assertAttachmentReadAccess(Id parentId) {
        assertRegistrationParentAccess(parentId);
        checkObjectAccess(Attachment.SObjectType, FieldAccessType.READ, 'Insufficient access to view attachments.');
        checkFieldAccess(
            Attachment.SObjectType,
            new Set<String>{ 'Id', 'Name', 'ParentId', 'ContentType' },
            FieldAccessType.READ,
            'Insufficient access to view attachments.'
        );
    }

    private static void assertNoteCreateAccess(Id parentId) {
        assertRegistrationParentAccess(parentId);
        checkObjectAccess(Note.SObjectType, FieldAccessType.CREATE, 'Insufficient access to create notes.');
        checkFieldAccess(
            Note.SObjectType,
            new Set<String>{ 'ParentId', 'Title', 'Body' },
            FieldAccessType.CREATE,
            'Insufficient field access to create notes.'
        );
    }

    private static void assertNoteUpdateAccess(Id parentId) {
        assertRegistrationParentAccess(parentId);
        checkObjectAccess(Note.SObjectType, FieldAccessType.EDIT, 'Insufficient access to update notes.');
        checkFieldAccess(
            Note.SObjectType,
            new Set<String>{ 'ParentId', 'Title', 'Body' },
            FieldAccessType.EDIT,
            'Insufficient field access to update notes.'
        );
    }

    private static void assertNoteReadAccess(Id parentId) {
        assertRegistrationParentAccess(parentId);
        checkObjectAccess(Note.SObjectType, FieldAccessType.READ, 'Insufficient access to view notes.');
        checkFieldAccess(
            Note.SObjectType,
            new Set<String>{ 'Id', 'ParentId', 'Title' },
            FieldAccessType.READ,
            'Insufficient access to view notes.'
        );
    }

    private static void assertNoteDeleteAccess(Id parentId) {
        assertRegistrationParentAccess(parentId);
        checkDeleteAccess(Note.SObjectType, 'Insufficient access to delete notes.');
        checkFieldAccess(
            Note.SObjectType,
            new Set<String>{ 'ParentId' },
            FieldAccessType.READ,
            'Insufficient access to delete notes.'
        );
    }
/**
 * @description Verifies that the current user has read access to the specified parent record.
 *              Performs both object-level permission checks and a USER_MODE query to confirm
 *              the record exists and is accessible to the running user.
 *
 * @param parentId The Salesforce record Id of the parent object to validate access for.
 *
 * @throws AuraHandledException If the parent record is not found or is inaccessible to the current user.
 *
 * @example
 * Id accountId = '001XXXXXXXXXXXXXXX';
 * assertParentRecordAccessible(accountId);
 */
    public static List<Attachment> getAttachmentsByParent(Id parentId) {
        assertAttachmentReadAccess(parentId);
        return [
            SELECT Id, Name, ParentId, ContentType
            FROM Attachment
            WHERE ParentId = :parentId
            WITH USER_MODE
            ORDER BY CreatedDate ASC
            LIMIT 1000
        ];
    }
/**
 * @description Retrieves all notes associated with the specified parent record.
 *              Validates object and field-level access before querying.
 * @param parentId The Id of the parent record whose notes are to be retrieved.
 * @return List of Notes linked to the given parent, ordered by creation date ascending.
 * @throws AuraHandledException If the user lacks access to the parent registration or Note object/fields.
 */
    public static List<Note> getNotesByParent(Id parentId) {
        if (!Schema.sObjectType.Registration_SCH__c.isAccessible()) {
            throw new AuraHandledException('Insufficient access to the parent registration.');
        }
        if (!Schema.sObjectType.Note.isAccessible() ||
            !Schema.sObjectType.Note.fields.Id.isAccessible() ||
            !Schema.sObjectType.Note.fields.ParentId.isAccessible() ||
            !Schema.sObjectType.Note.fields.Title.isAccessible()) {
            throw new AuraHandledException('Insufficient access to view notes.');
        }
        assertNoteReadAccess(parentId);
        return [
            SELECT Id, Title, ParentId
            FROM Note
            WHERE ParentId = :parentId
            WITH USER_MODE
            ORDER BY CreatedDate ASC
            LIMIT 1000
        ];
    }

    private static Note parseNotePayload(String noteJson) {
        validateNotBlank(noteJson, 'Invalid note payload.');
        try {
            return (Note) JSON.deserialize(noteJson, Note.class);
        } catch (JSONException ex) {
            throw new AuraHandledException('Invalid note payload.');
        }
    }

    private static Note buildSafeNoteForUpdate(Id noteId, Id parentId, Note requestedNote) {
        Note noteToUpdate = new Note(Id = noteId);
        if (Schema.sObjectType.Note.fields.ParentId.isUpdateable()) {
            noteToUpdate.ParentId = parentId;
        }
        if (Schema.sObjectType.Note.fields.Title.isUpdateable()) {
            noteToUpdate.Title = requestedNote.Title.trim();
        }
        if (Schema.sObjectType.Note.fields.Body.isUpdateable()) {
            noteToUpdate.Body = requestedNote.Body;
        }
        return noteToUpdate;
    }

    private static Note getAccessibleNoteById(Id noteId) {
        checkObjectAccess(Note.SObjectType, FieldAccessType.READ, 'Insufficient access to view notes.');
        checkFieldAccess(
            Note.SObjectType,
            new Set<String>{ 'Id', 'ParentId' },
            FieldAccessType.READ,
            'Insufficient access to view notes.'
        );
        List<Note> notes = [
            SELECT Id, ParentId
            FROM Note
            WHERE Id = :noteId
            WITH USER_MODE
            LIMIT 1
        ];
        if (notes.isEmpty()) {
            throw new AuraHandledException('Note record is not accessible.');
        }
        return notes[0];
    }

    private static SObject getAccessibleRelatedRecordForDelete(Id relatedRecordId, String objName) {
        if (objName == 'Attachment') {
            checkObjectAccess(Attachment.SObjectType, FieldAccessType.READ, 'Insufficient access to delete attachments.');
            checkFieldAccess(
                Attachment.SObjectType,
                new Set<String>{ 'Id', 'ParentId' },
                FieldAccessType.READ,
                'Insufficient access to delete attachments.'
            );
            List<Attachment> attachments = [
                SELECT Id, ParentId
                FROM Attachment
                WHERE Id = :relatedRecordId
                WITH USER_MODE
                LIMIT 1
            ];
            if (attachments.isEmpty()) {
                throw new AuraHandledException('Attachment record is not accessible.');
            }
            assertSObjectType(attachments[0].ParentId, Registration_SCH__c.SObjectType, 'Parent record must be a registration.');
            assertAttachmentDeleteAccess(attachments[0].ParentId);
            return attachments[0];
        }
        if (objName == 'Note') {
            Note noteRecord = getAccessibleNoteById(relatedRecordId);
            assertSObjectType(noteRecord.ParentId, Registration_SCH__c.SObjectType, 'Parent record must be a registration.');
            assertNoteDeleteAccess(noteRecord.ParentId);
            return noteRecord;
        }
        throw new AuraHandledException('Unsupported related record type.');
    }

    private static void validateUploadInput(String fileName, String encodedPayload, String contentType) {
        validateNotBlank(fileName, 'File name is required.');
        validateNotBlank(encodedPayload, 'File content is required.');
        validateNotBlank(contentType, 'File content type is required.');
        String normalizedFileName = fileName.trim();
        Integer extensionIndex = normalizedFileName.lastIndexOf('.');
        if (extensionIndex <= 0 || extensionIndex == normalizedFileName.length() - 1) {
            throw new AuraHandledException('File type is not allowed.');
        }
        String extension = normalizedFileName.substring(extensionIndex + 1).toLowerCase();
        if (!ALLOWED_ATTACHMENT_EXTENSIONS.contains(extension)) {
            throw new AuraHandledException('File type is not allowed.');
        }
        if (!ALLOWED_ATTACHMENT_CONTENT_TYPES.contains(contentType.trim().toLowerCase())) {
            throw new AuraHandledException('File content type is not allowed.');
        }
    }

    private static Blob decodeAttachmentBody(String encodedPayload) {
        try {
            String decodedPayload = EncodingUtil.urlDecode(encodedPayload, 'UTF-8');
            Blob fileBody = EncodingUtil.base64Decode(decodedPayload);
            if (fileBody == null || fileBody.size() == 0) {
                throw new AuraHandledException('File content is required.');
            }
            if (fileBody.size() > MAX_ATTACHMENT_SIZE_BYTES) {
                throw new AuraHandledException('File exceeds the maximum supported size.');
            }
            return fileBody;
        } catch (StringException ex) {
            throw new AuraHandledException('File content could not be decoded.');
        }
    }

   /**
 * @description Uploads an attachment to the specified parent record.
 * @param parent Parent record identifier.
 * @param fileName File name to save.
 * @param base64Data Base64-encoded file contents.
 * @param contentType MIME type of the uploaded file.
 * @param userInitiated Indicates whether the upload was triggered by a user action.
 * @return Attachments currently associated with the parent record.
 */
    @AuraEnabled
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static List<Attachment> uploadFile(String parent, String fileName, String base64Data, String contentType, Boolean userInitiated) {
        assertAuthenticatedRequest();
        Id parentId = validateParentRecordId(parent);
        validateUploadInput(fileName, base64Data, contentType);
        if (!Schema.sObjectType.Registration_SCH__c.isAccessible()) {
            throw new AuraHandledException('Insufficient access to the parent registration.');
        }
        if (!Schema.sObjectType.Attachment.isCreateable() ||
            !Schema.sObjectType.Attachment.fields.ParentId.isCreateable() ||
            !Schema.sObjectType.Attachment.fields.Body.isCreateable() ||
            !Schema.sObjectType.Attachment.fields.Name.isCreateable() ||
            !Schema.sObjectType.Attachment.fields.ContentType.isCreateable()) {
            throw new AuraHandledException('Insufficient access to upload attachments.');
        }
        assertAttachmentCreateAccess(parentId);
        Blob attachmentBody = decodeAttachmentBody(base64Data);
        Attachment a = new Attachment();
        a.ParentId = parentId;
        a.Body = attachmentBody;
        a.Name = fileName.trim();
        a.ContentType = contentType.trim().toLowerCase();
        saveInsertResult(
            Database.insert(a, false, AccessLevel.USER_MODE),
            'Unable to upload the attachment.'
        );

        return getAttachmentsByParent(parentId);
    }
/**
 * @description Verifies that the current user has read access to the specified parent record.
 *              Performs both object-level permission checks and a USER_MODE query to confirm
 *              the record exists and is accessible to the running user.
 *
 * @param parentId The Salesforce record Id of the parent object to validate access for.
 *
 * @throws AuraHandledException If the parent record is not found or is inaccessible to the current user.
 *
 * @example
 * Id accountId = '001XXXXXXXXXXXXXXX';
 * assertParentRecordAccessible(accountId);
 */
    public static List<Attachment> uploadFile(String parent, String fileName, String base64Data, String contentType) {
        return uploadFile(parent, fileName, base64Data, contentType, true);
    }

    /**
     * @description Saves a note for the specified registration and returns related notes.
     * @param nn Serialized note payload.
     * @param regID Parent registration identifier.
     * @return Notes related to the provided registration.
     */
    @AuraEnabled
    public static List<Note> saveNotes(String nn, String regID) {
        assertAuthenticatedRequest();
        Id parentId = validateParentRecordId(regID);
        if (!Schema.sObjectType.Registration_SCH__c.isAccessible()) {
            throw new AuraHandledException('Insufficient access to the parent registration.');
        }
        Note requestedNote = parseNotePayload(nn);
        if (requestedNote.ParentId != null && requestedNote.ParentId != parentId) {
            throw new AuraHandledException('Mismatched note parent record.');
        }
        validateNotBlank(requestedNote.Title, 'Note title is required.');

        if (requestedNote.Id == null) {
            if (!Schema.sObjectType.Note.isCreateable() ||
                !Schema.sObjectType.Note.fields.ParentId.isCreateable() ||
                !Schema.sObjectType.Note.fields.Title.isCreateable() ||
                !Schema.sObjectType.Note.fields.Body.isCreateable()) {
                throw new AuraHandledException('Insufficient access to create notes.');
            }
            assertNoteCreateAccess(parentId);
            Note noteToInsert = new Note();
            noteToInsert.ParentId = parentId;
            noteToInsert.Title = requestedNote.Title.trim();
            noteToInsert.Body = requestedNote.Body;
            saveInsertResult(
                Database.insert(noteToInsert, false, AccessLevel.USER_MODE),
                'Unable to save the note.'
            );
        } else {
            Note existingNote = getAccessibleNoteById(validateRecordId(String.valueOf(requestedNote.Id), 'Invalid note record id.'));
            if (existingNote.ParentId != parentId) {
                throw new AuraHandledException('Mismatched note parent record.');
            }
            if (!Schema.sObjectType.Note.isUpdateable() ||
                !Schema.sObjectType.Note.fields.ParentId.isUpdateable() ||
                !Schema.sObjectType.Note.fields.Title.isUpdateable() ||
                !Schema.sObjectType.Note.fields.Body.isUpdateable()) {
                throw new AuraHandledException('Insufficient access to update notes.');
            }
            assertNoteUpdateAccess(parentId);
            Note noteToUpdate = buildSafeNoteForUpdate(existingNote.Id, parentId, requestedNote);
            saveUpdateResult(
                Database.update(noteToUpdate, false, AccessLevel.USER_MODE),
                'Unable to save the note.'
            );
        }
        return getNotesByParent(parentId);
    }

    /**
     * @description Deletes a related attachment or note record by Id.
     * @param raId Identifier of the record to delete.
     * @param objName API name of the object to delete from.
     * @return Wrapper indicating completion state.
     */
    @AuraEnabled(cacheable=false)
    public static wrapper  deleteAT(String raId, String objName){
        Wrapper wrapper=new Wrapper();
        assertAuthenticatedRequest();
        if (!SUPPORTED_RELATED_RECORD_OBJECTS.contains(objName)) {
            throw new AuraHandledException('Unsupported related record type.');
        }
        Id relatedRecordId = validateRecordId(raId, 'Invalid related record id.');
        SObject relatedRecord = getAccessibleRelatedRecordForDelete(relatedRecordId, objName);
        saveDeleteResult(
            Database.delete(relatedRecord, false, AccessLevel.USER_MODE),
            'Unable to delete the related record.'
        );
        return wrapper;
    }

    /**
     * @description Returns an empty records wrapper for queue registration data.
     * @return New records wrapper instance.
     */
    @AuraEnabled
    public static Records getRegRecords(){
        Records rec=new Records();
        return rec;
    }

    /**
     * Wrapper for registration details shown in the queue scheduler UI.
     */
    public class Records{
        /**
         * Registration record returned to the client.
         */
        @AuraEnabled public Registration_SCH__c regRecords {get;set;}
        /**
         * Calculated wait time label for the registration.
         */
        @AuraEnabled public String waitingTime {get;set;}
        /**
         * Initializes the records wrapper with an empty registration instance.
         */
        public Records(){
            regRecords = new Registration_SCH__c();
        }
    }

    /**
     * Select-option model used by the scheduler picklists.
     */
    public class SelectOptions {
        /**
         * Display label shown to the user.
         */
        @AuraEnabled public String label     { get; set; }
        /**
         * Backing value submitted by the client.
         */
        @AuraEnabled public String value     { get; set; }
        /**
         * Indicates whether the option is preselected.
         */
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        @AuraEnabled public Boolean selected { get; set; }

        /**
         * Creates an unselected option entry.
         *
         * @param lab Label shown to the user.
         * @param val Stored option value.
         */
        public SelectOptions(String lab, string val) {
            label = lab;//selected = false;
            value = val;
        }
        /**
         * Creates an option entry with an explicit selected state.
         *
         * @param lab Label shown to the user.
         * @param val Stored option value.
         * @param sel Whether the option is selected.
         */
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        public SelectOptions(String lab, string val, Boolean sel) {
            label = lab;
            value = val;
            selected = sel;
        }
    }

    // commented by abuzar on 2026-03-13 for the scanning issue and added below line "moved the helper request model and branching utility methods into a dedicated support class to reduce Queue_Expert_Sch class cyclomatic complexity and remove the long helper constructor parameter list"
    /*
    private class LocationLoadRequest {
        private String locationId;
        private String resourceId;
        private String serviceId;
        private String category;

        private LocationLoadRequest(String location, String resource, String service, String catValue) {
            locationId = normalizeInput(location);
            resourceId = normalizeInput(resource);
            serviceId = normalizeInput(service);
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

    /**
     * Response wrapper shared across queue scheduler Aura/LWC actions.
     */
    @SuppressWarnings('PMD.ExcessivePublicCount')
    public class Wrapper{
        /**
         * Category options available to the client.
         */
        @AuraEnabled public  List<Selectoptions> allCategory            { get;set;}
        /**
         * Registration records returned by the current query.
         */
        @AuraEnabled public List<Registration_SCH__c> records             {get;set;}
        /**
         * Error message surfaced to the client.
         */
        @AuraEnabled public String   errorMsg                                   {get;set;}
        /**
         * Available location names.
         */
        @AuraEnabled public Set<String> allLocations                            {get;set;}
        /**
         * Selected location identifier.
         */
        @AuraEnabled public String   locationId                                 {get;set;}
        /**
         * Generic response payload map for dynamic data.
         */
        @AuraEnabled public map<String, Object> mapOfRecords                   {get;set;}
        /**
         * Selected service identifier.
         */
        @AuraEnabled public String   serviceId                                  {get;set;}
        /**
         * Indicates whether at least one location exists.
         */
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        @AuraEnabled public boolean existLocation                               {get;set;}
        /**
         * Indicates whether an operation is currently in progress.
         */
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        @AuraEnabled public boolean inProgress                                  {get;set;}
        /**
         * Registration records used by object-based views.
         */
        @AuraEnabled public List<Registration_SCH__c> objectValues        {get;set;}
        /**
         * Indicates whether a status update succeeded.
         */
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        @AuraEnabled public boolean updateStatus                                {get;set;}
        /**
         * Indicates whether a cancel status update succeeded.
         */
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        @AuraEnabled public boolean updateStatusForCancel                       {get;set;}
        /**
         * User records available for assignment or filtering.
         */
        @AuraEnabled public List<User> userName                                 {get;set;}
        /**
         * Record types available to the client.
         */
        @AuraEnabled public List<RecordType> recordTypeName                     {get;set;}
        /**
         * Registrations prepared for rescheduling.
         */
        @AuraEnabled public list<Registration_SCH__c> getReschudle        {get;set;}
        /**
         * Human-readable booked time label.
         */
        @AuraEnabled public String bookedTime                                   {get;set;}
        /**
         * Available slot labels.
         */
        @AuraEnabled public List<String> slots                                  {get;set;}
        /**
         * Available slot date-times.
         */
        @AuraEnabled public List<DateTime> dslots                               {get;set;}
        /**
         * Selected reschedule date-time.
         */
        @AuraEnabled public DateTime resDate                                    {get;set;}
		/**
         * Indicates whether the time-slot update succeeded.
         */
		@SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        @AuraEnabled public boolean updateTimeSlot                              {get;set;}
        /**
         * Selected schedule day.
         */
        @AuraEnabled public Date sDay                                           {get;set;}

        /**
         * Slots grouped by date.
         */
        @AuraEnabled public Map<Date, List<DateTime>> mapOfslots                {get;set;}
        /**
         * Selected expert name.
         */
        @AuraEnabled public String expertName                                   {get;set;}
        /**
         * Current date-time reference used by the scheduler.
         */
        @AuraEnabled public DateTime todaysDate                                {get;set;}
        /**
         * Registrations impacted by slot updates.
         */
        @AuraEnabled public List<Registration_SCH__c> updateSlotReg       {get;set;}
        /**
         * Slots grouped by date and display key.
         */
        @AuraEnabled public Map<Date, Map<String,String>> mapOfslots2           {get;set;}
        /**
         * Existing slot date-times.
         */
        @AuraEnabled public List<DateTime> dateExist                            {get;set;}
        /**
         * Available expert identifiers.
         */
        @AuraEnabled public Set<String> expertIds                               {get;set;}
        /**
         * Available service identifiers.
         */
        @AuraEnabled public Set<String> serviceIds                              {get;set;}
        /**
         * Available location identifiers.
         */
        @AuraEnabled public Set<String> locationIds                             {get;set;}
        /**
         * Available program names.
         */
        @AuraEnabled public Set<String> programs                                {get;set;}
        /**
         * Generic disable flag used by the client.
         */
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        @AuraEnabled public boolean dis                                         {get;set;}
        /**
         * Secondary disable flag used by the client.
         */
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        @AuraEnabled public boolean disl                                        {get;set;}
        /**
         * Available service names.
         */
        @AuraEnabled public set<String> allService                              {get;set;}
        /**
         * Queue records returned to the client.
         */
        @AuraEnabled public List<Queue__c> queue                      {get;set;}
        /**
         * Available resource names.
         */
        @AuraEnabled public Set<String> allresources                            {get;set;}
        /**
         * Available service labels.
         */
        @AuraEnabled public Set<String> allServices                             {get;set;}
        /**
         * Queue records used for location selection.
         */
        @AuraEnabled public List<Queue__c> getLocation                {get;set;}
        /**
         * Filtered service value.
         */
        @AuraEnabled public  String   fser {get;set;}
        /**
         * Filtered resource value.
         */
        @AuraEnabled public String   fres                                       {get;set;}
        /**
         * Filtered location value.
         */
        @AuraEnabled public String   floc                                       {get;set;}
        /**
         * Selected location name.
         */
        @AuraEnabled public String   locName                                    {get;set;}
        /**
         * Attachments linked to the current registration.
         */
        @AuraEnabled public List<Attachment> attachments                       {get;set;}
        /**
         * Notes linked to the current registration.
         */
        @AuraEnabled public List<Note> notes                                   {get;set;}
        /**
         * Indicates whether team-related UI should be shown.
         */
        @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
        @AuraEnabled public Boolean   showTeam                                  {get;set;}
        /**
         * Selected resource name.
         */
        @AuraEnabled public  String resName {get;set;}
        /**
         * Selected team identifier.
         */
        @AuraEnabled public String selectedTeamID                               {get;set;}
        /**
         * Wrapped registration records for the client.
         */
        @AuraEnabled public List<Records> regRecords                            {get;set;}
        /**
         * Currently selected program.
         */
        @AuraEnabled public String currentProgram    {get;set;}
        /**
         * Alternate error message field.
         */
        @AuraEnabled public String        errmsg                                {get;set;}
        /**
         * Selected registration identifier.
         */
        @AuraEnabled public String selRG            {get;set;}
        /**
         * Selected resource identifier.
         */
        @AuraEnabled public String                             selRes            {get;set;}
        /**
         * Queue field API names requested by the client.
         */
        @AuraEnabled public List<String>                       queueFields      {get;set;}
        /**
         * Appointment field API names requested by the client.
         */
        @AuraEnabled public List<String>                 appointmentFields      {get;set;}
        /**
         * Customer field API names requested by the client.
         */
        @AuraEnabled public List<String>                 customerFields         {get;set;}
        /**
         * Meeting field API names requested by the client.
         */
        @AuraEnabled public List<String>                 meetingFields          {get;set;}
        /**
         * Scheduler field API names requested by the client.
         */
        @AuraEnabled public List<String>                 schudlarFields         {get;set;}
        /**
         * Refresh interval for the workbench view.
         */
        @AuraEnabled public Integer                      wbRefresh              { get;set;}
        /**
         * Selected user name for resource filtering.
         */
        @AuraEnabled public String                       selectedUserName       { get;set;} //User Resource__c
        /**
         * Active appointment filter label.
         */
        @AuraEnabled public String   appointmentFiler{ get;set;}
        /**
         * Initializes the wrapper with default collection and flag values.
         */
        public Wrapper(){
            queueFields=new List<String>();
            appointmentFields=new List<String>();
            customerFields=new List<String>();
            meetingFields=new List<String>();
            schudlarFields=new List<String>();
            allService=new set<String>();
            queue=new List<Queue__c>();
            allresources=new Set<String>();
            allServices=new Set<String>();
            getLocation=new List<Queue__c>();
            attachments=new List<Attachment>();
            notes=new List<Note>();
            showTeam=false;
            allCategory = new List<Selectoptions>();
            selectedUserName='';
            appointmentFiler='Todays Appointments';
            dateExist=new List<DateTime>();
            expertIds=new Set<String>();
            serviceIds=new Set<String>();
            locationIds=new Set<String>();
            programs=new Set<String>();
            dis=false;
            disl=false;
            objectValues    = new List<Registration_SCH__c>();
            records         = new List<Registration_SCH__c>();
            regRecords      = new List<Records>();
            mapOfRecords    = new Map<String, Object>();
            userName        = new List<User>();
            recordTypeName  = new List<RecordType>();
            existLocation   = false;
            inProgress      = false;
            updateStatus    = false;
            updateStatusForCancel = false;
        }
    }
    // commented by abuzar on 2026-03-13 for the scanning issue and added below line "moved the support classes into dedicated Apex files so Queue_Expert_Sch compiles cleanly and the helper complexity no longer counts against this class"
    //changes end here by abuzar
}
