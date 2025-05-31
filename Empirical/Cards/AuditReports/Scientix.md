# Project Name
Scientix

# Description
1. Centralized Control of State Variable 
    
    Critical state variables can be updated any time by the controlling authorities. Changes in these variables can cause impacts to the users, so the users should accept or be notified before these changes are effective.
    
    However, as the contract is not yet deployed, there is potentially no constraint to prevent the authorities from modifying these variables without notifying the users
    
2. Design Flaw in _updatePools() Function
    
    The _updatePools() function executes the pool.update(_ctx) function, which is a state modifying function for all added pools.  
    
    With the current design, the pools created with the createPool() function cannot be removed. They can only be disabled by setting the rewardWeight to 0. Even if a pool is disabled, the update() function for this pool is still called. Therefore, if new pools continue to be added to this contract, the _pools.length will continue to grow and this function will eventually be unusable due to excessive gas usage

# Root Cause
```solidity
// Centralized Control of State Variable
/// @dev Sets the governance.
///
/// This function can only called by the current governance.
///
/// @param _pendingGovernance the new pending governance.
function setPendingGovernance(address _pendingGovernance) external onlyGovernance {
  require(_pendingGovernance != address(0), "StakingPools: pending governance address cannot be 0x0");
  pendingGovernance = _pendingGovernance;

  emit PendingGovernanceUpdated(_pendingGovernance);
}

function setRewardRate(uint256 _rewardRate) external onlyGovernance {
  _updatePools();

  _ctx.rewardRate = _rewardRate;

  emit RewardRateUpdated(_rewardRate);
}  

/// @dev Creates a new pool.
///
/// The created pool will need to have its reward weight initialized before it begins generating rewards.
///
/// @param _token The token the pool will accept for staking.
///
/// @return the identifier for the newly created pool.
function createPool(IERC20 _token) external onlyGovernance returns (uint256) {
  require(tokenPoolIds[_token] == 0, "StakingPools: token already has a pool");

  uint256 _poolId = _pools.length();

  _pools.push(Pool.Data({
    token: _token,
    totalDeposited: 0,
    rewardWeight: 0,
    accumulatedRewardWeight: FixedPointMath.uq192x64(0),
    lastUpdatedBlock: block.number
  }));

  tokenPoolIds[_token] = _poolId + 1;

  emit PoolCreated(_poolId, _token);

  return _poolId;
}

/// @dev Sets the reward weights of all of the pools.
///
/// @param _rewardWeights The reward weights of all of the pools.
function setRewardWeights(uint256[] calldata _rewardWeights) external onlyGovernance {
  require(_rewardWeights.length == _pools.length(), "StakingPools: weights length mismatch");

  _updatePools();

  uint256 _totalRewardWeight = _ctx.totalRewardWeight;
  for (uint256 _poolId = 0; _poolId < _pools.length(); _poolId++) {
    Pool.Data storage _pool = _pools.get(_poolId);

    uint256 _currentRewardWeight = _pool.rewardWeight;
    if (_currentRewardWeight == _rewardWeights[_poolId]) {
      continue;
    }

    // FIXME
    _totalRewardWeight = _totalRewardWeight.sub(_currentRewardWeight).add(_rewardWeights[_poolId]);
    _pool.rewardWeight = _rewardWeights[_poolId];

    emit PoolRewardWeightUpdated(_poolId, _rewardWeights[_poolId]);
  }

  _ctx.totalRewardWeight = _totalRewardWeight;
}

// Design Flaw in _updatePools() Function
function _updatePools() internal {
	for (uint256 _poolId = 0; _poolId < _pools.length(); _poolId++) {
		Pool.Data storage _pool = _pools.get(_poolId);
		_pool.update(_ctx);
	}
}