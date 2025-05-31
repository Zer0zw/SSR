# Project Name
NomiSwap

# Description
1. Centralization Risk in `StakingService2.sol`
    
    In the contract **`StakingService2`** the role **`_owner`** has authority over the functions shown in the diagram below.
    
    Any compromise to the **`_owner`** account may allow the hacker to take advantage of this authority and:
    
    - Change the address state variable **`nmxSupplier`** by calling function **`changeNmxSupplier()`**. **`nmxSupplier`** is in charge of minting **`NMX`** tokens to the **`StakingService2`** contract.
    - Set the state variable **`claimRewardPaused`** and either pause or resume users from claiming rewards through functions:
        - **`claimReward()`**
        - **`claimRewardTo()`**
        - **`claimRewardToWithoutUpdate()`**
        - **`claimWithAuthorization()`**
    - Withdraw any amount of **`ETH`** or **`ERC20`** tokens from within this contract by calling function **`recoverFunds()`** from the inherited **`RecoverableByOwner.sol`** contract.
2. Missing Zero Address Validation
    
    Addresses should be checked before assignment or external call to make sure they are not zero addresses.

# Root Cause
Not Open Source
