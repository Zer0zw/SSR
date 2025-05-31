# Project Name
MarsmelloBurn

# Description
1. Winner Selection Randomization
    
    The contract does not select the top three winners randomly. Instead, the addresses are being passed as arguments to the `setTopThreeWinner` function. As a result, the signer can manipulate the winners by passing any addresses as arguments.

# Root Cause
```solidity
// Winner Selection Randomization
function setTopThreeWinner(address _first, address _second, address _third) external onlySigner {
    require(_first != address(0) && _second != address(0) && _third != address(0), "error: zero values");
    FirstWinner = _first;
    SecondWinner = _second;
    ThirdWinner = _third;
}