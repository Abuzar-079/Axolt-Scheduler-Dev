/**
 * @description Test support for Queue_Sch_RecordHelper insertRecords request setup.
 */
@IsTest
public class QueueSchInsertRecordsTestSupport {
    public static final String INSERT_RECORD_ACTION = 'Queue_Sch_RecordHelper.insertRecords';

    /**
     * @description Mutable context used to build insertRecords requests in tests.
     */
    public class Context {
        public String firstName;
        public String lastName;
        public String email;
        public String phone;
        public Id locationId;
        public Id serviceId;
        public Id queueId;
        public DateTime slotStart;
        public DateTime slotEnd;
    }

    /**
     * @description Builds the default insertRecords context used by the happy-path test.
     * @return Default insertRecords context.
     */
    public static Context buildDefaultContext() {
        Expert_Location__c loc = [SELECT Id FROM Expert_Location__c LIMIT 1];
        Product2 service = [SELECT Id FROM Product2 LIMIT 1];
        Queue__c queue = [SELECT Id FROM Queue__c LIMIT 1];

        Context context = new Context();
        context.firstName = 'NewFirst';
        context.lastName = 'NewLast';
        context.email = 'new@test.com';
        context.phone = '5555555555';
        context.locationId = loc.Id;
        context.serviceId = service.Id;
        context.queueId = queue.Id;
        applySlot(context, System.now().addDays(1).addHours(2));
        return context;
    }

    /**
     * @description Applies the selected slot and derived end time to a request context.
     * @param context Request context to update.
     * @param slotStart Selected slot start time.
     */
    public static void applySlot(Context context, DateTime slotStart) {
        context.slotStart = slotStart;
        context.slotEnd = slotStart.addMinutes(30);
    }

    /**
     * @description Executes insertRecords inside a test governor-limit scope.
     * @param context Request context used to build the Apex request.
     * @return Wrapper returned by insertRecords.
     */
    public static Queue_Sch_Wrapper execute(Context context) {
        Queue_Sch_InsertRecordsRequest request = buildRequest(context);
        Test.startTest();
        Queue_Sch_Wrapper result = Queue_Sch_RecordHelper.insertRecords(request);
        Test.stopTest();
        return result;
    }

    /**
     * @description Executes insertRecords and returns an empty wrapper when the scenario intentionally errors.
     * @param context Request context used to build the Apex request.
     * @return Wrapper returned by insertRecords, or an empty wrapper if the request throws.
     */
    public static Queue_Sch_Wrapper executeSafely(Context context) {
        Queue_Sch_Wrapper result;
        Test.startTest();
        try {
            result = Queue_Sch_RecordHelper.insertRecords(buildRequest(context));
        } catch (Exception e) {
            result = new Queue_Sch_Wrapper();
        }
        Test.stopTest();
        return result;
    }

    private static Queue_Sch_InsertRecordsRequest buildRequest(Context context) {
        Queue_Sch_InsertRecordsRequest request = new Queue_Sch_InsertRecordsRequest();
        request.fname = context.firstName;
        request.lname = context.lastName;
        request.email = context.email;
        request.phone = context.phone;
        request.location = context.locationId;
        request.service = context.serviceId;
        request.event = null;
        request.queueId = context.queueId;
        request.selSlotST = context.slotStart;
        request.selSlotET = context.slotEnd;
        request.serviceId = context.serviceId;
        request.res = '';
        request.csrfToken = Queue_Sch_CsrfGuard.issueToken(INSERT_RECORD_ACTION);
        return request;
    }
}
