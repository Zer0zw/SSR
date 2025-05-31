# Project Name
Merlin Labs

# Description
Merlin Labs forked the DeFi protocol from the yield aggregator PancakeBunny. The attacker exploited AutoShark using the same method as the attack on PancakeBunny.

# Root Cause
```solidity
function mintFor(address asset, uint _withdrawalFee, uint _performanceFee, address to, uint) external payable override onlyMinter {
    uint feeSum = _performanceFee.add(_withdrawalFee);
    _transferAsset(asset, feeSum);

    if (asset == MERLIN) {
        IBEP20(MERLIN).safeTransfer(0x000000000000000000000000000000000000dEaD, feeSum);
        return;
    }

    if (_withdrawalFee > 0) {
        IBEP20(asset).approve(address(this), uint(-1));
        IBEP20(asset).safeTransfer(WITHDRAWAL_FEE_ACCOUNT, _withdrawalFee);
    }

    if (_performanceFee == 0) return;

    // Burn performance fee (aka contribution fee)
    uint burnAmount = _performanceFee.mul(BURN_CONTRIBUTION).div(10000);
    _performanceFee = _performanceFee.sub(burnAmount);

    (uint valueInBNB,) = priceCalculator.valueOfAsset(asset, _performanceFee);
    uint contribution = valueInBNB;

    uint amountMerlinBNB = _zapAssetsToMerlinBNB(asset, _performanceFee);
    if (amountMerlinBNB == 0) return;

    IBEP20(MERLIN_BNB).safeTransfer(MERLIN_POOL, amountMerlinBNB);
    IStakingRewards(MERLIN_POOL).notifyRewardAmount(amountMerlinBNB);

    if (burnAmount > 1000) {
        _transferToLotteryAndBuyback(asset, burnAmount);
    }

    uint mintMerlin = amountMerlinToMint(contribution);

    if (mintMerlin == 0) return;
    _mint(mintMerlin, to);
}

function _zapAssetsToMerlinBNB(address asset, uint amount) private returns (uint merlinBNBAmout) {
    uint _initMerlinBNBAmount = IBEP20(MERLIN_BNB).balanceOf(address(this));

    if (asset == address(0)) {
        zapBSC.zapIn{ value : amount }(MERLIN_BNB);
    }
    else if (keccak256(abi.encodePacked(IPancakePair(asset).symbol())) == keccak256("Cake-LP")) {
        if (IBEP20(asset).allowance(address(this), address(router)) == 0) {
            IBEP20(asset).safeApprove(address(router), uint(- 1));
        }

        IPancakePair pair = IPancakePair(asset);
        address token0 = pair.token0();
        address token1 = pair.token1();

        (uint amountToken0, uint amountToken1) = router.removeLiquidity(token0, token1, amount, 0, 0, address(this), block.timestamp);

        if (IBEP20(token0).allowance(address(this), address(zapBSC)) == 0) {
            IBEP20(token0).safeApprove(address(zapBSC), uint(- 1));
        }
        if (IBEP20(token1).allowance(address(this), address(zapBSC)) == 0) {
            IBEP20(token1).safeApprove(address(zapBSC), uint(- 1));
        }

        zapBSC.zapInToken(token0, amountToken0, MERLIN_BNB);
        zapBSC.zapInToken(token1, amountToken1, MERLIN_BNB);
    }
    else {
        if (IBEP20(asset).allowance(address(this), address(zapBSC)) == 0) {
            IBEP20(asset).safeApprove(address(zapBSC), uint(- 1));
        }

        zapBSC.zapInToken(asset, amount, MERLIN_BNB);
    }

    merlinBNBAmout = IBEP20(MERLIN_BNB).balanceOf(address(this)).sub(_initMerlinBNBAmount);
}

function valueOfAsset(address asset, uint amount) public view returns (uint valueInBNB, uint valueInUSD) {
    if (asset == address(0) || asset == WBNB) {
        valueInBNB = amount;
        valueInUSD = amount.mul(priceOfBNB()).div(1e18);
    }
    else if (keccak256(abi.encodePacked(IPancakePair(asset).symbol())) == keccak256("Cake-LP")) {
        if (IPancakePair(asset).token0() == WBNB || IPancakePair(asset).token1() == WBNB) {
            valueInBNB = amount.mul(IBEP20(WBNB).balanceOf(address(asset))).mul(2).div(IPancakePair(asset).totalSupply());
            valueInUSD = valueInBNB.mul(priceOfBNB()).div(1e18);
        } else {
            uint balanceToken0 = IBEP20(IPancakePair(asset).token0()).balanceOf(asset);
            (uint token0PriceInBNB,) = valueOfAsset(IPancakePair(asset).token0(), 1e18);

            valueInBNB = amount.mul(balanceToken0).mul(2).mul(token0PriceInBNB).div(1e18).div(IPancakePair(asset).totalSupply());
            valueInUSD = valueInBNB.mul(priceOfBNB()).div(1e18);
        }
    }
    else {
        address pairToken = pairTokens[asset] == address(0) ? WBNB : pairTokens[asset];
        address pair = factory.getPair(asset, pairToken);
        valueInBNB = IBEP20(pairToken).balanceOf(pair).mul(amount).div(IBEP20(asset).balanceOf(pair));
        if (pairToken != WBNB) {
            (uint pairValueInBNB,) = valueOfAsset(pairToken, 1e18);
            valueInBNB = valueInBNB.mul(pairValueInBNB).div(1e18);
        }
        valueInUSD = valueInBNB.mul(priceOfBNB()).div(1e18);
    }
}