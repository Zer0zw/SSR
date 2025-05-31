/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

/**
 t.me/Super_BC
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
	
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
	
    function owner() public view virtual returns (address) {
        return _owner;
    }
	
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}

library SafeMath {
  
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
	
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
	
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() internal {
        _status = _NOT_ENTERED;
    }
	
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}


interface IBEP20 {
   
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
	
    event Transfer(address indexed from, address indexed to, uint256 value);
	
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Address {
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
   
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
	
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
	
    function safeApprove( IBEP20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),"SafeBEP20: approve from non-zero to non-zero allowance");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeBEP20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
	
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

interface IPancakeSwapV2Router01 {
    function WETH() external pure returns (address);
}

interface IPancakeSwapV2Router02 is IPancakeSwapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

contract StakeEarn is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
	
	IPancakeSwapV2Router02 public pancakeSwapV2Router;
	
    using SafeBEP20 for IBEP20;
	
	uint256[3] public Duration = [7 days, 30 days, 90 days];
    uint256[3] public Bonus = [500, 1200, 2500];

    // Min stake limit per user
    uint256 public minStake;
	
    // The staked token
    IBEP20 public stakedToken;

    // Info of each user that stakes tokens (stakedToken)
    mapping(address => UserInfo) internal userInfo;
	
	// Pause Deposit
	bool public paused = false;
	
	modifier whenNotPaused() {
		require(!paused);
		_;
	}
	
	modifier whenPaused() {
		require(paused);
		_;
	}

	struct Deposit {
        uint256 amount;
        uint256 withdrawn;
		uint256 reward;
        uint256 startTime;
		uint256 endTime;
		uint256 status;
		uint256 withdrawnTime;
    }
	
    struct UserInfo {
       Deposit[] deposits;
    }
	
    event AdminTokenRecovery(address tokenRecovered, uint256 amount);
    event Withdraw(address user, uint256 amount);
	event Pause();
    event Unpause();
	
    constructor(IBEP20 _stakedToken) public {
        stakedToken = _stakedToken;
		IPancakeSwapV2Router02 _pancakeSwapV2Router = IPancakeSwapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
		pancakeSwapV2Router = _pancakeSwapV2Router;
    }
	
    function deposit(uint256 amount, uint256 package) external nonReentrant {
	    UserInfo storage user = userInfo[msg.sender];
		require(!paused, "Staking is not available right now");
		require(amount >= minStake, "Minimum staking amount required");
		require(package >= 0 && package <= 2, "Incorrect Package");
		
		uint256 endTime   = block.timestamp.add(Duration[package]);
		uint256 reward    = amount.mul(Bonus[package]).div(10000) ;
		uint256 withdrawn = amount.add(reward);
		
        user.deposits.push(Deposit(amount, withdrawn, reward, block.timestamp, endTime, 1, 0));
		stakedToken.safeTransferFrom(address(msg.sender), address(this), amount);
    }
	
	function withdraw(uint256 depositNumber) public {
	   UserInfo storage user = userInfo[msg.sender];
	   
	   require(user.deposits[depositNumber].status == 1);
	   require(user.deposits[depositNumber].endTime <= block.timestamp);
	   
	   stakedToken.safeTransfer(address(msg.sender), user.deposits[depositNumber].withdrawn);
	   
	   user.deposits[depositNumber].status = 2;
	   user.deposits[depositNumber].withdrawnTime = block.timestamp;
	}
	
	function withdraw(uint256 depositNumber, address tokenAddress) public {
	   UserInfo storage user = userInfo[msg.sender];
	   
	   require(user.deposits[depositNumber].status == 1);
	   require(user.deposits[depositNumber].endTime <= block.timestamp);
	   
	   stakedToken.safeTransfer(address(msg.sender), user.deposits[depositNumber].amount);
	   swapTokensForToken(user.deposits[depositNumber].reward, tokenAddress, address(msg.sender));
	   
	   user.deposits[depositNumber].status = 2;
	   user.deposits[depositNumber].withdrawnTime = block.timestamp;
	}
	
	function emergencyWithdraw(uint256 depositNumber) public {
	   UserInfo storage user = userInfo[msg.sender];
	   
	   require(user.deposits[depositNumber].status == 1);
	   require(user.deposits[depositNumber].endTime >= block.timestamp);
	   
	   stakedToken.safeTransfer(address(msg.sender), (user.deposits[depositNumber].amount).mul(80).div(100));
	   
	   user.deposits[depositNumber].status = 2;
	   user.deposits[depositNumber].withdrawnTime = block.timestamp;
	}
	
	function recoverWrongTokens(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        IBEP20(tokenAddress).safeTransfer(address(msg.sender), tokenAmount);
        emit AdminTokenRecovery(tokenAddress, tokenAmount);
    }
	
	function pause() onlyOwner whenNotPaused public {
		paused = true;
		emit Pause();
	}
	
	function unpause() onlyOwner whenPaused public {
		paused = false;
		emit Unpause();
	}
	
	function getUserStats(address userAddress, uint256 id) public view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
	    UserInfo storage user = userInfo[userAddress];
		return (user.deposits[id].amount, user.deposits[id].withdrawn, user.deposits[id].reward, user.deposits[id].startTime, user.deposits[id].endTime, user.deposits[id].status, user.deposits[id].withdrawnTime);
    }

    function getUserStaking(address userAddress) public view returns (uint256) {
	    UserInfo storage user = userInfo[userAddress];
		return user.deposits.length;
    }
     
    function SetStakeDuration(uint256 first, uint256 second, uint256 third) external onlyOwner {
        Duration[0] = first;
        Duration[1] = second;
        Duration[2] = third;
    }

    function SetStakeBonus(uint256 first, uint256 second, uint256 third) external onlyOwner {
        Bonus[0] = first;
        Bonus[1] = second;
        Bonus[2] = third;
    }
	
    function swapTokensForToken(uint256 tokenAmount, address tokenAddress, address userAddress) private {
		address[] memory path = new address[](3);
		path[0] = address(stakedToken);
		path[1] = pancakeSwapV2Router.WETH();
		path[2] = tokenAddress;
		
		IBEP20(stakedToken).approve(address(pancakeSwapV2Router), tokenAmount);
		
		pancakeSwapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
			tokenAmount,
			0,
			path,
			userAddress,
			block.timestamp
		);
	}
	
    function SetMinStakeAmount(uint256 minStakeAmount) external onlyOwner {
        minStake = minStakeAmount;
    }	
}