# Project Name
Omnipus

# Description
It functions as a message relayer to other staking / layerzero endpoint contracts. In part of this contract `OAppSender.sol`, `payNative()` function ensures the msg.value from the sender aligns with declared `nativeFee()`. However the check was commented out so that two messages can be sent in the same transaction.

# Root Cause
```solidity
/**
    *
    * @param _nativeFee The native fee to be paid.
    * @return nativeFee The amount of native currency paid.
    *
    * @notice We override this because we send two messages in the same transaction
    */
function _payNative(uint256 _nativeFee) internal pure override returns (uint256 nativeFee) {
    // if (msg.value != _nativeFee) revert NotEnoughNative(msg.value);
    return _nativeFee;
}