/**
 * @description Dedicated DML support for event booking flows to keep orchestration logic separate from persistence.
 */
public with sharing class EventBookingSchDmlSupport {
    public static void upsertContactUserMode(Contact contactRecord) {
        Database.upsert(contactRecord, AccessLevel.USER_MODE);
    }

    public static void upsertRegistrationUserMode(Registration_SCH__c registrationRecord) {
        Database.upsert(registrationRecord, AccessLevel.USER_MODE);
    }

    public static void insertRegistrations(List<Registration_SCH__c> registrations) {
        if (registrations == null || registrations.isEmpty()) {
            return;
        }
        insert registrations;
    }

    public static void updateRegistrations(List<Registration_SCH__c> registrations) {
        if (registrations == null || registrations.isEmpty()) {
            return;
        }
        update registrations;
    }

    public static void insertContacts(List<Contact> contacts) {
        if (contacts == null || contacts.isEmpty()) {
            return;
        }
        insert contacts;
    }

    public static void upsertContacts(List<Contact> contacts) {
        if (contacts == null || contacts.isEmpty()) {
            return;
        }
        upsert contacts;
    }

    public static void upsertRegistration(Registration_SCH__c registrationRecord) {
        if (registrationRecord == null) {
            return;
        }

        List<Registration_SCH__c> registrationRecords = new List<Registration_SCH__c>{ registrationRecord };
        persistRegistrationRecords(registrationRecords);
    }

    public static void upsertRegistrations(List<Registration_SCH__c> registrationRecords) {
        if (registrationRecords == null || registrationRecords.isEmpty()) {
            return;
        }
        persistRegistrationRecords(registrationRecords);
    }

    public static void upsertContact(Contact contactRecord) {
        upsert contactRecord;
    }

    public static void updateEvent(Event__c eventRecord) {
        update eventRecord;
    }

    public static void insertContact(Contact contactRecord) {
        insert contactRecord;
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
            if (Schema.sObjectType.Registration_SCH__c.isCreateable()) {
                insert createRecords;
            } else {
                throw new AuraHandledException('Insufficient access to create registrations.');
            }
        }

        if (!updateRecords.isEmpty()) {
            if (Schema.sObjectType.Registration_SCH__c.isUpdateable()) {
                update updateRecords;
            } else {
                throw new AuraHandledException('Insufficient access to update registrations.');
            }
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
