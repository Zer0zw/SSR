# Project Name
MASTERNODED

# Description
1. Unchecked ETH Contribution
    
    The contract is not adequately verifying the `msg.value` during the `stake` function when an `assetAddress` is specified that is not zero. This oversight allows users to potentially include ETH (native currency) as `msg.value` along with token transfers specified in the `assets` array. Consequently, the `joinPool` function processes both the specified token amount and the provided `msg.value`, which can lead to unexpected financial interactions in the pool, such as incorrect token balances or unintended liquidity provisions.
    
2. Equivalent Rewards Distribution Across Pools
    
    The contract is currently structured to reward users with interest from staking only if they use a specific `poolId` associated with the noded token. This design decision results in a limitation where staking with any other `poolId` does not yield interest rewards, but users are still subject to fee deductions during the unstaking process. This imbalance could significantly reduce the incentive for users to participate in the staking process unless they are able to stake in the specific pool that contains the noded token. As a result, the contract may see lower overall participation and engagement from potential stakers.
    
3. Unnecessary Parameter Arrays Passed
    
    The contract is currently designed to accept arrays of `assets` addresses and `amounts` when staking, despite the intended functionality being to stake only one token at a time. This design allows for multiple assets to be passed arbitrarily, which can lead to confusion and potential misuse. By requiring an array of addresses and amounts, the contract adds unnecessary complexity and the risk of errors. Instead, the contract should be designed to accept only a single asset address and amount as parameters, and then create the necessary arrays within the function to comply with the requirements of the Balancer contract. This approach would streamline the staking process and ensure that only one asset is staked at a time, aligning with the intended functionality.
    
4. Contract Centralization Risk
    
    The contract's functionality and behavior are heavily dependent on external parameters or configurations. While external configuration can offer flexibility, it also poses several centralization risks that warrant attention. Centralization risks arising from the dependence on external configuration include Single Point of Control, Vulnerability to Attacks, Operational Delays, Trust Dependencies, and Decentralization Erosion.
    
    Specifically, the contract owner has the authority to change the address of the balancer contract, set the APR for node tokens (nodedApr), adjusting pool-specific fees and APRs, creating new pools, toggling the active status of pools, and even deleting pools. This centralized control extends to financial aspects that can directly affect the earnings and strategies of stakeholders involved in these pools. The ability to alter financial parameters and pool status at the discretion of a single entity can lead to potential biases, mismanagement, or abuse of power.

# Root Cause
```solidity
// Unchecked ETH Contribution
function stake(
    bytes32 poolId,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256 lockupIndex,
    bytes calldata userData
) external payable nonReentrant {
    ...

    if (assetAddress == address(0)) {
        require(msg.value == assetAmount, "Native amount sent does not match the required amount");
    } else {
        IERC20Upgradeable(assetAddress).transferFrom(msg.sender, address(this), assetAmount);
    }

    JoinPoolRequest memory request = JoinPoolRequest({
        assets: assets,
        maxAmountsIn: amounts,
        userData: userData,
        fromInternalBalance: false
    });
    balancer.joinPool{ value: msg.value }(poolId, address(this), address(this), request);
    ...

// Equivalent Rewards Distribution Across Pools
if (containsNoded(poolId)) {
    uint256 nodedInterest = calculateNodedInterest(stakex.amount, block.timestamp - stakex.startTime);
    nodedToken.transfer(msg.sender, nodedInterest);
}

// Unnecessary Parameter Arrays Passed
 function stake(
      bytes32 poolId,
      address[] calldata assets,
      uint256[] calldata amounts,
      uint256 lockupIndex,
      bytes calldata userData
  ) external payable nonReentrant {
     ...
     
      address assetAddress = address(0);
      uint256 assetAmount = 0;

      for (uint256 i = 0; i < assets.length; i++) {
          if (amounts[i] > 0) {
              assetAddress = assets[i];
              assetAmount = amounts[i];
              break;
          }
      }

      JoinPoolRequest memory request = JoinPoolRequest({
          assets: assets,
          maxAmountsIn: amounts,
          userData: userData,
          fromInternalBalance: false
      });
      balancer.joinPool{ value: msg.value }(poolId, address(this), address(this), request);
      ...

// Contract Centralization Risk
function setNodedApr(uint256 _nodedApr) public onlyOwner {
    nodedApr = _nodedApr;
}

function setPoolFee(bytes32 poolId, uint256 feePercentage) public onlyOwner {
    require(feePercentage <= 10000, "Fee percentage cannot exceed 100%");
    pools[poolId].feePercentage = feePercentage;
}

function setPoolApr(bytes32 poolId, uint256 apr) public onlyOwner {
    pools[poolId].apr = apr;
}

function getPoolDataFromBalancer(bytes32 poolId) public view returns (address[] memory, uint256[] memory, uint256) {
    (address[] memory tokens, uint256[] memory balances, uint256 lastChangeBlock) = balancer.getPoolTokens(poolId);
    return (tokens, balances, lastChangeBlock);
}

function createPool(
    ...
    
    pools[poolId] = Pool(poolId, assets, lockupDurations, apr, poolToken, isActive, feePercentage);
    poolIds.push(poolId);
}

function togglePoolActive(bytes32 poolId, bool isActive) public onlyOwner {
    require(poolId != bytes32(0), "Invalid poolId");
    pools[poolId].isActive = isActive;
}

function deletePool(bytes32 poolId) public onlyOwner {
    require(poolId != bytes32(0), "Invalid poolId");
    delete pools[poolId];
    for (uint256 i = 0; i < poolIds.length; i++) {
        if (poolIds[i] == poolId) {
            poolIds[i] = poolIds[poolIds.length - 1];
            poolIds.pop();
            break;
        }
    }
}

function setBalancerAddress(address _balancerAddress) public onlyOwner {
    require(_balancerAddress != address(0), "Balancer address cannot be zero");
    balancer = IBalancerPool(_balancerAddress);
}