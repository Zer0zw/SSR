# Project Name
Rosy

# Description
1. Contract Centralization Risk
    
    The contract's functionality and behavior are heavily dependent on external parameters or configurations. While external configuration can offer flexibility, it also poses several centralization risks that warrant attention. Centralization risks arising from the dependence on external configuration include Single Point of Control, Vulnerability to Attacks, Operational Delays, Trust Dependencies, and Decentralization Erosion.
    
    Specifically, the contract owner has the authoriry to set key variables, that impact the functionality of the contract. This capability grants the contract owner substantial control.

# Root Cause
```solidity
// Contract Centralization Risk
function setBurnInfluencingFactor(IBurnInfluencingFactor _burnInfluencingFactor) external onlyOwner {
    burnt.setBurnInfluencingFactor(_burnInfluencingFactor);
}

function setburnThreshold(uint256 _burnThreshold) external onlyOwner {
    burnt.setburnThreshold(_burnThreshold);
}

function setAllowPublicBurn(bool _allowPublicBurn) public onlyOwner {
    allowPublicBurn = _allowPublicBurn;
    emit AllowPublicBurnUpdated(msg.sender, allowPublicBurn);
}