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
        upsert registrationRecord;
    }

    public static void upsertRegistrations(List<Registration_SCH__c> registrationRecords) {
        if (registrationRecords == null || registrationRecords.isEmpty()) {
            return;
        }
        upsert registrationRecords;
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
}