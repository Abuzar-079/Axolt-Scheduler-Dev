/**
 * @description Record-focused queue expert actions extracted from Queue_Expert_Sch.
 */
public with sharing class QueueExpertRecordActionSupport {
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

    private class RecordUpdateContext {
        private Id registrationId;
        private List<String> recordValues;
        private Registration_SCH__c registrationToUpdate;
    }

    /**
     * @description Updates a registration record with approved queue-expert field values.
     * @param regId Registration identifier to update.
     * @param recValues Serialized field values submitted by the client.
     * @param userID User identifier associated with the update request.
     * @param recordType Record type context supplied by the client.
     * @param queueId Queue identifier supplied by the client.
     * @param accountId Account identifier supplied by the client.
     * @param event Event identifier supplied by the client.
     * @param location Expert location identifier supplied by the client.
     * @param sDate Start date-time supplied by the client.
     * @param eDate End date-time supplied by the client.
     * @return Wrapper containing the update outcome.
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static QueueExpertWrapper updateRecordValues(
        String regId,
        String recValues,
        String userID,
        String recordType,
        String queueId,
        String accountId,
        String event,
        String location,
        DateTime sDate,
        DateTime eDate
    ) {
        QueueExpertWrapper wrapper = new QueueExpertWrapper();
        RecordUpdateContext updateContext = buildRecordUpdateContext(regId, recValues);
        QueueExpertAccessSupport.applyApprovedUpdateRecordValues(updateContext.registrationToUpdate, updateContext.recordValues);
        QueueExpertAccessSupport.saveUpdateResult(
            Database.update(updateContext.registrationToUpdate, false, AccessLevel.USER_MODE),
            'Unable to update the registration.'
        );
        return wrapper;
    }

    /**
     * @description Marks a registration as in progress and reloads its detail wrapper.
     * @param id Registration identifier to update.
     * @param location Location context supplied by the client.
     * @param waitingTime Waiting-time value to store on the registration.
     * @return Wrapper containing refreshed registration details.
     */
    public static QueueExpertWrapper popUpRecordsOfId(String id, String location, String waitingTime) {
        QueueExpertWrapper wrapper = new QueueExpertWrapper();
        QueueExpertAccessSupport.assertAuthenticatedRequest();
        Id registrationId = QueueExpertAccessSupport.validateRegistrationId(id);
        QueueExpertAccessSupport.assertRegistrationAccess(registrationId, QueueExpertAccessSupport.ACCESS_EDIT);
        QueueExpertAccessSupport.checkFieldAccess(
            QueueExpertAccessSupport.buildFieldAccessRequest(
                Registration_SCH__c.SObjectType,
                new Set<String>{ 'Booked_Current_Status__c', 'waiting_Time__c', 'Serve_Start_Time__c' },
                QueueExpertAccessSupport.ACCESS_EDIT
            ).withErrorMessage('Insufficient field access to update the registration.')
        );

        Registration_SCH__c registrationToUpdate = new Registration_SCH__c(Id = registrationId);
        registrationToUpdate.Booked_Current_Status__c = 'InProgress';
        registrationToUpdate.waiting_Time__c = QueueExpertAccessSupport.normalizeForField(waitingTime);
        registrationToUpdate.Serve_Start_Time__c = System.now();
        QueueExpertAccessSupport.saveUpdateResult(
            Database.update(registrationToUpdate, false, AccessLevel.USER_MODE),
            'Unable to mark the registration as in progress.'
        );

        QueueExpertAccessSupport.checkFieldAccess(
            QueueExpertAccessSupport.buildFieldAccessRequest(
                Registration_SCH__c.SObjectType,
                new Set<String>{ 'Booked_Current_Status__c' },
                QueueExpertAccessSupport.ACCESS_READ
            ).withErrorMessage('Insufficient field access to view the registration.')
        );
        Registration_SCH__c refreshedRecord = [
            SELECT Booked_Current_Status__c
            FROM Registration_SCH__c
            WHERE Id = :registrationId
            WITH USER_MODE
            LIMIT 1
        ];
        if (refreshedRecord.Booked_Current_Status__c == 'InProgress') {
            wrapper.updateStatusForCancel = true;
        }
        QueueExpertSchSupport.loadWrapperDetailsForRegistration(wrapper, id);
        return wrapper;
    }

    /**
     * @description Loads queue-expert details for the supplied registration.
     * @param id Registration identifier to load.
     * @return Wrapper containing registration details and related data.
     */
    public static QueueExpertWrapper getRegDetails(String id) {
        QueueExpertWrapper wrapper = new QueueExpertWrapper();
        Id registrationId = QueueExpertAccessSupport.validateRegistrationId(id);
        QueueExpertAccessSupport.assertRegistrationAccess(registrationId, QueueExpertAccessSupport.ACCESS_READ);
        QueueExpertSchSupport.loadWrapperDetailsForRegistration(wrapper, id);
        return wrapper;
    }

    // commented by abuzar on 2026-03-30 for the scanning issue and added below line "Avoid long parameter lists (4 parameters - threshold is 4)."
    // public static QueueExpertWrapper setStatus(String passedId, String location, String status, String purpose) {
    /**
     * @description Updates the registration status and completion metadata.
     * @param passedId Registration identifier to update.
     * @param status Status value to store on the registration.
     * @param purpose Cancellation or completion reason from the client.
     * @return Wrapper containing the status-update outcome.
     */
    public static QueueExpertWrapper setStatus(String passedId, String status, String purpose) {
    //changes end here by abuzar
        QueueExpertWrapper wrapper = new QueueExpertWrapper();
        QueueExpertAccessSupport.assertAuthenticatedRequest();
        Id registrationId = QueueExpertAccessSupport.validateRegistrationId(passedId);
        QueueExpertAccessSupport.validateNotBlank(status, 'Status is required.');
        QueueExpertAccessSupport.assertRegistrationAccess(registrationId, QueueExpertAccessSupport.ACCESS_EDIT);
        QueueExpertAccessSupport.checkFieldAccess(
            QueueExpertAccessSupport.buildFieldAccessRequest(
                Registration_SCH__c.SObjectType,
                new Set<String>{ 'Status__c', 'Booked_Current_Status__c', 'Cancellation_Reason__c', 'Serve_Finished_Time__c' },
                QueueExpertAccessSupport.ACCESS_EDIT
            ).withErrorMessage('Insufficient field access to update the registration.')
        );

        Registration_SCH__c registrationToUpdate = new Registration_SCH__c(Id = registrationId);
        registrationToUpdate.Status__c = status.trim();
        registrationToUpdate.Booked_Current_Status__c = 'Completed';
        registrationToUpdate.Cancellation_Reason__c = QueueExpertAccessSupport.normalizeForField(purpose);
        registrationToUpdate.Serve_Finished_Time__c = System.now();
        QueueExpertAccessSupport.saveUpdateResult(
            Database.update(registrationToUpdate, false, AccessLevel.USER_MODE),
            'Unable to update the registration status.'
        );
        QueueExpertAccessSupport.checkFieldAccess(
            QueueExpertAccessSupport.buildFieldAccessRequest(
                Registration_SCH__c.SObjectType,
                new Set<String>{ 'Status__c' },
                QueueExpertAccessSupport.ACCESS_READ
            ).withErrorMessage('Insufficient field access to view the registration.')
        );
        Registration_SCH__c refreshedRecord = [
            SELECT Status__c
            FROM Registration_SCH__c
            WHERE Id = :registrationId
            WITH USER_MODE
            LIMIT 1
        ];
        if (refreshedRecord.Status__c == status.trim()) {
            wrapper.updateStatusForCancel = true;
        }
        QueueExpertSchSupport.loadPrimaryRecordRelatedData(wrapper);
        return wrapper;
    }

    /**
     * @description Updates a registration and reloads the queue-expert detail wrapper.
     * @param regId Registration identifier to update.
     * @param recValues Serialized field values submitted by the client.
     * @param userID User identifier associated with the update request.
     * @param recordType Record type context supplied by the client.
     * @param queueId Queue identifier supplied by the client.
     * @param accountId Account identifier supplied by the client.
     * @param event Event identifier supplied by the client.
     * @param location Expert location identifier supplied by the client.
     * @param sDate Updated start date-time.
     * @param eDate Updated end date-time.
     * @return Wrapper containing refreshed registration details.
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static QueueExpertWrapper getRegRecordUpdate(
        String regId,
        String recValues,
        String userID,
        String recordType,
        String queueId,
        String accountId,
        String event,
        String location,
        DateTime sDate,
        DateTime eDate
    ) {
        QueueExpertWrapper wrapper = new QueueExpertWrapper();
        RecordUpdateContext updateContext = buildRecordUpdateContext(regId, recValues);
        updateContext.registrationToUpdate.Status__c = 'Completed';
        updateContext.registrationToUpdate.Customer_Status__c = 'Attended';
        updateContext.registrationToUpdate.Registration_Time__c = sDate;
        updateContext.registrationToUpdate.End_Time__c = eDate;
        QueueExpertAccessSupport.applyApprovedUpdateRecordValues(updateContext.registrationToUpdate, updateContext.recordValues);
        updateContext.registrationToUpdate.Booked_Current_Status__c = 'Completed';
        updateContext.registrationToUpdate.Serve_Finished_Time__c = System.now();
        QueueExpertAccessSupport.saveUpdateResult(
            Database.update(updateContext.registrationToUpdate, false, AccessLevel.USER_MODE),
            'Unable to update the registration.'
        );

        QueueExpertAccessSupport.checkFieldAccess(
            QueueExpertAccessSupport.buildFieldAccessRequest(
                Registration_SCH__c.SObjectType,
                new Set<String>{ 'Status__c' },
                QueueExpertAccessSupport.ACCESS_READ
            ).withErrorMessage('Insufficient field access to view the registration.')
        );
        Registration_SCH__c refreshedRecord = [
            SELECT Status__c
            FROM Registration_SCH__c
            WHERE Id = :updateContext.registrationId
            WITH USER_MODE
            LIMIT 1
        ];
        if (refreshedRecord.Status__c == 'Completed') {
            wrapper.updateStatus = true;
        }
        QueueExpertSchSupport.loadWrapperDetailsForRegistration(wrapper, regId);
        wrapper.errmsg = null;
        return wrapper;
    }

    private static RecordUpdateContext buildRecordUpdateContext(String regId, String recValues) {
        QueueExpertAccessSupport.assertAuthenticatedRequest();

        RecordUpdateContext updateContext = new RecordUpdateContext();
        updateContext.registrationId = QueueExpertAccessSupport.validateRegistrationId(regId);
        updateContext.recordValues = QueueExpertAccessSupport.deserializeSubmittedValues(
            recValues,
            'Invalid record update payload.'
        );
        QueueExpertAccessSupport.assertRegistrationAccess(
            updateContext.registrationId,
            QueueExpertAccessSupport.ACCESS_EDIT
        );
        QueueExpertAccessSupport.checkFieldAccess(
            QueueExpertAccessSupport.buildFieldAccessRequest(
                Registration_SCH__c.SObjectType,
                UPDATE_RECORD_MUTABLE_FIELDS,
                QueueExpertAccessSupport.ACCESS_EDIT
            ).withErrorMessage('Insufficient field access to update the registration.')
        );
        updateContext.registrationToUpdate = new Registration_SCH__c(Id = updateContext.registrationId);
        return updateContext;
    }
}
