# Project Name
Deus_Finance_Staking_Contracts

# Description
Functions on DEAStaking.sol (setShares, setRewardPerBlock`,setWallets) are callable only from one address if the private key of this address becomes compromised rewards can be changed and this may lead to undesirable consequences. 

# Root Cause
```solidity
function setWallets(address _daoWallet, address _earlyFoundersWallet) public onlyOwner {
    daoWallet = _daoWallet;
    earlyFoundersWallet = _earlyFoundersWallet;
}

function setShares(uint256 _daoShare, uint256 _earlyFoundersShare) public onlyOwner {
    withdrawParticleCollector();
    daoShare = _daoShare;
    earlyFoundersShare = _earlyFoundersShare;
}

function setRewardPerBlock(uint256 _rewardPerBlock) public onlyOwner {
    update();
    emit RewardPerBlockChanged(rewardPerBlock, _rewardPerBlock);
    rewardPerBlock = _rewardPerBlock;
}