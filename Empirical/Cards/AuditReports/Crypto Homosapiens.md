# Project Name
Crypto Homosapiens

# Description
1. Inadequate Contract Verification
    
    The contract utilizes the `isContract` function to prevent contracts from participating in the `presaleMint` and `airdropMint` functions. While the `isContract` function can accurately determine if an address is a contract, it cannot reliably verify that an address is not a contract. Specifically, `isContract` will return false for certain types of addresses, including externally-owned accounts (EOAs), contracts in construction, addresses where contracts will be created, and addresses where contracts previously existed but have been destroyed. As a result, relying solely on `isContract` for security may create a false sense of protection, as malicious actors could exploit these scenarios to bypass the contract verification.
    
2. Redundant Storage Writes
    
    The contract modifies the state of the following variables without checking if their current value is the same as the one given as an argument. As a result, the contract performs redundant storage writes, when the provided parameter matches the current state of the variables, leading to unnecessary gas consumption and inefficiencies in contract execution.

# Root Cause
```solidity
// Inadequate Contract Verification
require(!isContract(msg.sender), "Contracts are not allowed to mint");

function isContract(address account) internal view returns (bool) {
    uint256 size;
    assembly {
        size := extcodesize(account)
    }
    return size > 0;
}

// Redundant Storage Writes
function pause(bool _state) external onlyOwner {
    paused = _state;
}

function setWhitelistMerkleRoot(bytes32 _newMerkleRoot) external onlyOwner {
    whitelistMerkleRoot = _newMerkleRoot;
}

function setOgMerkleRoot(bytes32 _newMerkleRoot) external onlyOwner {
    ogMerkleRoot = _newMerkleRoot;
}