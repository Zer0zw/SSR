# Project Name
BNO

# Description
The logic for calculating returns, `pendingFit`, is independent of the staking duration. Furthermore, the emergencyWithdraw function within the contract does not update the critical variable `user.nftaddition` that is essential for calculating staking returns. As a result, an attacker can exploit this vulnerability by repeatedly calling `stakeNFT` and `unstakeNFT` after `emergencyWithdraw` to repeatedly gain returns.

# Root Cause
```solidity
function emergencyWithdraw() public {

    pledgeAddress.safeTransfer(address(msg.sender), userInfo[msg.sender].allstake);
    userInfo[msg.sender].allstake = 0;
    userInfo[msg.sender].rewardDebt = 0;
}

function pendingFit(address _user) public view returns(uint256){
    uint256 curBlock = poolInfo.endBlock < block.number ? poolInfo.endBlock : block.number;
    UserInfo storage user = userInfo[_user];
    uint256 accPerShare = poolInfo.accPerShare;

    if (curBlock > poolInfo.lastRewardBlock && poolInfo.stakeSupply != 0) {
        uint256 multiplier =
            getMultiplier(poolInfo.lastRewardBlock, curBlock);
        uint256 fitReward =
            multiplier.mul(perBlock);
        accPerShare = accPerShare.add(
            fitReward.mul(1e12).div(poolInfo.stakeSupply.add(poolInfo.nftAddition))
        );
    }

    uint256 userreward = (user.allstake.add(user.nftAddition)).mul(accPerShare).div(1e12).sub(user.rewardDebt);
    return userreward;
}

function unstakeNft(uint[] memory tokenIds) public payable notPause{
		require(msg.value >= withdrawalFee,"Please pay the withdrawal fee");
        uint256 pending = pendingFit(msg.sender);
        if(pending > 0){           
            payable(wallet).transfer(msg.value);        
            safeGoodTransfer(msg.sender,pending);
            emit Withdraw(msg.sender, pending);
        }else{
			payable(wallet).transfer(msg.value); 
		}
		

    require(tokenIds.length > 0, "At least one token ID must be provided");
    for (uint i = 0; i < tokenIds.length; i++) {
	    require(nftContract.ownerOf(tokenIds[i]) == address(this), "There is no such NFT on the contract");
			
			(bool isIn, uint256 index) = firstIndexOf(userNft[msg.sender],tokenIds[i]);
				require(isIn,"This is not your NFT");
				removeByIndex(msg.sender, index);
				userInfo[msg.sender].nftAmount = userInfo[msg.sender].nftAmount.sub(1);
				nftContract.safeTransferFrom(address(this), msg.sender, tokenIds[i]);   

                poolInfo.nftSupply = poolInfo.nftSupply.sub(1);
                emit UnStakeNft(msg.sender,tokenIds[i]);         
        }
       
        updatePool();
        userInfo[msg.sender].rewardDebt = (userInfo[msg.sender].allstake.add(userInfo[msg.sender].nftAddition)).mul(poolInfo.accPerShare).div(1e12);   

       
    }
