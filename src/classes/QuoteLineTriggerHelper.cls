/**
 * Class for quote line trigger helper.
 */
public with sharing class QuoteLineTriggerHelper {
Public static Boolean isBatch = false;
Public static Boolean isDeliveryContract = true;
/**
 * Gets the pricing to customer.
 *
 * @param      setOpptyid      The set opptyid
 * @param      setQuoteLineId  The set quote line identifier
 *
 * @return     The pricing to customer.
 */
public static Map<Id, Quote_Line__c> getPricingToCustomer(Set<String> setOpptyid,
                                                          Set<String> setQuoteLineId) {
	Map<String, Quote_Line__c> mapQuoteProduct = new Map<String, Quote_Line__c>();
	Set<String> setPricingId = new Set<String>();
	Map<Id, Date> mapOpptyEnquiryDate = new Map<Id, Date>();
	Map<Id, Date> mapOpptyDeliveryDate = new Map<Id, Date>();
	//find Oppoty and their line items where calculations are required
	for (Opportunity eachOppty : [Select id, AccountId, Delivery_Date__c, Delivery_Terminal__c, CloseDate,
	                              (Select id, Enquiry__c, Litres_15_Deg__c, Metric_Tonnes__c, Price_To_Customer_Local_Currency__c, Currency__c,
	                               Product_or_Service__c, Unit_of_Measure__c, Density__c
	                               from Quote_Lines__r
	                               where Product_or_Service__c != null and Currency__c != null and Unit_of_Measure__c != null)
	                              from Opportunity
	                              where Id in:setOpptyid and Invoiced__c = false
	                                                                       AND Pricing_Mechanism__c != 'Spot' AND CloseDate != null
	                                                                       and AccountId != null AND Delivery_Terminal__c != null]) {
		mapOpptyEnquiryDate.put(eachOppty.Id, eachOppty.CloseDate);
		if (null != eachOppty.Delivery_Date__c)
			mapOpptyDeliveryDate.put(eachOppty.Id, eachOppty.Delivery_Date__c);
		for (Quote_Line__c eachQuote : eachOppty.Quote_Lines__r) {
			if (null == setQuoteLineId || (null != setQuoteLineId && setQuoteLineId.contains(eachQuote.Id))) {
				String externalId = eachOppty.AccountId
				                    + '_' + eachOppty.Delivery_Terminal__c + '_'
				                    + eachQuote.Product_or_Service__c.replace(' ', '_');
				eachQuote.External_Id__c = eachQuote.Id + '_' + externalId;
				setPricingId.add(externalId);
				mapQuoteProduct.put(eachQuote.External_Id__c, eachQuote);
			}
		}
	}
	Map<String, Pricing_Contract__c> mapPC = new Map<String, Pricing_Contract__c>();
	for (Pricing_Contract__c eachPricingContract : [Select Id, Enquiry_vs_Delivery_Date__c, Uplift_Currency__c, Uplift__c, External_Id__c, FX_Rate_field_API_name__c, Index__r.API_Name_Source__c,
	                                                Index__r.Currency_Source__c, Contract_Valid_To__c, Pricing_Terms__c, Contract_Valid_From__c
	                                                from Pricing_Contract__c
	                                                where External_Id__c in:setPricingId and Index__c != null And Active__c = true
	                                                                                                                          and Contract_Valid_To__c != null and Contract_Valid_From__c != null
	                                                                                                                          and Pricing_Terms__c != null and Enquiry_vs_Delivery_Date__c != null]) {
		mapPC.put(eachPricingContract.External_Id__c, eachPricingContract);
	}
	System.debug('mapPC**' + mapPC);
	System.debug('setPricingId**' + setPricingId);
	//loop thru each Quote Line Item and populate price to customer and their valid pricing contract
	for (String externalId : mapQuoteProduct.keySet()) {
		Quote_Line__c eachQuoteLine = mapQuoteProduct.get(externalId);
		System.debug('eachQuoteLine**' + eachQuoteLine);
		Date closeDate = mapOpptyEnquiryDate.get(eachQuoteLine.Enquiry__c);
		Date deliveryDate = mapOpptyDeliveryDate.get(eachQuoteLine.Enquiry__c);
		Date actualDate;
		Decimal priceToCustomer = 0;
		//fetch external Id for pricing contract, as external id for each quote line is prefixe with recordId_
		String pricingContractExternalId = externalId.substring(19);
		System.debug('pricingContractExternalId**' + pricingContractExternalId);
		System.debug('pricingContractExternalId**' + pricingContractExternalId);
		Id contractId = null;
		if (mapPC.containsKey(pricingContractExternalId)) {
			isDeliveryContract = mapPC.get(pricingContractExternalId).Enquiry_vs_Delivery_Date__c == 'Enquiry' ? false : true;
			actualDate = mapPC.get(pricingContractExternalId).Enquiry_vs_Delivery_Date__c == 'Enquiry'
			             ? mapOpptyEnquiryDate.get(eachQuoteLine.Enquiry__c)
			             : mapOpptyDeliveryDate.get(eachQuoteLine.Enquiry__c);
		}
		//if contract is valid for product in loop
		if (mapPC.containsKey(pricingContractExternalId)
		    && mapPC.get(pricingContractExternalId).Contract_Valid_To__c >= actualDate
		    && actualDate >= mapPC.get(pricingContractExternalId).Contract_Valid_From__c) {
			Pricing_Contract__c eachPricingContract = mapPC.get(pricingContractExternalId);
			contractId = eachPricingContract.Id;
			//stop calculation if Normal Monthly Average pricing conytract is found and dates are past
			if (eachPricingContract.Pricing_Terms__c == 'Normal Monthly Average' && actualDate < date.Today()) {
				continue;
			}
			//calculate uplift value based on contract pricing ters derived from prcing contract object
			priceToCustomer =  getUplift(eachPricingContract, actualDate, eachQuoteLine.Currency__c);
			//based on unit calculate final price to customer
			switch on eachQuoteLine.Unit_of_Measure__c       {
				when 'Litres @ 15 Deg' {
					priceToCustomer = null != eachQuoteLine.Density__c ? (priceToCustomer * eachQuoteLine.Density__c) / 1000 : 0;
				} when 'Metric Tonnes' {
					priceToCustomer = null != eachQuoteLine.Metric_Tonnes__c ? priceToCustomer : priceToCustomer;
				}
				when null {
					priceToCustomer = priceToCustomer;
				}
			}
		}
		//set price to customer and contract fields
		eachQuoteLine.Price_To_Customer_Local_Currency__c =  priceToCustomer;
		eachQuoteLine.Pricing_Contract__c = contractId;
		eachQuoteLine.Pricing_Contract_Calculated__c = true;
		mapQuoteProduct.put(externalId, eachQuoteLine);
	}
	if (!mapQuoteProduct.isEmpty()) {
		//update mapQuoteProduct.values();
	}
	return new Map<Id, Quote_Line__c>(mapQuoteProduct.values());
}

/**
 * Gets the uplift.
 *
 * @param      eachPricingContract  Each pricing contract
 * @param      enquiryDate          The enquiry date
 * @param      displayCurrency      The display currency
 *
 * @return     The uplift.
 */
public static Decimal getUplift(Pricing_Contract__c eachPricingContract,
                                Date enquiryDate,
                                String displayCurrency) {
	String pricingTerm = eachPricingContract.Pricing_Terms__c;
	Decimal upliftValue;
	String mdpWhereClause = ' ';
	switch on pricingTerm {
		when 'D-1' {
			//When an Enquiry/Opportunity has a Delivery date which falls on a Saturday or Sunday,
			//if the associated Pricing Contract is: D-1: It should take Thursday's price

			if (isDeliveryContract && GlobalUtil.getDayOfWeek(enquiryDate) > 4) {
				enquiryDate =  GlobalUtil.getDayOfWeek(enquiryDate) == 5 ? enquiryDate - 2 : enquiryDate - 3;
			} else{
				//for D - 1 pricing terms valid MDP is enquriy date - 1, for monday D - 1 ill be last friday
				enquiryDate = GlobalUtil.getDayOfWeek(enquiryDate) == 0 ? enquiryDate - 3 : enquiryDate - 1;
			}
			mdpWhereClause += ' Date__c <=' + String.valueOf(enquiryDate)+' order by Date__c desc limit 1 ';
			for(Master_Daily_Price__c eachMDP: (List<Master_Daily_Price__c>)GlobalUtil.getSObjectRecords('Master_Daily_Price__c',
			                                                                                             null,
			                                                                                             null,
			                                                                                             mdpWhereClause)) {
				mdpWhereClause =' Date__c =' + String.valueOf(eachMDP.Date__c);

			}
			upliftValue = calculatePriceForMonthlyAvg(eachPricingContract,  displayCurrency, mdpWhereClause, pricingTerm);
		} when 'CoB' {
			// When an Enquiry/Opportunity has a Delivery date which falls on a Saturday or Sunday, if the associated Pricing Contract is:
			//COB: It should take the following Monday's price (this was just confirmed by the client)
			if (isDeliveryContract && GlobalUtil.getDayOfWeek(enquiryDate) > 4) {
				enquiryDate =  GlobalUtil.getDayOfWeek(enquiryDate) == 5 ? enquiryDate + 2 : enquiryDate + 1;
			}
			//for D-1 pricing terms valid MDP is enquriy date
			mdpWhereClause += 'Date__c =' + String.valueOf(enquiryDate);
			upliftValue = calculatePriceForMonthlyAvg(eachPricingContract, displayCurrency, mdpWhereClause, pricingTerm);
		} when 'Latest Monthly Average' {
			Integer calendarMonthMDP = enquiryDate.Month();
			Integer calendarYearMDP = enquiryDate.Year();
			//use whole months MDP records
			mdpWhereClause += 'Calendar_Month(Date__c) =' + calendarMonthMDP + ' AND Calendar_YEAR(Date__c)=' + calendarYearMDP;
			upliftValue = calculatePriceForMonthlyAvg(eachPricingContract,  displayCurrency, mdpWhereClause, pricingTerm);
		} when 'Normal Monthly Average' {
			Integer calendarMonthMDP = enquiryDate.Month();
			Integer calendarYearMDP = enquiryDate.Year();
			mdpWhereClause += 'Calendar_Month(Date__c) =' + calendarMonthMDP + ' AND Calendar_YEAR(Date__c)=' + calendarYearMDP;
			upliftValue = calculatePriceForMonthlyAvg(eachPricingContract,  displayCurrency, mdpWhereClause, pricingTerm);
		} when 'Weekly Lag' {
			//for weekly lag previeous weeks MDP should be fetched
			mdpWhereClause += GlobalUtil.findWeekClause(enquiryDate - 7);
			upliftValue = calculatePriceForMonthlyAvg(eachPricingContract,  displayCurrency, mdpWhereClause, pricingTerm);
		}
	}
	return upliftValue;
}
///**
// * Calculates the price for co b and d 1.
// *
// * @param      eachPricingContract           pricing contract valid for quote item
// * @param      enquiryDate      The enquiry date on opportunity object
// * @param      displayCurrency  The display currency
// *
// * @return     The Price To Customer (Local Currency) for CoB and d-1  pricing terms.
// */
//public static Decimal calculatePriceForCoBAndD1(Pricing_Contract__c eachPricingContract,
//        Date enquiryDate,
//        String displayCurrency) {
//	String fxApiFieldName = eachPricingContract.FX_Rate_field_API_name__c;
//	Decimal upliftValue;
//	String mdpWhereClause = 'Date__c =' + String.valueOf(enquiryDate);
//	List<sObject> listMasterDailyPrice = GlobalUtil.getSObjectRecords('Master_Daily_Price__c',
//	                                     null,
//	                                     null,
//	                                     mdpWhereClause);
//	upliftValue = eachPricingContract.Uplift_Currency__c == eachPricingContract.Index__r.Currency_Source__c
//	              ? (eachPricingContract.Uplift__c + (Decimal)listMasterDailyPrice[0].get(eachPricingContract.Index__r.API_Name_Source__c))
//	              : ((eachPricingContract.Uplift__c * (Decimal)listMasterDailyPrice[0].get(fxApiFieldName)) + ((Decimal)listMasterDailyPrice[0].get(eachPricingContract.Index__r.API_Name_Source__c)));
//	if (displayCurrency != eachPricingContract.Uplift_Currency__c) {
//		upliftvalue = upliftvalue * (Decimal)listMasterDailyPrice[0].get('FX_Rate_' + eachPricingContract.Uplift_Currency__c + '_' + displayCurrency + '__c');
//	}
//	return upliftValue;
//}
/**
 * Calculates the price for monthly average.
 *
 * @param      eachPricingContract  Each pricing contract
 * @param      enquiryDate          The enquiry date
 * @param      displayCurrency      The display currency
 *
 * @return     The price for monthly average.
 */
public static Decimal calculatePriceForMonthlyAvg(Pricing_Contract__c eachPricingContract,
                                                  String displayCurrency,
                                                  String mdpWhereClause,
                                                  String pricingTerm) {
	String fxApiFieldName = eachPricingContract.FX_Rate_field_API_name__c;
	String fxAVGApiFieldName;
	Decimal upliftValue = eachPricingContract.Uplift__c;
	Decimal sourceFieldValue = 0;
	Decimal priceToCustomer = 0;
	System.debug(mdpWhereClause + '*mdpWhereClause***');
	// List<sObject> listMasterDailyPrice = GlobalUtil.getSObjectRecords('Master_Daily_Price__c',
	//                                      null,
	//                                      null,
	//                                      mdpWhereClause);

	//find the avg FX rates and value if field to be used to display the price to customer
	Map<String, Decimal> mapFXRate = GlobalUtil.findAverageFX(mdpWhereClause, eachPricingContract.Index__r.API_Name_Source__c);
	sourceFieldValue = null != mapFXRate.get(eachPricingContract.Index__r.API_Name_Source__c)
	                   ? mapFXRate.get(eachPricingContract.Index__r.API_Name_Source__c)
	                   : 0;
	System.debug(mapFXRate + '***mapFXRate');
	System.debug(sourceFieldValue + '***sourceFieldValue');
	System.debug(JSON.serialize(mapFXRate) + '***mapFXRate');
	System.debug(eachPricingContract + '***eachPricingContract');
	//convert uplift to the Source field currency using AVG fx rate based on MDP where clause calculated above
	// upliftValue = eachPricingContract.Uplift_Currency__c == eachPricingContract.Index__r.Currency_Source__c
	//               ? (upliftValue + sourceFieldValue)
	//               : ((((null != mapFXRate && mapFXRate.containsKey(fxApiFieldName)) ? upliftvalue * mapFXRate.get(fxApiFieldName).setScale(4) : 0)) + sourceFieldValue);
	//convert source to uplift curreny equivalent
	if(eachPricingContract.Uplift_Currency__c != eachPricingContract.Index__r.Currency_Source__c) {
		sourceFieldValue = (mapFXRate.containsKey(eachPricingContract.FX_Rate_field_API_name__c) && null != mapFXRate.get(eachPricingContract.FX_Rate_field_API_name__c) )
		                   //Girish P: 12 Sep 2019- changed the logic based on business feedback
		                   //? sourceFieldValue * mapFXRate.get(eachPricingContract.FX_Rate_field_API_name__c)
		                   ? sourceFieldValue / mapFXRate.get(eachPricingContract.FX_Rate_field_API_name__c)
		                   : sourceFieldValue;
		System.debug('Converting to uplift value');
		System.debug(sourceFieldValue);

	}
	priceToCustomer=sourceFieldValue+upliftValue;
	System.debug(priceToCustomer+'**Before applying Dispaly Currency change');

	// System.debug(upliftValue + '***upliftValue');
	// System.debug(displayCurrency + '***displayCurrency');
	//if display current is not same as index, apply FX change rate
	// if (displayCurrency != eachPricingContract.Index__r.Currency_Source__c) {
	//      fxAVGApiFieldName =     'FX_Rate_' + eachPricingContract.Index__r.Currency_Source__c + '_' + displayCurrency + '__c';
	//      decimal val = mapFXRate.get(fxAVGApiFieldName);
	//      upliftvalue = (mapFXRate.containsKey(fxAVGApiFieldName) && null != mapFXRate.get(fxAVGApiFieldName) ) ? upliftvalue * mapFXRate.get(fxAVGApiFieldName).setScale(4) : upliftvalue;
	// }
	if (displayCurrency != eachPricingContract.Uplift_Currency__c) {
		fxAVGApiFieldName = 'FX_Rate_' + eachPricingContract.Uplift_Currency__c + '_' + displayCurrency + '__c';
		decimal val = mapFXRate.get(fxAVGApiFieldName);
		priceToCustomer = (mapFXRate.containsKey(fxAVGApiFieldName) && null != mapFXRate.get(fxAVGApiFieldName) )
		                  ? priceToCustomer * mapFXRate.get(fxAVGApiFieldName)
		                  : priceToCustomer;
		System.debug('After Applying the Display conversion');
		System.debug('Applied rate '+mapFXRate.get(fxAVGApiFieldName));
		System.debug(priceToCustomer);
	}

	return priceToCustomer.setScale(2);
}

///**
// * { function_description }
// *
// * @param      setOpptyid      The set opptyid
// * @param      setQuoteLineId  The set quote line identifier
// */
//public static void updatePriceToCustomer(Set<String> setOpptyid,
//        Set<String> setQuoteLineId) {
//	Map<Id, Quote_Line__c> mapQuoteLine = QuoteLineTriggerHelper.getPricingToCustomer(setOpptyid, setQuoteLineId);
//	System.debug(mapQuoteLine + '***mapQuoteLine');
//	for (Quote_Line__c eachQuote : (List<Quote_Line__c>) Trigger.new) {
//		if (mapQuoteLine.containsKey(eachQuote.Id)) {
//			eachQuote = mapQuoteLine.get(eachQuote.Id);
//		}
//		System.debug(eachQuote + '***eachQuote');
//	}
//}
}