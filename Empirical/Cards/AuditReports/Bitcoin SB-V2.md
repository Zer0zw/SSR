# Project Name
Bitcoin SB-V2Bitcoin SB-V2

# Description
1. Possible out-of-order function
    
    Doing a loop through all the stakeholders and processing them could burn a lot of gas. While having that on the writable only Admin functions may be risky in the meaning of the gas amount but on the view-only functions, it will make those functions inaccessible.

# Root Cause
```solidity
/*
* @dev End the staking pool
*/
function end() public onlyOwner returns (bool){
    require(!ended, "Staking already ended");
    address _aux;
    
    for(uint i = 0; i < holders.length(); i = i.add(1)){
        _aux = holders.at(i);
        rewardEnded[_aux] = getPendingRewards(_aux);
        unclaimed[_aux] = 0;
        stakingTime[_aux] = block.timestamp;
        progressiveTime[_aux] = block.timestamp;
        alreadyProgUnstaked[_aux] = 0;
        amountPerInterval[_aux] = depositedTokens[_aux].div(number_intervals);
    }
    
    ended = true;
    endTime = block.timestamp;
    return true;
}