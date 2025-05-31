# Project Name
stakefish_ethereum_staking_audit_report

# Description
1. Possibility of disproportional payments after services end
    
    Once the StakefishServicesContract enters the Withdrawn phase, depositors can withdraw their share from the contract. If ServiceContract hasn't been paid its collateral and staking rewards, depositors won’t get their fair proportional share if they withdraw too early. 
    
2. Vulnerability in StakefishServicesContract.receive() 
    
    The receive() function implements a feature that allows users to deposit via a plain Ether transfer transaction instead of calling the deposit() function. This can lead to the loss of user funds.

# Root Cause
Not Open Source
