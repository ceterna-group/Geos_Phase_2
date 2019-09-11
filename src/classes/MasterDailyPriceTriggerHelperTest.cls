/**
 * Class for master daily price trigger helper test.
 */
@isTest
private class MasterDailyPriceTriggerHelperTest {

	/**
	 * { function_description }
	 */
	@testSetup public static void ceraetTestData() {
		Index_Mapping__c indexMapPT = Testutil.createIM('P66_Daily_Uplift__c', 'GBP', 'Master_Daily_Price__c');
		Account client =  Testutil.createAccount('Client1', 'Customer');
		insert client;
		Pricing_Table__c pc = Testutil.createPT(10.0, (String)indexMapPT.Id, 'GBP', '2018-12-31', '2017-10-10');
	}
	/**
	 * { function_description }
	 */
	@isTest static void test_method_one() {
		Test.startTest();
		Master_Daily_Price__c mdp = Testutil.createMDP('2018-11-11');
		mdp.Date__c = Date.valueOf('2019-11-12');
		mdp.Reconsile__c = true;
		update mdp;
		Test.stopTest();
	}
}