/**
 * @File Name          : Batch_PricingContractForClientsTest.cls
 * @Description        : 
 * @Author             : Girish P
 * @Group              : 
 * @Last Modified By   : Girish P
 * @Last Modified On   : 6/10/2019, 9:31:58 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    6/10/2019, 9:31:56 PM   Girish P     Initial Version
**/
@isTest
private class Batch_PricingContractForClientsTest {

	@testSetup public static void creatTestData() {
		TestUtil.createTestData();
	}
	/**
	 * { function_description }
	 */
	@isTest static void dailyReportTest() {
		Master_Daily_Price__c mdp = [Select id from Master_Daily_Price__c limit 1];
		Test.startTest();
		Batch_PricingContractForClients batchJob = new Batch_PricingContractForClients();
		Database.executeBatch(batchJob);
		Test.stopTest();
	}


}