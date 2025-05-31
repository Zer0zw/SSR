/**
 *Submitted for verification at BscScan.com on 2022-01-06
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


contract Ownable  {
    address payable public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        _owner = payable(msg.sender);
        emit OwnershipTransferred(address(0), msg.sender);
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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address payable newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface Token {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
    function decimals() external view returns(uint256);

}


contract PEDACOIN_StakePool_2 is Ownable{
    
    using SafeMath for uint;

    struct User {
        uint256 poolBal;
        uint40 pool_deposit_time;
        uint256 total_deposits;
        uint256 pool_payouts;
        uint256 rewardEarned;
        uint256 rewardUnWithdrawed;
    }
    
    address public tokenAddr;
    uint256 public Pool = 50000000;
    uint256 public PoolBalance;
    uint256 public tokenDecimal;
    uint256 public poolMinStake = 2500;
    uint256 public poolMaxStake = 200000;

    uint256 public poolNumber = 2;
    uint256 public poolRewardPercent = 17;
    uint256 public fullMaturityTime = 360 days; 
    uint256 public totaldays = 360;

   

    mapping(address => User) public users;

    event TokenTransfer(address beneficiary, uint amount);
    event PoolTransfer(address beneficiary, uint amount);
    event RewardClaimed(address beneficiary, uint amount);
    
    mapping (address => uint256) public balances;


    constructor(address _tokenAddr) {
        tokenAddr = _tokenAddr;
        tokenDecimal = Token(tokenAddr).decimals();
    }
    
    /* Recieve Accidental BNB Transfers */
    receive() payable external {
        _owner.transfer(msg.value);
        balances[msg.sender] = balances[msg.sender].add(msg.value);
    }


    /* Stake Token Function */
    function PoolStake(uint256  _amount) public returns (bool) {
        
        require(_amount <= Token(tokenAddr).balanceOf(msg.sender),"Token Balance of user is less");
        require(_amount >= poolMinStake * (10**tokenDecimal),"Token lower than minimum limit");
        require(_amount <= poolMaxStake * (10**tokenDecimal),"Token higher than maximum limit");
        require(Token(tokenAddr).transferFrom(msg.sender,address(this), _amount),"BEP20: Amount Transfer Failed Check id Amount is Approved");
        PoolBalance += _amount;
        require(PoolBalance <= Pool * (10**tokenDecimal),"Pool is Full, Enter Amount Equal to Pool Holding or remaining pool balance");
        require(users[msg.sender].poolBal == 0,"Already Staked");
        users[msg.sender].poolBal = _amount;
        users[msg.sender].total_deposits += _amount;
        users[msg.sender].pool_deposit_time = uint40(block.timestamp);
        uint256 stakeRewards = (((_amount*poolRewardPercent)/100)/360)*totaldays;
        users[msg.sender].rewardUnWithdrawed = stakeRewards; 
        emit PoolTransfer(msg.sender, _amount);
        return true;
    }
    
    /* Claims Principal Token and Rewards Collected */
    function claimPool() public returns(bool){
        require(users[msg.sender].poolBal > 0,"There is no deposit for this address in Pool");
        require(block.timestamp > users[msg.sender].pool_deposit_time + fullMaturityTime,"Cannot Withdraw Before full Maturity");


        uint256 amount = users[msg.sender].poolBal;
        uint256 reward = users[msg.sender].rewardUnWithdrawed;
        
        users[msg.sender].rewardUnWithdrawed = 0;
        users[msg.sender].poolBal = 0;
        users[msg.sender].pool_deposit_time = 0;
        users[msg.sender].pool_payouts += amount;

        require(Token(tokenAddr).transfer(msg.sender, amount),"Cannot Transfer Principal Funds");
        require(Token(tokenAddr).transfer(msg.sender, reward),"Cannot Transfer Reward Funds");
        users[msg.sender].rewardEarned += reward;
        emit RewardClaimed(msg.sender, reward);
        
        
        
        emit TokenTransfer(msg.sender, amount);
        return true;

            
    }

    
    /* Check Token Balance inside Contract */
    function tokenBalance() public view returns (uint256){
        return Token(tokenAddr).balanceOf(address(this));
    }

    /* Check BSC Balance inside Contract */
    function bnbBalance() public view returns (uint256){
        return address(this).balance;
    }

    function retrieveBnbStuck(address payable wallet) public onlyOwner() returns(bool){
        wallet.transfer(address(this).balance);
        return true;
    }

    function retrieveBEP20TokenStuck(address _tokenAddr,uint256 amount,address toWallet) public onlyOwner() returns(bool){
        Token(_tokenAddr).transfer(toWallet, amount);
        return true;
    }


    /* Calculate Remaining Staking Claim time of Users */
    function stakeTimeRemaining(address _userAdd) public view returns (uint256){
        if(users[_userAdd].pool_deposit_time > 0){
            uint256 stakeTime = users[_userAdd].pool_deposit_time + fullMaturityTime;
            if(stakeTime > block.timestamp){
                return (stakeTime - block.timestamp);
            }else{
                return 0;
            }
        }else{
            return 0;
        }
    }
    

    /* Admin function to update the Pool Total Stake Capacity */
    function updatePoolCapacity(uint256 PoolAmount) public onlyOwner() returns(bool){
        Pool = PoolAmount;
        return true;
    }
    
    /* Admin function to update the pool Min Stake */
    function updatePoolMinStake(uint256 amount) public onlyOwner() returns(bool){
        poolMinStake = amount;
        return true;
    }
    
    /* Maturity Date */
    function maturityDate(address userAdd) public view returns(uint256){
        return (users[userAdd].pool_deposit_time + fullMaturityTime);
    }
    


}