# Project Name
Liquify

# Description
1. Inconsistent Token Claim Conditions
    
    The contract requires specific project states, such as `Distributing` or `Finished`, in order to proceed with claiming real tokens via the `claimRealTokens`function. However, the `claimSyntheticTokens` function lacks a similar status check, allowing users to claim their synthetic tokens immediately after contributing. This inconsistency in the claim process can lead to confusion and create an imbalance between the timing of synthetic and real token claims, as users can access synthetic tokens without any project status restrictions, while real tokens are subject to state checks.
    
2. Missing RealToken Validation Mechanism
    
    The contract contains the `updatePaymentTokens` function, which grants the owner the authority to define legitimate payment tokens for the contract. However, it lacks a similar function to set and validate the legitimate `realTokens` used during the `initiatorDeposit`. As a result, the project owner is able to specify any address as the `realToken` address during the deposit process, potentially allowing them to use incorrect or malicious token addresses, which could harm the integrity of the contract.
    
3. Withdraw Before Project Completion
    
    The contract allows the project owner to withdraw funds through the `initiatorWithdraw` function without verifying that the project has reached the `Finished` status. This omission could lead to premature withdrawals while the project is still ongoing, potentially disrupting the intended process and leaving insufficient funds for future project phases or user claims.

# Root Cause
```solidity
// Inconsistent Token Claim Conditions
function claimSyntheticTokens(uint256 projectId, uint256[] calldata vestingStages) external whenNotPaused nonReentrant {
    if (vestingStages.length == 0) revert NoVestingStagesSpecified();
    ...
        IERC20(tokenClone).safeTransfer(msg.sender, tokensToClaim);
        projectState.tokenEntitlements[msg.sender][stage].entitlements = 0;
        totalClaimed += tokensToClaim;

        emit SyntheticTokensClaimed(msg.sender, projectId, address(this), stage, tokensToClaim);
    ...
}

function claimRealTokens(uint256 projectId, uint256[] calldata rounds) external whenNotPaused nonReentrant {
    ProjectState storage state = projectStates[projectId];
    if (state.status != ProjectStatus.Distributing && state.status != ProjectStatus.Finished)
        revert InvalidStatus2(ProjectStatus.Distributing, ProjectStatus.Finished, state.status);

    ...
    if (totalRealTokens > 0) {
        uint8 realTokenDecimals = IERC20Metadata(address(state.realTokensAddress)).decimals();
        uint256 denormalizedTotalRealTokens = denormalizeTokenAmount(totalRealTokens, realTokenDecimals);

        state.realTokensAddress.transfer(msg.sender, denormalizedTotalRealTokens);
    }
    else revert NoTokensToClaim();
}

// Missing RealToken Validation Mechanism
function updatePaymentTokens(IERC20[] calldata tokens, bool[] calldata states) external onlyOwner whenNotPaused validateArrayLengths(tokens.length, states.length) {
    for (uint256 i = 0; i < tokens.length; i++) {
        paymentTokens[tokens[i]] = states[i];
    }
    emit PaymentTokensUpdated(tokens, states);
}

function initiatorDeposit(uint256 projectId, IERC20 realToken) external whenNotPaused nonReentrant onlyProjectOwner(projectId) {
    ProjectDetails storage project = projectDetails[projectId];
    ProjectState storage projectState = projectStates[projectId];
    IERC20 sc_realToken = projectState.realTokensAddress;
    uint256 vestingPhaseIndex = projectState.vestingPhaseIndex;


    ...
    if (vestingPhaseIndex == project.vestingReleasePercentages.length - 1) projectState.status = ProjectStatus.Finished;
    else projectState.vestingPhaseIndex++;
    ...
}

// Withdraw Before Project Completion
function initiatorWithdraw(uint256 projectId, uint256 amount) external whenNotPaused nonReentrant onlyProjectOwner(projectId) {
    ProjectDetails storage project = projectDetails[projectId];
    ProjectState storage projectState = projectStates[projectId];
    ...
    paymentToken.safeTransfer(msg.sender, amount);

    emit FundsWithdrawn(projectId, amount);
}