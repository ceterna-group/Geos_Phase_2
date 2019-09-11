@isTest
private class SupplyCostTriggerHandlerTest 
{
	@isTest
	public static void testSupplyCostLineInsert1()
	{
		Test.startTest();
		Account cusAccount = createCustomerAccount();

		Account dtAccount1 = createDeliveryTerminalAccount('_1');
		Account dtAccount2 = createDeliveryTerminalAccount('_2');
		insert new List<Account>{cusAccount, dtAccount1, dtAccount2};

		Terminal_Costs__c tc1 = createTerminalCostsForAccount(dtAccount1.Id, 10, 'Gasoline 10ppm');
		Terminal_Costs__c tc2 = createTerminalCostsForAccount(dtAccount1.Id, 20, 'Ethanol');
		Terminal_Costs__c tc3 = createTerminalCostsForAccount(dtAccount1.Id, 30, 'Diesel 10 ppm');

		Terminal_Costs__c tc4 = createTerminalCostsForAccount(dtAccount2.Id, 40, 'Gasoline 10ppm');
		Terminal_Costs__c tc5 = createTerminalCostsForAccount(dtAccount2.Id, 50, 'Ethanol');
		insert new List<Terminal_Costs__c>{tc1, tc2, tc3, tc4, tc5};

		Opportunity enquiry = createEnquiry(cusAccount.Id, dtAccount1.Id);
		insert enquiry;

		SupplyCost_Line__c sc1 = createSupplyCostForOpp(enquiry.Id, 'Terminal Charges', 'Gasoline 10ppm', null);

		insert sc1;

		Test.stopTest();

		SupplyCost_Line__c sc2 = [Select Id, Delivery_Terminal__c, Cost_to_Geos_Local_Currency__c from SupplyCost_Line__c where Id = :sc1.Id];

		System.assert(sc2 != null);
		System.assertEquals(dtAccount1.Id, sc2.Delivery_Terminal__c);
		System.assertEquals(10, sc2.Cost_to_Geos_Local_Currency__c);
	}

	@isTest
	public static void testSupplyCostLineInsert2()
	{
		Test.startTest();
		Account cusAccount = createCustomerAccount();

		Account dtAccount1 = createDeliveryTerminalAccount('_1');
		Account dtAccount2 = createDeliveryTerminalAccount('_2');
		insert new List<Account>{cusAccount, dtAccount1, dtAccount2};

		Terminal_Costs__c tc1 = createTerminalCostsForAccount(dtAccount1.Id, 10, 'Gasoline 10ppm');
		Terminal_Costs__c tc2 = createTerminalCostsForAccount(dtAccount1.Id, 20, 'Ethanol');
		Terminal_Costs__c tc3 = createTerminalCostsForAccount(dtAccount1.Id, 30, 'Diesel 10 ppm');

		Terminal_Costs__c tc4 = createTerminalCostsForAccount(dtAccount2.Id, 40, 'Gasoline 10ppm');
		Terminal_Costs__c tc5 = createTerminalCostsForAccount(dtAccount2.Id, 50, 'Ethanol');
		insert new List<Terminal_Costs__c>{tc1, tc2, tc3, tc4, tc5};

		Opportunity enquiry = createEnquiry(cusAccount.Id, dtAccount1.Id);
		insert enquiry;

		SupplyCost_Line__c sc1 = createSupplyCostForOpp(enquiry.Id, 'Terminal Charges', 'Ethanol', dtAccount2.Id);

		insert sc1;

		Test.stopTest();

		SupplyCost_Line__c sc2 = [Select Id, Delivery_Terminal__c, Cost_to_Geos_Local_Currency__c from SupplyCost_Line__c where Id = :sc1.Id];

		System.assert(sc2 != null);
		System.assertEquals(dtAccount2.Id, sc2.Delivery_Terminal__c);
		System.assertEquals(50, sc2.Cost_to_Geos_Local_Currency__c);
	}

