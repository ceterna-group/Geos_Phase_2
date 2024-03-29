/**
 * Class for quote line trigger helper.
 */
public with sharing class QuoteLineTriggerHelper {

	public static Boolean isBatch 				= false;
	public static Boolean isDeliveryContract 	= true;

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

		Map<String, Quote_Line__c> mapQuoteProduct 	= new Map<String, Quote_Line__c>();
		Set<String> setPricingId 					= new Set<String>();
		Map<Id, Date> mapOpptyEnquiryDate 			= new Map<Id, Date>();
		Map<Id, Date> mapOpptyDeliveryDate 			= new Map<Id, Date>();

		//find Oppoty and their line items where calculations are required
		for (Opportunity eachOppty : [SELECT Id, AccountId, Delivery_Date__c, Delivery_Terminal__c, CloseDate,
											Invoice_Or_Credit__c,
											(SELECT Id, Enquiry__c, Litres_15_Deg__c, Metric_Tonnes__c,
												Price_To_Customer_Local_Currency__c, Currency__c,
												Product_or_Service__c, Unit_of_Measure__c, Density__c
										   FROM Quote_Lines__r
										   WHERE Product_or_Service__c != NULL
										   AND Currency__c != NULL
										   AND Unit_of_Measure__c != NULL)
									   FROM Opportunity
									   WHERE Id IN :setOpptyid
									   AND Invoiced__c = FALSE
									   AND Pricing_Mechanism__c != 'Spot'
									   AND CloseDate != NULL
									   AND AccountId != NULL AND Delivery_Terminal__c != NULL]) {

			// todo: if it's invoiced need to send an email

			mapOpptyEnquiryDate.put(eachOppty.Id, eachOppty.CloseDate);

			system.debug('is insert ' + Trigger.IsInsert);

			if (!(Trigger.IsInsert && eachOppty.Invoice_Or_Credit__c == 'Credit')){
				if (null != eachOppty.Delivery_Date__c){
					mapOpptyDeliveryDate.put(eachOppty.Id, eachOppty.Delivery_Date__c);
				}

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
		}

		Map<String, Pricing_Contract__c> mapPC = new Map<String, Pricing_Contract__c>();

		for (Pricing_Contract__c eachPricingContract : [SELECT Id, Enquiry_vs_Delivery_Date__c, Uplift_Currency__c,
															Uplift__c, External_Id__c, FX_Rate_field_API_name__c,
															Index__r.API_Name_Source__c, Density__c,
															Index__r.Currency_Source__c, Contract_Valid_To__c,
															Pricing_Terms__c, Contract_Valid_From__c
														FROM Pricing_Contract__c
														WHERE External_Id__c IN :setPricingId
														AND Index__c != NULL
														AND Active__c = TRUE
														AND Contract_Valid_To__c != NULL
														AND Contract_Valid_From__c != NULL
														AND Pricing_Terms__c != NULL
														AND Enquiry_vs_Delivery_Date__c != NULL]) {
			mapPC.put(eachPricingContract.External_Id__c, eachPricingContract);
		}

		System.debug('mapPC**' + mapPC);
		System.debug('setPricingId**' + setPricingId);

		//loop thru each Quote Line Item and populate price to customer and their valid pricing contract
		for (String externalId : mapQuoteProduct.keySet()) {

			Quote_Line__c eachQuoteLine = mapQuoteProduct.get(externalId);

			System.debug('eachQuoteLine**' + eachQuoteLine);

			Date closeDate 		= mapOpptyEnquiryDate.get(eachQuoteLine.Enquiry__c);
			Date deliveryDate 	= mapOpptyDeliveryDate.get(eachQuoteLine.Enquiry__c);

			Date actualDate;

			Decimal priceToCustomer = 0;
			//fetch external Id for pricing contract, as external id for each quote line is prefixe with recordId_
			String pricingContractExternalId = externalId.substring(19);

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

				//calculate uplift value based on contract pricing ters derived from pricing contract object
				priceToCustomer =  getUplift(eachPricingContract, actualDate, eachQuoteLine.Currency__c);

				//based on unit calculate final price to customer
				switch on eachQuoteLine.Unit_of_Measure__c       {
					when 'Litres @ 15 Deg' {
						priceToCustomer = null != eachQuoteLine.Density__c ? (priceToCustomer * eachQuoteLine.Density__c) / 1000 : 0;
					} when 'Metric Tonnes' {
						priceToCustomer = null != eachQuoteLine.Metric_Tonnes__c ? priceToCustomer : priceToCustomer;
					} when null {
						priceToCustomer = priceToCustomer;
					}
				}
			}

			System.debug('the price to customer is **' + priceToCustomer);

			//set price to customer and contract fields
			eachQuoteLine.Price_To_Customer_Local_Currency__c 	=  priceToCustomer;

			if (mapPC.containsKey(pricingContractExternalId) && mapPC.get(pricingContractExternalId).Density__c != null){
				eachQuoteLine.Price_To_Customer_Local_Currency__c = priceToCustomer * mapPC.get(pricingContractExternalId).Density__c / 1000;
			}

			eachQuoteLine.Pricing_Contract__c 					= contractId;
			eachQuoteLine.Pricing_Contract_Calculated__c 		= true;

			// todo:

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

		System.debug('original date is ' + enquiryDate);

		Date originalDate 	= enquiryDate;
		String pricingTerm 	= eachPricingContract.Pricing_Terms__c;
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

				for(Master_Daily_Price__c eachMDP:
						(List<Master_Daily_Price__c>)GlobalUtil.getSObjectRecords('Master_Daily_Price__c',
																				 null,
																				 null,
																				 mdpWhereClause)) {
					mdpWhereClause =' Date__c =' + String.valueOf(eachMDP.Date__c);

				}
				upliftValue = calculatePriceForMonthlyAvg(eachPricingContract,  displayCurrency, mdpWhereClause, pricingTerm);
			} when 'CoB' {
				// When an Enquiry/Opportunity has a Delivery date which falls on a Saturday or Sunday,
				// if the associated Pricing Contract is:
				// COB: It should take the following Monday's price (this was just confirmed by the client)
				if (isDeliveryContract && GlobalUtil.getDayOfWeek(enquiryDate) > 4) {
					enquiryDate =  GlobalUtil.getDayOfWeek(enquiryDate) == 5 ? enquiryDate + 2 : enquiryDate + 1;
				}
				//for D-1 pricing terms valid MDP is enquriy date
				mdpWhereClause += 'Date__c =' + String.valueOf(enquiryDate);
				upliftValue = calculatePriceForMonthlyAvg(eachPricingContract, displayCurrency, mdpWhereClause, pricingTerm);
			} when 'Latest Monthly Average' {
				System.debug('using latest monthly average');
				System.debug('DEFINITELY USING LATEST');
				Integer calendarMonthMDP 	= enquiryDate.month();
				Integer calendarYearMDP 	= enquiryDate.year();
				//use whole months MDP records
				mdpWhereClause += 'Calendar_Month(Date__c) =' + calendarMonthMDP + ' AND Calendar_YEAR(Date__c)=' + calendarYearMDP;
				upliftValue = calculatePriceForMonthlyAvg(eachPricingContract,  displayCurrency, mdpWhereClause, pricingTerm);
			} when 'Normal Monthly Average' {
				System.debug('AM USING NORMAL MONTHLY');
				Integer calendarMonthMDP 	= enquiryDate.month();
				Integer calendarYearMDP 	= enquiryDate.year();
				mdpWhereClause += 'Calendar_Month(Date__c) =' + calendarMonthMDP + ' AND Calendar_YEAR(Date__c)=' + calendarYearMDP +
						' AND Date__c < ' + String.valueOf(enquiryDate);
				upliftValue = originalDate >= Date.today() ? 0 : calculatePriceForMonthlyAvg(eachPricingContract,  displayCurrency, mdpWhereClause, pricingTerm);
			} when 'Weekly Lag' {
				System.debug('AM USING WEEKLY LAG');
				if (enquiryDate > Date.today().toStartOfWeek().addDays(6)){
					upliftValue = 0;
				} else {
					//for weekly lag previeous weeks MDP should be fetched
					mdpWhereClause += GlobalUtil.findWeekClause(enquiryDate - 7);
					upliftValue = calculatePriceForMonthlyAvg(eachPricingContract,  displayCurrency, mdpWhereClause, pricingTerm);
				}
			}
		}
		return upliftValue;
	}

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

		String fxApiFieldName 		= eachPricingContract.FX_Rate_field_API_name__c;
		String fxAVGApiFieldName;
		Decimal upliftValue 		= eachPricingContract.Uplift__c;
		Decimal sourceFieldValue 	= 0;
		Decimal priceToCustomer 	= 0;
		System.debug(mdpWhereClause + '*mdpWhereClause***');


		//find the avg FX rates and value if field to be used to display the price to customer
		Map<String, Decimal> mapFXRate = GlobalUtil.findAverageFX(mdpWhereClause, eachPricingContract.Index__r.API_Name_Source__c);

		system.debug('looking at field ' + eachPricingContract.Index__r.API_Name_Source__c);

		sourceFieldValue = null != mapFXRate.get(eachPricingContract.Index__r.API_Name_Source__c)
						   ? mapFXRate.get(eachPricingContract.Index__r.API_Name_Source__c)
						   : 0;
		System.debug(mapFXRate + '***mapFXRate');
		System.debug(sourceFieldValue + '***sourceFieldValue');
		System.debug(JSON.serialize(mapFXRate) + '***mapFXRate');
		System.debug(eachPricingContract + '***eachPricingContract');

		System.debug('Uplift_Currency__c is ' + eachPricingContract.Uplift_Currency__c + ' and Index__r.Currency_Source__c is  ' + eachPricingContract.Index__r.Currency_Source__c);
		System.debug('eachPricingContract.FX_Rate_field_API_name__c is ' + eachPricingContract.FX_Rate_field_API_name__c);


		if(eachPricingContract.Uplift_Currency__c != eachPricingContract.Index__r.Currency_Source__c) {
			sourceFieldValue = (mapFXRate.containsKey(eachPricingContract.FX_Rate_field_API_name__c) &&
								null != mapFXRate.get(eachPricingContract.FX_Rate_field_API_name__c) )
							   ? sourceFieldValue / mapFXRate.get(eachPricingContract.FX_Rate_field_API_name__c)
							   : sourceFieldValue;
			System.debug('Converting to uplift value');
			System.debug(sourceFieldValue);

		}

		priceToCustomer=sourceFieldValue+upliftValue;
		System.debug(priceToCustomer+'**Before applying Dispaly Currency change');

		if (displayCurrency != eachPricingContract.Uplift_Currency__c) {
			fxAVGApiFieldName 	= 'FX_Rate_' + displayCurrency + '_' + eachPricingContract.Uplift_Currency__c + '__c';

			System.debug('fxAVGApiFieldName is ' + fxAVGApiFieldName);

			Decimal val 		= mapFXRate.get(fxAVGApiFieldName);

			System.debug('found in mapFXRate map is ' + mapFXRate.containsKey(fxAVGApiFieldName));

			priceToCustomer = (mapFXRate.containsKey(fxAVGApiFieldName) && null != mapFXRate.get(fxAVGApiFieldName) )
							  ? priceToCustomer / mapFXRate.get(fxAVGApiFieldName)
							  : priceToCustomer;
			System.debug('After Applying the Display conversion');
			System.debug('Applied rate '+mapFXRate.get(fxAVGApiFieldName));
			System.debug(priceToCustomer);
		}

		return priceToCustomer.setScale(2);
	}
}