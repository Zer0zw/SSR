# Project Name
FIZODApp

# Description
1. Potential Reentrance Exploit
    
    The contract makes an external call to transfer funds to recipients using the payable transfer method. The recipient could be a malicious contract that has an untrusted code in its fallback function that makes a recursive call back to the original contract. The re-entrance exploit could be used by a malicious user to drain the contract’s funds or to perform unauthorized actions. This could happen because the original contract does not update the state before sending funds.
    
2. Potential Circular Referral
    
    The contract is using the `_setReferral` and `_setReReferral` functions to record referrals between users. The `deposit` function includes a check to prevent direct circular referrals, where a user cannot refer themselves `_referer` cann't be `msg.sender`. However, the function does not prevent indirect circular referrals, where a third user can refer the first user, creating a circular referral chain.
    
    Specifically, if User A uses the `deposit` function and passes User B as `_referral`, and then User B does the same for User A, a circular referral is established. This creates a loop within the `_setReferral` function, which can lead to unintended behavior, such as infinite loops and incorrect referral calculations.
    
3. Redundant Require Check
    
    The contract includes a `require` statement within the `_burn` function to check if `_totalSupply >= amount`. This check is redundant because there is already a preceding `require` statement that ensures `accountBalance >= amount`. Given that `accountBalance` is a subset of `_totalSupply`, if `amount` is greater than `accountBalance`, the code will revert at that `require` statement. Consequently, if the `amount` exceeds `accountBalance`, it would always exceed `_totalSupply`. Therefore, the `require _totalSupply>=amount` statement is unnecessary and adds extra gas costs to the contract execution.

# Root Cause
```solidity
// Potential Reentrance Exploit
function fizoWithdraw(uint8 _perc) public{
        User storage user = users[msg.sender];
        Userwithdraw storage userwithdraw = userwithdraws[msg.sender];
       
        require(lock==0, "Lock!");
        require(user.totalInvestment>0, "Invalid User!");
        require(is_activeb[msg.sender].fizowithdrawb==0, "Invalid User!");
        
        if(_perc == 10 || _perc == 50 || _perc == 100)
        {
         uint256 nextPayout = (userwithdraw.lastNonWokingWithdraw>0)?userwithdraw.lastNonWokingWithdraw + 1 days:deposits[msg.sender][0].depositTime;
         require(block.timestamp >= nextPayout,"Sorry ! See you next time.");
         uint8 perc = _perc;
              if(perc==10)
            {
                deduct=10;
                vippercentage=0;
            }
            else if(perc==50)
            {
                deduct=20;
                vippercentage=3;

            }
        uint256 tokenAmount = user.token.mul(perc).div(100);
        require(_balances[msg.sender]>=tokenAmount, "Insufficient token balance!");
        uint256 ftmAmount = tokensToFTM(tokenAmount);
        uint256 ftmrate = tokensToFTM(1);
        require(address(this).balance>=ftmAmount, "Insufficient fund in contract!");
        uint256 calcWithdrawable = ftmAmount;
        contractBalance-=calcWithdrawable;
        uint256 withdrawable = ftmAmount;
        _addPOI(msg.sender);
        uint256 withdrawable1 =withdrawable.mul(deduct).div(100);
        uint256 withdrawable2 = withdrawable -withdrawable1;
        payable(msg.sender).transfer(withdrawable2);
        ...
        }
       
    }

// Potential Circular Referral
function deposit(address _referer) public payable 
  {
          require(msg.value >= 0, "Minimum 200 FANTOM allowed to invest");
          require(lock==0, "Lock!");
          User storage user = users[msg.sender];
          require(user.depositCount == 0, "already Deposited");
          if (users[_referer].depositCount > 0 && _referer != msg.sender) {
              _referer = _referer;
          } else {
              _referer = address(0);
          }
      ...
  _setReferral(msg.sender, _referer, depositValue);
  ...
  }
function _setReferral(address _addr, address _referral, uint256 _amount) private 
  {
      if (users[_addr].referral != address(0)) 
      {
          address nextReferral = _referral;
          uint256 levelPercentage;
          uint256 incomeShare;
          uint256 level_count= LEVEL_PERCENTS.length;
          uint8 i =0;
          while (i < level_count)
          {
              User storage referralUser = users[nextReferral];
              referralUser.referrals_per_level[i] += _amount;
              referralUser.team_per_level[i]++;
              
              referralUser.teammember++;
              referralUser.teambusiness+=_amount;

              levelPercentage = LEVEL_PERCENTS[i];
              incomeShare = _amount.mul(levelPercentage).div(10000);
          
              if (referralUser.referrals_per_level[i] >= LEVEL_UNLOCK[i]) {
                  referralUser.levelIncome[i] += incomeShare;
                  referralUser.teamIncome += incomeShare;
              } 
              ...
      }
  }

// Redundant Require Check
function _burn(address account,uint256 amount) internal virtual 
{
    ...
    uint256 accountBalance = _balances[account];
    require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
    require(_totalSupply>=amount, "Invalid amount of tokens!");
    ...
}