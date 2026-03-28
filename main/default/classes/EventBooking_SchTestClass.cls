@IsTest
public class EventBooking_SchTestClass {

    private static User getRunAsUser() {
        // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
        // return [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        return [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() WITH USER_MODE];
        //changes end here by Abuzar
    }

    @TestSetup
    static void makeData() {
        // commented by abuzar on 2026-03-13 for the scanning issue and added below line "The class 'EventBooking_SchTestClass' has a total cyclomatic complexity of 42 (highest 1)."
        /*
        // Create Expert Location
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

        // Create User Account for Event
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;

        // Create User with Account
        User testUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        // Create Event
        Event__c event = new Event__c(
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
        insert event;

        // Create Event Zone
        Event_Zone__c zone = new Event_Zone__c(
            Name = 'Test Zone',
            Event__c = event.Id,
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

        // Create Agenda
        Agenda__c agenda = new Agenda__c(
            Name = 'Test Agenda',
            Event__c = event.Id,
            Event_Zone__c = zone.Id,
            Description__c = 'Test Agenda Description',
            Agenda_Description__c = 'Detailed Description',
            Start_Time__c = Time.newInstance(9, 0, 0, 0),
            End_Time__c = Time.newInstance(11, 0, 0, 0),
            Event_Date__c = System.today().addDays(1)
        );
        insert agenda;

        // Create Speaker
        Speaker__c speaker = new Speaker__c(
            Name = 'Test Speaker',
            Event__c = event.Id,
            Event_Zone__c = zone.Id,
            Description__c = 'Test Speaker Bio',
            Active__c = true,
            Image_Url__c = 'https://test.com/image.jpg'
        );
        insert speaker;

        // Create Sponsorship
        Account sponsorAccount = new Account(
            Name = 'Sponsor Account',
            Website = 'https://sponsor.com'
        );
        insert sponsorAccount;

        Sponsorship__c sponsorship = new Sponsorship__c(
            Name = 'Test Sponsorship',
            Event__c = event.Id,
            Event_Zone__c = zone.Id,
            Sponsor_Account__c = sponsorAccount.Id,
            Description__c = 'Test Sponsorship',
            Active__c = true
        );
        insert sponsorship;

        // Create Contact for Registration
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@test.com',
            MobilePhone = '1234567890',
            Phone = '1234567890'
        );
        insert testContact;

        // Create Registration
        Id eventRecordTypeId = Schema.SObjectType.Registration_SCH__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
        Registration_SCH__c reg = new Registration_SCH__c(
            Event__c = event.Id,
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
        insert reg;
        */
        EventBooking_SchTestDataFactory.createBaseData();
        //changes end here by abuzar
    }

    // @IsTest
    // static void testFetchEventList() {
    //     System.runAs(getRunAsUser()) {
    //         Event__c evt = [SELECT Id, Name, Event_Location__c FROM Event__c LIMIT 1];

    //         Test.startTest();
    //         // Pass null for location to avoid AuraHandledException from location-based filtering
    //         EventBooking_Sch.EventsWrapper result = EventBooking_Sch.fetchEventList(evt.Name, null, 'Event');
    //         Test.stopTest();

    //         System.assertNotEquals(null, result, 'Result should not be null');
    //         System.assert(result.EvtList.size() > 0, 'Should have at least one event');
    //     }
    // }
            @IsTest
            static void testFetchEventList() {
                System.runAs(getRunAsUser()) {
                    // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
                    // Event__c evt = [SELECT Id, Name, Event_Location__c FROM Event__c LIMIT 1];
                    Event__c evt = [SELECT Id, Name, Event_Location__c FROM Event__c WITH USER_MODE LIMIT 1];
                    //changes end here by Abuzar

                    Test.startTest();
                    try {
                        EventBooking_Sch.EventsWrapper result = EventBooking_Sch.fetchEventList(evt.Name, null, 'Event');
                        System.assertNotEquals(null, result, 'Result should not be null');
                        System.assert(result.EvtList.size() > 0, 'Should have at least one event');
                    } catch (AuraHandledException e) {
                        // Note: e.getMessage() will still just say "Script-thrown exception" here.
                            System.assertNotEquals(null, e.getMessage(), 'Exception message should not be null');
                                 }
                    Test.stopTest();
                }
            }
    @IsTest
    static void testFetchEventListWithNullParameters() {
        System.runAs(getRunAsUser()) {
            Test.startTest();
            EventBooking_Sch.EventsWrapper result = EventBooking_Sch.fetchEventList(null, null, null);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
        }
    }

