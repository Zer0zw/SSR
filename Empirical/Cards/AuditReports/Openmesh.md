# Project Name
Openmesh

# Description
1. Contract Centralization Risk
    
    The contract's functionality and behavior are heavily dependent on external parameters or configurations. While external configuration can offer flexibility, it also poses several centralization risks that warrant attention. Centralization risks arising from the dependence on external configuration include Single Point of Control, Vulnerability to Attacks, Operational Delays, Trust Dependencies, and Decentralization Erosion.
    
    Specifically, the contract is currently structured in a way that centralizes significant control and authority in the hands of the contract owner, along with designated minter and burner accounts. The owner has the exclusive ability to set addresses authorized to mint tokens and NFTs to specific target addresses, and to burn NFTs. Additionally, the owner have the authority to transfer tokens to the ****`Fundraiser` contract and to execute withdrawals through the `OpenStaking` contract. Furthermore, the owner have to supply the `rewardToken` to the `VerifiedContributorStaking`, which is essential for users to claim their rewards, and also sets the end time of the staking period. This concentration of power in a single role raises concerns about potential misuse or single points of failure, which could undermine the trust and security of the contract.
    
2. Potential Stake Functionality Enhancement
    
    The contract contains the `stake` function which transfers the user's tokens to the contract address and subsequently burns them. This burn of staked tokens poses a risk to accurately measuring the total value locked within the contract, since the total value locked is reduced, leading to an inability to accurately track the total value of the tokens within the contract.

# Root Cause
```solidity
// Contract Centralization Risk
function mint(
    address account,
    uint256 amount
) external onlyRole(MINT_ROLE) {
    if (totalSupply() + amount > maxSupply) {
        revert SurpassMaxSupply();
    }

    _mint(account, amount);
}

function mint(address account) external onlyRole(MINT_ROLE) {
    _mint(account, mintCounter++);
}

function mint(
    address to,
    uint256 tokenId
) external virtual onlyRole(MINT_ROLE) {
    _mint(to, tokenId);
}

function burn(uint256 tokenId) external virtual onlyRole(BURN_ROLE) {
    _burn(tokenId);
}
function withdraw(
    ...
) external {
    ...
    if (signer != owner()) {
        revert InvalidProof();
    }

    token.mint(_withdrawer, _amount);
    ...
}


// Potential Stake Functionality Enhancement
function stake(uint256 _amount) external {
    token.transferFrom(msg.sender, address(this), _amount);
    token.burn(_amount);
    emit TokensStaked(msg.sender, _amount);
}