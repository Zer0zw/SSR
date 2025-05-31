# Project Name
Dextop

# Description
1. Redundant Storage Writes
    
    The contract modifies the state of the following variables without checking if their current value is the same as the one given as an argument. As a result, the contract performs redundant storage writes, when the provided parameter matches the current state of the variables, leading to unnecessary gas consumption and inefficiencies in contract execution.

# Root Cause
```solidity
// Redundant Storage Writes
function setUniswapV2Pair(address _uniswapV2Pair) external onlyOwner {
    uniswapV2Pair = _uniswapV2Pair;
}

function setDXTSteakAddress(address _DXTSteakAddress) external onlyOwner {
    DXTSteakAddress = _DXTSteakAddress;
}

function excludeFromFee(address account, bool excluded) public onlyOwner {
    _isExcludedFromFee[account] = excluded;
}