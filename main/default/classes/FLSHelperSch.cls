/**
 * @description Shared helper for returning FLS-safe records before DML.
 */
public with sharing class FLSHelperSch {
    /**
     * @description Returns records sanitized for the requested object and access type.
     * @param records Records to sanitize.
     * @param objectApiName Target object API name.
     * @param accessType Requested access type.
     * @return Sanitized records ready for typed casting.
     */
    public static List<SObject> getSafeRecords(
        List<SObject> records,
        String objectApiName,
        AccessType accessType
    ) {
        if (hasNoRecords(records)) {
            return new List<SObject>();
        }

        Schema.SObjectType expectedType = getExpectedType(objectApiName);
        validateRecordsMatchType(records, expectedType);
        return getStrippedRecords(records, accessType);
    }

    private static Boolean hasNoRecords(List<SObject> records) {
        return records == null || records.isEmpty();
    }

    private static Schema.SObjectType getExpectedType(String objectApiName) {
        validateObjectApiName(objectApiName);
        Map<String, Schema.SObjectType> describeByName = Schema.getGlobalDescribe();
        validateSupportedObject(objectApiName, describeByName);
        return describeByName.get(objectApiName);
    }

    private static void validateObjectApiName(String objectApiName) {
        if (String.isBlank(objectApiName)) {
            throw new AuraHandledException('Object API name is required for FLS enforcement.');
        }
    }

    private static void validateSupportedObject(String objectApiName, Map<String, Schema.SObjectType> describeByName) {
        if (!describeByName.containsKey(objectApiName)) {
            throw new AuraHandledException('Unsupported object for FLS enforcement: ' + objectApiName);
        }
    }

    private static void validateRecordsMatchType(List<SObject> records, Schema.SObjectType expectedType) {
        for (SObject record : records) {
            validateRecordMatchesType(record, expectedType);
        }
    }

    private static void validateRecordMatchesType(SObject record, Schema.SObjectType expectedType) {
        if (record == null) {
            throw new AuraHandledException('A null record cannot be sanitized.');
        }
        if (record.getSObjectType() != expectedType) {
            throw new AuraHandledException('Mismatched record type for FLS enforcement.');
        }
    }

    private static List<SObject> getStrippedRecords(List<SObject> records, AccessType accessType) {
        return Security.stripInaccessible(accessType, records).getRecords();
    }
}
