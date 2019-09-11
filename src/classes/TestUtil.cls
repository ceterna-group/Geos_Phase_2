/**
 * Class for test utility.
 */
@ISTEST
public class TestUtil {

	/**
	 * Creates an account.
	 *
	 * @param      name            The name
	 * @param      recordTypeName  The record type name
	 *
	 * @return     { description_of_the_return_value }
	 */
	public Static Account createAccount(String name, String recordTypeName) {
		Account a = new Account();
		a.Name = name;
		a.recordTypeID = GlobalUtil.getRecordTypes('Account').get(recordTypeName);
		return a;
	}

	/**
	 * Creates bulk accounts.
	 *
	 * @param      numAccts        The number accounts
	 * @param      name            The name
	 * @param      recordTypeName  The record type name
	 *
	 * @return     { description_of_the_return_value }
	 */
	public static List<Account> createBulkAccounts(Integer numAccts, String name, String recordTypeName) {
		List<Account> accts = new List<Account>();
		for (Integer i = 0; i < numAccts; i++) {
			Account a = createAccount(name + String.ValueOf(i), recordTypeName);
			accts.add(a);
		}
		return accts;
	}


	/**
	 * Creates a contact.
	 *
	 * @param      acctId     The account identifier
	 * @param      firstName  The first name
	 * @param      lastName   The last name
	 *
	 * @return     { description_of_the_return_value }
	 */
	public Static Contact createContact(Id acctId, String firstName, String lastName) {
		Contact ct = createContact(firstName, lastName);
		ct.AccountId = acctId;
		ct.Phone = '0439876780';
		ct.MobilePhone = '0434567890';
		ct.Email = getRandomString() + 'll@gmail.com';
		ct.Title = getRandomString();
		System.debug('contact created: ' + ct);
		return ct;
	}

	/**
	 * Creates a contact.
	 *
	 * @param      firstName  The first name
	 * @param      lastName   The last name
	 *
	 * @return     { description_of_the_return_value }
	 */
	public Static Contact createContact(String firstName, String lastName) {
		Contact c = new Contact();
		c.Salutation = 'Mr.';
		c.FirstName = firstName;
		c.LastName = lastName;
		//c.LastName = getRandomString();
		c.Birthdate = Date.newInstance(2000, 2, 18);
		return c;
	}

