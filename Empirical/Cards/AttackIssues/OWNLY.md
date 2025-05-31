# Project Name
OWNLY

# Description
The staking contract contains a critical error, allowing for a staker to unstake unlimited amount of time, draining tokens from the contract. Specifically, the unstake() function does not check if a staker has unstaked already, and/or update the staking amount of the caller, allowing any staker to unstake unlimited number of times, up to the total staking balance of the contract.

# Root Cause
```solidity
function unstake(uint _idToStakingItem) public virtual {
    require(msg.sender == idToStakingItem[_idToStakingItem].account, "Staking item doesn't belong to this account.");
    idToStakingItem[_idToStakingItem].isWithdrawnWithoutMinting = true;

    IERC20Upgradeable stakingTokenContract = IERC20Upgradeable(stakingTokenAddress);
    stakingTokenContract.transfer(idToStakingItem[_idToStakingItem].account, idToStakingItem[_idToStakingItem].amount);
}