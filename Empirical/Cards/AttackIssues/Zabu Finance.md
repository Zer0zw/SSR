# Project Name
Zabu Finance

# Description
The ZabuFarm contract records the amount of collateral a user inputs directly when staking, rather than recording the actual amount of tokens received by the contract. However, when a user withdraws, the ZabuFarm contract allows them to withdraw the full amount of collateral recorded at the time of staking. Since the SPORE token requires a transaction fee during transfers (collected by the SPORE contract), attackers exploit this discrepancy by repeatedly performing staking and withdrawing operations within the ZabuFarm contract. This depletes the SPORE funds in the ZabuFarm contract to a very low level.

# Root Cause
Not Open Source