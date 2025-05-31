# Project Name
OpSec

# Description
1. Contract Centralization Risk
    
    The contract's functionality and behavior are heavily dependent on external parameters or configurations. While external configuration can offer flexibility, it also poses several centralization risks that warrant attention. Centralization risks arising from the dependence on external configuration include Single Point of Control, Vulnerability to Attacks, Operational Delays, Trust Dependencies, and Decentralization Erosion. Specifically, the `claim` function requires the contract owner to initiate transactions, deciding which users receive Ethereum payouts and how much each receives. This setup places substantial control in the hands of a single entity, potentially allowing for arbitrary or biased distributions of rewards. Additionally, The contract owner has the authority to claim all the balance of the contract. The owner may take advantage of it by calling the withdraw function. Lastly, the owner can stop the functioning of the contract by calling the `pause` function.
    
2. Staking Logic Misalignment
    
    The contract primarily functions as a token locker rather than a traditional staking contract, due to its reward distribution mechanism. In typical staking contracts, rewards are often calculated and distributed automatically based on the amount and duration of the tokens staked by each user. However, in this contract, the claim function, which is responsible for distributing rewards, must be manually invoked by the contract owner. This function allows the owner to arbitrarily decide both the recipients and the amounts of the distributions. There is no inherent mechanism within the contract that automatically calculates and allocates staking rewards based on predefined criteria such as staking duration or amounts. This setup significantly deviates from the usual expectations of a staking mechanism where rewards are expected to be distributed in a decentralized and algorithmically defined manner.
    
3. User Staked Tokens Risk
    
    As described in the CCR finding, the contract owner has the authority to withdraw any tokens from the contract without restrictions. This functionality can lead to scenarios where users are unable to unstake their tokens because the necessary funds have been removed from the contract.

# Root Cause
```solidity
// Contract Centralization Risk
function pause() external onlyOwner {
    _pause();
}

function claim(
    uint256[] calldata amounts,
    address[] calldata users
) external onlyOwner whenNotPaused {
    require(
        amounts.length == users.length,
        "Invalid the length of amounts and users"
    );

    for (uint256 i = 0; i < amounts.length; i++) {
        payable(users[i]).sendValue(amounts[i]);

        emit Claimed(amounts[i], users[i]);
    }
}

function withdraw(
    address token,
    address user,
    uint256 amount
) external onlyOwner {
    IERC20(token).safeTransfer(user, amount);
}

// Staking Logic Misalignment
function claim(
    uint256[] calldata amounts,
    address[] calldata users
) external onlyOwner whenNotPaused {
    require(
        amounts.length == users.length,
        "Invalid the length of amounts and users"
    );

    for (uint256 i = 0; i < amounts.length; i++) {
        payable(users[i]).sendValue(amounts[i]);

        emit Claimed(amounts[i], users[i]);
    }
}

// User Staked Tokens Risk
function unstake(bytes32 stakeId) external whenNotPaused {
    StakeData storage stakeData = stakes[stakeId];
    require(stakeData.user == msg.sender, "You are not the staker");
    require(!stakeData.unstaked, "You already unstaked");
    require(
        stakeData.timestamp + stakeData.duration <= block.timestamp,
        "The stake is still locked"
    );

    stakeData.unstaked = true;
    stakeAmounts[msg.sender] -= stakeData.amount;

    opsec.safeTransfer(msg.sender, stakeData.amount);

    emit Unstaked(stakeId, msg.sender, stakeData.amount, block.timestamp);
}