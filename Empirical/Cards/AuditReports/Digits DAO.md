# Project Name
Digits DAO

# Description
1. Transfers Contract's Tokens
    
    The contract owner has the authority to claim all the balance of the contract. The owner may take advantage of it by calling the `rescueToken` function.

# Root Cause
```solidity
// Transfers Contract's Tokens
function rescueToken(address _token, uint256 _amount) external onlyOwner {
  IERC20(_token).transfer(msg.sender, _amount);
}