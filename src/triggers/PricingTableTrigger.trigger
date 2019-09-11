trigger PricingTableTrigger on Pricing_Table__C (after insert, after update) {
	(new PricingTableTriggerHandler()).execute();
}