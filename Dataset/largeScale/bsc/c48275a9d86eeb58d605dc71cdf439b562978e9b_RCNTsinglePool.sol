/**
 *Submitted for verification at BscScan.com on 2022-08-14
*/

// File: RichCatsToken.sol


pragma solidity ^0.8;

abstract contract RichCatsToken {
    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool);
    
    function balanceOf(address owner) public virtual view returns (uint);

    function approve(address spender, uint value) public virtual returns (bool);
}
// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: rcntdualpool.sol


pragma solidity ^0.8.13;





contract RCNTsinglePool is Ownable{

    event Deposit(address indexed depositor, uint amount);
    event Withdraw(address indexed withdrawer, uint amount);

    mapping(uint256 => mapping(address => Staker)) public stake;
    mapping(uint256 => StakerHistory) public stakehistory;
    mapping(uint256 => StakingPool) public stakingpool;

    
    uint256 public txCount;    
    uint256 public TOTAL_INTEREST_PAID;
    uint256 public TAX_COLLECTED;


    address constant RCNT_ADDRESS = 0xBa778D691f363984984Cd36c83BC81e0062B51c6;

    struct Staker {
        uint256 deposit_amount;
        uint256 stake_creation_time;
        address staker_addr;
    }

    struct StakerHistory {
        uint256 deposit_amount;
        uint256 stake_creation_time;
        address staker_addr;
        string depositORwithdraw;
    }

    struct StakingPool {
        uint256 MAX_POOL_VALUE;
        uint256 EMISSIONS_RATE;
        uint256 MINIMUM_DURATION;
        uint256 TAX_RATE;
        uint256 CURRENT_POOL_VALUE;
    }


    function SET_POOL_VALUE(uint256 pool_id, uint256 newPoolValue, uint256 newEmissionRate,uint256 newDuration, uint256 newTaxRate) public onlyOwner {
        StakingPool memory pool_item = stakingpool[pool_id];
        stakingpool[pool_id] = StakingPool(newPoolValue,newEmissionRate,newDuration,newTaxRate,pool_item.CURRENT_POOL_VALUE);
    }



    function depositRCNT(uint256 pool_id,uint256 depositvalue) public payable {
        Staker memory item = stake[pool_id][msg.sender];
        StakingPool memory pool_item = stakingpool[pool_id];
        
        require((pool_item.CURRENT_POOL_VALUE + depositvalue) <= pool_item.MAX_POOL_VALUE, "Max pool size reached! lower deposit amount");
        require(pool_item.CURRENT_POOL_VALUE <= pool_item.MAX_POOL_VALUE, "Staking Pool has reached max size!");
        require(RichCatsToken(RCNT_ADDRESS).balanceOf(msg.sender) > depositvalue, "Balance of RCNT not sufficient.");

        //transfer pending reward
        if (item.deposit_amount != 0) {
            uint256 pendingrewards = (block.timestamp - item.stake_creation_time)* pool_item.EMISSIONS_RATE * item.deposit_amount/10e18;
            require(RichCatsToken(RCNT_ADDRESS).approve(address(this),pendingrewards));
            RichCatsToken(RCNT_ADDRESS).transferFrom(address(this),msg.sender,pendingrewards);
            TOTAL_INTEREST_PAID += pendingrewards;
        }
        
        //update record
        stake[pool_id][msg.sender] = Staker(item.deposit_amount+depositvalue, block.timestamp, msg.sender);
        stakehistory[txCount] = StakerHistory(depositvalue, block.timestamp, msg.sender,"deposit");
        stakingpool[pool_id].CURRENT_POOL_VALUE += depositvalue; 
        
        //transfer depositvalue
        require(RichCatsToken(RCNT_ADDRESS).approve(msg.sender,depositvalue));
        RichCatsToken(RCNT_ADDRESS).transferFrom(msg.sender,address(this),depositvalue);

        pool_item.CURRENT_POOL_VALUE += depositvalue;
        txCount ++;
        emit Deposit(msg.sender,depositvalue);

    }




    function unstakeRCNT(uint256 pool_id,uint256 withdrawvalue) public payable {
        Staker memory item = stake[pool_id][msg.sender];
        StakingPool memory pool_item = stakingpool[pool_id];

        require(withdrawvalue <= item.deposit_amount, "amount is bigger than deposit balance!");
        
        // transfer pending reward
        uint256 pendingrewards = (block.timestamp - item.stake_creation_time)* pool_item.EMISSIONS_RATE * item.deposit_amount/10e18;
        require(RichCatsToken(RCNT_ADDRESS).approve(address(this),pendingrewards));
        RichCatsToken(RCNT_ADDRESS).transferFrom(address(this),msg.sender,pendingrewards);
        TOTAL_INTEREST_PAID += pendingrewards;


        //check if taxeable charged TAX_RATE%
        if ( block.timestamp - item.stake_creation_time < pool_item.MINIMUM_DURATION) {
            
            //update record
            stake[pool_id][msg.sender] = Staker(item.deposit_amount-withdrawvalue, block.timestamp, msg.sender);
            stakehistory[txCount] = StakerHistory(withdrawvalue, block.timestamp, msg.sender,"withdraw");

            //transfer withdrawvalue
            uint tax_amount = withdrawvalue*pool_item.TAX_RATE/100;
            uint balanceafterTax = withdrawvalue - tax_amount; 
            require(RichCatsToken(RCNT_ADDRESS).approve(address(this),balanceafterTax));
            RichCatsToken(RCNT_ADDRESS).transferFrom(address(this),msg.sender,balanceafterTax);
            TAX_COLLECTED += tax_amount;
            
        } else {
            //update record
            stake[pool_id][msg.sender] = Staker(item.deposit_amount-withdrawvalue, block.timestamp, msg.sender);
            stakehistory[txCount] = StakerHistory(withdrawvalue, block.timestamp, msg.sender,"withdraw");

            //transfer withdrawvalue
            require(RichCatsToken(RCNT_ADDRESS).approve(address(this),withdrawvalue));
            RichCatsToken(RCNT_ADDRESS).transferFrom(address(this),msg.sender,withdrawvalue);
        }

    stakingpool[pool_id].CURRENT_POOL_VALUE -= withdrawvalue;
    txCount ++;
    emit Withdraw(msg.sender,withdrawvalue);
    }



    function claimRewards(uint256 pool_id) public {
        Staker memory item = stake[pool_id][msg.sender];
        StakingPool memory pool_item = stakingpool[pool_id];

        require(item.deposit_amount > 0, "no deposit amount!");

        //calculate reward
        uint256 pendingrewards = (block.timestamp - item.stake_creation_time)* pool_item.EMISSIONS_RATE * item.deposit_amount/10e18;

         //update new timestamp
        stake[pool_id][msg.sender] = Staker(item.deposit_amount, block.timestamp, msg.sender);

        //transfer reward
        require(RichCatsToken(RCNT_ADDRESS).approve(address(this),pendingrewards));
        RichCatsToken(RCNT_ADDRESS).transferFrom(address(this),msg.sender,pendingrewards);
        TOTAL_INTEREST_PAID += pendingrewards;
        
    }




  function GET_POOL_BALANCE() public view returns(uint256) {
    
    return RichCatsToken(RCNT_ADDRESS).balanceOf(address(this));
  }


  function getRewards(uint256 pool_id, address stake_addr) public view returns(uint256) {
    Staker memory item = stake[pool_id][stake_addr];
    StakingPool memory pool_item = stakingpool[pool_id];
    if (item.deposit_amount != 0) {
        return (block.timestamp - item.stake_creation_time) * pool_item.EMISSIONS_RATE * item.deposit_amount/10e18;
    }
    else {
        return (0);
    }
  }

}