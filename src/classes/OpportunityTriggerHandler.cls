public with sharing class OpportunityTriggerHandler extends TriggerHandler {
	public static Boolean isBatch = false;

	public override void beforeUpdate() {
		OpportunityTriggerHelper.updateExternalId();
		Set<String> setOppty = new Set<String>();
		for (Opportunity eachOppty : (List<Opportunity>)Trigger.new) {
			if (isBatch || (GlobalUtil.isChanged(eachOppty.Id, 'CloseDate')) || (GlobalUtil.isChanged(eachOppty.Id, 'Delivery_Date__c')) || ( GlobalUtil.isChanged(eachOppty.Id, 'StageName') && eachOppty.StageName == 'Order'))
				setOppty.add(eachOppty.Id);
		}
		Map<Id, Quote_Line__c> mapQuoteLine = QuoteLineTriggerHelper.getPricingToCustomer(setOppty, null);
		System.debug('mapQuoteLine**' + mapQuoteLine);
		update mapQuoteLine.values();
	}

	/**
	 * { function_description }
	 *
	 * @return     { description_of_the_return_value }
	 */
	public override void beforeInsert() {
		OpportunityTriggerHelper.updateExternalId();
	}
}