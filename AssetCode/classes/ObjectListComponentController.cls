public class ObjectListComponentController {
	
    @AuraEnabled
    public static Map<String,String> getFields(String ObjectName, String fieldSetName) {
        Map<String,String> apiToLabel = new Map<String,String>();
        Map<String, Schema.SObjectField> refObjFieldMap = Schema.getGlobalDescribe().get(ObjectName).getDescribe().Fields.getMap();
        for(Schema.FieldSetMember fieldSetMemberObj : getFieldValues(ObjectName,fieldSetName)){
            if(fieldSetMemberObj.getType() !=  Schema.DisplayType.Reference){
                apiToLabel.put(fieldSetMemberObj.getFieldPath(),fieldSetMemberObj.getLabel());
            }
            else{
                if(refObjFieldMap.get(fieldSetMemberObj.getFieldPath()).getDescribe().getReferenceTo()[0] == Schema.Case.SObjectType){
                    apiToLabel.put(refObjFieldMap.get(fieldSetMemberObj.getFieldPath()).getDescribe().getRelationshipName() + '.CaseNumber',refObjFieldMap.get(fieldSetMemberObj.getFieldPath()).getDescribe().getRelationshipName()); 

                }
                else{
                    apiToLabel.put(refObjFieldMap.get(fieldSetMemberObj.getFieldPath()).getDescribe().getRelationshipName() + '.Name',refObjFieldMap.get(fieldSetMemberObj.getFieldPath()).getDescribe().getRelationshipName()); 

                }
            }
        }
        return apiToLabel;
    }
    
    @AuraEnabled
    public static ObjectWrapper getHeaders(String ObjectName, String fieldSetName){
        
        ObjectWrapper wrappedObj = new ObjectWrapper();
        List<String> headerLabels = new List<String>();
        for(Schema.FieldSetMember fieldSetMemberObj : getFieldValues(ObjectName,fieldSetName)){
            headerLabels.add(fieldSetMemberObj.getLabel());
            system.debug(fieldSetMemberObj.getFieldPath());
            system.debug(fieldSetMemberObj.getLabel());
        }
        wrappedObj.headerLabels = headerLabels;
        return wrappedObj;
    }
    
    public static List<Schema.FieldSetMember> getFieldValues(String ObjectName, String fieldSetName){
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        
        return fieldSetObj.getFields();
    }
    
    @AuraEnabled
    public static ObjectWrapper getCases(String search, String sortBy,  String sortDirection, String ObjectName){
        List<Schema.FieldSetMember> fieldSetMemberList = getFieldValues(ObjectName,'fieldsToDisplay');
        Map<String, Schema.SObjectField> refObjFieldMap = Schema.getGlobalDescribe().get(ObjectName).getDescribe().Fields.getMap();
        String query = 'SELECT Id, ';
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList){
            if(fieldSetMemberObj.getType() !=  Schema.DisplayType.Reference){
                query += fieldSetMemberObj.getFieldPath() + ', ';
            }
            else{
                if(refObjFieldMap.get(fieldSetMemberObj.getFieldPath()).getDescribe().getReferenceTo()[0] == Schema.Case.SObjectType){
                     query += refObjFieldMap.get(fieldSetMemberObj.getFieldPath()).getDescribe().getRelationshipName() + '.CaseNumber, ';
                }
                else{
                    query += refObjFieldMap.get(fieldSetMemberObj.getFieldPath()).getDescribe().getRelationshipName() + '.Name, ';
                }
            }
        }
        query = query.removeEnd(', ');
        query = query + ' FROM '+ ObjectName;
        system.debug('query first--->'+query);
        if(String.isBlank(search)  && String.isNotBlank(sortBy) && sortBy != 'All'){
            query += ' Order By ' + sortBy + ' ' + sortDirection; 
        }
        else if(String.isBlank(search) && String.isNotBlank(sortBy) && sortBy == 'All'){
            query += ' Order By Name ' + sortDirection; 
        }
        else if(String.isNotBlank(search) && sortBy == 'All'){
            search = '\'%'+search+'%\'';
            query += ' WHERE ';
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList){
                if(fieldSetMemberObj.getType() == Schema.DisplayType.String){
                    query += fieldSetMemberObj.getFieldPath() + ' LIKE '+search + ' OR ';
                }
                else if(fieldSetMemberObj.getType() ==  Schema.DisplayType.Reference){
                    if(refObjFieldMap.get(fieldSetMemberObj.getFieldPath()).getDescribe().getReferenceTo()[0] == Schema.Case.SObjectType){
                         query += refObjFieldMap.get(fieldSetMemberObj.getFieldPath()).getDescribe().getRelationshipName() + '.CaseNumber LIKE '+search + ' OR ';
                    }
                    else{
                        query += refObjFieldMap.get(fieldSetMemberObj.getFieldPath()).getDescribe().getRelationshipName() + '.Name LIKE '+search + ' OR ';
                    }
                }
            }
        }
        else if(String.isNotBlank(search) && sortBy != 'All'){
            search = '\'%'+search+'%\'';
            query += ' Where ' + sortBy +' Like '+ search + ' order By '+ sortBy + ' ' + sortDirection; 
        }
        query = query.removeEnd('OR ');
        system.debug('query--->'+query);
    	ObjectWrapper wrap = new ObjectWrapper();
    	wrap.detailValues = new List<List<sobjectDetail>>();
    	List<sobjectDetail> sobjectDetailList;
        if(query.contains('order By')){
            query += ' NULLS LAST';
        }
        system.debug('query--->'+query);
    	for(Sobject con : database.Query(query)){
    	     sobjectDetailList = new List<sObjectDetail>();
    	     for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList){
    	         if(fieldSetMemberObj.getType() !=  Schema.DisplayType.Reference){
    	             if(con.get(fieldSetMemberObj.getFieldPath()) != null ){
        	             sObjectDetailList.add(new sObjectDetail(fieldSetMemberObj.getLabel(),String.valueOf(con.get(fieldSetMemberObj.getFieldPath()))));
        	         }
        	         else{
        	             sObjectDetailList.add(new sObjectDetail(fieldSetMemberObj.getLabel(),' '));
        	         }
                }
                else{
                    String refPath;
                    SObject parentObj = con.getSobject(refObjFieldMap.get(fieldSetMemberObj.getFieldPath()).getDescribe().getRelationshipName());
                    if(refObjFieldMap.get(fieldSetMemberObj.getFieldPath()).getDescribe().getReferenceTo()[0] == Schema.Case.SObjectType){
                        if(parentObj != null && parentObj.get('CaseNumber') != null){
                            sObjectDetailList.add(new sObjectDetail(refObjFieldMap.get(fieldSetMemberObj.getFieldPath()).getDescribe().getRelationshipName(),String.valueOf(parentObj.get('CaseNumber'))));
                        }
                    }
                    else{
                        if(parentObj != null && parentObj.get('Name') != null){
                            sObjectDetailList.add(new sObjectDetail(refObjFieldMap.get(fieldSetMemberObj.getFieldPath()).getDescribe().getRelationshipName(),String.valueOf(parentObj.get('Name'))));
                        }
                    }
                }
    	         
    	     }
    	     sobjectDetailList.add(new sObjectDetail('Id',String.valueOf(con.get('Id'))));
    	     wrap.detailValues.add(sObjectDetailList);
    	}
        return wrap;
  
  }
}