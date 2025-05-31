# Project Name
YAM

# Description
The `rebase` function in the contract is used for initialization and modifies the value of `totalSupply`. By analyzing the logic of the `rebase` function, it is found that the code adjusts `totalSupply` according to `yamsScalingFactor`. Since `yamsScalingFactor` is a high-precision value, it should be divided by BASE after the adjustment is completed to remove the accuracy in the calculation process and obtain the correct value. However, when the project party adjusted `totalSupply`, they forgot to adjust the calculation results, which resulted in the unexpected increase of `totalSupply` and incorrect results.

# Root Cause
```solidity
/**
* @notice Initiates a new rebase operation, provided the minimum time period has elapsed.
*
* @dev The supply adjustment equals (totalSupply * DeviationFromTargetRate) / rebaseLag
*      Where DeviationFromTargetRate is (MarketOracleRate - targetRate) / targetRate
*      and targetRate is CpiOracleRate / baseCpi
*/
function rebase(
    uint256 epoch,
    uint256 indexDelta,
    bool positive
)
    external
    onlyRebaser
    returns (uint256)
{
    if (indexDelta == 0) {
      emit Rebase(epoch, yamsScalingFactor, yamsScalingFactor);
      return totalSupply;
    }

    uint256 prevYamsScalingFactor = yamsScalingFactor;

    if (!positive) {
       yamsScalingFactor = yamsScalingFactor.mul(BASE.sub(indexDelta)).div(BASE);
    } else {
        uint256 newScalingFactor = yamsScalingFactor.mul(BASE.add(indexDelta)).div(BASE);
        if (newScalingFactor < _maxScalingFactor()) {
            yamsScalingFactor = newScalingFactor;
        } else {
          yamsScalingFactor = _maxScalingFactor();
        }
    }

    totalSupply = initSupply.mul(yamsScalingFactor);
    emit Rebase(epoch, prevYamsScalingFactor, yamsScalingFactor);
    return totalSupply;
}