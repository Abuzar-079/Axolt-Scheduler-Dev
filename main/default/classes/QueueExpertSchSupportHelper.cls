// commented by abuzar on 2026-03-13 for the scanning issue and added below line "Apex classes should declare a sharing model if DML or SOQL/SOSL is used"
// public class QueueExpertSchSupportHelper {
/**
 * @description Utility helpers shared by queue expert scheduler support classes.
 */
public with sharing class QueueExpertSchSupportHelper {
    /**
     * @description Adds the location filter to a dynamic registration query when present.
     * @param query Base query string.
     * @param bindVars Bind variables used by the query.
     * @param locationId Location identifier filter.
     * @return Query string with the optional location filter applied.
     */
    public static String addLocationFilter(String query, Map<String, Object> bindVars, String locationId) {
        if (locationId != null) {
            bindVars.put('locationId', locationId);
            return query + ' AND Expert_Location__c = :locationId';
        }
        return query;
    }

    /**
     * @description Adds the service filter to a dynamic registration query when present.
     * @param query Base query string.
     * @param bindVars Bind variables used by the query.
     * @param serviceId Service identifier filter.
     * @return Query string with the optional service filter applied.
     */
    public static String addServiceFilter(String query, Map<String, Object> bindVars, String serviceId) {
        if (serviceId != null) {
            bindVars.put('serviceId', serviceId);
            return query + ' AND Product2__c = :serviceId';
        }
        return query;
    }

    /**
     * @description Adds the resource filter to a dynamic registration query.
     * @param query Base query string.
     * @param bindVars Bind variables used by the query.
     * @param resourceId Resource identifier filter.
     * @return Query string with the resource or current-user filter applied.
     */
    public static String addResourceFilter(String query, Map<String, Object> bindVars, String resourceId) {
        if (resourceId != null) {
            bindVars.put('resourceId', resourceId);
            return query + ' AND User__c = :resourceId';
        }
        return query + ' AND User__c = :currentUserId';
    }

    /**
     * @description Adds the record to the wrapper when it is currently in progress.
     * @param wrapper Wrapper being populated.
     * @param recordItem Registration record to inspect.
     */
    public static void addInProgressRecord(Queue_Expert_Sch.Wrapper wrapper, Registration_SCH__c recordItem) {
        if (recordItem.Booked_Current_Status__c == 'InProgress') {
            wrapper.objectValues.add(recordItem);
            wrapper.inProgress = true;
        }
    }

    /**
     * @description Builds a lightweight record wrapper for queue scheduler display.
     * @param recordItem Registration record to wrap.
     * @return Queue scheduler record wrapper.
     */
    public static Queue_Expert_Sch.Records buildRecordWrapper(Registration_SCH__c recordItem) {
        Queue_Expert_Sch.Records rec = new Queue_Expert_Sch.Records();
        rec.regRecords = recordItem;
        rec.waitingTime = '12 hours';
        return rec;
    }

    /**
     * @description Loads notes, attachments, owner, and record type details for the primary record.
     * @param wrapper Wrapper to enrich with related data.
     */
    public static void loadPrimaryRecordRelatedData(Queue_Expert_Sch.Wrapper wrapper) {
        if (wrapper.objectValues.isEmpty()) {
            return;
        }
        Registration_SCH__c primaryRecord = wrapper.objectValues[0];
        wrapper.notes = [Select Id, Title, ParentId From Note Where ParentId = :primaryRecord.Id Order By CreatedDate Asc LIMIT 1000];
        wrapper.attachments = [Select Id, Name, ParentId, ContentType From Attachment Where ParentId = :primaryRecord.Id Order By CreatedDate Asc LIMIT 1000];
        wrapper.userName = [SELECT Name FROM User WHERE Id = :primaryRecord.OwnerId LIMIT 1000];
        wrapper.recordTypeName = [Select Id, Name From RecordType where id = :primaryRecord.RecordTypeId LIMIT 1000];
    }

    /**
     * @description Normalizes an empty contact value to `null`.
     * @param contactId Raw contact identifier value.
     * @return Contact identifier or `null` when blank.
     */
    public static String getNormalizedContactValue(String contactId) {
        return contactId == '' ? null : contactId;
    }

    /**
     * @description Returns a request value from the ordered list when available.
     * @param requestValues Ordered request values.
     * @param index Zero-based index to read.
     * @return Requested value, or `null` when the index is unavailable.
     */
    public static String getRequestValue(List<String> requestValues, Integer index) {
        return requestValues.size() > index ? requestValues[index] : null;
    }
}
//changes end here by abuzar