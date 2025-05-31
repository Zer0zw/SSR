# Project Name
Eleven Finance

# Description
This incident was due to a bug in the `emergencyBurn()` function of `ElevenNeverSellVault` contract that is designed to allow user to withdraw funds and burn shares. However, the function doesn’t burn shares after transferring funds to users. The hacker made use of this bug and drained funds from at least four vaults of `ElevenNeverSellVault`. 

# Root Cause
```solidity
/**
 * @dev A helper function to call withdraw() with all the sender's funds.
 */
function withdrawAll() external {
    withdraw(balanceOf(msg.sender));
}

/**
 * @dev Function to exit the system. The vault will withdraw the required tokens
 * from the strategy and pay up the token holder. A proportional number of IOU
 * tokens are burned in the process.
 */
function withdraw(uint256 _shares) public {
    claim(msg.sender);//TODO double check inhereted correctly
    _burn(msg.sender, _shares);
    uint avai = available();
    if(avai<_shares) IMasterMind(mastermind).withdraw(nrvPid, (_shares.sub(avai)));
    token.safeTransfer(msg.sender, _shares);
    emit Withdrawn(msg.sender, _shares, block.number);
    updateDebt(msg.sender);
}

function emergencyBurn() public {
    uint balan = balanceOf(msg.sender);
    uint avai = available();
    if(avai<balan) IMasterMind(mastermind).withdraw(nrvPid, (balan.sub(avai)));
    token.safeTransfer(msg.sender, balan);
    emit Withdrawn(msg.sender, balan, block.number);
}