# Project Name
Quint

# Description
The root cause of the attack is when the `reStake` function is performed for reward re-staking, the reward amount time of LP tokens is not updated, resulting in the attacker being able to claim the issued rewards multiple times.

# Root Cause
```solidity
function reStake(uint256 _index) public {
    require(_index < 2, "Invalid index");
    uint256 preReward;
    if (_index == 0) {
        preReward = calculateTokenReward(msg.sender);
        if (preReward > 0) {
            token.transferFrom(distributor, address(this), preReward);
            stakeToken(msg.sender, preReward);
        }
    } else {
        preReward = calculateLpReward(msg.sender);
        if (preReward > 0) {
            token.transferFrom(distributor, address(this), preReward);
            stakeToken(msg.sender, preReward);
        }
    }

    emit RESTAKE(msg.sender, preReward);
}

function calculateLpReward(address _user)
    public
    view
    returns (uint256 _reward)
{
    LpStake storage userStake = lpStakeRecord[_user];
    uint256 rewardDuration = block.timestamp.sub(userStake.time);
    _reward = userStake.amount.mul(rewardDuration).mul(tokenReward).div(
        rewardDivider
    );
}

function calculateTokenReward(address _user)
    public
    view
    returns (uint256 _reward)
{
    TokenStake storage userStake = tokenStakeRecord[_user];
    uint256 rewardDuration = block.timestamp.sub(userStake.time);
    _reward = userStake.amount.mul(rewardDuration).mul(tokenReward).div(
        rewardDivider
    );
}

function stakeToken(address _user, uint256 _amount) private {
    User storage user = users[_user];
    TokenStake storage userStake = tokenStakeRecord[_user];
    userStake.amount = userStake.amount.add(_amount);
    userStake.time = block.timestamp;
    user.stakeCount++;
    user.totalStakedToken = user.totalStakedToken.add(_amount);
    totalStakedToken = totalStakedToken.add(_amount);
}

function stakeLp(address _user, uint256 _amount) private {
    User storage user = users[_user];
    LpStake storage userStake = lpStakeRecord[_user];
    userStake.lpAmount = userStake.lpAmount.add(_amount);
    userStake.amount = userStake.amount.add(getTokenForLP(_amount));
    userStake.time = block.timestamp;
    user.stakeCount++;
    user.totalStakedLp = user.totalStakedLp.add(_amount);
    totalStakedLp = totalStakedLp.add(_amount);
}
