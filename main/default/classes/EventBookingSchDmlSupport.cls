/**
 * @description Dedicated DML support for event booking flows to keep orchestration logic separate from persistence.
 */
public with sharing class EventBookingSchDmlSupport {
    /**
     * @description Upserts a contact in user mode.
     * @param contactRecord Contact record to persist.
     */
    public static void upsertContactUserMode(Contact contactRecord) {
        Database.upsert(contactRecord, AccessLevel.USER_MODE);
    }

    /**
     * @description Upserts a registration in user mode.
     * @param registrationRecord Registration record to persist.
     */
    public static void upsertRegistrationUserMode(Registration_SCH__c registrationRecord) {
        Database.upsert(registrationRecord, AccessLevel.USER_MODE);
    }

    /**
     * @description Inserts registration records in user mode when records are supplied.
     * @param registrations Registration records to insert.
     */
    public static void insertRegistrations(List<Registration_SCH__c> registrations) {
        if (registrations != null) {
            Database.insert(registrations, AccessLevel.USER_MODE);
        }
    }

    /**
     * @description Updates registration records in user mode when records are supplied.
     * @param registrations Registration records to update.
     */
    public static void updateRegistrations(List<Registration_SCH__c> registrations) {
        if (registrations != null) {
            Database.update(registrations, AccessLevel.USER_MODE);
        }
    }

    /**
     * @description Inserts contact records in user mode when records are supplied.
     * @param contacts Contact records to insert.
     */
    public static void insertContacts(List<Contact> contacts) {
        if (contacts != null) {
            Database.insert(contacts, AccessLevel.USER_MODE);
        }
    }

    /**
     * @description Upserts contact records in user mode when records are supplied.
     * @param contacts Contact records to persist.
     */
    public static void upsertContacts(List<Contact> contacts) {
        if (contacts != null) {
            Database.upsert(contacts, AccessLevel.USER_MODE);
        }
    }

    /**
     * @description Upserts a single registration after splitting create and update paths.
     * @param registrationRecord Registration record to persist.
     */
    public static void upsertRegistration(Registration_SCH__c registrationRecord) {
        if (registrationRecord == null) {
            return;
        }

        List<Registration_SCH__c> registrationRecords = new List<Registration_SCH__c>{ registrationRecord };
        persistRegistrationRecords(registrationRecords);
    }

    /**
     * @description Upserts registration records after splitting create and update paths.
     * @param registrationRecords Registration records to persist.
     */
    public static void upsertRegistrations(List<Registration_SCH__c> registrationRecords) {
        if (registrationRecords != null) {
            persistRegistrationRecords(registrationRecords);
        }
    }

    /**
     * @description Upserts a contact in user mode.
     * @param contactRecord Contact record to persist.
     */
    public static void upsertContact(Contact contactRecord) {
        Database.upsert(contactRecord, AccessLevel.USER_MODE);
    }

    /**
     * @description Updates an event in user mode.
     * @param eventRecord Event record to update.
     */
    public static void updateEvent(Event__c eventRecord) {
        Database.update(eventRecord, AccessLevel.USER_MODE);
    }

    /**
     * @description Inserts a contact in user mode.
     * @param contactRecord Contact record to insert.
     */
    public static void insertContact(Contact contactRecord) {
        Database.insert(contactRecord, AccessLevel.USER_MODE);
    }

    private static void persistRegistrationRecords(List<Registration_SCH__c> registrationRecords) {
        List<SObject> createCandidates = new List<SObject>();
        List<SObject> updateCandidates = new List<SObject>();

        for (Registration_SCH__c registrationRecord : registrationRecords) {
            if (registrationRecord == null) {
                continue;
            }
            if (registrationRecord.Id == null) {
                createCandidates.add(registrationRecord);
            } else {
                updateCandidates.add(registrationRecord);
            }
        }

        List<Registration_SCH__c> createRecords = getSafeRegistrationCreateRecords(createCandidates);
        List<Registration_SCH__c> updateRecords = getSafeRegistrationUpdateRecords(updateCandidates);

        if (!createRecords.isEmpty()) {
            Database.insert(createRecords, AccessLevel.USER_MODE);
        }

        if (!updateRecords.isEmpty()) {
            Database.update(updateRecords, AccessLevel.USER_MODE);
        }
    }

    private static List<Registration_SCH__c> getSafeRegistrationCreateRecords(List<SObject> createCandidates) {
        if (createCandidates.isEmpty()) {
            return new List<Registration_SCH__c>();
        }

        List<SObject> safeList = FLSHelperSch.getSafeRecords(
            createCandidates,
            'Registration_SCH__c',
            AccessType.CREATABLE
        );

        List<Registration_SCH__c> typedList = new List<Registration_SCH__c>();
        for (Integer index = 0; index < safeList.size(); index++) {
            Registration_SCH__c typeRecord = (Registration_SCH__c)safeList[index];
            Registration_SCH__c sourceRecord = (Registration_SCH__c)createCandidates[index];

            if (!typeRecord.getPopulatedFieldsAsMap().containsKey('RecordTypeId') && sourceRecord.RecordTypeId != null) {
                typeRecord.RecordTypeId = sourceRecord.RecordTypeId;
            }

            typedList.add(typeRecord);
        }
        return typedList;
    }

    private static List<Registration_SCH__c> getSafeRegistrationUpdateRecords(List<SObject> updateCandidates) {
        if (updateCandidates.isEmpty()) {
            return new List<Registration_SCH__c>();
        }

        List<SObject> safeList = FLSHelperSch.getSafeRecords(
            updateCandidates,
            'Registration_SCH__c',
            AccessType.UPDATABLE
        );

        List<Registration_SCH__c> typedList = new List<Registration_SCH__c>();
        for (Integer index = 0; index < safeList.size(); index++) {
            Registration_SCH__c typeRecord = (Registration_SCH__c)safeList[index];
            Registration_SCH__c sourceRecord = (Registration_SCH__c)updateCandidates[index];

            if (!typeRecord.getPopulatedFieldsAsMap().containsKey('Id') && sourceRecord.Id != null) {
                typeRecord.Id = sourceRecord.Id;
            }

            typedList.add(typeRecord);
        }
        return typedList;
    }
}
