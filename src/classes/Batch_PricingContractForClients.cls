/**
 * @File Name          : Batch_PricingContractForClients.cls
 * @Description        : 
 * @Author             : Girish P
 * @Group              : 
 * @Last Modified By   : Girish P
 * @Last Modified On   : 7/13/2019, 11:41:50 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    6/10/2019, 9:31:45 PM   Girish P     Initial Version
**/
global class Batch_PricingContractForClients implements Database.Batchable<sObject>, Schedulable {
	global void execute(SchedulableContext sc) {
		Batch_PricingContractForClients batchJob = new Batch_PricingContractForClients();
		Database.executeBatch(batchJob, 1);
	}
	String query;

	global Batch_PricingContractForClients() {
		query =	+'Select Terminal__r.Name,Id,Index_Name__c, Report_Destination_1__c,Report_Destination_2__c,Report_Destination_3__c,Enquiry_vs_Delivery_Date__c,Product__c, Index__r.Report_Fields__c,Uplift_Currency__c, Uplift__c, External_Id__c,'
		        + ' FX_Rate_field_API_name__c, Index__r.API_Name_Source__c,'
		        + ' Report_Destination_4__c,Report_Destination_5__c,Report_Destination_6__c,Report_Destination_7__c,'
		        + ' Report_Destination_8__c,Report_Destination_9__c,Report_Destination_10__c,Report_Destination_11__c,Report_Destination_12__c,'
		        + ' Index__r.Currency_Source__c,Client__r.name, Contract_Valid_To__c, Pricing_Terms__c, Contract_Valid_From__c'
		        + ' from Pricing_Contract__c'
		        + ' where Client__c!=null and Index__c != null And Active__c = true'
		        + ' and Contract_Valid_To__c != null and Contract_Valid_From__c != null '
		        + ' and Pricing_Terms__c != null and Enquiry_vs_Delivery_Date__c != null ';
	}

	/**
	 * { function_description }
	 *
	 * @param      BC    { parameter_description }
	 *
	 * @return     { description_of_the_return_value }
	 */
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	/**
	 * { function_description }
	 *
	 * @param      scope  The scope
	 *
	 * @return     { description_of_the_return_value }
	 */
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		Map<String, list<String>> mapMDPFields = new Map<String, List<String>>();
		String mdpFields;
		Decimal priceToCustomer;
		Decimal totalPriceToCustomer=0.0000;
		Decimal actualPrice;
		List<String> emailDestination = new List<String>();
		List<String> listMDPFields = new List<String>();
		String subject;
		Decimal uplift;
		String contract;
		String currencySymbol='$ ';

		Pricing_Contract__c pricingContract= new Pricing_Contract__c();
		Decimal avegareExcahngeRate= 0;
		for (sObject eachPC : scope) {
			pricingContract= (Pricing_Contract__c)eachPC;
			contract = String.valueof(eachPC.get('Pricing_Terms__c'));
			//mdpFields = (String)eachPC.getSObject('Index__r').get('Report_Fields__c');
			mdpFields = (String)eachPC.getSObject('Index__r').get('API_Name_Source__c');
			subject = String.valueOf(eachPC.getSObject('Client__r').get('Name')) + '-' 
			+String.valueOf(eachPC.getSObject('Terminal__r').get('Name')) + '\n' 
			+ Date.today().format() + '-' + String.valueOf(eachPC.get('Product__c'));
			for (Integer i = 1; i < 13; i++) {
				if (null != String.valueOf(eachPC.get('Report_Destination_' + i + '__c')))
					emailDestination.add(String.valueOf(eachPC.get('Report_Destination_' + i + '__c')));
			}
		}
		subject=subject.replaceAll('BS2869:2010', '');
		if (!emailDestination.isEmpty()) {
			Date firstDay = Date.today().toStartofMonth();
			Date dateFilter = firstDay;
			if (firstDay == Date.today()) {
				//if (true) {
				//firstDay = (firstDay - 1 ).toStartofMonth();
				dateFilter -= 1;
			}
			Integer month = firstDay.month();
			Integer year = firstDay.year();
			String sWhereClause = '';
			List<sObject> listMDP = Database.query('Select id,Date__c,Day__c,Year_Month__c,'
			                                       + ' FX_Rate_GBP_USD__c,FX_Rate_USD_EUR__c,FX_Rate_GBP_EUR__c,' + mdpFields + ' from'
			                                       + ' Master_Daily_Price__c where Date__c=:dateFilter OR ( Calendar_Month(Date__c)=:month and Calendar_YEAR(Date__c)=:year ) order by Date__c asc');
			//No MDP tp process return
			if (listMDP.isEmpty()) {
				return;
			}
			String htmlBody = '<div><img width="200px" src="'+Label.GEOS_LOGO_URL+'"/></div><br/><br/><table style="border-collapse: collapse;border-color:black" border="1">';
			Map<String, Schema.SObjectField> fieldMap = GlobalUtil.getFields('Master_Daily_Price__c');
			htmlBody += '<tr style="background-color:' + CONSTANTS.PRICING_EMAIL_TABLE_HEADER_COLOR + '">';
			htmlBody += '<th style="width:60px">' + fieldMap.get('Date__c').getDescribe().getLabel() + '</th>';
			//below 2 columns arent needed, removed as per snag
			htmlBody += '<th style="width:60px">' + fieldMap.get('Day__c').getDescribe().getLabel() + '</th>';
			//htmlBody += '<th>' + fieldMap.get('Year_Month__c').getDescribe().getLabel() + '</th>';
			htmlBody += '<th style="width:60px">' + fieldMap.get('FX_Rate_GBP_USD__c').getDescribe().getLabel() + '</th>';
			//below 2 columns arent needed, removed as per snag
			//htmlBody += '<th>' + fieldMap.get('FX_Rate_USD_EUR__c').getDescribe().getLabel() + '</th>';
			//htmlBody += '<th>' + fieldMap.get('FX_Rate_GBP_EUR__c').getDescribe().getLabel() + '</th>';
			for (String eachField : mdpFields.split(',')) {
				htmlBody += '<th style="width:60px">' + fieldMap.get(eachField).getDescribe().getLabel() + '</th>';
			}
			htmlBody += '<th style="width:60px">' + pricingContract.Client__r.Name + ' - ' +pricingContract.Terminal__r.Name+' - Daily Prices' + '</th>';
			htmlBody += '</tr>';
			String color = '';
			Integer rowNo = 0;
			for (sObject mdp : listMDP) {
				Date mdpdate = Date.valueOf(mdp.get('Date__c'));
				if (mdpdate < Date.Today()) {
					color = CONSTANTS.PRICING_EMAIL_TABLE_PASTDATA_COLOR;
				} else {
					color = CONSTANTS.PRICING_EMAIL_TABLE_FUTURE_COLOR;
					if (Math.mod(rowNo, 2) == 0) {
						color = 'white';
					}
				}
				rowNo = rowNo + 1;
				htmlBody += '<tr style="background-color:' + color + '">';
				htmlBody += getTableColumn(String.valueOf(Date.valueOf(mdp.get('Date__c')).format()), color);
				htmlBody += getTableColumn(String.valueOf(mdp.get('Day__c')), color);
				//htmlBody += getTableColumn(String.valueOf(mdp.get('Year_Month__c')), color);
				avegareExcahngeRate += (Decimal)mdp.get('FX_Rate_GBP_USD__c');
				//htmlBody += getTableColumn('$ '+ String.valueOf(mdp.get('FX_Rate_GBP_USD__c')), color);
				//removing $ as per feedback
				htmlBody += getTableColumn(String.valueOf(mdp.get('FX_Rate_GBP_USD__c')), color);
				//htmlBody += getTableColumn(String.valueOf(mdp.get('FX_Rate_USD_EUR__c')), color);
				//htmlBody += getTableColumn(String.valueOf(mdp.get('FX_Rate_GBP_EUR__c')), color);
				for (String eachField : mdpFields.split(',')) {
					actualPrice = Decimal.valueOf(String.valueOf(mdp.get(eachField)));
					currencySymbol = fieldMap.get(eachField).getDescribe().getLabel().substring(0, 1) ;
					priceToCustomer=fieldMap.containsKey(pricingContract.FX_Rate_field_API_name__c)
						?(Decimal.valueOf(String.valueOf(mdp.get(pricingContract.FX_Rate_field_API_name__c)))/ pricingContract.Uplift__c)+ actualPrice
						:actualPrice+pricingContract.Uplift__c;
					totalPriceToCustomer+=priceToCustomer;
					htmlBody += getTableColumn(currencySymbol+ ' ' + actualPrice, '#00ffbf');
				}
				htmlBody += getTableColumn(currencySymbol+' '+priceToCustomer, color);
				htmlBody += '</tr>';
			}
			System.debug('htmlBody***' + htmlBody);
			if (CONSTANTS.EMAIL_AVERAGEROW_CONTRACT.contains(contract)) {
				List<String> sQuery = new List<String>();
				for (String eachField : mdpFields.split(',')) {
					sQuery.add('AVG(' + eachField + ') ' + eachField);
				}
				List<AggregateResult> listAvg = Database.query('Select ' + String.join(sQuery, ',') + ' from Master_Daily_Price__c where Calendar_Month(Date__c)=:month and Calendar_YEAR(Date__c)=:year');
				String stringResult = JSON.serialize(listAvg[0]);
				stringResult = stringResult.replace('"attributes":{"type":"AggregateResult"},', '');
				System.debug(stringResult);
				Map<String, Decimal> mapAVGdata = (Map<String, Decimal>)JSON.deserialize(stringResult, Map<String, Decimal>.class);
				htmlBody += '<tr bgcolor="' + CONSTANTS.PRICING_EMAIL_TABLE_HEADER_COLOR 
				+ '"><td colspan="2" style="align:right"><b>Average</b></td>';
				//Sorry to be a pain, but can we now remove the USD $ sign from the exchange rate column. We know we asked for it to be added but have since decided that it doesn’t look right and is not needed.
				//htmlBody += getTableColumn('$ '+ String.valueOf((avegareExcahngeRate/rowNo)), '#00ffbf ');
				htmlBody += getTableColumn(String.valueOf((avegareExcahngeRate/rowNo).setScale(4)), '#00ffbf');
				for (String eachField : mdpFields.split(',')) {
            		htmlBody += getTableColumn(fieldMap.get(eachField).getDescribe().getLabel().substring(0, 1) + ' ' + (mapAVGdata.get(eachField)).setScale(2), '#00ffbf');
				}
				htmlBody += getTableColumn(currencySymbol+' ' + (totalPriceToCustomer/rowNo).setScale(2), '#00ffbf');
				htmlBody += '</tr>';
			}
			htmlBody += '</table>';
			htmlBody += Label.EMAIL_PRICING_CONTRACT_SIGNATURE	;
			GlobalUtil.sendEmail(emailDestination, subject, htmlBody);
		}
	}
	/**
	 * { function_description }
	 *
	 * @param      BC    { parameter_description }
	 *
	 * @return     { description_of_the_return_value }
	 */
	global void finish(Database.BatchableContext BC) {
	}
	/**
	 * Gets the table column.
	 *
	 * @param      tableData  The table data
	 * @param      tdcolor    The tdcolor
	 *
	 * @return     The table column.
	 */
	public static String getTableColumn(String tableData, String tdcolor) {
		return '<td style="width:60px;text-align:center">' + tableData + '</td>';
	}

}