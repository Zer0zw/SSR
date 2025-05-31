# Project Name
LayerZ

# Description
1. Stops Transactions
    
    The contract owner has the authority to stop the sales for all users excluding the owner. The owner may take advantage of it by setting the `maxBuyPercent` to zero. As a result, the contract may operate as a honeypot.

# Root Cause
```solidity
// Stops Transactions
if (_amount > (balanceOf(PANCAKE_PAIR) * maxBuyPercent) / PRECISION) {
    revert TransferAmountExceedsPurchaseAmount();
}
...
function setMaxBuyPercent(uint256 _maxBuyPercent) external onlyOwner {
    maxBuyPercent = _maxBuyPercent;
}