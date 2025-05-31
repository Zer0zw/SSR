# Project Name
WrapStaking

# Description
The logic for calculating staking rewards, currentRewardsInRewardToken, in the contract depends on the token ratio within a single liquidity pool (comprising the project token WPS and BTCB). An attacker can manipulate the liquidity of this pool, thereby increasing their own rewards by more than 44,000 times.

# Root Cause
```solidity
function currentRewardsInRewardToken(address account)
    public
    view
    returns (uint256)
{
    uint256 reward = this.currentRewards(account);
    if (reward <= 0) {
        return 0;
    }

    return reward.mul(rewardTokenPriceInToken()).div(10**18);
}

function rewardTokenPriceInToken() public view returns (uint256) {
    (uint256 lpReserve0, uint256 lpReserve1, uint256 lpTimestamp) = _lp
    .getReserves();

    return
        (_tokenLpIndex == 0 ? lpReserve0 : lpReserve1).mul(10**18).div(
            _tokenLpIndex == 0 ? lpReserve1 : lpReserve0
        );
}

function harvest() external returns (uint256) {
    return _harvest(msg.sender, msg.sender);
}

function _harvest(
    address account,
    address receiver /*, bool force*/
) internal virtual returns (uint256) {
    UserData storage user = _userDatas[account];

    uint256 rewards = this.currentRewardsInRewardToken(account);
    user.lastResetTime = block.timestamp;

    if (rewards <= 0) {
        return 0;
    }

    /*if (!force) {
        require(
            user.lastBlockHarvested.add(2) <= block.number,
            "Harvest only allowed every 2 block"
        );
    }*/

    _rewardToken.transfer(receiver, rewards);
    user.lastTimeHarvested = block.timestamp;
    user.lastBlockHarvested = block.number;
    user.totalHarvested = user.totalHarvested.add(rewards);

    emit Harvest(account, receiver, rewards);
    return rewards;
}