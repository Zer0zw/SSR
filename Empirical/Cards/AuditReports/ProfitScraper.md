# Project Name
ProfitScraper

# Description
1. Potential Reentrance Exploit
    
    As part of the `contribution` method, the contract transfers ETH to the referrer if the referrer's address is not equal to the zero address. Since the referrer can be any address, the address can be exploited for a re-entrance attack.

# Root Cause
```solidity
// Potential Reentrance Exploit
function contribution(address _referrer) public payable {
    ...
    payable(investors[msg.sender].referrer).transfer(referrerAmountlvl1);
    ...
    payable(investors[_referrer].referrer).transfer(referrerAmountlvl2);
    ...
}