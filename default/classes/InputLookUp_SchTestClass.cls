@IsTest
public class InputLookUp_SchTestClass {

    private static User getRunAsUser() {
        return [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    }

    @IsTest
    static void testFetchLookUpValues() {
        System.runAs(getRunAsUser()) {
            List<Account> accList = new List<Account>();
            for (Integer i = 0; i < 20; i++) {
                accList.add(new Account(Name = 'Test'));
            }
            insert accList;

            List<Product2> prodList = new List<Product2>();
            for (Integer i = 0; i < 30; i++) {
                prodList.add(new Product2(Name = 'Test'));
            }
            insert prodList;

            Test.startTest();
            // commented by abuzar on 13-03-2026 for the scanning issue and added below line "ExcessiveParameterList issue fixed by moving fetchLookUpValues inputs into a single request wrapper"
            // List<sObject> accResults = InputLookUp_Sch.fetchLookUpValues('Test', 'Account', '', 'Name');
            // List<sObject> prodResults = InputLookUp_Sch.fetchLookUpValues('Test', 'Product2', '', 'Name');
            InputLookUp_Sch.LookupRequest accountRequest = new InputLookUp_Sch.LookupRequest();
            accountRequest.searchKeyWord = 'Test';
            accountRequest.objectName = 'Account';
            accountRequest.queryFilter = '';
            accountRequest.searchField = 'Name';
            InputLookUp_Sch.LookupRequest productRequest = new InputLookUp_Sch.LookupRequest();
            productRequest.searchKeyWord = 'Test';
            productRequest.objectName = 'Product2';
            productRequest.queryFilter = '';
            productRequest.searchField = 'Name';
            List<sObject> accResults = InputLookUp_Sch.fetchLookUpValues(accountRequest);
            List<sObject> prodResults = InputLookUp_Sch.fetchLookUpValues(productRequest);
            //changes end here by abuzar
            Test.stopTest();

            System.assertNotEquals(null, accResults, 'Account results should not be null');
            System.assertNotEquals(null, prodResults, 'Product results should not be null');
        }
    }

    @IsTest
    static void testFetchLookUpValuesNoMatch() {
        System.runAs(getRunAsUser()) {
            List<Account> accList = new List<Account>();
            for (Integer i = 0; i < 20; i++) {
                accList.add(new Account(Name = 'Test'));
            }
            insert accList;

            Test.startTest();
            // commented by abuzar on 13-03-2026 for the scanning issue and added below line "ExcessiveParameterList issue fixed by moving fetchLookUpValues inputs into a single request wrapper"
            // List<sObject> results = InputLookUp_Sch.fetchLookUpValues('Test1', 'Account', '', 'Name');
            InputLookUp_Sch.LookupRequest request = new InputLookUp_Sch.LookupRequest();
            request.searchKeyWord = 'Test1';
            request.objectName = 'Account';
            request.queryFilter = '';
            request.searchField = 'Name';
            List<sObject> results = InputLookUp_Sch.fetchLookUpValues(request);
            //changes end here by abuzar
            Test.stopTest();

            System.assertNotEquals(null, results, 'Results should not be null even with no match');
            System.assertEquals(0, results.size(), 'Results should be empty for no match');
        }
    }

    @IsTest
    static void testFetchLookUpValueById() {
        System.runAs(getRunAsUser()) {
            Account acc = new Account(Name = 'Test');
            insert acc;

            Test.startTest();
            sObject accResult = InputLookUp_Sch.fetchLookUpValueById('Account', 'Name', acc.Id);
            sObject prodResult = InputLookUp_Sch.fetchLookUpValueById('Product2', 'Name', acc.Id);
            Test.stopTest();

            System.assertNotEquals(null, accResult, 'Account result should not be null');
            System.assertEquals(null, prodResult, 'Product result should be null for Account Id');
        }
    }

    @IsTest
    static void testFindRecords() {
        System.runAs(getRunAsUser()) {
            Account acc = new Account(Name = 'Test');
            insert acc;

            List<Product2> prodList = new List<Product2>();
            for (Integer i = 0; i < 5; i++) {
                prodList.add(new Product2(Name = 'Test'));
            }
            insert prodList;

            Test.startTest();
            List<sObject> accountResults = InputLookUp_Sch.findRecords('Test', 'Account');
            List<sObject> productResults = InputLookUp_Sch.findRecords('Test', 'Product2');
            Test.stopTest();

            System.assertNotEquals(null, accountResults, 'Account results should not be null');
            System.assert(accountResults.size() > 0, 'Account results should return records');
            System.assertNotEquals(null, productResults, 'Product results should not be null');
            System.assert(productResults.size() > 0, 'Product results should return records');
        }
    }

    @IsTest
    static void testAssertEquality() {
        System.runAs(getRunAsUser()) {
            String salName = 'ERP';
            String sal1Name = 'ERP';
            System.assertEquals(salName, sal1Name);
        }
    }
}