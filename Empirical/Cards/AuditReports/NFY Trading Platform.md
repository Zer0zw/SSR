# Project Name
NFY Trading Platform

# Description
1. Non handling of zero address can result in funds getting locked. 
    
    In NFYTradingPlatform.sol, there is no check for zero (0x00) address for devAddress and communityFund address variables in setDevFeeAddress() and setCommunityFeeAddress() functions respectively. These variables are used in createLimitOrder() for transfer of NFY Token. If any of these addresses are set to zero (0x00) then the user's transactions to create new orders will always revert. This can result in ambiguous contract state.

# Root Cause
Not Open Source