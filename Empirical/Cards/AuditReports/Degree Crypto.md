# Project Name
Degree Crypto

# Description
1. Potentially Mint Reward Token Failure
    
    The function **`mint`** of the contract **`DegreeCryptoToken`** to mint reward tokens will potentially fail due to the total supply exceeding the max supply. Hence, the stakers are possibly unable to claim reward tokens.
    
2. Lack Of Validation Of `xstatus`
    
    There is no validation to ensure the **`xstatus`** is valid.
    
3. Potentially Lose Reward Token
    
    The calculation of the reward depends on the variable **`stakers[staker].amountStaked`**, which stands for the token amount the user staked. So the users potentially lose the reward token in the scenarios below.
    
    - If the contract owner calls the **`burnStaker`** function to burn stakers' tokens before they can claim their reward tokens.
    - When the **`claimReward`** function is called, the user's pending amount will not be converted to the staked amount. If a user stakes tokens multiple times in different stages over time but never calls the **`claimReward`** function to withdraw rewards, then the user will ultimately lose some reward tokens because the staked amount has not been updated in a timely manner.

# Root Cause
```solidity
// Potentially Mint Reward Token Failure
require((totalSupply() + (value)<=maxSupply), "DCT: LIMIT EXCEEDED");

require(token.mint(msg.sender, reward), "Reward transfer failed");
// mint for fee
require(token.mint(addrfee, amountfee), "Reward fee transfer failed");
// mint for tax
require(token.mint(addrtax, amounttax), "Reward tax transfer failed");
stakerMinted[msg.sender] = stakerMinted[msg.sender] + dailyReward;
stakers[msg.sender].lastRewardTime = (stakers[msg.sender].lastRewardTime) + (rewardInterval);

// Potentially Lose Reward Token
function _calcReward(address staker) internal view returns (uint256){
    uint256 dailyReward = (stakers[staker].amountStaked * rewardPercentage[nowStage]) / (10000);
    return dailyReward;
}

if(pendingStaking[msg.sender] > 0) {
    stakers[msg.sender].amountStaked = (stakers[msg.sender].amountStaked) + (pendingStaking[msg.sender]);
    totalStaked = totalStaked + (pendingStaking[msg.sender]);
    totalPendingStaked = totalPendingStaked - (pendingStaking[msg.sender]);
    pendingStaking[msg.sender] = 0;
}