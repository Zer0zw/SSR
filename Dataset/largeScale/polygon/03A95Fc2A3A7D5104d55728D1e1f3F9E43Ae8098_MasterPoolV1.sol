/**
 *Submitted for verification at polygonscan.com on 2022-10-14
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function circularSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function faucet(address account,uint256 amount,uint256 price) external;
  function burnt(address account,uint256 amount,uint256 price) external;
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address internal owner;
    constructor(address _owner) { owner = _owner; }
    modifier onlyOwner() { require(isOwner(msg.sender), "!OWNER"); _; }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
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
        return c;
    }
    function sqrt(uint x) internal pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}

contract MasterPoolV1 is Ownable {
  using SafeMath for uint256;

  struct MasterPool {
    address deposittoken;
    address rewardtoken;
    uint256 apr;
    uint256 endblock;
    uint256 lockblock;
    bool active;
    uint256 minimum;
    uint256 maximum;
    uint256 totalstaked;
    uint256 remainreward;
    uint256 fixedcouta;
    uint256 maxblockreward;
    mapping(address => User) users;
  }

  struct Snapshot {
    uint256 balance;
    uint256 snapblock;
  }

  struct User {
    uint256 balance;
    uint256 harvest;
    uint256 locked;
    uint256 firststakedblock;
  }

  uint256 public totalpool;
  uint256 public ayear = 60*60*24*365;

  mapping(address => bool) public wasStaked;
  mapping(address => bool) public permission;
  mapping(uint256 => MasterPool) public masterpool;
  mapping(uint256 => Snapshot) public snapshot;
  
  bool reentrantcy;
  modifier noReentrant() {
    require(!reentrantcy);
    reentrantcy = true;
    _;
    reentrantcy = false;
  }

  modifier onlyPermission() { require(permission[msg.sender], "!PERMISSION"); _; }

  constructor() Ownable(msg.sender) {
    permission[msg.sender] = true;
  }

  function poolendin(uint256 _id) public view returns (uint256) {
    if(masterpool[_id].endblock>block.timestamp){
        return masterpool[_id].endblock.sub(block.timestamp);
    }else{
        return 0;
    }
  }

  function isPermission(address _account) public view returns (bool) {
    return permission[_account];
  }

  function viewUsers(uint256 _id,address _account) public view returns (
      uint256 balance_,
      uint256 harvest_,
      uint256 locked_,
      uint256 locked_sec_
    ) {
        uint256 human_sec = 0;
        if(masterpool[_id].users[_account].locked>block.timestamp){
            human_sec = masterpool[_id].users[_account].locked.sub(block.timestamp);
        }
    return (
        masterpool[_id].users[_account].balance,
        masterpool[_id].users[_account].harvest,
        masterpool[_id].users[_account].locked,
        human_sec
    );
  }

  function pausePool(uint256 _id) public onlyPermission returns (bool) {
    masterpool[_id].active = false;
    return true;
  }

  function resumePool(uint256 _id) public onlyPermission returns (bool) {
    masterpool[_id].active = true;
    return true;
  }

  function flagePermission(address _account,bool _flag) public onlyOwner returns (bool) {
    permission[_account] = _flag;
    return true;
  }

  function createNewPool(address _dtoken,address _rtoken,uint256 _apr,uint256 _endtimer,uint256 _lockblock,uint256 _minimum,uint256 _maximum,uint256 _fixedcouta,uint256 _maxreward) public onlyPermission returns (bool) {
    uint256 endblock = block.timestamp.add(_endtimer);
    totalpool = totalpool.add(1);
    masterpool[totalpool].deposittoken = _dtoken;
    masterpool[totalpool].rewardtoken = _rtoken;
    masterpool[totalpool].apr = _apr;
    masterpool[totalpool].endblock = endblock;
    masterpool[totalpool].lockblock = _lockblock;
    masterpool[totalpool].active = false;
    masterpool[totalpool].minimum = _minimum;
    masterpool[totalpool].maximum = _maximum;
    masterpool[totalpool].fixedcouta = _fixedcouta;
    masterpool[totalpool].maxblockreward = _maxreward;
    return true;
  }

  function settingPool(uint256 _id,address _dtoken,address _rtoken,uint256 _apr,uint256 _endtimer,uint256 _lockblock,uint256 _minimum,uint256 _maximum,uint256 _fixedcouta,uint256 _maxreward) public onlyPermission returns (bool) {
    uint256 endblock = block.timestamp.add(_endtimer);
    masterpool[_id].deposittoken = _dtoken;
    masterpool[totalpool].rewardtoken = _rtoken;
    masterpool[_id].apr = _apr;
    masterpool[_id].endblock = endblock;
    masterpool[_id].lockblock = _lockblock;
    masterpool[_id].minimum = _minimum;
    masterpool[_id].maximum = _maximum;
    masterpool[_id].fixedcouta = _fixedcouta;
    masterpool[_id].maxblockreward = _maxreward;
    return true;
  }

  function filledReward(uint256 _id,uint256 _amount) public returns (bool) {
    IERC20 token = IERC20(masterpool[_id].rewardtoken);
    token.transferFrom(msg.sender,address(this),_amount);
    uint256 remainreward = getupdatereward(_id);
    masterpool[_id].remainreward = remainreward.add(_amount);
    return true;
  }

  function revokepool(uint256 _id) public returns (bool) {
    uint256 remainreward = getupdatereward(_id);
    IERC20 token = IERC20(masterpool[_id].rewardtoken);
    token.transfer(msg.sender,remainreward);
    masterpool[_id].remainreward = 0;
    return true;
  }

  function deposit(uint256 _id,uint256 _amount) public returns (bool) {
    require(!wasStaked[msg.sender],"revert by wallet was staked!");
    require(masterpool[_id].active,"this pool maybe pause");
    require(availableCouta(_id)>=_amount.add(masterpool[_id].totalstaked),"not enought couta");
    require(_amount>=masterpool[_id].minimum,"revert amount by minimum vaule");
    if(masterpool[_id].maximum!=0){
      require(_amount<=masterpool[_id].maximum,"revert amount by maximum vaule");
    }
    IERC20 token = IERC20(masterpool[_id].deposittoken);
    token.transferFrom(msg.sender,address(this),_amount);
    harvest(_id,msg.sender);
    masterpool[_id].users[msg.sender].locked = tryincreaseblock(_id,_amount,msg.sender);
    masterpool[_id].totalstaked = masterpool[_id].totalstaked.add(_amount);
    masterpool[_id].users[msg.sender].balance = masterpool[_id].users[msg.sender].balance.add(_amount);
    uint256 remainreward = getupdatereward(_id);
    masterpool[_id].remainreward = remainreward;
    snapshot[_id].balance = masterpool[_id].totalstaked;
    snapshot[_id].snapblock = block.timestamp;
    masterpool[_id].users[msg.sender].firststakedblock = block.timestamp;
    wasStaked[msg.sender] = true;
    return true;
  }

  function withdraw(uint256 _id,uint256 _amount) public returns (bool) {
    if(shouldlocked(_id)){
      require(masterpool[_id].users[msg.sender].locked<=block.timestamp,"token is in locked period");
    }
    require(masterpool[_id].users[msg.sender].locked<=block.timestamp,"token is in locked period");
    require(masterpool[_id].users[msg.sender].balance>=_amount,"not enought balance for withdraw");
    if(_amount>masterpool[_id].users[msg.sender].balance){
      _amount = masterpool[_id].users[msg.sender].balance;
    }
    harvest(_id,msg.sender);
    IERC20 token = IERC20(masterpool[_id].deposittoken);
    token.transfer(msg.sender,_amount);
    masterpool[_id].totalstaked = masterpool[_id].totalstaked.sub(_amount);
    masterpool[_id].users[msg.sender].balance = masterpool[_id].users[msg.sender].balance.sub(_amount);
    uint256 remainreward = getupdatereward(_id);
    masterpool[_id].remainreward = remainreward;
    snapshot[_id].balance = masterpool[_id].totalstaked;
    snapshot[_id].snapblock = block.timestamp;
    if(masterpool[_id].users[msg.sender].balance==0){
      wasStaked[msg.sender] = false;
    }
    return true;
  }

  function availableCouta(uint256 _id) public view returns (uint256) {
    if(masterpool[_id].fixedcouta>0){
      return masterpool[_id].fixedcouta;
    }
    uint256 result = 0;
    if(masterpool[_id].endblock>block.timestamp){
        uint256 harvested = getHarvested(_id);
        uint256 remainreward = masterpool[_id].remainreward.sub(harvested);
        uint256 endperiod = masterpool[_id].endblock.sub(block.timestamp);
        uint256 maxreward = remainreward.mul(100).div(masterpool[_id].apr);
        result = maxreward.mul(ayear).div(endperiod);
    }
    return result;
  }

  function tryincreaseblock(uint256 _id,uint256 _amount,address _account) public view returns (uint256) {
    uint256 beforebalance = masterpool[_id].users[_account].balance;
    uint256 increaseblock = masterpool[_id].lockblock.mul(_amount).div(beforebalance.add(_amount));
    if(masterpool[_id].users[_account].locked<block.timestamp){
        return block.timestamp.add(increaseblock);
    }else{
        return masterpool[_id].users[_account].locked.add(increaseblock);
    }
  }

  function harvesting(uint256 _id) public returns (bool) {
    harvest(_id,msg.sender);
    return true;
  }

  function tryharvest(uint256 _id,address _account) public view returns (uint256) {
    uint256 lastclaimblock = masterpool[_id].users[_account].harvest;
    uint256 maxearnblock;
    if(block.timestamp>masterpool[_id].users[_account].firststakedblock.add(masterpool[_id].maxblockreward)){
      maxearnblock = masterpool[_id].users[_account].firststakedblock.add(masterpool[_id].maxblockreward);
    }else{
      maxearnblock = block.timestamp;
    }
    if(lastclaimblock>0){
        return (masterpool[_id].users[_account].balance).mul(masterpool[_id].apr).div(100).mul(maxearnblock.sub(lastclaimblock)).div(ayear);
    }else{
        return 0;
    }
  }

  function harvest(uint256 _id,address _account) internal {
    uint256 lastclaimblock = masterpool[_id].users[_account].harvest;
    uint256 maxearnblock;
    if(block.timestamp>masterpool[_id].users[_account].firststakedblock.add(masterpool[_id].maxblockreward)){
      maxearnblock = masterpool[_id].users[_account].firststakedblock.add(masterpool[_id].maxblockreward);
    }else{
      maxearnblock = block.timestamp;
    }
    if(lastclaimblock>0){
        uint256 reward = (masterpool[_id].users[_account].balance).mul(masterpool[_id].apr).div(100).mul(maxearnblock.sub(lastclaimblock)).div(ayear);
        IERC20 token = IERC20(masterpool[_id].rewardtoken);
        token.transfer(_account,reward);
    }
    masterpool[_id].users[_account].harvest = block.timestamp;
  }

  function getupdatereward(uint256 _id) internal view returns (uint256) {
    uint256 harvested = getHarvested(_id);
    return masterpool[_id].remainreward.sub(harvested);
  }

  function getHarvested(uint256 _id) internal view returns (uint256) {
    uint256 bf_balance = snapshot[_id].balance;
    uint256 bf_block = snapshot[_id].snapblock;
    if(bf_block>0){
        return (bf_balance).mul(masterpool[_id].apr).div(100).mul(block.timestamp.sub(bf_block)).div(ayear);
    }else{
        return 0;
    }
  }

  function shouldlocked(uint256 _id) public view returns (bool) {
    if(masterpool[_id].endblock > block.timestamp && masterpool[_id].remainreward > 0 ){
      return true;
    }else{
      return false;
    }
  }

}