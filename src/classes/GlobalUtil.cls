/**
 * Class for global utility.
 */
public with sharing class GlobalUtil {
	/***************************************************************************************
	       @input  :sObjectName-Name of sObject to e queried
	       sIdentifieldAPI - Field API Name to be used as identifier
	       sIdentifiers - data for identifier field
	       @output : returns Lead id for newly created lead
	       @Description : upsert the lead and asset corresponding to the newly activation sim.
	****************************************************************************************/
	public static List<sObject> getSObjectRecords(
	    String sObjectName,
	    String sIdentifieldAPI,
	    String sIdentifiers,
	    String sWhereClause
	) {
		String OPERATOR_WHERE;
		String sWhereClauseDynamic;
		List<String> identifiers = new List<String>();
		if (NULL != sWhereClause) {
			sWhereClauseDynamic = sWhereClause;
		} else if (sIdentifiers.contains(',')) {
			identifiers = sIdentifiers.split(',');
			OPERATOR_WHERE = ' in ';
			sWhereClauseDynamic = sIdentifieldAPI + OPERATOR_WHERE + ' :identifiers ';
		} else {
			identifiers.add(sIdentifiers);
			OPERATOR_WHERE = ' = ';
			sWhereClauseDynamic = sIdentifieldAPI + OPERATOR_WHERE + ' :identifiers ';
		}
		String query = 'SELECT ';
		Set<String> sFields = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().keySet();
		String sAllFields = String.join(new List<String>(sFields), ',');
		query += sAllFields + ' FROM ' + sObjectName + ' WHERE ' + sWhereClauseDynamic;
		System.debug('Query****' + query);
		return database.query(query);
	}

	/**
	 * Gets the day of week.
	 *
	 * @param      weekDate  The current date. 0 represents first day
	 *
	 * @return     The day of week.
	 */
	public static Integer getDayOfWeek(Date weekDate) {
		return  weekDate.toStartofWeek().daysBetween(weekDate);
	}
	/**
	 * Sends an email.
	 *
	 * @param      emailTo       The email to
	 * @param      emailSubject  The email subject
	 * @param      emailBody     The email body
	 */
	public static void sendEmail(String[] emailTo, String emailSubject, String emailBody) {
		OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'commercial@geosgroup.com'];

		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		if ( owea.size() > 0 ) {
			message.setOrgWideEmailAddressId(owea.get(0).Id);
		}
		message.setToAddresses(emailTo);
		message.optOutPolicy = 'FILTER';
		message.subject = emailSubject;
		//message.plainTextBody = emailBody;
		message.setHtmlBody( emailBody);
		Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
		Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
		if (results[0].success) {
			System.debug('The email was sent successfully.');
		} else {
			System.debug('The email failed to send: ' + results[0].errors[0].message);
		}
	}
	/**
	 * Determines if field value isc changed.
	 *
	 * @param      objectId  The object identifier
	 * @param      fieldApi  The field api
	 *
	 * @return     True if changed, False otherwise.
	 */
	public static boolean isChanged(String objectId, String fieldApi) {
		sObject oldObject = Trigger.oldMap.get(objectId);
		sObject newObject = Trigger.newMap.get(objectId);
		// if (null != oldObject.get(fieldApi) && null != newObject.get(fieldApi) && oldObject.get(fieldApi) != newObject.get(fieldApi)) {
		if (null != newObject.get(fieldApi) && oldObject.get(fieldApi) != newObject.get(fieldApi)) {
			return true;
		}
		return false;
	}
	public static Map<String, Schema.SObjectField> getFields(String type) {
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Schema.SObjectType leadSchema = schemaMap.get(type);
		Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
		return fieldMap;
		//for (String fieldName: fieldMap.keySet()) {
		//	System.debug('##Field API Name='+fieldName);// list of all field API name
		//	fieldMap.get(fieldName).getDescribe().getLabel();//It provides to get the object fields label.
		//}
	}
	/**
	 * get MDP weeks filter clause
	 *
	 * @param      weekDate  The week date
	 *
	 * @return     { description_of_the_return_value }
	 */
	public static String findWeekClause(Date weekDate) {
		Date startWeek = weekDate.tostartofweek();
		Date endWeek = startWeek + 6 ;
		String sWhereClause = ' Date__c>=' + String.valueOf(startWeek) + ' AND Date__c <= ' + String.valueOf(startWeek + 6);
		return sWhereClause;
	}
	/**
	 * { function_description }
	 *
	 * @param      mdpWhereClause  The mdp where clause
	 * @param      apiFieldSource  The api field source
	 *
	 * @return     { description_of_the_return_value }
	 */
	public static Map<String, Decimal> findAverageFX(String mdpWhereClause, String apiFieldSource) {
		System.debug('mdpWhereClause***AVG**' + mdpWhereClause);
		List<AggregateResult> listAggregate = Database.query('Select AVG(' + apiFieldSource + ')' + apiFieldSource
											+ 	',AVG(FX_Rate_EUR_GBP__c)FX_Rate_EUR_GBP__c,'
		                                      + ' AVG(FX_Rate_EUR_USD__c)FX_Rate_EUR_USD__c, AVG(FX_Rate_GBP_EUR__c)FX_Rate_GBP_EUR__c,'
		                                      + ' AVG(FX_Rate_GBP_USD__c)FX_Rate_GBP_USD__c, AVG(FX_Rate_USD_EUR__c)FX_Rate_USD_EUR__c,'
		                                      + ' AVG(FX_Rate_USD_GBP__c)FX_Rate_USD_GBP__c from'
		                                      + ' Master_Daily_Price__c where Excluded__c=false AND ' + mdpWhereClause);
		system.debug('using latest monthly average: getting listAggregate');


		Map<String, Decimal> mapFXRate = new Map<String, Decimal> ();
		String stringResult = JSON.serialize(listAggregate[0]);
		stringResult = stringResult.replace('"attributes":{"type":"AggregateResult"},', '');
		System.debug(stringResult);
		return (Map<String, Decimal>)JSON.deserialize(stringResult, Map<String, Decimal>.class);
	}
	public static Map<String, Id> getRecordTypes(String objectAPIName) {
		Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objectAPIName).getDescribe();
		List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
		Map<String, Id> mapofCaseRecordTypeNameandId = new Map<String, Id>();
		for (Schema.RecordTypeInfo info : recordTypeInfo) {
			mapofCaseRecordTypeNameandId.put(info.getName(), info.getRecordTypeId());
		}
		system.debug('***mapofCaseRecordTypeNameandId*' + mapofCaseRecordTypeNameandId);
		return mapofCaseRecordTypeNameandId;
	}

}