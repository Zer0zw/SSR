# Project Name
Bunny Park

# Description
1. Administrator Capability On Minting And Burning
    
    The owner account can mint tokens to any account address by the function **`mintTo`** and burn anyone's tokens by the function **`burn`** at any time. Any compromise to the owner account may allow the hacker to take advantage of this function and eventually damage the contract.
    
2. Administrator Capability On Burning Cards
    
    The owner account can burn anyone's cards by the function **`burn`** at any time. The keeper account can burn anyone's cards by the function **`keeperburn`** at any time. Any compromise to the owner account may allow the hacker to take advantage of this function and eventually damage the contract.
    
3. Incorrect logical
    
    Could users get more than one King Share Card? If yes, line 495 code should be **`BPrewards = BPrewards.add(...)`**. If no, it is better to remove the **`for`** loop.

# Root Cause
```solidity
// Incorrect logical
BPrewards = multiplier.mul(kingRate).div(decimal);