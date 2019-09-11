/**
@Purpose:- Controls Visualforce Template --> Offer Email
*/
public class OfferEmailCmpController{
    
    public String enquiryId{get; set;}
    
    public List<QuoteLineWrapper> getlistOfQuoteLines(){
        
        System.debug('enquiryId!!!!!!!!!!' +enquiryId);       
        List<QuoteLineWrapper> listOfQuoteLines = new List<QuoteLineWrapper>();
        
        if( String.isNotBlank( enquiryId ) ){
            
            try{
                for( Quote_Line__c recordQuoteLine : [SELECT Id, 
                                                          Unit_of_Measure_Order_Quantity__c, 
                                                          Unit_of_Measure__c, 
                                                          Quantity_for_email_template__c, 
                                                          Product_or_Service__c, 
                                                          Price_To_Customer_Local_Currency__c, 
                                                          Currency__c, 
                                                          Enquiry__c, 
                                                          VAT__c, 
                                                          Quantity_using_second_unit_of_measure__c 
                                                      FROM Quote_Line__c 
                                                      WHERE Enquiry__c =:enquiryId 
                                                     ] ){
                                                         QuoteLineWrapper instanceQuoteLineWrapper = new QuoteLineWrapper( recordQuoteLine );
                                                         listOfQuoteLines.add( instanceQuoteLineWrapper );
                                                     }
            }
            catch( Exception e ){
                System.debug( 'Exception Occured while fetching Quote Lines'+e );
            }           
        }
        return listOfQuoteLines;
    } 
    public OpportunityWrapper getEnquiryRecord(){
        
        Opportunity recordOpportunity;
        Organization recordOrganization;
        OpportunityWrapper instanceOpportunityWrapper = new OpportunityWrapper();
        
        if( String.isNotBlank( enquiryId ) ){
            
            try{
                recordOpportunity = [SELECT Vessel__c, 
                                         Port__c, 
                                         Masters_or_Owners__c,
                                         Delivery_Date__c, 
                                         Delivery_Method__c,
                                         Ship_Agent__c, 
                                         Order_Notes__c,
                                         Vessel__r.Name,
                                         Ship_Agent__r.Name,
                                         Account.Name,
                                         Geos_Ref__c,
                                         Account.BillingStreet, 
                                         Account.BillingCity, 
                                         Account.BillingState, 
                                         Account.BillingPostalCode, 
                                         Account.BillingCountry,
                                         Account.Invoice_Address__c,
                                         Customer_PO_Number__c
                                     FROM Opportunity 
                                     WHERE ID =: enquiryId 
                                     LIMIT 1
                                    ];
            }catch( Exception e ){
                System.debug('Exception occured while fetching Opportunity'+e.getMessage());
            }  
            
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
        }
        if( recordOpportunity != NULL && recordOrganization != NULL ){
            instanceOpportunityWrapper = new OpportunityWrapper( recordOpportunity, recordOrganization );
        }
        return instanceOpportunityWrapper;
    }
    
    public class OpportunityWrapper{
        
        public String geosGroupLogoUrl{get;set;}
        public String seaBunkeringLogoUrl{get;set;}
        public String strTo{get;set;}
        public String strReference{get;set;}
        public String strCustomerAddress{get;set;}
        public String strVessel{get;set;}
        public String strPort{get;set;}
        public Date deliveryDate{get;set;}
        public String strDeliveryMethod{get;set;}
        public String strAgent{get;set;}
        public String strNotes{get;set;}
        public String strCustomerPONumber{get;set;}
        public String strMastersOrOwners{get;set;}
        
        public OpportunityWrapper(){}
        
