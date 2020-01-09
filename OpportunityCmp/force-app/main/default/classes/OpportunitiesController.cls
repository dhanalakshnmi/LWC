public with sharing class OpportunitiesController {
   
    @AuraEnabled(Cacheable=true)
    public static List<opportunityWrapper> OpportunitiesController(Integer pagenumber, Integer numberOfRecords, Integer pageSize, String searchString) {
       String searchKey = '%' + searchString + '%';
       String query = 'SELECT Id, Name, Account.Name, StageName, CloseDate, Amount FROM Opportunity '; 
       if (searchString != null && searchString != '') {  
        query += ' where name like \'%' + searchString + '%\' ';  
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
    @AuraEnabled(cacheable = true)  
    public static Integer getOpportunitiesCount(String searchString) {  
        String query = 'select count() from Opportunity ';  
        if (searchString != null && searchString != '') {  
        query += ' where name like \'%' + searchString + '%\' ';  
        }  
        return Database.countQuery(query);  
    } 
     //wrapper class
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
