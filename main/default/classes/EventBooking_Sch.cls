public static String getCreateContact(String regs, String contactId) {
    List<Registration_SCH__c> regList = deserializeRegistrationList(regs);
    if (regList.isEmpty()) {
        return null;
    }

    RegistrationBuildContext context = buildRegistrationContext(regList[0], contactId);
    List<Registration_SCH__c> rList = buildRegistrationContactAssignments(regList, context);
    List<Registration_SCH__c> registrationsToInsert = buildSafeRegistrationInserts(rList, context);
    List<Registration_SCH__c> registrationsToUpdate = buildSafeRegistrationUpdates(rList, context);

    insertRegistrationsInUserMode(registrationsToInsert);
    updateRegistrationsInUserMode(registrationsToUpdate);
    return getFirstRegistrationId(rList);
}

private static List<Registration_SCH__c> deserializeRegistrationList(String regs) {
    if (String.isBlank(regs)) {
        return new List<Registration_SCH__c>();
    }
    List<Registration_SCH__c> registrations =
        (List<Registration_SCH__c>) JSON.deserialize(regs, List<Registration_SCH__c>.class);
    return registrations == null ? new List<Registration_SCH__c>() : registrations;
}

private static RegistrationBuildContext buildRegistrationContext(Registration_SCH__c firstReg, String contactId) {
    List<Contact> conList = fetchContactsForRegistration(firstReg);
    RegistrationBuildContext context = new RegistrationBuildContext();
    context.conList = conList;
    context.contactId = contactId;
    context.canCreateContact = Schema.sObjectType.Contact.isCreateable();
    context.canSetFirstName = Schema.sObjectType.Contact.fields.FirstName.isCreateable();
    context.canSetLastName = Schema.sObjectType.Contact.fields.LastName.isCreateable();
    context.canSetMobile = Schema.sObjectType.Contact.fields.MobilePhone.isCreateable();
    context.canSetEmail = Schema.sObjectType.Contact.fields.Email.isCreateable();
    context.canSetEvent = Schema.sObjectType.Contact.fields.Event__c.isCreateable();
    context.canCreateReg = Schema.sObjectType.Registration_SCH__c.isCreateable();
    context.canSetRegContact = Schema.sObjectType.Registration_SCH__c.fields.Contact__c.isCreateable() ||
        Schema.sObjectType.Registration_SCH__c.fields.Contact__c.isUpdateable();
    context.canCreateRegContact = Schema.sObjectType.Registration_SCH__c.fields.Contact__c.isCreateable();
    context.canUpdateReg = Schema.sObjectType.Registration_SCH__c.isUpdateable();
    context.canUpdateRegContact = Schema.sObjectType.Registration_SCH__c.fields.Contact__c.isUpdateable();
    return context;
}

private static void assertRegistrationCreateAccess() {
    if (!Schema.sObjectType.Registration_SCH__c.isCreateable()) {
        throw new AuraHandledException('You do not have permission to create registrations.');
    }
}

private static void assertRegistrationUpdateAccess() {
    if (!Schema.sObjectType.Registration_SCH__c.isUpdateable()) {
        throw new AuraHandledException('You do not have permission to update registrations.');
    }
}

private static void assertRegistrationFieldCreateable(String fieldApiName) {
    Schema.SObjectField fieldRef = Schema.sObjectType.Registration_SCH__c.fields.getMap().get(fieldApiName);
    if (fieldRef == null || !fieldRef.getDescribe().isCreateable()) {
        throw new AuraHandledException('You do not have permission to create registration field ' + fieldApiName + '.');
    }
}

private static void assertRegistrationFieldUpdateable(String fieldApiName) {
    Schema.SObjectField fieldRef = Schema.sObjectType.Registration_SCH__c.fields.getMap().get(fieldApiName);
    if (fieldRef == null || !fieldRef.getDescribe().isUpdateable()) {
        throw new AuraHandledException('You do not have permission to update registration field ' + fieldApiName + '.');
    }
}

