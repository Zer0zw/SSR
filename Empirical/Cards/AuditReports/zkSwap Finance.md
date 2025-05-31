# Project Name
zkSwap Finance

# Description
1. Contract Centralization Risk
    
    The contract's functionality and behavior are heavily dependent on external parameters or configurations. While external configuration can offer flexibility, it also poses several centralization risks that warrant attention. Centralization risks arising from the dependence on external configuration include Single Point of Control, Vulnerability to Attacks, Operational Delays, Trust Dependencies, and Decentralization Erosion.
    
    Specifically, the contract owner has the authority to make changes to key parameters of the smart contract, that can heavily impact on its functionality.
    
2. Locked Tokens Accumulation
    
    The contract's withdrawal mechanism calculates the withdrawal amount based on the user's shares and applies a withdrawal fee. However, due to the integer arithmetic used in Solidity, fractional parts of tokens resulting from this fee calculation are not transferred to the user and are effectively left in the contract. Over time, especially with numerous transactions, these residual amounts could accumulate, leading to a growing pool of locked tokens within the contract's balance.
    
    The presence of these locked tokens in the contract's balance could inadvertently inflate the apparent value of each share when users make subsequent withdrawals. This situation might lead to an unintentional distribution of these locked tokens to users withdrawing their stakes, thereby slightly increasing their withdrawal amounts. While this might seem beneficial to users in the short term, it represents a deviation from the intended token distribution and staking mechanics as designed.

# Root Cause
```solidity
// Contract Centralization Risk
function setWithdrawFeeFactor(uint8 _factor) external onlyOwner {
    require(_factor < withdrawFeeFactorMax, "setWithdrawFeeFactor: max Factor");
    withdrawFeeFactor = _factor;
}

function setRewardRate(uint256 _zfPerSecond) external onlyOwner {
    zfPerSecond = _zfPerSecond;
}

// Locked Tokens Accumulation
function withdraw(uint256 _shares) nonReentrant public {
    // Harvest
    uint256 pending = pendingZF();
    if (pending > 0) {
        IZFToken(token).mint(address(this), pending);
        lastRewardTime = block.timestamp;
    }
        
    uint256 _withdrawAmount = (balance().mul(_shares)).div(totalSupply);
    _withdrawAmount = _withdrawAmount.mul(withdrawFeeFactor).div(withdrawFeeFactorMax);

    _burn(msg.sender, _shares);
    IERC20(token).safeTransfer(msg.sender, _withdrawAmount);
}