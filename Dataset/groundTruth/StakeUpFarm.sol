/**
 *Submitted for verification at BscScan.com on 2022-10-16
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

/*
 *  ______     ______   ______     __  __     ______     __  __     ______      ______   ______     ______     __    __
 * /\  ___\   /\__  _\ /\  __ \   /\ \/ /    /\  ___\   /\ \/\ \   /\  == \    /\  ___\ /\  __ \   /\  == \   /\ "-./  \
 * \ \___  \  \/_/\ \/ \ \  __ \  \ \  _"-.  \ \  __\   \ \ \_\ \  \ \  _-/    \ \  __\ \ \  __ \  \ \  __<   \ \ \-./\ \
 *  \/\_____\    \ \_\  \ \_\ \_\  \ \_\ \_\  \ \_____\  \ \_____\  \ \_\       \ \_\    \ \_\ \_\  \ \_\ \_\  \ \_\ \ \_\
 *   \/_____/     \/_/   \/_/\/_/   \/_/\/_/   \/_____/   \/_____/   \/_/        \/_/     \/_/\/_/   \/_/ /_/   \/_/  \/_/
 *
 *  ╔═══════════════════════════════════════╗
 *  ║ - StakeUp Farm - $SUF                 ║
 *  ║ -> https://stakeup.farm <-            ║
 *  ║ -> https://t.me/stakeupfarm <-        ║
 *  ║ -> https://discord.gg/yCSVMGeS2f <-   ║
 *  ║ -> https://twitter.com/stakeupfarm <- ║
 *  ╚═══════════════════════════════════════╝
 *
 */
/*    SPDX-License-Identifier: MIT    */
pragma solidity 0.8.17;



/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)





/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: @openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)




/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: StakeUpFarm.sol






