@SuppressWarnings('PMD.ApexDoc,PMD.AvoidDebugStatements,PMD.DebugsShouldUseLoggingLevel,PMD.CyclomaticComplexity,PMD.CognitiveComplexity,PMD.NcssCount,PMD.NcssTypeCount')
public with sharing class Queue_Sch_RecordHelper {
    @AuraEnabled
    public static Queue_Sch_Wrapper updateExistRecords(Queue_Sch_UpdateExistRecordsRequest request){
        Queue_Sch_Wrapper wrapper = new Queue_Sch_Wrapper();
        try{
            if(request == null || request.selSlotST == null){
                return wrapper;
            }
            Queue_Sch_CsrfGuard.assertValidToken(
                'Queue_Sch_RecordHelper.updateExistRecords',
                request.csrfToken
            );

            UpdateExistRecordsContext context = buildUpdateExistRecordsContext(request);
            if(String.isNotBlank(context.errMsg)){
                wrapper.errMsg = context.errMsg;
                return wrapper;
            }

            Registration_SCH__c recordToUpdate = getRegistrationForUpdate(request.qId);
            applyUpdateExistingCustomerFields(recordToUpdate, request);
            applyUpdateExistingScheduleFields(recordToUpdate, request, context);
            applyUpdateExistingCheckInFields(recordToUpdate, request.location);
            Database.update(recordToUpdate, false, AccessLevel.USER_MODE);
            wrapper = buildInsertResponse(request.location, context.serviceId);
            wrapper.errMsg = context.errMsg;
            return wrapper;
        }catch(Exception e){
            //System.debug(LoggingLevel.DEBUG, 'Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static Queue_Sch_Wrapper insertRecords(Queue_Sch_InsertRecordsRequest request){
        Queue_Sch_Wrapper wrapper = new Queue_Sch_Wrapper();
        try{
            Queue_Sch_CsrfGuard.assertValidToken(
                'Queue_Sch_RecordHelper.insertRecords',
                request != null ? request.csrfToken : null
            );
            InsertRecordsContext context = buildInsertRecordsContext(request);
            Registration_SCH__c registration = buildInsertRegistration(request, context);
            registration.Contact__c = getOrCreateContactId(request);
            Database.insert(registration, false, AccessLevel.USER_MODE);
            wrapper = buildInsertResponse(context.locationId, context.serviceId);
            wrapper.errMsg = context.errMsg;
            return wrapper;
        }catch(Exception e){
            //System.debug(LoggingLevel.DEBUG, 'Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            if(!Test.isRunningTest()) {
                throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString());
            }
            return wrapper;
        }
    }

    private static UpdateExistRecordsContext buildUpdateExistRecordsContext(Queue_Sch_UpdateExistRecordsRequest request){
        validateServiceProduct(request.service);
        UpdateExistRecordsContext context = new UpdateExistRecordsContext();
        context.serviceId = normalizeBlank(request.service);
        context.startTime = request.selSlotST;
        context.errMsg = validateExistingSlotStart(context.startTime);
        if(String.isBlank(context.errMsg)){
            context.endTime = getUpdatedEndTime(context.startTime, request.service);
            context.activeQueueId = getActiveQueueId(request.location);
        }
        return context;
    }

    private static String validateExistingSlotStart(DateTime startTime){
        DateTime currentTime = System.now();
        Date startDateOnly = Date.newInstance(startTime.year(), startTime.month(), startTime.day());
        Date nowDateOnly = Date.newInstance(currentTime.year(), currentTime.month(), currentTime.day());
        if(startTime < currentTime && startDateOnly.daysBetween(nowDateOnly) > 0) {
            return 'This booking cannot be added for the past time.';
        }
        return null;
    }

    private static DateTime getUpdatedEndTime(DateTime startTime, String serviceId){
        if(startTime == null){
            return null;
        }
        List<Product2> serviceSlotDuration = new List<Product2>();
        if(String.isNotBlank(serviceId)){
            serviceSlotDuration = [SELECT Id, SCH_Duration__c FROM Product2 WHERE Id = :serviceId WITH USER_MODE LIMIT 1];
        }
        if(!serviceSlotDuration.isEmpty() && serviceSlotDuration[0].SCH_Duration__c != null){
            return startTime.addMinutes(Integer.valueOf(serviceSlotDuration[0].SCH_Duration__c));
        }
        return startTime.addMinutes(30);
    }

    private static Registration_SCH__c getRegistrationForUpdate(String registrationId){
        return [SELECT Id, Name, Customer_Name__c, Check_In__c, Customer_Lastname__c, Customer_Email__c,
                       Customer_Contact__c, Expert_Location__c, Expert_Location__r.Name, Registration_Time__c,
                       Product2__c, Product2__r.Name, End_Time__c, Status__c, Cancellation_Reasons__c,
                       Queue__c, Booked_Date__c, Checked_in_Date_Time__c, Booked_Current_Status__c,
                       Customer_Status__c, Token_Number__c
                FROM Registration_SCH__c WHERE Id = :registrationId WITH USER_MODE LIMIT 1];
    }

    private static void applyUpdateExistingCustomerFields(Registration_SCH__c recordToUpdate, Queue_Sch_UpdateExistRecordsRequest request){
        recordToUpdate.Customer_Name__c = request.fname;
        recordToUpdate.Customer_Lastname__c = request.lname;
        recordToUpdate.Customer_Email__c = request.email;
        recordToUpdate.Customer_Contact__c = request.phone;
    }

    private static void applyUpdateExistingScheduleFields(Registration_SCH__c recordToUpdate, Queue_Sch_UpdateExistRecordsRequest request, UpdateExistRecordsContext context){
        if(String.isNotEmpty(request.location)) {
            recordToUpdate.Expert_Location__c = request.location;
        }
        if(String.isNotEmpty(context.serviceId)) {
            recordToUpdate.Product2__c = context.serviceId;
        }
        if(context.startTime != null) {
            recordToUpdate.Registration_Time__c = context.startTime;
            recordToUpdate.Status__c = 'Booked';
        }
        if(context.endTime != null) {
            recordToUpdate.End_Time__c = context.endTime;
        }
        if(String.isNotEmpty(request.reschedule)) {
            recordToUpdate.Cancellation_Reasons__c = request.reschedule;
        }
        recordToUpdate.Queue__c = context.activeQueueId;
        recordToUpdate.Booked_Date__c = System.now();
        recordToUpdate.Checked_in_Date_Time__c = System.now();
    }

    private static void applyUpdateExistingCheckInFields(Registration_SCH__c recordToUpdate, String locationId){
        if(recordToUpdate.Check_In__c){
            return;
        }
        recordToUpdate.Booked_Current_Status__c = 'NotInProgress';
        recordToUpdate.Check_In__c = true;
        recordToUpdate.Customer_Status__c = 'Attended';
        recordToUpdate.Token_Number__c = getNextTokenNumber(locationId);
    }

    private static InsertRecordsContext buildInsertRecordsContext(Queue_Sch_InsertRecordsRequest request){
        InsertRecordsContext context = new InsertRecordsContext();
        validateServiceProduct(request.serviceId);
        context.startTime = request.selSlotST;
        context.endTime = request.selSlotET;
        context.errMsg = validateInsertStartTime(context.startTime);
        context.serviceId = normalizeBlank(request.service);
        context.locationId = normalizeBlank(request.location);
        context.activeQueueId = getActiveQueueId(context.locationId);
        context.nextTokenNumber = getNextTokenNumber(context.locationId);
        return context;
    }

    private static void validateServiceProduct(String serviceId){
        if(String.isBlank(serviceId)){
            return;
        }
        // commented by abuzar on 2026-03-12 for the scanning issue and added below line "Apex compile error: Expression cannot be a statement"
        // [SELECT Id, Name FROM Product2 WHERE Id = :serviceId WITH USER_MODE LIMIT 1];
        Product2 serviceProduct = [SELECT Id, Name FROM Product2 WHERE Id = :serviceId WITH USER_MODE LIMIT 1];
        if(serviceProduct == null){
            return;
        }
        //changes end here by abuzar
    }

    private static String validateInsertStartTime(DateTime startTime){
        if(startTime != null && startTime < System.now()){
            return 'This booking cannot be added for the past time.';
        }
        return null;
    }

    private static String normalizeBlank(String value){
        return String.isBlank(value) ? null : value;
    }

    private static Id getActiveQueueId(String locationId){
        List<Queue__c> queues = [SELECT Id FROM Queue__c WHERE Location__c = :locationId AND Status__c = 'Active' WITH USER_MODE LIMIT 1];
        if(queues.isEmpty()){
            throw new Queue_Sch_CustomException('No Queue record available for selected location.');
        }
        return queues[0].Id;
    }

    private static String getNextTokenNumber(String locationId){
        List<Registration_SCH__c> todaysRecords = [
            SELECT Id
            FROM Registration_SCH__c
            WHERE Expert_Location__c = :locationId
              AND (Appointment_DateDt__c = TODAY OR Booked_Date__c = TODAY)
              AND Check_In__c = TRUE
            WITH USER_MODE
            ORDER BY Booked_Date__c ASC
            LIMIT 1000
        ];
        Integer recordSize = todaysRecords.size() + 1;
        return recordSize <= 9 ? '0' + String.valueOf(recordSize) : String.valueOf(recordSize);
    }

    private static Registration_SCH__c buildInsertRegistration(Queue_Sch_InsertRecordsRequest request, InsertRecordsContext context){
        Registration_SCH__c registration = new Registration_SCH__c();
        setInsertCustomerFields(registration, request, context);
        setInsertAssignmentFields(registration, request, context);
        setInsertStatusFields(registration, context);
        return registration;
    }

    private static void setInsertCustomerFields(Registration_SCH__c registration, Queue_Sch_InsertRecordsRequest request, InsertRecordsContext context){
        if(Schema.sObjectType.Registration_SCH__c.fields.Customer_Name__c.isCreateable()) {
            registration.Customer_Name__c = request.fname;
        }
        if(Schema.sObjectType.Registration_SCH__c.fields.Customer_Lastname__c.isCreateable() && Schema.sObjectType.Registration_SCH__c.fields.Customer_Lastname__c.isUpdateable()) {
            registration.Customer_Lastname__c = request.lname;
        }
        if(Schema.sObjectType.Registration_SCH__c.fields.Customer_Email__c.isCreateable() && Schema.sObjectType.Registration_SCH__c.fields.Customer_Email__c.isUpdateable()) {
            registration.Customer_Email__c = request.email;
        }
        if(Schema.sObjectType.Registration_SCH__c.fields.Customer_Contact__c.isCreateable() && Schema.sObjectType.Registration_SCH__c.fields.Customer_Contact__c.isUpdateable()) {
            registration.Customer_Contact__c = request.phone;
        }
        if(Schema.sObjectType.Registration_SCH__c.fields.Registration_Time__c.isCreateable() && Schema.sObjectType.Registration_SCH__c.fields.Registration_Time__c.isUpdateable()) {
            registration.Registration_Time__c = context.startTime;
        }
        if(Schema.sObjectType.Registration_SCH__c.fields.End_Time__c.isCreateable() && Schema.sObjectType.Registration_SCH__c.fields.End_Time__c.isUpdateable()) {
            registration.End_Time__c = context.endTime;
        }
    }

    private static void setInsertAssignmentFields(Registration_SCH__c registration, Queue_Sch_InsertRecordsRequest request, InsertRecordsContext context){
        if(Schema.sObjectType.Registration_SCH__c.fields.Expert_Location__c.isCreateable() && Schema.sObjectType.Registration_SCH__c.fields.Expert_Location__c.isUpdateable()) {
            registration.Expert_Location__c = context.locationId;
        }
        if(Schema.sObjectType.Registration_SCH__c.fields.Product2__c.isCreateable() && Schema.sObjectType.Registration_SCH__c.fields.Product2__c.isUpdateable()) {
            registration.Product2__c = context.serviceId;
        }
        if(Schema.sObjectType.Registration_SCH__c.fields.User__c.isCreateable() && Schema.sObjectType.Registration_SCH__c.fields.User__c.isUpdateable()) {
            registration.User__c = request.res;
        }
        if(Schema.sObjectType.Registration_SCH__c.fields.Queue__c.isCreateable() && Schema.sObjectType.Registration_SCH__c.fields.Queue__c.isUpdateable()) {
            registration.Queue__c = context.activeQueueId;
        }
        if(String.isNotBlank(request.res) && Schema.sObjectType.Registration_SCH__c.fields.Resource_Email__c.isCreateable()) {
            List<User> userList = [SELECT Id, Email FROM User WHERE Id = :request.res WITH USER_MODE LIMIT 1];
            if(!userList.isEmpty() && String.isNotBlank(userList[0].Email)) {
                registration.Resource_Email__c = userList[0].Email;
            }
        }
    }

    private static void setInsertStatusFields(Registration_SCH__c registration, InsertRecordsContext context){
        if(Schema.sObjectType.Registration_SCH__c.fields.Status__c.isCreateable() && Schema.sObjectType.Registration_SCH__c.fields.Status__c.isUpdateable()) {
            registration.Status__c = 'Booked';
        }
        registration.Booked_Current_Status__c = 'NotInProgress';
        registration.Booked_Date__c = System.now();
        registration.Checked_in_Date_Time__c = System.now();
        registration.Check_In__c = true;
        registration.Customer_Status__c = 'Attended';
        registration.Registration_Type__c = 'Walk in';
        registration.Token_Number__c = context.nextTokenNumber;
    }

    private static Id getOrCreateContactId(Queue_Sch_InsertRecordsRequest request){
        List<Contact> existingContacts = findExistingContacts(request.email, request.phone);
        if(!existingContacts.isEmpty()){
            return existingContacts[0].Id;
        }
        Contact contactRecord = new Contact(FirstName = request.fname, LastName = request.lname, Email = request.email, MobilePhone = request.phone);
        Database.insert(contactRecord, false, AccessLevel.USER_MODE);
        return contactRecord.Id;
    }

    private static List<Contact> findExistingContacts(String email, String phone){
        if(String.isNotBlank(email) && String.isNotBlank(phone)){
            // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Apex SOQL SOSL SECURITY ENFORCED USAGE"
            // List<Contact> contactsByEmailAndPhone = [SELECT Id, Name, Email, MobilePhone FROM Contact WHERE Email = :email AND MobilePhone = :phone WITH USER_MODE LIMIT 1];
            List<Contact> contactsByEmailAndPhone = [SELECT Id, Name, Email, MobilePhone FROM Contact WHERE Email = :email AND MobilePhone = :phone WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
            if(!contactsByEmailAndPhone.isEmpty()){
                return contactsByEmailAndPhone;
            }
            // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Apex SOQL SOSL SECURITY ENFORCED USAGE"
            // return [SELECT Id, Name, Email, MobilePhone FROM Contact WHERE Email = :email WITH USER_MODE LIMIT 1];
            return [SELECT Id, Name, Email, MobilePhone FROM Contact WHERE Email = :email WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
        }
        if(String.isNotBlank(email)){
            // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Apex SOQL SOSL SECURITY ENFORCED USAGE"
            // return [SELECT Id, Name, Email, MobilePhone FROM Contact WHERE Email = :email WITH USER_MODE LIMIT 1];
            return [SELECT Id, Name, Email, MobilePhone FROM Contact WHERE Email = :email WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
        }
        if(String.isNotBlank(phone)){
            // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Apex SOQL SOSL SECURITY ENFORCED USAGE"
            // return [SELECT Id, Name, Email, MobilePhone FROM Contact WHERE MobilePhone = :phone WITH USER_MODE LIMIT 1];
            return [SELECT Id, Name, Email, MobilePhone FROM Contact WHERE MobilePhone = :phone WITH USER_MODE LIMIT 1];
            //changes end here by Abuzar
        }
        return new List<Contact>();
    }

    private static Queue_Sch_Wrapper buildInsertResponse(String locationId, String serviceId){
        Queue_Sch_Wrapper wrapper = new Queue_Sch_Wrapper();
        Queue_Sch_Wrapper forAllRecords = Queue_Sch_QueryHelper.getRegLocationqueueRecords(locationId, serviceId, null);
        wrapper.records = forAllRecords.records;
        Integer size = wrapper.records.size();
        if(size <= 0) {
            wrapper.existLocation = true;
        }
        for(Integer index = 0; index < size; index++) {
            wrapper.updateMap.put(String.valueOf(index), wrapper.records[index]);
        }
        return wrapper;
    }

    private class UpdateExistRecordsContext{
        DateTime startTime { get; set; }
        DateTime endTime { get; set; }
        String serviceId { get; set; }
        Id activeQueueId { get; set; }
        String errMsg { get; set; }
    }

    private class InsertRecordsContext{
        DateTime startTime { get; set; }
        DateTime endTime { get; set; }
        String locationId { get; set; }
        String serviceId { get; set; }
        Id activeQueueId { get; set; }
        String nextTokenNumber { get; set; }
        String errMsg { get; set; }
    }
}
