# Project Name
Pythia

# Description
The smart contract code for `PythiaTokenStaking` contains a potential reentrancy vulnerability in the `claimRewards` function. The issue arises from the fact that `setupClaim`, an internal function, is called after `distributeRewards`, which can result in an external call to distribute rewards to the user. If the rewardToken's `safeTransfer` function (called in `claimRewards`) were to call back into the contract (e.g., due to a faulty or malicious token contract), this could be exploited to reenter the claimRewards function and potentially claim the rewards multiple times, or interact with the contract in an unintended way. 

# Root Cause
```solidity
function claimRewards() external {
    distributeRewards();
    uint256 rewardAmount = setupClaim(_msgSender());
    uint256 escrowedRewardAmount = rewardAmount * escrowPortion / 1e18;
    uint256 nonEscrowedRewardAmount = rewardAmount - escrowedRewardAmount;

    if(escrowedRewardAmount != 0 && address(escrowPool) != address(0)) {
        escrowPool.vestingLock(_msgSender(), escrowedRewardAmount);
    }

    // ignore dust
    if(nonEscrowedRewardAmount > 1) {
        rewardToken.safeTransfer(_msgSender(), nonEscrowedRewardAmount);
    }

    emit RewardsClaimed(_msgSender(), escrowedRewardAmount, nonEscrowedRewardAmount);
}

function setupClaim(address _account) internal returns (uint256) {
    uint256 redeemableShare = getRedeemablePayouts(_account);
    if (redeemableShare > 0) {
        withdrawnRewards[_account] = withdrawnRewards[_account] + redeemableShare;
        emit RewardsWithdrawn(_account, redeemableShare);
    }
    return redeemableShare;
}