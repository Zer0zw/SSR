# Project Name
MintStakeShare

# Description
In the contract, the `buyWithMint` function, which is used for staking tokens, calculates the governance tokens received using the `getTokenMintAmount` and calculatePrice functions. This calculation logic depends on the variable `_totalSupply`. However, the value of this variable can be manipulated through transfer operations within the contract. An attacker can exploit this by first performing large transfer transactions to alter the value of `_totalSupply`, and then calling the staking function to obtain an increased amount of governance tokens.

# Root Cause
```solidity
function buyWithMint(
	address beneficiary,
	address _referrer
) external payable nonReentrant {
	uint amount = msg.value;
	totalEthRaised += amount;

	uint256 tokens = getTokenMintAmount(amount);
	_mint(beneficiary, tokens);
	_setReferrer(_referrer);
	_handleReferralETH(amount);
	_handleIncomingETHFromMint();
	emit Purchase(beneficiary, amount, tokens);
}

function getTokenMintAmount(
	uint256 _inputAmount
) public view returns (uint256) {
	uint256 price = calculatePrice();
	uint256 outputTokens = (_inputAmount / price) * 10 ** 18;

	if (outputTokens > priceSupplyInterval) {
		uint priceTotalSupply = totalSupply() + outputTokens;

		uint higherPriceTier = (priceTotalSupply / priceSupplyInterval);
		price = _calculatePrice(higherPriceTier);
		outputTokens = (_inputAmount / price) * 10 ** 18;
	}

	return outputTokens;
}

function _calculatePrice(uint priceTier) private view returns (uint) {
	return fracExp(initialPrice, priceIncreasePercent, priceTier, 5);
}

/**
 * @notice Calculate the price to mint tokens at the current price tier
 * @return The price to mint tokens at the given price tier
 */
function calculatePrice() public view returns (uint256) {
	uint256 currentTier = currentPriceTier();
	if (currentTier == 0) {
		return initialPrice;
	} else {
		return _calculatePrice(currentTier);
	}
}

function currentPriceTier() public view returns (uint256) {
	return (totalSupply() / priceSupplyInterval);
}

/**
 * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
 * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
 * this function.
 *
 * Emits a {Transfer} event.
 */
function _update(address from, address to, uint256 value) internal virtual {
	if (from == address(0)) {
		// Overflow check required: The rest of the code assumes that totalSupply never overflows
		_totalSupply += value;
	} else {
		uint256 fromBalance = _balances[from];
		if (fromBalance < value) {
			revert ERC20InsufficientBalance(from, fromBalance, value);
		}
		unchecked {
			// Overflow not possible: value <= fromBalance <= totalSupply.
			_balances[from] = fromBalance - value;
		}
	}

	if (to == address(0)) {
		unchecked {
			// Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
			_totalSupply -= value;
		}
	} else {
		unchecked {
			// Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
			_balances[to] += value;
		}
	}

	emit Transfer(from, to, value);
}