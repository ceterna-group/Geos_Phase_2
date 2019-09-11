@isTest
private class Batch_RecalculateQuoteLinePriceTest {
	@testSetup public static void creatTestData() {
		TestUtil.createTestData();
	}
	/**
	 * { function_description }
	 */
	@isTest static void insertQuote() {
		Master_Daily_Price__c mdp = [Select id from Master_Daily_Price__c limit 1];
		Test.startTest();
		Batch_RecalculateQuoteLinePrice.reCalculateAffectedOpportunities(mdp.Id);
		Test.stopTest();
	}

}