/**
 * @ClassName : QuoteBDRController
 * @Purpose   : To show Enquiry and QuoteLineItems on VF page.
 * @Date      : 15th Nov, 2017
 */
public class QuoteBDRController {
    public Opportunity opportunity{get;set;}
    //public List<Quote_Line__c> quoteLineList{get;set;}
    public String geosGroupLogoUrl{get;set;}
    public String seaBunkeringLogoUrl{get;set;}
    public OpportunityWrapper oppWrapper{get;set;}
    public List<QuoteLineWrapper> quoteLineWrapperList{get;set;}
    
    /**
     * @MethodName : Constructor
     * @Purpose    : To fetch Opportunity Record.
     * @Parameters : OpportunityStandardController
     * @Return     : -
     * @Date       : 15th Nov, 2017
     */
    public QuoteBDRController(ApexPages.StandardController stdController){
        opportunity = (Opportunity)stdController.getRecord();
        
        opportunity = [SELECT Id, 
                       Name, 
                       Vessel__r.Name, 
                       Vessel__r.IMO_Number__c, 
                       Port__c, 
                       Delivery_Terminal__r.Name 
                       FROM Opportunity 
                       WHERE Id = :opportunity.Id];
        oppWrapper = new OpportunityWrapper(opportunity);
            
        quoteLineWrapperList = new List<QuoteLineWrapper>();
        for(Quote_Line__c quote: [SELECT Id,
                                  Density__c,
                                  Metric_Tonnes__c,
                                  Name,
                                  Natural_Litres__c,
                                  Product_or_Service__c,
                                  Litres_15_Deg__c,
                                  Actual_Density__c, Actual_Quantity_Delivered_Litres_15__c, 
                                  Actual_Quantity_Delivered_MT__c, Actual_Natural_Litres_Delivered__c
                                  FROM Quote_Line__c 
                                  WHERE Enquiry__c = :opportunity.Id 
                                  AND Product_or_Service__c ='Marine Gas Oil 0.1% (max) Sulphur BS2869:2010' 
                                  ORDER BY CreatedDate DESC LIMIT 1]){
                                      quoteLineWrapperList.add(new QuoteLineWrapper(quote, false));
                                  }
        
        if(quoteLineWrapperList.isEmpty()){
            quoteLineWrapperList.add(new QuoteLineWrapper(new Quote_Line__c(Enquiry__c = opportunity.Id, 
                                                                            Cost_Type__c = 'Product',
                                                                            Currency__c = 'GBP',
                                                                            Product_or_Service__c = 'Marine Gas Oil 0.1% (max) Sulphur BS2869:2017'), true));
        }
            
            String geosGroupLogoId = Label.GeosGroupLogoID;
            try{
                geosGroupLogoId = Id.valueOf( geosGroupLogoId );
                geosGroupLogoUrl = URL.getSalesforceBaseUrl().toExternalForm() 
                    + '/servlet/servlet.ImageServer?id=' 
                    + geosGroupLogoId 
                    + '&oid=' 
                    + UserInfo.getOrganizationId();
            }catch( Exception e ){
                geosGroupLogoUrl = '';
                System.debug('Exception Occured '+e.getMessage() );
            }
            
            String seaBunkeringLogoID = Label.SeaBunkeringLogoID;
            try{
                seaBunkeringLogoID = Id.valueOf( seaBunkeringLogoID );
                seaBunkeringLogoUrl = URL.getSalesforceBaseUrl().toExternalForm() 
                    + '/servlet/servlet.ImageServer?id=' 
                    + seaBunkeringLogoID 
                    + '&oid=' 
                    + UserInfo.getOrganizationId();
            }catch( Exception e ){
                seaBunkeringLogoUrl = '';
                System.debug('Exception Occured '+e.getMessage() );
            }
        }
    
    public class OpportunityWrapper{
        public String VesselName{get;set;}
        public String IMONumber{get;set;}
        public String Port{get;set;}
        public String Name{get;set;}
        public String DeliveryTerminalName{get;set;}
        
        //empty constructor
        public OpportunityWrapper(){}
        
        /**
         * @MethodName : Constructor for OpportunityWrapper class
         * @Purpose    : To check null values and handle them appropriately.
         * @Parameters : Current opportunity
         * @Return     : -
         * @Date       : 15th Nov, 2017
         */
        public OpportunityWrapper(Opportunity opportunity){
            if(opportunity.Vessel__r != null){
                this.VesselName = opportunity.Vessel__r.Name;
            }else{                
                this.VesselName = '';
            }
            
            if(opportunity.Vessel__r != null && opportunity.Vessel__r.IMO_Number__c != null){
                this.IMONumber = opportunity.Vessel__r.IMO_Number__c;
            }else{                
                this.IMONumber = '';
            }
            
            if(opportunity.Port__c != null){
                this.Port = opportunity.Port__c;
            }else{
                this.Port = '';
            }
            
            this.Name = opportunity.Name;
            this.DeliveryTerminalName = opportunity.Delivery_Terminal__r.Name;
        }
    }
    
    public class QuoteLineWrapper{
        
        public Decimal NaturalLitres{get;set;}
        public String ProductOrService{get;set;}
        public Decimal Litres_15Degrees{get;set;}
        public Decimal Density{get;set;}
        public Decimal MetricTonnes{get;set;}
        public Boolean NewRecord{get;set;}
        
        //empty constructor
        public QuoteLineWrapper(){}
        
        /**
         * @MethodName : Constructor for QuoteLineWrapper class.
         * @Purpose    : To check null values and handle them appropriately.
         * @Parameters : QuoteLine record
         * @Return     : -
         * @Date       : 15th Nov, 2017
         */
        public QuoteLineWrapper(Quote_Line__c quoteLine, Boolean newRecord){
 
            if(quoteLine.Actual_Natural_Litres_Delivered__c != null){
                this.NaturalLitres = quoteLine.Actual_Natural_Litres_Delivered__c;
            }else{
                this.NaturalLitres = 0;
            }
            
            if(quoteLine.Product_or_Service__c != null){
                this.ProductOrService = quoteLine.Product_or_Service__c;
            }else{
                this.ProductOrService = '';
            }
            
            if(quoteLine.Actual_Quantity_Delivered_Litres_15__c != null){
                this.Litres_15Degrees = quoteLine.Actual_Quantity_Delivered_Litres_15__c;
            }else{
                this.Litres_15Degrees = 0;
            }
            
            if(quoteLine.Actual_Density__c != null){
                this.Density = quoteLine.Actual_Density__c;
            }else{
                this.Density = 0;
            }
            
            if(quoteLine.Actual_Quantity_Delivered_MT__c != null){
                this.MetricTonnes = quoteLine.Actual_Quantity_Delivered_MT__c;
            }else{
                this.MetricTonnes = 0;
            }
            
            this.NewRecord = newRecord;
        }
    }
}