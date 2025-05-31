# Project Name
ThorusFi

# Description
1. Centralized Control of State Variable 
    
    Critical state variables can be updated any time by the controlling authorities. Changes in these variables can cause impacts to the users, so the users should accept or be notified before these changes are effective.
    
    However, there is currently no constraint to prevent the authorities from modifying these variables without notifying the users

# Root Cause
```solidity
// Centralized Control of State Variable
function setPerformanceFee(uint256 _performanceFee) external onlyOwner {
    require(_performanceFee <= MAX_PERFORMANCE_FEE, "performanceFee cannot be more than MAX_PERFORMANCE_FEE");
    performanceFee = _performanceFee;
    emit SetPerformanceFee(_performanceFee);
}

function setCallFee(uint256 _callFee) external onlyOwner {
    require(_callFee <= MAX_CALL_FEE, "callFee cannot be more than MAX_CALL_FEE");
    callFee = _callFee;
    emit SetCallFee(_callFee);
}

function setWithdrawFee(uint256 _withdrawFee) external onlyOwner {
    require(_withdrawFee <= MAX_WITHDRAW_FEE, "withdrawFee cannot be more than MAX_WITHDRAW_FEE");
    withdrawFee = _withdrawFee;
    emit SetWithdrawFee(_withdrawFee);
}

function setWithdrawFeePeriod(uint256 _withdrawFeePeriod) external onlyOwner {
    require(
        _withdrawFeePeriod <= MAX_WITHDRAW_FEE_PERIOD,
        "withdrawFeePeriod cannot be more than MAX_WITHDRAW_FEE_PERIOD"
    );
    withdrawFeePeriod = _withdrawFeePeriod;
    emit SetWithdrawFeePeriod(_withdrawFeePeriod);
}