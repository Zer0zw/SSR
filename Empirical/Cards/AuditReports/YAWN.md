# Project Name
YAWN

# Description
1. Potential Transfer Revert Propagation
    
    The contract sends funds to a `marketingWallet` as part of the transfer flow. This address can either be a wallet address or a contract. If the address belongs to a contract then it may revert from incoming payment. As a result, the error will propagate to the token’s contract and revert the transfer.
    
2. Redundant Code Segment
    
    There are code segments that could be optimized. A segment may be optimized so that it becomes a smaller size, consumes less memory, executes more rapidly, or performs fewer operations.
    
    The `tradingOpen` variable is initialized in the constructor and set to true. Since its value cannot be modified later in any way, the following code segment is redundant since it will never execute.

# Root Cause
```solidity
// Potential Transfer Revert Propagation
_uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
    tokenAmount,
    0,
    path,
    marketingWallet,
    block.timestamp
);

// Redundant Code Segment
if (!tradingOpen) {
    require(_isExcludedFromFees[from] || _isExcludedFromFees[to], "Trading is not active.");
}