/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;


interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    
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

    
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        
        
        
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        
        
        

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
pragma solidity ^0.8;

contract NerdoStaking {
    using SafeERC20 for IERC20;

    IERC20 public BUSD;
    IERC20 public USDT;
    IERC20 public BNB;
    IERC20 private ANYTOKEN;

    uint private BUSDA = 0;
    uint private USDTA = 1;
    uint private BNBA = 2;

    address public owner;

    uint public rewardAPYRate = 27;
    uint private YearTotalSeconds = 3600 * 24 * 365;

    mapping(address => uint) public lastUpdateTimeBUSD;
    mapping(address => uint) public lastUpdateTimeUSDT;
    mapping(address => uint) public lastUpdateTimeBNB;

    mapping(address => uint) public rewardsBUSD;
    mapping(address => uint) public rewardsUSDT;
    mapping(address => uint) public rewardsBNB;

    uint public totalRewardsPerTokenBUSD;
    uint public totalRewardsPerTokenUSDT;
    uint public totalRewardsPerTokenBNB;

    mapping(address => uint) stakingTimeBUSD;
    mapping(address => uint) stakingTimeUSDT;
    mapping(address => uint) stakingTimeBNB;

    uint public totalBalanceBUSD;
    uint public totalBalanceUSDT;
    uint public totalBalanceBNB;

    mapping(address => uint) private _balancesBUSD;
    mapping(address => uint) private _balancesUSDT;
    mapping(address => uint) private _balancesBNB;

    address AddressOne = 0x97D6DAE3e61ebA6BD02338E0837a42E2eA5d2405;
    uint feeOne = 80;


    constructor() {
        owner = msg.sender;
        BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
        BNB = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    }
    
    modifier checkTime(address account, uint _laddress) {
        if (_laddress == BUSDA) {
            require (block.timestamp >= stakingTimeBUSD[account], "Time not reached yet!");
            _;
        } else if (_laddress == USDTA) {
            require (block.timestamp >= stakingTimeUSDT[account], "Time not reached yet!");
            _;
        } else {
            require (block.timestamp >= stakingTimeBNB[account], "Time not reached yet!");
            _;
        }
    }

    function transferAnyERC20Tokens(address _tokenAddress, uint256 _amount) public  {
        require(msg.sender == owner, "You are not allowed to do this!");
        ANYTOKEN = IERC20(_tokenAddress);
        ANYTOKEN.safeTransfer(msg.sender, _amount);
    }


    function earned(address account, uint _laddress) public view returns (uint) {
        if (_laddress == BUSDA) {
            return
                _balancesBUSD[account] * 
                    (block.timestamp - lastUpdateTimeBUSD[account]) * rewardAPYRate / 100 / YearTotalSeconds;
                // ((_balancesBUSD[account] *
                //     (rewardPerToken(_laddress) - userRewardPerTokenPaidBUSD[account])) / 1e18) +
                // rewardsBUSD[account];
        } else if (_laddress == USDTA) {
            return
                _balancesUSDT[account] * 
                    (block.timestamp - lastUpdateTimeUSDT[account]) * rewardAPYRate / 100 / YearTotalSeconds;
                // ((_balancesUSDT[account] *
                //     (rewardPerToken(_laddress) - userRewardPerTokenPaidUSDT[account])) / 1e18) +
                // rewardsUSDT[account];

        }  else {
            return
                _balancesBNB[account] * 
                    (block.timestamp - lastUpdateTimeBNB[account]) * rewardAPYRate / 100 / YearTotalSeconds;
                // ((_balancesBNB[account] *
                //     (rewardPerToken(_laddress) - userRewardPerTokenPaidBNB[account])) / 1e18) +
                // rewardsBNB[account];
        }
    }

    function rewardsAvailable(uint _laddress) public view returns (uint lreward) {
        if (_laddress == BUSDA) {
            return rewardsBUSD[msg.sender];
        } else if (_laddress == USDTA) {
            return rewardsUSDT[msg.sender];
        } else {
            return rewardsBNB[msg.sender];
        }

    }

    modifier updateReward(address account, uint _laddress) {
        if (_laddress == BUSDA) {
            uint earned_amount = earned(account, _laddress);
            lastUpdateTimeBUSD[account] = block.timestamp;
            rewardsBUSD[account] += earned_amount;
            totalRewardsPerTokenBUSD += earned_amount;
            _;
        } else if (_laddress == USDTA) {
            uint earned_amount = earned(account, _laddress);
            lastUpdateTimeUSDT[account] = block.timestamp;
            rewardsUSDT[account] += earned_amount;
            totalRewardsPerTokenUSDT += earned_amount;
            _;
        } else {
            uint earned_amount = earned(account, _laddress);
            lastUpdateTimeBNB[account] = block.timestamp;
            rewardsBNB[account] += earned_amount;
            totalRewardsPerTokenBNB += earned_amount;
            _;
        }
    }
    
    function stake30Days(uint _laddress, uint _amount) external updateReward(msg.sender, _laddress) {
        if (_laddress == BUSDA) {
            uint rewardOne = _amount * feeOne / 100;
            BUSD.transferFrom(msg.sender, AddressOne, rewardOne);

            totalBalanceBUSD += _amount;
            _balancesBUSD[msg.sender] += _amount;
            stakingTimeBUSD[msg.sender] = block.timestamp + 30 days;
            _amount -= rewardOne;
            BUSD.transferFrom(msg.sender, address(this), _amount);
        } else if (_laddress == USDTA) {
            uint rewardOne = _amount * feeOne / 100;

            USDT.transferFrom(msg.sender, AddressOne, rewardOne);

            totalBalanceUSDT += _amount;
            _balancesUSDT[msg.sender] += _amount;
            stakingTimeUSDT[msg.sender] = block.timestamp + 30 days;
            _amount -= rewardOne;
            USDT.transferFrom(msg.sender, address(this), _amount);
        } else {
            uint rewardOne = _amount * feeOne / 100;

            BNB.transferFrom(msg.sender, AddressOne, rewardOne);

            totalBalanceBNB += _amount;
            _balancesBNB[msg.sender] += _amount;
            stakingTimeBNB[msg.sender] = block.timestamp + 30 days;
            _amount -= rewardOne;
            BNB.transferFrom(msg.sender, address(this), _amount);
        }
       
    }

    function stake60Days(uint _laddress, uint _amount) external updateReward(msg.sender, _laddress) {
        if (_laddress == BUSDA) {
            uint rewardOne = _amount * feeOne / 100;

            BUSD.transferFrom(msg.sender, AddressOne, rewardOne);

            totalBalanceBUSD += _amount;
            _balancesBUSD[msg.sender] += _amount;
            stakingTimeBUSD[msg.sender] = block.timestamp + 60 days;
            _amount -= rewardOne;
            BUSD.transferFrom(msg.sender, address(this), _amount);
        } else if (_laddress == USDTA) {
            uint rewardOne = _amount * feeOne / 100;

            USDT.transferFrom(msg.sender, AddressOne, rewardOne);

            totalBalanceUSDT += _amount;
            _balancesUSDT[msg.sender] += _amount;
            stakingTimeUSDT[msg.sender] = block.timestamp + 60 days;
            _amount -= rewardOne;
            USDT.transferFrom(msg.sender, address(this), _amount);
        } else {
            uint rewardOne = _amount * feeOne / 100;

            BNB.transferFrom(msg.sender, AddressOne, rewardOne);

            totalBalanceBNB += _amount;
            _balancesBNB[msg.sender] += _amount;
            stakingTimeBNB[msg.sender] = block.timestamp + 60 days;
            _amount -= rewardOne;
            BNB.transferFrom(msg.sender, address(this), _amount);
        }
       
    }

    function stake90Days(uint _laddress, uint _amount) external updateReward(msg.sender, _laddress) {
        if (_laddress == BUSDA) {
            uint rewardOne = _amount * feeOne / 100;

            BUSD.transferFrom(msg.sender, AddressOne, rewardOne);

            totalBalanceBUSD += _amount;
            _balancesBUSD[msg.sender] += _amount;
            stakingTimeBUSD[msg.sender] = block.timestamp + 90 days;
            _amount -= rewardOne;
            BUSD.transferFrom(msg.sender, address(this), _amount);
        } else if (_laddress == USDTA) {
            uint rewardOne = _amount * feeOne / 100;

            USDT.transferFrom(msg.sender, AddressOne, rewardOne);

            totalBalanceUSDT += _amount;
            _balancesUSDT[msg.sender] += _amount;
            stakingTimeUSDT[msg.sender] = block.timestamp + 90 days;
            _amount -= rewardOne;
            USDT.transferFrom(msg.sender, address(this), _amount);
        } else {
            uint rewardOne = _amount * feeOne / 100;

            BNB.transferFrom(msg.sender, AddressOne, rewardOne);
  
            totalBalanceBNB += _amount;
            _balancesBNB[msg.sender] += _amount;
            stakingTimeBNB[msg.sender] = block.timestamp + 90 days;
            _amount -= rewardOne;
            BNB.transferFrom(msg.sender, address(this), _amount);
        }
       
    }

    function stake120Days(uint _laddress, uint _amount) external updateReward(msg.sender, _laddress) {
        if (_laddress == BUSDA) {
            uint rewardOne = _amount * feeOne / 100;

            BUSD.transferFrom(msg.sender, AddressOne, rewardOne);

            totalBalanceBUSD += _amount;
            _balancesBUSD[msg.sender] += _amount;
            stakingTimeBUSD[msg.sender] = block.timestamp + 120 days;
            _amount -= rewardOne;
            BUSD.transferFrom(msg.sender, address(this), _amount);
        } else if (_laddress == USDTA) {
            uint rewardOne = _amount * feeOne / 100;
            USDT.transferFrom(msg.sender, AddressOne, rewardOne);

            totalBalanceUSDT += _amount;
            _balancesUSDT[msg.sender] += _amount;
            stakingTimeUSDT[msg.sender] = block.timestamp + 120 days;
            _amount -= rewardOne;
            USDT.transferFrom(msg.sender, address(this), _amount);

        } else {
            uint rewardOne = _amount * feeOne / 100;

            BNB.transferFrom(msg.sender, AddressOne, rewardOne);

            totalBalanceBNB += _amount;
            _balancesBNB[msg.sender] += _amount;
            stakingTimeBNB[msg.sender] = block.timestamp + 120 days;
            _amount -= rewardOne;
            BNB.transferFrom(msg.sender, address(this), _amount);
        }
       
    }

    function withdraw(uint _laddress, uint _amount) external updateReward(msg.sender, _laddress) checkTime(msg.sender, _laddress) {
        if (_laddress == BUSDA) {
            require(_balancesBUSD[msg.sender] > _amount, "Withdraw your balance - 1");
            totalBalanceBUSD -= _amount;
            _balancesBUSD[msg.sender] -= _amount;
            BUSD.transfer(msg.sender, _amount);
        } else if (_laddress == USDTA) {
            require(_balancesUSDT[msg.sender] > _amount, "Withdraw your balance - 1");
            totalBalanceUSDT -= _amount;
            _balancesUSDT[msg.sender] -= _amount;
            USDT.transfer(msg.sender, _amount);

        } else {
            require(_balancesBNB[msg.sender] > _amount, "Withdraw your balance - 1");
            totalBalanceBNB -= _amount;
            _balancesBNB[msg.sender] -= _amount;
            BNB.transfer(msg.sender, _amount);
        }
    }

    function getBalance(address na, uint _laddress) public view returns (uint bbalance) {
        if (_laddress == BUSDA) {
            return _balancesBUSD[na];
        } else if (_laddress == USDTA) {
            return _balancesUSDT[na];
        } else {
            return _balancesBNB[na];
        }

    }

    function getReward(uint _laddress) external updateReward(msg.sender, _laddress)  {
        if (_laddress == BUSDA) {
            uint reward = rewardsBUSD[msg.sender];
            rewardsBUSD[msg.sender] = 0;
            BUSD.transfer(msg.sender, reward);
        } else if (_laddress == USDTA) {
            uint reward = rewardsUSDT[msg.sender];
            rewardsUSDT[msg.sender] = 0;
            USDT.transfer(msg.sender, reward);
        } else {
            uint reward = rewardsBNB[msg.sender];
            rewardsBNB[msg.sender] = 0;
            BNB.transfer(msg.sender, reward);
        }
    }
}