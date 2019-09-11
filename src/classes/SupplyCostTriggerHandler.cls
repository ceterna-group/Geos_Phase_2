public with sharing class SupplyCostTriggerHandler extends TriggerHandler   
{
	public override void beforeInsert() 
    {        
        updateDeliveryTerminal();
        getCostToGoesValue();
    }
    public override void beforeUpdate() 
    {        
        updateDeliveryTerminal();
        getCostToGoesValue();
    }

    public override void afterInsert()
    {}   	
    

    public override void afterUpdate() 
    {}

    public void updateDeliveryTerminal()
    {
        List<Id> enquiryIds = new List<Id>();
        List<Opportunity> opps = new List<Opportunity>();
        Map<Id, Id> oppIdToDeliveryTerminalIdMap = new Map<Id, Id>();

        for(SupplyCost_Line__c suppCostObj : (List<SupplyCost_Line__c>)Trigger.new)
        {
            if(suppCostObj.Delivery_Terminal__c == null)
                enquiryIds.add(suppCostObj.Enquiry__c);
        }

        if(enquiryIds != null && enquiryIds.size() > 0)
        {
            opps = [Select Id, Delivery_Terminal__c from Opportunity where Id In :enquiryIds];

            if(opps != null && opps.size() > 0)
            {
                for(Opportunity opp : opps)
                {
                    oppIdToDeliveryTerminalIdMap.put(opp.Id, opp.Delivery_Terminal__c);
                }
            }
        }

        for(SupplyCost_Line__c suppCostObj : (List<SupplyCost_Line__c>)Trigger.new)
        {
            if(suppCostObj.Delivery_Terminal__c == null)
            {
                if(oppIdToDeliveryTerminalIdMap != null && oppIdToDeliveryTerminalIdMap.size() > 0 && oppIdToDeliveryTerminalIdMap.containsKey(suppCostObj.Enquiry__c))
                {
                    suppCostObj.Delivery_Terminal__c = oppIdToDeliveryTerminalIdMap.get(suppCostObj.Enquiry__c);
                }
            }
        }
    }

    public void getCostToGoesValue()
    {
    	List<Id> accountDeliveryTerminalIds = new List<Id>();
    	List<Terminal_Costs__c> terminalCostList = new List<Terminal_Costs__c>();
    	Map<Id, Map<String, Decimal>> accountIdToTCGradeCostMap = new Map<Id, Map<String, Decimal>>();
    	Map<String, Decimal> gradeToCostMap = new Map<String, Decimal>();

    	for(SupplyCost_Line__c suppCostObj : (List<SupplyCost_Line__c>)Trigger.new)
    	{
    		if(suppCostObj.Cost_Type__c == 'Terminal Charges' && suppCostObj.Delivery_Terminal__c != null)
    		{
    			accountDeliveryTerminalIds.add(suppCostObj.Delivery_Terminal__c);
    		}
    	}


    	if(accountDeliveryTerminalIds != null && accountDeliveryTerminalIds.size() > 0)
    	{
    		terminalCostList = [Select Id, Name, Charge_per_Metric_Tonne__c, Grade__c,  Supplier_Terminal__c 
    							from Terminal_Costs__c where Supplier_Terminal__c In :accountDeliveryTerminalIds];

    		if(terminalCostList != null && terminalCostList.size() > 0)
    		{
    			for(Terminal_Costs__c termCostObj : terminalCostList)
    			{
    				if(accountIdToTCGradeCostMap.isEmpty() || (!accountIdToTCGradeCostMap.isEmpty() && accountIdToTCGradeCostMap.size() > 0 && !accountIdToTCGradeCostMap.containsKey(termCostObj.Supplier_Terminal__c)))
    					accountIdToTCGradeCostMap.put(termCostObj.Supplier_Terminal__c, new Map<String, Decimal>{termCostObj.Grade__c => termCostObj.Charge_per_Metric_Tonne__c}); 
    				else
    					accountIdToTCGradeCostMap.get(termCostObj.Supplier_Terminal__c).put(termCostObj.Grade__c, termCostObj.Charge_per_Metric_Tonne__c);

    			}
    		}
    	}

    	for(SupplyCost_Line__c suppCostObj : (List<SupplyCost_Line__c>)Trigger.new)
		{
			SupplyCost_Line__c oldSuppCostObj;

			if(Trigger.isBefore && Trigger.isUpdate)
				oldSuppCostObj = (SupplyCost_Line__c) Trigger.oldMap.get(suppCostObj.Id);

			if(suppCostObj.Cost_Type__c == 'Terminal Charges' && suppCostObj.Delivery_Terminal__c != null)
			{

                if(Trigger.isInsert || (Trigger.isUpdate && (suppCostObj.Delivery_Terminal__c != oldSuppCostObj.Delivery_Terminal__c) || (suppCostObj.Product_or_Service__c != oldSuppCostObj.Product_or_Service__c)))
                {
    				if(accountIdToTCGradeCostMap != null && accountIdToTCGradeCostMap.size() > 0 && accountIdToTCGradeCostMap.containsKey(suppCostObj.Delivery_Terminal__c))
    				{
    					gradeToCostMap = accountIdToTCGradeCostMap.get(suppCostObj.Delivery_Terminal__c);
    					if(gradeToCostMap != null && gradeToCostMap.size() > 0)
    					{
    						if(gradeToCostMap.containsKey(suppCostObj.Product_or_Service__c))             
    						   suppCostObj.Cost_to_Geos_Local_Currency__c = gradeToCostMap.get(suppCostObj.Product_or_Service__c);                            
                            else
                                suppCostObj.Cost_to_Geos_Local_Currency__c = null;                            
    					}
    				}
                }
			}
		}
    }
       
}