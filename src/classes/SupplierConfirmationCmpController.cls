/**
@Purpose:- Controls Visualforce Template --> Supplier Confirmation
*/
public class SupplierConfirmationCmpController{
    
    public String supplyCostLineId{get; set;}
    
    public SupplyCostLineWrapper getSupplyCostLineRecord(){
        
        System.debug('supplyCostLineId!!!!!!!!!!' +supplyCostLineId);
        SupplyCost_Line__c recordSupplyCostLine;
        Organization recordOrganization;
        SupplyCostLineWrapper instanceSupplyCostLineWrapper = new SupplyCostLineWrapper();
        
        if( String.isNotBlank( supplyCostLineId ) ){
            
            try{
                recordSupplyCostLine = [SELECT  Quantity_for_email_template__c, 
                                            Unit_of_Measure_Order_Quantity__c,
                                            Product_or_Service__c, 
                                            Cost_to_Geos_Local_Currency__c,
                                            Currency__c, 
                                            Unit__c, Enquiry__r.Vessel__c, 
                                            Enquiry__r.Port__c, 
                                            Enquiry__r.Delivery_Date__c, 
                                            Enquiry__r.Delivery_Method__c,
                                            Enquiry__r.Ship_Agent__c, 
                                            Enquiry__r.Order_Notes__c,
                                            Enquiry__r.Vessel__r.Name,
                                            Enquiry__r.Ship_Agent__r.Name,
                                            Enquiry__r.Account.Name, 
                                            Enquiry__r.Geos_Ref__c,
                                            Enquiry__r.Customer_PO_Number__c, 
                                            VAT__c, Enquiry__r.Masters_or_Owners__c, 
                                            Quantity_using_second_unit_of_measure__c,
                                        	Supplier__r.Name
                                        FROM SupplyCost_Line__c 
                                        WHERE ID =:supplyCostLineId 
                                        LIMIT 1
                                       ];
            }catch( Exception e ){
                System.debug('Exception occured while fetching Supply Cost Line'+e.getMessage());
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
        System.debug('recordSupplyCostLine'+recordSupplyCostLine);
        if( recordSupplyCostLine != NULL && recordOrganization != NULL ){
            instanceSupplyCostLineWrapper = new SupplyCostLineWrapper( recordSupplyCostLine, recordOrganization );
        }
        System.debug('instanceSupplyCostLineWrapper'+instanceSupplyCostLineWrapper);
        return instanceSupplyCostLineWrapper; 
    } 
    public class SupplyCostLineWrapper{
        public String geosGroupLogoUrl{get;set;}
        public String seaBunkeringLogoUrl{get;set;}
        public String strTo{get;set;}
        public String strReference{get;set;}
        public String strVessel{get;set;}
        public String strPort{get;set;}
        public Date deliveryDate{get;set;}
        public String strDeliveryMethod{get;set;}
        public String strAgent{get;set;}
        public String strCustomerPONumber{get;set;}
        public String strMastersOrOwners{get;set;}
        
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
        public String strSupplierName{get;set;}
        
        public String strNotes{get;set;}
        
        public SupplyCostLineWrapper(){}
        public SupplyCostLineWrapper( SupplyCost_Line__c recordSupplyCostLine, Organization recordOrganization ){
            
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
                    seaBunkeringLogoID+
                    '&oid='+
                    UserInfo.getOrganizationId();
            }catch( Exception e ){
                seaBunkeringLogoUrl = '';
                System.debug('Exception Occured '+e.getMessage() );
            }
            strTo = recordSupplyCostLine.Enquiry__r.Account.Name; //not decided
            strReference = recordSupplyCostLine.Enquiry__r.Geos_Ref__c;
            strVessel = recordSupplyCostLine.Enquiry__r.Vessel__r.Name;
            strPort = recordSupplyCostLine.Enquiry__r.Port__c;
            deliveryDate = recordSupplyCostLine.Enquiry__r.Delivery_Date__c;
            strDeliveryMethod = recordSupplyCostLine.Enquiry__r.Delivery_Method__c;
            strAgent = recordSupplyCostLine.Enquiry__r.Ship_Agent__r.Name;
            strCustomerPONumber = recordSupplyCostLine.Enquiry__r.Customer_PO_Number__c;
            
            strMastersOrOwners = recordSupplyCostLine.Enquiry__r.Masters_or_Owners__c;
            if(strMastersOrOwners != NULL && strMastersOrOwners.equals( 'Blank' )){
                strMastersOrOwners = '';
            }
            
            qty = recordSupplyCostLine.Quantity_for_email_template__c;
            if( qty == NULL ){
                qty = 0.00;
            }
            qty = qty.setScale(4);
            
            qty_second = recordSupplyCostLine.Quantity_using_second_unit_of_measure__c;
            if( qty_second == NULL ){
                qty_second = 0.00;
            }
            qty_second = qty_second.setScale(4);
            
            strUnitOfMeasureForQty = recordSupplyCostLine.Unit_of_Measure_Order_Quantity__c;
            strProductOrService = recordSupplyCostLine.Product_or_Service__c;
            price = recordSupplyCostLine.Cost_to_Geos_Local_Currency__c;
            if( price == NULL ){
                price = 0.00;
            }
            price = price.setScale(4);
            
            strCurrency = recordSupplyCostLine.Currency__c;
            
            strUnitOfMeasure = recordSupplyCostLine.Unit__c;
            
            strNotes = recordSupplyCostLine.Enquiry__r.Order_Notes__c;
            
            totalWithoutVat = qty_second * price;
            totalWithoutVat = totalWithoutVat.setScale(2);
            
            if(totalWithoutVat > 0 && recordSupplyCostLine.VAT__c != null && recordSupplyCostLine.VAT__c > 0){
                vatAmount = totalWithoutVat * recordSupplyCostLine.VAT__c / 100;
                vatAmount = vatAmount.setScale(2);
            } else {
                vatAmount = 0.00;
            }
            
            totalAmount = totalWithoutVat + vatAmount;
            totalAmount = totalAmount.setScale(2);
            
            if(recordSupplyCostLine.Supplier__c != null && recordSupplyCostLine.Supplier__r.Name != null){
                strSupplierName = recordSupplyCostLine.Supplier__r.Name;
            } else {
                strSupplierName = '';
            }            
        }
    }
}