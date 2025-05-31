# Project Name
Cake Panda

# Description
1. Unstake Lock Limitation
    
    The contract contains the `unStake` function, which includes a requirement that the `isLocked` attribute of a pool must be `true` to proceed with the unstaking process. However, there is no function or mechanism within the contract to alter the `isLocked` state. This oversight can lead to a situation where, if `isLocked` is initially set to `false`, users will be perpetually unable to unstake their assets. This rigidity can significantly impact the functionality and user experience of the contract, potentially leading to user dissatisfaction and trust issues, especially in scenarios where the unlocking of funds is expected to be a flexible and user-controlled process.
    
2. Incorrect Tax Handling
    
    The contract is currently implementing a staking mechanism where it transfers the staked amount from the sender to the contract, deducting the `stakeFee`. However, there is an issue with how the contract handles the `taxAmount`. After receiving the staked amount (minus the stakeFee), the contract then transfers the `taxAmount` from its own balance to a specific address. This implementation results in the contract itself bearing the cost of the `taxAmount`, rather than deducting it from the user's staked amount. This approach is inconsistent with typical staking mechanisms where the user is expected to cover any associated fees or taxes.

# Root Cause
```solidity
// Unstake Lock Limitation
function unStake(uint256 _poolId) external {
    Pool storage pool = pools[_poolId];
    StakedUser storage stakedUser = stakedUsers[_poolId][msg.sender];
    uint256 amount = stakedUser.amount;
    require(pool.isLocked, "can't UnStake");
...
}

// Incorrect Tax Handling
function stake(uint256 _poolId, uint256 _amount) external {
      require(_amount > 0, "Deposit amount can't be zero");
      Pool storage pool = pools[_poolId];
      StakedUser storage stakedUser = stakedUsers[_poolId][msg.sender];
      require(block.timestamp <= pool.stakedTime, "staking time expire");
      require(block.timestamp <= pool.rewardEnd, "pool ended");

      updatePoolRewards(_poolId);
      // Update current staked user
      uint taxAmount = _amount -
          ((_amount * (10000 - pool.stakeFee)) / 10000);
      stakedUser.amount =
          stakedUser.amount +
          ((_amount * (10000 - pool.stakeFee)) / 10000);
      stakedUser.rewardDebt =
          (stakedUser.amount * pool.accumulatedRewardsPerShare) /
          REWARDS_PRECISION;

      // Update pool
      pool.tokensStaked =
          pool.tokensStaked +
          ((_amount * (10000 - pool.stakeFee)) / 10000);

      // Deposit tokens
      emit Stake(msg.sender, _poolId, _amount);
      SafeERC20.safeTransferFrom(
          IERC20(pool.stakeToken),
          msg.sender,
          address(this),
          (_amount * (10000 - pool.stakeFee)) / 10000
      );
      // tax amount transfer to the marketing wallet
      SafeERC20.safeTransfer(
          IERC20(pool.stakeToken),
          0xd21d89F5b91C55A60f6533788ce3711Bd90B8A2C,
          taxAmount
      );
  }