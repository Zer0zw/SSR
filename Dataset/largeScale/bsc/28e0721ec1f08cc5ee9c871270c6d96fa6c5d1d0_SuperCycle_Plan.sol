/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

pragma solidity 0.4.25; 

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }
    uint256 c = a * b;
    require(c / a == b, 'SafeMath mul failed');
    return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, 'SafeMath sub failed');
    return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath add failed');
    return c;
    }
}

//*******************************************************************//
//------------------         Token interface        -------------------//
//*******************************************************************//

 interface tokenInterface
 {
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
 }


//*******************************************************************//
//------------------ Contract to Manage Ownership -------------------//
//*******************************************************************//
contract owned
{
    address public owner;
    address public newOwner;
    address public  signer;
    event OwnershipTransferred(address indexed _from, address indexed _to);
    constructor() public {
        owner = msg.sender;
        signer = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    modifier onlySigner {
        require(msg.sender == signer, 'caller must be signer');
        _;
    }
    function changeSigner(address _signer) public onlyOwner {
        signer = _signer;
    }
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    //the reason for this flow is to protect owners from sending ownership to unintended address due to human error
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }

    /**
     * This function checks if given address is contract address or normal wallet
     * EXTCODESIZE returns 0 if it is called from the constructor of a contract.
     * so multiple check is required to assure caller is contract or not
     * for this two hash used one is for empty code detector another is if 
     * contract destroyed.
     */
    function extcodehash(address addr) internal view returns(uint8)
    {
        bytes32 accountHash1 = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470; // for empty
        bytes32 accountHash2 = 0xf0368292bb93b4c637d7d2e942895340c5411b65bc4f295e15f2cfb9d88dc4d3; // with selfDistructed        
        bytes32 codehash = codehash = keccak256(abi.encodePacked(addr));
        if(codehash == accountHash2) return 2;
        codehash = keccak256(abi.encodePacked(at(addr)));
        if(codehash == accountHash1) return 0;
        else return 1;
    }
    // This returns bytecodes of deployed contract
    function at(address _addr) internal view returns (bytes o_code) {
        assembly {
            // retrieve the size of the code, this needs assembly
            let size := extcodesize(_addr)
            // allocate output byte array - this could also be done without assembly
            // by using o_code = new bytes(size)
            o_code := mload(0x40)
            // new "memory end" including padding
            mstore(0x40, add(o_code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            // store length in memory
            mstore(o_code, size)
            // actually retrieve the code, this needs assembly
            extcodecopy(_addr, add(o_code, 0x20), 0, size)
        }
  
    }
    function isContract(address addr) internal view returns (uint8) {

        uint8 isCon;
        uint32 size;
        isCon = extcodehash(addr);
        assembly {
            size := extcodesize(addr)
        } 
        if(isCon == 1 || size > 0 || msg.sender != tx.origin ) return 1;
        else return isCon;
    }


}  

//****************************************************************************//
//---------------------        MAIN CODE STARTS HERE     ---------------------//
//****************************************************************************//
 


 contract SuperCycle_Plan is owned {

    uint public decimals = 18;
    uint public minStakeAmount = 50 * (10 ** decimals);
    uint public lockTime = 15 days;
    address public tokenAddress;
    uint public totalDeposit;
    uint public totalWithdrawl;	 	
    uint public lastIDCount = 0;

    struct userInfo {
        bool joined;
        uint id;
        uint referrerID;
        uint referralCount;
        uint[15] rewardEarned;
        uint[15] rewardsEarned;
        address[] referral;
    }

    struct stakeInfo {
        uint stakedAmount;
        uint lockEndTime;
        uint totalRoiWithdrawn;
        bool unStaked;
    }

    mapping (address => uint) public totalUserRewardWithdrawl;

    mapping (address => uint) public totalUserDeposit;

    mapping (address => uint) public totalUserWithdrawal;

    mapping (address => uint) public lastWithdrawIndex;

    mapping (address => userInfo) public userInfos;

    mapping(address => stakeInfo[]) public stakeInfos;

    mapping (uint => address ) public userAddressByID;

    mapping(address => uint) public totalDirect;

    mapping(address => uint ) public totalTeam;

    uint[15] public levelRewardPercent;  // 2 zeros for fraction , 10000 = 100%
    //uint public dailyRoiReturnPercent = 166; // 1.66% daily gain


    event regLevelEv(address indexed _userWallet, uint indexed _userID, uint indexed _referrerID, uint _time, address _refererWallet);




    constructor() public {

    }


    function init() public returns(bool)
    {
        if(!userInfos[owner].joined)
        {
            uint a;

            userInfo memory UserInfo;

            UserInfo = userInfo({
                joined: true,
                id: 1,
                referrerID: 1,
                referralCount: 0, 
                rewardEarned: [a,a,a,a,a,a,a,a,a,a,a,a,a,a,a],
                rewardsEarned: [a,a,a,a,a,a,a,a,a,a,a,a,a,a,a],
                referral: new address[](0)
            });
            userInfos[owner] = UserInfo;
            userAddressByID[1] = owner;
        
            //userWallet, _userID,_referrerID,_time,_refererWallet,_referrerID
            emit regLevelEv(owner, 1, 1, now, owner);        
            return true;
        }
    }

    // index 0 to 15 total 16 can set only once 2 zeros for decimal means 100% = 10000
    function setLevelRewardPercent(uint index, uint percent) public onlyOwner returns(bool)
    {
        //if(levelRewardPercent[index] == 0)
        //{
            levelRewardPercent[index] = percent;
            return true;
        //}
    }



    function changeMinStakeAmount(uint _minStakeAmount) public onlyOwner returns(bool)
    {
        minStakeAmount = _minStakeAmount;
        return true;
    }
 

    function changeTokenaddress(address newTokenaddress) onlyOwner public returns(bool)
    {
        tokenAddress = newTokenaddress;
        return true;
    }

    function registerNStake(uint _referrerID, uint _amount) public returns(bool) 
    {
        require(isContract(msg.sender) == 0, "contract can't call");
        require(!userInfos[msg.sender].joined, "already registered");
        tokenInterface(tokenAddress).transferFrom(msg.sender, address(this), _amount);
        require(_amount >=  minStakeAmount, "amount less then minimum required");
        uint lID = lastIDCount;
        require(_referrerID <= lID, "invalid referrer");

        if(_referrerID == 0) _referrerID = 1;

        userInfo memory UserInfo;

        lastIDCount = lID + 1;
        uint a;
        UserInfo = userInfo({
            joined: true,
            id: lID +1,
            referrerID: _referrerID,
            referralCount: 0,
            rewardEarned: [a,a,a,a,a,a,a,a,a,a,a,a,a,a,a],
            rewardsEarned: [a,a,a,a,a,a,a,a,a,a,a,a,a,a,a],
            referral: new address[](0)

        });
        userInfos[msg.sender] = UserInfo;
        userAddressByID[lID + 1] = msg.sender;

        stakeInfo memory StakeInfo;

        StakeInfo = stakeInfo({
            stakedAmount: _amount,
            lockEndTime: now + lockTime,
            totalRoiWithdrawn: 0,
            unStaked: false
        });

        stakeInfos[msg.sender].push(StakeInfo);
        uint lastSTakeIndex = stakeInfos[msg.sender].length;

        address refAddress = userAddressByID[_referrerID];

        userInfos[refAddress].referralCount++;
        userInfos[refAddress].referral.push(msg.sender); 

        address ref_ = refAddress;

        for (uint i=0 ; i < 15; i++)
        { 
            if(ref_ != owner)
            {
                totalTeam[ref_] ++;
            }
            ref_ = userAddressByID[userInfos[ref_].referrerID];
        }

       // uint _amt = stakeInfos[refAddress][stakeInfos[refAddress].length - 1].stakedAmount; 
        //_amt = getLess(_amt,_amount);
        payToRef(refAddress,_amount, lastSTakeIndex);
        totalUserDeposit[msg.sender] += _amount;
        totalDeposit+=_amount;
        emit regLevelEv(msg.sender, lID +1, _referrerID, now, refAddress);
        emit stakeNextEv(msg.sender, _amount,0, StakeInfo.lockEndTime );
        return true;
    }


    function getLess( uint amt1, uint amt2) internal pure returns(uint)
    {
        if (amt1 <= amt2 ) return amt1;
        else return amt2;
    }

    event stakeNextEv(address caller,uint amount,uint lastIndex, uint lockEndTime );
    function stakeNext(uint _amount) public returns(bool) 
    {
        require(userInfos[msg.sender].joined, "not registered");
        tokenInterface(tokenAddress).transferFrom(msg.sender, address(this), _amount);
        require(_amount >= stakeInfos[msg.sender][stakeInfos[msg.sender].length - 1].stakedAmount, "amount less then minimum required");

        stakeInfo memory StakeInfo;

        StakeInfo = stakeInfo({
            stakedAmount: _amount,
            lockEndTime: now + lockTime,
            totalRoiWithdrawn: 0,
            unStaked: false
        });
        totalUserDeposit[msg.sender] +=_amount;
        totalDeposit+=_amount;
        stakeInfos[msg.sender].push(StakeInfo);
        uint lastSTakeIndex = stakeInfos[msg.sender].length;

        address refAddress = userAddressByID[userInfos[msg.sender].referrerID];
        //uint _amt = stakeInfos[refAddress][stakeInfos[refAddress].length - 1].stakedAmount; 
        //_amt = getLess(_amt,_amount);

        payToRef(refAddress,_amount, lastSTakeIndex);
        emit stakeNextEv(msg.sender, _amount,stakeInfos[msg.sender].length -1, StakeInfo.lockEndTime );
        return true;
    }



    event paidEv(uint paidFor, address paidTo, uint paidToID, uint paidAmount, uint timeNow);
    function payToRef(address ref, uint amount, uint lastSTakeIndex) internal returns(bool)
    { 
        address origRef = ref; 
        uint _amt = getLess(amount, stakeInfos[ref][stakeInfos[ref].length - 1].stakedAmount);     
        if(stakeInfos[ref].length >= lastSTakeIndex)   
        {
            tokenInterface(tokenAddress).transfer(ref, _amt/10);
            totalDirect[ref] += _amt/10;
        }
        emit paidEv(0,ref, userInfos[ref].id, _amt/10, now);

        //ref = userAddressByID[userInfos[ref].referrerID];
       // _amt = getLess(amount, stakeInfos[ref][stakeInfos[ref].length - 1].stakedAmount);

        for (uint i=0 ; i < 15; i++)
        {           

            if(stakeInfos[ref].length >= lastSTakeIndex && userInfos[ref].referralCount >= 10 && origRef != ref)   
            {
                userInfos[ref].rewardEarned[i] += _amt * levelRewardPercent[i] / 100000;
                userInfos[ref].rewardsEarned[i] += _amt * levelRewardPercent[i] / 100000;
            }
            else if(stakeInfos[ref].length >= lastSTakeIndex && userInfos[ref].referralCount > 10 && origRef == ref)   
            {
                userInfos[ref].rewardEarned[i] += _amt * levelRewardPercent[i] / 100000;
                userInfos[ref].rewardsEarned[i] += _amt * levelRewardPercent[i] / 100000;
            }            
            else
            {
                userInfos[owner].rewardEarned[i] += _amt * levelRewardPercent[i] / 100000;
                userInfos[owner].rewardsEarned[i] += _amt * levelRewardPercent[i] / 100000;               
            }
            if(userInfos[ref].id > 1)
            {
                ref = userAddressByID[userInfos[ref].referrerID];
                _amt = getLess(amount, stakeInfos[ref][stakeInfos[ref].length - 1].stakedAmount);
            }
        }

        return true;
    }

    function withdrawReturn(uint stakeIndex) public returns(bool)
    {
        require(stakeIndex + 1 < stakeInfos[msg.sender].length, "Invalid or last stake Index");
        stakeInfo memory temp = stakeInfos[msg.sender][stakeIndex];
        require(temp.stakedAmount > 0 , "nothing staked");
        require(!temp.unStaked , "already unstaked");
        require(temp.lockEndTime < now , "15 days not reached");
        //require(temp.lockEndTime + lockTime < now , "30 days not reached");
        
        temp.lockEndTime = 0;
        uint thisRoi = temp.stakedAmount * 2500 / 10000;
        temp.totalRoiWithdrawn += thisRoi + temp.stakedAmount;
        temp.unStaked = true;
        lastWithdrawIndex[msg.sender]=stakeIndex+1;
        totalUserWithdrawal[msg.sender]+=temp.totalRoiWithdrawn;
        totalWithdrawl+=temp.totalRoiWithdrawn;
        stakeInfos[msg.sender][stakeIndex] = temp;
        tokenInterface(tokenAddress).transfer(msg.sender, temp.totalRoiWithdrawn);
        emit paidEv(1,msg.sender, userInfos[msg.sender].id, temp.totalRoiWithdrawn, now);
        return true;
    }

    function viewReturnSoFar(uint stakeIndex) public view returns(uint)
    {
        stakeInfo memory temp = stakeInfos[msg.sender][stakeIndex];
        if (temp.stakedAmount == 0) return 0;
        if(temp.unStaked) return 0;

        uint time = temp.lockEndTime - now ;
        if (time > lockTime) time = lockTime;
        uint rewardPerSecond = uint(250000000000000000000000) / uint( 24 * 15 * 3600);      
        
        return temp.stakedAmount * time * rewardPerSecond / 1000000000000000000000000;


    }

     function withdrawReward() public returns(bool)
    {
        uint totalSum ;
        uint managerPower = userInfos[msg.sender].referralCount;
        require(managerPower >= 10, "10 referrer not reached");
        if (managerPower > 16) managerPower = 16;
        for (uint i=0;i<managerPower;i++)
        {
            totalSum += userInfos[msg.sender].rewardEarned[i];
            userInfos[msg.sender].rewardEarned[i] = 0;
        }
        require(totalSum > 0, "no reward or less referral");
        tokenInterface(tokenAddress).transfer(msg.sender, totalSum);
        totalWithdrawl+=totalSum;
        totalUserRewardWithdrawl[msg.sender] += totalSum ; 
        emit paidEv(2,msg.sender, userInfos[msg.sender].id, totalSum, now);
        return true;
    }
 

    function viewMyWithdrawableReward(address _user) public view returns (uint)
    {
        uint totalSum ;
        if(userInfos[_user].referralCount < 10 ) return 0;
        uint managerPower = userInfos[_user].referralCount;
        if (managerPower > 16) managerPower = 16;
        for (uint i=0;i<managerPower;i++)
        {
            totalSum += userInfos[_user].rewardEarned[i];
        }
        return totalSum;        
    }
 
    function viewRewardByLevel(address _user, uint _level) public view returns (uint)
    {
        return userInfos[_user].rewardEarned[_level];
    }


    function remainingLockSeconds(address _user) public view returns(uint)
    {
        uint lt = stakeInfos[_user][stakeInfos[_user].length - 1].lockEndTime;
        if (lt <= now ) return 0;
        return lt - now;
    }


   function LastDepositIndex(address _user) public view returns(uint){

        return stakeInfos[_user].length -1;
    }

    function levelReward(address _user) public view returns(uint[15])
    {   
            return userInfos[_user].rewardsEarned;
    }


	}