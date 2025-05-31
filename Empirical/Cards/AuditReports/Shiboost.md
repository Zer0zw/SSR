# Project Name
Shiboost

# Description
1. Non-Guaranteed Reward
    
    The contract does not guarantee the users will get their rewards. The deposited amounts are transferred to the contract's balance, but the claimable rewards are transferred to the users from the `Reserve` contract. Additionally, the owner has the authority to claim all the reward funds from the `Reserve` contract.

# Root Cause
```solidity
// Non-Guaranteed Reward
function emergencyAdminWithdraw(uint256 _pid) external onlyOwner {
    PoolInfo storage pool = poolInfo[_pid];
    uint256 balanceToWithdraw = pool.rewardToken.balanceOf(address(this));
    require(balanceToWithdraw != 0, "STAKING: Not enough balance to withdraw!");
    pool.rewardToken.transfer(owner(), balanceToWithdraw);
    rewardReserve.safeTransfer(pool.rewardToken, owner(), pool.rewardToken.balanceOf(address(rewardReserve)));
    emit AdminEmergencyWithdraw(_pid, pool.rewardToken.balanceOf(address(this)), pool.accTokenPerShare, pool.tokenPerBlock, pool.lastRewardBlock);
    delete poolInfo[_pid];
}