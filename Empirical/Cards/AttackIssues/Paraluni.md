# Project Name
Paraluni

# Description
The `depositByAddLiquidity` function within the MasterChef contract does not check whether the LP token constructed by the incoming token array parameter `_tokens` corresponds to the specified `_pid` parameter and is consistent with the LP token (USDT-BUSD LP) in the pool. There is also no reentrancy restriction when adding liquidity calculations, leading to the use of malicious contracts to conduct reentrancy attacks.

# Root Cause
```solidity
function depositByAddLiquidity(uint256 _pid, address[2] memory _tokens, uint256[2] memory _amounts) external{
    require(_amounts[0] > 0 && _amounts[1] > 0, "!0");
    address[2] memory tokens;
    uint256[2] memory amounts;
    (tokens[0], amounts[0]) = _doTransferIn(msg.sender, _tokens[0], _amounts[0]);
    (tokens[1], amounts[1]) = _doTransferIn(msg.sender, _tokens[1], _amounts[1]);
    depositByAddLiquidityInternal(msg.sender, _pid, tokens,amounts);
}

function addLiquidityInternal(address _lpAddress, address _user, address[2] memory _tokens, uint256[2] memory _amounts) internal returns (uint){
    //Stack too deep, try removing local variables
    DepositVars memory vars;
    approveIfNeeded(_tokens[0], address(paraRouter), _amounts[0]);
    approveIfNeeded(_tokens[1], address(paraRouter), _amounts[1]);
    vars.oldBalance = IERC20(_lpAddress).balanceOf(address(this));
    (vars.amountA, vars.amountB, vars.liquidity) = paraRouter.addLiquidity(_tokens[0], _tokens[1], _amounts[0], _amounts[1], 1, 1, address(this), block.timestamp + 600);
    vars.newBalance = IERC20(_lpAddress).balanceOf(address(this));
    require(vars.newBalance > vars.oldBalance, "B:E");
    vars.liquidity = vars.newBalance.sub(vars.oldBalance);
    addChange(_user, _tokens[0], _amounts[0].sub(vars.amountA));
    addChange(_user, _tokens[1], _amounts[1].sub(vars.amountB));
    return vars.liquidity;
}