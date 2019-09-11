@isTest
private class SupplierConfirmationCmpControllerTest{
    
    // Holds number of records to be inserted.
    private static final Integer intNumberOfRecords = 10;
    
    /*
        @ Purpose : Insert entire test data to test the functionality.
    */
    
    @testSetup static void insertTestData() {
        
        Account recordAccount = new Account( Name = 'Test Account',
                                             VAT_Number__c = 'V123456'
                                            );
        insert recordAccount;
        System.assertEquals( 1, [ SELECT COUNT() FROM Account ] );
        
        Opportunity recordOpportunity = new Opportunity( 
                                                         Account = recordAccount,
                                                         Name = 'Test Opportunity',
                                                         StageName = 'Enquiry',
                                                         CloseDate = System.today().addDays(1),          
                                                         Masters_or_Owners__c = 'Masters or Owners',
                                                         Port__c = 'Boston',                                     
                                                         Delivery_Date__c = System.today(), 
                                                         Customer_PO_Number__c = 'C1234'
                                                        );
        insert recordOpportunity;
        System.assertEquals( 1, [ SELECT COUNT() FROM Opportunity ] );
        
        SupplyCost_Line__c recordSupplyCostLine =   new SupplyCost_Line__c 
                                                    ( 
                                                        Density__c = 78,
                                                        Cost_Type__c = 'Product',
                                                        Product_or_Service__c = 'Ethanol',                  
                                                        Unit_of_Measure_Order_Quantity__c = 'CBM',
                                                        Currency__c = 'GBP',
                                                        VAT__c = 10,
                                                        Enquiry__c = recordOpportunity.Id
                                                    );
        insert recordSupplyCostLine;    
        System.assertEquals( 1, [ SELECT COUNT() FROM SupplyCost_Line__c ] );
    }
    /*
        @ Purpose : Test the entire functionality.
    */
    public testmethod static void testOfferEmailControllerFunctionality() {
        Test.startTest();
        SupplyCost_Line__c recordSupplyCostLine = [ SELECT Id
                                                    FROM SupplyCost_Line__c LIMIT 1 
                                                   ];
        SupplierConfirmationCmpController instanceSupplier = new SupplierConfirmationCmpController();
        
        //with positive input
        instanceSupplier.supplyCostLineId = recordSupplyCostLine.Id;
        System.assert( instanceSupplier.getSupplyCostLineRecord() != NULL );
        
        //with negative input
        instanceSupplier.supplyCostLineId = '12345';        
        instanceSupplier.getSupplyCostLineRecord(); 
        System.assert( instanceSupplier.getSupplyCostLineRecord().price == NULL );  
        Test.stopTest();
    }
}