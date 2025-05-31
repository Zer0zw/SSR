# Project Name
Convergence Finance

# Description
The `claimMultipleStaking` function, used for minting governance tokens in exchange for staked tokens within the contract, lacks proper verification of the staked account specified by the `_account` parameter. Without validation of the staking contract, the hacker has been able to pass a malicious contract that he deployed in parameter, which contains a function with the same signature as `claimCvgCvxMultiple`, allowing him to mint all tokens that were dedicated to staking emissions (58,000,000 CVG). He then dumped all newly minted CVG into liquidity pools.

# Root Cause
```solidity
/**
 * @notice Claims rewards from Convex integration on different CvxStakingPositionService.
 *         Allows the users to claim all the rewards from the Convex integration in 1 Tx.
 *         All CVG to mint are accumulated in one value.
 *         All Convex rewards are merged in one array.
 * @param claimContracts  List of contracts having a list of tokenID with a list of cycleID to claim rewards on.
 * @param _minCvgCvxAmountOut If greater than 0, converts all CVX into cvgCVX through the pool. If equals to 0 mint through the cvgCVX contract. Minimum amount to receive.
 * @param _isConvert          If true, converts all CVX into cvgCVX.
 * @param cvxRewardCount This parameter must be configured through the front-end.
 */
function claimMultipleStaking(
    ICvxStakingPositionService[] calldata claimContracts,
    address _account,
    uint256 _minCvgCvxAmountOut,
    bool _isConvert,
    uint256 cvxRewardCount
) external {
    require(claimContracts.length != 0, "NO_STAKING_SELECTED");

    /// @dev To prevent an other user than position owner claims through swapping and grief the user rewards in cvgCVX
    if (_isConvert) {
        require(msg.sender == _account, "CANT_CONVERT_CVX_FOR_OTHER_USER");
    }
    /// @dev Accumulates amounts of CVG coming from different contracts.
    uint256 _totalCvgClaimable;

    /// @dev Array merging & accumulating rewards coming from different claims.
    ICommonStruct.TokenAmount[] memory _totalCvxClaimable = new ICommonStruct.TokenAmount[](cvxRewardCount);

    /// @dev Iterate over all staking service
    for (uint256 stakingIndex; stakingIndex < claimContracts.length; ) {
        ICvxStakingPositionService cvxStaking = claimContracts[stakingIndex];

        /** @dev Claims Cvg & Cvx
         *       Returns the amount of CVG claimed on the position.
         *       Returns the array of all CVX rewards claimed on the position.
         */
        (uint256 cvgClaimable, ICommonStruct.TokenAmount[] memory _cvxRewards) = cvxStaking.claimCvgCvxMultiple(
            _account
        );
        /// @dev increments the amount to mint at the end of function
        _totalCvgClaimable += cvgClaimable;

        uint256 cvxRewardsLength = _cvxRewards.length;
        /// @dev Iterate over all CVX rewards claimed on the iterated position
        for (uint256 positionRewardIndex; positionRewardIndex < cvxRewardsLength; ) {
            /// @dev Is the claimable amount is 0 on this token
            ///      We bypass the process to save gas
            if (_cvxRewards[positionRewardIndex].amount != 0) {
                /// @dev Iterate over the final array to merge the iterated CvxRewards in the totalCVXClaimable
                for (uint256 totalRewardIndex; totalRewardIndex < cvxRewardCount; ) {
                    address iteratedTotalClaimableToken = address(_totalCvxClaimable[totalRewardIndex].token);
                    /// @dev If the token is not already in the totalCVXClaimable.
                    if (iteratedTotalClaimableToken == address(0)) {
                        /// @dev Set token data in the totalClaimable array.
                        _totalCvxClaimable[totalRewardIndex] = ICommonStruct.TokenAmount({
                            token: _cvxRewards[positionRewardIndex].token,
                            amount: _cvxRewards[positionRewardIndex].amount
                        });

                        /// @dev Pass to the next token
                        break;
                    }

                    /// @dev If the token is already in the totalCVXClaimable.
                    if (iteratedTotalClaimableToken == address(_cvxRewards[positionRewardIndex].token)) {
                        /// @dev Increments the claimable amount.
                        _totalCvxClaimable[totalRewardIndex].amount += _cvxRewards[positionRewardIndex].amount;
                        /// @dev Pass to the next token
                        break;
                    }

                    /// @dev If the token is not found in the totalRewards and we are at the end of the array.
                    ///      it means the cvxRewardCount is not properly configured.
                    require(totalRewardIndex != cvxRewardCount - 1, "REWARD_COUNT_TOO_SMALL");

                    unchecked {
                        ++totalRewardIndex;
                    }
                }
            }

            unchecked {
                ++positionRewardIndex;
            }
        }

        unchecked {
            ++stakingIndex;
        }
    }

    _withdrawRewards(_account, _totalCvgClaimable, _totalCvxClaimable, _minCvgCvxAmountOut, _isConvert);
}