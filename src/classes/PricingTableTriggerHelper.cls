/**
 * Class for pricing table trigger helper.
 */
public with sharing class PricingTableTriggerHelper {

	/**
	 * { function_description }
	 */
	public static void updateUpliftValue() {
		Map<Id, Pricing_Table__c> mapPricingTable = new Map<Id, Pricing_Table__c>([select id, FX_Rate_field_API_name__c, Index_Mapping__c, Exchange_rate__c, Uplift_Value__c,
		        Index_Mapping__r.API_Name_Source__c, Index_Mapping__r.API_Name_Output__c, Index_Mapping__r.Currency_Output__c,
		        Index_Mapping__r.Currency_Source__c, Re_Calculate_Uplift_Value__c, Uplift__c, Uplift_Currency__c
		        from Pricing_Table__c
		        where Id in :trigger.new and Index_Mapping__c != null]);
		if (!mapPricingTable.isEmpty()) {
			Map<id, sObject> mapExchangeRate = new Map<id, sObject>(GlobalUtil.getSObjectRecords('Exchange_Rate__c', 'Id', mapPricingTable.values()[0].Exchange_Rate__c, null));
			for (Pricing_Table__c eachPT : mapPricingTable.values()) {
				if (eachPT.Re_Calculate_Uplift_Value__c || Trigger.isInsert ) {
					//eachPT.Re_Calculate_Uplift_Value__c = false;
					//	eachPT.Uplift_Value__c = eachPT.Uplift__c * (Decimal) mapExchangeRate.get(eachPT.Exchange_Rate__c).get(eachPT.FX_Rate_field_API_name__c);
				}
			}
			if (!mapPricingTable.isEmpty()) {
				//update mapPricingTable.values();
			}
		}
	}
}