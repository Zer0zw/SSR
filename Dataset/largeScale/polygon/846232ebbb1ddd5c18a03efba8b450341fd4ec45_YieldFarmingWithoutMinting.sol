/**
 *Submitted for verification at polygonscan.com on 2022-02-15
*/

// Sources flattened with hardhat v2.7.0 https://hardhat.org

// File contracts/_mock/MockERC20.sol

pragma solidity ^0.8.0;
// SPDX-License-Identifier: Unlicensed
contract MockERC20 {
    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint8 public constant decimals = 18;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(string memory name_, string memory symbol_) public {
        name = name_;
        symbol = symbol_;
    }

    function transfer(address _to, uint256 _value) external returns (bool success) {
        require(balanceOf[msg.sender] >= _value, 'ERC20: NOT enough tokens');
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success) {
        require(_value <= balanceOf[_from], 'ERC20: NOT enough tokens');
        require(_value <= allowance[_from][msg.sender], 'ERC20: NOT enough allowance tokens');
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function mint(address account, uint256 amount) external {
        require(account != address(0), 'ERC20: mint to the zero address');
        totalSupply += amount;
        balanceOf[account] += amount;
        emit Transfer(address(0), account, amount);
    }
}


// File contracts/_mock/MockTokens.sol


contract MockUSDC is MockERC20 {
    constructor() public MockERC20('MockUSDC', 'MUSDC') {}
}

contract MockEnergy is MockERC20 {
    constructor() public MockERC20('MockEnergy', 'MENERGY') {}
}


// File contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)



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


// File contracts/libs/Ownable.sol


// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)


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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), 'Ownable: caller is not the owner');
        _;
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
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
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


// File contracts/interfaces/IERC20.sol



interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// File contracts/interfaces/IPancakePair.sol



interface IPancakePair {
    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}


// File contracts/interfaces/IPancakeRouter.sol


interface IPancakeRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}


// File contracts/interfaces/IPancakeFactory.sol



interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}


// File contracts/libs/Lockable.sol



abstract contract Lockable {
    bool private unlocked = true;

    modifier withLock() {
        require(unlocked, 'Call locked');
        unlocked = false;
        _;
        unlocked = true;
    }
}


// File contracts/YieldFarmingWithoutMinting.sol


