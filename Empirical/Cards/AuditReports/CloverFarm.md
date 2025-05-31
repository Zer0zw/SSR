# Project Name
CloverFarm

# Description
1. Inconsistent Reward Distribution
    
    The contract features a staking flow with a reward mechanism that allows users to claim ETH from the `CloverPot` contract if they stake with a 2-hour delay between stakes. However, the current implementation results in inconsistent reward distribution. Users may claim varying amounts of ETH, including potentially receiving no reward or receiving a substantial amount of ETH.

# Root Cause
```solidity
// Inconsistent Reward Distribution
cloverPot.update(block.timestamp, msg.sender);

if (_time - moment >= DELAY_TIME) 
    getReward(lastUser);

function getReward(address _user) private {
    emit GetReward(_user, address(this).balance);
    histories.push(History(_user, address(this).balance, block.timestamp));
    payable(_user).transfer(address(this).balance);
}