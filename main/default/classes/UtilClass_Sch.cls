/**
 * @description Shared utility methods for schema inspection and field-level security checks.
 */
public with sharing Class UtilClass_Sch {

    /**
     * @description Builds a comma-separated list of accessible fields for the given sObject.
     * @param sObjectName API name of the target sObject.
     * @return Escaped comma-separated field list, or `Name` when no fields are available.
     */
    public static String selectStarFromSObject(String sObjectName) {
        Boolean considerNamespace = false;
        String sObjectNameUnChanged = sObjectName;
        String allFields = '';
        Set<String> ignoredFieldsSet = new Set<String>{ 'isdeleted', 'systemmodstamp', 'lastvieweddate', 'lastreferenceddate' };

        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType sObjectType = globalDescribe.get(sObjectName);

        if (sObjectType == null) {
            considerNamespace = !considerNamespace;
            sObjectName = sObjectNameUnChanged;
            if (sObjectName.containsIgnoreCase('__c') && considerNamespace) {
                sObjectName = (sObjectName.containsIgnoreCase('')) ? sObjectName : '' + sObjectName;
            }
            sObjectType = globalDescribe.get(sObjectName);
        }

        if (sObjectType != null) {
            // ✅ Already using DEFERRED
            Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED);
            if (describeResult != null) {
                allFields = buildFieldList(describeResult, ignoredFieldsSet);
            }
        }

        if (String.isEmpty(allFields)) { allFields = ' Name '; }
        return String.escapeSingleQuotes(allFields);
    }

    private static String buildFieldList(Schema.DescribeSObjectResult describeResult, Set<String> ignoredFieldsSet) {
        Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();
        Set<String> allFieldsSet = new Set<String>();
        for (String fieldName : fieldMap.keySet()) {
            // ✅ getDescribe() on SObjectField does not take options - this is correct as-is
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            if (fieldDescribe.isAccessible() && !ignoredFieldsSet.contains(fieldName)) {
                allFieldsSet.add(fieldName);
            }
        }
        return String.join(new List<String>(allFieldsSet), ',');
    }

    /**
     * @description Returns the API names from the requested field set.
     * @param sObjectName API name of the target sObject.
     * @param fieldSetApiName API name of the field set.
     * @return Field API names in field-set order.
     */
    public static List<String> getFieldsSetApiName(String sObjectName, String fieldSetApiName) {
        List<String> fields = new List<String>();
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        // ✅ Added DEFERRED
        for (Schema.FieldSetMember field : globalDescribe.get(sObjectName).getDescribe(SObjectDescribeOptions.DEFERRED).fieldSets.getMap().get(fieldSetApiName).getFields()) {
            fields.add(field.getFieldPath());
        }
        return fields;
    }

    /**
     * @description Returns the display labels from the requested field set.
     * @param sObjectName API name of the target sObject.
     * @param fieldSetApiName API name of the field set.
     * @return Field labels in field-set order.
     */
    public static List<String> getFieldsSetLabelName(String sObjectName, String fieldSetApiName) {
        List<String> fields = new List<String>();
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        // ✅ Added DEFERRED
        for (Schema.FieldSetMember field : globalDescribe.get(sObjectName).getDescribe(SObjectDescribeOptions.DEFERRED).fieldSets.getMap().get(fieldSetApiName).getFields()) {
            fields.add(field.getLabel());
        }
        return fields;
    }

    /**
     * @description Validates field accessibility for the supplied sObject fields.
     * @param fieldsToCheck Field API names to validate.
     * @param sObjectName API name of the target sObject.
     */
    public static void flsCheck(String[] fieldsToCheck, String sObjectName) {
        try {
            Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
            Schema.SObjectType sObjectType = globalDescribe.get(sObjectName);

            if (sObjectType != null && globalDescribe.containsKey(sObjectName)) {
                validateFields(fieldsToCheck, sObjectType);
            }
        } catch (FLSException e) {
            return;
        } catch (Exception e) {
            return;
            //System.debug(LoggingLevel.DEBUG, 'Exception in flsCheck method of UtilClass_Sch class. Exception Message: ' + e.getMessage());
        }
    }

    private static void validateFields(String[] fieldsToCheck, Schema.SObjectType sObjectType) {
        // ✅ Added DEFERRED to both calls, cached into single describeResult
        Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED);
        Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();
        String sObjectLabel = describeResult.getLabel();

        for (String fieldToCheck : fieldsToCheck) {
            validateSingleField(fieldToCheck, fieldMap, sObjectLabel);
        }
    }

    private static void validateSingleField(String fieldToCheck, Map<String, Schema.SObjectField> fieldMap, String sObjectLabel) {
        String fieldKey = fieldToCheck.toLowerCase().trim();
        Schema.SObjectField sObjectField = fieldMap.get(fieldKey);

        if (sObjectField == null) {
            throw new FLSException('Invalid Field ' + fieldToCheck + ' does not belong to sObject ' + sObjectLabel);
        }

        Schema.DescribeFieldResult fieldDescribe = sObjectField.getDescribe();

        if (!fieldDescribe.isAccessible()) {
            throw new FLSException('Insufficient access To Field For Field ' + fieldToCheck +
                '(API NAME) ' + fieldDescribe.getLabel() + ' of sObject ' + sObjectLabel);
        }
    }

    /**
     * @description Exception raised when field-level security validation fails.
     */
    public class FLSException extends Exception {}
}