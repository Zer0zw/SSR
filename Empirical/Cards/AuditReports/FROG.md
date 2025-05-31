# Project Name
FROG

# Description
1. Token Address Modification
    
    The contract owner has the authority to change the token address of the token by calling the `changeTokenAddress` function of the contract. While this function does have checks to prevent the new token address from being zero or the same as the current one, it does not account for the potential loss of user balances. If the token address is changed, users will not be able to call the `claim` or `unstake` function using the older token address. Since the contract will point to a new token address after the change, any token balance of the users regarding the previous token will be lost. This is because the `claim` and `unstake` functions transfer tokens from the contract to the user, and after the token address change, the contract's balance of the old token becomes irrelevant.

# Root Cause
```solidity
// Token Address Modification
function changeTokenAddress(address newTokenAddress)
    public
    onlyOwner
    returns (bool)
{
    require(newTokenAddress != address(0), "Token address cannot be 0");
    require(
        newTokenAddress != address(token),
        "Token address cannot be the same as the current one"
    );
    emit TokenAddressUpdated(address(token), newTokenAddress);
    token = ERC20(newTokenAddress);
    return true;
}

function claim() public returns (bool) {
    ...
    token.transfer(msg.sender, rewardToClaim);
    return true;
}    

function unstake(uint256 _amount) public returns (bool) {
    ...
        token.transfer(burnAddress, burn);
    }

    //send % to user
    token.transfer(msg.sender, users);

    }else{

        token.transfer(msg.sender, amount);

    }
    ...
    return true;
}