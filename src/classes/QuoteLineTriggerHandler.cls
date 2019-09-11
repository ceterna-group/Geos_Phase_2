/**
 * Class for quote line trigger handler.
 */
public with sharing class QuoteLineTriggerHandler extends TriggerHandler {
	/**
		 * [beforeInsert description]
		 * @return [description]
		 */
	public override void afterInsert() {
		/**
		 * return if trigger sze >200. Bulk scenario not considered
		 * @return     { description_of_the_return_value }
		 */
		if (Trigger.new.size() > 1) {
			return;
		}
		Set<String> setQuoteLineId = new Set<String>();
		Set<String> setOpptyid = new Set<String>();
		for (Quote_Line__c eachOLT : (List<Quote_Line__c>) Trigger.new) {
			//if (eachOLT.Pricing_Contract_Calculated__c == false && eachOLT.Pricing_Contract__c == null)
			setOpptyid.add(eachOLT.Enquiry__c);
			setQuoteLineId.add(eachOLT.Id);
		}
		if (!setOpptyid.isEmpty()) {
			Map<Id, Quote_Line__c> mapQuoteLine = QuoteLineTriggerHelper.getPricingToCustomer(setOpptyid, setQuoteLineId);
			System.debug('mapQuoteLine**' + mapQuoteLine);
			update mapQuoteLine.values();
		}
	}
	public override void afterUpdate() {
		/**
		 * return if trigger sze >200. Bulk scenario not considered
		 * @return     { description_of_the_return_value }
		 */
		if (Trigger.new.size() > 1 || CONSTANTS.QUOTE_TRIGGER_EXECUTED) {
			return;
		}
		Set<String> setOpptyid = new Set<String>();
		Set<String> setQuoteLineId = new Set<String>();
		for (Quote_Line__c eachOLT : (List<Quote_Line__c>) Trigger.new) {
			//if (eachOLT.Price_To_Customer_Local_Currency__c == null 
			if ((GLobalUtil.isChanged(eachOLT.Id, 'Currency__c') 
			|| GLobalUtil.isChanged(eachOLT.Id, 'Product_or_Service__c') 
			|| GLobalUtil.isChanged(eachOLT.Id, 'Unit_of_Measure_Order_Quantity__c'))
			        || (eachOLT.Pricing_Contract_Calculated__c == false && eachOLT.Pricing_Contract__c == null && GLobalUtil.isChanged(eachOLT.id, 'Product_or_Service__c'))) {
				setOpptyid.add(eachOLT.Enquiry__c);
				setQuoteLineId.add(eachOLT.Id);
			}
		} 
		if (!setOpptyid.isEmpty()) {
			//QuoteLineTriggerHelper.updatePriceToCustomer(setOpptyid, setQuoteline);
			Map<Id, Quote_Line__c> mapQuoteLine = QuoteLineTriggerHelper.getPricingToCustomer(setOpptyid, setQuoteLineId);
			System.debug('mapQuoteLine**' + mapQuoteLine);
			update mapQuoteLine.values();
			//for (Quote_Line__c eachQuote : (List<Quote_Line__c>) Trigger.new) {
			//	if (mapQuoteLine.containsKey(eachQuote.Id)) {
			//		eachQuote = mapQuoteLine.get(eachQuote.Id);
			//	}
			//	System.debug(eachQuote + '***eachQuote');
			//}
		}
		CONSTANTS.QUOTE_TRIGGER_EXECUTED=true;

	}
}