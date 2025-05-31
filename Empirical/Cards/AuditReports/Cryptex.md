# Project Name
Cryptex

# Description
1. Multiple invocations of `stake()`
    
    If `stake()` is called multiple times for the same `delegator_`, user may be unable to withdraw previous stakes before the last `block.timestamp + waitTime`.

# Root Cause
```solidity
/**
* @notice Stakes to delegator_ the amount_ specified
* @param delegator_ contract address where to send the amount_
* @param amount_ uint to be staked and delegated
* @dev Delegator must be valid and amount has to be greater than 0
* @dev amount_ is transferred to the delegator contract and staker starts earning rewards if active
* @dev updates rewards on call
*/
function stake(address delegator_, uint256 amount_)
  external
  nonReentrant
  updateReward(msg.sender)
{
  require(delegators[delegator_], "Not a valid delegator");
  require(amount_ > 0, "Amount must be greater than 0");
  _totalSupply = _totalSupply.add(amount_);
  _balances[msg.sender] = _balances[msg.sender].add(amount_);
  Delegator d = Delegator(delegator_);
  d.stake(msg.sender, amount_);
  stakerWaitTime[msg.sender][delegator_] = block.timestamp + waitTime;
  IGovernanceToken(stakingToken).transferFrom(
     msg.sender,
     delegator_,
     amount_
  );
  emit Staked(delegator_, msg.sender, amount_);
}