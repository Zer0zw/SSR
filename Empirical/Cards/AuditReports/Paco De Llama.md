# Project Name
Paco De Llama

# Description
1. Possible Unstakeable Amount
    
    The owner has the authority to stop users from unstaking. The owner may take advantage of this by calling the `setStakeTime` function with a large value.
    
2. Non-Guaranteed Rewards
    
    The contract's staking reward calculation formula is heavily dependent on the `dailyROI` variable. The owner has authority to manipulate this variable without restrictions. Hence, if the owner assigns the value of zero to the variable, the users will not receive any rewards.
    
3. Inaccurate Reward Calculation
    
    The contract has an issue in the `calculateEarnings` function where it determines the number of staking days for a user based on the timestamp. When a user stakes, the `lastClock` variable is set to the beginning of the day (00:00). This setup means that a user who stakes near the end of the day can withdraw a full day's worth of rewards after just a few minutes, as the contract calculates an active day. This behavior can lead to unintended gains for users who stake at the end of the day.

# Root Cause
```solidity
// Possible Unstakeable Amount
require(block.timestamp - timeOfStake[msg.sender] > stakeTime, "You need to stake for the minimum amount of days");

// Non-Guaranteed Rewards
function calculateEarnings(address _stakeholder) public view returns(uint256) {
    uint256 activeDays = (block.timestamp - lastClock[_stakeholder]) / 86400;
    return (stakes[_stakeholder] * dailyROI * activeDays) / 10000;
}

function setDailyROI(uint256 _dailyROI) external onlyOwner() {
    dailyROI = _dailyROI;
}

// Inaccurate Reward Calculation
function calculateEarnings(address _stakeholder) public view returns(uint256) {
    uint256 activeDays = (block.timestamp - lastClock[_stakeholder]) / 86400;
    return (stakes[_stakeholder] * dailyROI * activeDays) / 10000;
}

uint256 remainder = (block.timestamp - lastClock[msg.sender]) % 86400;
lastClock[msg.sender] = block.timestamp - remainder;