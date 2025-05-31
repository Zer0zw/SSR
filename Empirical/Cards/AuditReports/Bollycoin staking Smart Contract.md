# Project Name
Bollycoin staking Smart Contract

# Description
1. No access control on removeStakeholder & addStakeholder function 
    
    There is no access control on the removeStakeholder & addStakeholder function. So users can remove other users from the stakeholders array. This means at the time of reward distribution any user can front-run and remove others from the stakeholders array and claim 100% of the rewards.
    
    Someone can also use these functions to fill the stakeholder array to a length such that transactions adding/removing more stakeholder will exceed the block gas limit. Such a scenario is very rare, but still it is possible to do so. 
    
2. Reward distribution is controlled by the owner 
    
    The reward distribution is controlled by the owner. This means that the owner might not give out the rewards according to the agreement, or the amount might not be correct. 
    
3. User’s locked_amount is not decreased when removing stake 
    
    The user’s locked_amount should be decreased when removing the stake. But in the remove_stake() function, the locked_amount value of the user is not changed.
    
    It does not have any serious security issues but should be fixed as leaves the following require statement(one line #888) useless :
    
    _share <= users[msg.sender].locked_amount

# Root Cause
```solidity
// No access control on removeStakeholder & addStakeholder function
function removeStakeholder(address _stakeholder) public
{
	(bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);if(_isStakeholder){
	stakeholders[s] = stakeholders[stakeholders.length - 1];stakeholders.pop();
}

function addStakeholder(address _stakeholder) public
{
	(bool _isStakeholder, ) = isStakeholder(_stakeholder);if(!_isStakeholder) stakeholders.push(_stakeholder);
}

// Reward distribution is controlled by the owner
function distributeRewards(uint amount) public {
	uint256 allowance = usdt.allowance(msg.sender, address(this));require(amount > 0, "Nothing to distribute");
	require(msg.sender == owner, "Caller is not authorised");require(allowance >= amount, "Check the USDT allowance");
	usdt.transferFrom(owner,address(this),amount);
	for (uint256 s = 0; s < stakeholders.length; s += 1){
		address stakeholder = stakeholders[s];
		uint256 stakeof = stakeOf(stakeholder);
		uint256 totalstakes = total_eligible_Stakes();
		if(users[stakeholder].expire > block.timestamp) {
			uint256 reward = (stakeof.mul(amount)).div(totalstakes);
			// Transfer the usdt
			usdt.transfer(stakeholder, reward);
		}
	}
}

// User’s locked_amount is not decreased when removing stake
function remove_stake(uint256 _share) public {
	require( (users[msg.sender].expire < block.timestamp) && (_share <=users[msg.sender].locked_amount) ,"Please wait 365 days until removingstake");
	_burn(msg.sender, _share);
	stakes[msg.sender] = stakes[msg.sender].sub(_share);
	if(stakes[msg.sender] == 0) removeStakeholder(msg.sender);
	BOLLY.transfer(msg.sender, _share);
}