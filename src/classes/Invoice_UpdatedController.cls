/**
@Purpose: Controls Page--> Invoice_Updated
*/
public class Invoice_UpdatedController{
    
    public static Decimal totalCurrencyISO {get;set;}
    public static Decimal totalVatAmount {get;set;}
    public static Decimal totalToCustomer{get;set;}
    public String strCurrency{get;set;}
    public String enquiryId{get;set;}

    public OpportunityWrapper getinstanceOpportunityWrapper( ){
        
        OpportunityWrapper instanceOpportunityWrapper = new OpportunityWrapper();
        
        if( String.isNotBlank( enquiryId ) ){
            
            Opportunity recordOpportunity;
            try{
                recordOpportunity = [SELECT Id, 
                                         Masters_or_Owners__c, 
                                         Vessel__c, 
                                         Port__c, 
                                         Geos_Ref__c,
                                         Delivery_Date__c, 
                                         Customer_PO_Number__c,
                                         AccountId, 
                                         Account.Name,
                                         Vessel__r.Name,
                                         Account.VAT_Number__c,
                                         Account.BillingStreet, 
                                         Account.BillingCity, 
                                         Account.BillingState, 
                                         Account.BillingPostalCode,
                                         Account.BillingCountry,
                                         Account.Invoice_Address__c,
                                         Settlement_Date__c,
                                         Invoice_Or_Credit__c
                                     FROM Opportunity
                                     WHERE Id =: enquiryId
                                    ];
            }catch( Exception e ){
                System.debug('Exception Occured while fetching Opportunity'+e.getMessage());                
            }
            Organization recordOrganization;
            try{
                recordOrganization = [SELECT Id, 
                                          Name, 
                                          Street, 
                                          City, 
                                          State, 
                                          PostalCode, 
                                          Country, 
                                          Phone
                                      FROM Organization 
                                      LIMIT 1 
                                     ];
            }
            catch( Exception e ){
                System.debug( 'Exception Occured while fetching Organization Record'+e );
            }
            if( recordOpportunity != NULL && recordOrganization != NULL ){
                instanceOpportunityWrapper = new OpportunityWrapper( recordOpportunity, recordOrganization );
            }
        } 
        return instanceOpportunityWrapper;
    }
    
    public List<QuoteLineWrapper> getlistOfQuoteLineItems( ){
        
        List<QuoteLineWrapper> listOfQuoteLineItems = new List<QuoteLineWrapper>();
        
        totalCurrencyISO = 0.00;
        totalVatAmount = 0.00;
        totalToCustomer = 0.00;
        
        Set<String> currencySet = new Set<String>();
        
        if( String.isNotBlank( enquiryId ) ){
            try{
                for( Quote_Line__c recordQuoteLine : [SELECT Product_or_Service__c, 
                                                          Quantity_for_email_template__c,
                                                          Unit_of_Measure__c, 
                                                          Density__c,
                                                          Price_To_Customer_Local_Currency__c,
                                                          Total_Price_to_Customer_Local_Currency__c, 
                                                          Currency__c, 
                                                          VAT__c, 
                                                          Quantity_using_second_unit_of_measure__c
                                                      FROM Quote_Line__c 
                                                      WHERE Enquiry__c =: enquiryId ] ){
                                                          
                                                          QuoteLineWrapper instanceQuoteLineWrapper = new QuoteLineWrapper( recordQuoteLine );
                                                          listOfQuoteLineItems.add( instanceQuoteLineWrapper );
                                                          totalToCustomer = totalCurrencyISO + totalVatAmount;
                                                          totalToCustomer = totalToCustomer.setScale(2);
                                                          currencySet.add(recordQuoteLine.Currency__c);
                                                          
                                                          this.strCurrency = String.join(new List<String>(currencySet), '/');
                                                      }
            }
            catch( Exception e ){
                System.debug( 'Exception Occured while fetching Quote Lines'+e );
            }
        }
        return listOfQuoteLineItems;
    }
    
