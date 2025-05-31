# Project Name
ARCHIE COIN

# Description
1. Function Unrestricted Access
    
    The contract's `registerBLSPublicKey()` function adds a public key to the `_addressToBLSPublicKey` variable. The `validatorBLSPublicKeys()` function returns only the registered keys of the `validators`. The `registerBLSPublicKey()` function can be called by any user, not just validators. As a result, the `validatorBLSPublicKeys()` function may return inaccurate results.

# Root Cause
```solidity
// Function Unrestricted Access
function validatorBLSPublicKeys() public view returns (bytes[] memory) {
    bytes[] memory keys = new bytes[](_validators.length);

    for (uint256 i = 0; i < _validators.length; i++) {
        keys[i] = _addressToBLSPublicKey[_validators[i]];
    }

    return keys;
}
...
function registerBLSPublicKey(bytes memory blsPubKey) public {
    _addressToBLSPublicKey[msg.sender] = blsPubKey;

    emit BLSPublicKeyRegistered(msg.sender, blsPubKey);
}