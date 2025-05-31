# Project Name
0x v3 Staking

# Description
1. Anyone can remove a maker’s pending pool join status
    
    Using behavior described in [issue 5.6](https://diligence.consensys.io/audits/2019/10/0x-v3-staking/#recommendation-fix-weak-assertions-in-mixinstakingpool-stemming-from-use-of-nil_pool_id), it is possible to delete the *pending* join status of *any maker in any pool* by passing in `NIL_POOL_ID` to `removeMakerFromStakingPool`. Note that the attacker in the following example must not be a confirmed member of any pool:
    
    1. The attacker calls `addMakerToStakingPool(NIL_POOL_ID, makerAddress)`. In this case, `makerAddress` can be almost any address, as long as it has not called `joinStakingPoolAsMaker` (an easy example is `address(0)`). The key goal of this call is to increment the number of makers in pool 0:
        
        **code/contracts/staking/contracts/src/staking_pools/MixinStakingPool.sol:L262**
        
    2. The attacker calls `removeMakerFromStakingPool(NIL_POOL_ID, targetAddress)`. This function queries `getStakingPoolIdOfMaker(targetAddress)` and compares it to the passed-in pool id. Because the target is an unconfirmed maker, their staking pool id is `NIL_POOL_ID`:
        
        **code/contracts/staking/contracts/src/staking_pools/MixinStakingPool.sol:L166-L173**
        
    
    The check passes, and the target’s `_poolJoinedByMakerAddress` struct is deleted. Additionally, the number of makers in pool 0 is decreased:
    
    **code/contracts/staking/contracts/src/staking_pools/MixinStakingPool.sol:L176-L177**
    
    This can be used to prevent any makers from being confirmed into a pool.

# Root Cause
```solidity
// Anyone can remove a maker’s pending pool join status
_poolById[poolId].numberOfMakers = uint256(pool.numberOfMakers).safeAdd(1).downcastToUint32();

bytes32 makerPoolId = getStakingPoolIdOfMaker(makerAddress);
if (makerPoolId != poolId) {
    LibRichErrors.rrevert(LibStakingRichErrors.MakerPoolAssignmentError(
        LibStakingRichErrors.MakerPoolAssignmentErrorCodes.MakerAddressNotRegistered,
        makerAddress,
        makerPoolId
    ));
}

delete _poolJoinedByMakerAddress[makerAddress];
_poolById[poolId].numberOfMakers = uint256(_poolById[poolId].numberOfMakers).safeSub(1).downcastToUint32();