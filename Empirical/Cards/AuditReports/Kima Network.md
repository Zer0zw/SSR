# Project Name
Kima Network

# Description
1. Burns Tokens
    
    The contract owner has the authority to burn tokens from a specific address. The owner may take advantage of it by calling the `burn` function. As a result, the targeted address will lose the corresponding tokens.

# Root Cause
```solidity
function burn(address to, uint256 amount) public onlyOwner {
  _burn(to, amount);
}