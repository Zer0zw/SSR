# Project Name
OTSea Staking

# Description
In the `withdraw` function, the condition to check whether an account has already withdrawn is based on the statement `_deposits[_msgSender()][_indexes[i]].rewardReferenceEpoch = 0` in the `_withdrawMultiple` function. However, this value can be modified by calling the `claim` function, which changes it from 0 to `currentEpoch`. This allows the attacker to bypass the condition and repeatedly call the `withdraw` function to exploit the system.

# Root Cause
```solidity
/**
 * @notice Withdraw multiple deposits as well as claim their rewards
 * @param _indexes A list of deposit IDs to withdraw
 * @param _receiver Address to receive the tokens and ETH
 */
function withdraw(uint256[] calldata _indexes, address _receiver) external {
    if (_receiver == address(0)) revert OTSeaErrors.InvalidAddress();
    (uint88 totalAmount, uint256 totalRewards) = _withdrawMultiple(_indexes);
    if (totalRewards != 0) {
        _transferETHOrRevert(_receiver, totalRewards);
        emit Claimed(_msgSender(), _receiver, _indexes, totalRewards);
    }
    _otseaERC20.safeTransfer(_receiver, uint256(totalAmount));
    emit Withdrawal(_msgSender(), _receiver, _indexes, totalAmount);
}

/**
 * @notice Claim rewards for multiple deposits
 * @param _indexes A list of deposit IDs to claim
 * @param _receiver Address to receive ETH
 */
function claim(uint256[] calldata _indexes, address _receiver) external {
    if (_receiver == address(0)) revert OTSeaErrors.InvalidAddress();
    uint256 totalRewards = _claimMultiple(_indexes);
    _transferETHOrRevert(_receiver, totalRewards);
    emit Claimed(_msgSender(), _receiver, _indexes, totalRewards);
}

    /**
 * @param _indexes A list of deposit indexes
 * @return totalAmount Total amount to withdraw based on _indexes
 * @return totalRewards Total amount of rewards based on _indexes
 */
function _withdrawMultiple(
    uint256[] calldata _indexes
) private returns (uint88 totalAmount, uint256 totalRewards) {
    uint256 length = _indexes.length;
    _validateListLength(length);
    uint256 total = getTotalDeposits(_msgSender());
    uint32 currentEpoch = _currentEpoch;
    for (uint256 i; i < length; ) {
        if (total <= _indexes[i]) revert DepositNotFound(_indexes[i]);
        totalRewards += _calculateRewards(_msgSender(), _indexes[i]);
        Deposit memory deposit = _deposits[_msgSender()][_indexes[i]];
        if (deposit.rewardReferenceEpoch == 0) revert OTSeaErrors.NotAvailable();
        _deposits[_msgSender()][_indexes[i]].rewardReferenceEpoch = 0;
        /**
         * @dev if the rewardReferenceEpoch is in the future, it means that the user deposited in the current
         * epoch (currentEpoch). Therefore next epoch's total stake needs to be reduced by the user's deposit.
         *
         * If the rewardReferenceEpoch is less than or equal to the currentEpoch it means that the user
         * either deposited or claimed rewards in a past epoch. Either way it means that the user's
         * deposit cannot possible be in the future therefore the current epoch's total stake needs to be reduced
         */
        _epochs[
            currentEpoch < deposit.rewardReferenceEpoch
                ? deposit.rewardReferenceEpoch
                : currentEpoch
        ].totalStake -= deposit.amount;
        totalAmount += deposit.amount;
        unchecked {
            i++;
        }
    }
    return (totalAmount, totalRewards);
}

/**
 * @param _indexes A list of deposit indexes
 * @return totalRewards Total amount of rewards based on _indexes
 */
function _claimMultiple(uint256[] calldata _indexes) private returns (uint256 totalRewards) {
    uint256 length = _indexes.length;
    _validateListLength(length);
    uint256 total = getTotalDeposits(_msgSender());
    uint32 currentEpoch = _currentEpoch;
    for (uint256 i; i < length; ) {
        if (total <= _indexes[i]) revert DepositNotFound(_indexes[i]);
        totalRewards += _calculateRewards(_msgSender(), _indexes[i]);
        _deposits[_msgSender()][_indexes[i]].rewardReferenceEpoch = currentEpoch;
        unchecked {
            i++;
        }
    }
    if (totalRewards == 0) revert NoRewards();
    return totalRewards;
}
