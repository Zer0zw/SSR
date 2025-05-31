# Project Name
GolduckDAO

# Description
1. Duplicate Reward Tokens
    
    The function `removeRewardToken` removes a token from the reward distribution. The contract overrides the token's value with the last element of the `rewardAsset` array. The contract does not remove the last element after this action. As a result, the last element of the array will have more than one instance in the array.

# Root Cause
```solidity
// Duplicate Reward Tokens
uint8 index = _rewardInfo[rewardToken].index;
_rewardAsset[index] = _rewardAsset[totalRewardDistributor - 1];
_rewardInfo[_rewardAsset[totalRewardDistributor - 1]].index = index;