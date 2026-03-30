/**
 * @description DML result handling helpers for queue expert validation flows.
 */
public with sharing class QueueExpertAccessValidationDmlSupport {
    /**
     * @description Throws an AuraHandledException when an insert result contains an error.
     * @param saveResult Database insert result to inspect.
     * @param errorMessage Base error message to include in the exception.
     */
    public static void saveInsertResult(Database.SaveResult saveResult, String errorMessage) {
        throwIfSaveFailed(saveResult, errorMessage);
    }

    /**
     * @description Throws an AuraHandledException when an update result contains an error.
     * @param saveResult Database update result to inspect.
     * @param errorMessage Base error message to include in the exception.
     */
    public static void saveUpdateResult(Database.SaveResult saveResult, String errorMessage) {
        throwIfSaveFailed(saveResult, errorMessage);
    }

    /**
     * @description Throws an AuraHandledException when a delete result contains an error.
     * @param deleteResult Database delete result to inspect.
     * @param errorMessage Base error message to include in the exception.
     */
    public static void saveDeleteResult(Database.DeleteResult deleteResult, String errorMessage) {
        if (deleteResult == null || !deleteResult.isSuccess()) {
            throw buildDmlException(errorMessage, deleteResult == null ? null : deleteResult.getErrors());
        }
    }

    /**
     * @description Throws an AuraHandledException when a save result is null or unsuccessful.
     * @param saveResult Save result to inspect.
     * @param errorMessage Base error message to include in the exception.
     */
    private static void throwIfSaveFailed(Database.SaveResult saveResult, String errorMessage) {
        if (saveResult == null || !saveResult.isSuccess()) {
            throw buildDmlException(errorMessage, saveResult == null ? null : saveResult.getErrors());
        }
    }

    /**
     * @description Builds a DML exception with the first platform error appended when available.
     * @param errorMessage Base error message to include in the exception.
     * @param errors Platform errors returned by the DML operation.
     * @return AuraHandledException ready to be thrown.
     */
    private static AuraHandledException buildDmlException(String errorMessage, Database.Error[] errors) {
        String finalMessage = errorMessage;
        if (errors != null && !errors.isEmpty() && !String.isBlank(errors[0].getMessage())) {
            finalMessage += ' ' + errors[0].getMessage();
        }
        return new AuraHandledException(finalMessage);
    }
}
