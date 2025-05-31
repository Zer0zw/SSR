# Project Name
AlemX

# Description
1. Contract Centralization Risk
    
    The contract's functionality and behavior are heavily dependent on external parameters or configurations. While external configuration can offer flexibility, it also poses several centralization risks that warrant attention. Centralization risks arising from the dependence on external configuration include Single Point of Control, Vulnerability to Attacks, Operational Delays, Trust Dependencies, and Decentralization Erosion.
    
    Specifically, the ****`DEFAULT_ADMIN_ROLE` has the authority to update the token used for airdrops. This capability allows the admin to change the token type at any point, potentially impacting the value or relevance of the tokens being airdropped. Additionally, the `SENDER_ROLE`, which can distribute tokens to specified addresses, adds another layer of centralization, as this role can selectively decide the recipients of the token distributions. This combination of centralized control points can lead to potential misuse or uneven distribution strategies.

# Root Cause
```solidity
// Contract Centralization Risk
function dropTokensToAll(
    address[] memory recipients,
    uint256[] memory amounts
) external onlyRole(SENDER_ROLE) {
    ...
}

function updateToken(address newToken) public onlyRole(DEFAULT_ADMIN_ROLE) {
    ...
    token = IERC20(newToken);
    ONE_TOKEN = 10 ** IERC20Metadata(newToken).decimals();
    emit TokenUpdated(newToken);
}