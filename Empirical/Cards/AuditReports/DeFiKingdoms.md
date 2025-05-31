# Project Name
DeFi Kingdoms

# Description
Redundant calculations can occur in various forms in a smart contract, such as repetitive calculations for the same result, the recalculation of unchanging values, and the repeated execution of complex computations. These redundant calculations can significantly increase the gas cost of executing the smart contract. The contract executes redundant calculations in the segments listed below.

- `_executeOrder()`: The operations `(price * _quantity) / PRICE_FACTOR` is calculated more than once.
- `_addOrder()`: The operation `(_price * _quantity) / PRICE_FACTOR` is calculated twice.

# Root Cause
```solidity
uint256 sellerFee = calcFee(token, Side.SELL, (price * _quantity) / PRICE_FACTOR);
TokenFeesStorage.layout().powerToken.transfer(
    msg.sender,
    (price * _quantity) / PRICE_FACTOR - sellerFee
);
...