# Project Name
TempleDAO

# Description
In the contract, the function `migrateStake`, which is used to migrate the Staking contract, does not verify the identity of the caller. Consequently, this function can be invoked by any account. An attacker created a malicious new staking contract and called the `migrateStake` function to transfer all staked tokens and staking rewards to the malicious contract.

# Root Cause
```solidity
/**
  * @notice For migrations to a new staking contract:
  *         1. User/DApp checks if the user has a balance in the `oldStakingContract`
  *         2. If yes, user calls this function `newStakingContract.migrateStake(oldStakingContract, balance)`
  *         3. Staking balances are migrated to the new contract, user will start to earn rewards in the new contract.
  *         4. Any claimable rewards in the old contract are sent directly to the user's wallet.
  * @param oldStaking The old staking contract funds are being migrated from.
  * @param amount The amount to migrate - generally this would be the staker's balance
  */
function migrateStake(address oldStaking, uint256 amount) external {
    StaxLPStaking(oldStaking).migrateWithdraw(msg.sender, amount);
    _applyStake(msg.sender, amount);
}

/**
  * @notice For migrations to a new staking contract.
  *         1. Withdraw `staker`s tokens to the new staking contract (the migrator)
  *         2. Any existing rewards are claimed and sent directly to the `staker`
  * @dev Called only from the new staking contract (the migrator).
  *      `setMigrator(new_staking_contract)` needs to be called first
  * @param staker The staker who is being migrated to a new staking contract.
  * @param amount The amount to migrate - generally this would be the staker's balance
  */
function migrateWithdraw(address staker, uint256 amount) external onlyMigrator {
    _withdrawFor(staker, msg.sender, amount, true, staker);
}

function _withdrawFor(
    address staker,
    address toAddress,
    uint256 amount,
    bool claimRewards,
    address rewardsToAddress
) internal updateReward(staker) {
    require(amount > 0, "Cannot withdraw 0");
    require(_balances[staker] >= amount, "Not enough staked tokens");

    _totalSupply -= amount;
    _balances[staker] -= amount;

    stakingToken.safeTransfer(toAddress, amount);
    emit Withdrawn(staker, toAddress, amount);
 
    if (claimRewards) {
        // can call internal because user reward already updated
        _getRewards(staker, rewardsToAddress);
    }
}