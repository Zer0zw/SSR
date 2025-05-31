# Project Name
Nebula Revelation

# Description
In the `withdrawNft` function, which is used to unstake NFTs in the contract, a transfer occurs before updating the staked NFT quantity and other state variables. Exploiting this vulnerability, the attacker launched a reentrancy attack.

# Root Cause
```solidity
function withdrawNft(uint256 _index) public {
    StakeInfo[] storage stakes = userStakeInfo[msg.sender];
    require(_index < stakes.length, "invalid stake index");

    uint tokenid = stakes[_index].nftTokenId;
    require(tokenid > 0, "no stake available");

    uint amount = stakes[_index].nblStakeAmount;
    uint power = getSlotPower(msg.sender, _index);

    nft.safeTransferFrom(address(this), msg.sender, tokenid);
    if (stakes[_index].inscriptionId > 0) {
        inscription.safeTransferFrom(address(this), msg.sender, stakes[_index].inscriptionId);
    }

    uint discount = calcDiscount(stakes[_index].begin, amount);
    nbl.safeTransfer(community, discount);
    nbl.safeTransfer(msg.sender, SafeMath.sub(amount, discount));

    uint multiply = slotPowerMultiplies[stakes.length - 1];
    power = SafeMath.mul(power, multiply) / 100;
    stakebook.withdraw(msg.sender, power);

    stakes[_index].nftTokenId = 0;
    stakes[_index].inscriptionId = 0;
    stakes[_index].nblStakeAmount = 0;
    stakes[_index].begin = 0;

    emit WithdrawNft(msg.sender, tokenid);
}