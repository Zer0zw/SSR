# Project Name
Merlin Lab

# Description
When calculating the profit of the strategy, it converts the received BNB to WBNB. The increase in WBNB balance is then seen as the profit. The issue? By sending BNB to the contract directly, it is also converted to WBNB and considered "profit". Finally, exploiters had an easy way to complete the arbitrage: Deposit BNB in the contract, harvest and all that BNB would be assumed to be rewardable profit.

# Root Cause
```solidity
function _swapRewardTokenTowBNB(uint256amount) internaloverride returns (uint256){ 
    //exchange to wBNB
    uint256 wBNBBefore = IERC20Upgradeable(WRAPPED NATIVE TOKEN).balanceof(address(this)),
    IWETH(WRAPPED NATIVE TOKEN).deposit{value: amount}();
    uint256 wBNBExchanged= IERC20Upgradeable(WRAPPED NATIVE TOKEN).balance0f(address(this)).sub(wBNBBefore);
    return wBNBExchanged;
}