    public class QuoteLineWrapper{
        public String strProductOrService{get;set;}
        public Decimal qty{get;set;}
        public String strUnitOfMeasure{get;set;}
        public Decimal density{get;set;}
        public Decimal pricePerUOM{get;set;}
        public Decimal total{get;set;}
        public String decCurrency{get;set;}
        public Decimal vat{get;set;}
        public Decimal vatAmount{get;set;}
        public Decimal totalAfterVat{get;set;}
        public Decimal qty_second{get; set;}
        
        
        public QuoteLineWrapper( Quote_Line__c recordQuoteLine ){
            
            strProductOrService = recordQuoteLine.Product_or_Service__c;
            
            qty = recordQuoteLine.Quantity_for_email_template__c;
            if( qty == NULL ){
                qty = 0.00;
            }
            qty = qty.setScale( 3 );
            
            qty_second = recordQuoteLine.Quantity_using_second_unit_of_measure__c;
            if( qty_second == NULL ){
                qty_second = 0.00;
            }
            qty_second = qty_second.setScale( 3 );
            
            strUnitOfMeasure = recordQuoteLine.Unit_of_Measure__c;
            
            density = recordQuoteLine.Density__c;
            if( density == NULL ){
                density = 0.00;
            }
            density = density.setScale( 4 );
            
            pricePerUOM = recordQuoteLine.Price_To_Customer_Local_Currency__c;
            if( pricePerUOM == NULL ){
                pricePerUOM = 0.00;
            }
            pricePerUOM = pricePerUOM.setScale( 4 );
            
            total = qty_second * pricePerUOM;
            
            if( total == NULL ){
                total = 0.00;
            }
            total = total.setScale( 2 );
            
            totalCurrencyISO = totalCurrencyISO + total;
            totalCurrencyISO = totalCurrencyISO.setScale( 4 );
            
            decCurrency = recordQuoteLine.Currency__c;          
            
            vat = recordQuoteLine.VAT__c;
            if( vat == NULL ){
                vat = 0.00;
            }
            vat = vat.setScale( 4 );
            
            if( vat > 0 && total > 0 ){
                vatAmount = ( total * vat )/100;
            }else{
                vatAmount = 0.00;
            }
            vatAmount = vatAmount.setScale( 2 );
            
            totalVatAmount = totalVatAmount + vatAmount;
            totalVatAmount = totalVatAmount.setScale( 2 );
            
            totalAfterVat = total + vatAmount;
            totalAfterVat = totalAfterVat.setScale( 2 );
        }
    }
    
    //Wrapper Class to store Opportunity Record
    public class OpportunityWrapper{
        public String geosGroupLogoUrl{get;set;}
        public String seaBunkeringLogoUrl{get;set;}
        public String strMastersOrOwners{get;set;}
        public String strTo{get;set;}
        public String strAddress{get;set;}
        public String strVesselName{get;set;}
        public String strGeosRef{get;set;}
        public String strPort{get;set;}
        public Date invoiceDate{get;set;}
        public String strOurVatNo{get;set;}
        public String strYourVatNo{get;set;}
        public Date deliveryDate{get;set;}
        public String strCustomerPONumber{get;set;}
        public String strToAddress{get;set;}
        public Date settlementDate{get;set;}
        public String strinvoiceorcredit{get;set;}
        
        public OpportunityWrapper(){}
        
        public OpportunityWrapper( Opportunity recordOpportunity, Organization recordOrganization ){
            
            String geosGroupLogoId = Label.GeosGroupLogoID;
            try{
                geosGroupLogoId = Id.valueOf( geosGroupLogoId );
                geosGroupLogoUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.ImageServer?id='+geosGroupLogoId+'&oid='+UserInfo.getOrganizationId();
            }catch( Exception e ){
                geosGroupLogoUrl = '';
                System.debug('Exception Occured '+e.getMessage() );
            }
            
            String seaBunkeringLogoID = Label.SeaBunkeringLogoID;
            try{
                seaBunkeringLogoID = Id.valueOf( seaBunkeringLogoID );
                seaBunkeringLogoUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.ImageServer?id='+seaBunkeringLogoID+'&oid='+UserInfo.getOrganizationId();
            }catch( Exception e ){
                seaBunkeringLogoUrl = '';
                System.debug('Exception Occured '+e.getMessage() );
            }
            
            strMastersOrOwners = recordOpportunity.Masters_or_Owners__c;
            if( strMastersOrOwners != NULL && strMastersOrOwners.equals( 'Blank' ) ){
                strMastersOrOwners = '';
            }
            strTo = recordOpportunity.Account.Name;
            
            strAddress = '';
            strAddress = strAddress + (recordOrganization.Street != null? (recordOrganization.Street + '<br />') : '');
            strAddress = strAddress + (recordOrganization.City != null? (recordOrganization.City + '<br />') : '');
            strAddress = strAddress + (recordOrganization.State != null? (recordOrganization.State + '<br />') : '');
            strAddress = strAddress + (recordOrganization.PostalCode != null? (recordOrganization.PostalCode + '<br />') : '');
            strAddress = strAddress + (recordOrganization.Country != null? (recordOrganization.Country + '<br />') : '');
            
            strVesselName = recordOpportunity.Vessel__r.Name;
            strGeosRef = recordOpportunity.Geos_Ref__c;
            strPort = recordOpportunity.Port__c;
            invoiceDate = System.today();
            strOurVatNo = 'GB 552 0669 47';
            strYourVatNo= recordOpportunity.Account.VAT_Number__c;
            deliveryDate = recordOpportunity.Delivery_Date__c;
            strCustomerPONumber = recordOpportunity.Customer_PO_Number__c;
            strinvoiceorcredit = recordOpportunity.Invoice_Or_Credit__c;
            
            if(recordOpportunity.Account != null && recordOpportunity.Account.Invoice_Address__c != null){
                strToAddress = recordOpportunity.Account.Invoice_Address__c;
                strToAddress = strToAddress.replaceAll('[,]', ',<br/>');           
            } else {
                strToAddress = '';
            }
            
            if(recordOpportunity.Settlement_Date__c != null){
                settlementDate = recordOpportunity.Settlement_Date__c;
            }
        }
    } 
}