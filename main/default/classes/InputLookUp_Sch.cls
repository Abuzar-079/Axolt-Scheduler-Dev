// public class InputLookUp_Sch {
// adnan  updated class to with sharing
/**
 * @description Provides lookup search helpers for Aura components.
 */
public with sharing class InputLookUp_Sch {
    /**
     * @description Request wrapper for lookup search inputs.
     */
    public class LookupRequest {
        @AuraEnabled public String searchKeyWord;
        @AuraEnabled public String objectName;
        @AuraEnabled public String queryFilter;
        @AuraEnabled public String searchField;
    }

    // commented by abuzar on 13-03-2026 for the scanning issue and added below line "ExcessiveParameterList, cognitive complexity, cyclomatic complexity and NCSS in fetchLookUpValues method"
    // @AuraEnabled
    // public static List<sObject> fetchLookUpValues(String searchKeyWord, String objectName, String queryFilter, String searchField) {
    //     //System.debug(LoggingLevel.DEBUG, 'ObjectName-->' + objectName+'  ,queryFilter==>'+queryFilter);
    //     String searchKey ='%' + String.escapeSingleQuotes(searchKeyWord) + '%';
    //     queryFilter = (String.isBlank(queryFilter))? '' : queryFilter;
    //     List<sObject> returnList = new List<sObject>();
    //     Integer lim = 20;
    //     String sQuery = 'SELECT Id, ' + String.escapeSingleQuotes(searchField) +
    //                     ' FROM ' + String.escapeSingleQuotes(objectName) +
    //                     ' WHERE ' + String.escapeSingleQuotes(searchField) + ' LIKE :searchKey ';
    //     if (!String.isBlank(queryFilter)) {
    //         sQuery += ' AND ' + String.escapeSingleQuotes(queryFilter) + ' ';
    //     }
    //     sQuery += ' ORDER BY CreatedDate DESC LIMIT 50';
    //     List<sObject> lstOfRecords = Database.query(sQuery);
    //     for (sObject obj : lstOfRecords) {
    //         returnList.add(obj);
    //     }
    //     Integer nameLength = 0;
    //     Integer index = 0;
    //     List<sObject> returnListFinal = new List<sObject>();
    //     returnListFinal.addAll(returnList);
    //     try {
    //         if (returnList.size() > lim && String.isNotEmpty(searchKeyWord)) {
    //             for (Integer i = 0; i < returnList.size(); i++) {
    //                 String nm = (String) returnList[i].get('Name');
    //                 Integer nameLengthRecod = nm.length();
    //                 if (i == 0) {
    //                     nameLength = nameLengthRecod;
    //                 }
    //                 if (nameLength > nameLengthRecod) {
    //                     nameLength = nameLengthRecod;
    //                     index = i;
    //                 }
    //             }
    //             for (Integer i = 0; i < lim; i++) {
    //                 returnListFinal.add(returnList[i]);
    //             }
    //             sObject firstObj = returnList[index];
    //             returnListFinal.remove(0);
    //             returnListFinal.add(0, firstObj);
    //             returnList = returnListFinal;
    //         } else {
    //             returnListFinal = returnList;
    //         }
    //         if (returnListFinal.size() > lim) {
    //             List<sObject> recordList = new List<sObject>();
    //             recordList.addAll(returnListFinal);
    //             returnListFinal.clear();
    //             for (Integer i = 0; i < lim; i++) {
    //                 returnListFinal.add(recordList[i]);
    //             }
    //         }
    //     } catch (Exception ex) {
    //         //System.debug(LoggingLevel.DEBUG, 'Exception in fetchLookUpValues method: ' + ex.getMessage());
    //     }
    //     return returnListFinal;
    // }
    /**
     * @description Fetches matching lookup records based on the supplied search request.
     * @param request Lookup search criteria including object, field, and filter values.
     * @return Matching records limited for lookup display.
     */
    @AuraEnabled                                                           //adnan changed param to camel case :- ObjectName-> objectName and SearchField -> searchField.. change reflected in SearchCompSch.js too
    public static List<sObject> fetchLookUpValues(LookupRequest request) {
        //System.debug(LoggingLevel.DEBUG, 'ObjectName-->' + request.objectName + '  ,queryFilter==>' + request.queryFilter);
        String searchKey = buildSearchKey(request.searchKeyWord);
        // commented by Abuzar on 25-03-2026 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING result path 4 and 6"
        // List<sObject> fetchedRecords = Database.query(buildLookupQuery(request, searchKey));
        List<sObject> fetchedRecords = Database.queryWithBinds(
            buildLookupQuery(request),
            new Map<String, Object>{ 'searchKey' => searchKey },
            AccessLevel.USER_MODE
        );
        //changes end here by Abuzar
        return prepareLookupResults(fetchedRecords, request.searchKeyWord);
    }

    private static String buildSearchKey(String searchKeyWord) {
        return '%' + String.escapeSingleQuotes(searchKeyWord) + '%';
    }

    private static String buildLookupQuery(LookupRequest request) {
        Schema.SObjectType objectType = getValidatedObjectType(request.objectName);
        String selectFields = getValidatedSelectFields(objectType, request.searchField);
        String primarySearchField = getPrimaryValidatedField(objectType, request.searchField);
        String safeQueryFilter = String.isBlank(request.queryFilter) ? '' : request.queryFilter;
        String sQuery = 'SELECT Id, ' + selectFields +
                        ' FROM ' + objectType.getDescribe().getName() +
                        ' WHERE ' + primarySearchField + ' LIKE :searchKey ';
        if (!String.isBlank(safeQueryFilter)) {
            sQuery += ' AND ' + String.escapeSingleQuotes(safeQueryFilter) + ' ';
        }
        return sQuery + ' ORDER BY CreatedDate DESC LIMIT 50';
    }

    private static List<sObject> prepareLookupResults(List<sObject> returnList, String searchKeyWord) {
        Integer lim = 20;
        List<sObject> returnListFinal = new List<sObject>();
        returnListFinal.addAll(returnList);
        try {
            if (shouldPrioritizeByNameLength(returnList, lim, searchKeyWord)) {
                returnListFinal = buildPrioritizedResults(returnList, lim);
            }
            return limitResults(returnListFinal, lim);
        } catch (Exception ex) {
            //System.debug(LoggingLevel.DEBUG, 'Exception in fetchLookUpValues method: ' + ex.getMessage());
            return limitResults(returnListFinal, lim);
        }
    }

    private static Boolean shouldPrioritizeByNameLength(List<sObject> returnList, Integer lim, String searchKeyWord) {
        return returnList.size() > lim && String.isNotEmpty(searchKeyWord);
    }

    private static List<sObject> buildPrioritizedResults(List<sObject> returnList, Integer lim) {
        List<sObject> prioritizedResults = new List<sObject>();
        prioritizedResults.addAll(returnList);
        for (Integer i = 0; i < lim; i++) {
            prioritizedResults.add(returnList[i]);
        }
        Integer shortestNameIndex = findShortestNameIndex(returnList);
        prioritizedResults.remove(0);
        prioritizedResults.add(0, returnList[shortestNameIndex]);
        return prioritizedResults;
    }

    private static Integer findShortestNameIndex(List<sObject> returnList) {
        Integer shortestNameLength = 0;
        Integer shortestNameIndex = 0;
        for (Integer i = 0; i < returnList.size(); i++) {
            String recordName = (String) returnList[i].get('Name');
            Integer currentNameLength = recordName.length();
            if (i == 0 || shortestNameLength > currentNameLength) {
                shortestNameLength = currentNameLength;
                shortestNameIndex = i;
            }
        }
        return shortestNameIndex;
    }

    private static List<sObject> limitResults(List<sObject> records, Integer lim) {
        if (records.size() <= lim) {
            return records;
        }
        List<sObject> limitedRecords = new List<sObject>();
        for (Integer i = 0; i < lim; i++) {
            limitedRecords.add(records[i]);
        }
        return limitedRecords;
    }
    //changes end here by abuzar

    /**
     * @description Fetches a single lookup record by Id for the requested object and field.
     * @param objectName API name of the target object.
     * @param searchField API name of the display field to query.
     * @param recordId Identifier of the record to fetch.
     * @return Matching record, or `null` when no record is found.
     */
    @AuraEnabled                              //adnan changed Case of ObjectName and SearchField and in search comp
    public static sObject fetchLookUpValueById(String objectName,String searchField,String recordId) {
        Schema.SObjectType objectType = getValidatedObjectType(objectName);
        String selectFields = getValidatedSelectFields(objectType, searchField);
        // commented by Abuzar on 25-03-2026 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING result path 1, 2 and 7"
        // String sQuery =  'SELECT Id, ' + selectFields +
        //                  ' FROM ' + objectType.getDescribe().getName() +
        //                  ' WHERE Id = :recordId LIMIT 1000';
        // List < sObject > lstOfRecords = Database.query(sQuery);
        String sQuery =  'SELECT Id, ' + selectFields +
                         ' FROM ' + objectType.getDescribe().getName() +
                         ' WHERE Id = :recordId LIMIT 1000';
        List<sObject> lstOfRecords = Database.queryWithBinds(
            sQuery,
            new Map<String, Object>{ 'recordId' => recordId },
            AccessLevel.USER_MODE
        );
        //changes end here by Abuzar
        if(lstOfRecords.size()>0){return lstOfRecords[0];} return null; //adnan brackets for if
    }

    /**
     * @description Finds records by name prefix for the given object.
     * @param searchKey Name prefix entered by the user.
     * @param objectName API name of the object to search.
     * @return Matching records containing `Id` and `Name`.
     */
   @AuraEnabled(cacheable=true)
public static List<sobject> findRecords(String searchKey, String objectName) {
    // 1. Prepare the search string with the wildcard, NO manual quotes needed!
    String searchText = searchKey + '%';
    Schema.SObjectType objectType = getValidatedObjectType(objectName);
    
    // 2. Build the query string using a bind variable (:searchText)
    // commented by Abuzar on 25-03-2026 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING result path 3 and 5"
    // String query = 'SELECT Id, Name FROM ' + objectType.getDescribe().getName() + ' WHERE Name LIKE :searchText LIMIT 10';
    // return Database.query(query);
    String query = 'SELECT Id, Name FROM ' + objectType.getDescribe().getName() + ' WHERE Name LIKE :searchText LIMIT 10';
    
    // 3. Execute the query
    List<sObject> records = Database.queryWithBinds(
        query,
        new Map<String, Object>{ 'searchText' => searchText },
        AccessLevel.USER_MODE
    );
    //changes end here by Abuzar
    return records;
}

    private static Schema.SObjectType getValidatedObjectType(String objectName) {
        if (String.isBlank(objectName)) {
            throw new AuraHandledException('Invalid object name');
        }
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName.trim());
        if (objectType == null) {
            throw new AuraHandledException('Invalid object name');
        }
        return objectType;
    }

    private static String getValidatedSelectFields(Schema.SObjectType objectType, String fieldList) {
        return String.join(getValidatedFieldNames(objectType, fieldList), ', ');
    }

    private static String getPrimaryValidatedField(Schema.SObjectType objectType, String fieldList) {
        return getValidatedFieldNames(objectType, fieldList)[0];
    }

    private static List<String> getValidatedFieldNames(Schema.SObjectType objectType, String fieldList) {
        // 1. Guard clause for initial input
        if (String.isBlank(fieldList)) {
            throw new AuraHandledException('Invalid search field');
        }
        Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
        List<String> validatedFields = new List<String>();
        for (String rawFieldName : fieldList.split(',')) {
            String fieldName = String.isNotBlank(rawFieldName) ? rawFieldName.trim() : '';
            // 2. Combined validation check
            if (String.isBlank(fieldName) || !fieldMap.containsKey(fieldName)) {
                throw new AuraHandledException('Invalid search field');
            }
            validatedFields.add(fieldMap.get(fieldName).getDescribe().getName());
        }
        // 3. Final check (Optional: If the loop finishes, validatedFields is guaranteed to have items)
        return validatedFields;
    }
}