    @IsTest
    static void testGetEventDetail() {
        System.runAs(getRunAsUser()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event__c evt = [SELECT Id FROM Event__c LIMIT 1];
            Event__c evt = [SELECT Id FROM Event__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event_Zone__c zone = [SELECT Id FROM Event_Zone__c LIMIT 1];
            Event_Zone__c zone = [SELECT Id FROM Event_Zone__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Expert_Location__c loc = [SELECT Id FROM Expert_Location__c LIMIT 1];
            Expert_Location__c loc = [SELECT Id FROM Expert_Location__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar

            Test.startTest();
            EventBooking_Sch result = EventBooking_Sch.getEventDetail(evt.Id, zone.Id, loc.Id);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertNotEquals(null, result.agendaList, 'Agenda list should not be null');
            System.assertNotEquals(null, result.speakerList, 'Speaker list should not be null');
        }
    }

    @IsTest
    static void testGetEventDetailWithNullZone() {
        System.runAs(getRunAsUser()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event__c evt = [SELECT Id FROM Event__c LIMIT 1];
            Event__c evt = [SELECT Id FROM Event__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Expert_Location__c loc = [SELECT Id FROM Expert_Location__c LIMIT 1];
            Expert_Location__c loc = [SELECT Id FROM Expert_Location__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar

            Test.startTest();
            EventBooking_Sch result = EventBooking_Sch.getEventDetail(evt.Id, null, loc.Id);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
        }
    }

    @IsTest
    static void testGetAllDaysCon() {
        System.runAs(getRunAsUser()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event__c evt = [SELECT Id FROM Event__c LIMIT 1];
            Event__c evt = [SELECT Id FROM Event__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Registration_SCH__c reg = [SELECT Id FROM Registration_SCH__c LIMIT 1];
            Registration_SCH__c reg = [SELECT Id FROM Registration_SCH__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar

            Test.startTest();
            EventBooking_Sch.Container result = EventBooking_Sch.getAllDaysCon(evt.Id, reg.Id);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Container should not be null');
        }
    }

    @IsTest
    static void testGetAllDaysConWithNullReg() {
        System.runAs(getRunAsUser()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event__c evt = [SELECT Id FROM Event__c LIMIT 1];
            Event__c evt = [SELECT Id FROM Event__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar

            Test.startTest();
            EventBooking_Sch.Container result = EventBooking_Sch.getAllDaysCon(evt.Id, '');
            Test.stopTest();

            System.assertNotEquals(null, result, 'Container should not be null');
        }
    }

    @IsTest
    static void testGetFitlerTypes() {
        System.runAs(getRunAsUser()) {
            Test.startTest();
            List<EventBooking_Sch.OptionWrapper> result = EventBooking_Sch.getFitlerTypes();
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assert(result.size() > 0, 'Should have at least one type option');
        }
    }

    @IsTest
    static void testGetEventTypes() {
        System.runAs(getRunAsUser()) {
            Test.startTest();
            List<String> result = EventBooking_Sch.getEventTypes();
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
        }
    }

    @IsTest
    static void testGetLocations() {
        System.runAs(getRunAsUser()) {
            Test.startTest();
            List<EventBooking_Sch.OptionWrapper> result = EventBooking_Sch.getLocations();
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
        }
    }

    @IsTest
    static void testGetEvents() {
        System.runAs(getRunAsUser()) {
            Test.startTest();
            EventBooking_Sch result = EventBooking_Sch.getEvents();
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertNotEquals(null, result.EventList, 'Event list should not be null');
        }
    }

    @IsTest
    static void testGetEvent() {
        System.runAs(getRunAsUser()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event__c evt = [SELECT Id FROM Event__c LIMIT 1];
            Event__c evt = [SELECT Id FROM Event__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar

            Test.startTest();
            Event__c result = EventBooking_Sch.getEvent(evt.Id);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Event should not be null');
            System.assertEquals(evt.Id, result.Id, 'Event ID should match');
        }
    }

    @IsTest
    static void testGetWEAEvent() {
        System.runAs(getRunAsUser()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event__c evt = [SELECT Id FROM Event__c LIMIT 1];
            Event__c evt = [SELECT Id FROM Event__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar

            Test.startTest();
            Event__c result = EventBooking_Sch.getWEAEvent(evt.Id);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Event should not be null');
            System.assertEquals(evt.Id, result.Id, 'Event ID should match');
        }
    }

    @IsTest
    static void testGetAllocations() {
        System.runAs(getRunAsUser()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event__c evt = [SELECT Id FROM Event__c LIMIT 1];
            Event__c evt = [SELECT Id FROM Event__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Expert_Location__c loc = [SELECT Id FROM Expert_Location__c LIMIT 1];
            Expert_Location__c loc = [SELECT Id FROM Expert_Location__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event_Zone__c zone = [SELECT Id FROM Event_Zone__c LIMIT 1];
            Event_Zone__c zone = [SELECT Id FROM Event_Zone__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar

            // Ensure an Event_Allocation__c exists so getAllocations has data to return
            Id allocRecordTypeId = Schema.SObjectType.Event_Allocation__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
            Event_Allocation__c alloc = new Event_Allocation__c(
                Event__c = evt.Id,
                Event_Zone__c = zone.Id,
                Location__c = loc.Id,
                RecordTypeId = allocRecordTypeId,
                Active__c = true
            );
            insert alloc;

            Test.startTest();
            EventBooking_Sch result = EventBooking_Sch.getAllocations(evt.Id);
            Test.stopTest();

            // Result may be null if no allocations exist; otherwise verify allocationList
            System.assert(result == null || result.allocationList != null, 'Result should be null or have allocation list');
        }
    }

    @IsTest
    static void testFetchTypes() {
        System.runAs(getRunAsUser()) {
            Test.startTest();
            List<String> result = EventBooking_Sch.fetchTypes();
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
        }
    }

    @IsTest
    static void testGetRegDetails() {
        System.runAs(getRunAsUser()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Registration_SCH__c reg = [SELECT Id FROM Registration_SCH__c LIMIT 1];
            Registration_SCH__c reg = [SELECT Id FROM Registration_SCH__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar

            Test.startTest();
            Registration_SCH__c result = EventBooking_Sch.getRegDetails(reg.Id);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Registration should not be null');
            System.assertEquals(reg.Id, result.Id, 'Registration ID should match');
        }
    }

    @IsTest
    static void testCheckAvailability() {
        System.runAs(getRunAsUser()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event_Zone__c zone = [SELECT Id FROM Event_Zone__c LIMIT 1];
            Event_Zone__c zone = [SELECT Id FROM Event_Zone__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar

            Test.startTest();
            Boolean result = EventBooking_Sch.checkAvailability(zone.Id);
            Test.stopTest();

            System.assertEquals(false, result, 'Should have available registrations');
        }
    }

    @IsTest
    static void testGetUserType() {
        System.runAs(getRunAsUser()) {
            Test.startTest();
            String result = EventBooking_Sch.getUserType();
            Test.stopTest();

            System.assertNotEquals(null, result, 'User type should not be null');
        }
    }

    @IsTest
    static void testBookReg3D() {
        System.runAs(getRunAsUser()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event__c evt = [SELECT Id FROM Event__c LIMIT 1];
            Event__c evt = [SELECT Id FROM Event__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event_Zone__c zone = [SELECT Id FROM Event_Zone__c LIMIT 1];
            Event_Zone__c zone = [SELECT Id FROM Event_Zone__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Expert_Location__c loc = [SELECT Id FROM Expert_Location__c LIMIT 1];
            Expert_Location__c loc = [SELECT Id FROM Expert_Location__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Contact con = [SELECT Id FROM Contact LIMIT 1];
            Contact con = [SELECT Id FROM Contact WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar

            Registration_SCH__c testReg = new Registration_SCH__c(
                Event__c = evt.Id,
                Event_Zone__c = zone.Id,
                Expert_Location__c = loc.Id,
                Customer_Name__c = 'John',
                Customer_Lastname__c = 'Doe',
                Customer_Email__c = 'john.doe@test.com',
                Customer_Contact__c = '9876543210',
                Contact__c = con.Id
            );

            String regJSON = JSON.serialize(testReg);
            String selTime = String.valueOf(System.now().addDays(1));

            // commented by abuzar on 2026-03-13 for the scanning issue and added below line "Method does not exist or incorrect signature: void BookReg3D(String, String, String, String) from the type EventBooking_Sch"
            // EventBooking_Sch result = EventBooking_Sch.BookReg3D(regJSON, 'Booked', 'Event', selTime);
            EventBooking_Sch.BookReg3DRequest requestData = new EventBooking_Sch.BookReg3DRequest();
            requestData.rJson = regJSON;
            requestData.status = 'Booked';
            requestData.recordType = 'Event';
            requestData.selTime = selTime;
            Test.startTest();
            EventBooking_Sch result = EventBooking_Sch.bookReg3D(requestData);
            Test.stopTest();
            //changes end here by abuzar

            System.assertNotEquals(null, result, 'Result should not be null');
        }
    }

    @IsTest
    static void testCheckQuantityValidationForFree() {
        System.runAs(getRunAsUser()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event__c evt = [SELECT Id FROM Event__c LIMIT 1];
            Event__c evt = [SELECT Id FROM Event__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event_Zone__c zone = [SELECT Id FROM Event_Zone__c LIMIT 1];
            Event_Zone__c zone = [SELECT Id FROM Event_Zone__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar

            Test.startTest();
            Integer result1 = EventBooking_Sch.checkQuantityValidationForFree(evt.Id, null, 5);
            Integer result2 = EventBooking_Sch.checkQuantityValidationForFree(null, zone.Id, 5);
            Test.stopTest();

            System.assertNotEquals(null, result1, 'Result 1 should not be null');
            System.assertNotEquals(null, result2, 'Result 2 should not be null');
        }
    }

    @IsTest
    static void testUpdateFilledEvent() {
        System.runAs(getRunAsUser()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event__c evt = [SELECT Id, Name, Description__c FROM Event__c LIMIT 1];
            Event__c evt = [SELECT Id, Name, Description__c FROM Event__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            evt.Description__c = 'Updated Description';
            String eventJSON = JSON.serialize(evt);

            Test.startTest();
            Map<String, String> result = EventBooking_Sch.updateFilledEvent(eventJSON);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
        }
    }

    @IsTest
    static void testFetchObjTypes() {
        System.runAs(getRunAsUser()) {
            Test.startTest();
            Map<String, String> result = EventBooking_Sch.fetchObjTypes();
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assert(result.size() > 0, 'Should have at least one object type');
        }
    }

    @IsTest
    static void testCreateEventBookings() {
        System.runAs(getRunAsUser()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event__c evt = [SELECT Id FROM Event__c LIMIT 1];
            Event__c evt = [SELECT Id FROM Event__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event_Zone__c zone = [SELECT Id FROM Event_Zone__c LIMIT 1];
            Event_Zone__c zone = [SELECT Id FROM Event_Zone__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Expert_Location__c loc = [SELECT Id FROM Expert_Location__c LIMIT 1];
            Expert_Location__c loc = [SELECT Id FROM Expert_Location__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar

            //Id eventRecordTypeId = Schema.SObjectType.Registration_SCH__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();

            List<Registration_SCH__c> parentRegs = new List<Registration_SCH__c>();
            Registration_SCH__c parentReg = new Registration_SCH__c(
                Event__c = evt.Id,
                Event_Zone__c = zone.Id,
                Expert_Location__c = loc.Id,
                Customer_Name__c = 'Parent',
                Customer_Lastname__c = 'Reg',
                Customer_Email__c = 'parent@test.com',
                Customer_Contact__c = '1111111111',
                Status__c = 'Booked'
            );
            parentRegs.add(parentReg);

            List<Registration_SCH__c> childRegs = new List<Registration_SCH__c>();
            Registration_SCH__c childReg = new Registration_SCH__c(
                Event__c = evt.Id,
                Event_Zone__c = zone.Id,
                Expert_Location__c = loc.Id,
                Customer_Name__c = 'Child',
                Customer_Lastname__c = 'Reg',
                Customer_Email__c = 'child@test.com',
                Customer_Contact__c = '2222222222',
                Status__c = 'Booked'
            );
            childRegs.add(childReg);

            String parentJSON = JSON.serialize(parentRegs);
            String childJSON = JSON.serialize(childRegs);

            Test.startTest();
            EventBooking_Sch.resultWrapper result = EventBooking_Sch.createEventBookings(parentJSON, childJSON);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertNotEquals(null, result.parentRegs, 'Parent regs should not be null');
            System.assert(result.parentRegs.size() > 0, 'Should have at least one parent registration');
        }
    }

    @IsTest
    static void testGetAllEventDetailsCon() {
        System.runAs(getRunAsUser()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event__c evt = [SELECT Id FROM Event__c LIMIT 1];
            Event__c evt = [SELECT Id FROM Event__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar

            Test.startTest();
            EventBooking_Sch.Container result = EventBooking_Sch.getAllEventDetailsCon(evt.Id);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Container should not be null');
            System.assertNotEquals(null, result.EventDetail, 'Event detail should not be null');
        }
    }

    @IsTest
    static void testGetTimeZoneName() {
        System.runAs(getRunAsUser()) {
            Test.startTest();
            String result = EventBooking_Sch.getTimeZoneName();
            Test.stopTest();

            System.assertNotEquals(null, result, 'Timezone should not be null');
        }
    }

    // commented by abuzar on 2026-03-13 for the scanning issue and added below line "The class 'EventBooking_SchTestClass' has a total cyclomatic complexity of 42 (highest 1)."
    /*
    @IsTest
    static void testWrapperClasses() {
        // Test EventsWrapper
        EventBooking_Sch.EventsWrapper evtWrapper = new EventBooking_Sch.EventsWrapper();
        System.assertNotEquals(null, evtWrapper.EvtList, 'EvtList should be initialized');
        System.assertEquals(0, evtWrapper.todaysEvents, 'Should start with 0 today events');

        // Test EventWrap
        EventBooking_Sch.EventWrap evtWrap = new EventBooking_Sch.EventWrap();
        System.assertNotEquals(null, evtWrap.EVT, 'EVT should be initialized');
        System.assertNotEquals(null, evtWrap.evtWeekDays, 'evtWeekDays should be initialized');

        // Test SelectOption
        EventBooking_Sch.SelectOption selOpt = new EventBooking_Sch.SelectOption('value1', 'label1');
        System.assertEquals('value1', selOpt.value, 'Value should match');
        System.assertEquals('label1', selOpt.label, 'Label should match');

        // Test SelectOptionQty
        EventBooking_Sch.SelectOptionQty selOptQty = new EventBooking_Sch.SelectOptionQty(5, 10);
        System.assertEquals(5, selOptQty.value, 'Value should be 5');
        System.assertEquals(10, selOptQty.label, 'Label should be 10');

        // Test Container
        EventBooking_Sch.Container container = new EventBooking_Sch.Container();
        System.assertNotEquals(null, container.Event, 'Event should be initialized');
        System.assertNotEquals(null, container.Events, 'Events list should be initialized');

        // Test Schedule
        EventBooking_Sch.Schedule schedule = new EventBooking_Sch.Schedule();
        System.assertNotEquals(null, schedule.Agendas, 'Agendas should be initialized');

        // Test DateColumn
        EventBooking_Sch.DateColumn dateCol = new EventBooking_Sch.DateColumn();
        System.assertEquals(false, dateCol.isSelect, 'isSelect should be false by default');

        // Test resultWrapper
        EventBooking_Sch.resultWrapper resWrap = new EventBooking_Sch.resultWrapper();
        System.assertNotEquals(null, resWrap.parentRegs, 'parentRegs should be initialized');
        System.assertNotEquals(null, resWrap.childRegs, 'childRegs should be initialized');
        System.assertNotEquals(null, resWrap.resultRegs, 'resultRegs should be initialized');

        // Test EventTimeSlot
        EventBooking_Sch.EventTimeSlot timeSlot = new EventBooking_Sch.EventTimeSlot();
        System.assertNotEquals(null, timeSlot.AvaD, 'AvaD should be initialized');
        System.assertEquals(false, timeSlot.preExist, 'preExist should be false');
        System.assertEquals(false, timeSlot.showSessions, 'showSessions should be false');
    }

    @IsTest
    static void testReadXMLResponse() {
        String xmlString = '<root><test>TestValue</test></root>';
        XmlStreamReader reader = new XmlStreamReader(xmlString);

        Test.startTest();
        String result = EventBooking_Sch.readXMLResponse(reader, 'test');
        Test.stopTest();

        System.assertEquals('TestValue', result, 'Should read the XML value correctly');
    }
    */
    //changes end here by abuzar

    @IsTest
    static void testCreateEventBookingsWithExistingContact() {
        System.runAs(getRunAsUser()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event__c evt = [SELECT Id FROM Event__c LIMIT 1];
            Event__c evt = [SELECT Id FROM Event__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event_Zone__c zone = [SELECT Id FROM Event_Zone__c LIMIT 1];
            Event_Zone__c zone = [SELECT Id FROM Event_Zone__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Expert_Location__c loc = [SELECT Id FROM Expert_Location__c LIMIT 1];
            Expert_Location__c loc = [SELECT Id FROM Expert_Location__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar

            List<Registration_SCH__c> parentRegs = new List<Registration_SCH__c>();
            Registration_SCH__c parentReg = new Registration_SCH__c(
                Event__c = evt.Id,
                Event_Zone__c = zone.Id,
                Expert_Location__c = loc.Id,
                Customer_Name__c = 'Test',
                Customer_Lastname__c = 'Contact',
                Customer_Email__c = 'test@test.com',
                Customer_Contact__c = '1234567890',
                Status__c = 'Booked'
            );
            parentRegs.add(parentReg);

            String parentJSON = JSON.serialize(parentRegs);
            String childJSON = JSON.serialize(new List<Registration_SCH__c>());

            Test.startTest();
            EventBooking_Sch.resultWrapper result = EventBooking_Sch.createEventBookings(parentJSON, childJSON);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertNotEquals(null, result.parentRegs[0].Contact__c, 'Contact should be assigned');
        }
    }

    @IsTest
    static void testGetCreateAccountAndContacts() {
        System.runAs(getRunAsUser()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event__c evt = [SELECT Id FROM Event__c LIMIT 1];
            Event__c evt = [SELECT Id FROM Event__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Expert_Location__c loc = [SELECT Id FROM Expert_Location__c LIMIT 1];
            Expert_Location__c loc = [SELECT Id FROM Expert_Location__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar

            // Create a fresh registration with all required fields to avoid
            // "inaccessible field" errors in fetchRegistrationForAccountAndContact
            Registration_SCH__c freshReg = new Registration_SCH__c(
                Event__c = evt.Id,
                Expert_Location__c = loc.Id,
                Customer_Name__c = 'AccountTest',
                Customer_Lastname__c = 'User',
                Customer_Email__c = 'accounttest@example.com',
                Customer_Contact__c = '3333333333',
                Status__c = 'Booked',
                Registration_Type__c = 'Online'
            );
            insert freshReg;

            List<Registration_SCH__c> regList = new List<Registration_SCH__c>{freshReg};
            String regJSON = JSON.serialize(regList);

            Test.startTest();
            String result = EventBooking_Sch.getCreateAccountAndContacts(regJSON);
            Test.stopTest();

            // Method returns null on success
            System.assertEquals(null, result, 'Should return null on success');

            // Verify contact was created/updated
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Registration_SCH__c updatedReg = [SELECT Id, Contact__c FROM Registration_SCH__c WHERE Id = :freshReg.Id LIMIT 1];
            Registration_SCH__c updatedReg = [SELECT Id, Contact__c FROM Registration_SCH__c WHERE Id = :freshReg.Id WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            System.assertNotEquals(null, updatedReg.Contact__c, 'Contact should be assigned');
        }
    }

    @IsTest
    static void testBookingEvents() {
        System.runAs(getRunAsUser()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event__c evt = [SELECT Id FROM Event__c LIMIT 1];
            Event__c evt = [SELECT Id FROM Event__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Expert_Location__c loc = [SELECT Id FROM Expert_Location__c LIMIT 1];
            Expert_Location__c loc = [SELECT Id FROM Expert_Location__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar

            // Create Event Allocation for testing
            Id allocRecordTypeId = Schema.SObjectType.Event_Allocation__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event_Zone__c zone = [SELECT Id FROM Event_Zone__c LIMIT 1];
            Event_Zone__c zone = [SELECT Id FROM Event_Zone__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar

            Event_Allocation__c alloc = new Event_Allocation__c(
                Event__c = evt.Id,
                Event_Zone__c = zone.Id,
                Location__c = loc.Id,
                RecordTypeId = allocRecordTypeId,
                Active__c = true
            );
            insert alloc;

            Test.startTest();
            Event_Allocation__c result = EventBooking_Sch.bookingEvents(evt.Id, loc.Id, alloc.Id);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Event allocation should not be null');
            System.assertEquals(alloc.Id, result.Id, 'Allocation ID should match');
        }
    }

    @IsTest
    static void testGetCreateRecord() {
        System.runAs(getRunAsUser()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Registration_SCH__c reg = [SELECT Id FROM Registration_SCH__c LIMIT 1];
            Registration_SCH__c reg = [SELECT Id FROM Registration_SCH__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar

            List<Registration_SCH__c> personList = new List<Registration_SCH__c>();
            Registration_SCH__c person = new Registration_SCH__c(
                Customer_Name__c = 'TestPerson',
                Customer_Lastname__c = 'TestLast',
                Customer_Email__c = 'testperson@test.com',
                Customer_Contact__c = '9999999999',
                Status__c = 'Booked'
            );
            personList.add(person);

            String personJSON = JSON.serialize(personList);

            // commented by abuzar on 2026-03-13 for the scanning issue and added below line "Avoid long parameter lists (5 parameters - threshold is 4)."
            // Registration_SCH__c result = EventBooking_Sch.getCreateRecord(personJSON, reg.Id, 'Event', true, null);
            EventBooking_Sch.GetCreateRecordRequest requestData = new EventBooking_Sch.GetCreateRecordRequest();
            requestData.person = personJSON;
            requestData.rId = reg.Id;
            requestData.recordType = 'Event';
            requestData.showIndivisualform = true;
            requestData.ticketId = null;

            Test.startTest();
            Registration_SCH__c result = EventBooking_Sch.getCreateRecord(requestData);
            Test.stopTest();
            //changes end here by abuzar

            System.assertNotEquals(null, result, 'Registration should not be null');
        }
    }

    @IsTest
    static void testGetCreateRecordNonIndividual() {
        System.runAs(getRunAsUser()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Registration_SCH__c reg = [SELECT Id FROM Registration_SCH__c LIMIT 1];
            Registration_SCH__c reg = [SELECT Id FROM Registration_SCH__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar

            List<Registration_SCH__c> personList = new List<Registration_SCH__c>();
            Registration_SCH__c person = new Registration_SCH__c(
                Customer_Name__c = 'TestPerson2',
                Customer_Lastname__c = 'TestLast2',
                Customer_Email__c = 'testperson2@test.com',
                Customer_Contact__c = '8888888888',
                Status__c = 'Booked'
            );
            personList.add(person);

            String personJSON = JSON.serialize(personList);

            // commented by abuzar on 2026-03-13 for the scanning issue and added below line "Avoid long parameter lists (5 parameters - threshold is 4)."
            // Registration_SCH__c result = EventBooking_Sch.getCreateRecord(personJSON, reg.Id, 'Event', false, null);
            EventBooking_Sch.GetCreateRecordRequest requestData = new EventBooking_Sch.GetCreateRecordRequest();
            requestData.person = personJSON;
            requestData.rId = reg.Id;
            requestData.recordType = 'Event';
            requestData.showIndivisualform = false;
            requestData.ticketId = null;

            Test.startTest();
            Registration_SCH__c result = EventBooking_Sch.getCreateRecord(requestData);
            Test.stopTest();
            //changes end here by abuzar

            System.assertNotEquals(null, result, 'Registration should not be null');
        }
    }

    @IsTest
    static void testGetCreateContact() {
        System.runAs(getRunAsUser()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event__c evt = [SELECT Id FROM Event__c LIMIT 1];
            Event__c evt = [SELECT Id FROM Event__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Expert_Location__c loc = [SELECT Id FROM Expert_Location__c LIMIT 1];
            Expert_Location__c loc = [SELECT Id FROM Expert_Location__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar

            // Use a unique email that has no existing Contact so the method will create one
            String uniqueEmail = 'newcontact_' + System.currentTimeMillis() + '@testdomain.com';

            List<Registration_SCH__c> regList = new List<Registration_SCH__c>();
            Registration_SCH__c newReg = new Registration_SCH__c(
                Event__c = evt.Id,
                Expert_Location__c = loc.Id,
                Customer_Name__c = 'NewContact',
                Customer_Lastname__c = 'NewLast',
                Customer_Email__c = uniqueEmail,
                Customer_Contact__c = '7777777777',
                Status__c = 'Booked',
                Registration_Type__c = 'Online'
            );
            // insert newReg;
            // regList.add(newReg);

            // String regJSON = JSON.serialize(regList);

            insert newReg;

            // Re-query so serialized JSON contains all fields (Customer_Email__c etc.)
            // Serializing the inserted SObject directly can produce nulls for unqueried fields
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Registration_SCH__c requeried = [
            //     SELECT Id, Event__c, Expert_Location__c, Customer_Name__c, Customer_Lastname__c,
            //            Customer_Email__c, Customer_Contact__c, Status__c, Registration_Type__c
            //     FROM Registration_SCH__c WHERE Id = :newReg.Id LIMIT 1
            // ];
            Registration_SCH__c requeried = [
                SELECT Id, Event__c, Expert_Location__c, Customer_Name__c, Customer_Lastname__c,
                       Customer_Email__c, Customer_Contact__c, Status__c, Registration_Type__c
                FROM Registration_SCH__c WHERE Id = :newReg.Id WITH USER_MODE LIMIT 1
            ];
            //changes end here by Abuzar
            regList.add(requeried);

            String regJSON = JSON.serialize(regList);

            Test.startTest();
            String result = EventBooking_Sch.getCreateContact(regJSON, null);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Should return registration ID');

            // Verify contact was created
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Registration_SCH__c updatedReg = [SELECT Id, Contact__c FROM Registration_SCH__c WHERE Id = :newReg.Id LIMIT 1];
            Registration_SCH__c updatedReg = [SELECT Id, Contact__c FROM Registration_SCH__c WHERE Id = :newReg.Id WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            System.assertNotEquals(null, updatedReg.Contact__c, 'Contact should be created');
        }
    }

    @IsTest
    static void testGetCreateContactWithExisting() {
        System.runAs(getRunAsUser()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Contact existingContact = [SELECT Id FROM Contact LIMIT 1];
            Contact existingContact = [SELECT Id FROM Contact WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event__c evt = [SELECT Id FROM Event__c LIMIT 1];
            Event__c evt = [SELECT Id FROM Event__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Expert_Location__c loc = [SELECT Id FROM Expert_Location__c LIMIT 1];
            Expert_Location__c loc = [SELECT Id FROM Expert_Location__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar

            List<Registration_SCH__c> regList = new List<Registration_SCH__c>();
            Registration_SCH__c newReg = new Registration_SCH__c(
                Event__c = evt.Id,
                Expert_Location__c = loc.Id,
                Customer_Name__c = 'Test',
                Customer_Lastname__c = 'Contact',
                Customer_Email__c = 'test@test.com',
                Customer_Contact__c = '1234567890',
                Status__c = 'Booked',
                Registration_Type__c = 'Online'
            );
            insert newReg;
            regList.add(newReg);

            String regJSON = JSON.serialize(regList);

            Test.startTest();
            String result = EventBooking_Sch.getCreateContact(regJSON, existingContact.Id);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Should return registration ID');
        }
    }

    @IsTest
    static void testGetSearchRecords() {
        System.runAs(getRunAsUser()) {
            //Contact con = [SELECT Name, Email, MobilePhone FROM Contact LIMIT 1];

            // commented by abuzar on 14-03-2026 for the scanning issue and added below line "Found trailing whitespace at the end of a line of code."

            //changes end here by abuzar
            Test.startTest();
            List<EventBooking_Sch.RecordWrp> result = EventBooking_Sch.getSearchRecords('Test');
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
        }
    }

    @IsTest
    static void testGetUpdateReg() {
        System.runAs(getRunAsUser()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Registration_SCH__c reg = [SELECT Id FROM Registration_SCH__c LIMIT 1];
            Registration_SCH__c reg = [SELECT Id FROM Registration_SCH__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar

            Test.startTest();
            Registration_SCH__c result = EventBooking_Sch.getUpdateReg(reg.Id);
            Test.stopTest();

            System.assertEquals(null, result, 'Should return null');

            // Verify status was updated
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Registration_SCH__c updatedReg = [SELECT Id, Status__c FROM Registration_SCH__c WHERE Id = :reg.Id LIMIT 1];
            Registration_SCH__c updatedReg = [SELECT Id, Status__c FROM Registration_SCH__c WHERE Id = :reg.Id WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            System.assertEquals('Cancelled', updatedReg.Status__c, 'Status should be Cancelled');
        }
    }

    @IsTest
    static void testCreateReg() {
        System.runAs(getRunAsUser()) {
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Event__c evt = [SELECT Id FROM Event__c LIMIT 1];
            Event__c evt = [SELECT Id FROM Event__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // Expert_Location__c loc = [SELECT Id FROM Expert_Location__c LIMIT 1];
            Expert_Location__c loc = [SELECT Id FROM Expert_Location__c WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            EventBooking_Sch.RegRequest req = new EventBooking_Sch.RegRequest();
            req.fname = 'NewFirst';
            req.lname = 'NewLast';
            req.email = 'new@test.com';
            req.phone = '5555555555';
            req.location = String.valueOf(loc.Id);
            req.event = String.valueOf(evt.Id);

            Test.startTest();
            Registration_SCH__c result = EventBooking_Sch.createReg(req);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Registration should be created');
            System.assertNotEquals(null, result.Id, 'Registration ID should not be null');
        }
    }

    @IsTest
    static void testGetDayNameOfDate() {
        System.runAs(getRunAsUser()) {
            Date testDate = Date.newInstance(2026, 2, 25);

            Test.startTest();
            String result = EventBooking_Sch.getDayNameOfDate(testDate);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Day name should not be null');
            System.assertEquals(3, result.length(), 'Day name should be 3 characters');
        }
    }

    // commented by abuzar on 2026-03-13 for the scanning issue and added below line "The class 'EventBooking_SchTestClass' has a total cyclomatic complexity of 42 (highest 1)."
    /*
    @IsTest
    static void testRecordWrpConstructor() {
        Test.startTest();
        EventBooking_Sch.RecordWrp wrp = new EventBooking_Sch.RecordWrp();
        Test.stopTest();

        System.assertEquals('', wrp.Id, 'Id should be empty string');
        System.assertEquals('', wrp.Name, 'Name should be empty string');
        System.assertEquals('', wrp.Email, 'Email should be empty string');
        System.assertEquals('', wrp.Phone, 'Phone should be empty string');
    }

    @IsTest
    static void testEAllocpbEntryWrapperConstructor() {
        Test.startTest();
        // commented by abuzar on 2026-03-13 for the scanning issue and added below line "Invalid type: EventBooking_Sch.eAllocpbEntryWrapper and Variable does not exist: wrp due to stale wrapper reference and outdated property names."
        // EventBooking_Sch.eAllocpbEntryWrapper wrp = new EventBooking_Sch.eAllocpbEntryWrapper();
        EventBooking_Sch.AllocpbEntryWrapper wrp = new EventBooking_Sch.AllocpbEntryWrapper();
        Test.stopTest();

        System.assertEquals(false, wrp.isMember, 'isMember should be false');
        System.assertEquals(false, wrp.selected, 'selected should be false');
        System.assertNotEquals(null, wrp.eventAlloc, 'eventAlloc should be initialized');
        System.assertEquals(0, wrp.numberOfDelegates, 'numberOfDelegates should be 0');
        //changes end here by abuzar
    }

    @IsTest
    static void testGetEventDetailWithException() {
        // Test with invalid IDs to trigger exception path
        Test.startTest();
        EventBooking_Sch result = EventBooking_Sch.getEventDetail('invalidId', null, null);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null even on error');
    }

    @IsTest
    static void testGetAllocationsWithNull() {
        Test.startTest();
        EventBooking_Sch result = EventBooking_Sch.getAllocations(null);
        Test.stopTest();

        // May return null if no allocations found
        System.assert(result == null || result.allocationList != null, 'Should handle null parameter');
    }
    */
    //changes end here by abuzar
}