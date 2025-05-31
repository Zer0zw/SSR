# Project Name
Uwerx

# Description
1. Non-Guaranteed Reward
    
    The contract currently allows users to stake their tokens, and upon unstaking, they are supposed to receive a reward based on the staking APY. However, there is no guarantee that the reward amount will always be available in the contract's balance. This poses a risk where users may stake their tokens, but the reward amount could potentially be insufficient or even zero, leading to a situation where they cannot claim their rewards as expected.

# Root Cause
```solidity
// Non-Guaranteed Reward
function unstakeToken(uint256 plan, uint256 count) external nonReentrant{
    require(mapUserInfo[address(msg.sender)][plan][count].amount > 0, "Staking not found");
    require(mapUserInfo[address(msg.sender)][plan][count].claimStatus == false, "Already unstaked");
    require(mapUserInfo[address(msg.sender)][plan][count].endTime < block.timestamp, "Can't unstake before staking end period");
    
    uint256 amount = mapUserInfo[address(msg.sender)][plan][count].amount;
    uint256 APY = mapUserInfo[address(msg.sender)][plan][count].APY;
    uint256 reward = (amount * APY) / 10000;
    
    totalStaked -= amount;
    mapUserInfo[address(msg.sender)][plan][count].claimStatus = true;
    
    IERC20(stakedToken).safeTransfer(address(msg.sender), amount + reward);
    emit UNStake(address(msg.sender), amount + reward);
     
}