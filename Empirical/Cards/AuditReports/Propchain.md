# Project Name
Propchain

# Description
1. Missing Pause Functionality
    
    The contract includes the `whenNotPaused` modifier in the `stake` function, which suggests an intention to allow the pausing and unpausing of the staking functionality. This modifier is used to prevent a function from being executed when the contract is in a paused state. However, the contract lacks any function to toggle the paused state. This omission means that there is no way to set the paused variable to `true`, which is necessary to activate the pausing mechanism. Consequently, the staking functionality cannot be paused, rendering the `whenNotPaused` modifier ineffective and leaving the contract without a key aspect of its intended control mechanism.

# Root Cause
```solidity
// Missing Pause Functionality
function stake(uint256 amount)
    ...
    whenNotPaused
    ...
{
    ...
}