	/**
	 * Adds a contact to account.
	 *
	 * @param      accountId  The account identifier
	 * @param      contactId  The contact identifier
	 *
	 * @return     { description_of_the_return_value }
	 */
	public Static Boolean addContactToAccount(Id accountId, Id contactId) {
		List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE Id = :contactId];
		if (!contacts.isEmpty()) {
			Contact contact = contacts.get(0);
			contact.AccountId = accountId;
			update contact;
			return true;
		}
		return false;
	}

	/**
	 * Gets the account.
	 *
	 * @param      accountId  The account identifier
	 *
	 * @return     The account.
	 */
	public Static Account getAccount(Id accountId) {
		List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id = :accountId];
		if (!accounts.isEmpty()) {
			return accounts[0];
		} else {
			return null;
		}
	}

	/**
	 * Gets the contact.
	 *
	 * @param      contactId  The contact identifier
	 *
	 * @return     The contact.
	 */
	public Static Contact getContact(Id contactId) {
		List<Contact> contacts = [SELECT Id, Name FROM Contact WHERE Id = :contactId];
		if (!contacts.isEmpty()) {
			return contacts[0];
		} else {
			return null;
		}
	}


	/**
	 * Creates an opportunity.
	 *
	 * @param      optyName          The opty name
	 * @param      accId             The acc identifier
	 * @param      terminal          The terminal
	 * @param      pricingMechanism  The pricing mechanism
	 * @param      stageName         The stage name
	 *
	 * @return     { description_of_the_return_value }
	 */
	public static Opportunity createOpportunity(String optyName,
	        Id accId,
	        Id terminal,
	        String pricingMechanism,
	        String stageName) {
		Opportunity opp = new Opportunity();
		opp.Name = optyName;
		opp.StageName = stageName;
		opp.CloseDate = Date.today();
		opp.accountId = accId;
		opp.Delivery_Terminal__c = terminal;
		opp.Invoice_Or_Credit__c = 'Invoice';
		opp.Pricing_Mechanism__c = pricingMechanism;
		return opp;
	}
	/**
	 * Creates an im.
	 *
	 * @param      source          The source
	 * @param      currencySOurce  The currency s ource
	 * @param      objectName      The object name
	 * @param      type            The type
	 */
	public static Index_Mapping__c createIM(String source,
	                                        String currencySOurce,
	                                        String objectName) {
		Index_Mapping__c sobj = new Index_Mapping__c(
		    API_Name_Source__c = source,// API Name (Source)
		    Currency_Source__c = currencySOurce,// Currency (Source)
		    Object__c = objectName// Object
		                //Type__c = 'Pricing Contract',
		                // Type
		);
		insert sobj;
		return sobj;
	}
	/**
	 * Creates a pc.
	 *
	 * @param      clientId      The client identifier
	 * @param      terminal      The terminal
	 * @param      im            { parameter_description }
	 * @param      validTo       The valid to
	 * @param      pricingTerm   The pricing term
	 * @param      deliveryType  The delivery type
	 * @param      uplift        The uplift
	 * @param      product       The product
	 * @param      destination   The destination
	 */
	public static Pricing_Contract__c createPC(ID clientId,
	        ID terminal,
	        ID im,
	        Date validTo,
	        String pricingTerm,
	        String deliveryType,
	        Decimal uplift,
	        String upliftC,
	        String product,
	        String destination) {
		Pricing_Contract__c sobj = new Pricing_Contract__c(
		    Client__c = clientId,                                          // Client
		    Report_Destination_1__c = destination,                         // Report Destination 1
		    Terminal__c = terminal,                                          // Terminal
		    Contract_Valid_From__c = Date.valueOf('2017-01-01'),                      // Contract Valid From
		    Contract_Valid_To__c = validTo,                        // Contract Valid To
		    Index__c = im,                                             // Index
		    Pricing_Terms__c = pricingTerm,                              // Pricing Terms
		    Enquiry_vs_Delivery_Date__c = deliveryType,                                  // Enquiry vs Delivery Date
		    Uplift__c = uplift,                                                      // Uplift
		    Uplift_Currency__c = upliftC,                                               // Uplift Currency
		    Product__c = product,                                            // Product
		    Active__c = true
		                // Active
		);
		insert sobj;
		return sobj;
	}

	/**
	 * Creates a pt.
	 *
	 * @param      uplift           The uplift
	 * @param      im               { parameter_description }
	 * @param      upliftCurrentcy  The uplift currentcy
	 * @param      validTo          The valid to
	 * @param      validfrom        The validfrom
	 */
	public static Pricing_Table__c createPT(Decimal uplift,
	                                        String im,
	                                        String upliftCurrentcy,
	                                        String validTo,
	                                        String validfrom) {
		Pricing_Table__c sobj = new Pricing_Table__c(
		    Re_Calculate_Uplift_Value__c = false,      // Re Calculate Uplift Value?
		    Valid_From__c = Date.valueOf(validfrom),  // Valid From
		    Uplift__c = uplift,                         // Uplift
		    Valid_To__c = Date.valueOf(validTo),    // Valid To
		    Uplift_Currency__c = upliftCurrentcy,                  // Uplift Currency
		    Index_Mapping__c = im        // Index Mapping
		);
		insert sobj;
		return sobj;
	}
	/**
	 * Creates a mdp.
	 *
	 * @param      uplift           The uplift
	 * @param      im               { parameter_description }
	 * @param      upliftCurrentcy  The uplift currentcy
	 * @param      validTo          The valid to
	 * @param      validfrom        The validfrom
	 */
	public static Master_Daily_Price__c createMDP(String idate) {
		Master_Daily_Price__c sobj = new Master_Daily_Price__c(
		    Manually_Created__c = true,                          // Manually Created
		    Reconsile__c = false,                                  // Reconsile?
		    Excluded__c = false,                                   // Excluded
		    Date__c = Date.valueOf(idate),              // Date
		    FX_Rate_GBP_USD__c = 1.3067,                         // FX Rate GBP / USD
		    CIF_AAYWS00__c = 535.50,                             // $ CIF AAYWS00
		    CIF_Diesel_10ppm_NWEARA_AAVBH00__c = 548.75,         // $ CIF Diesel 10ppm NWE/ARA AAVBH00
		    FX_Rate_USD_EUR__c = 1.1657,                         // FX Rate USD / EUR
		    CIF_Jet_NWEARA_PJAAU00__c = 586.00,                  // $ CIF Jet NWE/ARA PJAAU00
		    FOB_AAYWR00__c = 1000.00,                         // $ FOB AAYWR00
		    FX_Rate_GBP_EUR__c = 1.1210,                         // FX Rate GBP / EUR
		    FOB_Barges_FAME_10_RED_AAWGH00_CBM__c = 1010.75,   // $ FOB Barges FAME -10 (RED) AAWGH00 CBM
		    FOB_Rotterdam_Barges_AAXWT00__c = 536.50,            // $ FOB Rotterdam Barges AAXWT00
		    Gasoline_CIF_cargoes_10ppm_AAXFQ00__c = 631.00,      // $ Gasoline CIF cargoes 10ppm AAXFQ00
		    FOB_Barges_Ethanol_T2_Rtdm_AAYDT00_CBM__c = 532.14,  // € FOB Barges Ethanol T2 Rtdm AAYDT00 CBM
		    ICE_AAQSG00__c = 544.50,                             // $ ICE AAQSG00
		    P66_Daily_Uplift__c = 13.78                         // £ P66 Daily Uplift
		);
		insert sobj;		return sobj;
	}


	/**
	 * Creates an user.
	 *
	 * @param      username  The username
	 * @param      alias     The alias
	 * @param      profile   The profile
	 *
	 * @return     { description_of_the_return_value }
	 */
	public static User createUser(String username, String alias, String profile) {
		Profile p = [SELECT Id FROM Profile WHERE Name = :profile];
		User u = new User(Alias = alias, Email = 'testuser@test.com.sample',
		                  EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                  LocaleSidKey = 'en_AU', ProfileId = p.Id,
		                  TimeZoneSidKey = 'Australia/Sydney', UserName = username);
		return u;
	}
	public static Vessel__c createVessel(String imo, String nameV) {
		Vessel__c sobj = new Vessel__c(
		    Name = nameV,                   // Vessel Name
		    IMO_Number__c = imo         // IMO Number
		);
		insert sobj;
		return sobj;
	}

	//Get random string to use as name or email, needed to prevent duplicate errors
	public static String getRandomString() {
		Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
		String uniqueName = randomInt.format().replace(',', '');
		return uniqueName;
	}

	public static Opportunity insertOppty() {
		Opportunity oppty = new Opportunity(
		    StageName = 'Enquiry',                                // Stage
		    Name = 'Oppty1',                                // Stage
		    AccountId = GlobalUtil.getSObjectRecords('Account', 'Name', 'Client1', null)[0].Id,
		    Transport_Response_Time__c = '0-20 minutes',          // Transport Response Time
		    CloseDate = Date.valueOf('2018-11-12'),               // Enquiry Date
		    Probability = 10,                                     // Probability (%)
		    Hedged__c = false,                                    // Hedged?
		    Masters_or_Owners__c = 'Masters or Owners',           // Masters or Owners
		    Invoiced__c = false,                                  // Invoiced?
		    In_Sage__c = false,                                   // In Sage?
		    Invoice_Or_Credit__c = 'Invoice',                     // Invoice Or Credit
		    Pricing_Mechanism__c = 'Contract Daily',              // Pricing Mechanism
		    Delivery_Terminal__c = GlobalUtil.getSObjectRecords('Account', 'Name', 'Terminal1', null)[0].Id,            // Delivery Terminal
		    Actual_Quantity_Delivered_MT__c = 20.0000,         // Actual Quantity Delivered (MT)
		    Actual_Quantity_Delivered_Litres_15__c = 230.0000,  // Actual Quantity Delivered (Litres @ 15)
		    Actual_Density__c = 33.0000,
		    Delivery_Date__c = Date.valueOf('2018-12-12'),        // Delivery Date
		    Delivery_Method__c = 'Ex Pipe'                       // Delivery Method
		);
		insert oppty;
		return oppty;
	}
	public static Quote_Line__c insertQuoteLine(String sProduct) {
		Quote_Line__c sobj = new Quote_Line__c(
		    Enquiry__c = insertOppty().id,                                                            // Enquiry
		    Cost_Type__c = 'Product',                                                                    // Cost Type
		    VAT__c = 0.00,                                                                               // VAT %
		    Product_or_Service__c = sProduct,                                                    // Product or Service
		    Unit_of_Measure_Order_Quantity__c = 'Metric Tonnes',                                         // Unit of Measure (Order Quantity)
		    Unit_of_Measure__c = 'Metric Tonnes',                                                        // Unit of Measure
		    Metric_Tonnes__c = 20.0000,                                                                // Metric Tonnes
		    Litres_15_Deg__c = 230.000,                                                                // Litres @ 15 Deg
		    Items__c = 1,                                                                              // Items
		    Density__c = 33.0000,                                                                      // Density
		    Currency__c = 'GBP'                                                                         // Currency
		);
		insert sobj;
		return sobj;
	}

	public static void createTestData() {
		Index_Mapping__c indexMapPT = Testutil.createIM('P66_Daily_Uplift__c', 'GBP', 'Master_Daily_Price__c');
		Account client =  Testutil.createAccount('Client1', 'Customer');
		insert client;
		Account terminal =  Testutil.createAccount('Terminal1', 'Delivery Terminal');
		insert terminal;
		Pricing_Table__c pt = Testutil.createPT(10.0, (String)indexMapPT.Id, 'GBP', '2018-12-31', '2017-10-10');
		Pricing_Contract__c pc = Testutil.createPC(GlobalUtil.getSObjectRecords('Account', 'Name', 'Client1', null)[0].Id,
		                         GlobalUtil.getSObjectRecords('Account', 'Name', 'Terminal1', null)[0].Id,
		                         GlobalUtil.getSObjectRecords('Index_Mapping__c', null, null, 'name!=null')[0].Id,
		                         Date.valueOf('2018-11-12'),
		                         'CoB',
		                         'Enquiry',
		                         12.0,
		                         'GBP',
		                         'Biodiesel FAME -10 (RED)',
		                         'gp@gmail.com');
		update pc;
		Pricing_Contract__c pt2 = Testutil.createPC(GlobalUtil.getSObjectRecords('Account', 'Name', 'Client1', null)[0].Id,
		                          GlobalUtil.getSObjectRecords('Account', 'Name', 'Terminal1', null)[0].Id,
		                          GlobalUtil.getSObjectRecords('Index_Mapping__c', null, null, 'name!=null')[0].Id,
		                          Date.valueOf('2018-11-12'),
		                          'Normal Monthly Average',
		                          'Enquiry',
		                          12.0,
		                          'GBP',
		                          'Marine Gas Oil 0.1% (max) Sulphur BS2869:2010',
		                          'gp@gmail.com');
		Pricing_Contract__c pt3 = Testutil.createPC(GlobalUtil.getSObjectRecords('Account', 'Name', 'Client1', null)[0].Id,
		                          GlobalUtil.getSObjectRecords('Account', 'Name', 'Terminal1', null)[0].Id,
		                          GlobalUtil.getSObjectRecords('Index_Mapping__c', null, null, 'name!=null')[0].Id,
		                          Date.valueOf('2018-11-12'),
		                          'Latest Monthly Average',
		                          'Enquiry',
		                          12.0,
		                          'EUR',
		                          'Diesel 10 ppm',
		                          'gp@gmail.com');
		Pricing_Contract__c pt4 = Testutil.createPC(GlobalUtil.getSObjectRecords('Account', 'Name', 'Client1', null)[0].Id,
		                          GlobalUtil.getSObjectRecords('Account', 'Name', 'Terminal1', null)[0].Id,
		                          GlobalUtil.getSObjectRecords('Index_Mapping__c', null, null, 'name!=null')[0].Id,
		                          Date.valueOf('2018-11-12'),
		                          'D-1',
		                          'Enquiry',
		                          12.0,
		                          'EUR',
		                          'Ethanol',
		                          'gp@gmail.com');
		Pricing_Contract__c pt5 = Testutil.createPC(GlobalUtil.getSObjectRecords('Account', 'Name', 'Client1', null)[0].Id,
		                          GlobalUtil.getSObjectRecords('Account', 'Name', 'Terminal1', null)[0].Id,
		                          GlobalUtil.getSObjectRecords('Index_Mapping__c', null, null, 'name!=null')[0].Id,
		                          Date.valueOf('2018-11-12'),
		                          'Weekly Lag',
		                          'Enquiry',
		                          12.0,
		                          'EUR',
		                          'Ethanol',
		                          'gp@gmail.com');
		Pricing_Contract__c pt6 = Testutil.createPC(GlobalUtil.getSObjectRecords('Account', 'Name', 'Client1', null)[0].Id,
		                          GlobalUtil.getSObjectRecords('Account', 'Name', 'Terminal1', null)[0].Id,
		                          GlobalUtil.getSObjectRecords('Index_Mapping__c', null, null, 'name!=null')[0].Id,
		                          Date.valueOf('2018-11-12'),
		                          'Weekly Lag',
		                          'Delivery',
		                          12.0,
		                          'EUR',
		                          'Gasoline 10ppm',
		                          'gp@gmail.com');
		Master_Daily_Price__c mdp = Testutil.createMDP('2018-11-11');
	}
}