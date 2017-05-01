@isTest
public class ObjectListComponentControllerTest {
    
    @testSetup
    static void createTestData(){
        Account acc = new Account();
        acc.Name = 'testAccount';
        insert acc;
        
        contact con = new Contact(accountId = acc.id,lastNAme='test Con');
        insert con;
    }
    
    
    static testMethod void unitTest(){
        // Validating Fetched Fields Data From FieldSet.
        Map<String,String> apiToLabels = ObjectListComponentController.getFields('Contact','fieldsToFilter');
        system.assertNotEquals(null, apiToLabels);
        
        ObjectWrapper wrappedObj = ObjectListComponentController.getHeaders('Contact','fieldsToDisplay');
        system.assertNotEquals(wrappedObj.headerLabels,null);
        
        ObjectWrapper wrappedObj1 = ObjectListComponentController.getCases('test','All','ASC','Contact');
        system.assertNotEquals(wrappedObj1.detailValues, null);
        
        ObjectWrapper wrappedObj12 = ObjectListComponentController.getCases('test','Account.Name','DESC','Contact');
        system.assertNotEquals(wrappedObj12.detailValues, null);
        
        ObjectWrapper wrappedObj13 = ObjectListComponentController.getCases('','Name','DESC','Contact');
        system.assertNotEquals(wrappedObj13.detailValues, null);
        
        ObjectWrapper wrappedObj14 = ObjectListComponentController.getCases('Random','Name','DESC','Contact');
        system.assertEquals(wrappedObj14.detailValues.size(), 0);
        
    }
    
    
}