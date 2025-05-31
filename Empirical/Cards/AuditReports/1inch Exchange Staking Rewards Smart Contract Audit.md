# Project Name
1inch Exchange Staking Rewards Smart Contract Audit

# Description
Missing reentrancy protection

The `getReward` function did not make use of a modifier to protect against potential reentrancy attacks. If a token were to implement a callback (e.g. ERC-223 or ERC-777), the function could in theory be targeted through a reentrancy attack. However, as the checks-effects pattern was used the potential for exploitation was mitigated.

# Root Cause
```solidity
// Missing reentrancy protection
/// @notice Withdraws `msg.sender`'s reward
function getReward(uint i) public updateReward(msg.sender) {
    TokenRewards storage tr = tokenRewards[i];
    uint256 reward = tr.rewards[msg.sender];
    if (reward > 0) {
        tr.rewards[msg.sender] = 0;
        tr.gift.safeTransfer(msg.sender, reward);
        emit RewardPaid(i, msg.sender, reward);
    }
}