# Project Name
ONI

# Description
1. Missing ChainID in Signature Validation
    
    The contract is currently structured to validate signatures using parameters such as `expireTimestamp`, `mintData.reqid`, and user-defined attributes. However, it fails to include the `chainId` in the parameters used for signature verification. This omission can potentially expose the contract to replay attacks, where a valid transaction on one network could be maliciously or mistakenly executed on another network, leading to unintended effects or vulnerabilities. While the contract utilizes `reqid` to prevent the reuse of requests on the same network, this mechanism does not safeguard against cross-network replay attacks, as `reqid` could potentially be unmarked on other networks.

# Root Cause
```solidity
// Missing ChainID in Signature Validation
function _validate(
    uint256 expireTimestamp,
    uint256 reqid,
    bytes memory packedArg,
    bytes memory signature
) internal {
    require(expireTimestamp >= block.timestamp, "expired");
    require(!reqidUsed[reqid], "duplicated reqid");
    reqidUsed[reqid] = true;
    ...
    signatureUsed[hashMessage] = true;
}

_validate(
    expireTimestamp,
    mintData.reqid,
    abi.encodePacked(
        caller,
        expireTimestamp,
        mintData.reqid,
        mintData.category,
        mintData.rarity
    ),
    mintData.signature
);