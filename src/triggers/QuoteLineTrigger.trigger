trigger QuoteLineTrigger on Quote_Line__c (after insert, after update, before insert, before update) {

	System.debug('executing trigger');
	(new QuoteLineTriggerHandler()).execute();
}