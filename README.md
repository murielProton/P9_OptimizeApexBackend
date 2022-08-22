# Short commings of the repository Git OpenClassrooms https://github.com/OpenClassroomsSFDEV/P9_OptimizeApexBackend.git

- No -meta.xml files
- No inventory of all the manual actions to set up a reliable instances of organisation to test the code into
- The Api names of the fields are in french


# initial 9 erros and problems preventing the first deployment to Org

1 - force-app\main\default\classes\MyTeamOrdersController.cls  File name mismatch with class name: VFC01_Team                                                                     
2 - force-app\main\default\classes\testUpdateAccountCA.cls     Invalid type: OrderItemItem (24:25)                                                                                       
3 - force-app\main\default\classes\testUpdateAccountCA.cls     Invalid type: OrderItemItem (22:25)                                                                                       
4 - force-app\main\default\classes\UpdateAccounts.cls          Variable does not exist: Chiffre_d_affaire__c (17:63)                                                                      
5 - force-app\main\default\classes\UpdateAccounts.cls          Variable does not exist: Chiffre_d_affaire__c (14:14)                                                                     
6 - force-app\main\default\classes\UpdateAccounts.cls          Variable does not exist: Chiffre_d_affaire__c (17:30)                                                                     
7 - force-app\main\default\classes\UpdateAllAccounts.cls       Type name already in use: Batch01AccountChiffreAffaire (1:14)                                                             
force-app\main\default\triggers\CalculMontant.trigger      Variable does not exist: ShipmentCost__c (4:58)                                                                          
8 - force-app\main\default\triggers\UpdateAccountCA.trigger    SELECT Id, Chiffre_d_affaire__c FROM Account                                                                              
9 - ERROR at Row:1:Column:12                                   
    No such column 'Chiffre_d_affaire__c' on entity 'Account'. If you are attempting to use a custom field, be sure to append the '__c' after the custom field name. Please reference your WSDL or the describe call for the appropriate names. (8:23)


# Renaming Classes folowing the naming conventions :
https://github.com/cfpb/salesforce-docs/blob/master/_pages/Salesforce-Naming-Conventions.md

# Manual Actions before deployement
See file : Tasks-prior&after-deployment.csv

# Testing Fasha code
- the batch that updates
- the trigger on revenues
- the trigger en Ammount 

# Changes made in order for the app to work
- adding exceptions to the OrderNetAmountTrigger
- adding exceptions to the AccountRevenueTrigger