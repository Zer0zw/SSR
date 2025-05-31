# Project Name
Bitcointry

# Description
1. Centralization Risks in Token.sol
    
    In the contract **`Bitcointry_Token`** the role **`owner`** has authority over the functions shown in the diagram below. Any compromise to the **`owner`** account may allow the hacker to take advantage of this authority and
    
    - set fees via **`stakingFeesSetup()`** up to 25% each (buy, sell, transfer)
    - mark more addresses as AMM via **`setAMMPair()`** making more operations treated as buy/sell
    - **`excludeFromFees()`** more addresses allowing them to transfer tokens without fees
    - change **`stakingAddress`** via **`stakingAddressSetup()`**, it gets the fees
    - extract other tokens locked in the contract via **`recoverERC20()`**
2. Locked Blockchain Native Tokens
    
    The contract has a **`receive()`** function or payable functions, making it able to receive native tokens. However, it does not have a function to withdraw the funds, which can lead to permanently locked tokens within the contract.

# Root Cause
```solidity
// Centralization Risks in Token.sol
function stakingAddressSetup(address _newAddress) public onlyOwner {
    require(_newAddress != address(0), "TaxesDefaultRouterWallet: Wallet tax recipient cannot be a 0x0 address");

    stakingAddress = _newAddress;
    excludeFromFees(_newAddress, true);

    emit stakingAddressUpdated(_newAddress);
}

function stakingFeesSetup(uint16 _buyFee, uint16 _sellFee, uint16 _transferFee) public onlyOwner {
    totalFees[0] = totalFees[0] - stakingFees[0] + _buyFee;
    totalFees[1] = totalFees[1] - stakingFees[1] + _sellFee;
    totalFees[2] = totalFees[2] - stakingFees[2] + _transferFee;
    require(totalFees[0] <= 2500 && totalFees[1] <= 2500 && totalFees[2] <= 2500, "TaxesDefaultRouter: Cannot exceed max total fee of 25%");

    stakingFees = [_buyFee, _sellFee, _transferFee];

    emit stakingFeesUpdated(_buyFee, _sellFee, _transferFee);
}

// Locked Blockchain Native Tokens
receive() external payable {}