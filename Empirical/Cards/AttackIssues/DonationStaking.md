# Project Name
DonationStaking

# Description
There was no access control over the `setStakingContract()` function, so anyone could call it to modify the staking contract and staking token.

# Root Cause
```solidity
/**
    * @dev Function to set staking contract and withdraw previous stakings and send it to avatar
    */
function setStakingContract(
    address _stakingContract,
    address[] memory _ethToStakingTokenSwapPath
) external {
    require(
        _ethToStakingTokenSwapPath.length >= 2 &&
            _ethToStakingTokenSwapPath[0] == address(0x0) &&
            _ethToStakingTokenSwapPath[_ethToStakingTokenSwapPath.length - 1] ==
            address(SimpleStaking(_stakingContract).token()),
        "Invalid Path"
    );
    (uint256 stakingAmount, ) = stakingContract.getProductivity(address(this));
    if (stakingAmount > 0) stakingContract.withdrawStake(stakingAmount, false);
    uint256 stakingTokenBalance = stakingToken.balanceOf(address(this));
    uint256 safeAmount = IHasRouter(this).maxSafeTokenAmount(
        address(stakingToken),
        address(0x0),
        stakingTokenBalance,
        maxLiquidityPercentageSwap
    );
    if (safeAmount > 0)
        IHasRouter(this).swap(
            stakingTokenToEthSwapPath,
            safeAmount,
            0,
            address(this)
        );
    uint256 remainingStakingTokenBalance = stakingToken.balanceOf(
        address(this)
    );
    if (remainingStakingTokenBalance > 0)
        stakingToken.transfer(avatar, remainingStakingTokenBalance);
    stakingContract = SimpleStaking(_stakingContract);
    stakingToken = stakingContract.token();
    stakingToken.approve(address(stakingContract), type(uint256).max); //we trust the staking contract
    stakingToken.approve(address(uniswap), type(uint256).max); // we trust uniswap router
    ethToStakingTokenSwapPath = _ethToStakingTokenSwapPath;
    address[] memory tempStakingToEthSwapPath = new address[](
        _ethToStakingTokenSwapPath.length
    );
    uint256 k = 0;
    for (uint256 i = _ethToStakingTokenSwapPath.length; i > 0; --i) {
        tempStakingToEthSwapPath[k] = _ethToStakingTokenSwapPath[i - 1];
        k += 1;
    }
    stakingTokenToEthSwapPath = tempStakingToEthSwapPath;
}