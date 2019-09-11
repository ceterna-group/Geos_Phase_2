/**
 * @File Name          : Batch_RecalculateQuoteLinePrice.cls
 * @Description        : 
 * @Author             : Girish P
 * @Group              : 
 * @Last Modified By   : Girish P
 * @Last Modified On   : 6/10/2019, 9:32:28 PM
 * @Modification Log   : Class for batch recalculate quote line price.
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    6/10/2019, 9:32:14 PM   Girish P     Initial Version
**/
global class Batch_RecalculateQuoteLinePrice implements Database.Batchable<sObject>, Database.stateful {

	String query = 'Select id from Opportunity where ';
	string sWhereClause;
	Integer totalaffectedOpportunity;
	global Batch_RecalculateQuoteLinePrice(ApexPages.StandardController stdController) {
	}
	/**
	 * { function_description }
	 *
	 * @param      probableDates  The probable dates
	 * @param      month          The month
	 *
	 * @return     { description_of_the_return_value }
	 */
	global Batch_RecalculateQuoteLinePrice(Date probableDates,
	                                       Integer month) {
		totalaffectedOpportunity = 0;
		sWhereClause = ' (CloseDate>=' + string.valueOf(probableDates) + ' AND CloseDate<=' + string.valueOf(probableDates + 8)
		               + ') OR (Delivery_Date__c>=' + String.valueOf(probableDates)
		               + ' AND Delivery_Date__c<=' + String.valueOf(probableDates + 8) + ')'
		               + ' OR Calendar_Month(Delivery_Date__c) =' + String.valueOf(month + 1)
		               + ' OR Calendar_Month(CloseDate) =' + String.valueOf(month + 1)
		               + ' OR Calendar_Month(CloseDate) =' + String.valueOf(month)
		               + ' OR Calendar_Month(Delivery_Date__c) =' + String.valueOf(month);
	}

	/**
	 * { function_description }
	 *
	 * @param      BC    { parameter_description }
	 *
	 * @return     { description_of_the_return_value }
	 */
	global Database.QueryLocator start(Database.BatchableContext BC) {
		system.debug(query + sWhereClause + '**sWhereClause');
		return Database.getQueryLocator(query + sWhereClause );
	}

	/**
	 * { function_description }
	 *
	 * @param      scope  The scope
	 *
	 * @return     { description_of_the_return_value }
	 */
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		Set<String> setOpptyid = new Set<String>();
		for (sObject eachObject : scope) {
			setOpptyid.add(eachObject.Id);
		}
		Map<Id, Quote_Line__c> mapQuoteLine = QuoteLineTriggerHelper.getPricingToCustomer(setOpptyid, null);
		totalaffectedOpportunity += mapQuoteLine.size();
		update mapQuoteLine.values();
	}

	/**
	 * { function_description }
	 *
	 * @param      BC    { parameter_description }
	 *
	 * @return     { description_of_the_return_value }
	 */
	global void finish(Database.BatchableContext BC) {
		GlobalUtil.sendEmail(new String[] {Label.EMAIL_OPPORTUNITY_RECALCULATIONS},
		                     Label.EMAIL_SUBJECT_OPPORTUNITY_RECALCULATION,
		                     '<b>Total ' + totalaffectedOpportunity + ' affected Opportunities are recalculated successfully.' + '<br/>');
	}

	/**
	 * { function_description }
	 *
	 * @param      mdpId  The mdp identifier
	 *
	 * @return     { description_of_the_return_value }
	 */
	@RemoteAction
	WebService static String reCalculateAffectedOpportunities(String mdpId) {
		String theId = null == mdpId ? ApexPages.currentPage().getParameters().get('id') : mdpId;
		Master_Daily_Price__c mdp = [Select id, Date__c
		                             from Master_Daily_Price__c
		                             where id = :mdpId];
		Integer calendarMonth = (mdp.Date__c - 1).month();
		Id batch = Database.executeBatch(new Batch_RecalculateQuoteLinePrice(mdp.date__c - 1, calendarMonth), 1);
		return 'Success';
	}

}