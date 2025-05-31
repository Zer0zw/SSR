# Project Name
Noracle

# Description
1. Contract Centralization Risk
    
    The contract's functionality and behavior are heavily dependent on external parameters or configurations. While external configuration can offer flexibility, it also poses several centralization risks that warrant attention. Centralization risks arising from the dependence on external configuration include Single Point of Control, Vulnerability to Attacks, Operational Delays, Trust Dependencies, and Decentralization Erosion.
    
    Specifically, the owner has exclusive authority to set unlock times, manage investor and advisor roles, control budget allocations, and execute token transfers. This concentration of power can lead to potential misuse or arbitrary decisions without checks or balances in case where the owner's wallet is compromised, highlighting the need for governance mechanisms like multi-signature approvals or community voting to ensure a more decentralized and secure operation.
    
2. Allocation Overwrite Discrepancy
    
    The contract is designed to allocate tokens to specific addresses within different categories, such as investors, advisors, and airdrop beneficiaries. However, the functions responsible for setting these allocations directly assign the specified `balance` to variables `investorBalances`, `advisorBalances` and `airdropBeneficiaryBalances`, rather than incrementing the current balance. As a result, if the same function is called for an address that has already been assigned a balance, the new balance will overwrite the previous one without adjusting the total distributed tokens accordingly. This leads to discrepancies between the recorded total distributed tokens and the actual amounts allocated to each address, potentially causing misalignment in the contract’s token distribution.

# Root Cause
```solidity
// Contract Centralization Risk
function setUnlockTimes(uint256 newUnlockStartTime) external onlyOwner {
    require(
        newUnlockStartTime > block.timestamp,
        "Noracle: Invalid unlock time"
    );
    unlockStartTime = newUnlockStartTime;
    advisorUnlockStartTime = newUnlockStartTime + 365 days;
    airdropUnlockStartTime = newUnlockStartTime + 28 days;
    ecosystemUnlockStartTime = newUnlockStartTime + 180 days;
    ...
}

function addInvestor(
    address investor,
    uint256 balance
) external onlyOwner {
...
}

function removeInvestor(address investor) external onlyOwner {
    investors[investor] = false;
    emit MemberRemoved(investor, "investor removed");
}

function addAdvisor(address advisor, uint256 balance) external onlyOwner {
    ...
}

function removeAdvisor(address advisor) external onlyOwner {
    advisors[advisor] = false;
    emit MemberRemoved(advisor, "advisor removed");
}

function addAirdropBeneficiary(
    address airdropBeneficiary,
    uint256 balance
) external onlyOwner {
    ...
}

function removeAirdropBeneficiary(address airdropBeneficiary) external onlyOwner {
    airdropBeneficiaries[airdropBeneficiary] = false;
    emit MemberRemoved(airdropBeneficiary, "airdrop beneficiary removed");
}

function setEcosystemReserve(address newEcosystemReserve) external onlyOwner {
...
}

function setBudget(Category category, uint256 amount) external onlyOwner {
...
}

function transferNoraTokens(
    Category category,
    address recipient,
    uint256 amount
) external onlyOwner {
    ...
}

// Allocation Overwrite Discrepancy
function addInvestor(
    address investor,
    uint256 balance
) external onlyOwner {
    require(balance >= 0, "Noracle: Invalid balance");
    require(
        totalDistributedInvestorTokens + balance <= INVESTOR_LOCKED_SUPPLY,
        "Noracle: Exceeds investor max supply"
    );
    investors[investor] = true;
    investorBalances[investor] = balance;
    totalDistributedInvestorTokens += balance;
    investorRemainingWeeks[investor] = 24; //24 weeks;

    emit MemberAdded(investor, balance, "investor balance added");
}

function addAdvisor(address advisor, uint256 balance) external onlyOwner {
    require(balance >= 0, "Noracle: Invalid balance");
    require(
        totalDistributedAdvisorTokens + balance <= ADVISOR_LOCKED_SUPPLY,
        "Noracle: Exceeds advisor max supply"
    );
    advisors[advisor] = true;
    advisorBalances[advisor] = balance;
    totalDistributedAdvisorTokens += balance;
    advisorRemainingMonths[advisor] = 12; //12 months;

    emit MemberAdded(advisor, balance, "advisor balance added");
}

function addAirdropBeneficiary(
    address airdropBeneficiary,
    uint256 balance
) external onlyOwner {
    require(balance >= 0, "Noracle: Invalid balance");
    require(
        totalDistributedAirdropTokens + balance <= MAX_BALANCE_AIRDROP,
        "Noracle: Exceeds airdrop max supply"
    );
    airdropBeneficiaries[airdropBeneficiary] = true;
    airdropBeneficiaryBalances[airdropBeneficiary] = balance;
    totalDistributedAirdropTokens += balance;
    airdropBeneficiaryRemainingMonths[airdropBeneficiary] = 3; // 3x4 weeks;

    emit MemberAdded(airdropBeneficiary, balance, "airdrop beneficiary balance added");
}