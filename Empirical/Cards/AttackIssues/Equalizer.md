# Project Name
Equalizer

# Description
The function `getRatioForOneEToken()` uses the staked token of the current contract to calculate the token’s ratio, which may not look vulnerable at first glance. However, the contract also provides a flashloan functionality, which allows the token’s ratio of the contract to be manipulated arbitrarily.

# Root Cause
```solidity
/**
 * @dev One eToken to token
 * @return The current eToken ratio.
 */
function getRatioForOneEToken() public view returns (uint256) {
    if (totalSupply() > 0 && stakedToken.balanceOf(address(this)) > 0) {
        return (stakedToken.balanceOf(address(this)) * RATIO_MULTIPLY_FACTOR) / totalSupply();
    }
    return 1 * RATIO_MULTIPLY_FACTOR;
}

/**
 * @dev The amount of staked tokens.
 * @param amount of eTokens deposited to be burned.
 * @return The amount of staked tokens to send to address.
 */
function getStakedTokensFromAmount(uint256 amount) internal view returns (uint256) {
    return (amount * getRatioForOneEToken()) / RATIO_MULTIPLY_FACTOR;
}

/**
 * @dev Remove liquidity.
 * @param amount of eTokens to be removed from Vault.
 */
function removeLiquidity(uint256 amount) external nonReentrant {
    require(amount <= balanceOf(msg.sender), 'AMOUNT_BIGGER_THAN_BALANCE');

    uint256 stakedTokensToTransfer = getStakedTokensFromAmount(amount);
    totalAmountDeposited =
        totalAmountDeposited -
        (amount * totalAmountDeposited) /
        totalSupply();

    _burn(msg.sender, amount);
    require(stakedToken.transfer(msg.sender, stakedTokensToTransfer), 'TRANSFER_STAKED_FAIL');

    emit Withdraw(msg.sender, amount, stakedTokensToTransfer);
}