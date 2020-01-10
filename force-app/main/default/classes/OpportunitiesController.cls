public with sharing class OpportunitiesController {
   
   /***
	Name: OpportunitiesController(Constructor)
	Purpose: Method to fetch opportunities based on search string
    Parameters: [pagenumber, numberOfOpportunities, noOfRecordsPerSize, stringtobeSearched, searchBasedOn]
	Return Type: List of Wrapper class
	Created By: Dhanalakshmi
	Created Date: 07/01/20192020
	Modified By: 
	**/
    @AuraEnabled(Cacheable=true)
    public static List<opportunityWrapper> OpportunitiesController(Integer pagenumber, Integer numberOfRecords, Integer pageSize, String searchString, Boolean isAccountSearch) {
       if(isAccountSearch == NULL)
        isAccountSearch = false;
       String searchKey = '%' + searchString + '%';
       String query = 'SELECT Id, Name, Account.Name, StageName, CloseDate, Amount FROM Opportunity '; 
       if (searchString != null && searchString != '' && isAccountSearch != NULL && !isAccountSearch) {  
        query += ' where name like \'%' + searchString + '%\' ';  
        }
        else if(searchString != null && searchString != '' && isAccountSearch != NULL){
            query += ' where Account.Name like \'%' + searchString + '%\' '; 
        }   
        query += ' limit ' + pageSize + ' offset ' + (pageSize * (pagenumber - 1));  
        List<Opportunity> listOfOpportunities = Database.query(query);
        List<opportunityWrapper> listOfOpportunitiesData = new List<opportunityWrapper>();
        for(Opportunity opportunityInstance : listOfOpportunities){
            opportunityWrapper objWrapper = new opportunityWrapper(
                opportunityInstance.Id,
                opportunityInstance.Name,
                opportunityInstance.Account.name,
                opportunityInstance.StageName,
                opportunityInstance.CloseDate,
                opportunityInstance.Amount
            );
            listOfOpportunitiesData.add(objWrapper);
        }
        return listOfOpportunitiesData;
    } 
    /***
	Name: getOpportunitiesCount
	Purpose: Method to get the count of opportunities 
    Parameters: [stringtoBeSearched, searchBasedOn] 
	Return Type: Integer(No of Opportunities)
	Created By: Dhanalakshmi
	Created Date: 07/01/20192020
	Modified By: 
	**/
    @AuraEnabled(cacheable = true)  
    public static Integer getOpportunitiesCount(String searchString, Boolean isAccountSearch) {  
        if(isAccountSearch == NULL)
        isAccountSearch = false;
        String query = 'select count() from Opportunity ';  
        if (searchString != null && searchString != '' && isAccountSearch != NULL && !isAccountSearch) {  
        query += ' where name like \'%' + searchString + '%\' ';  
        } 
        else if(searchString != null && searchString != '' && isAccountSearch != NULL){
            query += ' where Account.Name like \'%' + searchString + '%\' '; 
        } 
        return Database.countQuery(query);  
    } 
    //wrapper class to bind the data to LWC Component
    public class opportunityWrapper{
        @AuraEnabled public string Id{get;set;}
        @AuraEnabled public string Name{get;set;}
        @AuraEnabled public string AccountName{get;set;}
        @AuraEnabled public string StageName{get;set;}
        @AuraEnabled public Date CloseDate{get;set;}
        @AuraEnabled public Decimal Amount{get;set;}

        public opportunityWrapper(string Id,string Name,string AccountName,string StageName,Date CloseDate,Decimal Amount){
            this.Id = Id;
            this.Name = Name;
            this.AccountName = AccountName;
            this.StageName = StageName;
            this.CloseDate = CloseDate;
            this.Amount = Amount;
        }
    } 
}
