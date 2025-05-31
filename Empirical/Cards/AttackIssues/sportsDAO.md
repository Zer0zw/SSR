# Project Name
sportsDAO

# Description
The logic for calculating Staking Reward in the contract relies on the variable `LPInstance.balanceOf(address(this))`; however, this variable can be modified by the external function `withdrawTeam` within the contract, potentially allowing an attacker to gain excessive profits.

# Root Cause
```solidity
function getPerTokenReward() public view returns(uint) {
    if ( LPInstance.balanceOf(address(this)) == 0) {
        return 0;
    }

    uint newPerTokenReward = (totalStakeReward - lastTotalStakeReward) * 1e18 / LPInstance.balanceOf(address(this));
    return PerTokenRewardLast + newPerTokenReward;
}

function pendingToken(address account) public view returns(uint) {
    return
    userLPStakeAmount[account]
        * (getPerTokenReward() - userRewardPerTokenPaid[account]) 
        / (1e18)
        + (userRewards[account]);
}

function getReward() public updateReward(msg.sender) {
    uint _reward = pendingToken(_msgSender());
    require(_reward > 0, "sDAOLP stake Reward is 0");
    userRewards[_msgSender()] = 0;
    if (_reward > 0) {
        _standardTransfer(address(this), _msgSender(), _reward);
        return ;
    }
}

...

function withdrawTeam(address _token) external {
    IERC20(_token).transfer(TEAM, IERC20(_token).balanceOf(address(this)));
    payable(TEAM).transfer(address(this).balance);
}