# Project Name
JokInTheBoxETH

# Description
In the contract's `unstake` function, there is no verification of the state variable `stakes[msg.sender][stakeIndex].unstaked` to check whether the tokens have already been unstaked. An attacker can exploit this by repeatedly calling the `unstake` function to continuously receive project tokens.

# Root Cause
```solidity
/**
* @dev Allows a user to withdraw staked funds
* @param stakeIndex The index of the stake being withdrawn.
*/
function unstake(uint256 stakeIndex) external {
    require(stakeIndex < stakes[msg.sender].length, "Invalid stake index!");
    Stake memory currentStake = stakes[msg.sender][stakeIndex];

    uint256 currentDay = getCurrentDay();

    require(currentDay > currentStake.stakedDay + currentStake.lockPeriod, "Lock period has not finalized!");
    stakes[msg.sender][stakeIndex].unstaked = true;
    stakes[msg.sender][stakeIndex].unstakedDay = currentDay;

    totalStaked -= currentStake.amountStaked;
    // Transfer back staked amount
    require(jokToken.transfer(msg.sender, currentStake.amountStaked), "Token transfer failed!");

    emit Unstake(msg.sender, currentStake.amountStaked, block.timestamp, currentStake.lockPeriod, stakeIndex);

}