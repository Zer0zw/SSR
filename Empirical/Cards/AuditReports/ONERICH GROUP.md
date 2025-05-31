# Project Name
ONERICH GROUP

# Description
1. Missing Upline Reset
    
    The contract resets certain data fields during the `unstake` function. Specifically, within the `unstake` function, the following data fields are reset: `nftdata.addr`, `nftdata.timestamp`, and `nftdata.lastclaim`. However, the `nftdata.upline` field is not being reset. This implies that once an upline address is set to the `nftdata.upline` value (during the `stake` function), this upline address will remain unchanged indefinitely, even after the `unstake` process.

# Root Cause
```solidity
// Missing Upline Reset
 function unstake(uint256 tokenId ,bool is_emergency) public {
        require(tokenId>0,"Require tokenId");
        if(!is_emergency){
        claim_staking_reward(tokenId);
        }
        nft_log storage nftdata = nft_logs[tokenId];
        if(nftdata.timestamp<=block.timestamp && nftdata.addr==msg.sender){
            IERC721(NFT[nftdata.nft]).safeTransferFrom(address(this),msg.sender, tokenId);

            emit Unstake(nftdata.addr,nftdata.addr ,   tokenId, nftdata.pid);
   

            //reset data after unstaking
            nftdata.addr = address(0);
            nftdata.timestamp = 0;
            nftdata.lastclaim = 0;
            ...
          
         }
     
      }