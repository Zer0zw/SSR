# Project Name
Penpie

# Description
The root cause is the introduction of an evil market that was used to inflates the staking balance to claim unwarranted rewards.

# Root Cause
```solidity

/**
 * @notice redeems the user's reward
 * @return amount of reward token redeemed, in the same order as `getRewardTokens()`
 */
function redeemRewards(address user) external nonReentrant returns (uint256[] memory) {
    return _redeemRewards(user);
}

/**
 * @dev Since rewardShares is based on activeBalance, user's activeBalance must be updated AFTER
    rewards is updated
 * @dev It's intended to have user's activeBalance updated when rewards is redeemed
 */
function _redeemRewards(address user) internal virtual returns (uint256[] memory rewardsOut) {
    _updateAndDistributeRewards(user);
    _updateUserActiveBalance(user);
    rewardsOut = _doTransferOutRewards(user, user);
    emit RedeemRewards(user, rewardsOut);
}

/// @dev this function doesn't need redeemExternal since redeemExternal is bundled in updateRewardIndex
/// @dev this function also has to update rewardState.lastBalance
function _doTransferOutRewards(
    address user,
    address receiver
) internal virtual override returns (uint256[] memory rewardAmounts) {
    address[] memory tokens = _getRewardTokens();
    rewardAmounts = new uint256[](tokens.length);
    for (uint256 i = 0; i < tokens.length; i++) {
        rewardAmounts[i] = userReward[tokens[i]][user].accrued;
        if (rewardAmounts[i] != 0) {
            userReward[tokens[i]][user].accrued = 0;
            rewardState[tokens[i]].lastBalance -= rewardAmounts[i].Uint128();
            _transferOut(tokens[i], receiver, rewardAmounts[i]);
        }
    }
}