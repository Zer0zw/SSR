# Project Name
Woonkly

# Description
1. Miscalculated decrease value in rewards 
    
    In the contract woonklyPOS.sol the function _withdrawReward is expected to decrease the user rewards of certain token for the claiming amount, but instead the subtraction to the total is done two times, resulting in a miscalculated result.

# Root Cause
```solidity
	uint256 rew=rewarded( sc, account);
	uint256 remainder = rew. sub(amount); (1)
	if(remainder==0){
		_doreward(sc, account, 0);
	} else{
	require(_decreaseRewards( sc, account, remainder),"W0:e--");
	}