/**
 *Submitted for verification at BscScan.com on 2021-09-11
*/

pragma solidity ^0.5.10;


interface IBEP20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

}

contract Ownable   {
    address public _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**

     * @dev Initializes the contract setting the deployer as the initial owner.

     */

    constructor() internal {
        _owner = msg.sender;

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
        require(_owner == msg.sender, "Ownable: caller is not the owner");

        _;
    }

    /**

     * @dev Transfers ownership of the contract to a new account (`newOwner`).

     * Can only be called by the current owner.

     */

    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;
    }
}

contract SMSstaking is Ownable{
    using SafeMath for uint256;
    IBEP20 public SMS;

    struct userInfo {
        uint256 DepositeToken;
        uint256 lastUpdated;
        uint256 lockableDays;
        uint256 WithdrawReward;
        uint256 WithdrawAbleReward;
        uint256 totalreward;
        uint256 depositeTime;
        address upline;
        uint256 referrals;
        uint256 rewarddays;
        uint256 upline_Reward;
        uint256 withrawableDepositeAmount;
        uint256 Upline_Earned;
    }
        struct UserInfo {
        uint256 lastUpdated;
        uint256 lockableDays;
        uint256 WithdrawReward;
        uint256 WithdrawAbleReward;
        uint256 totalreward;
        uint256 depositeTime;
        uint256 rewarddays;
        uint256 withrawableDepositeAmount;
        uint256 withoutlockingamount;
        uint256 Upline_Earned;
    }
    
    mapping(uint256 => uint256) public allocation;
    mapping(address => mapping(uint256 => userInfo)) private users;
    mapping(address => mapping(uint256 => UserInfo)) private withoutlocking;
    mapping(address =>  userInfo) public Users;
    mapping(address =>  UserInfo) public UsersWithoutlocking;
    uint256 minimumDeposit = 100E18;
    uint256 Depositwithoutlocking = 200E18;
    uint256 public TimeToGetReward = 1 days;
    uint256 public OwnerFee;
    uint256 public total_users = 1;

    uint256 public Total_Stake_SMS;
    uint256 public Total_Upline_Earned;
    uint256 [] deposit;
    uint256 private id = 0;

    constructor(IBEP20 _SMS) public {
        SMS = _SMS;
        allocation[15] = 30;
        allocation[30] = 36;
        allocation[60] = 48;
        allocation[120] = 60;
        allocation[240] = 72;
        allocation[365] = 96;
        allocation[0] = 24;
    }
     event Deposite_(address indexed upline, uint256 amount, uint256 day,uint256 time);
     event Deposite_Without_Locking( uint256 amount, uint256 day,uint256 time);
     event Reward( uint256 reward, uint256 WithdrawAbleReward,uint256 WithdrawReward);
     event Withdraw_Reward(address  user, uint256 amount,uint256 time);
     event Withdraw_Staking(address  user, uint256 amount,uint256 time,uint256 owerfee);




    function _setUpline(address _addr, address  _upline) private {
        if(Users[_addr].upline == address(0) && _upline != _addr && _addr != _owner && (Users[_upline].depositeTime > 0 || _upline == _owner)) {
            Users[_addr].upline = _upline;
            Users[_upline].referrals++;
            total_users++;
        }
    }

      function _chakUpline( address _upline) public view returns(bool){
        if(Users[msg.sender].upline == address(0) && _upline != msg.sender && msg.sender != _owner && (Users[_upline].depositeTime > 0 || _upline == _owner)) {

            return true;  

        }
    }
    
    

    function Deposite(uint256 _amount, uint256 _lockableDays,address _upline) public 
    {
        _setUpline(msg.sender,_upline);
        userInfo storage user = users[msg.sender][id];
        
        require(_amount >= minimumDeposit, "Invalid amount");
        require(allocation[_lockableDays] > 0, "Invalid day selection");
        
         if(total_users >= 2){
            uint256 referralone = _amount*5/100;
        Users[_upline].upline_Reward += referralone;
        Total_Upline_Earned += referralone;
        }
        address  upline2 = Users[_upline].upline;
        uint256 referraltwo = _amount*25/1000;
        if(total_users >= 3){
        Users[upline2].upline_Reward += referraltwo;
        Total_Upline_Earned += referraltwo;
        }
        address  upline3 = Users[upline2].upline;
        uint256 referralthree = _amount*5/1000;
        if(total_users >= 4){
        Users[upline3].upline_Reward += referralthree;
        Total_Upline_Earned += referralthree;
        }
        
        SMS.transferFrom(msg.sender,address(this), _amount);
        user.DepositeToken = _amount;
        user.lastUpdated = uint40(block.timestamp)+ TimeToGetReward;
        user.depositeTime = uint40(block.timestamp);
        Users[msg.sender].depositeTime = uint40(block.timestamp);
        Users[msg.sender].DepositeToken += _amount;
        user.lockableDays = _lockableDays;
        Total_Stake_SMS += _amount;
        deposit.push(id);
        id++;
        
        emit Deposite_(_upline,_amount,_lockableDays,uint40(block.timestamp));
        
    }
    
    function Deposite_WithoutLocking(uint256 _amount) public 
    {
        UserInfo storage user = withoutlocking[msg.sender][id];
        require(_amount >= Depositwithoutlocking, "Invalid amount");

        SMS.transferFrom(msg.sender, address(this), _amount);
        user.lastUpdated = uint40(block.timestamp)+ TimeToGetReward;
        user.depositeTime = uint40(block.timestamp);
        user.lockableDays = 0;
        user.withoutlockingamount = _amount;
        user.withrawableDepositeAmount = _amount;
        UsersWithoutlocking[msg.sender].withoutlockingamount +=_amount;
        Total_Stake_SMS += _amount;
        deposit.push(id);
        id++;
        emit Deposite_Without_Locking(_amount,0,uint40(block.timestamp));
    }


    function Rewards() private returns(uint256)
    {
        for(uint256 z=0 ; z< deposit.length;z++){
        userInfo storage user = users[msg.sender][z];
        require( Users[msg.sender].DepositeToken > 0, " Deposite not ");
        uint256 daysreward;
        uint256 perday = ((allocation[user.lockableDays].mul(1E18))).div(365);
        uint256 testTime = uint40(block.timestamp.sub(user.depositeTime));
        uint256 lockTime = user.depositeTime+(user.lockableDays*60);
        if(now > lockTime && user.lockableDays > 0 && user.DepositeToken > 0){
        daysreward = (user.lockableDays.mul(perday).div(100)).mul(user.DepositeToken).div(1E18);
        Users[msg.sender].totalreward += daysreward.sub(user.totalreward);
        user.totalreward += daysreward.sub(user.totalreward);
        Users[msg.sender].withrawableDepositeAmount += user.DepositeToken; 
        Users[msg.sender].WithdrawAbleReward = Users[msg.sender].totalreward.sub(Users[msg.sender].WithdrawReward);
        user.DepositeToken = 0;
        }
        else if (now > user.lastUpdated && user.DepositeToken > 0){
            user.rewarddays = uint256(testTime/ TimeToGetReward);
        daysreward = (user.rewarddays.mul(perday).div(100)).mul(user.DepositeToken).div(1E18);
        Users[msg.sender].totalreward += daysreward.sub(user.totalreward);
        user.totalreward += daysreward.sub(user.totalreward);
        user.lastUpdated += TimeToGetReward;
         Users[msg.sender].WithdrawAbleReward = Users[msg.sender].totalreward.sub(Users[msg.sender].WithdrawReward);
        }
        }
        return Users[msg.sender].WithdrawAbleReward;
    }
    
        function Check_Reward(address _add) public view returns(uint256 REWARD)
    {
        uint256 Rewarddays;
        for(uint256 z=0 ; z< deposit.length;z++){
        userInfo storage user = users[_add][z];
        require( Users[_add].DepositeToken > 0, " Deposite not ");
        uint256 daysreward;
        uint256 perday = ((allocation[user.lockableDays].mul(1E18))).div(365);
        uint256 testTime = uint40(block.timestamp.sub(user.depositeTime));
        uint256 lockTime = user.depositeTime+(user.lockableDays*60);
        if(now > lockTime && user.lockableDays > 0 && user.DepositeToken > 0){
        daysreward = (user.lockableDays.mul(perday).div(100)).mul(user.DepositeToken).div(1E18);
        REWARD += daysreward;
        
        }
        else if (now > user.lastUpdated && user.DepositeToken > 0){
            Rewarddays = uint256(testTime/ TimeToGetReward);
        daysreward = (Rewarddays.mul(perday).div(100)).mul(user.DepositeToken).div(1E18);
        REWARD += daysreward;
        }
        }
        return REWARD;
    }
    
        function Reward_without_locking() private returns(uint256)
    {
        for(uint256 x=0 ; x < deposit.length;x++){
        UserInfo storage user = withoutlocking[msg.sender][x];
        uint256 daysreward;
        uint256 perday = ((allocation[0].mul(1E18))).div(365);
        uint256 testTime = uint40(block.timestamp.sub(user.depositeTime));

         if (now > user.lastUpdated &&  user.withoutlockingamount > 0 && user.depositeTime != 0){
            user.rewarddays = uint256(testTime.div(TimeToGetReward));
        daysreward = (user.rewarddays.mul(perday).div(100)).mul(user.withoutlockingamount).div(1E18);
        UsersWithoutlocking[msg.sender].totalreward += daysreward.sub(user.totalreward);
        user.totalreward += daysreward.sub(user.totalreward);
        user.lastUpdated += TimeToGetReward;
         UsersWithoutlocking[msg.sender].WithdrawAbleReward = UsersWithoutlocking[msg.sender].totalreward.sub(UsersWithoutlocking[msg.sender].WithdrawReward);
        }
        }
        return UsersWithoutlocking[msg.sender].WithdrawAbleReward;
    }
    
    
    
            function Reward_(address _add) public view returns(uint256)
    {
        uint256 REWARD ;
        uint256 Rewarddays ;
        for(uint256 x=0 ; x < deposit.length;x++){
        UserInfo storage user = withoutlocking[_add][x];
        
        uint256 daysreward;
        uint256 perday = ((allocation[0].mul(1E18))).div(365);
        uint256 testTime = uint40(block.timestamp.sub(user.depositeTime));

         if (  user.withoutlockingamount > 0){
            Rewarddays = uint256(testTime.div(TimeToGetReward));
        daysreward = (Rewarddays.mul(perday).div(100)).mul(user.withoutlockingamount).div(1E18);
        REWARD += daysreward;
         }
        }
        return REWARD.sub(UsersWithoutlocking[_add].WithdrawReward);
    }
    
    
    

    function check_reward(uint256 _days,uint256 _amount) public view returns(uint256){
        uint256 perday = ((allocation[_days].mul(1E18))).div(365);
        uint256 _reward = (_days.mul(perday).div(100)).mul(_amount).div(1E18);
        return _reward;
    }

    function WithdrawReward() public {
        userInfo storage user = Users[msg.sender];
            Rewards();
            require(user.WithdrawAbleReward >= 0 , "reward not found" );
            SMS.transfer(msg.sender, user.WithdrawAbleReward);
             user.WithdrawReward =user.WithdrawReward.add(user.WithdrawAbleReward);
             user.WithdrawAbleReward = 0;
             emit Withdraw_Reward(msg.sender,user.WithdrawAbleReward,uint40(block.timestamp));
    }

    function WithdrawReward_withlocking() public {
        UserInfo storage user = UsersWithoutlocking[msg.sender];
        
             Reward_without_locking();
             require(user.WithdrawAbleReward >=  0 , "reward not found" );
             SMS.transfer(msg.sender, user.WithdrawAbleReward);
             user.WithdrawReward =user.WithdrawReward.add(user.WithdrawAbleReward);
             user.WithdrawAbleReward = 0;
             emit Withdraw_Reward(msg.sender,user.WithdrawAbleReward,uint40(block.timestamp));
    }    
    
    
     function Withdraw_Staking_Amount() public {
         
        userInfo storage user = Users[msg.sender];
        require(OwnerFee > 0 , "Set OwnerFee" );
        require(Users[msg.sender].withrawableDepositeAmount > 0 , "No deposite Balance found" );
        require(user.WithdrawAbleReward  == 0 , "Withdraw your Reward first" );
        uint256 ownerfee = (OwnerFee*Users[msg.sender].withrawableDepositeAmount/100).div(1E18);
        uint256 withdrawableAmount = user.DepositeToken.sub(ownerfee);
        SMS.transfer(msg.sender,withdrawableAmount);
        Users[msg.sender].DepositeToken=Users[msg.sender].DepositeToken.sub(Users[msg.sender].withrawableDepositeAmount);
        Users[msg.sender].withrawableDepositeAmount = 0;
        emit Withdraw_Staking(msg.sender,withdrawableAmount,uint40(block.timestamp),ownerfee);
     }

        function Withdraw_without_Staking_Amount() public {
         
        UserInfo storage user = UsersWithoutlocking[msg.sender];
        require(OwnerFee > 0 , "Set OwnerFee" );
        require(UsersWithoutlocking[msg.sender].withoutlockingamount > 0 , "No deposite Balance found" );
        require(user.WithdrawAbleReward  == 0 , "Withdraw your Reward first" );
        uint256 ownerfee = (OwnerFee*UsersWithoutlocking[msg.sender].withoutlockingamount/100).div(1E18);
        uint256 withdrawableAmount = UsersWithoutlocking[msg.sender].withoutlockingamount.sub(ownerfee);
        SMS.transfer(msg.sender,withdrawableAmount);
        UsersWithoutlocking[msg.sender].withoutlockingamount = 0;
        UsersWithoutlocking[msg.sender].WithdrawReward = 0;
        UsersWithoutlocking[msg.sender].totalreward = 0;
        removeamount();
        emit Withdraw_Staking(msg.sender,withdrawableAmount,uint40(block.timestamp),ownerfee);
    }
    
    
            function removeamount() private 
    {
        for(uint256 x=0 ; x < deposit.length;x++){
        UserInfo storage user = withoutlocking[msg.sender][x];
         user.withoutlockingamount=0;
         user.lastUpdated = 0;
         user.depositeTime=0;
         user.rewarddays = 0;
         
        }
    }
    
        function withdraw_upline_amount() public  {
            require(Users[msg.sender].upline_Reward > 0 , "balance not found");
         SMS.transfer(msg.sender, Users[msg.sender].upline_Reward);
          Users[msg.sender].Upline_Earned += Users[msg.sender].upline_Reward ;
          Users[msg.sender].upline_Reward = 0;
    }
   
 
     // EMERGENCY ONLY onlyOwner.
    function SetOwnerfee(uint256 _amount) public onlyOwner{
        OwnerFee = _amount;
    }
    function emergencyWithdraw(uint256 SMSAmount) public onlyOwner {
         SMS.transfer(msg.sender, SMSAmount);
    }
    function emergencyWithdrawBNB(uint256 Amount) public onlyOwner {
         msg.sender.transfer(Amount);
    }
    function check_Balance() public view returns(uint256){
        return address(this).balance;
    }
    
}