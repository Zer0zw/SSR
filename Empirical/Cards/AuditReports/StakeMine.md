# Project Name
StakeMine

# Description
1. Burn functionality is incompatible with reward calculation
    
    StakeMine coin provides burn functionality for user to burn their tokens. However, the reward calculation is related to the amount of tokens a user holds. If a user burns his tokens, **`holderMap[holder]`** is not updated, therefore he could still receive the reward. In addition, reflectPerShare is not updated as well, this could result in reward miscalculation.
    
2. Self transfer may increase user reward
    
    It is possible to inflate user's rewards by performing self-transfer. specifically, When the following criteria are met:
    
    - **`sender`** is not exempt
    - **`senderAmount`** is at least **`minTokenHoldToReflect`**
    - **`senderAmount * incReflectPerShare`** is at least **`reflectPrecision`** (where **`incReflectPerShare`** is the amount by which **`reflectPerShare`** is increased, which depends on **`accumulatedToReflect`** and **`totalTokens`**)
    
    Whether this could happen depends whether the extra reward outweighs the fees.

# Root Cause
```solidity
// Burn functionality is incompatible with reward calculation
function burn(uint amount) external {
  _burn(_msgSender(), amount);
}