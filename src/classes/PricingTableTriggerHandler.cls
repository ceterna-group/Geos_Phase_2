/**
 * Class for pricing table trigger handler.
 */
public with sharing class PricingTableTriggerHandler extends TriggerHandler {

	/**
	* [afterInsert :logic for all afterInsert logic]
	* @return [description]
	*/
	public override void afterInsert() {
		/**
				 * return if trigger sze >200. Bulk scenario not considered
				 * @return { description_of_the_return_value }
				 */
		if (Trigger.new.size() > 1) {
			return;
		}
		PricingTableTriggerHelper.updateUpliftvalue();
	}


	public override void afterUpdate() {
		/**
		 * return if trigger sze >1. Bulk scenario not considered
		 * @return { description_of_the_return_value }
		 */
		if (Trigger.new.size() > 1) {
			return;
		}
		PricingTableTriggerHelper.updateUpliftvalue();
	}
}