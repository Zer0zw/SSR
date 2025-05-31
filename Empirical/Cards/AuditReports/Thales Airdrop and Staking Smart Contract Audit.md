# Project Name
Thales Airdrop and Staking Smart Contract Audit

# Description
1. Unstaking does not account for cooldown period
    
    As per the Thales Tokenomics documentation, unstaking was subject to a cooldown period of 7 days (configurable by the contract owner). Stakers could call `startUnstaking()` to begin the cooldown period, during which no rewards would be received, and should only call `unstake()` after the cooldown period had elapsed to complete unstaking. However, `unstake()` did not include a check that the cooldown period had elapsed, and could be called immediately after `startUnstaking()`, rendering the cooldown period irrelevant.
    
2. Reentrancy guard prevents additional staking under certain conditions
    
    If a user has any claimable rewards and tries to stake additional tokens, the transaction would reverts since both the claim function and the stake function have a reentrancy guard. In this scenario, the reentrancy guard is locked on the first call to the `stake` function, which prevents any calls to other `nonReentrant` functions until the `stake` function has finished executing. A user can continue staking if the `claimEnabled` flag is disabled by the contract admin.
    
3. Restaking fails under certain conditions
    
    If a user unstaked while reward claiming was disabled, they would not be able to restake in a later period while reward claiming was enabled. This is because `stake(...)` would call `claimReward()`, which would revert as the user would have no staked balance.

# Root Cause
```solidity
// Unstaking does not account for cooldown period
function startUnstake() external {
    require(msg.sender != address(0), "Invalid address");
    require(
        _lastUnstakeTime[msg.sender] < block.timestamp.sub(unstakeDurationPeriod),
        "Already initiated unstaking cooldown"
    );
    if (_lastRewardsClaimedWeek[msg.sender] < weeksOfStaking) {
        claimReward();
    }
    _lastUnstakeTime[msg.sender] = block.timestamp;
    emit UnstakeCooldown(msg.sender, _lastUnstakeTime[msg.sender].add(unstakeDurationPeriod));
}

function unstake() external {
    require(msg.sender != address(0), "Invalid address");
    require(
        _lastUnstakeTime[msg.sender] < block.timestamp.sub(unstakeDurationPeriod),
        "Cannot stake, the staker is paused from staking due to unstaking"
    );
    //Lose the pending stake
    _pendingStake[msg.sender] = 0;
    _totalEscrowedAmount = _totalEscrowedAmount.sub(_escrowedBalances[msg.sender]);
    _escrowedBalances[msg.sender] = 0;
    _totalStakedAmount = _totalStakedAmount.sub(_stakedBalances[msg.sender]);
    uint unstakeAmount = _stakedBalances[msg.sender];
    _stakedBalances[msg.sender] = 0;
    stakingToken.transfer(msg.sender, unstakeAmount);
    emit Unstaked(msg.sender, unstakeAmount);
}

// Reentrancy guard prevents additional staking under certain conditions
// Restaking fails under certain conditions
function stake(uint amount) external nonReentrant notPaused {
    require(startTimeStamp > 0, "Staking period has not started");
    require(amount > 0, "Cannot stake 0");
    require(
        _lastUnstakeTime[msg.sender] < block.timestamp.sub(unstakeDurationPeriod),
        "Cannot stake, the staker is paused from staking due to unstaking"
    );
    // Check if there are not claimable rewards from last week.
    // Claim them, and add new stake
    if (_lastRewardsClaimedWeek[msg.sender] < weeksOfStaking) {
        claimReward();
    }
    _totalStakedAmount = _totalStakedAmount.add(amount);
    _stakedBalances[msg.sender] = _stakedBalances[msg.sender].add(amount);
    _lastStakingWeek[msg.sender] = weeksOfStaking;
    stakingToken.safeTransferFrom(msg.sender, address(this), amount);
    emit Staked(msg.sender, amount);
}