contract YieldFarmingWithoutMinting is Ownable, Lockable {
    struct Farm {
        address creator;
        IERC20 token;
        IPancakePair lpToken;
        string name;
        uint256 id;
        uint256 startsAt;
        uint256 lastRewardedBlock;
        uint256 lpLockTime;
        uint256 numberOfFarmers;
        uint256 lpTotalAmount;
        uint256 lpTotalLimit;
        uint256 farmersLimit;
        uint256 maxStakePerFarmer;
        uint256 revardsValue;
        uint256 revardsPerBlock;
        uint256 rewardPerTokenStored;
        uint256 lastUpdateBlock;
        uint256 durationInBlocks;
        bool isActive;
    }

    struct Farmer {
        address farmerAddress;
        uint256 balance;
        uint256 rewards;
        uint256 userRewardPerTokenPaid;
        uint256 startBlock;
        uint256 startTime;
    }

    Farm[] private _farms;
    mapping(uint256 => mapping(address => Farmer)) private _farmers;
    mapping(address => bool) private _pools;

    uint256 public farmsCount = 0;
    uint256 public creationFee;

    event FarmCreated(uint256 farmId);

    modifier updateReward(uint256 farmId, address farmerAddress) {
        Farm storage farm = _farms[farmId];
        Farmer storage farmer = _farmers[farmId][farmerAddress];

        farm.rewardPerTokenStored = rewardPerToken(farm);
        farm.lastUpdateBlock = block.number < farm.lastRewardedBlock ? block.number : farm.lastRewardedBlock;

        farmer.rewards = earned(farm.id, farmerAddress);
        farmer.userRewardPerTokenPaid = farm.rewardPerTokenStored;
        _;
    }

    constructor(uint256 _creationFee) {
        creationFee = _creationFee;
    }

    receive() external payable {}

    function createFarm(
        IERC20 token,
        IPancakePair lpToken,
        uint256 startsAt,
        uint256 durationInBlocks,
        uint256 lpLockTime,
        uint256 farmersLimit,
        uint256 maxStakePerFarmer,
        uint256 lpTotalLimit,
        uint256 revardsPerBlock
    ) external payable {
        if (_msgSender() != owner()) {
            require(msg.value >= creationFee, 'You need to pay fee for creating own yield farm');
        }

        address tokenAddress = address(token);
        address lpTokenAddress = address(lpToken);
        address pairToken0 = lpToken.token0();
        address pairToken1 = lpToken.token1();

        {
            require(!_pools[lpTokenAddress], 'This liquidity pool is already exist');

            IPancakeFactory factory = IPancakeFactory(lpToken.factory());

            address pairFromFactory = factory.getPair(pairToken0, pairToken1);

            require(
                pairFromFactory == lpTokenAddress && (pairToken0 == tokenAddress || pairToken1 == tokenAddress),
                'Liquidty pool is invalid'
            );
        }

        _pools[lpTokenAddress] = true;

        _farms.push(
            Farm({
                creator: _msgSender(),
                token: token,
                lpToken: lpToken,
                name: string(abi.encodePacked(IERC20(pairToken0).symbol(), '-', IERC20(pairToken1).symbol())),
                id: farmsCount,
                startsAt: startsAt,
                lastRewardedBlock: block.number + durationInBlocks,
                lpLockTime: lpLockTime,
                numberOfFarmers: 0,
                lpTotalAmount: 0,
                lpTotalLimit: lpTotalLimit,
                farmersLimit: farmersLimit,
                maxStakePerFarmer: maxStakePerFarmer,
                revardsValue: 0,
                revardsPerBlock: revardsPerBlock,
                rewardPerTokenStored: 0,
                lastUpdateBlock: 0,
                durationInBlocks: durationInBlocks,
                isActive: true
            })
        );
        uint256 farmId = farmsCount;
        farmsCount += 1;

        emit FarmCreated(farmId);
    }

    /**
     * Dev: owner or Creater can deposit Revards tokens.
     **/
    function depositRevards(uint256 farmId, uint256 amount) external {
        Farm storage farm = _farms[farmId];
        require(_msgSender() == owner() || _msgSender() == farm.creator, 'Only owner or creator can update this farm');
        farm.revardsValue += amount;
        farm.token.transferFrom(_msgSender(), address(this), amount);
    }

    /**
     * Dev: owner or Creater can withdrawal Revards tokens.
     **/
    function withdrawalRevards(uint256 farmId, uint256 amount) external onlyOwner {
        Farm storage farm = _farms[farmId];
        farm.revardsValue -= amount;
        farm.token.transfer(_msgSender(), amount);
    }

    function stake(uint256 farmId, uint256 amount) external withLock updateReward(farmId, msg.sender) {
        Farmer storage farmer = _farmers[farmId][_msgSender()];
        _stake(_farms[farmId], farmer, amount);
    }

    /*
    withdraw only reward
  */
    function harvest(uint256 farmId) external withLock updateReward(farmId, msg.sender) {
        _withdrawHarvest(_farms[farmId], _farmers[farmId][_msgSender()]);
    }

    /*
    withdraw both lp tokens and reward
  */
    function withdraw(uint256 farmId) external withLock updateReward(farmId, msg.sender) {
        Farm storage farm = _farms[farmId];
        Farmer storage farmer = _farmers[farmId][_msgSender()];

        _withdrawHarvest(farm, farmer);
        _withdrawLP(farm, farmer);
    }

    function emergencyWithdrawal(
        address farmerAddress,
        uint256 farmId,
        bool payHarvest
    ) external onlyOwner withLock updateReward(farmId, farmerAddress) {
        Farm storage farm = _farms[farmId];
        Farmer storage farmer = _farmers[farmId][farmerAddress];
        if (payHarvest) {
            _withdrawHarvest(farm, farmer);
        }
        _withdrawLP(farm, farmer);
    }

    function _stake(
        Farm storage farm,
        Farmer storage farmer,
        uint256 amount
    ) internal {
        require(amount > 0, 'Amount must be greater than zero');
        require(farm.isActive, 'This farm is inactive or not exist');
        require(block.timestamp >= farm.startsAt, 'Yield farming has not started yet for this farm');
        require(block.number <= farm.lastRewardedBlock, 'Yield farming is currently closed for this farm');

        uint256 farmersLimit = farm.farmersLimit;
        uint256 maxStakePerFarmer = farm.maxStakePerFarmer;
        uint256 lpTotalLimit = farm.lpTotalLimit;

        if (farmersLimit != 0) {
            require(farm.numberOfFarmers <= farmersLimit, 'This farm is already full');
        }

        if (lpTotalLimit != 0) {
            require(farm.lpTotalAmount + amount <= lpTotalLimit, 'This farm is already full');
        }

        if (maxStakePerFarmer != 0) {
            require(
                farmer.balance + amount <= maxStakePerFarmer,
                "You can't stake in this farm, because after that you will be a whale. Sorry :("
            );
        }

        farm.lpTotalAmount += amount;
        farmer.balance += amount;

        farm.lpToken.transferFrom(_msgSender(), address(this), amount);

        if (farmer.startBlock == 0) {
            farm.numberOfFarmers += 1;
            farmer.startBlock = block.number;
            farmer.startTime = block.timestamp;
            farmer.farmerAddress = _msgSender();
        }
    }

    function _withdrawLP(Farm storage farm, Farmer storage farmer) internal {
        uint256 amount = farmer.balance;

        require(amount > 0, 'Balance must be greater than zero');
        if (_msgSender() != owner()) {
            require(block.timestamp >= farmer.startTime + farm.lpLockTime, 'Too early for withdraw');
        }

        farm.lpTotalAmount -= amount;
        farm.numberOfFarmers -= 1;

        farmer.startBlock = 0;
        farmer.startTime = 0;
        farmer.balance = 0;
        farm.lpToken.transfer(farmer.farmerAddress, amount);
    }

    function _withdrawHarvest(Farm storage farm, Farmer storage farmer) internal {
        require(farmer.startBlock != 0, 'You are not a farmer');
        if (_msgSender() != owner()) {
            require(block.timestamp >= farmer.startTime + farm.lpLockTime, 'Too early for withdraw');
        }
        uint256 reward = farmer.rewards;

        require(farm.revardsValue >= reward, 'Not enough tokens');
        if (reward > 0) {
            farmer.rewards = 0;
            farm.revardsValue = farm.revardsValue - reward;
            farmer.startBlock = block.number;
            farm.token.transfer(farmer.farmerAddress, reward);
        }
    }

    function earned(uint256 farmId, address farmerAddress) public view returns (uint256) {
        Farm memory farm = _farms[farmId];
        Farmer memory farmer = _farmers[farmId][farmerAddress];
        uint256 rewardPerBlockNow = rewardPerToken(farm);
        return
            rewardPerBlockNow != 0
                ? ((farmer.balance * (rewardPerBlockNow - farmer.userRewardPerTokenPaid)) / 1 ether) + farmer.rewards
                : 0 + farmer.rewards;
    }

    function rewardPerToken(Farm memory farm) internal view returns (uint256) {
        uint256 lpTotalAmount = farm.lpTotalAmount;
        uint256 lastUpdateBlock = farm.lastUpdateBlock;
        uint256 lastRewardedBlock = farm.lastRewardedBlock;
        if (lpTotalAmount == 0 || lastUpdateBlock > farm.lastRewardedBlock) {
            return 0;
        }
        uint256 lastBlock = block.number;
        if (block.number > lastRewardedBlock) {
            lastBlock = lastRewardedBlock;
        }
        uint256 rewardedBlocks;
        if (lastUpdateBlock < lastBlock) {
            rewardedBlocks = lastBlock - lastUpdateBlock;
        }
        return (farm.rewardPerTokenStored + ((farm.revardsPerBlock * rewardedBlocks * 1 ether) / lpTotalAmount));
    }

    function me(uint256 farmId, address userAddress) external view returns (Farmer memory) {
        return _farmers[farmId][userAddress];
    }

    function updateFarm(
        uint256 farmId,
        uint256 startsAt,
        uint256 blocksDuration,
        uint256 lpLockTime,
        uint256 farmersLimit,
        uint256 maxStakePerFarmer,
        uint256 newRevardPerBlock
    ) external {
        Farm storage farm = _farms[farmId];

        require(_msgSender() == owner() || _msgSender() == farm.creator, 'Only owner or creator can update this farm');
        if (block.timestamp < farm.startsAt) {
            farm.lpLockTime = lpLockTime;
            farm.startsAt = startsAt;
        }

        farm.lastRewardedBlock = block.number + blocksDuration;
        farm.durationInBlocks = blocksDuration;
        farm.farmersLimit = farmersLimit;
        farm.maxStakePerFarmer = maxStakePerFarmer;
        farm.revardsPerBlock = newRevardPerBlock;
    }

    function setActive(uint256 farmId, bool value) external onlyOwner {
        _farms[farmId].isActive = value;
        _pools[address(_farms[farmId].lpToken)] = value;
    }

    function setRewardPerBlock(uint256 farmId, uint256 _newRevardPerBlock) public onlyOwner {
        Farm storage farm = _farms[farmId];
        farm.revardsPerBlock = _newRevardPerBlock;
    }

    function setCreationFee(uint256 _creationFee) external onlyOwner {
        creationFee = _creationFee;
    }

    function farms(uint256 start, uint256 size) external view returns (Farm[] memory) {
        Farm[] memory arrFarms = new Farm[](farmsCount);

        uint256 end = start + size > farmsCount ? farmsCount : start + size;

        for (uint256 i = start; i < end; i++) {
            Farm storage farm = _farms[i];
            arrFarms[i] = farm;
        }

        return arrFarms;
    }

    function withdrawFee() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}