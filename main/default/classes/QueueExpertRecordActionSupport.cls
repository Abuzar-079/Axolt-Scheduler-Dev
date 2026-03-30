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

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static Queue_Expert_Sch.Wrapper updateRecordValues(
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
        Queue_Expert_Sch.Wrapper wrapper = new Queue_Expert_Sch.Wrapper();
        QueueExpertAccessSupport.assertAuthenticatedRequest();
        Id registrationId = QueueExpertAccessSupport.validateRegistrationId(regId);
        List<String> recordValues = QueueExpertAccessSupport.deserializeSubmittedValues(recValues, 'Invalid record update payload.');
        QueueExpertAccessSupport.assertRegistrationAccess(registrationId, QueueExpertAccessSupport.AccessType.EDIT);
        QueueExpertAccessSupport.checkFieldAccess(
            QueueExpertAccessSupport.buildFieldAccessRequest(
                Registration_SCH__c.SObjectType,
                UPDATE_RECORD_MUTABLE_FIELDS,
                QueueExpertAccessSupport.AccessType.EDIT
            ).withErrorMessage('Insufficient field access to update the registration.')
        );
        Registration_SCH__c registrationToUpdate = new Registration_SCH__c(Id = registrationId);
        QueueExpertAccessSupport.applyApprovedUpdateRecordValues(registrationToUpdate, recordValues);
        QueueExpertAccessSupport.saveUpdateResult(
            Database.update(registrationToUpdate, false, AccessLevel.USER_MODE),
            'Unable to update the registration.'
        );
        return wrapper;
    }

    public static Queue_Expert_Sch.Wrapper popUpRecordsOfId(String id, String location, String waitingTime) {
        Queue_Expert_Sch.Wrapper wrapper = new Queue_Expert_Sch.Wrapper();
        QueueExpertAccessSupport.assertAuthenticatedRequest();
        Id registrationId = QueueExpertAccessSupport.validateRegistrationId(id);
        QueueExpertAccessSupport.assertRegistrationAccess(registrationId, QueueExpertAccessSupport.AccessType.EDIT);
        QueueExpertAccessSupport.checkFieldAccess(
            QueueExpertAccessSupport.buildFieldAccessRequest(
                Registration_SCH__c.SObjectType,
                new Set<String>{ 'Booked_Current_Status__c', 'waiting_Time__c', 'Serve_Start_Time__c' },
                QueueExpertAccessSupport.AccessType.EDIT
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
                QueueExpertAccessSupport.AccessType.READ
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

    public static Queue_Expert_Sch.Wrapper getRegDetails(String id) {
        Queue_Expert_Sch.Wrapper wrapper = new Queue_Expert_Sch.Wrapper();
        Id registrationId = QueueExpertAccessSupport.validateRegistrationId(id);
        QueueExpertAccessSupport.assertRegistrationAccess(registrationId, QueueExpertAccessSupport.AccessType.READ);
        QueueExpertSchSupport.loadWrapperDetailsForRegistration(wrapper, id);
        return wrapper;
    }

    public static Queue_Expert_Sch.Wrapper setStatus(String passedId, String location, String status, String purpose) {
        Queue_Expert_Sch.Wrapper wrapper = new Queue_Expert_Sch.Wrapper();
        QueueExpertAccessSupport.assertAuthenticatedRequest();
        Id registrationId = QueueExpertAccessSupport.validateRegistrationId(passedId);
        QueueExpertAccessSupport.validateNotBlank(status, 'Status is required.');
        QueueExpertAccessSupport.assertRegistrationAccess(registrationId, QueueExpertAccessSupport.AccessType.EDIT);
        QueueExpertAccessSupport.checkFieldAccess(
            QueueExpertAccessSupport.buildFieldAccessRequest(
                Registration_SCH__c.SObjectType,
                new Set<String>{ 'Status__c', 'Booked_Current_Status__c', 'Cancellation_Reason__c', 'Serve_Finished_Time__c' },
                QueueExpertAccessSupport.AccessType.EDIT
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
                QueueExpertAccessSupport.AccessType.READ
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

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static Queue_Expert_Sch.Wrapper getRegRecordUpdate(
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
        Queue_Expert_Sch.Wrapper wrapper = new Queue_Expert_Sch.Wrapper();
        QueueExpertAccessSupport.assertAuthenticatedRequest();
        Id registrationId = QueueExpertAccessSupport.validateRegistrationId(regId);
        List<String> recordValues = QueueExpertAccessSupport.deserializeSubmittedValues(recValues, 'Invalid record update payload.');
        QueueExpertAccessSupport.assertRegistrationAccess(registrationId, QueueExpertAccessSupport.AccessType.EDIT);
        QueueExpertAccessSupport.checkFieldAccess(
            QueueExpertAccessSupport.buildFieldAccessRequest(
                Registration_SCH__c.SObjectType,
                UPDATE_RECORD_MUTABLE_FIELDS,
                QueueExpertAccessSupport.AccessType.EDIT
            ).withErrorMessage('Insufficient field access to update the registration.')
        );

        Registration_SCH__c registrationToUpdate = new Registration_SCH__c(Id = registrationId);
        registrationToUpdate.Status__c = 'Completed';
        registrationToUpdate.Customer_Status__c = 'Attended';
        registrationToUpdate.Registration_Time__c = sDate;
        registrationToUpdate.End_Time__c = eDate;
        QueueExpertAccessSupport.applyApprovedUpdateRecordValues(registrationToUpdate, recordValues);
        registrationToUpdate.Booked_Current_Status__c = 'Completed';
        registrationToUpdate.Serve_Finished_Time__c = System.now();
        QueueExpertAccessSupport.saveUpdateResult(
            Database.update(registrationToUpdate, false, AccessLevel.USER_MODE),
            'Unable to update the registration.'
        );

        QueueExpertAccessSupport.checkFieldAccess(
            QueueExpertAccessSupport.buildFieldAccessRequest(
                Registration_SCH__c.SObjectType,
                new Set<String>{ 'Status__c' },
                QueueExpertAccessSupport.AccessType.READ
            ).withErrorMessage('Insufficient field access to view the registration.')
        );
        Registration_SCH__c refreshedRecord = [
            SELECT Status__c
            FROM Registration_SCH__c
            WHERE Id = :registrationId
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
}