	@isTest
	public static void testSupplyCostLineUpdate1()
	{
		Test.startTest();
		Account cusAccount = createCustomerAccount();

		Account dtAccount1 = createDeliveryTerminalAccount('_1');
		Account dtAccount2 = createDeliveryTerminalAccount('_2');
		insert new List<Account>{cusAccount, dtAccount1, dtAccount2};

		Terminal_Costs__c tc1 = createTerminalCostsForAccount(dtAccount1.Id, 10, 'Gasoline 10ppm');
		Terminal_Costs__c tc2 = createTerminalCostsForAccount(dtAccount1.Id, 20, 'Ethanol');
		Terminal_Costs__c tc3 = createTerminalCostsForAccount(dtAccount1.Id, 30, 'Diesel 10 ppm');

		Terminal_Costs__c tc4 = createTerminalCostsForAccount(dtAccount2.Id, 40, 'Gasoline 10ppm');
		Terminal_Costs__c tc5 = createTerminalCostsForAccount(dtAccount2.Id, 50, 'Ethanol');
		insert new List<Terminal_Costs__c>{tc1, tc2, tc3, tc4, tc5};

		Opportunity enquiry = createEnquiry(cusAccount.Id, dtAccount1.Id);
		insert enquiry;

		SupplyCost_Line__c sc1 = createSupplyCostForOpp(enquiry.Id, 'Terminal Charges', 'Ethanol', dtAccount2.Id);

		insert sc1;

		SupplyCost_Line__c sc2 = [Select Id, Delivery_Terminal__c, Cost_to_Geos_Local_Currency__c from SupplyCost_Line__c where Id = :sc1.Id];

		System.assert(sc2 != null);
		System.assertEquals(dtAccount2.Id, sc2.Delivery_Terminal__c);
		System.assertEquals(50, sc2.Cost_to_Geos_Local_Currency__c);

		sc2.Delivery_Terminal__c = dtAccount1.Id;
		update sc2;

		SupplyCost_Line__c sc3 = [Select Id, Delivery_Terminal__c, Cost_to_Geos_Local_Currency__c from SupplyCost_Line__c where Id = :sc2.Id];

		System.assert(sc3 != null);
		System.assertEquals(dtAccount1.Id, sc3.Delivery_Terminal__c);
		System.assertEquals(20, sc3.Cost_to_Geos_Local_Currency__c);


		Test.stopTest();		
	}

	@isTest
	public static void testSupplyCostLineUpdate2()
	{
		Test.startTest();
		Account cusAccount = createCustomerAccount();

		Account dtAccount1 = createDeliveryTerminalAccount('_1');
		Account dtAccount2 = createDeliveryTerminalAccount('_2');
		insert new List<Account>{cusAccount, dtAccount1, dtAccount2};

		Terminal_Costs__c tc1 = createTerminalCostsForAccount(dtAccount1.Id, 10, 'Gasoline 10ppm');
		Terminal_Costs__c tc2 = createTerminalCostsForAccount(dtAccount1.Id, 20, 'Ethanol');
		Terminal_Costs__c tc3 = createTerminalCostsForAccount(dtAccount1.Id, 30, 'Diesel 10 ppm');

		Terminal_Costs__c tc4 = createTerminalCostsForAccount(dtAccount2.Id, 40, 'Gasoline 10ppm');
		Terminal_Costs__c tc5 = createTerminalCostsForAccount(dtAccount2.Id, 50, 'Ethanol');
		insert new List<Terminal_Costs__c>{tc1, tc2, tc3, tc4, tc5};

		Opportunity enquiry = createEnquiry(cusAccount.Id, dtAccount1.Id);
		insert enquiry;

		SupplyCost_Line__c sc1 = createSupplyCostForOpp(enquiry.Id, 'Terminal Charges', 'Ethanol', dtAccount2.Id);

		insert sc1;

		SupplyCost_Line__c sc2 = [Select Id, Delivery_Terminal__c, Cost_to_Geos_Local_Currency__c from SupplyCost_Line__c where Id = :sc1.Id];

		System.assert(sc2 != null);
		System.assertEquals(dtAccount2.Id, sc2.Delivery_Terminal__c);
		System.assertEquals(50, sc2.Cost_to_Geos_Local_Currency__c);

		sc2.Cost_Type__c = 'Product';
		update sc2;

		SupplyCost_Line__c sc3 = [Select Id, Delivery_Terminal__c, Cost_to_Geos_Local_Currency__c from SupplyCost_Line__c where Id = :sc2.Id];

		System.assert(sc3 != null);
		System.assertEquals(dtAccount2.Id, sc3.Delivery_Terminal__c);
		System.assertEquals(50, sc3.Cost_to_Geos_Local_Currency__c);


		Test.stopTest();		
	}

