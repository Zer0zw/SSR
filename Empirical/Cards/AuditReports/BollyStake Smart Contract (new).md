# Project Name
BollyStake Smart Contract (new)

# Description
1. Users will lose their token if calling a wrong “days” in relock_stake() 
    
    User A calls enter_stake(XXX, YYY), where XXX can be any amount of the token, and YYY is in range of [30,60,90,180,365,540,730]. For example: YYY can be 30 in this case.
    
    After 3 mins, user A got some XXX expired amount and user A wants to relock_stake(YYY). As stated in the code, relock_stake() function does not sanitize the days parameter, therefore, a user can put any numbers of days to the function, YYY can be any positive number. For instance, YYY can be 10 in this case.
    
    Unfortunately, the operation in line 1021 and 1022 turn his locked_amount to 0. As a result, user A cannot get those XXX back to his wallet, which also means that user A has no expired_stakes anymore and that XXX amount is added to the total_eligible_stakes forever. 
    
2. Users will lose their tokens if it’s transferred to another user. 
    
    Users will receive an equivalent amount of Bolly Stake token after staking their Bolly coins. Users can send their Bolly Stake tokens to other users on the network. Unfortunately, we've discovered that if users attempt or inadvertently transfer their Bolly Stake token to other users, their Bolly Stake token will be lost forever because the contract is not designed for transferring as described by the Auditee.

# Root Cause
```solidity
// Users will lose their token if calling a wrong “days” in relock_stake()
if (user_stake_info[s].expire < block.timestamp) {
	user_stake_info[s].locked_amount = 0;
}