# Project Name
Deeplink

# Description
The contract is processing initializer arguments that have not been properly sanitized and checked that they form the proper shape. These variables may produce vulnerability issues.

# Root Cause
```solidity
function initialize(
    string memory name_,
    string memory symbol_,
    uint256 maxSupply_,
    address treasure_
) public initializer {
    require(treasure_ != address(0), "Invalid treasure address");

    __ReentrancyGuard_init();
    __ERC721A_init(name_, symbol_);
    __Ownable_init();

    maxPublicMintForEach = 1;

    MAX_SUPPLY = maxSupply_;
    MAX_OWNER_SUPPLY = 50;

    treasure = payable(treasure_);
    priceForEach = 0.5 ether;
    maxPriceForEach = 2 ether;
}