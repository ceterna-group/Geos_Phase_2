/**
 * Class for master daily price trigger helper.
 */
public with sharing class MasterDailyPriceTriggerHelper {
	static Boolean notFound = true;
	/**
	* Creates a daily master procer record. Bulk scenario is  not considered
	* as MDP are inserted one at a time
	*
	* @param      listMasterDailyPrice  The list master daily price
	*/
	public static void createDailyMasterPriceRecord(Master_Daily_Price__c masterDailyPrice) {
		List<Master_Daily_Price__c> listCloneRecords = new List<Master_Daily_Price__c>();
		Map<String, Master_Daily_Price__c> mapMDP = new Map<String, Master_Daily_Price__c>();
		String notFoundForDate = '';
		//find end date for current month
		Date endDate = masterDailyPrice.Date__c.addMonths(1).toStartofMonth().addDays(-1);
		Date loopDate = masterDailyPrice.Date__c + 1;
		System.debug('loopDate' + loopDate);
		//create MDP for rest of the month, clone and set unique key and excluded field
		while (loopDate <= endDate) {
			//do not create record for saturday and sunday
			if (GlobalUtil.getDayOfWeek(loopDate) < 5) {
				Master_Daily_Price__c eachCloneMDP = masterDailyPrice.clone();
				eachCloneMDP.Excluded__c = false;
				eachCloneMDP.Date__c = loopDate;
				eachCloneMDP.Reconsile__c = false;
				eachCloneMDP.Manually_Created__c = false;
				eachCloneMDP.Unique_Key__c = String.valueOf(loopDate);
				mapMDP.put(String.valueOf(loopDate), eachCloneMDP);
				eachCloneMDP = (Master_Daily_Price__c) populatePricingTableFields(loopDate, eachCloneMDP, 'Master_Daily_Price__c');
				System.debug('eachCloneMDP' + eachCloneMDP);
				notFoundForDate = notFound ? notFoundForDate + ',' + String.valueOf(loopDate) : notFoundForDate;
			}
			loopDate = loopDate + 1;
			notFound = true;
		}
		System.debug('notFoundForDate' + notFoundForDate);
		System.debug('End mapMDP' + mapMDP);
		if (!mapMDP.isEmpty()) {
		    //snag 13: existing MDP where Manually_Created__c=true should be removed
            for(Master_Daily_Price__c existingMDP: [Select id,Unique_Key__c,Manually_Created__c
                                                    from Master_Daily_Price__c 
                                                    where Unique_Key__c in:mapMDP.keySet()
                                                    and Manually_Created__c=true]){
                if(!String.isEmpty(existingMDP.Unique_Key__c) && mapMDP.containsKey(existingMDP.Unique_Key__c)){
                    mapMDP.remove(existingMDP.Unique_Key__c);
                }
            }
            //snag 13: ends
			Schema.SObjectField externalIdField = Master_Daily_Price__c.Fields.Unique_Key__c;
			database.upsert(mapMDP.values(), externalIdField, false);
			//send email if pricing data table not dound
			if (!String.isEmpty(notFoundForDate))
				GlobalUtil.sendEmail(new String[] {Label.EMAIL_PRICING_TABLE_NOT_FOUND}, Label.EMAIL_SUBJECT_PRICING_TABLE_NOT_FOUND, '<b>No platts data published</b> for following dates.' + '<br/>' + notFoundForDate);
		}
	}

	/**
	 * { function_description }
	 *
	 * @param      validDate      The valid date
	 * @param      eachClonedMDP  Each cloned mdp
	 * @param      objectApiName  The object api name
	 *
	 * @return     { description_of_the_return_value }
	 */
	public static sObject populatePricingTableFields(Date validDate,
	        sObject eachClonedMDP,
	        String objectApiName) {
		Set<String> foundField = new Set<String>();
		Set<String> setIndex = new Set<String>();
		//get the pricing table data and iterate over each Index mapping to fnd out each of MDP field to be updated
		for (Pricing_Table__c eachRecord : [select id, Index_Mapping__c, FX_Rate_field_API_name__c, Uplift_Value__c, Index_Mapping__r.API_Name_Source__c,
		                                    Index_Mapping__r.API_Name_Output__c, Index_Mapping__r.Currency_Output__c,
		                                    Index_Mapping__r.Currency_Source__c, Uplift__c, Uplift_Currency__c
		                                    from Pricing_Table__c
		                                    where Index_Mapping__c != null and Index_Mapping__r.Object__c = :objectApiName
		                                            AND Valid_From__c <= :validDate and Valid_To__c >= :validDate
		                                            and Index_Mapping__r.Type__c = 'Pricing Table']) {
			Decimal upliftValue;
			//if uplift and index currency is same, no uplift required
			upliftValue = eachRecord.Index_Mapping__r.Currency_Source__c == eachRecord.Uplift_Currency__c ? eachRecord.Uplift__c : eachRecord.Uplift__c * (Decimal) eachClonedMDP.get(eachRecord.FX_Rate_field_API_name__c);
			eachClonedMDP.put(eachRecord.Index_Mapping__r.API_Name_Source__c, upliftValue);
			notFound = false;
			System.debug('eachClonedMDP***' + eachClonedMDP);
			foundField.add(eachRecord.Index_Mapping__r.API_Name_Source__c);
		}
		//update the field of each MDP as 0 if Pricing table data not found
		for (Index_Mapping__c eachMapping : [select id, API_Name_Source__c
		                                     from Index_Mapping__c
		                                     where Object__c = :objectApiName
		                                             AND Type__c = 'Pricing Table'
		                                                     and API_Name_Source__c != null] ) {
			if (!foundField.contains(eachMapping.API_Name_Source__c)) {
				eachClonedMDP.put(eachMapping.API_Name_Source__c, 0);
			}
		}
		System.debug('returnSObject before***' + eachClonedMDP);
		return eachClonedMDP;
	}
}