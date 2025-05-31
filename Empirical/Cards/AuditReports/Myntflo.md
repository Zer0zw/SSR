# Project Name
Myntflo

# Description
1. Transfers Contract's Tokens
    
    The contract owner has the authority to claim all the balance of reward token from the contract. The owner may take advantage of it by calling the `withdrawRewardsToken` function.

# Root Cause
```solidity
// Transfers Contract's Tokens
function withdrawRewardsToken() external onlyOwner {
    rewardsToken.transfer(owner, rewardsToken.balanceOf(address(this)));
}