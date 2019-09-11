/**
* Class for pricing contract trigger handler test.
*/
@isTest
private class OpportunityTriggerHelperTest {

	@testSetup public static void creatTestData() {
		Index_Mapping__c indexMapPT = Testutil.createIM('P66_Daily_Uplift__c', 'GBP', 'Master_Daily_Price__c');
		Account client =  Testutil.createAccount('Client1', 'Customer');
		insert client;
		Account terminal =  Testutil.createAccount('Terminal1', 'Delivery Terminal');
		insert terminal;
		Pricing_Table__c pt = Testutil.createPT(10.0, (String)indexMapPT.Id, 'GBP', '2018-12-31', '2017-10-10');
		Pricing_Contract__c pc = Testutil.createPC(GlobalUtil.getSObjectRecords('Account', 'Name', 'Client1', null)[0].Id,
		                         GlobalUtil.getSObjectRecords('Account', 'Name', 'Terminal1', null)[0].Id,
		                         GlobalUtil.getSObjectRecords('Index_Mapping__c', null, null, 'name!=null')[0].Id,
		                         Date.valueOf('2018-11-12'),
		                         'CoB',
		                         'Enquiry',
		                         12.0,
		                         'GBP',
		                         'Biodiesel FAME -10 (RED)',
		                         'gp@gmail.com');
		update pc;
		Pricing_Contract__c pt2 = Testutil.createPC(GlobalUtil.getSObjectRecords('Account', 'Name', 'Client1', null)[0].Id,
		                          GlobalUtil.getSObjectRecords('Account', 'Name', 'Terminal1', null)[0].Id,
		                          GlobalUtil.getSObjectRecords('Index_Mapping__c', null, null, 'name!=null')[0].Id,
		                          Date.valueOf('2018-11-12'),
		                          'CoB',
		                          'Enquiry',
		                          102.0,
		                          'USD',
		                          'Gasoline 10ppm',
		                          'gp@gmail.com');
		update pt2;
	}
	/**
	 * { function_description }
	 */
	@isTest static void insertOpportunity() {
		Test.startTest();
		Opportunity oppty = new Opportunity(
		    StageName = 'Enquiry',
		    Name = 'Oppty1',                                // Stage
		    // Stage
		    AccountId = GlobalUtil.getSObjectRecords('Account', 'Name', 'Client1', null)[0].Id,
		    Transport_Response_Time__c = '0-20 minutes',          // Transport Response Time
		    CloseDate = Date.valueOf('2018-11-12'),               // Enquiry Date
		    Probability = 10,                                     // Probability (%)
		    Hedged__c = false,                                    // Hedged?
		    Masters_or_Owners__c = 'Masters or Owners',           // Masters or Owners
		    Invoiced__c = false,                                  // Invoiced?
		    In_Sage__c = false,                                   // In Sage?
		    Invoice_Or_Credit__c = 'Invoice',                     // Invoice Or Credit
		    Pricing_Mechanism__c = 'Contract Daily',              // Pricing Mechanism
		    Delivery_Terminal__c = GlobalUtil.getSObjectRecords('Account', 'Name', 'Terminal1', null)[0].Id,            // Delivery Terminal
		    Actual_Quantity_Delivered_MT__c = 20.0000,         // Actual Quantity Delivered (MT)
		    Actual_Quantity_Delivered_Litres_15__c = 230.0000,  // Actual Quantity Delivered (Litres @ 15)
		    Actual_Density__c = 33.0000,
		    Delivery_Date__c = Date.valueOf('2018-12-12'),        // Delivery Date
		    Delivery_Method__c = 'Ex Pipe'                       // Delivery Method
		                         // Actual Density
		);
		insert oppty;
		oppty.StageName = 'Order';
		oppty.vessel__c = TestUtil.createVessel('Test', '12212').Id;
		update oppty;
		Test.stopTest();
	}
}