@IsTest
public class EventBooking_SchTestClass_Additional {

    private static User getRunAsUser() {
        return [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    }

    @TestSetup
    static void makeData() {
        EventBooking_SchTestDataFactory.createBaseData();
    }

    @IsTest
    static void testWrapperClasses() {
        System.runAs(getRunAsUser()) {
            EventBooking_Sch.EventsWrapper evtWrapper = new EventBooking_Sch.EventsWrapper();
            System.assertNotEquals(null, evtWrapper.EvtList, 'EvtList should be initialized');
            System.assertEquals(0, evtWrapper.todaysEvents, 'Should start with 0 today events');

            EventBooking_Sch.EventWrap evtWrap = new EventBooking_Sch.EventWrap();
            System.assertNotEquals(null, evtWrap.EVT, 'EVT should be initialized');
            System.assertNotEquals(null, evtWrap.evtWeekDays, 'evtWeekDays should be initialized');

            EventBooking_Sch.SelectOption selOpt = new EventBooking_Sch.SelectOption('value1', 'label1');
            System.assertEquals('value1', selOpt.value, 'Value should match');
            System.assertEquals('label1', selOpt.label, 'Label should match');

            EventBooking_Sch.SelectOptionQty selOptQty = new EventBooking_Sch.SelectOptionQty(5, 10);
            System.assertEquals(5, selOptQty.value, 'Value should be 5');
            System.assertEquals(10, selOptQty.label, 'Label should be 10');

            EventBooking_Sch.Container container = new EventBooking_Sch.Container();
            System.assertNotEquals(null, container.Event, 'Event should be initialized');
            System.assertNotEquals(null, container.Events, 'Events list should be initialized');

            EventBooking_Sch.Schedule schedule = new EventBooking_Sch.Schedule();
            System.assertNotEquals(null, schedule.Agendas, 'Agendas should be initialized');

            EventBooking_Sch.DateColumn dateCol = new EventBooking_Sch.DateColumn();
            System.assertEquals(false, dateCol.isSelect, 'isSelect should be false by default');

            EventBooking_Sch.resultWrapper resWrap = new EventBooking_Sch.resultWrapper();
            System.assertNotEquals(null, resWrap.parentRegs, 'parentRegs should be initialized');
            System.assertNotEquals(null, resWrap.childRegs, 'childRegs should be initialized');
            System.assertNotEquals(null, resWrap.resultRegs, 'resultRegs should be initialized');

            EventBooking_Sch.EventTimeSlot timeSlot = new EventBooking_Sch.EventTimeSlot();
            System.assertNotEquals(null, timeSlot.AvaD, 'AvaD should be initialized');
            System.assertEquals(false, timeSlot.preExist, 'preExist should be false');
            System.assertEquals(false, timeSlot.showSessions, 'showSessions should be false');
        }
    }

    @IsTest
    static void testReadXMLResponse() {
        System.runAs(getRunAsUser()) {
            String xmlString = '<root><test>TestValue</test></root>';
            XmlStreamReader reader = new XmlStreamReader(xmlString);

            Test.startTest();
            String result = EventBooking_Sch.readXMLResponse(reader, 'test');
            Test.stopTest();

            System.assertEquals('TestValue', result, 'Should read the XML value correctly');
        }
    }

    @IsTest
    static void testRecordWrpConstructor() {
        System.runAs(getRunAsUser()) {
            Test.startTest();
            EventBooking_Sch.RecordWrp wrp = new EventBooking_Sch.RecordWrp();
            Test.stopTest();

            System.assertEquals('', wrp.Id, 'Id should be empty string');
            System.assertEquals('', wrp.Name, 'Name should be empty string');
            System.assertEquals('', wrp.Email, 'Email should be empty string');
            System.assertEquals('', wrp.Phone, 'Phone should be empty string');
        }
    }

    @IsTest
    static void testEAllocpbEntryWrapperConstructor() {
        System.runAs(getRunAsUser()) {
            Test.startTest();
            EventBooking_Sch.AllocpbEntryWrapper wrp = new EventBooking_Sch.AllocpbEntryWrapper();
            Test.stopTest();

            System.assertEquals(false, wrp.isMember, 'isMember should be false');
            System.assertEquals(false, wrp.selected, 'selected should be false');
            System.assertNotEquals(null, wrp.eventAlloc, 'eventAlloc should be initialized');
            System.assertEquals(0, wrp.numberOfDelegates, 'numberOfDelegates should be 0');
        }
    }

    @IsTest
    static void testGetEventDetailWithException() {
        System.runAs(getRunAsUser()) {
            Test.startTest();
            EventBooking_Sch result = EventBooking_Sch.getEventDetail('invalidId', null, null);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null even on error');
        }
    }

    @IsTest
    static void testGetAllocationsWithNull() {
        System.runAs(getRunAsUser()) {
            Test.startTest();
            EventBooking_Sch result = EventBooking_Sch.getAllocations(null);
            Test.stopTest();

            System.assert(result == null || result.allocationList != null, 'Should handle null parameter');
        }
    }
}