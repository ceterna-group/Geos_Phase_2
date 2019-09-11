/**
 * [Master_Daily_Price__c description]
 * @param  insert [description]
 * @return        [description]
 */
trigger MasterDailyPriceTrigger on Master_Daily_Price__c (before insert, before update, after update, after insert) {
	(new MasterDailyPriceTriggerHandler()).execute();
}