# Project Name
PancakeHunny

# Description
PancakeHunny Finance forked the DeFi protocol from the yield aggregator PancakeBunny. The attacker exploited AutoShark using the same method as the attack on PancakeBunny.

# Root Cause
```solidity
function mintFor(address flip, uint _withdrawalFee, uint _performanceFee, address to, uint, uint boostRate) override external onlyMinter returns(uint mintAmount) {
    uint feeSum = _performanceFee.add(_withdrawalFee);
    uint tax = 0;
    if (flip == address(PANTHER)) {
        tax = feeSum.mul(PANTHER.transferTaxRate()).div(10000);
    }
    if (feeSum > 0) {
        feeSum = feeSum.sub(1);
    }
    // Where 100000 is the dust
    if (feeSum > 100000) {
        IBEP20(flip).safeTransferFrom(msg.sender, address(this), feeSum.sub(tax));

        uint sharkBNBAmount = tokenToSharkBNB(flip, IBEP20(flip).balanceOf(address(this)));
        address flipToken = sharkBNBFlipToken();
        IBEP20(flipToken).safeTransfer(sharkPool, sharkBNBAmount);
        IStakingRewards(sharkPool).notifyRewardAmount(sharkBNBAmount);

        uint contribution = helper.tvlInBNB(flipToken, sharkBNBAmount).mul(_performanceFee).div(feeSum);
        uint mintShark = amountSharkToMint(contribution).mul(boostRate).div(10000);
        mint(mintShark, to);
        mintAmount = mintShark;
    }
}