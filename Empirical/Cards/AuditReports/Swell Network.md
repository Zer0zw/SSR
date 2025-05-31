# Project Name
Swell Network

# Description
1. Centralization Risks in SwellAuraVault.sol
    
    In the contract **`SwellAuraVault`** the role **`_owner`** has authority over the functions shown in the diagram below. Any compromise to the **`_owner`** account may allow the hacker to take advantage of this authority and change the **`platformFee`** value to send 100% of the **`tokenBalance`** collected in the contract from a call to **`auraBaseRewardPool.getReward()`** to the **`owner()`**.
    
2. Inconsistencies in updates to `userRecords`
    
    In the function **`_registerDeposit()`**, only the **`balance`** of a **`_user`** address is updated in the **`userRecords`** mapping. The struct variable **`entryRPT`** is not updated; this means that when the same **`_user`** address withdraws, their **`record.entryRPT`** will read as 0 (even if they deposited their tokens at a point in time when the sum was larger) and as a result, they will be privy to the all-time running sum **`rewardPerToken`** corresponding to the reward token address. Since their balance is updated, provided the **`rpt`** is positive, a user who goes through **`_registerDeposit()`** for their first deposit gets the full **`rpt`** value applied to the amount added to **`unclaimedRewards`**, either through a second deposit that goes through **`_depositRewards()`** or withdrawing through **`_withdrawRewards()`**.
    
    The function **`_depositRewards()`**, however, does not provide the same record-keeping for a first-time depositor. A user who deposits through **`_depositRewards()`** for the first time has an update to their **`record.unclaimedRewards`** that is 0 (since **`record.balance`** is 0 at that point). However, their **`record.entryRPT`** is updated to be the **`rpt`** value at the time of deposit. This means the next time this same user deposits or withdraws through **`_depositRewards()`** or **`_withdrawRewards()`**, their value for **`record.unclaimedRewards`** is only scaled by **`rpt - record.entryRPT`**, where **`record.entryRPT`** is nonzero.
    
    The issue appears to be that two users, both depositing for the first time, may have two different outcomes dependent upon whether the call to **`auraBaseRewardPool.getReward()`** yields a positive **`tokenBalance`** amount.
    
    It also appears possible that a user may both deposit tokens for a period of time and withdraw these tokens without ever receiving rewards. Such an instance appears to occur if the user happens to deposit tokens through the **`_depositRewards()`** function (in which case record.unclaimedRewards is still 0 after update), and then withdraws through the **`_registerWithdraw()`** function, where **`record.unclaimedRewards`** is also no updated for the user. Which functions are called is dependent upon whether **`auraBaseRewardPool.getReward()`** yields a nonzero **`tokenBalance`** for the contract.
    
3. Logic allows `_withdrawAmount` to be larger than `record.balance`
    
    In functions **`_registerWithdraw()`** and **`_withdrawRewards()`**, the **`record.balance`** for the input address **`_user`** is updated to subtract away the **`_amount`** to be withdrawn. However, the logic for updating the **`record.balance`** is as follows:
    
    ```solidity
    record.balance -= _amount > record.balance ? record.balance : _amount;
    ```
    
    which allows **`_amount`** to be larger than the value for **`record.balance`** without causing a revert of the transaction. While in most cases, a user calling **`withdraw()`** with a higher value for **`assets`** than they own will cause a revert, if there is a difference in **`msg.sender`** and **`tx.origin`**, this facilitates **`tx.origin`** in using a call for a withdrawal transaction that may be larger than the recorded **`record.balance`** for **`tx.origin`** to gain rewards.

# Root Cause
```solidity
record.balance -= _amount > record.balance ? record.balance : _amount;