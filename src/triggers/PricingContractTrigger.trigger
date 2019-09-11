trigger PricingContractTrigger on Pricing_Contract__c (before insert, before update, after update, after insert) {
	(new PricingContractTriggerHandler()).execute();
}