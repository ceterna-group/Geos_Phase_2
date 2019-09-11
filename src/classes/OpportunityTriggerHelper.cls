/**
 * @File Name          : OpportunityTriggerHelper.cls
 * @Description        : 
 * @Author             : Girish P
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 4/17/2019, 1:00:29 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    4/17/2019, 12:59:50 AM   Girish P     Initial Version
**/
public with sharing class OpportunityTriggerHelper {
	public static void updateExternalId() {
		for (Opportunity eachOppty : (List<Opportunity>)Trigger.new) {
			if (eachOppty.External_Id__c == null
			        || (!Trigger.isInsert && (GlobalUtil.isChanged(eachOppty.id, 'Delivery_Terminal__c')
			                                  || GlobalUtil.isChanged(eachOppty.id, 'CloseDate')
			                                  || GlobalUtil.isChanged(eachOppty.id, 'AccountId'))))
				eachOppty.External_Id__c = eachOppty.AccountId + '_'
				                           + eachOppty.Delivery_Terminal__c
				                           + '_' + String.valueOf(eachOppty.CloseDate);
		}
	}
}