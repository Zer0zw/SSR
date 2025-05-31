# Project Name
Vestra DAO

# Description
1. Centralization Related Risks
    
    In the contract **`PrivateSale`** the role **`_owner`** has authority over the functions shown in the list below.
    
    - **`withdrawUsdt()`**: Withdraw USDT in the contract;
    - **`withdrawToken()`**: Withdraw tokens in the contract;
    - **`whiteListAdd()`**: Adds multiple addresses to the whitelist;
    - **`whiteListRemove()`**: Removes an address from the whitelist.
    
    Additionally, because the contract inherits the **`Ownable`** contract from OpenZeppelin, the owner has the following authorities within the contract:
    
    - **`renounceOwnership()`**: Leaves the contract without owner;
    - **`transferOwnership()`**: Transfers ownership of the contract to a new account.
    
    Any compromise to the **`_owner`** account may allow the hacker to take advantage of this authority, disrupt the normal access control and withdraw the assets from the contract.
    
    Furthermore, the hacker can take advantage of this authority to remove the whitelist, preventing investors who buy VDAO token from claiming them.
    
2. Insufficient Refund Caused by Division Precision
    
    The **`_refundedUsdt()`** function allows users to calculate the refund they can obtain during the claim period, which is generally based on their deposit when **`_totalInvestment`** exceeds **`TOTAL_EXPECTATION`**.
    
    In Solidity, division often results in a loss of precision, with calculations rounding down. This can cause the actual result to be smaller than expected. For example, the result of calculation **`poolRate = (_deposit * RATE) / _totalInvestment`** is smaller, so the refund amount **`_deposit - (realInvestment / RATE)`** transferred to the user may be larger than intended.
    
    As a result, after all users have claimed their refunds, the actual USDT balance in the contract may be less than **`TOTAL_EXPECTATION`**. If the owner withdraws all **`TOTAL_EXPECTATION`** amount of USDT before users claim their refunds, the remaining USDT in the contract may not be sufficient to refund all users, potentially invalidating the claims.

# Root Cause
Not Open Source