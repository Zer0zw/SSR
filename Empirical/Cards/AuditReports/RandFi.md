# Project Name
RandFi

# Description
1. Centralization Risk
    
    The contract uses specific roles, namely `Guard` and `keeper`, which play pivotal roles in the operation and management of the contract. The `Guard` has the authority to update the state of the `keeper` addresses, which means adding or removing them. More critically, the `Guard` has the capability to include its address as a `keeper` address. The `keeper` role is crucial, as these users are responsible for depositing and withdrawing tokens from the contract. This implementation introduces a centralization risk, where a single address, the `Guard` or the `keeper` has substantial power over the contract, potentially compromising its decentralized nature and leading to central points of failure or abuse.

# Root Cause
```solidity
// Centralization Risk
function updateKeeper(address _keeper, bool state) external {
    require(msg.sender == Guard, "Vault: not guard");
    require(Update, "Vault: not add");
    keeper[_keeper] = state;
    mkeeper[_keeper] = state;
}

function withdraw(address token, address to, uint256 amount) external {
    require(keeper[msg.sender], "Vault: not keeper");
    ...
}