        public OpportunityWrapper(  Opportunity recordOpportunity, Organization recordOrganization ){
            
            String geosGroupLogoId = Label.GeosGroupLogoID;
            try{
                geosGroupLogoId = Id.valueOf( geosGroupLogoId );
                geosGroupLogoUrl = URL.getSalesforceBaseUrl().toExternalForm()+
                    '/servlet/servlet.ImageServer?id='+
                    geosGroupLogoId+
                    '&oid='+
                    UserInfo.getOrganizationId();
            }catch( Exception e ){
                geosGroupLogoUrl = '';
                System.debug('Exception Occured '+e.getMessage() );
            }
            
            String seaBunkeringLogoID = Label.SeaBunkeringLogoID;
            try{
                seaBunkeringLogoID = Id.valueOf( seaBunkeringLogoID );
                seaBunkeringLogoUrl = URL.getSalesforceBaseUrl().toExternalForm()+
                    '/servlet/servlet.ImageServer?id='+
                    seaBunkeringLogoID+'&oid='+
                    UserInfo.getOrganizationId();
            }catch( Exception e ){
                seaBunkeringLogoUrl = '';
                System.debug('Exception Occured '+e.getMessage() );
            }
            
            strTo = recordOpportunity.Account.Name; //not decided
            
            if(recordOpportunity.Account != null && recordOpportunity.Account.Invoice_Address__c != null){
                strCustomerAddress = recordOpportunity.Account.Invoice_Address__c;
                strCustomerAddress = strCustomerAddress.replaceAll('[,]', ',<br/>');
            } else {
                strCustomerAddress = '';
            }
            
            strMastersOrOwners = recordOpportunity.Masters_or_Owners__c;
            if( strMastersOrOwners != NULL && strMastersOrOwners.equals( 'Blank' ) ){
                strMastersOrOwners = '';
            }
            
            strReference = recordOpportunity.Geos_Ref__c;
            strVessel = recordOpportunity.Vessel__r.Name;
            strPort = recordOpportunity.Port__c;
            deliveryDate = recordOpportunity.Delivery_Date__c;
            strDeliveryMethod = recordOpportunity.Delivery_Method__c;
            strAgent = recordOpportunity.Ship_Agent__r.Name;
            strNotes = recordOpportunity.Order_Notes__c;
            strCustomerPONumber = recordOpportunity.Customer_PO_Number__c;
        }        
    }
    
    public class QuoteLineWrapper{
        
        public Decimal qty{get;set;}
        public String strUnitOfMeasureForQty{get;set;}
        public String strProductOrService{get;set;}
        public Decimal price{get;set;}
        public String strCurrency{get;set;}
        public String strUnitOfMeasure{get;set;}
        public Decimal totalWithoutVat{get;set;}
        public Decimal vatAmount{get;set;}
        public Decimal totalAmount{get;set;}
        public Decimal qty_second{get;set;}
        
        public QuoteLineWrapper(){}
        
        public QuoteLineWrapper(  Quote_Line__c recordQuoteLine ){
            
            qty = recordQuoteLine.Quantity_for_email_template__c;
            if( qty == NULL ){
                qty = 0.00;
            }
            qty = qty.setScale( 4 );
            
            qty_second = recordQuoteLine.Quantity_using_second_unit_of_measure__c;
            if( qty_second == NULL ){
                qty_second = 0.00;
            }
            qty_second = qty_second.setScale( 4 );
            
            strUnitOfMeasureForQty = recordQuoteLine.Unit_of_Measure_Order_Quantity__c;
            strProductOrService = recordQuoteLine.Product_or_Service__c;
            price = recordQuoteLine.Price_To_Customer_Local_Currency__c;
            if( price == NULL ){
                price = 0.00;
            }
            price = price.setScale( 4 );
            
            strCurrency = recordQuoteLine.Currency__c;
            
            strUnitOfMeasure = recordQuoteLine.Unit_of_Measure__c;
            
            totalWithoutVat = qty_second * price;
            totalWithoutVat = totalWithoutVat.setScale(2);
            
            if(totalWithoutVat > 0 && recordQuoteLine.VAT__c != null && recordQuoteLine.VAT__c > 0){
                vatAmount = totalWithoutVat * recordQuoteLine.VAT__c / 100;
                vatAmount = vatAmount.setScale(2);
            } else {
                vatAmount = 0.00;
            }
            
            totalAmount = totalWithoutVat + vatAmount;
            totalAmount = totalAmount.setScale(2);
        }        
    }
}