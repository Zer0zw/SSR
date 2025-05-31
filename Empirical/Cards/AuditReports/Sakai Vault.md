# Project Name
Sakai Vault

# Description
1. Inconsistent Reward Calculation
    
    An incosistency is present in the `_stake` function, specifically in the logic that calculates and assigns rewards to referrers based on the staked amount. Specifically, for the second layer of referrers (referrerLayer2), the line `rewardsFromReferrer[referrerLayer2] += amountLayer1;` mistakenly adds the reward amount calculated for the first layer (amountLayer1) to the second layer referrer's reward (referrerLayer2). This is incorrect as per the intended logic of the function, which should add `amountLayer2` (the reward amount specifically calculated for the second layer) to referrerLayer2's rewards.
    
2. Potential Token Drain
    
    Function ****`_claimReward` is designed to allow users to claim their rewards. However, its implementation could lead to an unintended draining of token balance. Specifically, the function includes a conditional check `if(IERC20(tokenAddress).balanceOf(address(this)) >= amount)` to ensure the contract has enough tokens to fulfill the reward claim. If the balance of the tokens is not sufficient, the function execution stops without updating the user's claim records or emitting any event. However, the `_deductTaxClaimReward` function, called earlier in the flow, still processes and distributes taxes to the `addressStakingPool` and `addressVaultCapital`, regardless of the token balance.
    
    Repeated calls to ****`_claimReward` without sufficient balance could lead to continuous tax deductions and distributions, eventually draining the contract's tokens to the staking pool and vault capital addresses.
    
3. Duplicate Reward Amount Addition
    
    Function `_calculateReward` is responsible for the calculation of pending rewards. At the beginning of the function, `rewardAmount` is initially added to `pendingCalculateReward`. However, if the criteria for immediate reward distribution are not met, the function falsely adds the `rewardAmount` to `pendingCalculateReward` a second time towards the end. This duplication in adding the `rewardAmount` leads to an inflated total of pending rewards, which can disrupt the accurate calculation of dividends for shareholders and the overall reward distribution mechanism.
    
4. Potential Underflow Calculation
    
    A potential underflow risk is present in the implementation of the `_setShare` function. The function's current logic involves reducing `totalShares` by an account's stake amount when the account's stake does not qualify for rewards. In scenarios where the stake amounts are modest relative to `totalShares`, this reduction can lead to a significantly lowered `totalShares` value. Subsequent unstaking actions, which subtract the unstaked amount from `totalShares`, could then result in an underflow.

# Root Cause
```solidity
// Inconsistent Reward Calculation
/** layer 2 referrer */
address referrerLayer2 = referrers[referrerLayer1];
if(referrerLayer2 != address(0)){
    uint256 amountLayer2 = amount * percentDistributionForReferrerLayer2 / percentDenominator;
    rewardsFromReferrer[referrerLayer2] += amountLayer1;
    referrerPendingAmount[referrerLayer2] += amountLayer2;
    referrerTotalAmountByAccount[account][referrerLayer2] += amountLayer2;
    totalAccumulateReferrerAmount += amountLayer2;
    totalPendingReferrerAmount += amountLayer2;
}

// Potential Token Drain
function _claimReward(address account) internal {
    /** this function for claim reward */
    require(account != address(0), "SakaiDAO: account is the zero address");
    require(shares[account].amount > 0, "SakaiDAO: account is not stake");
    uint256 originalAmount = dividendOf(account);
    uint256 amount = _deductTaxClaimReward(originalAmount);
    if(IERC20(tokenAddress).balanceOf(address(this)) >= amount){
        IERC20(tokenAddress).transfer(account, amount);
        _setClaimed(account, originalAmount);
    }
}

// Duplicate Reward Amount Addition
function _calculateReward(uint256 rewardAmount) internal {
    /** this function for calculate reward and count dividendsPerShare */
    pendingCalculateReward += rewardAmount;

    if(totalShares > 0 && (lastResetEpochAt + resetEpochEvery <= block.timestamp)){
        uint256 amount = pendingCalculateReward;
        totalDividends += amount;
        dividendsPerShare += (dividendsPerShareAccuracyFactor * amount / totalShares);

        currentEpoch++;
        lastResetEpochAt = block.timestamp;
        pendingCalculateReward = 0;
    } else {
        pendingCalculateReward += rewardAmount;
    }
}

// Potential Underflow Calculation
function _setShare(address account, uint256 amount) internal {
    /** this function for set shares balance */

    if(amount > 0 && shares[account].amount == 0){
        // if amount > 0 then add shareholder
        _addShareholder(account);
    } else if(amount == 0 && shares[account].amount > 0){
        // if amount = 0 then remove shareholder
        _removeShareholder(account);
    }

    /** Update shares balance */
    totalShares = totalShares - shares[account].amount + amount;
    shares[account].amount = amount;
    shares[account].totalExcluded = _getCumulativeDividend(shares[account].amount);
    shares[account].lastDepositTimestamp = block.timestamp;
    shares[account].lastDepositEpoch = currentEpoch;

    // get current epoch from vote contract for prevent user voting on running epoch
    shares[account].lastEpochNumberWhenDeposit = voteAddress != address(0) ? ITokenVote(voteAddress).getCurrentEpoch() : 0;

    if(shares[account].amount >= minimumStakeForGetReward){
        shares[account].isReceiveReward = true;
    } else {
        shares[account].isReceiveReward = false;
        totalShares = totalShares - shares[account].amount;
    }
}