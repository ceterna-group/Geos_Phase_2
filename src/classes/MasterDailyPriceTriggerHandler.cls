/**
 * Class for master daily price trigger handler.
 */
public with sharing class MasterDailyPriceTriggerHandler  extends TriggerHandler   {
	/**
	 * [beforeInsert description]
	 * @return [description]
	 */
	public override void beforeInsert() {
		/**
		 * return if trigger sze >1. Bulk scenario not considered
		 * @return     { description_of_the_return_value }
		 */
		if (Trigger.new.size() == 1) {
			for (Master_Daily_Price__c eachMDP : (List<Master_Daily_Price__c>)Trigger.new) {
				//add unique key for each record when inserting record
				if (eachMDP.Manually_Created__c) {
					if (null != eachMDP.Date__c) {
						eachMDP.Unique_Key__c = String.valueOf(eachMDP.Date__c);
					}
					eachMDP = (Master_Daily_Price__c)MasterDailyPriceTriggerHelper.populatePricingTableFields(eachMDP.Date__c, Trigger.new[0], 'Master_Daily_Price__c');
					MasterDailyPriceTriggerHelper.createDailyMasterPriceRecord((Master_Daily_Price__c)Trigger.new[0]);
				}
			}
		}
	}
	public override void beforeUpdate() {
		/**
		 * return if trigger sze >1. Bulk scenario not considered
		 * @return { description_of_the_return_value }
		 */
		if (Trigger.new.size() == 1) {
			for (Master_Daily_Price__c eachMDP : (List<Master_Daily_Price__c>)Trigger.new) {

				Master_Daily_Price__c oldrec = (Master_Daily_Price__c)Trigger.oldMap.get(eachMDP.Id);
				if (null != eachMDP.Date__c && GlobalUtil.isChanged(eachMDP.Id, 'Date__c')) {

					system.debug('triggering recalc at 1');
					eachMDP.Unique_Key__c = String.valueOf(eachMDP.Date__c);
				}
				if (eachMDP.Reconsile__c && eachMDP.Manually_Created__c){

					system.debug('triggering recalc at 2');

					eachMDP = (Master_Daily_Price__c)MasterDailyPriceTriggerHelper.populatePricingTableFields(eachMDP.Date__c, Trigger.new[0], 'Master_Daily_Price__c');
					eachMDP.Reconsile__c = false;
					System.debug('eachMDP***' + eachMDP);
				}
//				if (!GlobalUtil.isChanged(eachMDP.Id, 'Excluded__c') && !GlobalUtil.isChanged(eachMDP.Id, 'Manually_Created__c')) {
				if (!GlobalUtil.isChanged(eachMDP.Id, 'Excluded__c') && eachMDP.Manually_Created__c) {

					system.debug('triggering recalc at 3');


					MasterDailyPriceTriggerHelper.createDailyMasterPriceRecord((Master_Daily_Price__c)Trigger.new[0]);
					//call batch to recalculate affected opportunities
					Batch_RecalculateQuoteLinePrice.reCalculateAffectedOpportunities(eachMDP.Id);
				}
			}
		}
	}
}