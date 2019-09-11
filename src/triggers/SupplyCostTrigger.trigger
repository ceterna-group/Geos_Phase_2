trigger SupplyCostTrigger on SupplyCost_Line__c (before insert, before update, after insert, after update) 
{
	(new SupplyCostTriggerHandler()).execute();
}