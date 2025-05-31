# Project Name
Yearn Finance

# Description
The vulnerability was caused by a bug in the misconfigured yUSDT vault. Specifically, the contract’s fulcrum used the iUSDC token instead of the iUSDT token, leading to a mistaken dependency on the pool’s underlying token. This vulnerability was exploited to mint a large amount of yUSDT tokens. The misconfiguration was present at the time of deployment and went unnoticed for approximately 1000 days.

# Root Cause
```solidity
constructor () public ERC20Detailed("iearn USDT", "yUSDT", 6) {
  token = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
  apr = address(0xdD6d648C991f7d47454354f4Ef326b04025a48A8);
  dydx = address(0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e);
  aave = address(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8);
  fulcrum = address(0xF013406A0B1d544238083DF0B93ad0d2cBE0f65f);
  aaveToken = address(0x71fc860F7D3A592A4a98740e39dB31d25db65ae8);
  compound = address(0x39AA39c021dfbaE8faC545936693aC917d5E7563);
  dToken = 0;
  approveToken();
}