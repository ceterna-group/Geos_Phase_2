/**
 * Class for pricing contract trigger handler test.
 */
@isTest
private class PricingContractTriggerHandlerTest {

	@testSetup public static void creatTestData() {
		Index_Mapping__c indexMapPT = Testutil.createIM('P66_Daily_Uplift__c', 'GBP', 'Master_Daily_Price__c');
		Account client =  Testutil.createAccount('Client1', 'Customer');
		insert client;
		Account terminal =  Testutil.createAccount('Terminal1', 'Delivery Terminal');
		insert terminal;
		Pricing_Table__c pc = Testutil.createPT(10.0, (String)indexMapPT.Id, 'GBP', '2018-12-31', '2017-10-10');
	}
	/**
	 * { function_description }
	 */
	@isTest static void insertPC() {
		Test.startTest();
		GlobalUtil.getRecordTypes('Account').get('Customer');
		Pricing_Contract__c pc = Testutil.createPC(GlobalUtil.getSObjectRecords('Account', 'Name', 'Client1', null)[0].Id,
		                         GlobalUtil.getSObjectRecords('Account', 'Name', 'Terminal1', null)[0].Id,
		                         GlobalUtil.getSObjectRecords('Index_Mapping__c', null, null, 'name!=null')[0].Id,
		                         Date.valueOf('2018-11-12'),
		                         'CoB',
		                         'Enquiry',
		                         12.0,
		                         'GBP',
		                         'Gasoline 10ppm',
		                         'gp@gmail.com');
		update pc;
		Test.stopTest();
	}
}