private static List<Registration_SCH__c> buildSafeRegistrationInserts(
    List<Registration_SCH__c> registrations,
    RegistrationBuildContext context
) {
    List<Registration_SCH__c> registrationsToInsert = new List<Registration_SCH__c>();
    if (registrations.isEmpty()) {
        return registrationsToInsert;
    }

    Map<String, Schema.SObjectField> regFieldSchema = Schema.sObjectType.Registration_SCH__c.fields.getMap();
    for (Registration_SCH__c regRecord : registrations) {
        if (regRecord.Id != null) {
            continue;
        }
        Registration_SCH__c sanitized = new Registration_SCH__c();
        Map<String, Object> populated = regRecord.getPopulatedFieldsAsMap();
        for (String fieldName : populated.keySet()) {
            if (fieldName == 'Id' || !regFieldSchema.containsKey(fieldName)) {
                continue;
            }
            if (!regFieldSchema.get(fieldName).getDescribe().isCreateable()) {
                continue;
            }
            if (fieldName == 'Contact__c' && !context.canCreateRegContact) {
                continue;
            }
            sanitized.put(fieldName, populated.get(fieldName));
        }
        registrationsToInsert.add(sanitized);
    }
    if (registrationsToInsert.isEmpty()) {
        return registrationsToInsert;
    }

    assertRegistrationCreateAccess();
    for (Registration_SCH__c insertRecord : registrationsToInsert) {
        Map<String, Object> populatedInsertFields = insertRecord.getPopulatedFieldsAsMap();
        for (String fieldName : populatedInsertFields.keySet()) {
            if (fieldName == 'Id') {
                continue;
            }
            assertRegistrationFieldCreateable(fieldName);
        }
    }
    return (List<Registration_SCH__c>) Security.stripInaccessible(
        Security.AccessType.CREATABLE,
        registrationsToInsert
    ).getRecords();
}

private static List<Registration_SCH__c> buildSafeRegistrationUpdates(
    List<Registration_SCH__c> registrations,
    RegistrationBuildContext context
) {
    List<Registration_SCH__c> registrationsToUpdate = new List<Registration_SCH__c>();
    Boolean hasExistingRegistrations = false;
    if (registrations.isEmpty()) {
        return registrationsToUpdate;
    }

    for (Registration_SCH__c regRecord : registrations) {
        if (regRecord.Id == null) {
            continue;
        }
        hasExistingRegistrations = true;
        Registration_SCH__c updateRecord = new Registration_SCH__c(Id = regRecord.Id);
        if (context.canUpdateRegContact) {
            updateRecord.Contact__c = regRecord.Contact__c;
        }
        if (updateRecord.getPopulatedFieldsAsMap().size() > 1) {
            registrationsToUpdate.add(updateRecord);
        }
    }
    if (!hasExistingRegistrations) {
        return registrationsToUpdate;
    }

    assertRegistrationUpdateAccess();
    assertRegistrationFieldUpdateable('Contact__c');
    if (registrationsToUpdate.isEmpty()) {
        return registrationsToUpdate;
    }
    return (List<Registration_SCH__c>) Security.stripInaccessible(
        Security.AccessType.UPDATABLE,
        registrationsToUpdate
    ).getRecords();
}

private static void insertRegistrationsInUserMode(List<Registration_SCH__c> registrationsToInsert) {
    if (registrationsToInsert.isEmpty()) {
        return;
    }
    Database.SaveResult[] saveResults = Database.insert(registrationsToInsert, false, AccessLevel.USER_MODE);
    handleRegistrationSaveResults(saveResults, 'create');
}

private static void updateRegistrationsInUserMode(List<Registration_SCH__c> registrationsToUpdate) {
    if (registrationsToUpdate.isEmpty()) {
        return;
    }
    Database.SaveResult[] saveResults = Database.update(registrationsToUpdate, false, AccessLevel.USER_MODE);
    handleRegistrationSaveResults(saveResults, 'update');
}

private static void handleRegistrationSaveResults(Database.SaveResult[] saveResults, String operationName) {
    List<String> errors = new List<String>();
    for (Database.SaveResult saveResult : saveResults) {
        if (saveResult.isSuccess()) {
            continue;
        }
        for (Database.Error saveError : saveResult.getErrors()) {
            if (saveError != null && String.isNotBlank(saveError.getMessage())) {
                errors.add(saveError.getMessage());
            }
        }
    }
    if (!errors.isEmpty()) {
        throw new AuraHandledException(
            'Unable to ' + operationName + ' registration contact assignments. ' + String.join(errors, ' ')
        );
    }
}

private class RegistrationBuildContext {
    private List<Contact> conList;
    private String contactId;
    private Boolean canCreateContact;
    private Boolean canSetFirstName;
    private Boolean canSetLastName;
    private Boolean canSetMobile;
    private Boolean canSetEmail;
    private Boolean canSetEvent;
    private Boolean canCreateReg;
    private Boolean canSetRegContact;
    private Boolean canCreateRegContact;
    private Boolean canUpdateReg;
    private Boolean canUpdateRegContact;

    private RegistrationBuildContext() {
        this.contactId = this.contactId;
    }

    private ContactFieldAccess getContactFieldAccess() {
        ContactFieldAccess access = new ContactFieldAccess();
        access.canSetFirstName = canSetFirstName;
        access.canSetLastName = canSetLastName;
        access.canSetMobile = canSetMobile;
        access.canSetEmail = canSetEmail;
        access.canSetEvent = canSetEvent;
        return access;
    }
}
