# Project Name
Genesis

# Description
1. Mints Tokens
    
    The contract is designed to allow the owner to set the staking contract, which in turn has the ability to mint new tokens. This capability enables the staking contract to significantly alter the tokenomics by increasing the total supply at its discretion. Such centralization of minting power can lead to risks including inflation, dilution of token value, and potential manipulation of the token supply, thereby affecting the stability and trust in the token ecosystem.
    
2. Transfers Contract's Tokens
    
    The contract owner has the authority to claim all the balance of the contract. The owner may take advantage of it by calling the `emergencyWithdraw` function.

# Root Cause
```solidity
// Mints Tokens
function mint(address to, uint256 amount) external {
    require(msg.sender == stakingContract);
    _mint(to, amount);
}

function setStakingContract(address stakingContract_) external onlyOwner {
    require(_stakingContractSet == false, "Staking contract can only be set once, and is immutable afterwards");
    stakingContract = stakingContract_;
    _stakingContractSet = true;
}

// Transfers Contract's Tokens
function emergencyWithdraw(address token, address to, uint256 amount) public onlyOwner {
    IERC20(token).transfer(to, amount);
}