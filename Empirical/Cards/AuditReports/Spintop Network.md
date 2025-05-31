# Project Name
Spintop Network

# Description
1. Centralization Risk in SpinStakable.sol
    
    In the contract, **`SpinStakable`**, the role, **`_owner`**, has authority over the functions shown in the diagram below.
    
    Any compromise to the **`_owner`** account may allow the hacker to take advantage of this authority and [fixme, describe what hacker can do and the impact].
    
2. Missing Check for `rewardsToken`
    
    There is no check in the function **`recoverERC20()`** to ensure that enough **`rewardsToken`** balance is maintained, meaning a user may be unable to gain their allocated rewards.
    
3. `rewardRate` Overflow
    
    If both the **`rewardsToken`** and **`stakingToken`** reference the same token, then calling the **`balanceOf()`** function would return the amount staked and allocated for rewards. This could potentially lead to issues by allowing higher a **`rewardRate`** than expected.
    
4. Incompatibility With Deflationary Tokens (Staking)
    
    When transferring standard ERC20 deflationary tokens, the input amount may not be equal to the received amount due to the charged transaction fee. For example, if a user stakes 100 deflationary tokens (with a 10% transaction fee) in a MasterChef, only 90 tokens actually arrived in the contract. However, the user can still withdraw 100 tokens from the contract, which causes the contract to lose 10 tokens in such a transaction.
    
    The MasterChef takes the pool token balance(the **`lpSupply`**) into account when calculating the users' reward. An attacker can repeat the process of deposit and withdraw to lower the token balance(**`lpSupply`**) in a deflationary token pool and cause the contract to increase the reward amount.
    
    Reference: https://thoreum-finance.medium.com/what-exploit-happened-today-for-gocerberus-and-garuda-also-for-lokum-ybear-piggy-caramelswap-3943ee23a39f

# Root Cause
Not Open Source
