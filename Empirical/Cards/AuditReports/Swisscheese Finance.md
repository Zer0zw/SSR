# Project Name
Swisscheese Finance

# Description
1. Potential flashloan attack
    
    The contract's reliance on a single Dex pair for price feeds in the **`claimRewardsAndLeave()`** function exposes it to flashloan attack risks. An attacker can use a flashloan as the initial funds for an exploit to enlarge the profit or manipulate the token price in decentralized exchanges.

# Root Cause
```solidity
// Potential flashloan attack
uint256 rewardsToBePaid = (levels[level].earning * 1e36) /
      getSwchPrice();
SWCH.safeTransfer(msg.sender, rewardsToBePaid);

function getSwchPrice() public returns (uint256) {
	  (uint256 priceInUSDT, ) = swchPriceFeed.quoteExactOutputSingle(
	      address(USDT),
	      address(SWCH),
	      1e18,
	      0
	  );
	  uint256 priceInUSD = priceInUSDT * 1e12;
	  emit SWCHPriceGot(priceInUSD);
	  return priceInUSD;
}