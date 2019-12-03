@isTest
public class TestBorrowLogEventTrigger {
	@isTest
    static void testCreateBorrowLog() {       
        Test.enableChangeDataCapture(); // for all entities
        // Generate test data
        Contact newContact = new Contact(); 
        newContact.LastName = 'Newark';
        newContact.Email = 'newark@email.com';
        
        Book__c newBook = new Book__c();
        newBook.Name = 'The Simpsons';
        newBook.ISBN__c = '1234567891111';

        Database.insert(new sObject[] {newContact, newBook});
        
        Book_Copy__c newBookCopy = new Book_Copy__c(); 
        newBookCopy.Book__c = newBook.Id;       
        insert(newBookCopy);
        
        Borrow_Log__c borrow = new Borrow_Log__c();
        borrow.Contact__c = newContact.Id;
        borrow.Book_Copy__c = newBookCopy.Id;
        borrow.Returned__c = false;        
        insert borrow;
        //     	
        Test.getEventBus().deliver(); // Deliver change event message of type CREATE        
        Book_Copy__c bookCopy = [SELECT Id, Status__c FROM Book_Copy__c WHERE Id = :newBookCopy.Id];
        System.assertEquals('Loaned', bookCopy.Status__c, 'The book copy status did not update to loaned.');
        
        borrow.Returned__c = true;
        update borrow;
        Test.getEventBus().deliver(); // Deliver change event message of type UPDATE
        Book_Copy__c bookCopy2 = [SELECT Id, Status__c FROM Book_Copy__c WHERE Id = :newBookCopy.Id];
        System.assertEquals('Available', bookCopy2.Status__c, 'The book copy status did not update to Available.');        
    }
}