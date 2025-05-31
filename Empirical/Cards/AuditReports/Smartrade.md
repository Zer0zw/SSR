# Project Name
Smartrade

# Description
1. Transfers Contract's Tokens
    
    The contract owner has the authority to claim all the balance of the contract. The owner may take advantage of it by calling the `depositToVault` function.

# Root Cause
```solidity
// Transfers Contract's Tokens
function depositToVault(address token, address to, uint256 amount) public onlyOwner {
    IToken(token).transfer(to, amount);
}