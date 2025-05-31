# Project Name
APEX

# Description
1. Contract Centralization Risk
    
    The contract's functionality and behavior are heavily dependent on external parameters or configurations. While external configuration can offer flexibility, it also poses several centralization risks that warrant attention. Centralization risks arising from the dependence on external configuration include Single Point of Control, Vulnerability to Attacks, Operational Delays, Trust Dependencies, and Decentralization Erosion. Furthermore, the contract owner has to call functions like `addLiquidity` so that the system is functional afterwards.

# Root Cause
```solidity
//  Contract Centralization Risk
function setTradingFeeRate(uint256 feeRate) public onlyOwner {
    if (feeRate > MAX_FEE_RATE) revert InvalidFeeRate(); // 5%
    tradingFeeRate = feeRate;

    emit TradingFeeRateSet(feeRate);
}

function setMaxWalletPercent(uint256 maxWalletPercent_) public onlyOwner {
    if (maxWalletPercent_ > 10000) revert InvalidMaxWalletPercent(); // 100%
    if (maxWalletEnabled && maxWalletPercent_ == 0)
        revert InvalidMaxWalletPercent();
    maxWalletPercent = maxWalletPercent_;

    emit MaxWalletPercentSet(maxWalletPercent_);
}