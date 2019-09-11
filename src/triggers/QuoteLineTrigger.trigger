trigger QuoteLineTrigger on Quote_Line__c (after insert, after update, before insert, before update) {
	(new QuoteLineTriggerHandler()).execute();
}