@SuppressWarnings('PMD.ApexDoc,PMD.AvoidDebugStatements,PMD.DebugsShouldUseLoggingLevel,PMD.CyclomaticComplexity,PMD.CognitiveComplexity,PMD.NcssCount,PMD.NcssTypeCount')
public with sharing class Queue_Sch_QueryHelper {
    @AuraEnabled
    public static List<Registration_SCH__c> getBookedRegsList(Queue_Sch_GetBookedRegsListRequest request) {
        try {
            GetBookedRegsListContext context = buildBookedRegsListContext(request);
            String finalQuery = getBookedRegsListQuery(context.conditions);
            return (List<Registration_SCH__c>)Database.queryWithBinds(finalQuery, context.bindVars, AccessLevel.USER_MODE);
        } catch (Exception e) {
            //System.debug(LoggingLevel.DEBUG, 'Exception ~> ' + e.getMessage() + '; at line ~> ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage() + '; at line ~> ' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static Queue_Sch_Wrapper getRegLocationqueueRecords(String location, String service, String eventid) {
        Queue_Sch_Wrapper wrapper = new Queue_Sch_Wrapper();
        try {
            GetRegLocationQueueContext context = buildRegLocationQueueContext(location, service, eventid);
            wrapper.getLocation = getLatestQueueLocation(location);
            wrapper.records = getOpenQueueRegistrations(context);
            wrapper.bookedAppointment = getBookedQueueRegistrations(context);
            enrichRegLocationWrapper(wrapper, location, service);
            finalizeRegLocationWrapper(wrapper);
            return wrapper;
        } catch (Exception e) {
            //System.debug(LoggingLevel.DEBUG, 'Exception ~> ' + e.getMessage() + '; at line ~> ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage() + '; at line ~> ' + e.getStackTraceString());
        }
    }

    private static GetBookedRegsListContext buildBookedRegsListContext(Queue_Sch_GetBookedRegsListRequest request){
        GetBookedRegsListContext context = new GetBookedRegsListContext();
        context.locationId = request == null ? null : request.location;
        context.serviceId = request == null ? null : request.service;
        context.dateFilter = request == null ? null : request.datefilterby;
        context.searchFilter = request == null ? null : request.searchfilterby;
        context.conditions = buildBookedRegsListConditions(context);
        context.bindVars = buildBookedRegsListBindVars(context);
        return context;
    }

    private static List<String> buildBookedRegsListConditions(GetBookedRegsListContext context){
        List<String> conditions = new List<String>();
        if (String.isNotBlank(context.locationId)) {
            conditions.add('Expert_Location__c = :locationVal');
        }
        if (String.isNotBlank(context.serviceId)) {
            conditions.add('Product2__c = :serviceVal');
        }
        if (String.isNotBlank(context.searchFilter)) {
            conditions.add('(Name LIKE :searchVal OR Customer_Name__c LIKE :searchVal OR Customer_Lastname__c LIKE :searchVal OR Customer_Email__c LIKE :searchVal OR Customer_Contact__c LIKE :searchVal)');
        }
        if (String.isNotBlank(context.dateFilter)) {
            if (context.dateFilter.contains('Today')) {
                conditions.add('DAY_ONLY(Registration_Time__c) = TODAY');
            } else if (context.dateFilter.contains('Future')) {
                conditions.add('DAY_ONLY(Registration_Time__c) > TODAY');
            } else if (context.dateFilter.contains('Past')) {
                conditions.add('DAY_ONLY(Registration_Time__c) < TODAY');
            }
        }
        return conditions;
    }

    private static Map<String, Object> buildBookedRegsListBindVars(GetBookedRegsListContext context){
        Map<String, Object> bindVars = new Map<String, Object>{ 'bookVal' => 'Booked' };
        if (String.isNotBlank(context.locationId)) {
            bindVars.put('locationVal', context.locationId);
        }
        if (String.isNotBlank(context.serviceId)) {
            bindVars.put('serviceVal', context.serviceId);
        }
        if (String.isNotBlank(context.searchFilter)) {
            bindVars.put('searchVal', '%' + context.searchFilter + '%');
        }
        return bindVars;
    }

    private static String getBookedRegsListQuery(List<String> conditions){
        String baseQuery =
            'SELECT Id, Name, Customer_Name__c, Wait_Time_Exceeded__c, Token_Number__c, Customer_Lastname__c, ' +
            'Customer_Email__c, Booked_Current_Status__c, Customer_Contact__c, Expert_Location__c, ' +
            'Expert_Location__r.Name, Product2__r.SCH_Wait_Threshold__c, Product2__r.Name, Company__c, Status__c, ' +
            'waiting_Time__c, Booked_Date__c, Registration_Time__c, Checked_in_Date_Time__c, Appointment_DateDt__c, ' +
            'End_Time__c, Contact__c, Contact__r.Name FROM Registration_SCH__c WHERE Status__c = :bookVal ' +
            'AND Product2__c != NULL AND Registration_Time__c != NULL AND End_Time__c != NULL AND Appointment_DateDt__c != NULL ';
        return baseQuery + buildWhereClause(conditions) + ' ORDER BY LastModifiedDate DESC LIMIT 100';
    }

    private static GetRegLocationQueueContext buildRegLocationQueueContext(String location, String service, String eventId){
        GetRegLocationQueueContext context = new GetRegLocationQueueContext();
        context.locationId = location;
        context.serviceId = normalizeBlank(service);
        context.eventId = normalizeBlank(eventId);
        context.conditions = buildRegLocationConditions(context);
        context.openBindVars = buildRegLocationBindVars(context, 'canVal', 'Cancelled');
        context.bookedBindVars = buildRegLocationBindVars(context, 'bookVal', 'Booked');
        return context;
    }

    private static List<String> buildRegLocationConditions(GetRegLocationQueueContext context){
        List<String> conditions = new List<String>();
        if (String.isNotBlank(context.locationId)) {
            conditions.add('Expert_Location__c = :locationVal');
        }
        if (String.isNotBlank(context.serviceId)) {
            conditions.add('Product2__c = :serviceVal');
        }
        if (String.isNotBlank(context.eventId)) {
            conditions.add('User__c = :userVal');
        }
        return conditions;
    }

    private static Map<String, Object> buildRegLocationBindVars(GetRegLocationQueueContext context, String statusKey, String statusValue){
        Map<String, Object> bindVars = new Map<String, Object>{ statusKey => statusValue };
        if (String.isNotBlank(context.locationId)) {
            bindVars.put('locationVal', context.locationId);
        }
        if (String.isNotBlank(context.serviceId)) {
            bindVars.put('serviceVal', context.serviceId);
        }
        if (String.isNotBlank(context.eventId)) {
            bindVars.put('userVal', context.eventId);
        }
        return bindVars;
    }

    private static List<Queue__c> getLatestQueueLocation(String location){
        return [SELECT Id, Location__c, Location__r.Name FROM Queue__c WHERE Location__c = :location WITH USER_MODE ORDER BY LastModifiedDate DESC LIMIT 1];
    }

    private static List<Queue__c> getLatestActiveQueueLocation(String location){
        return [SELECT Id, Location__c, Location__r.Name FROM Queue__c WHERE Location__c = :location AND Status__c = 'Active' WITH USER_MODE ORDER BY LastModifiedDate DESC LIMIT 1];
    }

    private static List<Registration_SCH__c> getOpenQueueRegistrations(GetRegLocationQueueContext context){
        String baseQuery =
            'SELECT Id, Name, User__c, Customer_Name__c, Wait_Time_Exceeded__c, Token_Number__c, Customer_Lastname__c, Customer_Email__c, ' +
            'Booked_Current_Status__c, Customer_Contact__c, Expert_Location__c, Expert_Location__r.Name, Product2__r.SCH_Wait_Threshold__c, ' +
            'Product2__r.Name, Company__c, Status__c, waiting_Time__c, Booked_Date__c, Registration_Time__c, Checked_in_Date_Time__c ' +
            'FROM Registration_SCH__c WHERE Registration_Time__c = NULL AND Product2__c != NULL AND Status__c != :canVal ';
        return (List<Registration_SCH__c>)Database.queryWithBinds(baseQuery + buildWhereClause(context.conditions) + ' ORDER BY Booked_Date__c ASC LIMIT 500', context.openBindVars, AccessLevel.USER_MODE);
    }

    private static List<Registration_SCH__c> getBookedQueueRegistrations(GetRegLocationQueueContext context){
        String baseQuery =
            'SELECT Id, Name, User__c, Customer_Name__c, Wait_Time_Exceeded__c, Token_Number__c, Customer_Lastname__c, Customer_Email__c, ' +
            'Booked_Current_Status__c, Customer_Contact__c, Expert_Location__c, Expert_Location__r.Name, Product2__r.SCH_Wait_Threshold__c, ' +
            'Product2__r.Name, Company__c, Status__c, waiting_Time__c, Booked_Date__c, Registration_Time__c, Checked_in_Date_Time__c, ' +
            'Appointment_DateDt__c, End_Time__c, Contact__c, Contact__r.Name FROM Registration_SCH__c WHERE Status__c = :bookVal ' +
            'AND Product2__c != NULL AND Registration_Time__c != NULL AND End_Time__c != NULL AND Appointment_DateDt__c != NULL ';
        return (List<Registration_SCH__c>)Database.queryWithBinds(baseQuery + buildWhereClause(context.conditions) + ' ORDER BY LastModifiedDate DESC LIMIT 100', context.bookedBindVars, AccessLevel.USER_MODE);
    }

    private static void enrichRegLocationWrapper(Queue_Sch_Wrapper wrapper, String location, String service){
        if (String.isBlank(service)) {
            setRegLocationName(wrapper);
            return;
        }
        Queue_Sch_Wrapper filterwrap = Queue_Sch_Support.getFilterValues(location, null, null);
        wrapper.getLocation = getLatestActiveQueueLocation(location);
        wrapper.allServices = filterwrap.allServices;
        setRegLocationName(wrapper);
    }

    private static void finalizeRegLocationWrapper(Queue_Sch_Wrapper wrapper){
        Integer size = wrapper.records.size();
        if (size <= 0) {
            wrapper.existLocation = true;
        }
        for (Integer index = 0; index < size; index++) {
            wrapper.mapOfRecords.put(String.valueOf(index), wrapper.records[index]);
        }
        setRegLocationName(wrapper);
    }

    private static void setRegLocationName(Queue_Sch_Wrapper wrapper){
        if (!wrapper.getLocation.isEmpty() && wrapper.getLocation[0].Location__c != null) {
            wrapper.locationName = wrapper.getLocation[0].Location__r.Name;
        }
    }

    private static String buildWhereClause(List<String> conditions){
        return conditions.isEmpty() ? '' : ' AND ' + String.join(conditions, ' AND ');
    }

    private static String normalizeBlank(String value){
        return String.isBlank(value) ? null : value;
    }

    private class GetBookedRegsListContext{
        String locationId { get; set; }
        String serviceId { get; set; }
        String dateFilter { get; set; }
        String searchFilter { get; set; }
        List<String> conditions { get; set; }
        Map<String, Object> bindVars { get; set; }
    }

    private class GetRegLocationQueueContext{
        String locationId { get; set; }
        String serviceId { get; set; }
        String eventId { get; set; }
        List<String> conditions { get; set; }
        Map<String, Object> openBindVars { get; set; }
        Map<String, Object> bookedBindVars { get; set; }
    }
}