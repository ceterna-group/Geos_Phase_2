/**
 * Class for pricing contract trigger handler.
 */
public with sharing class PricingContractTriggerHandler extends TriggerHandler {
	public override void beforeUpdate() {
		if (Trigger.new.size() == 1) {
			PricingContractTriggerHelper.updateExternalId();
		}
	}
	public override void beforeInsert() {
		PricingContractTriggerHelper.updateExternalId();
	}
}