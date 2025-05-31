/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IERC20 {
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);

    // Standard
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }


    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
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

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IAFBPoints {
    function viewDiscountOf(address _address) external view returns (uint256);
    function viewEligibilityOf(address _address) external view returns (uint256 tranche);
    function discountPointsNeeded(uint256 _tranche) external view returns (uint256 pointsNeeded);
    function viewTxThreshold() external view returns (uint256);
    function viewRedirection(address _address) external view returns (bool);

    function overrideLoyaltyPoints(address _address, uint256 _points) external;
    function addPoints(address _address, uint256 _txSize, uint256 _points) external;
    function burn(uint256 _amount) external;
}

interface IAFBGov {
    function mastermind() external view returns (address);
    function viewActorLevelOf(address _address) external view returns (uint256);
    function viewFeeDestination() external view returns (address);
    function viewTxThreshold() external view returns (uint256);
    function viewBurnRate() external view returns (uint256);
    function viewFeeRate() external view returns (uint256);
}

interface IAfterStakeVault {
    function buyAFBWithTokens(address token, uint256 amount) external;
    function buyPointsWithTokens(address token, uint256 amount) external;

    function calculateRewards() external;
    function distributeRewards(address recipient, uint256 amount) external;
    function getTokenPrice(address token, address lpToken) external view returns (uint256);
}

interface IAfterStakeMigrator {
    function migrateTo(address user, address token, uint256 amount) external;
}

interface IAfterStake {
    function addReward(uint256 amount) external;
    function claim(uint256 pid) external;
    function deposit(uint256 pid, uint256 amount) external;
    function withdraw(uint256 pid, uint256 amount) external;
}

abstract contract AFBUtils is Ownable {
    event TokenSweep(address indexed user, address indexed token, uint256 amount);

    // Sweep any tokens/BNB accidentally sent or airdropped to the contract
    function sweep(address token) public virtual onlyOwner {
        uint256 amount = IERC20(token).balanceOf(address(this));
        require(amount > 0, "Sweep: No token balance");

        IERC20(token).transfer(msg.sender, amount); // use of the ERC20 traditional transfer

        if (address(this).balance > 0) {
            payable(msg.sender).transfer(address(this).balance);
        }

        emit TokenSweep(msg.sender, token, amount);
    }

    // Self-Destruct contract to free space on-chain, sweep any BNB to owner
    function kill() external onlyOwner {
        selfdestruct(payable(msg.sender));
    }
}

abstract contract AFBGovernedUtils is AFBUtils {
    event GovernanceUpdated(address indexed user, address governance);

    address public governance;

    modifier onlyMastermind {
        require(
            msg.sender == IAFBGov(governance).mastermind() || msg.sender == owner(),
            "Gov: Only Mastermind"
        );
        _;
    }

    modifier onlyGovernor {
        require(
            IAFBGov(governance).viewActorLevelOf(msg.sender) >= 2 || msg.sender == owner(),
            "Gov: Only Governors"
        );
        _;
    }

    modifier onlyPartner {
        require(
            IAFBGov(governance).viewActorLevelOf(msg.sender) >= 1 || msg.sender == owner(),
            "Gov: Only Partners"
        );
        _;
    }

    function _setGovernance(address _governance) internal {
        require(_governance != governance, "SetGovernance: No governance change");

        governance = _governance;
        emit GovernanceUpdated(msg.sender, governance);
    }

    function setGovernance(address _governance) external onlyGovernor {
        _setGovernance(_governance);
    }
}

abstract contract AfterStakeUtils is AFBGovernedUtils {
    using SafeERC20 for IERC20;

    event PointsUpdated(address indexed user, address points);
    event TokenUpdated(address indexed user, address token);
    event UniswapUpdated(address indexed user, address router, address weth, address factory);
  
    address public router;
    address public factory;
    address public weth;
    address public AFBToken;
    address public AFBPoints;
    address public AFBTokenLp;
    address public AFBPointsLp;

    mapping (address => bool) internal _blacklistedAdminWithdraw;

    constructor(address _router, address _gov, address _points, address _token) {
        _setGovernance(_gov);

        router = _router;
        AFBPoints = _points;
        AFBToken = _token;
         
        weth = IUniswapV2Router02(router).WETH();
        factory = IUniswapV2Router02(router).factory();
        AFBTokenLp = IUniswapV2Factory(factory).getPair(_token, weth);
        AFBPointsLp = IUniswapV2Factory(factory).getPair(_points, weth);
    }

    function sweep(address _token) public override onlyOwner {
        require(!_blacklistedAdminWithdraw[_token], "Sweep: Cannot withdraw blacklisted token");

        AFBUtils.sweep(_token);
    }

    function isBlacklistedAdminWithdraw(address _token)
        external
        view
        returns (bool)
    {
        return _blacklistedAdminWithdraw[_token];
    }

    // Method to avoid underflow on token transfers
    function safeTokenTransfer(address user, address token, uint256 amount) internal {
        if (amount == 0) {
            return;
        }

        uint256 tokenBalance = IERC20(token).balanceOf(address(this));
        if (amount > tokenBalance) {
            IERC20(token).safeTransfer(user, tokenBalance);
        } else {
            IERC20(token).safeTransfer(user, amount);
        }
    }

    function setToken(address _token) external onlyGovernor {
        require(_token != AFBToken, "SetToken: No token change");
        require(_token != address(0), "SetToken: Must set token value");

        AFBToken = _token;
        AFBTokenLp = IUniswapV2Factory(factory).getPair(_token, weth);
        emit TokenUpdated(msg.sender, AFBToken);
    }

    function setPoints(address _points) external onlyGovernor {
        require(_points != AFBPoints, "SetPoints: No points change");
        require(_points != address(0), "SetPoints: Must set points value");

        AFBPoints = _points;
        AFBPointsLp = IUniswapV2Factory(factory).getPair(_points, weth);
        emit PointsUpdated(msg.sender, AFBPoints);
    }

    function setUniswap(address _router) external onlyGovernor {
        require(_router != router, "SetUniswap: No uniswap change");
        require(_router != address(0), "SetUniswap: Must set uniswap value");

        router = _router;
        weth = IUniswapV2Router02(router).WETH();
        factory = IUniswapV2Router02(router).factory();
        emit UniswapUpdated(msg.sender, router, weth, factory);
    }
}

