/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    
    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
}


interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
     
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */

    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */

    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */

    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */

    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */

    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */

    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */

    function allowance(address _owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}



/**
 * @dev Collection of functions related to the address type
 */

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
   
    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    
    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
   
    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}



/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
}

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


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

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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


contract Updated_final2d is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;         // How many LP tokens the user has provided.
        uint256 rewardDebt;     // Reward debt. See explanation below.
        uint256 rewardLockedUp;  // Reward locked up.
        uint256 nextHarvestUntil; // When can the user harvest again.
        uint256 lastDepositTime; // when user deposited
        
    

        
        //   pending reward = (user.amount * pool.accTokenPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accTokenPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IBEP20 lpToken;             // Address of LP token contract.
        uint256 lastRewardBlock;    // Last block number that BYAS distribution occurs.
        uint256 accTokenPerShare;   // Accumulated BYAS per share, times 1e12. See below.
        uint256 harvestInterval;    // Harvest interval in seconds
        uint256 withdrawLockPeriod; // lock period for this pool
        uint256 tokenPerBlock;
        uint256 balance;            // pool token balance, allow multiple pools with same token
    }

    // The BYAS TOKEN!
    IBEP20 public token;
    // Dev address.
    address public devAddress;
    // Bonus muliplier for early token makers.
    uint256 public constant BONUS_MULTIPLIER = 1;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    
    // The block number when BYAS mining starts.
    uint256 public startBlock;
    uint256 public endBlock;
    // Total locked up rewards
    uint256 public totalLockedUpRewards;


    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Harvest(address indexed user, uint256 indexed pid, uint256 rewardAmount);
    event EmissionRateUpdated(address indexed caller, uint256 previousAmount, uint256 newAmount);
    event RewardLockedUp(address indexed user, uint256 indexed pid, uint256 amountLockedUp);

    constructor(
        IBEP20 _token,
        uint256 _startBlock
    )  public {
        token = _token;
        startBlock = _startBlock;
        token.balanceOf( address(this) );
        devAddress = msg.sender;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function addPool(IBEP20 _lpToken, uint256 _harvestInterval, bool _withUpdate,
        uint256 _withdrawLockPeriod, uint256 _tokenPerBlock) external onlyOwner {
        require(_withdrawLockPeriod <= 90 days, "withdraw lock must be less than 90 days");
        require(_harvestInterval <= 90 days, "add: invalid harvest interval");
        if (_withUpdate) {
            massUpdatePools();
        }
        _lpToken.balanceOf(address(this)); // prevent adding invalid token.
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            lastRewardBlock: lastRewardBlock,
            accTokenPerShare: 0,
            balance: 0,
            harvestInterval: _harvestInterval,
            withdrawLockPeriod: _withdrawLockPeriod,
            tokenPerBlock: _tokenPerBlock
        }));
    }

    // Update the given pool's reward allocation and time intervals for withdraw and harvest . Can only be called by the owner.
    function set(uint256 _pid, uint256 _harvestInterval, bool _withUpdate, 
        uint256 _withdrawLockPeriod, uint256 _tokenPerBlock ) external onlyOwner {
        require(_withdrawLockPeriod <= 90 days, "withdraw lock must be less than 90 days");
        require(_harvestInterval <= 90 days, "set: invalid harvest interval");
        if (_withUpdate) {
            massUpdatePools();
        }
       
        poolInfo[_pid].harvestInterval = _harvestInterval;
        poolInfo[_pid].withdrawLockPeriod = _withdrawLockPeriod;
        poolInfo[_pid].tokenPerBlock = _tokenPerBlock;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        if( treasure == 0 ){
            // if contract has no balance, stop emission.
            return 0;
        }
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    // View function to see pending BYAS on frontend.
    function pendingToken(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accTokenPerShare = pool.accTokenPerShare;
        uint256 lpSupply = pool.balance;
        uint256 myBlock = (block.number <= endBlock ) ? block.number : endBlock;
        if (myBlock > pool.lastRewardBlock && lpSupply != 0 ) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, myBlock);
            uint256 tokenReward = multiplier.mul(pool.tokenPerBlock); 
            accTokenPerShare = accTokenPerShare.add(tokenReward.mul(1e12).div(lpSupply));
        }
        uint256 pending = user.amount.mul(accTokenPerShare).div(1e12).sub(user.rewardDebt);
        return pending.add(user.rewardLockedUp);
    }

    // View function to see if user can harvest BYAS.
    function canHarvest(uint256 _pid, address _user) public view returns (bool) {
        UserInfo storage user = userInfo[_pid][_user];
        return block.timestamp >= user.nextHarvestUntil;
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        uint256 myBlock = (block.number <= endBlock ) ? block.number : endBlock;
        if (myBlock <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.balance;
        if (lpSupply == 0) {
            pool.lastRewardBlock = myBlock;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, myBlock);
        uint256 tokenReward = multiplier.mul(pool.tokenPerBlock); // .mul(pool.allocPoint).div(totalAllocPoint);
        mint(address(this), tokenReward);
        pool.accTokenPerShare = pool.accTokenPerShare.add(tokenReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = myBlock;
    }

    // Deposit LP tokens for BYAS allocation.
    function deposit(uint256 _pid, uint256 _amount) external nonReentrant {
        require(token.balanceOf(address(msg.sender)) >= 100 * 1000 * 10 ** 18 , 'BYAS token balance is too low');
        
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        
        updatePool(_pid);
        lockupPendingHarvest(_pid);
        if (_amount > 0) {
            uint256 oldBalance = pool.lpToken.balanceOf(address(this));
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            uint256 newBalance = pool.lpToken.balanceOf(address(this));
            _amount = newBalance.sub(oldBalance);

            pool.balance = pool.balance.add(_amount);
            user.amount = user.amount.add(_amount);
        
            user.nextHarvestUntil = block.timestamp.add(pool.harvestInterval);
            user.lastDepositTime = block.timestamp;
        }
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens only.
    function withdraw(uint256 _pid, uint256 _amount) external nonReentrant {
        require(token.balanceOf(address(msg.sender)) >= 100 * 1000 * 10 ** 18 , 'BYAS token balance is too low');
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        
        if (_amount > 0) {
            // check withdraw is locked:
            if(pool.withdrawLockPeriod > 0){
                bool isLocked = block.timestamp < user.lastDepositTime + pool.withdrawLockPeriod;
                require( isLocked == false, "withdraw still locked" );
               
             }

            lockupPendingHarvest(_pid);      
            user.amount = user.amount.sub(_amount);
            pool.balance = pool.balance.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);

            user.nextHarvestUntil = block.timestamp.add(pool.harvestInterval);
            user.lastDepositTime = block.timestamp;
            
        }
            
            user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
            emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens and rewards.
    function withdrawAndHarvest(uint256 _pid, uint256 _amount) external nonReentrant {
        require(token.balanceOf(address(msg.sender)) >= 100 * 1000 * 10 ** 18 , 'BYAS token balance is too low');
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount == _amount, "Must withdraw all LP tokens");
        updatePool(_pid);
        
        if (_amount > 0) {
            // check withdraw is locked:
            if( pool.withdrawLockPeriod > 0){
                bool isLocked = block.timestamp < user.lastDepositTime + pool.withdrawLockPeriod;
                require( isLocked == false, "withdraw still locked" );
            }

            payPendingHarvest(_pid);
            user.amount = user.amount.sub(_amount);
            pool.balance = pool.balance.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }

        
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }


    // Harvest BYAS tokens
    function harvest(uint256 _pid) external nonReentrant {
        require(token.balanceOf(address(msg.sender)) >= 100 * 1000 * 10 ** 18 , 'BYAS token balance is too low');
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        
        updatePool(_pid);

        uint256 pending = user.amount.mul(pool.accTokenPerShare).div(1e12).sub(user.rewardDebt);
        uint256 totalRewards = pending.add(user.rewardLockedUp);
    
            if (totalRewards > 0) {
            require(block.timestamp >= user.nextHarvestUntil, "not time to harvest");
            payPendingHarvest(_pid);

            user.nextHarvestUntil = block.timestamp.add(pool.harvestInterval);
            user.lastDepositTime = block.timestamp;
        }  
            
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        emit Harvest(msg.sender, _pid, totalRewards);
    }

    // Pay pending BYAS.
    function payPendingHarvest(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        if (user.nextHarvestUntil == 0) {
            user.nextHarvestUntil = block.timestamp.add(pool.harvestInterval);
        
        }
        uint256 pending = user.amount.mul(pool.accTokenPerShare).div(1e12).sub(user.rewardDebt);
        if (canHarvest(_pid, msg.sender)) {
            if (pending > 0 || user.rewardLockedUp > 0) {
                uint256 totalRewards = pending.add(user.rewardLockedUp);

                // reset lockup
                totalLockedUpRewards = totalLockedUpRewards.sub(user.rewardLockedUp);
                user.rewardLockedUp = 0;
                user.nextHarvestUntil = block.timestamp.add(pool.harvestInterval);
                user.lastDepositTime = block.timestamp;

                // send rewards
                safeTokenTransfer(msg.sender, totalRewards);
                emit Harvest(msg.sender, _pid, totalRewards);
                
            }
         }     
    }

     //Lockup pending BYAS. (For LP withdrawal without rewards)
      function lockupPendingHarvest(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        if (user.nextHarvestUntil == 0) {
            user.nextHarvestUntil = block.timestamp.add(pool.harvestInterval);
            
        }

        uint256 pending = user.amount.mul(pool.accTokenPerShare).div(1e12).sub(user.rewardDebt);
        if (canHarvest(_pid, msg.sender)) {
            if (pending > 0) {
            user.rewardLockedUp = user.rewardLockedUp.add(pending);
            totalLockedUpRewards = totalLockedUpRewards.add(pending);
            user.nextHarvestUntil = block.timestamp.add(pool.harvestInterval);
            user.lastDepositTime = block.timestamp;
            emit RewardLockedUp(msg.sender, _pid, pending);
        }
    }
 }

    // Update dev address by the previous dev.
    function setDevAddress(address _devAddress) external {
        require(msg.sender == devAddress, "setDevAddress: FORBIDDEN");
        require(_devAddress != address(0), "setDevAddress: ZERO");
        devAddress = _devAddress;
    }

    uint256 public treasure;
    uint256 public allocated;
    uint256 public blocks;
   
    event Mint(address to,  uint256 amount);
    function addBalance(uint256 _amount, uint256 _endBlock) external onlyOwner {
        require( _amount > 0 , "err _amount=0");
        require( _endBlock > block.number , "err start<=block");

        // Note: finding by auditors.
        uint256 oldBalance = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 newBalance = token.balanceOf(address(this));
        _amount = newBalance.sub(oldBalance);

        endBlock = _endBlock;
        treasure = treasure.add(_amount);
        blocks = _endBlock - block.number;
        // tokenPerBlock = treasure.div(blocks);
        startBlock = block.number;
    }

    function mint(address to,  uint256 amount ) internal {
        if( amount > treasure ){
            // treasure is 0, stop emission.
            // tokenPerBlock = 0;
            amount = treasure; // last ming
        }
        treasure = treasure.sub(amount);
        allocated = allocated.add(amount);
        emit Mint(to, amount);
    }
    // Safe token transfer function, just in case if rounding error causes pool to not have enough BYAS.
    function safeTokenTransfer(address _to, uint256 _amount) internal {
        uint256 tokenBal = token.balanceOf(address(this));
        if (_amount > tokenBal) {
            token.transfer(_to, tokenBal);
        } else {
            token.transfer(_to, _amount);
        }
    }

 
    function recoverTreasure( IBEP20 recoverToken, uint256 amount) external onlyOwner{
        uint256 length = poolInfo.length;
        for (uint256 pid = 1; pid < length; ++pid) {
            require(recoverToken != poolInfo[pid].lpToken,"can't transfer lp");
        }
        require(block.number > endBlock, "can recover only farming end.");
        // allow treasure recover unused/lost funds
        recoverToken.transfer(devAddress, amount);
    }
}