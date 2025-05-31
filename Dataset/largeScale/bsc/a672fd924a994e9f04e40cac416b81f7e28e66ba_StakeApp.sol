/**
 *Submitted for verification at BscScan.com on 2022-10-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
      return _owner;
    }

    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }

    function renounceOwnership() public onlyOwner {
      emit OwnershipTransferred(_owner, address(0));
      _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}

interface IERC20 
{
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function mint(address _toAddress, uint256 _amount) external;
    function burnFrom(address _fromAddress, uint256 _amount) external;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract ReentrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

contract StakeApp is Ownable , ReentrancyGuard {
    using SafeMath for uint256;
    uint256 public constant min = 50 ether; //50 BUSD
    uint256 public roi = 2500; //2.5%
    uint256 public constant claimCycleDays = 7; //7 days 
    uint256 public constant deposit_admin_fee = 2;
    uint256 public constant deposit_tvl_fee = 1;
    uint256 public constant withdraw_dev_fee = 2;
    uint256 public constant withdraw_tvl_fee = 1;
    uint256 public constant max_rewards = 3; //3x
    uint256 public ref_fee = 5;
    uint256 public tradeAmountWithdrawTime; //Admin can divert 30% of the pooled fund outside of the contract to make investments.
    uint256 public injectedFunds; //Admin can send money into the smart contract from the admin end

    address public admin = 0xFb190411CA1129FFfb2662F9Ed0768f3Eee32Ea6;
    address public BUSDaddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //BSC Testnet
    address public rpTokenAddress = 0xdf5Cd16D627251aDEdC333aeA3889C7f3F5B9e15; //BSC Testnet

    bool public init = false;

    IERC20 busd = IERC20(BUSDaddress);
    IERC20 rpToken = IERC20(rpTokenAddress);

    struct referral_system {
        address ref_address;
        uint256 reward;
    }

    struct referral_withdraw {
        address ref_address;
        uint256 totalWithdraw;
    }

    struct user_investment_details {
        address user_address;
        uint256 invested;
    }

    struct weeklyWithdraw {
        address user_address;
        uint256 startTime;
        uint256 deadline;
    }

    struct claimDaily {
        address user_address;
        uint256 startTime;
        uint256 deadline;
    }

    struct userWithdrawal {
        address user_address;
        uint256 amount;
    }

    struct userTotalWithdraw {
        address user_address;
        uint256 amount;
    }
     struct userTotalRewards {
        address user_address;
        uint256 amount;
    } 

    mapping(address => referral_system) public referral;
    mapping(address => user_investment_details) public investments;
    mapping(address => weeklyWithdraw) public weekly;
    mapping(address => claimDaily) public claimTime;
    mapping(address => userWithdrawal) public approvedWithdrawal;
    mapping(address => userTotalWithdraw) public totalWithdraw;
    mapping(address => userTotalRewards) public totalRewards; 
    mapping(address => referral_withdraw) public refTotalWithdraw;

    mapping(address => uint256) public userWithdrawCount;
    mapping(address => uint256) public userRedepositCount;
    mapping(address => uint256) public userRedepositAmount;

    // invest function 
    function deposit(address _ref, uint256 _amount) public noReentrant  {
        require(init, "Not Started Yet");
        require(_amount>=min, "Cannot Deposit");

        if(!isAlreadyInvested()) {
            uint256 ref_fee_add = refFee(_amount);
            if(_ref != address(0) && _ref != msg.sender) {
                uint256 ref_last_balance = referral[_ref].reward;
                uint256 totalRefFee = SafeMath.add(ref_fee_add,ref_last_balance);
                referral[_ref] = referral_system(_ref,totalRefFee);
            }

            // investment details
            uint256 userLastInvestment = investments[msg.sender].invested;
            uint256 userCurrentInvestment = _amount;
            uint256 totalInvestment = SafeMath.add(userLastInvestment,userCurrentInvestment);
            investments[msg.sender] = user_investment_details(msg.sender,totalInvestment);

            // weekly withdraw 
            uint256 weeklyStart = block.timestamp;
            uint256 deadline_weekly = block.timestamp + (claimCycleDays * 86400);

            weekly[msg.sender] = weeklyWithdraw(msg.sender,weeklyStart,deadline_weekly);

            // claim Setting
            uint256 claimTimeStart = block.timestamp;
            uint256 claimTimeEnd = block.timestamp + 1 days;

            claimTime[msg.sender] = claimDaily(msg.sender,claimTimeStart,claimTimeEnd);
                
            // fees 
            // uint256 total_fee = depositFee(_amount);
            uint256 deposit_admin_fee_amount = SafeMath.div(SafeMath.mul(_amount,deposit_admin_fee),100);
            busd.transferFrom(msg.sender, address(this), _amount);
            busd.transfer(admin, deposit_admin_fee_amount);

            rpToken.mint(msg.sender, _amount);
            
        } else {

            uint256 ref_fee_add = refFee(_amount);
            if(_ref != address(0) && _ref != msg.sender) {
                uint256 ref_last_balance = referral[_ref].reward;
                uint256 totalRefFee = SafeMath.add(ref_fee_add,ref_last_balance);   
                referral[_ref] = referral_system(_ref,totalRefFee);
            }

            // investment details
            uint256 userLastInvestment = investments[msg.sender].invested;
            uint256 userCurrentInvestment = _amount;
            uint256 totalInvestment = SafeMath.add(userLastInvestment,userCurrentInvestment);
            investments[msg.sender] = user_investment_details(msg.sender,totalInvestment);
        
            // fees 
            uint256 deposit_admin_fee_amount = SafeMath.div(SafeMath.mul(_amount,deposit_admin_fee),100);
            busd.transferFrom(msg.sender, address(this), _amount);
            busd.transfer(admin, deposit_admin_fee_amount);

            rpToken.mint(msg.sender, _amount);
        }
    }

    function redeemDeposit() public {
        require(init, "Not Started Yet");
        uint256 I_investment = investments[msg.sender].invested;
        uint256 t_withdraw = totalWithdraw[msg.sender].amount;

        require(I_investment > t_withdraw, "You already have withdrawn more than your investment");
        
        uint256 lastFee = depositFee(I_investment);
        uint256 currentBalance = SafeMath.sub(I_investment,lastFee);

        uint256 UnstakeValue = SafeMath.sub(currentBalance,t_withdraw);

        require(rpToken.allowance(msg.sender,address(this)) >= UnstakeValue, "Not enough allowance of RP tokens");
        require(rpToken.balanceOf(msg.sender) >= UnstakeValue, "Not enough balance of RP tokens");

        bool success = rpToken.transferFrom(msg.sender, address(this), UnstakeValue);
        require(success, "RP Tokens Transfer failed.");

        rpToken.approve(address(this), UnstakeValue);
        rpToken.burnFrom(address(this),UnstakeValue);

        busd.transfer(msg.sender,UnstakeValue);

        investments[msg.sender] = user_investment_details(msg.sender,0);

        approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender,0);

    } 

    function userReward(address _userAddress) public view returns(uint256) {
        uint256 userInvestment = investments[_userAddress].invested;
        uint256 userDailyReturn = DailyRoi(userInvestment);

        // invested time
        uint256 claimInvestTime = claimTime[_userAddress].startTime;
        uint256 claimInvestEnd = claimTime[_userAddress].deadline;

        uint256 totalTime = SafeMath.sub(claimInvestEnd,claimInvestTime);

        uint256 value = SafeMath.div(userDailyReturn,totalTime);

        uint256 nowTime = block.timestamp;

        if (claimInvestEnd>= nowTime) {
            uint256 earned = SafeMath.sub(nowTime,claimInvestTime);
            uint256 totalEarned = SafeMath.mul(earned, value);
            return totalEarned;
        } else {
            return userDailyReturn;
        }
        
    }

    function withdrawal(bool _isReinvest) public noReentrant {
        require(init, "Not Started Yet");    
        require(weekly[msg.sender].deadline <= block.timestamp, "You cant withdraw");
        require(totalRewards[msg.sender].amount <= SafeMath.mul(investments[msg.sender].invested, max_rewards), "You have calimed maximum rewards of your initial depostit - Reinvest using another wallet!");

        uint256 aval_withdraw = approvedWithdrawal[msg.sender].amount;
        uint256 aval_withdraw2 = SafeMath.div(aval_withdraw,2); // divide the fees
        uint256 wFee = withdrawFee(aval_withdraw2); // changed from aval_withdraw
        uint256 wDevfee = SafeMath.div(SafeMath.mul(aval_withdraw2,withdraw_dev_fee),100);
        uint256 totalAmountToWithdraw = SafeMath.sub(aval_withdraw2,wFee); // changed from aval_withdraw to aval_withdraw2
        
        approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender,aval_withdraw2);

        uint256 weeklyStart = block.timestamp;
        uint256 deadline_weekly = block.timestamp + (claimCycleDays * 86400);

        weekly[msg.sender] = weeklyWithdraw(msg.sender,weeklyStart,deadline_weekly);

        uint256 amount = totalWithdraw[msg.sender].amount;

        uint256 totalAmount = SafeMath.add(amount,aval_withdraw2);

        totalWithdraw[msg.sender] = userTotalWithdraw(msg.sender,totalAmount);
        
        userWithdrawCount[msg.sender]++;

        if(_isReinvest == true){
            deposit(admin, totalAmountToWithdraw);
        }else{
            busd.transfer(msg.sender, totalAmountToWithdraw);
            busd.transfer(admin, wDevfee);
        }
    }
   
    function claimDailyRewards() public noReentrant{
        require(init, "Not Started Yet");
        require(claimTime[msg.sender].deadline <= block.timestamp, "You cant claim");

        uint256 rewards = userReward(msg.sender);

        uint256 currentApproved = approvedWithdrawal[msg.sender].amount;

        uint256 value = SafeMath.add(rewards,currentApproved);

        approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender,value);
        uint256 amount = totalRewards[msg.sender].amount; //hhnew
        uint256 totalRewardAmount = SafeMath.add(amount,rewards); //hhnew
        totalRewards[msg.sender].amount=totalRewardAmount;

        uint256 claimTimeStart = block.timestamp;
        uint256 claimTimeEnd = block.timestamp + 1 days;

        claimTime[msg.sender] = claimDaily(msg.sender,claimTimeStart,claimTimeEnd);
    }

    function referralWithdraw() external noReentrant {
        require(init, "Not Started Yet");
        require(isAlreadyInvested(),"You do not have any active investments");
        
        uint256 value = referral[msg.sender].reward;
  
        referral[msg.sender] = referral_system(msg.sender,0);

        uint256 lastWithdraw = refTotalWithdraw[msg.sender].totalWithdraw;

        uint256 totalValue = SafeMath.add(value,lastWithdraw);

        refTotalWithdraw[msg.sender] = referral_withdraw(msg.sender,totalValue);

        busd.transfer(msg.sender, value);
    }

    // initialized the market
    function startStake() public onlyOwner {
        init = true;
    }

    // other functions
    function DailyRoi(uint256 _amount) public view returns(uint256) {
        return SafeMath.div(SafeMath.mul(_amount,roi),10000);
    }

    function isAlreadyInvested() public view returns(bool) {
        address _address= msg.sender;
        if(investments[_address].user_address==_address){
            return true;
        }
        else{
            return false;
        }
    }
 
    function depositFee(uint256 _amount) public pure returns(uint256){
        uint256 totalDepositFee = SafeMath.add(deposit_admin_fee,deposit_tvl_fee);
        return SafeMath.div(SafeMath.mul(_amount,totalDepositFee),100);
    }
    

    function refFee(uint256 _amount) public view returns(uint256) {
        return SafeMath.div(SafeMath.mul(_amount,ref_fee),100);
    }


    function withdrawFee(uint256 _amount) public pure returns(uint256) {
        uint256 totalWithdrawFee = SafeMath.add(withdraw_dev_fee,withdraw_tvl_fee);
        return SafeMath.div(SafeMath.mul(_amount,totalWithdrawFee),100);
    }
    

    function getBalance() public view returns(uint256){
        return busd.balanceOf(address(this));
    }

    function setRoi(uint256 _newRoi) public onlyOwner{
        roi = _newRoi;
    }

    function withdrawBUSDForTrading() public onlyOwner{
        uint256 lapsedDays = ((block.timestamp - tradeAmountWithdrawTime)/3600)/24; //3600 seconds per hour so: lapsed days = lapsed time * (3600seconds /24hrs)
        require(lapsedDays >= 24, "Tradable amount can be withdrwan only once per 24 hours");
        uint256 withdrableAmount =  SafeMath.div(SafeMath.mul(busd.balanceOf(address(this)),30),100);
        bool success = busd.transfer(msg.sender, withdrableAmount);
        require(success, "BUSD Transfer failed.");
        tradeAmountWithdrawTime = block.timestamp;
    }

    function injectFunds(uint256 _amount) public{
        require(busd.allowance(msg.sender,address(this)) >= _amount, "Not enough allowance of BUSD tokens");
        require(busd.balanceOf(msg.sender) >= _amount, "Not enough balance of BUSD tokens");

        bool success = busd.transferFrom(msg.sender, address(this), _amount);
        require(success, "BUSD Tokens Transfer failed.");

        injectedFunds += _amount;
    }

    function setAdminAddress(address _newAdmin) public onlyOwner{
        admin = _newAdmin;
    }
}