contract StakeUpFarm is Ownable, ReentrancyGuard {
    // Token
    IERC20 public BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    ERC20Burnable public SUF = ERC20Burnable(0x179Fbdc1cb93105B13796a4A2785Ce340D76e9E3);

    // Configurables
    uint256 public MINTdaily = 6;
    uint256 public STAKEdaily = 12;
    uint256 public minDeposit = 25 ether;
    uint256 public maxDeposit = 10000 ether;
    uint256 public startTime = 1666378800; // Fri Oct 21 2022 19:00:00 UTC
    uint256 public ID;

    // Fees
    uint256 public referralFee = 6;
    uint256 public depositFee = 4;
    uint256 public sellFee = 4;
    uint256 public unstakeFee = 20;
    address public feeWallet = 0x3444BE7E9c0A20ddB4e6DD9F4553d8bF26457EdF;

    // Multiplier prices
    uint256 public x125 = 125 ether;
    uint256 public x150 = 175 ether;
    uint256 public x175 = 250 ether;
    uint256 public x2 = 375 ether;

    // Structs
    struct investorDetails {
        address investorAddress;
        uint256 invested;
        uint256 sellLimit;
        uint256 sellLastTime;
        uint256 availableReferralToWithdraw;
        uint256 totalReferral;
        uint256 numberOfReferrals;
        uint256 staked;
        uint256 withdrawn;
        uint256 multiplier;
        bool boughtMultiplier;
    }

    struct claimDailyMINT {
        address investorAddress;
        uint256 startTime;
    }

    struct claimDailySTAKE {
        address investorAddress;
        uint256 startTime;
    }

    // Mappings
    mapping(address => investorDetails) public investor;
    mapping(address => claimDailyMINT) public claimTimeMINT;
    mapping(address => claimDailySTAKE) public claimTimeSTAKE;
    mapping(uint256 => address) public investorID;
    mapping(address => bool) public investorIDbyAddress;

    // Events
    function mintSUF(address _referral, uint256 _amount) external nonReentrant {
        require(
            block.timestamp >= startTime,
            "StakeUpFarm: Farming has not started yet"
        );
        require(
            _amount >= minDeposit && _amount <= maxDeposit,
            "Deposit amount is not in range"
        );

        require(
            BUSD.allowance(msg.sender, address(this)) >= _amount,
            "Not enough BUSD allowed"
        );

        require(
            BUSD.balanceOf(msg.sender) >= _amount,
            "Not enough BUSD balance"
        );

        uint256 _referralFee;
        if (
            _referral != address(0) &&
            _referral != msg.sender &&
            investor[_referral].invested >= 50 ether
        ) {
            _referralFee = (_amount * referralFee) / 100;
            investor[_referral].availableReferralToWithdraw += _referralFee;
            investor[_referral].totalReferral += _referralFee;
            investor[_referral].numberOfReferrals++;
        }

        uint256 _depositFee = (_amount * depositFee) / 100;
        investor[msg.sender].invested += _amount - _depositFee;

        BUSD.transferFrom(msg.sender, address(this), _amount - _depositFee);
        BUSD.transferFrom(msg.sender, feeWallet, _depositFee);

        if (claimTimeMINT[msg.sender].startTime == 0) {
            claimTimeMINT[msg.sender] = claimDailyMINT(
                msg.sender,
                block.timestamp
            );
        }

        investor[msg.sender].investorAddress = msg.sender;

        if (investorIDbyAddress[msg.sender] == false) {
            ID++;
            investorID[ID] = msg.sender;
            investorIDbyAddress[msg.sender] = true;
        }
    }

    function stakeSUF(uint256 _amount) external nonReentrant {
        require(
            block.timestamp >= startTime,
            "StakeUpFarm: Farming has not started yet"
        );
        require(
            SUF.allowance(msg.sender, address(this)) >= _amount,
            "Not enough SUF allowed"
        );
        require(SUF.balanceOf(msg.sender) >= _amount, "Not enough SUF balance");
        SUF.transferFrom(msg.sender, address(this), _amount);
        investor[msg.sender].staked += _amount;
        investor[msg.sender].sellLimit =
            (investor[msg.sender].staked * 10) /
            100;
        if (claimTimeSTAKE[msg.sender].startTime == 0) {
            claimTimeSTAKE[msg.sender] = claimDailySTAKE(
                msg.sender,
                block.timestamp
            );
        }
    }

    function buyMultiplier(uint256 _option) external nonReentrant {
        require(
            block.timestamp >= startTime,
            "StakeUpFarm: Farming has not started yet"
        );
        require(
            checkMultiplier(msg.sender) == false,
            "You have already bought a multiplier"
        );
        require(
            BUSD.allowance(msg.sender, address(this)) >= x125,
            "Not enough BUSD allowed"
        );
        require(BUSD.balanceOf(msg.sender) >= x125, "Not enough BUSD balance");
        (_option == 1 || _option == 2 || _option == 3 || _option == 4)
            ? _option
            : _option = 1;

        if (_option == 1) {
            BUSD.transferFrom(msg.sender, address(this), x125);
            investor[msg.sender].multiplier = 125;
        } else if (_option == 2) {
            BUSD.transferFrom(msg.sender, address(this), x150);
            investor[msg.sender].multiplier = 150;
        } else if (_option == 3) {
            BUSD.transferFrom(msg.sender, address(this), x175);
            investor[msg.sender].multiplier = 175;
        } else if (_option == 4) {
            BUSD.transferFrom(msg.sender, address(this), x2);
            investor[msg.sender].multiplier = 200;
        }
        investor[msg.sender].boughtMultiplier = true;
    }

    function sellSUF(uint256 _amount) external nonReentrant {
        require(
            block.timestamp >= startTime,
            "StakeUpFarm: Farming has not started yet"
        );
        require(
            SUF.allowance(msg.sender, address(this)) >= _amount,
            "Not enough SUF allowed"
        );
        require(SUF.balanceOf(msg.sender) >= _amount, "Not enough SUF balance");
        require(
            _amount <= investor[msg.sender].sellLimit,
            "Sell amount is not in range"
        );
        require(
            investor[msg.sender].sellLastTime + 1 days <= block.timestamp,
            "Sell time not passed"
        );
        require(
            investor[msg.sender].invested >= 24 ether,
            "You need to invest first"
        );
        investor[msg.sender].sellLastTime = block.timestamp;
        SUF.transferFrom(msg.sender, address(this), _amount);
        uint256 price = getSUFPrice();
        uint256 _amountToReceive = (_amount * price) / 1 ether;
        uint256 _fee = (_amountToReceive * sellFee) / 100;
        uint256 _amountToReceiveAfterFee = _amountToReceive - _fee;
        BUSD.transfer(msg.sender, _amountToReceiveAfterFee);
        BUSD.transfer(feeWallet, _fee);
        investor[msg.sender].sellLimit -= _amount;
        investor[msg.sender].withdrawn += _amountToReceiveAfterFee;
    }

    function claimDailyRewardMINT() external nonReentrant {
        require(
            block.timestamp >= startTime,
            "StakeUpFarm: Farming has not started yet"
        );
        uint256 reward = userRewardMINT(msg.sender);
        SUF.transfer(msg.sender, reward);
        claimTimeMINT[msg.sender] = claimDailyMINT(msg.sender, block.timestamp);
    }

    function claimDailyRewardSTAKE() external nonReentrant {
        require(
            block.timestamp >= startTime,
            "StakeUpFarm: Farming has not started yet"
        );
        uint256 reward = userRewardSTAKE(msg.sender);
        SUF.transfer(msg.sender, reward);
        claimTimeSTAKE[msg.sender] = claimDailySTAKE(
            msg.sender,
            block.timestamp
        );
    }

    function withdrawReferral() external nonReentrant {
        require(
            block.timestamp >= startTime,
            "StakeUpFarm: Farming has not started yet"
        );
        require(
            investor[msg.sender].availableReferralToWithdraw > 0,
            "No referral to withdraw"
        );
        BUSD.transfer(
            msg.sender,
            investor[msg.sender].availableReferralToWithdraw
        );
        investor[msg.sender].withdrawn += investor[msg.sender]
            .availableReferralToWithdraw;
        investor[msg.sender].availableReferralToWithdraw = 0;
    }

    function unstakeSUF() external nonReentrant {
        require(
            block.timestamp >= startTime,
            "StakeUpFarm: Farming has not started yet"
        );
        uint256 _amount = investor[msg.sender].staked;
        require(
            SUF.allowance(msg.sender, address(this)) >= _amount,
            "Not enough SUF allowed"
        );
        uint256 rewardMINT = userRewardMINT(msg.sender);
        uint256 rewardSTAKE = userRewardSTAKE(msg.sender);
        uint256 totalReward = rewardMINT + rewardSTAKE;
        SUF.transfer(msg.sender, totalReward);
        SUF.transfer(msg.sender, ((100 - unstakeFee) * _amount) / 100);
        SUF.burnFrom(msg.sender, (_amount * unstakeFee) / 100);
        investor[msg.sender].staked = 0;
    }

    function userRewardMINT(address _user) public view returns (uint256) {
        uint256 _reward = (investor[_user].invested * MINTdaily) / 100 / 86400;
        uint256 _timePassed = block.timestamp - claimTimeMINT[_user].startTime;
        return checkBoost(_user, _reward * _timePassed);
    }

    function userRewardSTAKE(address _user) public view returns (uint256) {
        uint256 _reward = (investor[_user].staked * STAKEdaily) / 100 / 86400;
        uint256 _timePassed = block.timestamp - claimTimeSTAKE[_user].startTime;
        return checkBoost(_user, _reward * _timePassed);
    }

    function getSUFPrice() public view returns (uint256) {
        uint256 d1 = BUSD.balanceOf(address(this)) * 1 ether;
        uint256 d2 = SUF.balanceOf(address(this)) + 1;
        return d1 / d2;
    }

    function changeReferralReward(uint256 _newReferralFee) external onlyOwner {
        referralFee = _newReferralFee;
    }

    function getNumberOfReferrals(address user) public view returns (uint256) {
        return investor[user].numberOfReferrals;
    }

    function getContractBalance() public view returns (uint256) {
        return BUSD.balanceOf(address(this));
    }

    function getAvailableToWithdrawReferral(address user)
        public
        view
        returns (uint256)
    {
        return investor[user].availableReferralToWithdraw;
    }

    function getTotalInvested(address user) public view returns (uint256) {
        return investor[user].invested;
    }

    function getTotalWithdrawn(address user) public view returns (uint256) {
        return investor[user].withdrawn;
    }

    function getUserStaked(address user) public view returns (uint256) {
        return investor[user].staked;
    }

    function getTotalReferral(address user) public view returns (uint256) {
        return investor[user].totalReferral;
    }

    function getAnnualPercentageRateMINT() public view returns (uint256) {
        return MINTdaily * 365;
    }

    function getAnnualPercentageRateSTAKE() public view returns (uint256) {
        return STAKEdaily * 365;
    }

    function getNumberOfInvestors() public view returns (uint256) {
        return ID;
    }

    function getSUFbalanceOf(address user) public view returns (uint256) {
        return SUF.balanceOf(user);
    }

    function getBUSDbalanceOf(address user) public view returns (uint256) {
        return BUSD.balanceOf(user);
    }

    function getAvailableSupply() public view returns (uint256) {
        return SUF.balanceOf(address(this));
    }

    function getCirculatingSupply() public view returns (uint256) {
        return
            SUF.totalSupply() -
            SUF.balanceOf(address(0)) -
            SUF.balanceOf(address(this));
    }

    function checkMultiplier(address _user) public view returns (bool) {
        return investor[_user].boughtMultiplier;
    }

    function checkBooster(address _user) public view returns (uint256) {
        return investor[_user].multiplier;
    }

    function checkBoost(address _user, uint256 _amount)
        public
        view
        returns (uint256)
    {
        uint256 multiplier = investor[_user].multiplier;
        return multiplier != 0 ? ((multiplier + 1e4) * _amount) / 1e4 : _amount;
    }
}

/* |====================> Made with love by the awesome @weimaster <===================| */
/* |================================> END OF CONTRACT <================================| */