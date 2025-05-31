/**
 *Submitted for verification at BscScan.com on 2022-01-24
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/math/Math.sol

pragma solidity ^0.8.10;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// File: @openzeppelin/contracts/math/SafeMath.sol

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
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * Available since v2.4.0.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * Available since v2.4.0.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * Available since v2.4.0.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: @openzeppelin/contracts/GSN/Context.sol

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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/ownership/Ownable.sol
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
    function mint(address account, uint amount) external;

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// File: @openzeppelin/contracts/utils/Address.sol

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * IMPORTANT: It is unsafe to assume that an address for which this
     * function returns false is an externally-owned account (EOA) and not a
     * contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * Available since v2.4.0.
     */
    function toPayable(address account) internal pure returns (address payable) {
        return payable(address(uint160(account)));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * Available since v2.4.0.
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        // (bool success, ) = recipient.call.value(amount)("");
        (bool success, ) = recipient.call{value:amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

//
interface Uni {
    function swapExactTokensForTokens(
        uint256,
        uint256,
        address[] calldata,
        address,
        uint256
    ) external;
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
}

interface ICA2LPFarm{
    function stakeFarm(uint256 amount, address _userAddress) external;

}

contract CA2Farm is Ownable{
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    uint public PoolId;
    uint public Duration = 90 days;
    uint public Counter;
    uint public TotalReward = 1000000000000000000;
    address public CA2LPFarm = 0x36f18E5192E209A5338777423E3977bF538F96f4; //test


    mapping(address => mapping(uint => uint)) public UserPoolStakeAmount;
    mapping(uint => uint) public PoolStaked;
    mapping(uint => mapping(uint => address)) public PoolSubIdUser;
    mapping(address => mapping(uint => uint)) public UserPoolSubId;
    mapping(uint => uint) public PoolSubIdCounter;
    mapping(address => uint) public UserLastStakePool;
    mapping(uint => bool) public PoolLock;
    mapping(uint => uint) public PoolEndTime;
    mapping(address => uint) public UserRewards;
    mapping(address => mapping(uint => bool)) public PoolFirstStake;
    mapping(uint => uint) public PoolCounter;
    mapping(uint => uint) public RewardAmountCal;
    mapping(uint => uint) public StampCounter;
    mapping(uint => bool) public PoolRewardDistributed;
    
    address public PlatformAccount;
    IERC20 public CA2Token;
    IERC20 public CA2LPToken;
    IERC20 public BUSD;
    IERC20 public WBNB;
    address public constant pancakerouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    event InsertUser(address indexed _address, uint indexed _poolid, uint indexed _amount);
    event WithdrawUser(address indexed _address, uint indexed _poolid, uint indexed _amount);
    event RewardPaid(address indexed _address, uint indexed _amount);
    event RewardPaidInCA2(address indexed _address, uint indexed _amount);
    event RewardPaidRestake(address indexed _address, uint indexed _amount);
    event RewardDistributed(uint indexed _poolid, address indexed _userAddress, uint indexed _reward);
    event StartPhase(uint indexed _phaseId, uint _poolEndTime);
    event PoolRewardDistributedEvent(uint indexed _poolId);

    constructor(){
        PlatformAccount = 0xA13Db39BdcE5d0Ca42cAd9B41b9485ed12646f16; //test
        CA2Token = IERC20(0xea9A139EB851fFcB854B432e4e84B410161cdfb6); //test
        CA2LPToken = IERC20(0xF16Dd231a6bf9D70Bbc563bEC0084D7fEC53F0CC); //test
        BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); //test
        WBNB = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); //test
        PoolEndTime[PoolId] = block.timestamp;
    }

    function SetPlatformAccount(address _account) external onlyOwner{
        PlatformAccount = _account;
    }
    function SetCA2Token(address _token) external onlyOwner{
        CA2Token = IERC20(_token);
    }
    function SetBUSD(address _token) external onlyOwner{
        BUSD = IERC20(_token);
    }
    function SetTotalReward(uint _total) external onlyOwner{
        TotalReward = _total;
    }
    

    modifier checkPhase(){
        if(block.timestamp > PoolEndTime[PoolId]){
            PoolLock[PoolId] = true;
            PoolCounter[PoolId] = Counter;
            Counter = 0;
            PoolId = PoolId + 1;
            PoolEndTime[PoolId] = block.timestamp + Duration;
            emit StartPhase(PoolId, PoolEndTime[PoolId]);
        }
        _;
    }

    function Deposit(uint amount) public checkPhase{
        CA2Token.safeTransferFrom(msg.sender, address(this), amount);
        Insert(amount, false);
    }

    function Insert(uint amount, bool _restake) internal{
        if(!_restake){
            if(UserRewards[msg.sender] > 0){
            Claim();
            }
        }
        
        UserPoolStakeAmount[msg.sender][PoolId] = UserPoolStakeAmount[msg.sender][PoolId].add(amount);
        UserLastStakePool[msg.sender] = PoolId;
        PoolStaked[PoolId] = PoolStaked[PoolId].add(amount); 
        if(PoolFirstStake[msg.sender][PoolId] == false){
            PoolFirstStake[msg.sender][PoolId] = true;
            Counter = Counter + 1;
            PoolSubIdCounter[PoolId] = PoolSubIdCounter[PoolId] + 1;
            PoolSubIdUser[PoolId][PoolSubIdCounter[PoolId]] = msg.sender;
            UserPoolSubId[msg.sender][PoolId] = PoolSubIdCounter[PoolId];
        }
        emit InsertUser(msg.sender, PoolId, amount);
    }
    

    function Exit() public checkPhase{
        require(UserPoolStakeAmount[msg.sender][PoolId] > 0, "No CA2Token to withdraw in this pool");
        CA2Token.safeTransfer(msg.sender, UserPoolStakeAmount[msg.sender][PoolId]);
        PoolStaked[PoolId] = PoolStaked[PoolId] - UserPoolStakeAmount[msg.sender][PoolId];
        emit WithdrawUser(msg.sender, PoolId, UserPoolStakeAmount[msg.sender][PoolId]);
        UserPoolStakeAmount[msg.sender][PoolId] = 0;
        if(Counter > 2){
            address lastUser = PoolSubIdUser[PoolId][PoolSubIdCounter[PoolId]];
            uint exitSubId = UserPoolSubId[msg.sender][PoolId];
            PoolSubIdUser[PoolId][PoolSubIdCounter[PoolId]] = address(0);
            UserPoolSubId[lastUser][PoolId] = 0;
            PoolSubIdUser[PoolId][exitSubId] = lastUser;
            UserPoolSubId[lastUser][PoolId] = exitSubId;
            PoolSubIdCounter[PoolId] = PoolSubIdCounter[PoolId] - 1;
        }
        else{
            PoolSubIdCounter[PoolId] = PoolSubIdCounter[PoolId] -1;
            PoolSubIdUser[PoolId][UserPoolSubId[msg.sender][PoolId]] = address(0);
            UserPoolSubId[msg.sender][PoolId] = 0;
        }
    
        PoolFirstStake[msg.sender][PoolId] = false;
        Counter = Counter - 1;
    }

    function OwnerDisributeReward(uint _poolId, uint _amount) external onlyOwner{
        require(PoolLock[_poolId] == true, "Period not end");
        require(PoolRewardDistributed[_poolId] == false, "Pool reward distributed");

        if(RewardAmountCal[_poolId] == 0){
            RewardAmountCal[_poolId] = TotalReward.mul(10).div(PoolStaked[_poolId]).div(10); //test
        }

        for(uint i = 0; i <= _amount; i++){
            address user = PoolSubIdUser[_poolId][i];
            if(UserPoolStakeAmount[user][i] > 0){
                UserRewards[user] = UserRewards[user].add(RewardAmountCal[_poolId].mul(UserPoolStakeAmount[user][_poolId]));
                emit RewardDistributed(_poolId, user, RewardAmountCal[_poolId] * UserPoolStakeAmount[user][_poolId]); //test
            }
            StampCounter[_poolId] = StampCounter[_poolId] + 1;

            if(StampCounter[_poolId] > PoolSubIdCounter[_poolId]){
                PoolRewardDistributed[_poolId] = true;
                emit PoolRewardDistributedEvent(_poolId);
                break;
            }
        }
    }

    function Claim() public{
        require(UserRewards[msg.sender] > 0, "No reward to claim");
        BUSD.safeTransfer(address(this), UserRewards[msg.sender]);
        emit RewardPaid(msg.sender, UserRewards[msg.sender]);
        UserRewards[msg.sender] = 0;
        if(UserPoolStakeAmount[msg.sender][PoolId - 1] > 0){
            Insert(UserPoolStakeAmount[msg.sender][PoolId - 1], false);
            UserPoolStakeAmount[msg.sender][PoolId - 1] = 0;
        }
        else{
            Insert(UserPoolStakeAmount[msg.sender][UserLastStakePool[msg.sender]], false);
            UserPoolStakeAmount[msg.sender][UserLastStakePool[msg.sender]] = 0;
        }
    }

    function ClaimCA2() external{
        require(UserRewards[msg.sender] > 0, "No reward to claim");
        uint balanceInContrat = CA2Token.balanceOf(address(this));
        convertPancake(UserRewards[msg.sender], address(BUSD), address(CA2Token));
        uint CA2UserReward = CA2Token.balanceOf(address(this)).sub(balanceInContrat);

        CA2Token.safeTransfer(address(this), CA2UserReward);
        emit RewardPaidInCA2(msg.sender, CA2UserReward);
        UserRewards[msg.sender] = 0;
        if(UserPoolStakeAmount[msg.sender][PoolId - 1] > 0){
            Insert(UserPoolStakeAmount[msg.sender][PoolId - 1], false);
            UserPoolStakeAmount[msg.sender][PoolId - 1] = 0;
        }
        else{
            Insert(UserPoolStakeAmount[msg.sender][UserLastStakePool[msg.sender]], false);
            UserPoolStakeAmount[msg.sender][UserLastStakePool[msg.sender]] = 0;
        }
    }

    function testChangeUserBalance(address _address, uint _amount, uint _stakeamount, uint _poolid) external onlyOwner{
        UserRewards[_address] = _amount;
        UserPoolStakeAmount[_address][_poolid] = _stakeamount;
    }

    function testChangePoolId(uint _poolid) external onlyOwner{
        PoolId = _poolid;
    }

    function Restake() external{
        require(UserRewards[msg.sender] > 0, "No reward to claim");
        uint balanceInContrat = CA2Token.balanceOf(address(this));
        convertPancake(UserRewards[msg.sender], address(BUSD), address(CA2Token));
        uint CA2UserReward = CA2Token.balanceOf(address(this)).sub(balanceInContrat);

        Insert(CA2UserReward, true);
        emit RewardPaidRestake(msg.sender, CA2UserReward);
        UserRewards[msg.sender] = 0;
        if(UserPoolStakeAmount[msg.sender][PoolId - 1] > 0){
            Insert(UserPoolStakeAmount[msg.sender][PoolId - 1], false);
            UserPoolStakeAmount[msg.sender][PoolId - 1] = 0;
        }
        else{
            Insert(UserPoolStakeAmount[msg.sender][UserLastStakePool[msg.sender]], false);
            UserPoolStakeAmount[msg.sender][UserLastStakePool[msg.sender]] = 0;
        }
    }
    
    function RestakeLP() external{
        require(UserRewards[msg.sender] > 0, "No reward to claim");
        uint balanceInContrat = CA2Token.balanceOf(address(this));
        uint half = UserRewards[msg.sender];
        convertPancake(half, address(BUSD), address(CA2Token));
        convertPancake(half, address(BUSD), address(WBNB));
        uint CA2UserReward = CA2Token.balanceOf(address(this)).sub(balanceInContrat);

        // Liquidity pool
        uint256 token0Amt = CA2UserReward;
        uint256 token1Amt = IERC20(WBNB).balanceOf(address(this));
        require(token0Amt > 0 && token1Amt > 0, "token1Amt or token0Amt not greater than 0");
        if (token0Amt > 0 && token1Amt > 0) {
                IERC20(CA2Token).safeApprove(pancakerouter, 0);
                IERC20(CA2Token).safeApprove(pancakerouter, CA2UserReward);
                IERC20(WBNB).safeApprove(pancakerouter, 0);
                IERC20(WBNB).safeApprove(pancakerouter, WBNB.balanceOf(address(this)));
                Uni(pancakerouter).addLiquidity(
                    address(CA2Token),
                    address(WBNB),
                    token0Amt,
                    token1Amt,
                    0,
                    0,
                    address(this),
                    block.timestamp.add(1800)
                );
        }

        //Stake to LPFarm
        IERC20(CA2LPToken).safeApprove(CA2LPFarm, 0);
        IERC20(CA2LPToken).safeApprove(CA2LPFarm, CA2LPToken.balanceOf(address(this)));
        ICA2LPFarm(CA2LPFarm).stakeFarm(CA2LPToken.balanceOf(address(this)), msg.sender);
    }
    

    function convertPancake(uint _amount, address _tokenin, address _tokenout) public { //test
            require(!Address.isContract(msg.sender),"!contract");
            IERC20(_tokenin).safeApprove(pancakerouter, 0);
            IERC20(_tokenin).safeApprove(pancakerouter, uint256(_amount));
            if(_tokenout == address(WBNB)){
                address[] memory path = new address[](2);
                    path[0] = _tokenin;
                    path[1] = _tokenout;
                    Uni(pancakerouter).swapExactTokensForTokens(
                            _amount,
                            uint256(0),
                            path,
                            address(this),
                            block.timestamp.add(1800)
                    );
            }
            else{
                address[] memory path = new address[](3);
                    path[0] = _tokenin;
                    path[1] = address(WBNB);
                    path[2] = _tokenout;
                    Uni(pancakerouter).swapExactTokensForTokens(
                            _amount,
                            uint256(0),
                            path,
                            address(this),
                            block.timestamp.add(1800)
                    );
            }
            
    }

    function setCA2LPFarm(address _CA2Token, address _CA2LPFarm, address _CA2LPToken) external onlyOwner{
        CA2Token = IERC20(_CA2Token);
        CA2LPFarm = _CA2LPFarm;
        CA2LPToken = IERC20(_CA2LPToken);
    }

    function testNextPhase() external onlyOwner{
        PoolEndTime[PoolId] = block.timestamp - 1;
    }
}