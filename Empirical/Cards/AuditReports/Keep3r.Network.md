# Project Name
Keep3r.Network

# Description
1. Incorrect update of totalLiquidity 
    
    If user calls deposit() -> withdraw() -> getReward() then contract will incorrectly calculate totalLiquidity which will lead to incorrect calculations of rewards for users: StakingRewardsV3-1.sol#L342
    
2. Impossible withdraw for smart contract
    
    If any smart contract deposits NFT to StakingRewardsV3 it must have onERC721Received() function or withdraw() will always revert: StakingRewardsV3-1.sol#L256

# Root Cause
```solidity
// Incorrect update of totalLiquidity
modifier update(uint tokenId) {
    uint _rewardPerLiquidityStored = rewardPerLiquidity();
    uint _lastUpdateTime = lastTimeRewardApplicable();
    rewardPerLiquidityStored = _rewardPerLiquidityStored;
    lastUpdateTime = _lastUpdateTime;
    if (tokenId != 0) {
        (uint _reward, uint32 _secondsInside, uint _liquidity, uint _forfeited) = earned(tokenId);
        tokenRewardPerLiquidityPaid[tokenId] = _rewardPerLiquidityStored;
        rewards[tokenId] = _reward;
        forfeit += _forfeited;

        if (elapsed[tokenId].timestamp < _lastUpdateTime) {
            elapsed[tokenId] = time(uint32(_lastUpdateTime), _secondsInside);
        }

        uint _currentLiquidityOf = liquidityOf[tokenId];
        if (_currentLiquidityOf != _liquidity) {
            totalLiquidity -= _currentLiquidityOf;
            liquidityOf[tokenId] = _liquidity;
            totalLiquidity += _liquidity;
        }
    }
    _;
}

// Impossible withdraw for smart contract
function withdraw(uint tokenId) public update(tokenId) {
    _collect(tokenId);
    _withdraw(tokenId);
}

function _withdraw(uint tokenId) internal {
    require(owners[tokenId] == msg.sender);
    uint _liquidity = liquidityOf[tokenId];
    liquidityOf[tokenId] = 0;
    totalLiquidity -= _liquidity;
    owners[tokenId] = address(0);
    _remove(tokenIds[msg.sender], tokenId);
    nftManager.safeTransferFrom(address(this), msg.sender, tokenId);

    emit Withdraw(msg.sender, tokenId, _liquidity);
}