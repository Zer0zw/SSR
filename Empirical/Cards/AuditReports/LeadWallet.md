# Project Name
LeadWallet

# Description
1. No check for referrer address. 
    
    In registerAndStake() function, referrer address is taken as input from the user, the validity of which is not checked in the function which can be misused. Any address which is passed as referrer address collects referral rewards 
    
    Users can provide the address of LeadStake contract as referrer, or any fresh address which has never interacted with LeadStake contract. That address will accrue referral rewards but won’t be able to claim them which is entirely an unhandled scenario 
    
2. Too much Admin controls 
    
    The LeadStake contract has too many admin rights which can be misused intentionally or unintentionally, i.e. in the case where the admin's private key gets compromised. Admin has the right to change all crucial parameters of smart contract like stakingTaxRate, registrationTax, weeklyROI, unstakingTaxRate, minimumStakeValue and referralTaxAllocation.
    
    In a scenario, these unstaking taxes can be set too high so that the user won’t be able to claim back their Lead token stakes
    
3. Users cannot stake again within 7 days 
    
    Due to the time restrictions in the LeadStake smart contract’s stake() function, users cannot stake again within a seven days period. The developer comments mentions that this condition is used to introduce a delay between user’s last payout and stake but it also prevents users to stake again within 7 days 
    
4. No input checking in unstake() function
    
    The unstake() function in LeadStake.sol takes amount as an input parameter from the user. The validity of this variable is not checked in the function. In a case where the user supplies zero(0) as amount, this function behaves similar to withdrawEarnings() function. Since withdrawEarnings() is a separate dedicated function for claiming all earnings, the mentioned scenario is entirely unintentional.

