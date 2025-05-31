# Project Name
yDAI

# Description
The `earn()` function for obtaining returns and the `withdraw()` function for unstaking tokens in the contract rely on the strategy provided by a single liquidity pool, `StrategyDAIPools`. The attacker manipulated the token quantity in the liquidity pool `StrategyDAIPools` through flash loans, thereby manipulating its staking strategy. Subsequently, the attacker repeatedly called the `earn()` and `withdraw()` functions to obtain unearned profits.

# Root Cause
```solidity
function earn() public {
  uint _bal = available();
  token.safeTransfer(controller, _bal);
  Controller(controller).earn(address(token), _bal);
}

// No rebalance implementation for lower fees and faster swaps
function withdraw(uint _shares) public {
  uint r = (balance().mul(_shares)).div(totalSupply());
  _burn(msg.sender, _shares);
  
  // Check balance
  uint b = token.balanceOf(address(this));
  if (b < r) {
      uint _withdraw = r.sub(b);
      Controller(controller).withdraw(address(token), _withdraw);
      uint _after = token.balanceOf(address(this));
      uint _diff = _after.sub(b);
      if (_diff < _withdraw) {
          r = b.add(_diff);
      }
  }
  
  token.safeTransfer(msg.sender, r);
}