/**
 * @description Test data factory for queue scheduler Apex tests.
 */
@IsTest
public class Queue_SchTestDataFactory {

    /**
     * @description Creates queue scheduler test records including location, service,
     * queue, contact, and registrations in multiple statuses.
     */
    public static void createQueueData() {
        Expert_Location__c expertLoc = new Expert_Location__c(
            Name = 'Test Location',
            Address__c = '123 Test St',
            City__c = 'Test City',
            Province_State__c = 'Test State',
            Country__c = 'Test Country',
            Zip_Code__c = '12345',
            Show_Experts__c = true
        );
        insert expertLoc;

        Product2 service = new Product2(
            Name = 'Test Service',
            IsActive = true,
            SCH_Duration__c = 30,
            SCH_Wait_Threshold__c = 15
        );
        insert service;

        Queue__c queue = new Queue__c(
            Location__c = expertLoc.Id,
            Status__c = 'Active'
        );
        insert queue;

        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Customer',
            Email = 'test@example.com',
            MobilePhone = '1234567890',
            MailingCity = 'Test City',
            MailingPostalCode = '12345'
        );
        insert con;

        insert new List<Registration_SCH__c>{
            new Registration_SCH__c(
                Customer_Name__c = 'John',
                Customer_Lastname__c = 'Doe',
                Customer_Email__c = 'john.doe@test.com',
                Customer_Contact__c = '1111111111',
                Expert_Location__c = expertLoc.Id,
                Product2__c = service.Id,
                Queue__c = queue.Id,
                Status__c = 'On Waitlist',
                Booked_Date__c = System.now()
            ),
            new Registration_SCH__c(
                Customer_Name__c = 'Jane',
                Customer_Lastname__c = 'Smith',
                Customer_Email__c = 'jane.smith@test.com',
                Customer_Contact__c = '2222222222',
                Expert_Location__c = expertLoc.Id,
                Product2__c = service.Id,
                Queue__c = queue.Id,
                Contact__c = con.Id,
                Status__c = 'Booked',
                Registration_Time__c = System.now().addHours(1),
                End_Time__c = System.now().addHours(2),
                Booked_Date__c = System.now(),
                Check_In__c = true,
                Token_Number__c = '01',
                Booked_Current_Status__c = 'NotInProgress',
                Customer_Status__c = 'Attended',
                Checked_in_Date_Time__c = System.now()
            ),
            new Registration_SCH__c(
                Customer_Name__c = 'Bob',
                Customer_Lastname__c = 'Johnson',
                Customer_Email__c = 'bob.johnson@test.com',
                Customer_Contact__c = '3333333333',
                Expert_Location__c = expertLoc.Id,
                Product2__c = service.Id,
                Queue__c = queue.Id,
                Status__c = 'Cancelled',
                Booked_Date__c = System.now()
            ),
            new Registration_SCH__c(
                Customer_Name__c = 'Alice',
                Customer_Lastname__c = 'Williams',
                Customer_Email__c = 'alice.williams@test.com',
                Customer_Contact__c = '4444444444',
                Expert_Location__c = expertLoc.Id,
                Product2__c = service.Id,
                Queue__c = queue.Id,
                Status__c = 'Booked',
                Booked_Date__c = System.now()
            ),
            new Registration_SCH__c(
                Customer_Name__c = 'Charlie',
                Customer_Lastname__c = 'Brown',
                Customer_Email__c = 'charlie.brown@test.com',
                Customer_Contact__c = '5555555555',
                Expert_Location__c = expertLoc.Id,
                Product2__c = service.Id,
                Queue__c = queue.Id,
                Contact__c = con.Id,
                Status__c = 'Booked',
                Registration_Time__c = System.now().addHours(1),
                End_Time__c = System.now().addHours(2),
                Booked_Date__c = System.now(),
                Check_In__c = true,
                Token_Number__c = '02',
                Booked_Current_Status__c = 'InProgress',
                Customer_Status__c = 'Attended',
                Checked_in_Date_Time__c = System.now()
            )
        };
    }
}
