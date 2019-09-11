/**
 * @ClassName : QuoteBDRControllerTest
 * @Purpose   : To Test QuoteBDRController class.
 * @Date      : 15th Nov, 2017
 */
@isTest
public class QuoteBDRControllerTest {
    /**
     * @MethodName : createData
     * @Purpose    : To create data for testing.
     * @Parameters : -
     * @Return     : -
     * @Date       : 15th Nov, 2017
     */
    @testSetup
    static void createData(){
        Opportunity opportunity = new Opportunity(Name = 'test Opportunity', 
                                                  CloseDate = System.today().addYears(1), 
                                                  StageName = 'Prospecting');
        insert opportunity;
        
        List<Quote_Line__c> quoteLineList = new List<Quote_Line__c>();
        for(Integer count = 0; count < 25; count++){
            quoteLineList.add(new Quote_Line__c(Enquiry__c = opportunity.Id));
        }
        
        for(Integer count = 0; count < 25; count++){
            quoteLineList.add(new Quote_Line__c(Enquiry__c = opportunity.Id, 
                                                Natural_Litres__c = 10,
                                                Cost_Type__c = 'Duty',
                                                Product_or_Service__c = 'Duty', 
                                                Litres_15_Deg__c = 10, 
                                                Density__c = 15, 
                                                Metric_Tonnes__c = 20));
        }
        
        insert quoteLineList;
    }
    
    /**
     * @MethodName : testFunc
     * @Purpose    : To test QuoteBDRController constructor.
     * @Parameters : -
     * @Return     : -
     * @Date       : 15th Nov, 2017
     */
    static testmethod void testFunc(){
        
        Opportunity opportunity = [SELECT Id 
                                   FROM Opportunity];
        
        ApexPages.StandardController standardController =  new ApexPages.StandardController(opportunity);
        
        Test.startTest();
        QuoteBDRController quoteBDRController = new QuoteBDRController(standardController);
        Test.stopTest();
    }
}