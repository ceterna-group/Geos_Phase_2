/**
* Class for pricing contract trigger handler test.
*/
@isTest
private class QuoteLineTriggerHelperTest {

	@testSetup public static void creatTestData() {
		TestUtil.createTestData();
	}
	/**
	 * { function_description }
	 */
	@isTest static void insertQuote() {
		Test.startTest();
		Quote_Line__c sobj = TestUtil.insertQuoteLine('Gasoline 10ppm');
		sobj.Currency__c = 'USD';
		update sobj;
		//test for Latest monthly Avg
		sobj.Product_or_Service__c = 'Biodiesel FAME -10 (RED)';
		update sobj;
		Test.stopTest();
	}/**
	 * { function_description }
	 */
	@isTest static void insertQuote2() {
		Test.startTest();
		Quote_Line__c sobj = TestUtil.insertQuoteLine('Marine Gas Oil 0.1% (max) Sulphur BS2869:2010');
		update sobj;
		sobj.Product_or_Service__c = 'Diesel 10 ppm';
		update sobj;
		Test.stopTest();
	}/**
	 * { function_description }
	 */
	@isTest static void insertQuote3() {
		Test.startTest();
		Quote_Line__c sobj = TestUtil.insertQuoteLine('Ethanol');
		Test.stopTest();
	}
}