contract AfterStake is IAfterStakeMigrator, IAfterStake, AfterStakeUtils {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // EVENTS
    event Initialized(address indexed user, address vault);
    event Claim(address indexed user, uint256 indexed pid, uint256 amount);
    event ClaimAll(address indexed user, uint256 amount);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Migrate(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event PoolAdded(address indexed user, uint256 indexed pid, address indexed stakedToken, address lpToken, uint256 allocPoints);
    event MigratorUpdated(address indexed user, address migrator);
    event VaultUpdated(address indexed user, address vault);
    event PoolAllocPointsUpdated(address indexed user, uint256 indexed pid, uint256 allocPoints);
    event PoolVipAmountUpdated(address indexed user, uint256 indexed pid, uint256 vipAmount);
    event PoolStakingFeeUpdated(address indexed user, uint256 indexed pid, uint256 stakingFee);
    event PointStipendUpdated(address indexed user, uint256 stipend);

    // STRUCTS
    // UserInfo - User metrics, pending reward = (user.amount * pool.AFBPerShare) - user.rewardDebt
    struct UserInfo {
        uint256 amount; // How many tokens the user has provided.
        uint256 rewardDebt; // Token rewards paid out to user
        uint256 lastRewardBlock; // last pool interaction
    }

    // PoolInfo - Pool metrics
    struct PoolInfo {
        address stakedToken; // Address of staked token contract.
        address lpToken; // pancakeswap LP token corresponding to the trading pair needed for price calculation
        uint256 totalStaked; // total tokens staked
        uint256 allocPoint; // How many allocation points assigned to this pool. AFBs to distribute per block. 
        uint256 rewardsPerShare; // Accumulated AFBs per share, times 1e18. See below.
        uint256 lastRewardBlock; // last pool update
        uint256 vipAmount; // amount of AFB tokens that must be staked to access the pool
        uint256 stakingFee; // the % withdrawal fee charged. base 1000, 50 = 5%
        uint256 rewardDebt; // rewards paid out to the pool
    }

    address public afterstake; // AfterStake V0 contract
    address public migrator; // contract where we may migrate too
    address public vault; // where rewards are stored for distribution

    PoolInfo[] public poolInfo; // array of AfterStake pools
    mapping(uint256 => mapping(address => UserInfo)) public userInfo; // mapping of (pid => (userAddress => userInfo))
    mapping(address => uint256) public pids; // quick mapping for pool ids (staked_token => pid)

    uint256 public pointStipend; // amount of AFBPoints awarded per deposit
    uint256 public rewardsPerAllocPoint; // rewards per pool allocPoint, times 1e18 to maintain precision
    uint256 public totalAllocPoint; // Total allocation points. Must be the sum of all allocation points in all pools.

    modifier NoReentrant(uint256 pid, address user) {
        require(
            block.number > userInfo[pid][user].lastRewardBlock,
            "AfterStake: Must wait 1 block"
        );
        _;
    }

    modifier onlyAfterStake {
        require(msg.sender == afterstake, "AfterStake: Only previous AfterStake allowed");
        _;
    }

    modifier onlyVault() {
        require(msg.sender == vault, "AfterStake: Only Vault allowed");
        _;
    }

    constructor(address _afterstake, address _router, address _gov, address _points, address _token)  
        AfterStakeUtils(_router, _gov, _points, _token)
    {
        afterstake = _afterstake;
        pointStipend = 1e18;
    }

    // Pool - Get any incoming rewards, called during Vault.distributeRewards()
    function addReward(uint256 amount) external override onlyVault {
        if (amount == 0) {
            return;
        }

        rewardsPerAllocPoint = rewardsPerAllocPoint.add(amount.mul(1e18).div(totalAllocPoint));
    }

    // Pool - Updates the reward variables of the given pool
    function updatePool(uint256 pid) external {
        _updatePool(pid);
    }

    // Pool - Update internal
    function _updatePool(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];

        if (pool.totalStaked == 0 || pool.lastRewardBlock >= block.number || pool.allocPoint == 0) {
            return;
        }

        // calculate rewards, returns if already done this block
        IAfterStakeVault(vault).calculateRewards();     

        // Calculate pool's share of pending rewards 
        uint256 poolRewards = pendingPool(_pid);
        
        // update pool variables
        if (poolRewards > 0) {
            pool.rewardsPerShare = pool.rewardsPerShare.add(poolRewards.mul(1e18).div(pool.totalStaked));
            pool.rewardDebt = pool.rewardDebt.add(poolRewards);
        }
        
        pool.lastRewardBlock = block.number;
    }

    // Pool - Update all pool reward variables
    // NOTE: Must call before any change to totalAllocPoint (addPool, updatePoolAllocPoints)
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; pid++) {
            _updatePool(pid);
        }
    }

    // Pool - Claim rewards
    function claim(uint256 pid) external override NoReentrant(pid, msg.sender) {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        _updatePool(pid);
        _claim(pid, msg.sender);

        // set user metrics, reward block
        user.rewardDebt = user.amount.mul(pool.rewardsPerShare).div(1e18);
        user.lastRewardBlock = block.number;
    }

    // Pool - Claim internal, called during deposit() and withdraw()
    function _claim(uint256 _pid, address _user) internal {
        uint256 rewards = pending(_pid, _user);
        if (rewards == 0) {
            return;
        }

        // transfer AFB rewards from Vault
        IAfterStakeVault(vault).distributeRewards(_user, rewards);
        emit Claim(_user, _pid, rewards);
    }

    // Pool - Claim all rewards, only perform one transfer to save gas
    function claimAll() external {
        uint256 totalClaimable;
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; pid++) {
            PoolInfo storage pool = poolInfo[pid];
            UserInfo storage user = userInfo[pid][msg.sender];
            if (user.lastRewardBlock < block.number && user.amount > 0) {
                _updatePool(pid);
                uint256 rewards = pending(pid, msg.sender);
                if (rewards > 0) {
                    totalClaimable = totalClaimable.add(rewards);
                    user.rewardDebt = user.amount.mul(pool.rewardsPerShare).div(1e18);
                    user.lastRewardBlock = block.number;
                    emit Claim(msg.sender, pid, rewards);
                }
            }
        }

        if (totalClaimable > 0) {
            IAfterStakeVault(vault).distributeRewards(msg.sender, totalClaimable);
            emit ClaimAll(msg.sender, totalClaimable);
        }
    }

    // Pool - Deposit Tokens
    function deposit(uint256 pid, uint256 amount) external override NoReentrant(pid, msg.sender) {
        _deposit(msg.sender, pid, amount);
    }

    // Pool - Deposit internal
    function _deposit(address _user, uint256 _pid, uint256 _amount) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        
        require(_amount > 0, "Deposit: Cannot deposit zero tokens");
        require(pool.allocPoint > 0, "Deposit: Pool is not active");
        require(pool.vipAmount <= userInfo[0][_user].amount, "Deposit: VIP Only");

        // Update and claim rewards
        _updatePool(_pid);
        _claim(_pid, _user);

        // Get tokens from user, balance check to support Fee-On-Transfer tokens
        uint256 amountBefore = IERC20(pool.stakedToken).balanceOf(address(this));
        IERC20(pool.stakedToken).safeTransferFrom(_user, address(this), _amount);
        uint256 amountAfter = IERC20(pool.stakedToken).balanceOf(address(this));
        uint256 amount = amountAfter.sub(amountBefore);

        // Finalize, update user metrics
        pool.totalStaked = pool.totalStaked.add(amount);
        user.amount = user.amount.add(amount);
        user.rewardDebt = user.amount.mul(pool.rewardsPerShare).div(1e18);
        user.lastRewardBlock = block.number;
        
        // reward user
        IAFBPoints(AFBPoints).addPoints(_user, IAFBPoints(AFBPoints).viewTxThreshold(), pointStipend);

        // Transfer the total amounts from user and update pool user.amount into the AfterStake contract
        emit Deposit(_user, _pid, amount);
    }

    // Pool - Withdraw staked tokens
    function withdraw(uint256 pid, uint256 amount) external override NoReentrant(pid, msg.sender) {
        _withdraw(msg.sender, pid, amount);
    }
    
    // Pool - Withdraw Internal
    function _withdraw(
        address _user,
        uint256 _pid,
        uint256 _amount
    ) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        require(_amount > 0, "Withdraw: amount must be greater than zero");
        require(user.amount >= _amount, "Withdraw: user amount insufficient");
        require(pool.vipAmount <= userInfo[0][_user].amount, "Withdraw: VIP Only");
        
        // claim rewards
        _updatePool(_pid);
        _claim(_pid, _user);

        // update pool / user metrics
        pool.totalStaked = pool.totalStaked.sub(_amount);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.rewardsPerShare).div(1e18);
        user.lastRewardBlock = block.number;

        // find the staking fee amount
        uint256 stakingFeeAmount = _amount.mul(pool.stakingFee).div(1000);
        // get user's remaining shares after fee
        uint256 remainingUserAmount = _amount.sub(stakingFeeAmount);

        if(stakingFeeAmount > 0){
            // Send Fee to Vault and buy AFB, balance check to support Fee-On-Transfer tokens
            uint256 balanceBefore = IERC20(pool.stakedToken).balanceOf(vault);
            safeTokenTransfer(vault, pool.stakedToken, stakingFeeAmount);
            uint256 balanceAfter = IERC20(pool.stakedToken).balanceOf(vault);
            uint256 balance = balanceAfter.sub(balanceBefore);
            // perform the buyback
            IAfterStakeVault(vault).buyAFBWithTokens(pool.stakedToken, balance);
        }

        // withdraw user tokens
        safeTokenTransfer(_user, pool.stakedToken, remainingUserAmount);        
        emit Withdraw(_user, _pid, remainingUserAmount);
    }

    // Pool - migrate stake to a new contract, should only be called after 
    function migrate(uint256 pid) external NoReentrant(pid, msg.sender) {
        _migrate(msg.sender, pid);
    }

    // Pool - migrate internal
    function _migrate(address _user, uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 balance = user.amount;

        require(migrator != address(0), "Migrate: No migrator set");
        require(balance > 0, "Migrate: No tokens to migrate");
        require(pool.allocPoint == 0, "Migrate: Pool is still active");

        _claim(_pid, _user);

        pool.totalStaked = pool.totalStaked.sub(balance);
        user.amount = 0;
        user.rewardDebt = 0;
        user.lastRewardBlock = block.number;

        IERC20(pool.stakedToken).safeApprove(migrator, balance);
        IAfterStakeMigrator(migrator).migrateTo(_user, pool.stakedToken, balance);
        emit Migrate(_user, _pid, balance);
    }

    function migrateTo(address _user, address _token, uint256 _amount) 
        external
        override
        onlyAfterStake
    {
        uint256 pid = pids[_token];
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][_user];

        _claim(pid, _user);

        // transfer user stake from AfterStake, do the balance check
        uint256 balanceBefore = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transferFrom(afterstake, address(this), _amount);
        uint256 balanceAfter = IERC20(_token).balanceOf(address(this));
        uint256 userDeposit = balanceAfter.sub(balanceBefore);

        // update user / pool metrics
        pool.totalStaked = pool.totalStaked.add(userDeposit);
        user.amount = user.amount.add(userDeposit);
        user.rewardDebt = user.amount.mul(pool.rewardsPerShare).div(1e18);
        user.lastRewardBlock = block.number;

        IAFBPoints(AFBPoints).addPoints(_user, IAFBPoints(AFBPoints).viewTxThreshold(), pointStipend);
    }

    // Pool - withdraw all stake and forfeit rewards, skips pool update
    function emergencyWithdraw(uint256 pid) external NoReentrant(pid, msg.sender) {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        require(user.amount > 0, "EmergencyWithdraw: user amount insufficient");

        // find the fee amount and remaining user share
        uint256 stakingFeeAmount = user.amount.mul(pool.stakingFee).div(1000);
        uint256 remainingUserAmount = user.amount.sub(stakingFeeAmount);

        // update pool / user metrics
        pool.totalStaked = pool.totalStaked.sub(user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
        user.lastRewardBlock = block.number;

        // transfer vault the fee for admins to perform buyback, send user share
        safeTokenTransfer(vault, pool.stakedToken, stakingFeeAmount);
        safeTokenTransfer(msg.sender, pool.stakedToken, remainingUserAmount);
        emit EmergencyWithdraw(msg.sender, pid, remainingUserAmount);
    }

    // View - gets stakedToken price from the Vault
    function getPrice(uint256 pid) external view returns (uint256) {
        address token = poolInfo[pid].stakedToken;
        address lpToken = poolInfo[pid].lpToken;

        return IAfterStakeVault(vault).getTokenPrice(token, lpToken);
    }

    // View - Pending AFB Rewards for user in pool
    function pending(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        return user.amount.mul(pool.rewardsPerShare).div(1e18).sub(user.rewardDebt);
    }

    // View - Pending AFB Rewards for a given pool
    function pendingPool(uint256 _pid)
        public
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        return rewardsPerAllocPoint.mul(pool.allocPoint).div(1e18).sub(pool.rewardDebt);
    }

    // View - View Pool Length
    function poolLength() external view returns (uint256) {
        return poolInfo.length; // number of pools (pids)
    }

    // Governance - Add Multiple Token Pools
    function addPoolBatch(
        address[] calldata tokens,
        address[] calldata lpTokens,
        uint256[] calldata allocPoints,
        uint256[] calldata vipAmounts,
        uint256[] calldata stakingFees
    ) external onlyGovernor {
        massUpdatePools();

        for (uint i = 0; i < tokens.length; i++) {
            _addPool(tokens[i], lpTokens[i], allocPoints[i], vipAmounts[i], stakingFees[i]);
        }
    }

    // Governance - Add Single Token Pool
    function addPool(
        address token,
        address lpToken, 
        uint256 allocPoint,
        uint256 vipAmount,
        uint256 stakingFee
    ) external onlyGovernor {
        massUpdatePools();
        _addPool(token, lpToken, allocPoint, vipAmount, stakingFee);
    }

    // Governance - Add Token Pool Internal
    function _addPool(
        address stakedToken,
        address lpToken,
        uint256 allocPoint,
        uint256 vipAmount,
        uint256 stakingFee
    ) internal {
        require(pids[stakedToken] == 0, "AddPool: Token pool already added");

        // add token to pids
        pids[stakedToken] = poolInfo.length;
        // stakedToken now non-withrawable by admins
        _blacklistedAdminWithdraw[stakedToken] = true;
        // update total pool points
        totalAllocPoint = totalAllocPoint.add(allocPoint);
        // find reward debt for the pool
        uint256 rewardDebt = rewardsPerAllocPoint.mul(allocPoint).div(1e18);

        // Add new pool
        poolInfo.push(
            PoolInfo({
                stakedToken: stakedToken,
                lpToken: lpToken,
                allocPoint: allocPoint,
                lastRewardBlock: block.number,
                totalStaked: 0,
                rewardsPerShare: 0,
                vipAmount: vipAmount,
                stakingFee: stakingFee,
                rewardDebt: rewardDebt
            })
        );

        emit PoolAdded(msg.sender, pids[stakedToken], stakedToken, lpToken, allocPoint);
    }

    // Governance - Set Migrator
    function setMigrator(address _migrator) external onlyGovernor {
        require(_migrator != address(0), "SetMigrator: No migrator change");

        migrator = _migrator;
        emit MigratorUpdated(msg.sender, _migrator);
    }

    // Governance - Set Vault
    function setVault(address _vault) external onlyGovernor {
        require(_vault != address(0), "SetVault: No migrator change");

        vault = _vault;
        emit VaultUpdated(msg.sender, vault);
    }

    // Governance - Set Pool Allocation Points, updates all pools to maintain reward distribution
    function setPoolAllocPoints(uint256[] calldata _pids, uint256[] calldata _allocPoints) external onlyGovernor {
        massUpdatePools();

        for (uint256 i = 0; i < _pids.length; i++) {
            _setPoolAllocPoints(_pids[i], _allocPoints[i]);
        }
    }

    // Governance - Internal, set one pool alloc points
    function _setPoolAllocPoints(uint256 _pid, uint256 _allocPoint) internal {
        PoolInfo storage pool = poolInfo[_pid];
        require(pool.allocPoint != _allocPoint, "SetAllocPoints: No points change");

        // update alloc points
        totalAllocPoint = totalAllocPoint.sub(pool.allocPoint).add(_allocPoint);
        pool.allocPoint = _allocPoint;
        emit PoolAllocPointsUpdated(msg.sender, _pid, _allocPoint);
    }

    // Governance - Set Pool VIP Amount, AFB staking requirement to enter the pool
    function setPoolVipAmount(uint256[] calldata _pids, uint256[] calldata _vipAmounts) external onlyGovernor {
        for (uint256 i = 0; i < _pids.length; i++) {
            _setPoolVipAmount(_pids[i], _vipAmounts[i]);
        }
    }

    // Governance - Internal, Set Pool VIP Amount
    function _setPoolVipAmount(uint256 _pid, uint256 _vipAmount) internal {
        require(poolInfo[_pid].vipAmount != _vipAmount, "SetVipAmount: No amount change");

        poolInfo[_pid].vipAmount = _vipAmount;
        emit PoolVipAmountUpdated(msg.sender, _pid, _vipAmount);
    }

    // Governance - Set Pool Staking Fee, % of basis taken on withdrawal to buyback AFB
    function setPoolStakingFee(uint256[] calldata _pids, uint256[] calldata _stakingFees) external onlyGovernor {
        for (uint256 i = 0; i < _pids.length; i++) {
            _setPoolStakingFee(_pids[i], _stakingFees[i]);
        }
    }

    // Governance - Internal, Set Pool Fee
    function _setPoolStakingFee(uint256 _pid, uint256 _stakingFee) internal {
        require(_stakingFee != poolInfo[_pid].stakingFee, "SetStakingFee: No fee change");
        require(_stakingFee <= 1000, "SetFee: Fee cannot exceed 100%");

        poolInfo[_pid].stakingFee = _stakingFee;
        emit PoolStakingFeeUpdated(msg.sender, _pid, _stakingFee);
    }

    // Governance - Set Point Stipend for the contract
    function setPointStipend(uint256 _pointStipend) external onlyGovernor {
        require(_pointStipend != pointStipend, "SetStipend: No stipend change");

        pointStipend = _pointStipend;
        emit PointStipendUpdated(msg.sender, pointStipend);
    }
}

