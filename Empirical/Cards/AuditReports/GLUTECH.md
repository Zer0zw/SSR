# Project Name
GLUTECH

# Description
1. Potential Referrals Counter Manipulation
    
    The contract is designed to record referrals using the `recordReferral` function. This function is `public`, which means that anyone can call it. A malicious user could potentially exploit this by using multiple different wallets to refer the same account ( `_referrer`) repeatedly. This would artificially inflate the `totalDirectReferrals` count of the user ( `_referrer`), as each call to the function from the different wallets would increment the `totalDirectReferrals` value. This could lead to an inaccurate representation of the actual referrals made by a user.

# Root Cause
```solidity
// Potential Referrals Counter Manipulation
function recordReferral(address _referrer) public nonReentrant {
    ...

    user.referrals.push(msg.sender);
    user.totalDirectReferrals = user.totalDirectReferrals.add(1);

    totalTeams = totalTeams.add(1);

    ...
}