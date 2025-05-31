# Project Name
Aperocket

# Description
To perform this attack, the TVL of the affected pool must be very low. Due to the fact that the attacker must send $CAKE to the AutoCake contract and harvest them as the reward. If there are other users who staked their $CAKE in the pool, by performing `harvest()` function, the attacker’s $CAKE will be shared with the other users in the pool as well.

Unfortunately, the AutoCake contract was just deployed 10 hours before the attack. Thus, the TVL of the pool was very low.

# Root Cause
```solidity
function harvest() external override {
    MASTERCHEF.leaveStaking(0);
    _harvest();
}

// Private functions
function _harvest() private {
    uint256 cakeAmount = CAKE.balanceOf(address(this));
    if (cakeAmount > 0) {
        emit Harvested(cakeAmount);
        MASTERCHEF.enterStaking(cakeAmount);
    }
}

function getReward() external override {
    uint256 amount = earned(msg.sender);
    uint256 shares = Math.min(amount.mul(totalShares).div(balance()), _shares[msg.sender]);
    totalShares = totalShares.sub(shares);
    _shares[msg.sender] = _shares[msg.sender].sub(shares);
    _cleanupIfDustShares();

    _withdrawTokenWithCorrection(amount);
    uint256 depositTimestamp = _depositedAt[msg.sender];
    uint256 performanceFee = canMint() ? _minter.performanceFee(amount) : 0;
    if (performanceFee > DUST) {
        uint256 convertedAssets = convert(performanceFee);
        _minter.mintFor(address(WBNB), 0, convertedAssets, msg.sender, depositTimestamp);
        amount = amount.sub(performanceFee);
    }

    CAKE.safeTransfer(msg.sender, amount);
    emit ProfitPaid(msg.sender, amount, performanceFee);

    _harvest();
}