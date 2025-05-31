# Project Name
Apecoin

# Description
In the `AirdropGrapesToken` contract the function `claimTokens()` calles the function `getClaimableTokenAmountAndGammaToClaim()` to calculate the amount of ApeCoin to claim based on how many NFT the caller has  and it doesn’t consider how long the caller owns those NFTs.

# Root Cause
```solidity
function claimTokens() external whenNotPaused {
    require(block.timestamp >= claimStartTime && block.timestamp < claimStartTime + claimDuration, "Claimable period is finished");
    require((beta.balanceOf(msg.sender) > 0 || alpha.balanceOf(msg.sender) > 0), "Nothing to claim");

    uint256 tokensToClaim;
    uint256 gammaToBeClaim;

    (tokensToClaim, gammaToBeClaim) = getClaimableTokenAmountAndGammaToClaim(msg.sender);

    for(uint256 i; i < alpha.balanceOf(msg.sender); ++i) {
        uint256 tokenId = alpha.tokenOfOwnerByIndex(msg.sender, i);
        if(!alphaClaimed[tokenId]) {
            alphaClaimed[tokenId] = true;
            emit AlphaClaimed(tokenId, msg.sender, block.timestamp);
        }
    }

    for(uint256 i; i < beta.balanceOf(msg.sender); ++i) {
        uint256 tokenId = beta.tokenOfOwnerByIndex(msg.sender, i);
        if(!betaClaimed[tokenId]) {
            betaClaimed[tokenId] = true;
            emit BetaClaimed(tokenId, msg.sender, block.timestamp);
        }
    }

    uint256 currentGammaClaimed;
    for(uint256 i; i < gamma.balanceOf(msg.sender); ++i) {
        uint256 tokenId = gamma.tokenOfOwnerByIndex(msg.sender, i);
        if(!gammaClaimed[tokenId] && currentGammaClaimed < gammaToBeClaim) {
            gammaClaimed[tokenId] = true;
            emit GammaClaimed(tokenId, msg.sender, block.timestamp);
            currentGammaClaimed++;
        }
    }

    grapesToken.safeTransfer(msg.sender, tokensToClaim);

    totalClaimed += tokensToClaim;
    emit AirDrop(msg.sender, tokensToClaim, block.timestamp);
}

function getClaimableTokenAmountAndGammaToClaim(address _account) private view returns (uint256, uint256)
{
    uint256 unclaimedAlphaBalance;
    for(uint256 i; i < alpha.balanceOf(_account); ++i) {
        uint256 tokenId = alpha.tokenOfOwnerByIndex(_account, i);
        if(!alphaClaimed[tokenId]) {
            ++unclaimedAlphaBalance;
        }
    }
    uint256 unclaimedBetaBalance;
    for(uint256 i; i < beta.balanceOf(_account); ++i) {
        uint256 tokenId = beta.tokenOfOwnerByIndex(_account, i);
        if(!betaClaimed[tokenId]) {
            ++unclaimedBetaBalance;
        }
    }
    uint256 unclaimedGamaBalance;
    for(uint256 i; i < gamma.balanceOf(_account); ++i) {
        uint256 tokenId = gamma.tokenOfOwnerByIndex(_account, i);
        if(!gammaClaimed[tokenId]) {
            ++unclaimedGamaBalance;
        }
    }

    uint256 gammaToBeClaim = min(unclaimedAlphaBalance + unclaimedBetaBalance, unclaimedGamaBalance);
    uint256 tokensAmount = (unclaimedAlphaBalance * ALPHA_DISTRIBUTION_AMOUNT)
    + (unclaimedBetaBalance * BETA_DISTRIBUTION_AMOUNT) + (gammaToBeClaim * GAMMA_DISTRIBUTION_AMOUNT);

    return (tokensAmount, gammaToBeClaim);
}