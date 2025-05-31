# Project Name
Bera Reserve

# Description
1. Improper Address Check
    
    The contract is incorrectly using an `if` statement that only allows setting addresses when they are the zero address (`0x0`) and reverts in all other cases. As a result, legitimate addresses for essential components, such as the treasury, the team, and other critical roles, cannot be initialized or updated. This creates a significant limitation, effectively preventing the contract from being configured properly and may lead to operational failure or inability to deploy the contract effectively.
    
2. Incorrect Vesting Calculation
    
    The contract is flawed in its calculation of the vested amount due to an improper determination of the vesting duration. In the function that calculates the vested amount, the `durationPassed` is divided by the `duration`, which is incorrectly set as the current block timestamp plus the vesting duration, instead of using only the vesting duration itself. This results in the duration being an excessively large number, causing the vested amount calculation to be divided by a much larger value than intended. Consequently, this miscalculation leads to a significantly lower amount of vested tokens than expected, undermining the vesting logic and potentially affecting the participants’ token distribution.
    
3. Market Cap Price Manipulation
    
    The contract is vulnerable to manipulation due to its fee calculation mechanism, which relies on the total market capitalization (market cap) of the token. The fee applied to transactions is determined by the market cap relative to the treasury value, with different fee tiers depending on how much the market cap deviates from the treasury value. An attacker can exploit this mechanism by using a flash loan to artificially inflate or deflate the market cap. This temporary change allows the attacker to influence the fee calculation in a way that benefits them, either by lowering the fees they pay or by increasing fees for other users. This manipulation can undermine the fairness and stability of the fee mechanism, potentially causing financial loss to honest users and destabilizing the token's economy.
    
4. Missing Access Control
    
    The contract is missing appropriate access control for the `redeem` function, allowing any user to invoke this function on behalf of any recipient. As a result, any user can redeem bonds for any other user, potentially leading to unauthorized bond redemptions. This vulnerability could be exploited to manipulate the distribution of payouts, resulting in financial loss or unfair advantage.
    
5. Unrestricted Unstake Recipient
    
    The contract allows any user to specify an arbitrary address as the `_recipient` in the `unstakeFor` function, enabling them to unstake assets on behalf of any other user. As a result, malicious users could exploit this function to unstake and transfer the assets of other users without their consent, potentially causing unauthorized asset withdrawals and resulting in financial losses and trust issues for the affected users.

# Root Cause
```solidity
// Improper Address Check
constructor(address _treasury, address _pol, address _team, address _beraReserveToken) {
    if (_treasury != address(0) || _pol != address(0) || _team != address(0)) {
        revert BERA_RESERVE__INVALID_ADDRESS();
    }
...
function updateAddresses(address _team, address _pol, address _treasury) external override onlyOwner {
    if (_treasury != address(0) || _pol != address(0) || _team != address(0)) {
        revert BERA_RESERVE__INVALID_ADDRESS();
    }
    
// Incorrect Vesting Calculation
function vestedAmount(
  address member,
  MemberType memberType
) public view override returns (uint256) {
  VestingSchedule memory schedule = getSchedule(member, memberType);

  if (block.timestamp < schedule.cliff) {
    return 0;
  } else if (block.timestamp >= schedule.duration) {
    return schedule.totalAmount;
  } else {
    uint256 durationPassed = block.timestamp - schedule.start;

    uint256 totalVested = uint256(schedule.totalAmount).mulDiv(
      durationPassed,
      schedule.duration,
      Math.Rounding.Floor
    );

    return totalVested;
  }
}
...
function vestedAmount(
  InvestorBondInfo memory investorBonds
) public view override returns (uint256) {
  if (block.timestamp >= investorBonds.duration) {
    return investorBonds.totalAmount;
  } else {
    uint256 durationPassed = block.timestamp - investorBonds.start;

    uint256 totalVested = investorBonds.totalAmount.mulDiv(
      durationPassed,
      investorBonds.duration
    );

    return totalVested;
  }
} 

// Market Cap Price Manipulation
function calculateSlidingScaleFee(
  uint256 mCap,
  uint256 treasuryValue,
  uint256 sellFee,
  uint256 tenPercentBelowTreasuryFees,
  uint256 twentyFivePercentBelowTreasuryFees,
  uint256 belowTreasuryValueFees
) public pure returns (TreasuryValueData memory rvfData) {
  if (mCap > treasuryValue) {
    rvfData.fee = sellFee;

    return rvfData;
  }

  uint256 tenPercentBelowTreasury = treasuryValue.mulDiv(9_000, BASIS_POINTS);
  uint256 twentyFivePercentBelowTreasury = treasuryValue.mulDiv(
    7_500,
    BASIS_POINTS
  );

  uint256 burn_treasuryFee_25Perc = twentyFivePercentBelowTreasury / 2;
  uint256 burn_treasuryFee_10Perc = tenPercentBelowTreasury / 2;
  uint256 burn_treasuryFee_belowTreasury = belowTreasuryValueFees / 2;

  if (mCap <= twentyFivePercentBelowTreasury) {
    ...
    return rvfData; // 16%
  } else if (mCap <= tenPercentBelowTreasury) {
    ...
  } else if (mCap <= treasuryValue) {
    ...

    return rvfData;
  }
}

// Missing Access Control
function redeem(address _recipient, bool _stake) external returns (uint256) {
    Bond memory info = bondInfo[_recipient];
    ...
        return stakeOrSend(_recipient, _stake, payout);
    }
}

// Unrestricted Unstake Recipient
function unstakeFor(address _recipient, uint256 _amount) external {
    //!note add this only allow lockUp to call
    //require(msg.sender == locker, "Only locker can call this function");
    rebase();

    totalStaked = totalStaked.sub(_amount);

    IERC20(sOHM).safeTransferFrom(_recipient, address(this), _amount);
    IERC20(OHM).safeTransfer(_recipient, _amount);
}