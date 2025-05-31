# Project Name
Biswap

# Description

1. Confusing Reward Calculation
    
    The **`fpOwed`** represents the accumulated reward and is used to calculate farmed rewards from specific liquidity positions on pool in function **`harvest`**. When **`poolAddress == address(LIQUIDITY_MANAGER)`**, the **`fpOwed`** is acquired from **`LIQUIDITY_MANAGER.liquidities(liqId)`** and it only get updated in function **`updateLiquidity`** in contract **`LiquidityManager`**. The **`fpOwed`** doesn't get updated to the latest value in the function **`harvest`** before the reward calculation.
    
    The reward calculation in function **`harvest`** and **`pendingReward`** differs. The **`fpScale_128`** in function **`pendingReward`** doesn't multiply **`farmsRatio`**.
    
2. Potential Missing Reward
    
    The function **`burn`** will burn a generated NFT. The NFT can be used to harvest farmed rewards from specific liquidity positions on pool in contract FarmsDistributor. The function **`burn`** doesn't check if the reward attached to this NFT is already harvested, and the user can not get his unclaimed reward after burning the NFT.

# Root Cause
Not Open Source
