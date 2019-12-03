trigger BorrowLogEventTrigger on Borrow_Log__ChangeEvent (after insert) {    
    
    for (Borrow_Log__ChangeEvent event : Trigger.new) {        
        EventBus.ChangeEventHeader header = event.ChangeEventHeader;
        List<String> recordIdList = header.getRecordIds(); // get the Id's of the new borrows
        List<Borrow_Log__c> borrows = [SELECT Id, Returned__c, Book_Copy__r.Status__c FROM Borrow_Log__c WHERE Id = :recordIdList]; // get the book copies that were borrowed
        List<Book_Copy__c> copies = new List<Book_Copy__c>();
        List<String> changedFields = header.getChangedFields();
        
        // Update book copy status to 'Loaned' when creating a new borrow
        if (header.changetype == 'CREATE') {            
            for (Borrow_Log__c aBorrow : borrows) {
                aBorrow.Book_Copy__r.Status__c = 'Loaned';
                copies.add(aBorrow.Book_Copy__r);              
            }
            update copies;             
        } 
        // Update book copy status to 'Available' when a book is returned
        else if (header.changetype == 'UPDATE' && changedFields.contains('Returned__c')) {
            for (Borrow_Log__c aBorrow : borrows) {
                if (aBorrow.Returned__c) {
                	aBorrow.Book_Copy__r.Status__c = 'Available';
                	copies.add(aBorrow.Book_Copy__r);
                }
            }
            update copies;
        }        
    }
}