contract AfterStakeV0 is IAfterStake, AfterStakeUtils {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // EVENTS
    event Initialized(address indexed user, address vault);
    event Claim(address indexed user, uint256 indexed pid, uint256 amount);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Migrate(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event PoolAdded(address indexed user, uint256 indexed pid, address indexed stakedToken, address lpToken, uint256 allocPoints);
    event MigratorUpdated(address indexed user, address migrator);
    event VaultUpdated(address indexed user, address vault);
    event PoolAllocPointsUpdated(address indexed user, uint256 indexed pid, uint256 allocPoints);
    event PoolVipAmountUpdated(address indexed user, uint256 indexed pid, uint256 vipAmount);
    event PoolStakingFeeUpdated(address indexed user, uint256 indexed pid, uint256 stakingFee);
    event PointStipendUpdated(address indexed user, uint256 stipend);

    // STRUCTS
    // UserInfo - User metrics, pending reward = (user.amount * pool.AFBPerShare) - user.rewardDebt
    struct UserInfo {
        uint256 amount; // How many tokens the user has provided.
        uint256 rewardDebt; // Token rewards paid out to user
        uint256 lastRewardBlock; // last pool interaction
    }

    // PoolInfo - Pool metrics
    struct PoolInfo {
        address stakedToken; // Address of staked token contract.
        address lpToken; // pancakeswap LP token corresponding to the trading pair needed for price calculation
        uint256 totalStaked; // total tokens staked
        uint256 allocPoint; // How many allocation points assigned to this pool. AFBs to distribute per block.
        uint256 rewardsPerShare; // Accumulated AFBs per share, times 1e18. See below.
        uint256 lastRewardBlock; // last pool update
        uint256 vipAmount; // amount of AFB tokens that must be staked to access the pool
        uint256 stakingFee; // the % withdrawal fee charged. base 1000, 50 = 5%
    }

    address public migrator; // contract where we may migrate too
    address public vault; // where rewards are stored for distribution
    bool public initialized;

    PoolInfo[] public poolInfo; // array of AfterStake pools
    mapping(uint256 => mapping(address => UserInfo)) public userInfo; // mapping of (pid => (userAddress => userInfo))
    mapping(address => uint256) public pids; // quick mapping for pool ids (staked_token => pid)

    uint256 public lastRewardBlock; // last block the pool was updated
    uint256 public pendingRewards; // pending AFB rewards awaiting anyone to be distro'd to pools
    uint256 public pointStipend; // amount of AFBPoints awarded per deposit
    uint256 public totalAllocPoint; // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalBlockDelta; // Total blocks since last update
    uint256 public totalEligiblePools; // Amount of pools eligible for rewards

    modifier NoReentrant(uint256 pid, address user) {
        require(
            block.number > userInfo[pid][user].lastRewardBlock,
            "AfterStake: Must wait 1 block"
        );
        _;
    }

    modifier onlyVault() {
        require(msg.sender == vault, "AfterStake: Only Vault allowed");
        _;
    }

    modifier activated() {
        require(initialized, "AfterStake: Not initialized yet");
        _;
    }

    constructor(address _router, address _gov, address _points, address _token) 
        AfterStakeUtils(_router, _gov, _points, _token)
    {
        pointStipend = 1e18;
    }
    
    // Initialize pools/rewards after the Vault has been setup
    function initialize(address _vault) public onlyGovernor {
        require(_vault != address(0), "Initalize: Must pass in Vault");
        require(!initialized, "Initialize: AfterStake already initialized");

        vault = _vault;
        initialized = true;
        emit Initialized(msg.sender, _vault);
    }

    // Pool - Get any incoming rewards, called during Vault.distributeRewards()
    function addReward(uint256 amount) external override onlyVault {
        if (amount == 0) {
            return;
        }

        pendingRewards = pendingRewards.add(amount);
    }

    // Pool - Updates the reward variables of the given pool
    function updatePool(uint256 pid) external {
        _updatePool(pid);
    }

    // Pool - Update internal
    function _updatePool(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        if (pool.totalStaked == 0 || pool.lastRewardBlock >= block.number || pool.allocPoint == 0) {
            return;
        }

        // calculate total reward blocks since last update call
        if (lastRewardBlock < block.number) {
            totalBlockDelta = totalBlockDelta.add(block.number.sub(lastRewardBlock).mul(totalEligiblePools));
            lastRewardBlock = block.number;
        }

        // calculate rewards, returns if already done this block
        IAfterStakeVault(vault).calculateRewards();        

        // Calculate pool's share of pending rewards, using blocks since last reward and alloc points
        uint256 poolBlockDelta = block.number.sub(pool.lastRewardBlock);
        uint256 poolRewards = pendingRewards
            .mul(poolBlockDelta)
            .div(totalBlockDelta)
            .mul(pool.allocPoint)
            .div(totalAllocPoint);
        
        // update reward variables
        totalBlockDelta = poolBlockDelta > totalBlockDelta ? 0 : totalBlockDelta.sub(poolBlockDelta);
        pendingRewards = poolRewards > pendingRewards ? 0 : pendingRewards.sub(poolRewards);
        
        // update pool variables
        pool.rewardsPerShare = pool.rewardsPerShare.add(poolRewards.mul(1e18).div(pool.totalStaked));
        pool.lastRewardBlock = block.number;
    }

    // Pool - Claim rewards
    function claim(uint256 pid) external override NoReentrant(pid, msg.sender) {
        _updatePool(pid);
        _claim(pid, msg.sender);
    }

    // Pool - Claim internal, called during deposit() and withdraw()
    function _claim(uint256 _pid, address _user) internal {
        UserInfo storage user = userInfo[_pid][_user];

        uint256 rewards = pending(_pid, _user);
        if (rewards == 0) {
            return;
        }

        // update pool / user metrics
        user.rewardDebt = user.amount.mul(poolInfo[_pid].rewardsPerShare).div(1e18);
        user.lastRewardBlock = block.number;

        // transfer AFB rewards
        IAfterStakeVault(vault).distributeRewards(_user, rewards);
        emit Claim(_user, _pid, rewards);
    }

    // Pool - Deposit Tokens
    function deposit(uint256 pid, uint256 amount) external override NoReentrant(pid, msg.sender) {
        _deposit(msg.sender, pid, amount);
    }

    // Pool - Deposit internal
    function _deposit(address _user, uint256 _pid, uint256 _amount) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        
        require(_amount > 0, "Deposit: Cannot deposit zero tokens");
        require(pool.allocPoint > 0, "Deposit: Pool is not active");
        require(pool.vipAmount <= userInfo[0][_user].amount, "Deposit: VIP Only");

        // add pool to reward calculation if previously no tokens staked
        if (pool.totalStaked == 0) {
            totalEligiblePools = totalEligiblePools.add(1);
            pool.lastRewardBlock = block.number; // reset reward block

            // begin computing rewards from this block if the first
            if (lastRewardBlock == 0) {
                lastRewardBlock = block.number;
            }
        }

        // Update and claim rewards
        _updatePool(_pid);
        _claim(_pid, _user);

        // Get tokens from user, balance check to support Fee-On-Transfer tokens
        uint256 amount = IERC20(pool.stakedToken).balanceOf(address(this));
        IERC20(pool.stakedToken).safeTransferFrom(_user, address(this), _amount);
        amount = IERC20(pool.stakedToken).balanceOf(address(this)).sub(amount);

        // Finalize, update user metrics
        pool.totalStaked = pool.totalStaked.add(amount);
        user.amount = user.amount.add(amount);
        user.rewardDebt = user.amount.mul(pool.rewardsPerShare).div(1e18);
        
        // reward user
        IAFBPoints(AFBPoints).addPoints(_user, IAFBPoints(AFBPoints).viewTxThreshold(), pointStipend);

        // Transfer the total amounts from user and update pool user.amount into the AfterStake contract
        emit Deposit(_user, _pid, amount);
    }

    // Pool - Withdraw staked tokens
    function withdraw(uint256 pid, uint256 amount) external override NoReentrant(pid, msg.sender) {
        _withdraw(msg.sender, pid, amount);
    }
    
    // Pool - Withdraw Internal
    function _withdraw(
        address _user,
        uint256 _pid,
        uint256 _amount
    ) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        require(_amount > 0, "Withdraw: amount must be greater than zero");
        require(user.amount >= _amount, "Withdraw: user amount insufficient");
        require(pool.vipAmount <= userInfo[0][_user].amount, "Withdraw: VIP Only");
        
        // claim rewards
        _updatePool(_pid);
        _claim(_pid, _user);

        // update pool / user metrics
        pool.totalStaked = pool.totalStaked.sub(_amount);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.rewardsPerShare).div(1e18);

        // reduce eligible pools only if done by user actions
        if (pool.totalStaked == 0 && pool.allocPoint > 0) {
            totalEligiblePools = totalEligiblePools.sub(1);
        }

        // PID = 0 : AFB-LP
        // PID = 1 : AFBPoints-LP
        // PID = 2 : weth
        // PID > 2 : all other tokens
        // No fee on AFB-BNB, AFBPoints-BNB pools
        uint256 stakingFeeAmount = _amount.mul(pool.stakingFee).div(1000);
        uint256 remainingUserAmount = _amount.sub(stakingFeeAmount);

        if(stakingFeeAmount > 0){
            // Send Fee to Vault and buy AFB, balance check to support Fee-On-Transfer tokens
            uint256 balance = IERC20(pool.stakedToken).balanceOf(vault);
            safeTokenTransfer(vault, pool.stakedToken, stakingFeeAmount);
            balance = IERC20(pool.stakedToken).balanceOf(vault);
            IAfterStakeVault(vault).buyAFBWithTokens(pool.stakedToken, balance);
        }

        // withdraw user tokens
        safeTokenTransfer(_user, pool.stakedToken, remainingUserAmount);        
        emit Withdraw(_user, _pid, remainingUserAmount);
    }

    // Pool - migrate stake to a new contract, should only be called after 
    function migrate(uint256 pid) external NoReentrant(pid, msg.sender) {
        _migrate(msg.sender, pid);
    }

    // Pool - migrate internal
    function _migrate(address _user, uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 balance = user.amount;

        require(migrator != address(0), "Migrate: No migrator set");
        require(balance > 0, "Migrate: No tokens to migrate");
        require(pool.allocPoint == 0, "Migrate: Pool is still active");

        _claim(_pid, _user);

        IERC20(pool.stakedToken).safeApprove(migrator, balance);
        IAfterStakeMigrator(migrator).migrateTo(_user, pool.stakedToken, balance);
        emit Migrate(_user, _pid, balance);
    }

    // Pool - withdraw all stake and forfeit rewards, skips pool update
    function emergencyWithdraw(uint256 pid) external NoReentrant(pid, msg.sender) {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        require(user.amount > 0, "EmergencyWithdraw: user amount insufficient");

        uint256 stakingFeeAmount = user.amount.mul(pool.stakingFee).div(1000);
        uint256 remainingUserAmount = user.amount.sub(stakingFeeAmount);
        pool.totalStaked = pool.totalStaked.sub(user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
        user.lastRewardBlock = block.number;

        if (pool.totalStaked == 0) {
            totalEligiblePools = totalEligiblePools.sub(1);
        }

        safeTokenTransfer(vault, pool.stakedToken, stakingFeeAmount);
        safeTokenTransfer(msg.sender, pool.stakedToken, remainingUserAmount);
        emit EmergencyWithdraw(msg.sender, pid, remainingUserAmount);
    }

    // View - gets stakedToken price from the Vault
    function getPrice(uint256 pid) external view returns (uint256) {
        address token = poolInfo[pid].stakedToken;
        address lpToken = poolInfo[pid].lpToken;

        return IAfterStakeVault(vault).getTokenPrice(token, lpToken);
    }

    // View - Pending AFB Rewards for user in pool
    function pending(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];

        // not sure if this will work with tokens non-1e18 decimals
        return user.amount.mul(pool.rewardsPerShare).div(1e18).sub(user.rewardDebt);
    }

    // View - View Pool Length
    function poolLength() external view returns (uint256) {
        return poolInfo.length; // number of pools (pids)
    }

    // Governance - Add Multiple Token Pools
    function addPoolBatch(
        address[] calldata tokens,
        address[] calldata lpTokens,
        uint256[] calldata allocPoints,
        uint256[] calldata vipAmounts,
        uint256[] calldata stakingFees
    ) external onlyGovernor {
        for (uint i = 0; i < tokens.length; i++) {
            _addPool(tokens[i], lpTokens[i], allocPoints[i], vipAmounts[i], stakingFees[i]);
        }
    }

    // Governance - Add Single Token Pool
    function addPool(
        address token,
        address lpToken, 
        uint256 allocPoint,
        uint256 vipAmount,
        uint256 stakingFee
    ) external onlyGovernor {
        _addPool(token, lpToken, allocPoint, vipAmount, stakingFee);
    }

    // Governance - Add Token Pool Internal
    function _addPool(
        address stakedToken,
        address lpToken,
        uint256 allocPoint,
        uint256 vipAmount,
        uint256 stakingFee
    ) internal {
        require(pids[stakedToken] == 0, "AddPool: Token pool already added");

        pids[stakedToken] = poolInfo.length;
        _blacklistedAdminWithdraw[stakedToken] = true; // stakedToken now non-withrawable by admins
        totalAllocPoint = totalAllocPoint.add(allocPoint);

        // Add new pool
        poolInfo.push(
            PoolInfo({
                stakedToken: stakedToken,
                lpToken: lpToken,
                allocPoint: allocPoint,
                lastRewardBlock: block.number,
                totalStaked: 0,
                rewardsPerShare: 0,
                vipAmount: vipAmount,
                stakingFee: stakingFee
            })
        );

        emit PoolAdded(msg.sender, pids[stakedToken], stakedToken, lpToken, allocPoint);
    }

    // Governance - Set Migrator
    function setMigrator(address _migrator) external onlyGovernor {
        require(_migrator != address(0), "SetMigrator: No migrator change");

        migrator = _migrator;
        emit MigratorUpdated(msg.sender, _migrator);
    }

    // Governance - Set Vault
    function setVault(address _vault) external onlyGovernor {
        require(_vault != address(0), "SetVault: No migrator change");

        vault = _vault;
        emit VaultUpdated(msg.sender, vault);
    }

    // Governance - Set Pool Allocation Points
    function setPoolAllocPoints(uint256 _pid, uint256 _allocPoint) external onlyGovernor {
        require(poolInfo[_pid].allocPoint != _allocPoint, "SetAllocPoints: No points change");

        if (_allocPoint == 0) {
            totalEligiblePools = totalEligiblePools.sub(1);
        }

        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
        emit PoolAllocPointsUpdated(msg.sender, _pid, _allocPoint);
    }

    // Governance - Set Pool Charge Fee
    function setPoolVipAmount(uint256 _pid, uint256 _vipAmount) external onlyGovernor {
        require(poolInfo[_pid].vipAmount != _vipAmount, "SetVipAmount: No amount change");

        poolInfo[_pid].vipAmount = _vipAmount;
        emit PoolVipAmountUpdated(msg.sender, _pid, _vipAmount);
    }

    // Governance - Set Pool Charge Fee
    function setPoolChargeFee(uint256 _pid, uint256 _stakingFee) external onlyGovernor {
        require(poolInfo[_pid].stakingFee != _stakingFee, "SetStakingFee: No fee change");

        poolInfo[_pid].stakingFee = _stakingFee;
        emit PoolStakingFeeUpdated(msg.sender, _pid, _stakingFee);
    }

    // Governance - Set Pool Allocation Points
    function setPointStipend(uint256 _pointStipend) external onlyGovernor {
        require(_pointStipend != pointStipend, "SetStipend: No stipend change");

        pointStipend = _pointStipend;
        emit PointStipendUpdated(msg.sender, pointStipend);
    }
}