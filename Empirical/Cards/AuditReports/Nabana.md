# Project Name
Nabana

# Description
1. Transfers Contract's Tokens
    
    The contract owner has the authority to claim all the balance of the contract. The owner may take advantage of it by calling the `emergencyWithdraw` function.

# Root Cause
```solidity
// Transfers Contract's Tokens
function emergencyWithdraw() external onlyOwner {
  nabana.transfer(owner(), nabana.balanceOf(address(this)));
}