# Project Name
Wault Finance

# Description
The `stake` function contains a logic that transfers an additional amount of WEX tokens to the staker, allowing for the acquisition of extra rewards without any time restrictions. The attacker exploited this by repeatedly calling the stake function to accumulate a large quantity of WEX tokens. Consequently, this led to a reduction in the number of WEX tokens in the BSC_USDT-WEX liquidity pool, creating an arbitrage opportunity. The attacker then sold the acquired WEX tokens to obtain unearned profits.

# Root Cause
```solidity
function stake(uint256 amount) external nonReentrant {
    require(amount <= maxStakeAmount, 'amount too high');
    usdt.safeTransferFrom(msg.sender, address(this), amount);
    if(feePermille > 0) {
        uint256 feeAmount = amount * feePermille / 1000;
        usdt.safeTransfer(treasury, feeAmount);
        amount = amount - feeAmount;
    }
    uint256 wexAmount = amount * wexPermille / 1000;
    usdt.approve(address(wswapRouter), wexAmount);
    wswapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
        wexAmount,
        0,
        swapPath,
        address(this),
        block.timestamp
    );
    wusd.mint(msg.sender, amount);
    
    emit Stake(msg.sender, amount);
}