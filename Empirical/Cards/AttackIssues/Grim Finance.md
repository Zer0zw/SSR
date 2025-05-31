# Project Name
Grim Finance

# Description
The `depositFor` function in the contract, which is used for staking tokens, lacks restrictions and allows users to deposit any token contract. However, the function does not verify the legitimacy of the token specified by the user. Attackers exploit this vulnerability by passing the address of a malicious token contract when calling the `depositFor` function, thereby facilitating a re-entrancy attack.

# Root Cause
```solidity
function depositFor(address token, uint _amount,address user ) public {

    uint256 _pool = balance();
    IERC20(token).safeTransferFrom(msg.sender, address(this), _amount);
    earn();
    uint256 _after = balance();
    _amount = _after.sub(_pool); // Additional check for deflationary tokens
    uint256 shares = 0;
    if (totalSupply() == 0) {
        shares = _amount;
    } else {
        shares = (_amount.mul(totalSupply())).div(_pool);
    }
    _mint(user, shares);
}