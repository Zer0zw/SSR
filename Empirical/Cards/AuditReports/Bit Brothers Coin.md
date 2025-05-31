# Project Name
Bit Brothers Coin

# Description
1. Centralization Risk
    
    In the contract **`Stake`** the role **`_owner`** has authority over the functions shown below. Any compromise to the **`_owner`** account may allow the hacker to take advantage of this authority.
    
    - stake(): set stake balance for specific accounts.
    - getReward(): send rewards to specific accounts.
2. Users May Not Get Back All of Their Liquidity
    
    According to the logic of the **`_transfer()`** function, when users add liquidity to **`_uniswapV2Pair`**, most of their liquidity will be transferred to a dead address. Users can receive up to 10,000 liquidity. In return, they can earn dividends from a tracker contract and rewards from staking contracts. However, this design might lead to user losses, as they could receive less income while losing most of their liquidity.

# Root Cause
```solidity
// Centralization Risk
  function stake(address account , uint amount) public onlyOwner nonReentrant  updateReward(account){
    _totalSupply = _totalSupply.add(amount);
    _balances[account] =  _balances[account].add(amount);
}


function getReward(address account) public onlyOwner nonReentrant updateReward(account) {
    uint256 reward = rewards[account];
    if (reward > 0) {
        rewards[account] = 0;
        safeTransferFrom(_token,address(0),account,reward );
    }
}

// Users May Not Get Back All of Their Liquidity
if(automatedMarketMakerPairs[to]&&_isAddLiquidity() &&from != owner() && to != owner() ){
        uint256 addUSDTAmount = getAddLiquidity();
        // console2.log("addUSDTAmount:", addUSDTAmount);
        require(addUSDTAmount >= 50e18 ,"Not Mint");
        IUniswapV2Pair(_uniswapV2Pair).mint(address(this));
        // console2.log("pair balance of Ant:", IUniswapV2Pair(_uniswapV2Pair).balanceOf(address(this)));
        if(IUniswapV2Pair(_uniswapV2Pair).balanceOf(address(this))>10000 ){
            IUniswapV2Pair(_uniswapV2Pair).transfer(_uniswapV2Pair,10000);
            IUniswapV2Pair(_uniswapV2Pair).burn(_router);
            try
            dividendTracker.setBalance(
                payable(from),
                dividendTracker.balanceOf(from) + IUniswapV2Pair(_uniswapV2Pair).balanceOf(address(this))
            )
            {} catch {}
            takeLpDead(from,IUniswapV2Pair(_uniswapV2Pair).balanceOf(address(this)));
            IUniswapV2Pair(_uniswapV2Pair).transfer(address(0xdead),IUniswapV2Pair(_uniswapV2Pair).balanceOf(address(this)));
            IERC20(_token).transferFrom(_router, _uniswapV2Pair,  IERC20(_token).balanceOf(_router) );
            _basicTransfer(_router,_uniswapV2Pair,balanceOf(_router));
        }
    }