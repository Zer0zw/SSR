# Project Name
PancakeBunny

# Description
In the contract, the function mintForV2, used for minting equity tokens, calculates the number of tokens to mint, mintBunny, based on the quantity of tokens in a single liquidity pool. The attacker manipulated the token quantity in the liquidity pool through a flash loan attack, thereby minting an undeserved large amount of equity tokens.

# Root Cause
```solidity
function mintForV2(address asset, uint _withdrawalFee, uint _performanceFee, address to, uint) external payable override onlyMinter {
    uint feeSum = _performanceFee.add(_withdrawalFee);
    _transferAsset(asset, feeSum);

    if (asset == BUNNY) {
        IBEP20(BUNNY).safeTransfer(DEAD, feeSum);
        return;
    }

    uint bunnyBNBAmount = _zapAssetsToBunnyBNB(asset, feeSum, true);
    if (bunnyBNBAmount == 0) return;

    IBEP20(BUNNY_BNB).safeTransfer(BUNNY_POOL, bunnyBNBAmount);
    IStakingRewards(BUNNY_POOL).notifyRewardAmount(bunnyBNBAmount);

    (uint valueInBNB,) = priceCalculator.valueOfAsset(BUNNY_BNB, bunnyBNBAmount);
    uint contribution = valueInBNB.mul(_performanceFee).div(feeSum);
    uint mintBunny = amountBunnyToMint(contribution);
    if (mintBunny == 0) return;
    _mint(mintBunny, to);
}
    
function _zapAssetsToBunnyBNB(address asset, uint amount, bool fromV2) private returns (uint bunnyBNBAmount) {
    uint _initBunnyBNBAmount = IBEP20(BUNNY_BNB).balanceOf(address(this));

    if (asset == address(0)) {
        zapBSC.zapIn{ value : amount }(BUNNY_BNB);
    }
    else if (keccak256(abi.encodePacked(IPancakePair(asset).symbol())) == keccak256("Cake-LP")) {
        IPancakeRouter02 router = fromV2 ? routerV2 : routerV1;

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

        zapBSC.zapInToken(token0, amountToken0, BUNNY_BNB);
        zapBSC.zapInToken(token1, amountToken1, BUNNY_BNB);
    }
    else {
        if (IBEP20(asset).allowance(address(this), address(zapBSC)) == 0) {
            IBEP20(asset).safeApprove(address(zapBSC), uint(- 1));
        }

        zapBSC.zapInToken(asset, amount, BUNNY_BNB);
    }

    bunnyBNBAmount = IBEP20(BUNNY_BNB).balanceOf(address(this)).sub(_initBunnyBNBAmount);
}

function valueOfAsset(address asset, uint amount) public view override returns (uint valueInBNB, uint valueInUSD) {
    if (asset == address(0) || asset == WBNB) {
        valueInBNB = amount;
        valueInUSD = amount.mul(priceOfBNB()).div(1e18);
    }
    else if (keccak256(abi.encodePacked(IPancakePair(asset).symbol())) == keccak256("Cake-LP")) {
        if (IPancakePair(asset).totalSupply() == 0) return (0, 0);

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
        if (IBEP20(asset).balanceOf(pair) == 0) return (0, 0);

        valueInBNB = IBEP20(pairToken).balanceOf(pair).mul(amount).div(IBEP20(asset).balanceOf(pair));
        if (pairToken != WBNB) {
            (uint pairValueInBNB,) = valueOfAsset(pairToken, 1e18);
            valueInBNB = valueInBNB.mul(pairValueInBNB).div(1e18);
        }
        valueInUSD = valueInBNB.mul(priceOfBNB()).div(1e18);
    }
}