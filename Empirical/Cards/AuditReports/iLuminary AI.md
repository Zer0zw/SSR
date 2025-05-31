# Project Name
iLuminary AI

# Description
1. Mints Tokens
    
    The minters, which is a role assigned by the contract owner have the authority to mint tokens, up to `maxSupply`. The minters may take advantage of it by calling the `mint` function.
    
2. Stops Transactions
    
    The contract owner has the authority to stop the transactions for all users. The owner may take advantage of it by calling the `pause` function, which will pause all transfers.

# Root Cause
```solidity
// Mints Tokens
function mint(address account, uint256 amount) external onlyMinter {
    require(account != address(0), "Invalid Address!");
    require(totalSupply() + amount <= maxSupply, "Exceeds Max Supply!");
    _mint(account, amount);
}

// Stops Transactions
function pause() external onlyOwner {
    _pause();
}

function _transfer(
    address from,
    address to,
    uint256 amount
) internal virtual override whenNotPaused { 
    super._transfer(from, to, amount);
}