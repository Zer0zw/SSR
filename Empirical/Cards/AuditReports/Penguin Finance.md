# Project Name
Penguin Finance

# Description
1. **Centralization Risk**
    
    The role **`owner`** has the authority over the listed functions:
    
    **IglooMaster.sol:**
    
    - **`add()`**
    - **`set()`**
    - **`migrateStrategy()`**
    - **`setStrategy()`**
    - **`manualMint()`**
    - **`transferMinter()`**
    - **`setDev()`**
    - **`setNest()`**
    - **`setNestAllocatorAddress()`**
    - **`setPerfomanceFeeAddress()`**
    - **`setDevMintBips()`**
    - **`setNestMintBips()`**
    - **`setNestSplitBips()`**
    - **`setPefiEmission()`**
    - **`setDefaultIpefiDistributionBips()`**
    - **`modifyApprovedContracts()`**
    - **`setOnlyApprovedContractOrEOAStatus()`**
    - **`inCaseTokensGetStuck()`**
    - **`setAllowances()`**
    - **`revokeAllowance()`**
    - **`setPerformanceFeeBips()`**
    - **`renounceOwnership()`**
    - **`transferOwnership()`** in **`Ownable`**
    - **`increaseRewardDebt()`**
    - **`decreaseRewardDebt()`**
    - **`setRewardDebt()`**
    - **`increaseRewardTokensPerShare()`**
    - **`withdraw()`** in **`IglooStrategyBase`**
    - **`inCaseTokensGetStuck()`** in **`IglooStrategyBase`**
    - **`revokeAllowance()`** in **`IglooStrategyBase`**
    - **`migrate()`** in **`IglooStrategyBase`**
    - **`transferOwnership()`** in **`IglooStrategyBase`**
    - **`setPerformanceFeeBips()`** in **`IglooStrategyBase`**
    - **`deposit()`** in **`IglooStrategyForPangolinStaking`**
    - **`withdraw()`** in **`IglooStrategyForPangolinStaking`**
    - **`migrate()`** in **`IglooStrategyForPangolinStaking`**
    - **`onMigration()`** in **`IglooStrategyForPangolinStaking`**
    - **`setAllowances()`** in **`IglooStrategyForPangolinStaking`**
    
    **PenguinNestsV2.sol:**
    
    - **`setPaperHandsPenalty()`**
    - **`setLuckyPenguinRewardBP()`**
    - **`setLuckyPenguinEnabled()`**
    - **`setLuckyPenguinInterval()`**
    - **`setLuckyPenguinMinimumDeposit()`**
    - **`renounceOwnership()`**
    - **`transferOwnership()`**
    - **`inCaseTokensGetStuck()`**
    
    The **`strategy`** contract has the authority over the listed functions:
    
    - **`accountAddedLP()`**
    
    Any compromise to the key role account may allow a potential hacker to take advantage of this and execute malicious acts.

# Root Cause
Not Open Source