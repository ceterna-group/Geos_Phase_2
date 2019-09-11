/**
    @Purpose :- Tests the functionality --> Invoice_UpdatedController
*/
@isTest
private class Invoice_UpdatedControllerTest {

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
            Customer_PO_Number__c = 'C1234',
            Invoice_Or_Credit__c = 'Invoice',
            Pricing_Mechanism__c = 'Contract Daily'
        );
        insert recordOpportunity;
        System.assertEquals( 1, [ SELECT COUNT() FROM Opportunity ] );
        List<Quote_Line__c> listOfQuoteLines = new List<Quote_Line__c>();
        for ( Integer intQuoteLineIndex = 0; intQuoteLineIndex < intNumberOfRecords; intQuoteLineIndex ++ ) {
            listOfQuoteLines.add(
                new Quote_Line__c (
                    Density__c = intQuoteLineIndex * 2,
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
    public testmethod static void testInvoiceControllerFunctionality() {
        Test.startTest();
        Opportunity recordOpportunity = [ SELECT Id, Masters_or_Owners__c,
                                          Vessel__c, Port__c, Geos_Ref__c,
                                          Delivery_Date__c, Customer_PO_Number__c,
                                          AccountId, Account.Name, Vessel__r.Name,
                                          Account.VAT_Number__c, Invoice_Or_Credit__c
                                          FROM Opportunity LIMIT 1
                                        ];
        Account recordAccount = [ SELECT Id FROM Account LIMIT 1 ];
        //with positive input
        /*ApexPages.StandardController stdController = new ApexPages.StandardController( recordOpportunity );
        Invoice_UpdatedController instanceInvoice_UpdatedController = new Invoice_UpdatedController( stdController );
        instanceInvoice_UpdatedController.enquiryId = recordOpportunity.Id;*/
        //System.assertEquals( intNumberOfRecords, instanceInvoice_UpdatedController.listOfQuoteLineItems.size() );
        //with negative input
        /*stdController = new ApexPages.StandardController( recordAccount );
        instanceInvoice_UpdatedController = new Invoice_UpdatedController( stdController );*/
        //System.assertEquals( 0, instanceInvoice_UpdatedController.listOfQuoteLineItems.size() );
        Invoice_UpdatedController invoiceUpdatedController = new Invoice_UpdatedController();
        invoiceUpdatedController.enquiryId = recordOpportunity.Id;
        invoiceUpdatedController.getinstanceOpportunityWrapper();
        invoiceUpdatedController.getlistOfQuoteLineItems();
        Test.stopTest();
    }

}