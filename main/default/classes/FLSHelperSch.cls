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
        if (records == null || records.isEmpty()) {
            return new List<SObject>();
        }
        if (String.isBlank(objectApiName)) {
            throw new AuraHandledException('Object API name is required for FLS enforcement.');
        }

        Map<String, Schema.SObjectType> describeByName = Schema.getGlobalDescribe();
        if (!describeByName.containsKey(objectApiName)) {
            throw new AuraHandledException('Unsupported object for FLS enforcement: ' + objectApiName);
        }

        Schema.SObjectType expectedType = describeByName.get(objectApiName);
        for (SObject record : records) {
            if (record == null) {
                throw new AuraHandledException('A null record cannot be sanitized.');
            }
            if (record.getSObjectType() != expectedType) {
                throw new AuraHandledException('Mismatched record type for FLS enforcement.');
            }
        }

        return Security.stripInaccessible(accessType, records).getRecords();
    }
}
