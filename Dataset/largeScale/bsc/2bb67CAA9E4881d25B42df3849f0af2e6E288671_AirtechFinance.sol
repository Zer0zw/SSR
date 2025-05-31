/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

pragma solidity 0.5.4;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender)
  external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value)
  external returns (bool);
  
  function transferFrom(address from, address to, uint256 value)
  external returns (bool);
  function burn(uint256 value)
  external returns (bool);
  event Transfer(address indexed from,address indexed to,uint256 value);
  event Approval(address indexed owner,address indexed spender,uint256 value);
}

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

contract AirtechFinance {
     using SafeMath for uint256;
     
    struct Staking {
        uint256 programId;
        uint256 stakingDate;
        uint256 staking;
        uint256 lastWithdrawalDate;
        uint256 currentRewards;
        bool    isExpired;
        uint256 genRewards;
        uint256 stakingToken;
        bool    isAddedStaked;
    }

    struct Program {
        uint256 dailyInterest;
        uint256 term; //0 means unlimited
        uint256 maxDailyInterest;
    }
  
     
    struct User {
        uint id;
        address referrer;
        uint256 programCount;
        uint256 totalStakingBusd;
        uint256 totalStakingToken;
        uint256 currentPercent;
        uint256 airdropReward;
        mapping(uint256 => Staking) programs;
    }
    
    
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    
    Program[] private stakingPrograms_;
    
    uint256 private constant INTEREST_CYCLE = 1 days;

    uint public lastUserId = 2;
    uint256 public tokenPrice=1e17;
    uint256  priceIncPercent=2e16;
    uint256  priceDecPercent=1e16;
    uint8 public lastChange=1;
    bool public isAdminOpen;
    
    uint256 public  total_staking_token = 0;
    uint256 public  total_staking_busd = 0;
    uint256 public  total_virtual_staking = 0;
    
    uint256 public  total_withdraw_token = 0;
    uint256 public  total_withdraw_busd = 0;
    
    uint256 public  total_token_buy = 0;
    uint256 public  total_token_sell = 0;
	
	bool   public  buyOn = true;
	bool   public  sellOn = true;
	bool   public  stakingOn = true;
	bool   public  airdropOn = true;
	
	uint256 public  MINIMUM_BUY = 1e18;
	uint256 public  MINIMUM_SELL = 1e18;
	
	uint256 public  priceIncUpdateGap = 3000*1e18;
	uint256 public  priceDecUpdateGap = 7000*1e18;
	
    address public owner; 
    
    event Registration(address indexed user, address indexed referrer, uint256 indexed userId, uint256 referrerId, uint8 position);
    event CycleStarted(address indexed user,uint256 stakeID, uint256 walletUsedBusd, uint256 totalToken);
    event TokenDistribution(address indexed sender, address indexed receiver, uint total_token, uint live_rate, uint busd_amount);
    event onWithdraw(address  _user, uint256 withdrawalAmount,uint256 withdrawalAmountToken);
    event ReferralReward(address  _user,address _from,uint256 reward);
    IBEP20 private airtechToken; 
    IBEP20 private busdToken; 

    constructor(address ownerAddress, IBEP20 _busdToken, IBEP20 _airtechToken) public 
    {
        owner = ownerAddress;
        
        airtechToken = _airtechToken;
        busdToken = _busdToken;
        
        stakingPrograms_.push(Program(100,365*24*60*60,100));  //  365 Days
        stakingPrograms_.push(Program(274,365*24*60*60,274));
        
        User memory user = User({
            id: 1,
            referrer: address(0),
            programCount: uint(0),
            totalStakingBusd: uint(0),
            totalStakingToken: uint(0),
            currentPercent: uint(0),
            airdropReward:uint(0)
        });
        users[ownerAddress] = user;
        idToAddress[1] = ownerAddress;
    } 
    
    function() external payable 
    {
        if(msg.data.length == 0) {
            return registration(msg.sender, owner,1);
        }
        
        registration(msg.sender, bytesToAddress(msg.data),1);
    }

    function withdrawBalance(uint256 amt,uint8 _type) public 
    {
        require(msg.sender == owner, "onlyOwner");
        if(_type==1)
        msg.sender.transfer(amt);
        else if(_type==2)
        busdToken.transfer(msg.sender,amt);
        else
        airtechToken.transfer(msg.sender,amt);
    }
    
      function multisend(address payable[]  memory  _contributors, uint256[] memory _balances) public payable 
     {
        require(msg.sender==owner,"Only Owner");
        uint256 i = 0;
        for (i; i < _contributors.length; i++) 
        {
            airtechToken.transfer(_contributors[i],_balances[i]);
        }
    }
    
  
    function registration(address userAddress, address referrerAddress, uint8 position) private 
    {
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        
        require(size == 0, "cannot be a contract");
        
        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
            programCount: 0,
            totalStakingBusd: 0,
            totalStakingToken: 0,
            currentPercent: 0,
            airdropReward:0
        });
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        
        users[userAddress].referrer = referrerAddress;
        
        lastUserId++;
        
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id,position);
    }
    
    // Staking Process
    
    function start_staking(uint256 walletUsedBusd,uint256 _programId,address referrer,uint8 position) public 
    {
        require(stakingOn,"Staking Stopped.");
        require(position==1 || position==2,"Invalid Position.");
        require(_programId==0, "Wrong staking program id");
        if(!isUserExists(msg.sender))
	    {
	        registration(msg.sender, referrer,position);   
	    }
	    else
	    {
	        updateRewards();
	    }
        require(isUserExists(msg.sender), "user not exists");
        
        // wallet balance 
        uint256 walletUsed=(walletUsedBusd.mul(1e18)).div(tokenPrice);
        require(airtechToken.balanceOf(msg.sender)>=walletUsed,"Low wallet balance");
        require(airtechToken.allowance(msg.sender,address(this))>=walletUsed,"Allow token first");
      
        airtechToken.transferFrom(msg.sender,address(this),walletUsed);
       
        uint256 _busdAmount=walletUsedBusd;
        require(_busdAmount>=11*1e18, "Minimum 11 Dollar");
        
        uint256 programCount = users[msg.sender].programCount;
        
        users[msg.sender].programs[programCount].programId = _programId;
        users[msg.sender].programs[programCount].stakingDate = block.timestamp;
        users[msg.sender].programs[programCount].lastWithdrawalDate = block.timestamp;
        users[msg.sender].programs[programCount].staking = _busdAmount;
        users[msg.sender].programs[programCount].currentRewards = 0;
        users[msg.sender].programs[programCount].genRewards = 0;
        users[msg.sender].programs[programCount].isExpired = false;
        users[msg.sender].programs[programCount].stakingToken = walletUsed;
        users[msg.sender].programCount = users[msg.sender].programCount.add(1);
        
        users[msg.sender].totalStakingToken = users[msg.sender].totalStakingToken.add(walletUsed);
        users[msg.sender].totalStakingBusd = users[msg.sender].totalStakingBusd.add(_busdAmount);
        users[msg.sender].currentPercent=getStakingPercent(msg.sender);
        address referrerAddress=users[msg.sender].referrer;
        
        if(msg.sender!=owner)
        {
            uint256 refBonus=(walletUsed.mul(10)).div(100);
            airtechToken.transfer(referrerAddress,refBonus);
            emit ReferralReward(referrerAddress,msg.sender,refBonus);
        }
	    
	    total_virtual_staking=total_virtual_staking+_busdAmount;
	    
	    if(total_virtual_staking>=priceIncUpdateGap && lastChange==1 && !isAdminOpen)
	    updateTokenPrice();
	    if(total_virtual_staking>=priceDecUpdateGap && lastChange==0 && !isAdminOpen)
	    updateTokenPrice();
	
	    emit CycleStarted(msg.sender,users[msg.sender].programCount, walletUsedBusd,walletUsed);
    }

    function buyToken(uint256 tokenQty) public payable
	{
	     require(buyOn,"Buy Stopped.");
	     require(!isContract(msg.sender),"Can not be contract");
	     require(tokenQty>=MINIMUM_BUY,"Invalid minimum quantity");
	     uint256 buy_amt=(tokenQty/1e18)*tokenPrice;
	     
	     busdToken.transferFrom(msg.sender ,address(this), (buy_amt));
	     airtechToken.transfer(msg.sender , tokenQty);
	     
         total_token_buy=total_token_buy+tokenQty;
		 emit TokenDistribution(address(this), msg.sender, tokenQty, tokenPrice, buy_amt);					
	 }
	 
	function sellToken(uint256 tokenQty) public payable
	{
	     require(sellOn,"Sell Stopped.");
	     require(!isContract(msg.sender),"Can not be contract");
	     require(tokenQty>=MINIMUM_SELL,"Invalid minimum quantity");
	     require(isUserExists(msg.sender),"User Not Exist");
	     airtechToken.transferFrom(msg.sender,address(this),tokenQty);
	     uint256 busd_amt=(tokenQty/1e18)*tokenPrice;
	     
	     busdToken.transfer(msg.sender,busd_amt);
         total_token_sell=total_token_sell+tokenQty;
         emit TokenDistribution(address(this), msg.sender, tokenQty, tokenPrice, busd_amt);					
	 } 
	 

	
	function withdraw() public payable 
	{
        require(msg.value == 0, "withdrawal doesn't allow to transfer bnb simultaneously");
        uint256 uid = users[msg.sender].id;
        require(uid != 0, "Can not withdraw because no any stakings");
        uint256 withdrawalAmount = 0;
        for (uint256 i = 0; i < users[msg.sender].programCount; i++) 
        {
            if (users[msg.sender].programs[i].isExpired) {
                users[msg.sender].programs[i].genRewards=0;
                continue;
            }

            Program storage program = stakingPrograms_[users[msg.sender].programs[i].programId];

            bool isExpired = false;
            bool isAddedStaked = false;
            uint256 withdrawalDate = block.timestamp;
            if (program.term > 0) {
                uint256 endTime = users[msg.sender].programs[i].stakingDate.add(program.term);
                if (withdrawalDate >= endTime) {
                    withdrawalDate = endTime;
                    isExpired = true;
                    isAddedStaked=true;
                    
                    if(users[msg.sender].programs[i].programId==0)
                    {
                        uint256 programCount = users[msg.sender].programCount;
                        users[msg.sender].programs[programCount].programId = 1;
                        users[msg.sender].programs[programCount].stakingDate = endTime;
                        users[msg.sender].programs[programCount].lastWithdrawalDate = endTime;
                        users[msg.sender].programs[programCount].staking = users[msg.sender].programs[i].staking;
                        users[msg.sender].programs[programCount].currentRewards = 0;
                        users[msg.sender].programs[programCount].genRewards = 0;
                        users[msg.sender].programs[programCount].isExpired = false;
                        users[msg.sender].programs[programCount].stakingToken = users[msg.sender].programs[i].stakingToken;
                        users[msg.sender].programCount = users[msg.sender].programCount.add(1);
                    }
                }
            }
            
            uint256 stakingPercent;
            if(users[msg.sender].programs[i].programId==0)
            stakingPercent=users[msg.sender].currentPercent;
            else
            stakingPercent=stakingPrograms_[users[msg.sender].programs[i].programId].dailyInterest;
            
            uint256 amount = _calculateRewards(users[msg.sender].programs[i].stakingToken , stakingPercent , withdrawalDate , users[msg.sender].programs[i].lastWithdrawalDate , stakingPercent);

            withdrawalAmount += amount;
            withdrawalAmount += users[msg.sender].programs[i].genRewards;
            
            users[msg.sender].programs[i].lastWithdrawalDate = withdrawalDate;
            users[msg.sender].programs[i].isExpired = isExpired;
            users[msg.sender].programs[i].isAddedStaked = isAddedStaked;
            users[msg.sender].programs[i].currentRewards += amount;
            users[msg.sender].programs[i].genRewards=0;
        }
        
        if(withdrawalAmount>0)
        {
            airtechToken.transfer(msg.sender,withdrawalAmount);
            total_withdraw_busd=total_withdraw_busd+(withdrawalAmount.mul(tokenPrice.div(1e18)));
            total_withdraw_token=total_withdraw_token+(withdrawalAmount);
            emit onWithdraw(msg.sender, total_withdraw_busd,withdrawalAmount);
        }
    }
    
    
    function updateRewards() private
	{
        require(msg.value == 0, "withdrawal doesn't allow to transfer bnb simultaneously");
        uint256 uid = users[msg.sender].id;
        require(uid != 0, "Can not withdraw because no any stakings");
        
        for (uint256 i = 0; i < users[msg.sender].programCount; i++) 
        {
            if (users[msg.sender].programs[i].isExpired) {
                continue;
            }

            Program storage program = stakingPrograms_[users[msg.sender].programs[i].programId];

            bool isExpired = false;
            bool isAddedStaked = false;
            uint256 withdrawalDate = block.timestamp;
            if (program.term > 0) {
                uint256 endTime = users[msg.sender].programs[i].stakingDate.add(program.term);
                if (withdrawalDate >= endTime) {
                    withdrawalDate = endTime;
                }
            }
            
            uint256 stakingPercent;
            if(users[msg.sender].programs[i].programId==0)
            stakingPercent=users[msg.sender].currentPercent;
            else
            stakingPercent=stakingPrograms_[users[msg.sender].programs[i].programId].dailyInterest;
            
            uint256 amount = _calculateRewards(users[msg.sender].programs[i].stakingToken , stakingPercent , withdrawalDate , users[msg.sender].programs[i].lastWithdrawalDate , stakingPercent);

            users[msg.sender].programs[i].lastWithdrawalDate = withdrawalDate;
            users[msg.sender].programs[i].isExpired = isExpired;
            users[msg.sender].programs[i].isAddedStaked = isAddedStaked;
            users[msg.sender].programs[i].currentRewards += amount;
            users[msg.sender].programs[i].genRewards += amount;
        }
    }
    
    function getStakingProgramByUID(address _user) public view returns (uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory,uint256[] memory, bool[] memory, bool[] memory) 
    {       
        User storage staker = users[_user];
        uint256[] memory stakingDates = new  uint256[](staker.programCount);
        uint256[] memory stakings = new  uint256[](staker.programCount);
        uint256[] memory currentRewards = new  uint256[](staker.programCount);
        bool[] memory isExpireds = new  bool[](staker.programCount);
        uint256[] memory newRewards = new uint256[](staker.programCount);
        uint256[] memory genRewards = new uint256[](staker.programCount);
        bool[] memory isAddedStakeds = new bool[](staker.programCount);

        for(uint256 i=0; i<staker.programCount; i++){
            require(staker.programs[i].stakingDate!=0,"wrong staking date");
            currentRewards[i] = staker.programs[i].currentRewards;
            genRewards[i] = staker.programs[i].genRewards;
            isAddedStakeds[i] = staker.programs[i].isAddedStaked;
            stakingDates[i] = staker.programs[i].stakingDate;
            stakings[i] = staker.programs[i].stakingToken;
            
            uint256 stakingPercent;
            if(staker.programs[i].programId==0)
            stakingPercent=staker.currentPercent;
            else
            stakingPercent=stakingPrograms_[staker.programs[i].programId].dailyInterest;
            
            if (staker.programs[i].isExpired) {
                isExpireds[i] = true;
                newRewards[i] = 0;
                
            } else {
                isExpireds[i] = false;
                if (stakingPrograms_[staker.programs[i].programId].term > 0) {
                    if (block.timestamp >= staker.programs[i].stakingDate.add(stakingPrograms_[staker.programs[i].programId].term)) {
                        newRewards[i] = _calculateRewards(staker.programs[i].stakingToken, stakingPercent, staker.programs[i].stakingDate.add(stakingPrograms_[staker.programs[i].programId].term), staker.programs[i].lastWithdrawalDate, stakingPercent);
                        isExpireds[i] = true;
                       
                    }
                    else{
                        newRewards[i] = _calculateRewards(staker.programs[i].stakingToken, stakingPercent, block.timestamp, staker.programs[i].lastWithdrawalDate, stakingPercent);
                      
                    }
                } else {
                    newRewards[i] = _calculateRewards(staker.programs[i].stakingToken, stakingPercent, block.timestamp, staker.programs[i].lastWithdrawalDate, stakingPercent);
                 
                }
            }
        }

        return
        (
        stakingDates,
        stakings,
        currentRewards,
        newRewards,
        genRewards,
        isExpireds,
        isAddedStakeds
        );
    }
    
    function getStakingToken(address _user) public view returns (uint256[] memory) 
    {       
        User storage staker = users[_user];
        uint256[] memory stakings = new  uint256[](staker.programCount);

        for(uint256 i=0; i<staker.programCount; i++){
            require(staker.programs[i].stakingDate!=0,"wrong staking date");
            stakings[i] = staker.programs[i].stakingToken;
        }

        return
        (
            stakings
        );
    }

	function _calculateRewards(uint256 _amount, uint256 _dailyInterestRate, uint256 _now, uint256 _start , uint256 _maxDailyInterest) private pure returns (uint256){

        uint256 numberOfDays =  (_now - _start) / INTEREST_CYCLE ;
        uint256 result = 0;
        uint256 index = 0;
        if(numberOfDays > 0){
          uint256 secondsLeft = (_now - _start);
           for (index; index < numberOfDays; index++) {
               if(_dailyInterestRate + index <= _maxDailyInterest ){
                   secondsLeft -= INTEREST_CYCLE;
                     result += (_amount * (_dailyInterestRate + index) / 100000 * INTEREST_CYCLE) / (24*60*60);
               }
               else
               {
                 break;
               }
            }

            result += (((_amount.mul(_dailyInterestRate)).div(100000)) * secondsLeft) / (24*60*60);

            return result;

        }else{
            return (_amount * _dailyInterestRate / 100000 * (_now - _start)) / (24*60*60);
        }

    }
    
    // ***Token Price Algorithm***
    
	function updateTokenPrice() private
	{
	     while(true)
	     {
	        if(lastChange==1)
	        {
	             if(total_virtual_staking<priceIncUpdateGap)
    	         return;
	             lastChange=0;
    	         tokenPrice=tokenPrice+priceIncPercent;
    	         total_virtual_staking=total_virtual_staking-priceIncUpdateGap;
    	         
	        }
	        else
	        {
	            if(total_virtual_staking<priceDecUpdateGap)
    	        return;
	            lastChange=1;
        	    tokenPrice=tokenPrice-priceDecPercent;
        	    total_virtual_staking=total_virtual_staking-priceDecUpdateGap;
	        }
	      }
	}
	
	
	// ***Staking Percent***
	
	function getStakingPercent(address _user) public view returns(uint16)
	{
	    require(isUserExists(_user),"User Not Exist");	    
	    if(users[_user].totalStakingBusd>10000*1e18)
	    return 300;
	    else if(users[_user].totalStakingBusd>5000*1e18)
	    return 260;
	    else if(users[_user].totalStakingBusd>2000*1e18)
	    return 230;
	    else if(users[_user].totalStakingBusd>500*1e18)
	    return 180;
        else if(users[_user].totalStakingBusd>250*1e18)
	    return 150;
	    else if(users[_user].totalStakingBusd>100*1e18)
	    return 110;
	    else
	    return 83;
	}

 
	
    function isContract(address _address) public view returns (bool _isContract)
    {
          uint32 size;
          assembly {
            size := extcodesize(_address)
          }
          return (size > 0);
    }   
   
    
    function openAdminPrice(uint8 _type) public payable
    {
              require(msg.sender==owner,"Only Owner");
              if(_type==1)
              isAdminOpen=true;
              else
              {
                isAdminOpen=false;
                total_virtual_staking=0;
              }
    }
    
    function sendAirdropToken(address _user,uint256 token) public payable
    {
        require(msg.sender==owner,"Only Owner.");
        require(isUserExists(_user),"User Not Exist.");
        airtechToken.transfer(_user,token*1e18);
	    users[_user].airdropReward=users[_user].airdropReward+token;
    }
    
    function updatePrice(uint256 _price) public payable
    {
              require(msg.sender==owner,"Only Owner");
              require(isAdminOpen,"Admin option not open.");
              tokenPrice=_price;
    }
    
    
    function switchStaking(uint8 _type) public payable
    {
        require(msg.sender==owner,"Only Owner");
            if(_type==1)
            stakingOn=true;
            else
            stakingOn=false;
    }
    
    function switchBuy(uint8 _type) public payable
    {
        require(msg.sender==owner,"Only Owner");
            if(_type==1)
            buyOn=true;
            else
            buyOn=false;
    }
    
    
    function switchSell(uint8 _type) public payable
    {
        require(msg.sender==owner,"Only Owner");
            if(_type==1)
            sellOn=true;
            else
            sellOn=false;
    }
    
    
    function isUserExists(address user) public view returns (bool) 
    {
        return (users[user].id != 0);
    }
    
    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}