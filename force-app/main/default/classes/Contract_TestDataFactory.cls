/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-24-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class Contract_TestDataFactory {
    public static Contract getContract(ID accountId){
        Contract contractToReturn = [SELECT Id,
                                            AccountId
                                     FROM Contract 
                                     WHERE AccountId= :accountId 
                                     LIMIT 1];
        return contractToReturn;
    }
    public static List<Contract> getContractsAll(){
        List<Contract> contractList = [SELECT Id,
                                            AccountId
                                     FROM Contract 
                                    ];
        return contractList;
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
    public static void createContractsList(List<Account> accountsList){
        List<Contract> contractsList = new List<Contract>();
        for(Account accountCurrent : accountsList){
            contractsList.add(new Contract(
                AccountId = accountCurrent.Id,
                Status = 'Draft',
                StartDate = Date.today(),
                ContractTerm = 6
            ));
        }
        insert contractsList;
    }
}
