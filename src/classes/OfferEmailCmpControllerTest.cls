/**
	@Purpose :- Tests the functionality --> OfferEmailCmpController
*/
@isTest
private class OfferEmailCmpControllerTest{
    
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
                                                         Delivery_Terminal__c = recordAccount.Id,
                                                         Masters_or_Owners__c = 'Masters or Owners',
                                                         Port__c = 'Boston',                                     
                                                         Delivery_Date__c = System.today(), 
                                                         Customer_PO_Number__c = 'C1234'
                                                        );
        insert recordOpportunity;
        System.assertEquals( 1, [ SELECT COUNT() FROM Opportunity ] );
        
        List<Quote_Line__c> listOfQuoteLines = new List<Quote_Line__c>();
        
        for( Integer intQuoteLineIndex = 0; intQuoteLineIndex < intNumberOfRecords; intQuoteLineIndex ++ ) {
            
            listOfQuoteLines.add(
                                    new Quote_Line__c ( 
                                                        Density__c = intQuoteLineIndex*2,
                                                        Cost_Type__c = 'Product',
                                                        Product_or_Service__c = 'Ethanol',
                                                        Unit_of_Measure__c = 'CBM',
                                                        Currency__c = 'GBP',
                                                        VAT__c = 10,
                                                        Enquiry__c = recordOpportunity.Id
                                                      )
                                );
        }
        insert listOfQuoteLines;    
        System.assertEquals( intNumberOfRecords, [ SELECT COUNT() FROM Quote_Line__c ] );
    }
    /*
        @ Purpose : Test the entire functionality.
    */
    public testmethod static void testOfferEmailControllerFunctionality() {
        Test.startTest();
        Opportunity recordOpportunity = [ SELECT Id
                                          FROM Opportunity LIMIT 1 
                                        ];
        OfferEmailCmpController instanceOfferEmailCmpController = new OfferEmailCmpController();
        
        //with positive input
        instanceOfferEmailCmpController.enquiryId = recordOpportunity.Id;
        instanceOfferEmailCmpController.getEnquiryRecord();     
        System.assertEquals( intNumberOfRecords, instanceOfferEmailCmpController.getlistOfQuoteLines().size() );
        
        //with negative input
        instanceOfferEmailCmpController.enquiryId = '12345';        
        instanceOfferEmailCmpController.getEnquiryRecord(); 
        System.assertEquals( 0, instanceOfferEmailCmpController.getlistOfQuoteLines().size() );     
        Test.stopTest();
    }
}