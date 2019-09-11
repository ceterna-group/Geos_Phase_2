/**
 * Class for pricing contract trigger helper.
 */
public with sharing class PricingContractTriggerHelper {

	/**
	 * update external id for pricing contract
	 */
	public static void updateExternalId() {
		for (Pricing_Contract__c eachPT : (List<Pricing_Contract__c>)Trigger.new) {
			if (Trigger.isInsert || eachPT.External_Id__c == null || GlobalUtil.isChanged(eachPT.id, 'Terminal__c') || GlobalUtil.isChanged(eachPT.id, 'Product__c') || GlobalUtil.isChanged(eachPT.id, 'Client__c')
			   )
				eachPT.External_Id__c = eachPT.Client__c + '_'
				                        + eachPT.Terminal__c + '_'
				                        + eachPT.Product__c.replace(' ', '_') ;
		}
	}
}