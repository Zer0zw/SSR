# Project Name
pSTAKE Finance

# Description
1. Reward rate changes are not taken into account in LP staking
    
    When users update their reward (e.g., by calling the `calculateRewards` function), the reward amount is calculated according to all reward rate changes after the last update. So it does not matter when and how frequently you update the reward; in the end, you’re going to have the same amount.
    
    On the other hand, we can’t say the same about the lp staking provided in the `StakeLPCoreV8` contract. The amount of these rewards depends on when you call the `calculateRewardsAndLiquidity` function, and the reward amount can even decrease over time.
    
    Two main factors lead to this:
    
    - Changes in the reward rate. If the reward rate is decreased at some point, it’s getting partially propagated to all the rewards there were not distributed yet. So the reward of the users that didn’t call the `calculateRewardsAndLiquidity` function may decrease. On the other hand, if the reward rate is supposed to increase, it’s better to wait and not call `calculateRewardsAndLiquidity` for as long as possible.
    - Not every liquidity provider will stake their LP tokens. When users provide liquidity but do not stake the LP tokens, the reward for these Stokens is still going to the Holder contract. These rewards getting proportionally distributed to the users that are staking their LP tokens. Basically, these rewards are added to the current reward rate but change more frequently. The same logic applies to that rewards; if you expect the unstaked LP tokens to increase, it’s in your interest not to withdraw your rewards. But if they are decreasing, it’s better to gather the rewards as early as possible.
2. The `withdrawUnstakedTokens` may run out of gas 
    
    The `withdrawUnstakedTokens` is iterating over all batches of unstaked tokens. One user, if unstaked many times, could get their tokens stuck in the contract.

# Root Cause
```solidity
// The withdrawUnstakedTokens may run out of gas 
function withdrawUnstakedTokens(address staker)
	public
	virtual
	override
	whenNotPaused
{
	require(staker == _msgSender(), "LQ20");
	uint256 _withdrawBalance;
	uint256 _unstakingExpirationLength = _unstakingExpiration[staker]
		.length;
	uint256 _counter = _withdrawCounters[staker];
	for (
		uint256 i = _counter;
		i < _unstakingExpirationLength;
		i = i.add(1)
	) {
		//get getUnstakeTime and compare it with current timestamp to check if 21 days + epoch difference has passed
		(uint256 _getUnstakeTime, , ) = getUnstakeTime(
			_unstakingExpiration[staker][i]
		);
		if (block.timestamp >= _getUnstakeTime) {
			//if 21 days + epoch difference has passed, then add the balance and then mint uTokens
			_withdrawBalance = _withdrawBalance.add(
				_unstakingAmount[staker][i]
			);
			_unstakingExpiration[staker][i] = 0;
			_unstakingAmount[staker][i] = 0;
			_withdrawCounters[staker] = _withdrawCounters[staker].add(1);
		}
	}

	require(_withdrawBalance > 0, "LQ21");
	emit WithdrawUnstakeTokens(staker, _withdrawBalance, block.timestamp);
	_uTokens.mint(staker, _withdrawBalance);
}