# Project Name
Mintdash

# Description
1. Missing Supply Validation
    
    The contract is using the `_updateMaxSupply` function to modify the `maxSupply` associated with the ERC721 or ERC1155 token implementation. However, the function does not verify if the `newMaxSupply` being set is greater than or equal to the current total supply of tokens. This means that the `_updateMaxSupply` function could potentially set `maxSupply` to a value lower than the existing total supply for that tokenId, leading to inconsistencies and potential issues in token management.
    
2. Centralization Risk
    
    The contract poses a centralization risk. Specifically, the `onlyOwnerOrAdministrator` modifier grants the owner and designated administrators the authority to supply the initial rewards tokens, add or remove reward tokens, and enable rewards by updating the current phase. This concentration of power in a limited number of entities undermines the decentralized nature of the contract and poses a risk in terms of censorship, manipulation, and single points of failure.
    
3. Limited Minting Flexibility
    
    The contract is using the `mintSigned` function to allow specific addresses to mint tokens. However, the function restricts the same user from minting more than once with the same parameters. This limitation arises from the `_getDigest` function, which calculates a digest based on the `minter` address, `mintParams`, and `salt`. If none of these three parameters change, the calculated signature will remain the same, preventing additional mints for the same user with the same parameters.

# Root Cause
```solidity
// Missing Supply Validation
function _updateMaxSupply(
    uint256 newMaxSupply
) internal {
    // Ensure the max supply does not exceed the maximum value of uint64.
    if (newMaxSupply > 2 ** 64 - 1) {
        revert CannotExceedMaxSupplyOfUint64();
    }

    maxSupply = newMaxSupply;

    emit MaxSupplyUpdated(newMaxSupply);
}
function _updateMaxSupply(
    uint256 tokenId,
    uint256 newMaxSupply
) internal {
   ...
}

// Centralization Risk
function initialize(address _nftContract, address _rewardToken, uint256 rewardsPerSecond)
      external
      initializer
  {
      __Ownable_init();

      nftToken = _nftContract;
      rewardToken = _rewardToken;

      _createNewRewardPhase(rewardsPerSecond);
}

function updateRewardRate(uint256 rewardsPerSecond) external onlyOwnerOrAdministrator {

    RewardPhase storage currentRewardPhase = rewardPhases[nextRewardPhaseId - 1];

    if (currentRewardPhase.rewardsPerSecond == rewardsPerSecond) {
        revert SameRewardRate();
    }

    currentRewardPhase.endTimestamp = uint128(block.timestamp);

    _createNewRewardPhase(rewardsPerSecond);

    emit RewardRateUpdated(rewardsPerSecond);
}

// Limited Minting Flexibility
function mintSigned(
      address recipient,
      uint256 quantity,
      SignedMintParams calldata mintParams,
      uint256 salt,
      bytes calldata signature
  ) external payable {
      ...
      // Get the digest to verify the EIP-712 signature.
      bytes32 digest = _getDigest(
          minter,
          mintParams,
          salt
      );

      // Ensure the digest has not already been used.
      if (_usedDigests[digest]) {
          revert SignatureAlreadyUsed();
      }

      // Mark the digest as used.
      _usedDigests[digest] = true;

      // Ensure correct signer signed this message.
      _checkSigner(digest, signature);
      ...
  }