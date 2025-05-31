# Project Name
Sanshu Inu

# Description
In the contract, the logic for calculating the amount of staked tokens to be withdrawn within the `withdraw` function is contingent upon the state of the liquidity pool, specifically `pool.accMfundPerShare`. The `KEANU` token exhibits a deflationary mechanism, whereby 2% of each transaction amount is burned. Exploiting this characteristic, attackers repeatedly invoke the `deposit` and `withdraw` functions, thereby progressively diminishing the quantity of `KEANU` tokens within the liquidity pool. Subsequently, after manipulating the liquidity pool, the attacker calls the `updatePool` function to revise the value of `pool.accMfundPerShare`, and ultimately invokes the withdraw function to illegitimately obtain unearned profits.

# Root Cause
```solidity
/// @notice Updates a specific pool to track all of the rewards accrued up to the TX block
/// @param _pid ID of the pool
function updatePool(uint256 _pid) public {
    require(_pid < poolInfo.length, "updatePool: invalid _pid");

    PoolInfo storage pool = poolInfo[_pid];
    if (block.number <= pool.lastRewardBlock) {
        return;
    }

    uint256 tokenContractSupply = pool.tokenContract.balanceOf(address(this));
    if (tokenContractSupply == 0) {
        pool.lastRewardBlock = block.number;
        return;
    }

    uint256 maxEndBlock = block.number <= endBlock ? block.number : endBlock;
    uint256 multiplier = getMultiplier(pool.lastRewardBlock, maxEndBlock);

    // No point in doing any more logic as the rewards have ended
    if (multiplier == 0) {
        return;
    }

    uint256 mFundReward = multiplier.mul(mFundPerBlock).mul(pool.allocPoint).div(totalAllocPoint);

    pool.accMfundPerShare = pool.accMfundPerShare.add(mFundReward.mul(1e18).div(tokenContractSupply));
    pool.lastRewardBlock = maxEndBlock;
} 

/// @notice Allows a user to withdraw any ERC20 tokens staked in a pool
/// @dev Partial withdrawals permitted
/// @param _pid Pool ID
/// @param _amount Being withdrawn
function withdraw(uint256 _pid, uint256 _amount) external {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][msg.sender];

    require(user.amount >= _amount, "withdraw: _amount not good");

    updatePool(_pid);

    uint256 pending = user.amount.mul(pool.accMfundPerShare).div(1e18).sub(user.rewardDebt);
    if (pending > 0) {
        safeMfundTransfer(msg.sender, pending);
    }

    if (_amount > 0) {
        user.amount = user.amount.sub(_amount);
        pool.tokenContract.safeTransfer(address(msg.sender), _amount);
    }

    user.rewardDebt = user.amount.mul(pool.accMfundPerShare).div(1e18);
    emit Withdraw(msg.sender, _pid, _amount);
}