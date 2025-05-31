# Project Name
DOGITA

# Description
1. Withdrawn Amount Inconsistency
    
    The contract's withdrawal mechanism calculates an unstaking fee, which is deducted from the withdrawn amount. The remaining balance is sent to the staker's address, and the fee is intended to be sent to the `withdrawFeeReceiver`. However, the contract incorrectly charges the staker twice in the withdrawal process. Initially, it calculates the unstaking fee and deducts it from the withdrawn amount, sending the remaining balance to the staker. Then, it requires the staker to pay the fee again from their own balance while withhelding the deducted amount. This effectively results in the staker paying the fees twice.
    
2. Missing Check
    
    The contract is processing variables that have not been properly sanitized and checked that they form the proper shape. These variables may produce vulnerability issues. In particular the contract is not checking whether `minStake < maxStake` and that the fees do not exceed an upper limit.

# Root Cause
```solidity
// Withdrawn Amount Inconsistency
function withdraw(uint256 orderId) external nonReentrant {
    ...
    uint256 fees = (orderInfo.amount * withdrawFees) / 100;
    uint256 depAmount = total - fees;
    ...
    require(token.transfer(address(_msgSender()), depAmount),
            "TokenStaking: token transfer via withdraw not succeeded");
    require(token.transferFrom(_msgSender(), withdrawFeeReceiver, fees),
            "TokenStaking: token transferFrom via deposit not succeeded");
    ...
    }

// Missing Check
function setWithdrawFees(uint256 _fee) external onlyOwner {
         withdrawFees = _fee;
}
function setMinStake(uint256 _value) external onlyOwner {
         minStake = _value;
}
function setMaxStake(uint256 _value) external onlyOwner {
         maxStake = _value;
}