# Project Name
Delabs Adventure Pass Staking

# Description
1. Centralization Risks in DelabsAdventurePassStaking.sol
    
    In the contract **`DelabsAdventurePassStaking`** the role **`_owner`** has authority over the functions shown in the diagram below.
    
    Any compromise to the **`_owner`** account may allow the hacker to take advantage of this authority and:
    
    - function **`forceBatchUnstake()`**: to force unstaking a batch of NFTs regardless of the locked period, and still keep the level.
    - function **`setTokenLevel()`**: to set the level for an NFT at will.
    - function **`setAdventurePassContract()`**: to set the **`adventurePass`** address.
    - function **`setStakingLevels()`**: to set the levels regarding a batch of the locking periods.
    - function **`upsertStakingLevel()`**: to set the level regarding one locking period.
    - function **`pauseStaking()`**: to pause the staking.
    - function **`unpauseStaking()`**: to unpause the staking.
2. Logical issue about the `lock`
    
    The **`lock()`** function allows adding a new **`lockedPeriod`** when the previous **`lockedPeriod`** has expired. However, the current implementation only replaces the old **`lockedPeriod`** with the new one while keeping the **`startTime`** unchanged, without taking into account the previous **`lockedPeriod`**. To correctly implement this feature, the new **`lockedPeriod`** should be added to the existing **`stakingPosition`**, that is, using the expression **`stakingPosition.lockedPeriod += lockedPeriod`** to replace the following implementations in the **`_lock`** function:

# Root Cause
```solidity
// Centralization Risks in DelabsAdventurePassStaking.sol
// @dev Force unstake one or more tokens (skips contract pause and locked periods)
function forceBatchUnstake(uint256[] calldata tokenIds) external onlyOwner {

    uint256 tokenLen = tokenIds.length;

    for(uint256 i; i < tokenLen; i++) {
        _forceUnstake(tokenIds[i]);
    }
}

// @dev Set level of given token
function setTokenLevel(uint256 tokenId, uint16 level) external onlyOwner {
    Position storage stakingPosition = stakingPositions[tokenId];
    stakingPosition.level = level;

    emit TokenLevelSet(tokenId, level);
}

// @dev Set the adventure pass contract address
function setAdventurePassContract(address adventurePassAddress) external onlyOwner {
    adventurePass = IDelabsAdventurePass(adventurePassAddress);

    emit AdventurePassContractChanged(adventurePassAddress);
}

// @dev Set available staking levels by locked periods
function setStakingLevels(uint40[] calldata lockedPeriods, uint16[] calldata levels) external onlyOwner {
    uint256 arrLength = lockedPeriods.length;

    for(uint256 i; i < arrLength; i++ ) {
        stakingLevels[lockedPeriods[i]] = levels[i];
    }

    emit StakingLevelsUpdated();
}

// @dev Upsert one staking level by locked period
function upsertStakingLevel(uint40 lockedPeriod, uint16 level) external onlyOwner {
    stakingLevels[lockedPeriod] = level;

    emit StakingLevelsUpdated();
}

// @dev Pause staking
function pauseStaking() external onlyOwner {
    _pause();
}

// @dev Unpause staking
function unpauseStaking() external onlyOwner {
    _unpause();
}

// Logical issue about the lock
function _lock(address holder, uint256 tokenId, uint40 lockedPeriod) internal {
    ...
    stakingPosition.lockedPeriod = lockedPeriod; // convert to seconds
    ...
}