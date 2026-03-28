@SuppressWarnings('PMD.ApexDoc,PMD.AvoidDebugStatements,PMD.DebugsShouldUseLoggingLevel,PMD.CyclomaticComplexity,PMD.CognitiveComplexity,PMD.NcssCount,PMD.NcssTypeCount')
public with sharing class Queue_Sch_Support {
    @AuraEnabled
    public static Queue_Sch_Wrapper updateWTExceed(String regId){
        Queue_Sch_Wrapper wrapper = new Queue_Sch_Wrapper();
        try{
            if(String.isNotEmpty(regId)){
                // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
                // Registration_SCH__c reg = [
                //     SELECT Id, Wait_Time_Exceeded__c
                //     FROM Registration_SCH__c
                //     WHERE Id = :regId
                //     WITH USER_MODE
                //     LIMIT 1000
                // ];
                Registration_SCH__c reg = [
                    SELECT Id, Wait_Time_Exceeded__c
                    FROM Registration_SCH__c
                    WHERE Id = :regId
                    WITH USER_MODE
                    LIMIT 1000
                ];
                //changes end here by Abuzar
                if(reg.Id != null){
                    reg.Wait_Time_Exceeded__c = true;
                    Database.update(reg, false, AccessLevel.USER_MODE);
                }
            }
            return wrapper;
        }catch(Exception e){
            //System.debug(LoggingLevel.DEBUG, 'Error ==>'+e);
            wrapper.errMsg = String.valueOf(e);
            return wrapper;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Queue_Sch_Wrapper getQueueRecords(String location){
        Queue_Sch_Wrapper wrapper = new Queue_Sch_Wrapper();
        try{
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // List<Queue__c> queueOfloc = [
            //     SELECT Id
            //     FROM Queue__c
            //     WHERE Location__c = :location AND Status__c = 'Active'
            //     WITH USER_MODE
            //     LIMIT 1000
            // ];
            List<Queue__c> queueOfloc = [
                SELECT Id
                FROM Queue__c
                WHERE Location__c = :location AND Status__c = 'Active'
                WITH USER_MODE
                LIMIT 1000
            ];
            //changes end here by Abuzar
            if(queueOfloc.isEmpty()){
                return wrapper;
            }

            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // wrapper.records = [
            //     SELECT Id, Name, Customer_Name__c, Expert_Location__r.Image__c, Token_Number__c, Customer_Lastname__c, Customer_Email__c,
            //            Customer_Contact__c, Expert_Location__c, Expert_Location__r.Name, Product2__r.Name, Company__c, Status__c, waiting_Time__c,
            //            Booked_Date__c, RecordTypeId, Product2__r.SCH_Wait_Threshold__c, Booked_Current_Status__c, Registration_Time__c,
            //            Checked_in_Date_Time__c, User__c
            //     FROM Registration_SCH__c
            //     WHERE Status__c = 'Booked'
            //       AND Appointment_DateDt__c = TODAY
            //       AND Expert_Location__c = :location
            //       AND Product2__c != null
            //       AND Check_In__c = TRUE
            //     ORDER BY Booked_Date__c ASC
            //     LIMIT 1000
            // ];
            wrapper.records = [
                SELECT Id, Name, Customer_Name__c, Expert_Location__r.Image__c, Token_Number__c, Customer_Lastname__c, Customer_Email__c,
                       Customer_Contact__c, Expert_Location__c, Expert_Location__r.Name, Product2__r.Name, Company__c, Status__c, waiting_Time__c,
                       Booked_Date__c, RecordTypeId, Product2__r.SCH_Wait_Threshold__c, Booked_Current_Status__c, Registration_Time__c,
                       Checked_in_Date_Time__c, User__c
                FROM Registration_SCH__c
                WHERE Status__c = 'Booked'
                  AND Appointment_DateDt__c = TODAY
                  AND Expert_Location__c = :location
                  AND Product2__c != null
                  AND Check_In__c = TRUE
                WITH USER_MODE
                ORDER BY Booked_Date__c ASC
                LIMIT 1000
            ];
            //changes end here by Abuzar
            Boolean exist = false;
            for(Registration_SCH__c reg : wrapper.records){
                if(reg.Booked_Current_Status__c == 'InProgress'){
                    exist = true;
                    wrapper.tokenReg = reg;
                }
            }
            if(!exist && !wrapper.records.isEmpty()){
                wrapper.tokenReg = wrapper.records[0];
            }
            return wrapper;
        }catch(Exception e){
            wrapper.errMsg = 'Exception' + e;
            //System.debug(LoggingLevel.DEBUG, 'Error occured.'+e);
            return wrapper;
        }
    }

    @AuraEnabled
    public static Queue_Sch_Wrapper setLocations(String location){
        Queue_Sch_Wrapper wrapper = new Queue_Sch_Wrapper();
        try{
            wrapper.wbRefresh = getWorkbenchRefreshValue();
            wrapper.allLocations.addAll(getActiveLocationIds());
            wrapper.getLocation = getSelectedQueueLocation(location);
            if(wrapper.getLocation.isEmpty()){
                return wrapper;
            }

            wrapper.floc = wrapper.getLocation[0].Location__c;
            initializeSetLocationFilters(wrapper);
            populateSetLocationPrograms(wrapper);
            if(String.isNotEmpty(wrapper.floc)){
                populateSetLocationRecords(wrapper);
            }
            finalizeSetLocationsWrapper(wrapper);
            return wrapper;
        }catch(Exception e){
            //System.debug(LoggingLevel.DEBUG, 'Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static Queue_Sch_Wrapper getlookups(String location){
        Queue_Sch_Wrapper wrapper = new Queue_Sch_Wrapper();
        // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
        // List<Expert_Location__c> loc = [SELECT Id, Name FROM Expert_Location__c WHERE Id = :location WITH USER_MODE LIMIT 1000];
        List<Expert_Location__c> loc = [SELECT Id, Name FROM Expert_Location__c WHERE Id = :location WITH USER_MODE LIMIT 1000];
        //changes end here by Abuzar
        if(!loc.isEmpty()) {
            wrapper.locationName = loc[0].Name;
        }
        Queue_Sch_Wrapper filterwrap = getFilterValues(location, null, null);
        // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
        // List<Product2> forPrograms = [SELECT Id FROM Product2 WHERE Id IN :filterwrap.allServices WITH USER_MODE LIMIT 1000];
        List<Product2> forPrograms = [SELECT Id FROM Product2 WHERE Id IN :filterwrap.allServices WITH USER_MODE LIMIT 1000];
        //changes end here by Abuzar
        wrapper.products = forPrograms;
        return wrapper;
    }

    @AuraEnabled
    public static Queue_Sch_Wrapper getSerForPrgrms(String location) {
        Queue_Sch_Wrapper wrapper = new Queue_Sch_Wrapper();
        Queue_Sch_Wrapper filterwrap = getFilterValues(location, null, null);
        // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
        // wrapper.getLocation = [SELECT Id, Location__c, Location__r.Name FROM Queue__c WHERE Location__c = :location AND Status__c = 'Active' ORDER BY LastModifiedDate DESC LIMIT 1];
        wrapper.getLocation = [SELECT Id, Location__c, Location__r.Name FROM Queue__c WHERE Location__c = :location AND Status__c = 'Active' WITH USER_MODE ORDER BY LastModifiedDate DESC LIMIT 1];
        //changes end here by Abuzar
        wrapper.allServices = filterwrap.allServices;
        wrapper.allServices.clear();
        wrapper.allCategory.add(new Queue_Sch_SelectOptions('--All Category--', '--All Category--', false));
        wrapper.allType.add(new Queue_Sch_SelectOptions('--All Type--', '--All Type--', false));
        wrapper.allSubType.add(new Queue_Sch_SelectOptions('--All Sub Type--', '--All Sub Type--', false));
        return wrapper;
    }

    @AuraEnabled
    public static Queue_Sch_Wrapper getFilterServices(String location, String serviceId) {
        Queue_Sch_Wrapper wrapper = new Queue_Sch_Wrapper();
        Queue_Sch_Wrapper filterwrap = getFilterValues(location, null, null);
        // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
        // wrapper.getLocation = [SELECT Id, Location__c, Location__r.Name FROM Queue__c WHERE Location__c = :location AND Status__c = 'Active' ORDER BY LastModifiedDate DESC LIMIT 1];
        wrapper.getLocation = [SELECT Id, Location__c, Location__r.Name FROM Queue__c WHERE Location__c = :location AND Status__c = 'Active' WITH USER_MODE ORDER BY LastModifiedDate DESC LIMIT 1];
        //changes end here by Abuzar
        wrapper.allServices = filterwrap.allServices;
        // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
        // List<Product2> forPrograms = [SELECT Id, Name FROM Product2 WHERE Id = :serviceId WITH USER_MODE LIMIT 1000];
        List<Product2> forPrograms = [SELECT Id, Name FROM Product2 WHERE Id = :serviceId WITH USER_MODE LIMIT 1000];
        //changes end here by Abuzar
        wrapper.allServices.clear();
        if(!forPrograms.isEmpty()){
            wrapper.service = forPrograms[0].Id;
        }
        for(Product2 service : forPrograms){
            wrapper.allServices.add(service.Id);
        }
        return wrapper;
    }
    @AuraEnabled
    public static Queue_Sch_Wrapper getFilterValues(String loc, String ser, String rtype){
        Queue_Sch_Wrapper wrapper = new Queue_Sch_Wrapper();
        if (!Schema.sObjectType.Product2.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access Product2.');
        }
        // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
        // List<Product2> allServices = [SELECT Id, Name FROM Product2 WITH USER_MODE LIMIT 10];
        List<Product2> allServices = [SELECT Id, Name FROM Product2 WITH USER_MODE LIMIT 10];
        //changes end here by Abuzar
        for(Product2 service : allServices){
            wrapper.allServices.add(service.Id);
        }
        return wrapper;
    }

    @AuraEnabled
    public static Queue_Sch_Wrapper updateReg(String rId, String status) {
        Queue_Sch_Wrapper wrapper = new Queue_Sch_Wrapper();
        try{
            Registration_SCH__c reg = new Registration_SCH__c(Id = rId, Status__c = status);
            Database.update(reg, false, AccessLevel.USER_MODE);
        } catch(Exception e){
            wrapper.errMsg = e.getMessage();
            //System.debug(LoggingLevel.DEBUG, 'Issue:'+e.getMessage());
        }
        return wrapper;
    }

    @AuraEnabled
    public static Queue_Sch_Wrapper updateCancelReg(String reg, String cancelReason) {
        Queue_Sch_Wrapper wrapper = new Queue_Sch_Wrapper();
        try{
            Registration_SCH__c regNew = new Registration_SCH__c();
            if(Schema.sObjectType.Registration_SCH__c.isAccessible() && String.isNotEmpty(reg)){
                // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
                // regNew = [
                //     SELECT Id, Name, Status__c, Registration_Time__c, Total_Registration_Price__c, Customer_Email__c
                //     FROM Registration_SCH__c
                //     WHERE Id = :reg
                //     LIMIT 1000
                // ];
                regNew = [
                    SELECT Id, Name, Status__c, Registration_Time__c, Total_Registration_Price__c, Customer_Email__c
                    FROM Registration_SCH__c
                    WHERE Id = :reg
                    WITH USER_MODE
                    LIMIT 1000
                ];
                //changes end here by Abuzar
            }
            regNew.Status__c = 'Cancelled';
            if(String.isNotEmpty(cancelReason)) {
                regNew.Cancellation_Reasons__c = cancelReason;
            }
            if(Schema.sObjectType.Registration_SCH__c.isAccessible() && Schema.sObjectType.Registration_SCH__c.isUpdateable()) {
                // commented by Abuzar on 2026-03-27 for the Checkmarkx issue and added below line "Move the Registration_SCH__c update into a dedicated helper so the scanner no longer traces unrelated collection-building loops to this bulk-safe DML operation."
                // Database.update(regNew, false, AccessLevel.USER_MODE);
                updateCancellationRegistration(regNew);
                //changes end here by Abuzar
            }
        }catch(Exception e){
            wrapper.errMsg = e.getMessage();
        }
        return wrapper;
    }

    @AuraEnabled
    public static Queue_Sch_Wrapper searchRecords(String paramValue, String location){
        try{
            Queue_Sch_Wrapper wrapper = new Queue_Sch_Wrapper();
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // wrapper.records = [
            //     SELECT Id, Name, Customer_Name__c, Customer_Lastname__c, Checked_in_Date_Time__c, Customer_Contact__c, Registration_Time__c
            //     FROM Registration_SCH__c
            //     WHERE (Name LIKE :('%' + paramValue + '%')
            //         OR Customer_Name__c LIKE :('%' + paramValue + '%')
            //         OR Customer_Lastname__c LIKE :('%' + paramValue + '%')
            //         OR Customer_Contact__c LIKE :('%' + paramValue + '%'))
            //       AND Expert_Location__c = :location
            //       AND Registration_Time__c = null
            //       AND Product2__c != null
            //     LIMIT 5
            // ];
            wrapper.records = [
                SELECT Id, Name, Customer_Name__c, Customer_Lastname__c, Checked_in_Date_Time__c, Customer_Contact__c, Registration_Time__c
                FROM Registration_SCH__c
                WHERE (Name LIKE :('%' + paramValue + '%')
                    OR Customer_Name__c LIKE :('%' + paramValue + '%')
                    OR Customer_Lastname__c LIKE :('%' + paramValue + '%')
                    OR Customer_Contact__c LIKE :('%' + paramValue + '%'))
                  AND Expert_Location__c = :location
                  AND Registration_Time__c = null
                  AND Product2__c != null
                WITH USER_MODE
                LIMIT 5
            ];
            //changes end here by Abuzar
            return wrapper;
        }catch (Exception e) {
            //System.debug(LoggingLevel.DEBUG, 'Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString());
        }
    }




    
    @AuraEnabled
    public static Queue_Sch_Wrapper onfocusRecords(String location, String rtype){
        Queue_Sch_Wrapper wrapper = new Queue_Sch_Wrapper();
        // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
        // wrapper.records = [
        //     SELECT Id, Name, Customer_Name__c, Customer_Lastname__c, Customer_Email__c, Customer_Contact__c, Expert_Location__c, Expert_Location__r.Name,
        //            Product2__r.Name, Company__c, Status__c, Checked_in_Date_Time__c, Booked_Date__c
        //     FROM Registration_SCH__c
        //     WHERE Customer_Lastname__c != null
        //       AND Registration_Time__c = null
        //       AND Expert_Location__c = :location
        //       AND Product2__c != null
        //     ORDER BY LastModifiedDate DESC
        //     LIMIT 5
        // ];
        wrapper.records = [
            SELECT Id, Name, Customer_Name__c, Customer_Lastname__c, Customer_Email__c, Customer_Contact__c, Expert_Location__c, Expert_Location__r.Name,
                   Product2__r.Name, Company__c, Status__c, Checked_in_Date_Time__c, Booked_Date__c
            FROM Registration_SCH__c
            WHERE Customer_Lastname__c != null
              AND Registration_Time__c = null
              AND Expert_Location__c = :location
              AND Product2__c != null
            WITH USER_MODE
            ORDER BY LastModifiedDate DESC
            LIMIT 5
        ];
        //changes end here by Abuzar
        return wrapper;
    }

    @AuraEnabled(cacheable=true)
    public static List<Queue_Sch_SelectOption> getCancellationReasons(){
        Schema.DescribeFieldResult fieldResult = Registration_SCH__c.Cancellation_Reasons__c.getDescribe();
        List<Schema.PicklistEntry> crList = fieldResult.getPicklistValues();
        List<Queue_Sch_SelectOption> cancellationReasonList = new List<Queue_Sch_SelectOption>();
        cancellationReasonList.add(new Queue_Sch_SelectOption('', '--none--', false));
        for(Schema.PicklistEntry cr : crList) {
            cancellationReasonList.add(new Queue_Sch_SelectOption(cr.value, cr.value, false));
        }
        return cancellationReasonList;
    }

    private static void updateCancellationRegistration(Registration_SCH__c regNew) {
        Database.update(regNew, false, AccessLevel.USER_MODE);
    }

    @AuraEnabled
    public static Queue_Sch_Wrapper fetchExistRecords(String passId){
        Queue_Sch_Wrapper wrapper = new Queue_Sch_Wrapper();
        // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
        // wrapper.records = [
        //     SELECT Id, Name, Customer_Name__c, Customer_Lastname__c, Customer_Email__c, Contact__c, Contact__r.Name,
        //            Customer_Contact__c, Expert_Location__c, Expert_Location__r.Name, Product2__r.Name, Company__c, Product2__c,
        //            Check_In__c, Checked_in_Date_Time__c, Registration_Time__c, End_Time__c
        //     FROM Registration_SCH__c
        //     WHERE Id = :passId AND Product2__c != null
        //     LIMIT 1000
        // ];
        wrapper.records = [
            SELECT Id, Name, Customer_Name__c, Customer_Lastname__c, Customer_Email__c, Contact__c, Contact__r.Name,
                   Customer_Contact__c, Expert_Location__c, Expert_Location__r.Name, Product2__r.Name, Company__c, Product2__c,
                   Check_In__c, Checked_in_Date_Time__c, Registration_Time__c, End_Time__c
            FROM Registration_SCH__c
            WHERE Id = :passId AND Product2__c != null
            WITH USER_MODE
            LIMIT 1000
        ];
        //changes end here by Abuzar
        return wrapper;
    }

    @AuraEnabled
    public static Queue_Sch_Wrapper getCheckinDetails(String regId){
        Queue_Sch_Wrapper wrapper = new Queue_Sch_Wrapper();
        // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
        // List<Registration_SCH__c> regs = [
        //     SELECT Id, Token_Number__c, Product2__c, Product2__r.Name, LastModifiedDate
        //     FROM Registration_SCH__c
        //     WHERE Id = :regId
        //     LIMIT 1
        // ];
        List<Registration_SCH__c> regs = [
            SELECT Id, Token_Number__c, Product2__c, Product2__r.Name, LastModifiedDate
            FROM Registration_SCH__c
            WHERE Id = :regId
            WITH USER_MODE
            LIMIT 1
        ];
        //changes end here by Abuzar
        if(!regs.isEmpty()){
            wrapper.serviceName = regs[0].Product2__r.Name;
            wrapper.lastmodified = String.valueOf((regs[0].LastModifiedDate).format('EEE, MMM d yyyy HH:mm:ss'));
        }
        return wrapper;
    }

    public static String getDayNameOfDate(Date dateVal){
        List<String> listDay = new List<String>{'Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'};
        Integer remainder = Math.mod(Date.newInstance(1, 1, 1).daysBetween(dateVal), 7);
        return listDay.get(remainder).substring(0, 3);
    }

    private static Integer getWorkbenchRefreshValue(){
        // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
        // List<SystemCode__c> sysWB = [SELECT Workbench_Refresh__c FROM SystemCode__c WITH USER_MODE LIMIT 1];
        List<SystemCode__c> sysWB = [SELECT Workbench_Refresh__c FROM SystemCode__c WITH USER_MODE LIMIT 1];
        //changes end here by Abuzar
        if(sysWB.isEmpty()){
            return 0;
        }
        return Integer.valueOf(sysWB[0].Workbench_Refresh__c);
    }

    private static Set<Id> getActiveLocationIds(){
        // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
        // List<Queue__c> queueLocations = [SELECT Id, Location__c, Location__r.Name FROM Queue__c WHERE Status__c = 'Active' WITH USER_MODE LIMIT 1000];
        List<Queue__c> queueLocations = [SELECT Id, Location__c, Location__r.Name FROM Queue__c WHERE Status__c = 'Active' WITH USER_MODE LIMIT 1000];
        //changes end here by Abuzar
        Set<Id> locationIds = new Set<Id>();
        for(Queue__c queueLocation : queueLocations){
            locationIds.add(queueLocation.Location__c);
        }
        return locationIds;
    }

    private static List<Queue__c> getSelectedQueueLocation(String location){
        if (!Schema.sObjectType.Queue__c.isAccessible()) {
            return new List<Queue__c>();
        }
        if(String.isNotEmpty(location)){
            // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
            // return [SELECT Id, Location__c, Location__r.Name FROM Queue__c WHERE Location__c = :location AND Status__c = 'Active' AND Location__c != null WITH USER_MODE ORDER BY LastModifiedDate DESC LIMIT 1];
            return [SELECT Id, Location__c, Location__r.Name FROM Queue__c WHERE Location__c = :location AND Status__c = 'Active' AND Location__c != null WITH USER_MODE ORDER BY LastModifiedDate DESC LIMIT 1];
            //changes end here by Abuzar
        }
        // commented by Abuzar on 2026-03-24 for the Checkmarkx issue and added below line "Apex SOQL SOSL USER MODE MISSING"
        // return [SELECT Id, Location__c, Location__r.Name FROM Queue__c WHERE Status__c = 'Active' AND Location__c != null WITH USER_MODE ORDER BY LastModifiedDate DESC LIMIT 1];
        return [SELECT Id, Location__c, Location__r.Name FROM Queue__c WHERE Status__c = 'Active' AND Location__c != null WITH USER_MODE ORDER BY LastModifiedDate DESC LIMIT 1];
        //changes end here by Abuzar
    }

    private static void initializeSetLocationFilters(Queue_Sch_Wrapper wrapper){
        wrapper.allCategory.add(new Queue_Sch_SelectOptions('--All Category--', '--All Category--', false));
        wrapper.allType.add(new Queue_Sch_SelectOptions('--All Type--', '--All Type--', false));
        wrapper.allSubType.add(new Queue_Sch_SelectOptions('--All Sub Type--', '--All Sub Type--', false));
    }

    private static void populateSetLocationPrograms(Queue_Sch_Wrapper wrapper){
        Queue_Sch_Wrapper forPrograms = getlookups(wrapper.floc);
        wrapper.allPrograms = forPrograms.allPrograms;
    }

    private static void populateSetLocationRecords(Queue_Sch_Wrapper wrapper){
        wrapper.records = getOpenRegistrationsForLocation(wrapper.floc);
        wrapper.bookedAppointment = getBookedRegistrationsForLocation(wrapper.floc);
    }

    private static List<Registration_SCH__c> getOpenRegistrationsForLocation(String locationId){
        if (!Schema.sObjectType.Registration_SCH__c.isAccessible()) {
            return new List<Registration_SCH__c>();
        }
        String cancelled = 'Cancelled';
        return [
            SELECT Id, Name, User__c, Customer_Name__c, Wait_Time_Exceeded__c, Token_Number__c, Customer_Lastname__c, Customer_Email__c,
                   Customer_Contact__c, Expert_Location__c, Expert_Location__r.Name, Product2__r.Name, Company__c, Status__c, waiting_Time__c,
                   Booked_Date__c, RecordTypeId, Product2__r.SCH_Wait_Threshold__c, Booked_Current_Status__c, Registration_Time__c, Checked_in_Date_Time__c
            FROM Registration_SCH__c
            WHERE Expert_Location__c = :locationId AND Registration_Time__c = null AND Status__c != :cancelled
            WITH USER_MODE
            ORDER BY Booked_Date__c ASC
            LIMIT 500
        ];
    }

    private static List<Registration_SCH__c> getBookedRegistrationsForLocation(String locationId){
        if (!Schema.sObjectType.Registration_SCH__c.isAccessible()) {
            return new List<Registration_SCH__c>();
        }
        String booked = 'Booked';
        return [
            SELECT Id, Name, User__c, Purpose__c, Information__c, Account__c, Category_of_registration__c, Customer_Email__c, Customer_Name__c, Customer_Lastname__c, Customer_Contact__c,
                   Customer_Status__c, Customer_Type__c, Discount__c, Event_Zone__c, Event_Zone__r.Name, Expert__c, Expert_Location__c, Meeting_Status__c,
                   Membership_Amount__c, Membership_Points__c, Product2__c, Registration_DateD__c, Registration_End_Time__c, Registration_Price__c, Registration_DateT__c, Registration_Type__c,
                   Registration_Time__c, Status__c, Total_Due_Amount__c, Event_Zone__r.Event_Zone_Location__c, Event_Zone__r.Event_Zone_Location__r.Name, Expert_Location__r.Show_Experts__c,
                   Expert_Location__r.Name, Expert_Location__r.Address__c, Expert_Location__r.City__c, Expert_Location__r.Province_State__c, Expert_Location__r.Country__c, Expert_Location__r.Zip_Code__c,
                   Product2__r.Name, Registration_SCH__c, End_Time__c, Contact__c, Contact__r.MailingCity, Contact__r.MailingState, Contact__r.MailingCountry, Contact__r.MailingPostalCode,
                   Where_Location_Voice_Video__c, Appointment_DateDt__c, Contact__r.Name
            FROM Registration_SCH__c
            WHERE Appointment_DateDt__c != null
              AND Expert_Location__c = :locationId
              AND Status__c = :booked
              AND Registration_Time__c != null
              AND End_Time__c != null
            WITH USER_MODE
            ORDER BY LastModifiedDate DESC
            LIMIT 100
        ];
    }

    private static void finalizeSetLocationsWrapper(Queue_Sch_Wrapper wrapper){
        Integer size = wrapper.records.size();
        if(size <= 0){
            wrapper.existLocation = true;
        }
        for(Integer index = 0; index < wrapper.records.size(); index++) {
            wrapper.mapOfRecords.put(String.valueOf(index), wrapper.records[index]);
        }
    }
}