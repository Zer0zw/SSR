# Project Name
UvToken

# Description
The essential functions of UvToken’s vault contract for withdrawals does not verify the validity of user input, which allows the attacker to feed in the malicious contract address and utilize it to return the withdrawn amount of tokens to deplete the pool.

# Root Cause
Not Open Source