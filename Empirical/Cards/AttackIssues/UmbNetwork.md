# Project Name
UmbNetwork

# Description
matters! The @UmbNetwork reward pools are drained at both @BNBCHAIN and @ethereum, leading to the ~$700K gain for the hacker! The hack is possible because of an unchecked underflow in withdraw() so that anyone can withdraw any amount even without any balance!

# Root Cause
```solidity
function _withdraw(uint256 amount,address user,address recipient)internal nonReentrantupdateReward(user) {
	require(amount !0，"Cannot withdraw ");
	// not using safe math, because there is no way to overflow if stake tokens not overflow
	totalSupply = totalSupply - amount;
	_balances[user] = _balances[user] - amount;
	//  not using safe transter, because we working with trusted tokens
	require(stakingToken,transfer(recipient, amount), "token transfer failed");
	emit Withdrawn(user, amount);
}