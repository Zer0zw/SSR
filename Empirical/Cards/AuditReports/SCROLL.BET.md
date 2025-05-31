# Project Name
SCROLL.BET

# Description
1. Stops Transactions
    
    Initially, `tradingOpen` is false, so as a result, users are unable to perform transactions involving the Uniswap pair. Once the `openTrading` function is called by the contract owner, `tradingOpen` is set to true, enabling trading on Uniswap and the contract owner cannot disable it again.

# Root Cause
```solidity
// Stops Transactions
function _transfer(address from, address to, uint256 value) internal {
  ...
  if (from != owner() && to != owner()) {
      if (
          (from == uniswapV2Pair && to != address(uniswapV2Router)) ||
          (to == uniswapV2Pair && from != address(this))
      ) {
          if (!tradingOpen) {
              revert("Trading is not open yet");
          }
              unchecked {
                  _taxAmt = (value * tax) / 1e4;
              }
          }
    }
    ...
}

function openTrading(address uniswapV2Router_) external onlyOwner {
    require(uniswapV2Router_ != address(0), "Invalid router address");
    require(!tradingOpen, "trading is already open");

    uniswapV2Router = IUniswapV2Router02(uniswapV2Router_);
    _approve(address(this), address(uniswapV2Router), _totalSupply);

    // check if the pair already exists
    uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(
        address(this),
        uniswapV2Router.WETH()
    );

    if (uniswapV2Pair == address(0)) {
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
    }

    uniswapV2Router.addLiquidityETH{value: address(this).balance}(
        address(this),
        balanceOf(address(this)),
        0,
        0,
        owner(),
        block.timestamp
    );
    IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);

    tradingOpen = true;
}