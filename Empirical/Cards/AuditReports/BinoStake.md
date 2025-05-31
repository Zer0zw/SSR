# Project Name
BinoStake

# Description
1. Burns Tokens
    
    The contract stake manager has the authority to burn tokens from a specific address. The stake manager is intented to be the BinoStakeManager contract. However, the contract's admin can modify the stake manager's address to any address. The stake manager may take advantage of it by calling the `burn` function. As a result, the targeted address will lose the corresponding tokens.
    
2. Mints Tokens
    
    The contract stake manager has the authority to mint tokens. The stake manager is intented to be the BinoStakeManager contract. However, the contract's admin can modify the stake manager's address to any address. Additonally, the contract has no cap for the `totalSupply`. The stake manager may take advantage of it by calling the `mint` function. As a result, the contract tokens will be highly inflated.

# Root Cause
```solidity
// Burns Tokens
function burn(address _account, uint256 _amount)
    external
    override
    onlyStakeManager
{
    _burn(_account, _amount);
}

// Mints Tokens
function mint(address _account, uint256 _amount)
    external
    override
    onlyStakeManager
{
    _mint(_account, _amount);
}