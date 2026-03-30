/**
 * @description Payload parsing and registration field-application helpers for queue expert validation flows.
 */
public with sharing class QueueExpertAccessValidationPayloadSupport {
    /**
     * @description Deserializes client-submitted values for record updates.
     * @param payload Serialized payload from the client.
     * @param errorMessage Error message to throw when deserialization fails.
     * @return Deserialized list of values.
     */
    public static List<String> deserializeSubmittedValues(String payload, String errorMessage) {
        QueueExpertAccessValidationSupport.validateNotBlank(payload, errorMessage);
        try {
            List<String> submittedValues = (List<String>)JSON.deserialize(payload, List<String>.class);
            return submittedValues == null ? new List<String>() : submittedValues;
        } catch (JSONException ex) {
            throw new AuraHandledException(errorMessage);
        }
    }

    /**
     * @description Applies approved record-update values to the target registration.
     * @param registrationToUpdate Registration record being prepared for update.
     * @param recordValues Ordered values submitted by the client.
     * @param updateFieldsByIndex Supported field mapping keyed by list index.
     */
    public static void applyApprovedUpdateRecordValues(
        Registration_SCH__c registrationToUpdate,
        List<String> recordValues,
        Map<Integer, String> updateFieldsByIndex
    ) {
        for (Integer indexValue : updateFieldsByIndex.keySet()) {
            if (recordValues.size() > indexValue) {
                registrationToUpdate.put(
                    updateFieldsByIndex.get(indexValue),
                    QueueExpertAccessValidationSupport.normalizeForField(recordValues[indexValue])
                );
            }
        }
        if (recordValues.size() >= 15) {
            registrationToUpdate.Status__c = 'Completed';
        }
    }
}
