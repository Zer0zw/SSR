# Project Name
aiPX

# Description
1. Contract Centralization Risk
    
    The contract's functionality and behavior are heavily dependent on external parameters or configurations. While external configuration can offer flexibility, it also poses several centralization risks that warrant attention. Centralization risks arising from the dependence on external configuration include Single Point of Control, Vulnerability to Attacks, Operational Delays, Trust Dependencies, and Decentralization Erosion. Specifically since the owner of the contracts is an EOA can arbitrarily change parameters that affect how the contract functionality. Additionally the minter role address has the authority to mint new tokens in the `LyAipx` contract.
    
2. Insufficient Stake Validation
    
    The contract is currently designed to handle the unstaking process in the `unstake` function. This function allows a user to unstake a specified amount of tokens. However, the contract lacks of validation to ensure that `msg.sender` actually has a staked balance before proceeding with the unstaking operation. As it stands, the function calculates the amount to unstake and the pending rewards, adjusts the user's staked amount and reward debt, and then transfers the unstaked tokens and any pending rewards to the specified address. The function emits the `Unstaked` event regardless of whether the user had an actual staked balance or not. This can lead to misleading event logs, as the `Unstaked` event could be emitted even when no tokens have been unstaked, potentially causing confusion and inaccuracies in tracking staked tokens.
    
3. Missing Check
    
    The contract is processing variables that have not been properly sanitized and checked that they form the proper shape in the calculation of `_taxAmount` using the `stakingTax` variable. The contract currently allows `stakingTax` to be set to any value, including those greater than `STAKING_TAX_PRECISION`, which could lead to incorrect or unexpected tax calculations. These variables may produce vulnerability issues.

# Root Cause
```solidity
// Contract Centralization Risk
function setDistributor(address _distributor) external onlyOwner {
    require(_distributor != address(0), "AipxReferralController::setDistributor: invalid address");
    distributor = _distributor;
    emit DistributorSet(distributor);
}

function setUpdater(address _updater) external onlyOwner {
    require(_updater != address(0), "AipxReferralController::setUpdater: invalid address");
    updater = _updater;
    emit UpdaterSet(updater);
}

function setOracle(address _oracle) external onlyOwner {
    require(
        _oracle != address(0) && _oracle != address(oracle), "AipxReferralController::setOracle: invalid address"
    );
    oracle = IAIPXOracle(_oracle);
    oracle.update();
    emit OracleSet(_oracle);
}

function setEpochDuration(uint256 _epochDuration) public onlyOwner {
    require(
        _epochDuration >= MIN_EPOCH_DURATION,
        "AipxReferralController::setEpochDuration: must >= MIN_EPOCH_DURATION"
    );
    epochDuration = _epochDuration;
    emit EpochDurationSet(epochDuration);
}

function withdrawAIPX(address _to, uint256 _amount) external onlyOwner {
    require(_to != address(0), "AipxReferralController::withdrawAIPX: invalid address");
    AIPX.safeTransfer(_to, _amount);

    emit AIPXWithdrawn(_to, _amount);
}

function setEnableNextEpoch(bool _enable) external {
    ...
}

function mint(address _to, uint256 _amount) external {
    require(_msgSender() == minter, "LyAipx: !minter");
    _mint(_to, _amount);
}

// Insufficient Stake Validation
function unstake(address _to, uint256 _amount) external override {
    update();
    require(_amount != 0, "INVALID_AMOUNT");
    UserInfo storage user = userInfo[msg.sender];
    ...

    IERC20(AIPX).safeTransfer(_to, amountToUnstake);

    emit Unstaked(msg.sender, _to, amountToUnstake);
}

function unstake(address _to, uint256 _amount) external nonReentrant {
    ...
    AIPX.safeTransfer(_to, _amount);
    emit Unstaked(sender, _to, _amount);
}

function unstake(address _to, uint256 _amount) external nonReentrant {
    ...
    ago.safeTransfer(_to, _amount);
    emit Unstaked(sender, _to, _amount);
}

// Missing Check
uint256 _taxAmount = _amount * stakingTax / STAKING_TAX_PRECISION;

function setStakingTax(uint256 tax) external onlyOwner {
    stakingTax = tax;
    emit StakingTaxSet(tax);
}
...
uint256 _taxAmount = _amount * stakingTax / STAKING_TAX_PRECISION;

function setStakingTax(uint256 _tax) external onlyOwner {
    stakingTax = _tax;
    emit StakingTaxSet(_tax);
}