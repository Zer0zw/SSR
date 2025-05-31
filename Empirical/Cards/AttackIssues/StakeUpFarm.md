# Project Name
StakeUpFarm

# Description
The `unstakeSUF` function, which is used to unstake staked tokens in the contract, does not update the staking duration in a timely manner. As a result, the staking rewards remain greater than zero even after unstaking. An attacker can exploit this by repeatedly calling `unstakeSUF` to continuously claim staking rewards.

# Root Cause
```solidity
function unstakeSUF() external nonReentrant {
    require(
        block.timestamp >= startTime,
        "StakeUpFarm: Farming has not started yet"
    );
    uint256 _amount = investor[msg.sender].staked;
    require(
        SUF.allowance(msg.sender, address(this)) >= _amount,
        "Not enough SUF allowed"
    );
    uint256 rewardMINT = userRewardMINT(msg.sender);
    uint256 rewardSTAKE = userRewardSTAKE(msg.sender);
    uint256 totalReward = rewardMINT + rewardSTAKE;
    SUF.transfer(msg.sender, totalReward);
    SUF.transfer(msg.sender, ((100 - unstakeFee) * _amount) / 100);
    SUF.burnFrom(msg.sender, (_amount * unstakeFee) / 100);
    investor[msg.sender].staked = 0;
}

function userRewardMINT(address _user) public view returns (uint256) {
    uint256 _reward = (investor[_user].invested * MINTdaily) / 100 / 86400;
    uint256 _timePassed = block.timestamp - claimTimeMINT[_user].startTime;
    return checkBoost(_user, _reward * _timePassed);
}