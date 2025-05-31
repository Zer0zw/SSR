# Project Name
Aavegotchi GHST Staking

# Description
1. Diamond facet upgrade
    
    If during an upgrade `diamondCut()` calls are executed in multiple Ethereum transactions, users may be exposed to contracts that are upgraded only partially, i.e., some of the functions are upgraded while others are not. This may result in unexpected inconsistencies.

# Root Cause
Not Open Source