	@isTest
	public static void testSupplyCostLineUpdate3()
	{
		Test.startTest();
		Account cusAccount = createCustomerAccount();

		Account dtAccount1 = createDeliveryTerminalAccount('_1');
		Account dtAccount2 = createDeliveryTerminalAccount('_2');
		insert new List<Account>{cusAccount, dtAccount1, dtAccount2};

		Terminal_Costs__c tc1 = createTerminalCostsForAccount(dtAccount1.Id, 10, 'Gasoline 10ppm');
		Terminal_Costs__c tc2 = createTerminalCostsForAccount(dtAccount1.Id, 20, 'Ethanol');
		Terminal_Costs__c tc3 = createTerminalCostsForAccount(dtAccount1.Id, 30, 'Diesel 10 ppm');

		Terminal_Costs__c tc4 = createTerminalCostsForAccount(dtAccount2.Id, 40, 'Gasoline 10ppm');
		Terminal_Costs__c tc5 = createTerminalCostsForAccount(dtAccount2.Id, 50, 'Ethanol');
		insert new List<Terminal_Costs__c>{tc1, tc2, tc3, tc4, tc5};

		Opportunity enquiry = createEnquiry(cusAccount.Id, dtAccount1.Id);
		insert enquiry;

		SupplyCost_Line__c sc1 = createSupplyCostForOpp(enquiry.Id, 'Terminal Charges', 'Ethanol', dtAccount1.Id);

		insert sc1;

		SupplyCost_Line__c sc2 = [Select Id, Delivery_Terminal__c, Cost_to_Geos_Local_Currency__c from SupplyCost_Line__c where Id = :sc1.Id];

		System.assert(sc2 != null);
		System.assertEquals(dtAccount1.Id, sc2.Delivery_Terminal__c);
		System.assertEquals(20, sc2.Cost_to_Geos_Local_Currency__c);

		sc2.Product_or_Service__c = 'Diesel 10 ppm';
		update sc2;

		SupplyCost_Line__c sc3 = [Select Id, Delivery_Terminal__c, Cost_to_Geos_Local_Currency__c from SupplyCost_Line__c where Id = :sc2.Id];

		System.assert(sc3 != null);
		System.assertEquals(dtAccount1.Id, sc3.Delivery_Terminal__c);
		System.assertEquals(30, sc3.Cost_to_Geos_Local_Currency__c);


		Test.stopTest();		
	}

	public static Account createDeliveryTerminalAccount(String NameStr)
	{
		Id accRecordTypeId = [Select Id from RecordType where SObjectType = 'Account' and DeveloperName='Delivery_Terminal'].Id;
		Account acc = new Account( Name = 'Delivery Terminal Test Account'+NameStr, RecordTypeId=accRecordTypeId);

		return acc;
	}

	public static Account createCustomerAccount()
	{
		Id accRecordTypeId = [Select Id from RecordType where SObjectType = 'Account' and DeveloperName='Customer'].Id;
		Account acc = new Account( Name = 'Test Account', RecordTypeId=accRecordTypeId);

		return acc;
	}

	public static Opportunity createEnquiry(String accountId, String deliveryTerAccountId)
	{
		Opportunity opp = new Opportunity(Name='Test Opp', AccountId=accountId, StageName='Enquiry', 
			CloseDate=System.today(), Delivery_Terminal__c=deliveryTerAccountId);
		return opp;
	}

	public static Terminal_Costs__c createTerminalCostsForAccount(String accountId, Decimal cost, String grade)
	{
		Terminal_Costs__c tc = new Terminal_Costs__c(Charge_per_Metric_Tonne__c=cost, Grade__c=grade, Supplier_Terminal__c=accountId);
		return tc;
	}

	public static SupplyCost_Line__c createSupplyCostForOpp(String oppId, String costType, String prodorservice, String dtAccountId)
	{
		SupplyCost_Line__c scl = new SupplyCost_Line__c(Cost_Type__c=costType, Delivery_Terminal__c=dtAccountId, Enquiry__c=oppId, 
										Product_or_Service__c=prodorservice, Currency__c='GBP');
		return scl;
	}
}