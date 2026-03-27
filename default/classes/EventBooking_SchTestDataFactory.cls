/**
 * @description Test data factory for event booking scheduler Apex tests.
 */
@IsTest
public class EventBooking_SchTestDataFactory {
    /**
     * @description Creates base event-booking test data including location, event,
     * zone, agenda, speaker, sponsorship, contact, and registration records.
     */
    public static void createBaseData() {
        Expert_Location__c loc = new Expert_Location__c(
            Name = 'Test Location',
            Address__c = '123 Test St',
            City__c = 'Test City',
            Province_State__c = 'Test State',
            Zip_Code__c = '12345',
            Country__c = 'Test Country',
            Active__c = true,
            Show_Experts__c = true
        );
        insert loc;

        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;

        User testUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        Event__c eventRecord = new Event__c(
            Name = 'Test Event',
            Event_Location__c = loc.Id,
            Event_Type__c = 'Event',
            Type_Of_Event__c = 'Conference',
            Event_Status__c = 'Active',
            Start_Date__c = System.now().addDays(1),
            End_Date__c = System.now().addDays(2),
            Registration_Start_Date__c = System.now().addDays(-5),
            Registration_End_Date__c = System.now().addDays(5),
            Week_Days__c = 'Mon;Tue;Wed',
            Active__c = true,
            User__c = testUser.Id,
            Description__c = 'Test Event Description',
            Maximum_Quantity_Select__c = 10,
            Allow_Guest_Registrations__c = true,
            Allow_override_duplicate_registration__c = true,
            Allow_Waiting_List__c = true,
            Instant_CheckIn__c = false
        );
        insert eventRecord;

        Event_Zone__c zone = new Event_Zone__c(
            Name = 'Test Zone',
            Event__c = eventRecord.Id,
            Event_Zone_Location__c = loc.Id,
            Status__c = 'Active',
            Start_Date__c = System.now().addDays(1),
            End_Date__c = System.now().addDays(2),
            Registration_Start_Date__c = System.now().addDays(-5),
            Registration_End_Date__c = System.now().addDays(5),
            Allow_Waiting_List__c = true,
            Show_Day_Slots__c = true
        );
        insert zone;

        Agenda__c agenda = new Agenda__c(
            Name = 'Test Agenda',
            Event__c = eventRecord.Id,
            Event_Zone__c = zone.Id,
            Description__c = 'Test Agenda Description',
            Agenda_Description__c = 'Detailed Description',
            Start_Time__c = Time.newInstance(9, 0, 0, 0),
            End_Time__c = Time.newInstance(11, 0, 0, 0),
            Event_Date__c = System.today().addDays(1)
        );
        insert agenda;

        Speaker__c speaker = new Speaker__c(
            Name = 'Test Speaker',
            Event__c = eventRecord.Id,
            Event_Zone__c = zone.Id,
            Description__c = 'Test Speaker Bio',
            Active__c = true,
            Image_Url__c = 'https://test.com/image.jpg'
        );
        insert speaker;

        Account sponsorAccount = new Account(
            Name = 'Sponsor Account',
            Website = 'https://sponsor.com'
        );
        insert sponsorAccount;

        Sponsorship__c sponsorship = new Sponsorship__c(
            Name = 'Test Sponsorship',
            Event__c = eventRecord.Id,
            Event_Zone__c = zone.Id,
            Sponsor_Account__c = sponsorAccount.Id,
            Description__c = 'Test Sponsorship',
            Active__c = true
        );
        insert sponsorship;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@test.com',
            MobilePhone = '1234567890',
            Phone = '1234567890'
        );
        insert testContact;

        Id eventRecordTypeId = Schema.SObjectType.Registration_SCH__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
        Registration_SCH__c registrationRecord = new Registration_SCH__c(
            Event__c = eventRecord.Id,
            Event_Zone__c = zone.Id,
            Expert_Location__c = loc.Id,
            Contact__c = testContact.Id,
            Customer_Name__c = 'Test',
            Customer_Lastname__c = 'Contact',
            Customer_Email__c = 'test@test.com',
            Customer_Contact__c = '1234567890',
            Status__c = 'Booked',
            Registration_Time__c = System.now(),
            End_Time__c = System.now().addHours(2),
            RecordTypeId = eventRecordTypeId,
            Registration_Type__c = 'Online'
        );
        insert registrationRecord;
    }
}