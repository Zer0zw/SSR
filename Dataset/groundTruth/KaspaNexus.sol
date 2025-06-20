/**
 *Submitted for verification at Etherscan.io on 2024-05-03
*/

//SPDX-License-Identifier: MIT Licensed
pragma solidity ^0.8.17;

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);
}

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract KSPNXPresale is Ownable {
    IERC20 public mainToken;
    IERC20 public USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IERC20 public USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    uint256[] public tokenPerUsdPrice;
    uint256[] public tokensToSell;
    uint256 public immutable totalStages;
    uint8 public immutable tokenDecimals;
    uint256 public totalStakedAmount;
    uint256 public distributedReward;

    uint256 public distrubuteAbleReward;
    uint256 constant APY = 20_00;
    uint256 constant year = 365 days;
    uint256 constant percentDivider = 100_00;
    uint256 constant RefRewardPercent = 10_00;

    AggregatorV3Interface public priceFeed;

    struct Phase {
        uint256 tokenPerUsdPrice;
        uint256 tokensToSell;
        uint256 tokenSold;
    }

    uint256 public currentStage;
    uint256 public totalStaker;
    uint256 public soldToken;
    uint256 public amountRaised;
    uint256 public amountRaisedUSDT;
    uint256 public amountRaisedUSDC;
    address payable public fundReceiver;

    bool public presaleStatus;
    bool public isPresaleEnded;

    address[] public UsersAddresses;
    struct User {
        uint256 native_balance;
        uint256 usdt_balance;
        uint256 usdc_balance;
        uint256 refReward;
        uint256 purchasedToken;
        uint256 claimedAmount;
        uint256 claimAbleAmount;
        uint256 stakeCount;
    }

    struct StakeData {
        uint256 stakedTokens;
        uint256 claimedTokens;
        uint256 stakeTime;
        uint256 claimedReward;
        bool isUnstake;
        uint256 unstakeTime;
    }
    mapping(address => User) public users;
    mapping(address => mapping(uint256 => StakeData)) public userStakes;
    mapping(uint256 => Phase) public phases;
    mapping(address => bool) public isExist;
    mapping(address => address) public referral;
    mapping(address => uint256) public referralCount;

    event BuyTokenETh(
        address indexed _user,
        uint256 buyingAmount,
        uint256 indexed _tokenamount
    );
    event BuyTokenUSDT(
        address indexed _user,
        uint256 buyingAmount,
        uint256 indexed _tokenamount
    );
    event BuyTokenUSDC(
        address indexed _user,
        uint256 buyingAmount,
        uint256 indexed _tokenamount
    );
    event ClaimToken(address _user, uint256 indexed _amount);
    event UpdatePrice(uint256 _oldPrice, uint256 _newPrice);

    constructor(IERC20 _token, address _fundReceiver) {
        mainToken = _token;
        fundReceiver = payable(_fundReceiver);
        priceFeed = AggregatorV3Interface(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        );
        tokenDecimals = mainToken.decimals();
        distrubuteAbleReward = 50_000_000 * 10**(tokenDecimals);
        tokenPerUsdPrice = [
            14285 * 10**(tokenDecimals - 2),
            125 * 10**(tokenDecimals),
            11111 * 10**(tokenDecimals - 2),
            100 * 10**(tokenDecimals),
            909 * 10**(tokenDecimals - 1),
            8333 * 10**(tokenDecimals - 2),
            76923 * 10**(tokenDecimals - 3),
            7142 * 10**(tokenDecimals - 2),
            6666 * 10**(tokenDecimals - 2),
            625 * 10**(tokenDecimals - 1)
        ];
        tokensToSell = [
            25_000_000 * 10**(tokenDecimals),
            75_000_000 * 10**(tokenDecimals),
            125_000_000 * 10**(tokenDecimals),
            175_000_000 * 10**(tokenDecimals),
            225_000_000 * 10**(tokenDecimals),
            275_000_000 * 10**(tokenDecimals),
            325_000_000 * 10**(tokenDecimals),
            375_000_000 * 10**(tokenDecimals),
            425_000_000 * 10**(tokenDecimals),
            475_000_000 * 10**(tokenDecimals)
        ];
        for (uint256 i = 0; i < tokenPerUsdPrice.length; i++) {
            phases[i].tokenPerUsdPrice = tokenPerUsdPrice[i];
            phases[i].tokensToSell = tokensToSell[i];
        }
        totalStages = tokenPerUsdPrice.length;
    }

    // to get real time price of ETH
    function getLatestPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price);
    }

    // to buy token during preSale time with ETH => for web3 use

    function buyToken(bool _isStake, address _refAddress) public payable {
        require(_refAddress != msg.sender, "cant ref yourself");
        require(!isPresaleEnded, "Presale ended!");
        require(presaleStatus, " Presale is Paused, check back later");
        if (!isExist[msg.sender]) {
            isExist[msg.sender] = true;
            UsersAddresses.push(msg.sender);
        }
        fundReceiver.transfer(msg.value);

        uint256 numberOfTokens;
        numberOfTokens = nativeToToken(msg.value, currentStage);
        require(
            phases[currentStage].tokenSold + numberOfTokens <=
                phases[currentStage].tokensToSell,
            "Phase Limit Reached"
        );
        if (referral[msg.sender] == address(0) && isExist[_refAddress]) {
            referral[msg.sender] = _refAddress;
            referralCount[_refAddress] += 1;
            users[_refAddress].refReward +=
                (numberOfTokens * RefRewardPercent) /
                percentDivider;
        }
        soldToken = soldToken + (numberOfTokens);
        phases[currentStage].tokenSold += numberOfTokens;
        amountRaised = amountRaised + msg.value;

        users[msg.sender].native_balance =
            users[msg.sender].native_balance +
            (msg.value);
        if (!_isStake) {
            users[msg.sender].claimAbleAmount =
                users[msg.sender].claimAbleAmount +
                numberOfTokens;
        } else {
            stake(numberOfTokens);
            if (users[msg.sender].stakeCount == 0) {
                totalStaker++;
            }
        }
        users[msg.sender].purchasedToken += numberOfTokens;
        emit BuyTokenETh(msg.sender, msg.value, numberOfTokens);
    }

    // to buy token during preSale time with USDT => for web3 use
    function buyTokenUSDT(
        uint256 amount,
        bool _isStake,
        address _refAddress
    ) public {
        require(_refAddress != msg.sender, "cant ref yourself");
        require(!isPresaleEnded, "Presale ended!");
        require(presaleStatus, " Presale is Paused, check back later");
        if (!isExist[msg.sender]) {
            isExist[msg.sender] = true;
            UsersAddresses.push(msg.sender);
        }
        USDT.transferFrom(msg.sender, address(this), amount);

        uint256 numberOfTokens;
        numberOfTokens = usdtToToken(amount, currentStage);
        require(
            phases[currentStage].tokenSold + numberOfTokens <=
                phases[currentStage].tokensToSell,
            "Phase Limit Reached"
        );
        if (referral[msg.sender] == address(0) && isExist[_refAddress]) {
            referral[msg.sender] = _refAddress;
            referralCount[_refAddress] += 1;
            users[_refAddress].refReward +=
                (numberOfTokens * RefRewardPercent) /
                percentDivider;
        }
        soldToken = soldToken + numberOfTokens;
        phases[currentStage].tokenSold += numberOfTokens;
        amountRaisedUSDT = amountRaisedUSDT + amount;

        users[msg.sender].usdt_balance += amount;
        if (!_isStake) {
            users[msg.sender].claimAbleAmount =
                users[msg.sender].claimAbleAmount +
                numberOfTokens;
        } else {
            stake(numberOfTokens);
            if (users[msg.sender].stakeCount == 0) {
                totalStaker++;
            }
        }
        users[msg.sender].purchasedToken += numberOfTokens;
        emit BuyTokenUSDT(msg.sender, amount, numberOfTokens);
    }

    // to buy token during preSale time with USDC => for web3 use
    function buyTokenUSDC(
        uint256 amount,
        bool _isStake,
        address _refAddress
    ) public {
        require(_refAddress != msg.sender, "cant ref yourself");
        require(!isPresaleEnded, "Presale ended!");
        require(presaleStatus, " Presale is Paused, check back later");
        if (!isExist[msg.sender]) {
            isExist[msg.sender] = true;
            UsersAddresses.push(msg.sender);
        }
        USDC.transferFrom(msg.sender, address(this), amount);

        uint256 numberOfTokens;
        numberOfTokens = usdtToToken(amount, currentStage);
        require(
            phases[currentStage].tokenSold + numberOfTokens <=
                phases[currentStage].tokensToSell,
            "Phase Limit Reached"
        );
        if (referral[msg.sender] == address(0) && isExist[_refAddress]) {
            referral[msg.sender] = _refAddress;
            referralCount[_refAddress] += 1;
            users[_refAddress].refReward +=
                (numberOfTokens * RefRewardPercent) /
                percentDivider;
        }
        soldToken = soldToken + numberOfTokens;
        phases[currentStage].tokenSold += numberOfTokens;
        amountRaisedUSDC = amountRaisedUSDC + amount;

        users[msg.sender].usdc_balance += amount;

        if (!_isStake) {
            users[msg.sender].claimAbleAmount =
                users[msg.sender].claimAbleAmount +
                numberOfTokens;
        } else {
            stake(numberOfTokens);
            if (users[msg.sender].stakeCount == 0) {
                totalStaker++;
            }
        }
        users[msg.sender].purchasedToken += numberOfTokens;
        emit BuyTokenUSDT(msg.sender, amount, numberOfTokens);
    }

    function stake(uint256 _amount) internal {
        User storage user = users[msg.sender];
        StakeData storage userStake = userStakes[msg.sender][user.stakeCount];
        userStake.stakedTokens = _amount;
        userStake.stakeTime = block.timestamp;
        user.stakeCount++;
        totalStakedAmount += _amount;
    }

    function unStake(uint256 _index) public {
        User storage user = users[msg.sender];
        StakeData storage userStake = userStakes[msg.sender][_index];
        require(isPresaleEnded, "Presale has not ended yet");
        require(user.stakeCount > 0, "there is no stake");
        require(userStake.stakeTime > 0, "No stake on this index");
        require(!userStake.isUnstake, "unstaked already");
        uint256 _reward = calculateReward(msg.sender, _index);
        if (_reward > 0) {
            mainToken.transfer(msg.sender, _reward);
            userStake.claimedReward += _reward;
            distributedReward += _reward;
        }
        mainToken.transfer(msg.sender, userStake.stakedTokens);
        userStake.claimedTokens = userStake.stakedTokens;
        userStake.unstakeTime = block.timestamp;
        userStake.isUnstake = true;
        totalStakedAmount -= userStake.stakedTokens;
        emit ClaimToken(msg.sender, userStake.stakedTokens);
        emit ClaimToken(msg.sender, _reward);
    }

    function claimTokens() external {
        require(isPresaleEnded, "Presale has not ended yet");
        require(isExist[msg.sender], "User don't exist");
        User storage user = users[msg.sender];
        uint256 claimAmount = user.claimAbleAmount;
        require(claimAmount > 0, "No tokens to claim");
        user.claimedAmount += claimAmount;
        mainToken.transfer(msg.sender, claimAmount);
        user.claimAbleAmount = 0;
        emit ClaimToken(msg.sender, claimAmount);
    }

    function claimRefReward() public {
        require(isPresaleEnded, "Presale has not ended yet");
        require(isExist[msg.sender], "User don't exist");
        User storage user = users[msg.sender];
        uint256 claimAmount = user.refReward;
        require(claimAmount > 0, "No tokens to claim");
        user.refReward = 0;
        mainToken.transfer(msg.sender, claimAmount);
        emit ClaimToken(msg.sender, claimAmount);
    }

    function calculateReward(address _user, uint256 _index)
        public
        view
        returns (uint256 _reward)
    {
        StakeData memory userStake = userStakes[_user][_index];
        uint256 rewardDuration = block.timestamp - (userStake.stakeTime);
        uint256 reward = (userStake.stakedTokens * (rewardDuration) * APY) /
            (percentDivider * (year));
        if (reward + distributedReward < distrubuteAbleReward) {
            _reward = reward;
        } else {
            _reward;
        }
    }

    function getPhaseDetail(uint256 phaseInd)
        public
        view
        returns (uint256 priceUsd)
    {
        Phase memory phase = phases[phaseInd];
        return (phase.tokenPerUsdPrice);
    }

    function setPresaleStatus(bool _status) external onlyOwner {
        presaleStatus = _status;
    }

    function endPresale() external onlyOwner {
        require(!isPresaleEnded, "Already ended");
        isPresaleEnded = true;
    }

    // to check number of token for given ETH
    function nativeToToken(uint256 _amount, uint256 phaseId)
        public
        view
        returns (uint256)
    {
        uint256 ethToUsd = (_amount * (getLatestPrice())) / (1 ether);
        uint256 numberOfTokens = (ethToUsd * getPhaseDetail(phaseId)) / (1e8);
        return numberOfTokens;
    }

    // to check number of token for given usdt
    function usdtToToken(uint256 _amount, uint256 phaseId)
        public
        view
        returns (uint256)
    {
        uint256 numberOfTokens = (_amount * getPhaseDetail(phaseId)) / (1e6);
        return numberOfTokens;
    }

    // change tokens
    function updateToken(address _token) external onlyOwner {
        mainToken = IERC20(_token);
    }

    function whitelistAddresses(
        address[] memory _addresses,
        uint256[] memory _tokenAmount,
        uint256[] memory _refAmount
    ) external onlyOwner {
        require(
            _addresses.length == _tokenAmount.length,
            "Addresses and amounts must be equal"
        );

        for (uint256 i = 0; i < _addresses.length; i++) {
            users[_addresses[i]].claimAbleAmount += _tokenAmount[i];
            users[_addresses[i]].refReward += _refAmount[i];
        }
    }

    // to withdraw funds for liquidity
    function initiateTransfer(uint256 _value) external onlyOwner {
        fundReceiver.transfer(_value);
    }

    function totalUsersCount() external view returns (uint256) {
        return UsersAddresses.length;
    }

    // to withdraw funds for liquidity
    function changeFundReciever(address _addr) external onlyOwner {
        fundReceiver = payable(_addr);
    }

    // to withdraw funds for liquidity
    function updatePriceFeed(AggregatorV3Interface _priceFeed)
        external
        onlyOwner
    {
        priceFeed = _priceFeed;
    }

    // funtion is used to change the stage of presale
    function setCurrentStage(uint256 _stageNum) public onlyOwner {
        currentStage = _stageNum;
    }

    // to withdraw out tokens
    function transferTokens(IERC20 token, uint256 _value) external onlyOwner {
        token.transfer(fundReceiver, _value);
    }
}