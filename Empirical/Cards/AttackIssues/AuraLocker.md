# Project Name
AuraLocker

# Description
There is a potential overflow in the rewards calculations which would lead to `updateReward()` always reverting.

The impact of this overflow is that all reward tokens will be permanently locked in the contract. User's will be unable to call any of the functions which have the `updateReward()` modifier, that is:

- `lock()`
- `getReward()`
- `_processExpiredLocks()`
- `_notifyReward()`

As a result the contract will need to call `shutdown()` and the users will only be able to receive their staked tokens via `emergencyWithdraw()`, which does not transfer the users the reward tokens.

Note that if one reward token overflows this will cause a revert on all reward tokens due to the loop over reward tokens.

# Root Cause
```solidity
modifier updateReward(address _account) {
    {
        Balances storage userBalance = balances[_account];
        uint256 rewardTokensLength = rewardTokens.length;
        for (uint256 i = 0; i < rewardTokensLength; i++) {
            address token = rewardTokens[i];
            uint256 newRewardPerToken = _rewardPerToken(token);
            rewardData[token].rewardPerTokenStored = newRewardPerToken.to96();
            rewardData[token].lastUpdateTime = _lastTimeRewardApplicable(rewardData[token].periodFinish).to32();
            if (_account != address(0)) {
                userData[_account][token] = UserData({
                    rewardPerTokenPaid: newRewardPerToken.to128(),
                    rewards: _earned(_account, token, userBalance.locked).to128()
                });
            }
        }
    }
    _;
}

// claim all pending rewards
function getReward(address _account) external {
    getReward(_account, false);
}

// Claim all pending rewards
function getReward(address _account, bool _stake) public nonReentrant updateReward(_account) {
    uint256 rewardTokensLength = rewardTokens.length;
    for (uint256 i; i < rewardTokensLength; i++) {
        address _rewardsToken = rewardTokens[i];
        uint256 reward = userData[_account][_rewardsToken].rewards;
        if (reward > 0) {
            userData[_account][_rewardsToken].rewards = 0;
            if (_rewardsToken == cvxCrv && _stake && _account == msg.sender) {
                IRewardStaking(cvxcrvStaking).stakeFor(_account, reward);
            } else {
                IERC20(_rewardsToken).safeTransfer(_account, reward);
            }
            emit RewardPaid(_account, _rewardsToken, reward);
        }
    }
}

function _rewardPerToken(address _rewardsToken) internal view returns (uint256) {
    if (lockedSupply == 0) {
        return rewardData[_rewardsToken].rewardPerTokenStored;
    }
    return
        uint256(rewardData[_rewardsToken].rewardPerTokenStored).add(
            _lastTimeRewardApplicable(rewardData[_rewardsToken].periodFinish)
                .sub(rewardData[_rewardsToken].lastUpdateTime)
                .mul(rewardData[_rewardsToken].rewardRate)
                .mul(1e18)
                .div(lockedSupply)
        );
}

