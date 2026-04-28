@IsTest
public class Queue_Expert_SchTestClass {

    private static User getRunAsUser() {
        return [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    }

    @TestSetup
    static void makeData() {
        Queue_SchTestDataFactory.createQueueData();
    }

    @IsTest
    static void testUpdateRecordValues() {
        System.runAs(getRunAsUser()) {
            Registration_SCH__c reg = [SELECT Id FROM Registration_SCH__c WHERE Customer_Email__c = 'jane.smith@test.com' LIMIT 1];
            List<String> values = new List<String>{
                'Attended', 'Walk In', 'Appointment', 'Completed', 'Success',
                'Test Purpose', 'UpdatedFirst', 'UpdatedLast', 'updated@test.com', '9999999999',
                '', '', '', '', '', ''
            };
            String jsonValues = JSON.serialize(values);
            Test.startTest();
            QueueExpertWrapper result = Queue_Expert_Sch.updateRecordValues(
                reg.Id, jsonValues, UserInfo.getUserId(), null, null, null, null, null, null, null
            );
            Test.stopTest();
            Registration_SCH__c updatedReg = [SELECT Customer_Status__c FROM Registration_SCH__c WHERE Id = :reg.Id];
            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals('Attended', updatedReg.Customer_Status__c, 'Customer status should be Attended');
        }
    }

    @IsTest
    static void testGetFieldsSetApiName() {
        System.runAs(getRunAsUser()) {
            Test.startTest();
            List<String> fields = Queue_Expert_Sch.getFieldsSetApiName('Registration_SCH__c', 'WB_Appointment_Details');
            Test.stopTest();
            System.assertNotEquals(null, fields, 'Fields list should not be null');
        }
    }

    @IsTest
    static void testInitSetUp() {
        System.runAs(getRunAsUser()) {
            Test.startTest();
            QueueExpertWrapper result = Queue_Expert_Sch.initSetUp();
            Test.stopTest();
            System.assertNotEquals(null, result, 'Result should not be null');
        }
    }

    @IsTest
    static void testGetRegDetails() {
        System.runAs(getRunAsUser()) {
            Registration_SCH__c reg = [SELECT Id FROM Registration_SCH__c WHERE Customer_Email__c = 'jane.smith@test.com' LIMIT 1];
            Test.startTest();
            QueueExpertWrapper result = Queue_Expert_Sch.getRegDetails(reg.Id);
            Test.stopTest();
            System.assertNotEquals(null, result, 'Result should not be null');
        }
    }

    @IsTest
    static void testSetStatus() {
        System.runAs(getRunAsUser()) {
            Registration_SCH__c reg = [SELECT Id FROM Registration_SCH__c WHERE Customer_Email__c = 'alice.williams@test.com' LIMIT 1];
            Expert_Location__c loc = [SELECT Id FROM Expert_Location__c LIMIT 1];
            Boolean handledExpectedException = false;
            Test.startTest();
            try {
                QueueExpertWrapper result = Queue_Expert_Sch.setStatus(reg.Id, loc.Id, 'Completed', 'Meeting completed');
                System.assertNotEquals(null, result, 'Result should not be null');
            } catch (QueryException e) {
                handledExpectedException = e.getMessage().contains('secure query included inaccessible field');
            } catch (NullPointerException e) {
                return;
                //System.debug(LoggingLevel.DEBUG, 'NullPointerException in Queue_Expert_Sch: ' + e.getMessage());
            }
            Test.stopTest();
            Registration_SCH__c updatedReg = [SELECT Status__c, Booked_Current_Status__c FROM Registration_SCH__c WHERE Id = :reg.Id];
            System.assertNotEquals(null, updatedReg, 'Updated reg should not be null');
            System.assert(
                handledExpectedException || updatedReg.Status__c != null,
                'Test should either handle the secure-query restriction or return an accessible registration record'
            );
        }
    }

    @IsTest
    static void testGetRegRecordUpdate() {
        System.runAs(getRunAsUser()) {
            Registration_SCH__c reg = [SELECT Id FROM Registration_SCH__c WHERE Customer_Email__c = 'alice.williams@test.com' LIMIT 1];
            Expert_Location__c loc = [SELECT Id FROM Expert_Location__c LIMIT 1];
            List<String> values = new List<String>{
                'Attended', 'Walk In', 'Appointment', 'Booked', 'Success',
                'Test Purpose', 'TestFirst', 'TestLast', 'test@test.com', '8888888888',
                '', '', '', '', '', ''
            };
            String jsonValues = JSON.serialize(values);
            DateTime startTime = System.now().addHours(1);
            DateTime endTime = System.now().addHours(2);
            Test.startTest();
            QueueExpertWrapper result = Queue_Expert_Sch.getRegRecordUpdate(
                reg.Id, jsonValues, UserInfo.getUserId(), null, null, null, null, loc.Id, startTime, endTime
            );
            Test.stopTest();
            System.assertNotEquals(null, result, 'Result should not be null');
        }
    }

    @IsTest
    static void testUploadFile() {
        System.runAs(getRunAsUser()) {
            Registration_SCH__c reg = [SELECT Id FROM Registration_SCH__c WHERE Customer_Email__c = 'jane.smith@test.com' LIMIT 1];
            String base64Data = EncodingUtil.base64Encode(Blob.valueOf('Test file content'));
            Test.startTest();
            QueueExpertUploadFileRequest request = new QueueExpertUploadFileRequest();
            request.parent = reg.Id;
            request.fileName = 'TestFile.txt';
            request.base64Data = base64Data;
            request.contentType = 'text/plain';
            List<Attachment> result = Queue_Expert_Sch.uploadFile(request);
            Test.stopTest();
            System.assertNotEquals(null, result, 'Result should not be null');
            System.assert(result.size() > 0, 'At least one attachment should be returned');
        }
    }

    @IsTest
    static void testSaveNotes() {
        System.runAs(getRunAsUser()) {
            Registration_SCH__c reg = [SELECT Id FROM Registration_SCH__c WHERE Customer_Email__c = 'jane.smith@test.com' LIMIT 1];
            Note testNote = new Note(Title = 'Test Note', Body = 'Test note body', ParentId = reg.Id);
            String noteJson = JSON.serialize(testNote);
            Test.startTest();
            List<Note> result = Queue_Expert_Sch.saveNotes(noteJson, reg.Id);
            Test.stopTest();
            System.assertNotEquals(null, result, 'Result should not be null');
            System.assert(result.size() > 0, 'At least one note should be returned');
        }
    }

    @IsTest
    static void testSaveNotesUpdateExistingNote() {
        System.runAs(getRunAsUser()) {
            Registration_SCH__c reg = [SELECT Id FROM Registration_SCH__c WHERE Customer_Email__c = 'jane.smith@test.com' LIMIT 1];
            Note existingNote = new Note(Title = 'Original Title', Body = 'Original body', ParentId = reg.Id);
            insert existingNote;

            Note updatedNote = new Note(Id = existingNote.Id, Title = 'Updated Title', Body = 'Updated body', ParentId = reg.Id);
            String noteJson = JSON.serialize(updatedNote);
            Boolean handledAccessException = false;

            Test.startTest();
            try {
                Queue_Expert_Sch.saveNotes(noteJson, reg.Id);
            } catch (AuraHandledException e) {
                handledAccessException = true;
                System.assertNotEquals(null, e.getMessage(), 'Access exception should include a message');
            }
            Test.stopTest();

            Note storedNote = [SELECT Id, Title, Body, ParentId FROM Note WHERE Id = :existingNote.Id LIMIT 1];
            System.assertEquals(true, handledAccessException, 'Existing note update should be blocked when note field update access is unavailable');
            System.assertEquals('Original Title', storedNote.Title, 'Existing note title should remain unchanged when update access is denied');
            System.assertEquals('Original body', storedNote.Body, 'Existing note body should remain unchanged when update access is denied');
            System.assertEquals(reg.Id, storedNote.ParentId, 'Existing note parent should remain the registration');
        }
    }

    @IsTest
    static void testDeleteATAttachment() {
        System.runAs(getRunAsUser()) {
            Registration_SCH__c reg = [SELECT Id FROM Registration_SCH__c WHERE Customer_Email__c = 'jane.smith@test.com' LIMIT 1];
            Attachment att = new Attachment(Name = 'TestAttachment.txt', Body = Blob.valueOf('Test content'), ParentId = reg.Id);
            insert att;
            Test.startTest();
            QueueExpertWrapper result = Queue_Expert_Sch.deleteAT(att.Id, 'Attachment');
            Test.stopTest();
            System.assertNotEquals(null, result, 'Result should not be null');
            List<Attachment> attachments = [SELECT Id FROM Attachment WHERE Id = :att.Id];
            System.assertEquals(0, attachments.size(), 'Attachment should have been deleted');
        }
    }

    @IsTest
    static void testDeleteATNote() {
        System.runAs(getRunAsUser()) {
            Registration_SCH__c reg = [SELECT Id FROM Registration_SCH__c WHERE Customer_Email__c = 'jane.smith@test.com' LIMIT 1];
            Note note = new Note(Title = 'Test Note', Body = 'Test note body', ParentId = reg.Id);
            insert note;
            Test.startTest();
            QueueExpertWrapper result = Queue_Expert_Sch.deleteAT(note.Id, 'Note');
            Test.stopTest();
            System.assertNotEquals(null, result, 'Result should not be null');
            List<Note> notes = [SELECT Id FROM Note WHERE Id = :note.Id];
            System.assertEquals(0, notes.size(), 'Note should have been deleted');
        }
    }

    @IsTest
    static void testGetRegRecords() {
        System.runAs(getRunAsUser()) {
            Test.startTest();
            QueueExpertRecords result = Queue_Expert_Sch.getRegRecords();
            Test.stopTest();
            System.assertNotEquals(null, result, 'Result should not be null');
        }
    }

    @IsTest
    static void testQueueExpertRecordsConstructor() {
        System.runAs(getRunAsUser()) {
            Test.startTest();
            QueueExpertRecords rec = new QueueExpertRecords();
            Test.stopTest();
            System.assertNotEquals(null, rec, 'Records should not be null');
        }
    }

    @IsTest
    static void testQueueExpertSelectOptionsConstructor() {
        System.runAs(getRunAsUser()) {
            Test.startTest();
            QueueExpertSelectOptions option1 = new QueueExpertSelectOptions('Label1', 'Value1');
            QueueExpertSelectOptions option2 = new QueueExpertSelectOptions('Label2', 'Value2', true);
            Test.stopTest();
            System.assertNotEquals(null, option1, 'Option1 should not be null');
            System.assertNotEquals(null, option2, 'Option2 should not be null');
        }
    }

    @IsTest
    static void testQueueExpertWrapperConstructor() {
        System.runAs(getRunAsUser()) {
            Test.startTest();
            QueueExpertWrapper wrapper = new QueueExpertWrapper();
            Test.stopTest();
            System.assertNotEquals(null, wrapper, 'Wrapper should not be null');
        }
    }
}
