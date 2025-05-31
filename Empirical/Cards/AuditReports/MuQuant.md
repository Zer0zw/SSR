# Project Name
MuQuant

# Description
1. Stable Parameter Inconsistency
    
    According to the contract, only the initial depositor of the stable addresses is registered to a specific token. The next depositor's `stable` parameter is ignored. This may produce wrong assumptions that the amount has been deposited and registered to a specific stable address.

# Root Cause
```solidity
// Stable Parameter Inconsistency
function deposit(address token, address stable, uint256 amount) external {
    require(keeper[msg.sender], "Vault: not keeper");
    if (vaults[token].stable == address(0)) {
        vaults[token].stable = stable;
    }
    vaults[token].amount += amount;
}