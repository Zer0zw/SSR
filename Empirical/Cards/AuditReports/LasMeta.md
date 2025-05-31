# Project Name
LasMeta

# Description
1. Potential Trapped NFTs
    
    The function `unLockNft()` is used to unlock all of the users' NFTs, while transferring each tokenId to the user. The function `unstake()` is used to remove the users' staking and transfer the accumulative reward tokens to the user. If the `unstake()` function is called before `unLockNft()` function, then the user will not be able to unlock his NFTs. The same thing can happen if the owner changes the `nftCollection` address. As a result, the NFTs will remain locked at the contract.
    
2. Reward Fund Sufficiency
    
    The function `addRewardToken()`, from our understanding, is intended to increase the reward tokens of the contract. However, the current implementation does not clearly define the mechanism for transferring the tokens. This raises concerns about the security and accuracy of token operations within the contract.

# Root Cause
```solidity
// Potential Trapped NFTs
delete userStaked[msg.sender][_id];
...
info storage userInfo = userStaked[msg.sender][_userStakeId];

// Reward Fund Sufficiency
function addRewardToken(uint256 _amount)
    external
    onlyOwner
{
    totalRewardTokenAmount += _amount;
}