# Project Name
Bitbook Staking Smart Contracts  V2

# Description
1. Insufficient check in the canHarvest() function
    
    The canHarvest() always returns true even if the _pid and _user do not exist, which means that the function does not validate the _pid and _user variables. Therefore, the block.timestamp is always greater than user.nextHarvestUntil (whereby the nextHarvestUntil = 0, if the _user is invalid)
    
2. Centralization Risk
    
    The role owner has the authority to update the critical settings:
    
    - set()
    - setLockDeposit()

# Root Cause
```solidity
// Insufficient check in the canHarvest() function
function canHarvest(uint256 _pid, address _user) public view returns (bool) {
    UserInfo storage user = userInfo[_pid][_user];
    return block.timestamp >= user.nextHarvestUntil;
}

// Centralization Risk
function setLockDeposit(uint256 pid, bool locked) external onlyOwner {
    poolInfo[pid].lockDeposit = locked;
    emit DepositLocked(pid, locked);
}

function set(
    uint256 _pid,
    uint256 _tokenPerBlock,
    uint16 _depositFeeBP,
    uint256 _minDeposit,
    uint256 _harvestInterval
) external onlyOwner {
    require(_depositFeeBP <= 10000, "BITBOOK_STAKING: invalid deposit fee basis points");
    require(_harvestInterval <= MAXIMUM_HARVEST_INTERVAL, "BITBOOK_STAKING: invalid harvest interval");

    poolInfo[_pid].tokenPerBlock = _tokenPerBlock;
    poolInfo[_pid].depositFeeBP = _depositFeeBP;
    poolInfo[_pid].minDeposit = _minDeposit;
    poolInfo[_pid].harvestInterval = _harvestInterval;

    emit PoolUpdated(_tokenPerBlock, _depositFeeBP, _minDeposit, _harvestInterval);
}