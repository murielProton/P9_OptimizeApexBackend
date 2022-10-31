/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-31-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class Contract_TestDataFactory {
    public static Contract getContract(ID accountId){
        Contract contractToReturn = [SELECT Id,
                                            AccountId,
                                            Name
                                     FROM Contract 
                                     WHERE AccountId= :accountId 
                                     LIMIT 1];
        return contractToReturn;
    }
    public static List<Contract> getContractsAll(){
        List<Contract> contractList = [SELECT Id,
                                            AccountId,
                                            Name,
                                            Status
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
                //can't create a contract with the Status set to Activated
                Status = 'Draft',
                StartDate = Date.today(),
                ContractTerm = 6
            ));
        }
        insert contractsList;
    }
    public static void updateContractsListStatusToActivated(List<Contract> contractsList){
        List<Contract> contractsListToUpdate = new List<Contract>();
        for(Contract contractCurrent : contractsList){
            //can't create a contract with the Status set to Activated
            contractCurrent.Status = 'Activated';
            contractsListToUpdate.add(contractCurrent);
        }
        update contractsListToUpdate;
    }
}
