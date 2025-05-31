# Project Name
Vee Finance

# Description
The oracle machine, a crucial component for determining the price feeds in the Vee Finance platform, was configured to rely solely on the price of the Pangolin pool. This design decision made the entire system susceptible to price manipulation. The oracle refreshed its price feed when there was a more than 3% fluctuation in the Pangolin pool’s price. This threshold was exploitable, as it provided a clear target for attackers looking to manipulate the price feed.

# Root Cause
Not Open Source