# Project Name
StakeWise

# Description
1. Inexistent Input Sanitization
    
    The **`withdraw()`** function fails to check the values of the **`payee`** argument.
    
2. Inexistent Input Sanitization
    
    The **`initialize()`**, **`stop()`** and **`claim()`** functions fail to check the values of the **`address`**-type arguments. In the case of **`stop()`** and **`claim()`** functions, burning an escrow may be intended functionality.
    
3. Potential `maintainer`-less Contract
    
    The **`setMaintainer()`** function allows for setting the **`maintainer`** state variable equal to the zero address, which can lead to token burning in case the **`maintainerFee`** is not equal to zero.

# Root Cause
Not Open Source
