# Project Name
CC

# Description
1. `addLPTime` is overridden
    
    The `addLPTime[to]` is refreshed when adding or removing liquidity. If `pairAmount[to]` is greater than `liquidit111`, `pairAmount[to]` retains a balance. Subsequently, `addLPTime[to]` and `_shareholders”` are removed, resulting in the loss of rewards for `to`.
    
2. Unlucky wallet receives less rewards
    
    If the **`tokenBal`** is insufficient for a shareholder, only the remaining available rewards are sent to that shareholder. Consequently, some unfortunate shareholders could receive a reduced amount or even zero rewards, which is unfair.

# Root Cause
```solidity
// Unlucky wallet receives less rewards
if(theDayMint[getC()]+amount>=tokenBal){
              amount =tokenBal>theDayMint[getC()]? (tokenBal - theDayMint[getC()]):0 ;
              //Protect the program from reporting errors
          }