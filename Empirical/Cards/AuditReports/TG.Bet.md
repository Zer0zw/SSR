# Project Name
TG.Bet

# Description
1. Contract Centralization Risk
    
    The contract's functionality and behavior are heavily dependent on external parameters or configurations. While external configuration can offer flexibility, it also poses several centralization risks that warrant attention. Centralization risks arising from the dependence on external configuration include Single Point of Control, Vulnerability to Attacks, Operational Delays, Trust Dependencies, and Decentralization Erosion.
    
    The contract owner is responsible for setting the proper pair addresses and launcher address. If this functionality abused by the contract owner, then liquidity may be added in the main pairs with different rate than the expected, before the presale process is finalized.
    
2. Stops Transactions
    
    As part of the launch process, initially, the transfers are disabled for all the users excluding the owner. Once the trades are enabled, they will not be able to stop again.

# Root Cause
```solidity
// Contract Centralization Risk
function setLauncher(address launcher)
function setPairs(address[] calldata pairs, bool[] calldata status)

// Stops Transactions
function enableTrading() external onlyOwner {
    require(!tradingEnabled, "TGB: trading already enabled");
    tradingEnabled = true;
    emit TradingEnabled();
}

function _transfer(
...
    if (!tradingEnabled) {
    ...