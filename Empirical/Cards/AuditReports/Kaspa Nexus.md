# Project Name
Kaspa Nexus

# Description
The contract's functionality and behavior are heavily dependent on external parameters or configurations. While external configuration can offer flexibility, it also poses several centralization risks that warrant attention. Centralization risks arising from the dependence on external configuration include Single Point of Control, Vulnerability to Attacks, Operational Delays, Trust Dependencies, and Decentralization Erosion.

Additionally, the contract is currently implementing a `require` statement to limit the number of tokens purchased in each phase based on the total tokens available for that stage. However, when the limit of tokens available for a stage is reached, the contract does not automatically proceed to the next phase. Instead, it relies on the contract owner to manually increment the current stage to allow the presale to continue. This reliance could introduce delays or potential management errors in the presale process.

# Root Cause
```solidity
function setPresaleStatus(bool _status) external onlyOwner {
    presaleStatus = _status;
}

function endPresale() external onlyOwner {
    require(!isPresaleEnded, "Already ended");
    isPresaleEnded = true;
}
function whitelistAddresses(
    address[] memory _addresses,
    uint256[] memory _tokenAmount,
    uint256[] memory _refAmount
) external onlyOwner {
...
}
function setCurrentStage(uint256 _stageNum) public onlyOwner {
    currentStage = _stageNum;
}

require(
		phases[currentStage].tokenSold + numberOfTokens <=
		    phases[currentStage].tokensToSell,
		"Phase Limit Reached"
);