# Project Name
GSPI Club-project3

# Description
If there is no reward sent to the contract with the addReward function, the contract runs out of balance and locks user’s staked SPI. There is no function to check if the contract has balance to pay-out rewards. There is no guarantee for getting back staked tokens.

# Root Cause
```solidity
// Add reward to the smart contract (must have approval)
function addReward(uint256 _amount) external {
	spiToken.transferFrom(msg.sender, address(this), _amount);
	emit RewardAdded(_amount);
}