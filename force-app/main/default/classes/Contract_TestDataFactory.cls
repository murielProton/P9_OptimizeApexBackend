/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-17-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class Contract_TestDataFactory {
    public static Contract getContract(ID accountId){
        Contract contractToReturn = [SELECT Id
                                     FROM Contract 
                                     WHERE AccountId= :accountId 
                                     LIMIT 1];
        return contractToReturn;
    }
    public static void createContract(Account accountForThisTest){
        List<Contract> contractsToInsertForTest = new List<Contract>();
        contractsToInsertForTest.add(new Contract(
            AccountId = accountForThisTest.Id,
            Status = 'Draft',
            StartDate = Date.today(),
            ContractTerm = 6
        ));
        insert contractsToInsertForTest;
    }
}