# Root Cause
```solidity
// No check for referrer address.
/**
 * registers and creates stakes for new stakeholders
 * deducts the registration tax and staking tax
 * calculates refferal bonus from the registration tax and sends it to the _referrer if there is one
 * transfers LEAD from sender's address into the smart contract
 * Emits an {OnRegisterAndStake} event..
 */
function registerAndStake(uint _amount, address _referrer) external onlyUnregistered() whenActive() {
    //makes sure user is not the referrer
    require(msg.sender != _referrer, "Cannot refer self");
    //makes sure referrer is registered already
    require(registered[_referrer] || address(0x0) == _referrer, "Referrer must be registered");
    //makes sure user has enough amount
    require(IERC20(lead).balanceOf(msg.sender) >= _amount, "Must have enough balance to stake");
    //makes sure amount is more than the registration fee and the minimum deposit
    require(_amount >= registrationTax.add(minimumStakeValue), "Must send at least enough LEAD to pay registration fee.");
    //makes sure smart contract transfers LEAD from user
    require(IERC20(lead).transferFrom(msg.sender, address(this), _amount), "Stake failed due to failed amount transfer.");
    //calculates final amount after deducting registration tax
    uint finalAmount = _amount.sub(registrationTax);
    //calculates staking tax on final calculated amount
    uint stakingTax = (stakingTaxRate.mul(finalAmount)).div(1000);
    //conditional statement if user registers with referrer 
    if(_referrer != address(0x0)) {
        //increase referral count of referrer
        referralCount[_referrer]++;
        //add referral bonus to referrer
        referralRewards[_referrer] = (referralRewards[_referrer]).add(stakingTax);
    } 
    //register user
    registered[msg.sender] = true;
    //mark the transaction date
    lastClock[msg.sender] = now;
    //update the total staked LEAD amount in the pool
    totalStaked = totalStaked.add(finalAmount).sub(stakingTax);
    //update the user's stakes deducting the staking tax
    stakes[msg.sender] = (stakes[msg.sender]).add(finalAmount).sub(stakingTax);
    //emit event
    emit OnRegisterAndStake(msg.sender, _amount, registrationTax.add(stakingTax), _referrer);
}

// Too much Admin controls 
//sets the staking rate
function setStakingTaxRate(uint _stakingTaxRate) external onlyOwner() {
    stakingTaxRate = _stakingTaxRate;
}

//sets the unstaking rate
function setUnstakingTaxRate(uint _unstakingTaxRate) external onlyOwner() {
    unstakingTaxRate = _unstakingTaxRate;
}

//sets the daily ROI
function setDailyROI(uint _dailyROI) external onlyOwner() {
    dailyROI = _dailyROI;
}

//sets the registration tax
function setRegistrationTax(uint _registrationTax) external onlyOwner() {
    registrationTax = _registrationTax;
}

//sets the minimum stake value
function setMinimumStakeValue(uint _minimumStakeValue) external onlyOwner() {
    minimumStakeValue = _minimumStakeValue;
}


// Users cannot stake again within 7 days 
/**
 * creates stakes for already registered stakeholders
 * deducts the staking tax from _amount inputted
 * registers the remainder in the stakes of the sender
 * records the previous earnings before updated stakes 
 * Emits an {OnStake} event
 */
function stake(uint _amount) external onlyRegistered() whenActive() {
    //makes sure stakeholder does not stake below the minimum
    require(_amount >= minimumStakeValue, "Amount is below minimum stake value.");
    //makes sure stakeholder has enough balance
    require(IERC20(lead).balanceOf(msg.sender) >= _amount, "Must have enough balance to stake");
    //makes sure smart contract transfers LEAD from user
    require(IERC20(lead).transferFrom(msg.sender, address(this), _amount), "Stake failed due to failed amount transfer.");
    //calculates staking tax on amount
    uint stakingTax = (stakingTaxRate.mul(_amount)).div(1000);
    //calculates amount after tax
    uint afterTax = _amount.sub(stakingTax);
    //update the total staked LEAD amount in the pool
    totalStaked = totalStaked.add(afterTax);
    //adds earnings current earnings to stakeRewards
    stakeRewards[msg.sender] = (stakeRewards[msg.sender]).add(calculateEarnings(msg.sender));
    //calculates unpaid period
    uint remainder = (now.sub(lastClock[msg.sender])).mod(86400);
    //mark transaction date with remainder
    lastClock[msg.sender] = now.sub(remainder);
    //updates stakeholder's stakes
    stakes[msg.sender] = (stakes[msg.sender]).add(afterTax);
    //emit event
    emit OnStake(msg.sender, afterTax, stakingTax);
}

// No input checking in unstake() function
/**
 * removes '_amount' stakes for already registered stakeholders
 * deducts the unstaking tax from '_amount'
 * transfers the sum of the remainder, stake rewards, referral rewards, and current eanrings to the sender 
 * deregisters stakeholder if all the stakes are removed
 * Emits an {OnStake} event
 */
function unstake(uint _amount) external onlyRegistered() {
    //makes sure _amount is not more than stake balance
    require(_amount <= stakes[msg.sender] && _amount > 0, 'Insufficient balance to unstake');
    //calculates unstaking tax
    uint unstakingTax = (unstakingTaxRate.mul(_amount)).div(1000);
    //calculates amount after tax
    uint afterTax = _amount.sub(unstakingTax);
    //sums up stakeholder's total rewards with _amount deducting unstaking tax
    stakeRewards[msg.sender] = (stakeRewards[msg.sender]).add(calculateEarnings(msg.sender));
    //updates stakes
    stakes[msg.sender] = (stakes[msg.sender]).sub(_amount);
    //calculates unpaid period
    uint remainder = (now.sub(lastClock[msg.sender])).mod(86400);
    //mark transaction date with remainder
    lastClock[msg.sender] = now.sub(remainder);
    //update the total staked LEAD amount in the pool
    totalStaked = totalStaked.sub(_amount);
    //transfers value to stakeholder
    IERC20(lead).transfer(msg.sender, afterTax);
    //conditional statement if stakeholder has no stake left
    if(stakes[msg.sender] == 0) {
        //deregister stakeholder
        registered[msg.sender] = false;
    }
    //emit event
    emit OnUnstake(msg.sender, _amount, unstakingTax);
}