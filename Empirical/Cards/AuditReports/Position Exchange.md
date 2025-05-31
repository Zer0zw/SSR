# Project Name
Position Exchange

# Description
1. Incorrect Calculation Of `pendingEarned` And `earned`
    
    The calculation of `pendingEarned` and `earned` is not correct. The formula `balanceOf(account).mul(userInfo[account].rewards)` is meaningless.
    
2. Centralization Risk
    
    In the contract `BUSDPosiVault`, the role `onlyOwner` has the authority over the following function: `updatePositionReferral`, `updateReferralCommissionRate`, `updatePercentFeeForCompounding`. Any compromise to the `onlyOwner` account may allow the hacker to take advantage of this.

# Root Cause
Not Open Source