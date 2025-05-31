# Project Name
BXH

# Description
This attack is caused by the use of `getReserves()` in the contract's `getITokenBonusAmount` function to obtain the instantaneous quotation, so that the attacker can make a profit by manipulating the quotation.

# Root Cause
```solidity
function getITokenBonusAmount( uint256 _pid, uint256 _amountInToken ) public view returns (uint256){
    PoolInfo storage pool = poolInfo[_pid];

    (uint112 _reserve0, uint112 _reserve1, ) = IUniswapV2Pair(pool.swapPairAddress).getReserves();
    uint256 amountTokenOut = 0; 
    uint256 _fee = 0;
    if(IUniswapV2Pair(pool.swapPairAddress).token0() == address(iToken)){
        amountTokenOut = getAmountOut( _amountInToken , _reserve0, _reserve1, _fee);
    } else {
        amountTokenOut = getAmountOut( _amountInToken , _reserve1, _reserve0, _fee);
    }
    return amountTokenOut;
}

function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut, uint256 feeFactor) private pure returns (uint ) {
    require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
    require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');

    uint256 feeBase = 10000;

    uint amountInWithFee = amountIn.mul(feeBase.sub(feeFactor));
    uint numerator = amountInWithFee.mul(reserveOut);
    uint denominator = reserveIn.mul(feeBase).add(amountInWithFee);
    uint amountOut = numerator / denominator;
    return amountOut;
}
