/**
 *Submitted for verification at polygonscan.com on 2022-04-08
*/

//SPDX-License-Identifier: GPL-3.0+

pragma solidity 0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract GoToken
{
    function approve(address, uint256) external returns (bool) {}
    function balanceOf(address) external view returns (uint256) {}
}

contract WingsToken
{
    function approve(address, uint256) external returns (bool) {}
    function balanceOf(address) external view returns (uint256) {}
}

contract EthereumToken
{
    function approve(address, uint256) external returns (bool) {}
    function balanceOf(address) external view returns (uint256) {}
    function transfer(address, uint256) external returns (bool) {}
    function transferFrom(address, address, uint256) external returns (bool) {}
}

contract PearlNote
{
	function balanceOf(address) external view returns (uint256) {}
	function tokenOfOwnerByIndex(address, uint256) external view returns (uint256) {}
}

contract JetSwapRouter
{
    function swapExactTokensForTokens(
                 uint,
                 uint,
                 address[] calldata,
                 address,
                 uint
             ) external virtual returns (uint[] memory) {}
}

contract GoFarm
{
    function donate(uint256) external {}
}

contract MasterChef
{
    function lock(address noteAddr, uint256 amount) public {}
    function claimReward(address noteAddr, uint256 tokenId) public {}
    function extendLock(address noteAddr, uint256 tokenId, uint256 amount) public {}
}

contract Vault is IERC721Receiver
{
    struct UserData 
    { 
        uint256 stakingDeposit;
        uint256 stakingBlock;
    }
    
    string  private _name = "\x56\x61\x75\x6c\x74";
    uint256 private _swapWaitingBlocks = 3600;
    uint256 private _depositFee = 10; //Deposit fee: 10%
    uint256 private _performanceFee = 1; //Performance fee: 1%
    uint256 private _autoCompoundFee = 33; //Auto-compound fee: 33%
    uint256 private _harvestCooldownBlocks = 28800;
    uint256 private _stakingBlockRange = 864000;
    uint256 private _decimalFixMultiplier = 1000000000000000000;
    uint256 private _updateCooldownBlocks = 1200;

    uint256 private _lastUpdate;
    uint256 private _totalStakingDeposits;
    
    mapping(address => UserData) private _userData;
    
    address private _goTokenAddress = 0x98D23ADA1Da268Bc10E2e0d1585C47971C4B89DD;
    address private _wingsTokenAddress = 0x52A7F40BB6e9BD9183071cdBdd3A977D713F2e34; //PEARL
    address private _ethereumTokenAddress = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619; 
    address private _maticTokenAddress = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    address private _jetSwapRouterAddress = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff; //QuickSwap
    address private _goFarmAddress = 0x05C1EC18455dB5edcf1389B8fC215d56B42A15C0;
    address private _masterChefAddress = 0xc67aBdA25D0421FE9Dc1afd64183b179A426a256; //OtterLake
    address private _pearlNoteAddress = 0x931f0857130bcd221D30C06d80aD98affe3Aa526;    
        
    GoToken       private _goToken;
    WingsToken    private _wingsToken;
    EthereumToken private _ethereumToken;
    JetSwapRouter private _jetSwapRouter;
    GoFarm        private _goFarm;
    MasterChef    private _masterChef;
    PearlNote     private _pearlNote;
    
    address[] private _ethereumWingsPair;
    address[] private _wingsGoPair;
    address[] private _wingsEthereumPair;
    
    bool private _isFirstDeposit = true;

    uint256 private _tokenId;
   
    constructor()
    {
        //Initialize contracts
        _goToken = GoToken(_goTokenAddress);
        _wingsToken = WingsToken(_wingsTokenAddress);
        _ethereumToken = EthereumToken(_ethereumTokenAddress);
        _jetSwapRouter = JetSwapRouter(_jetSwapRouterAddress);
        _goFarm = GoFarm(_goFarmAddress);
        _masterChef = MasterChef(_masterChefAddress);
        _pearlNote = PearlNote(_pearlNoteAddress);
        
        //Initialize trading pairs
        _ethereumWingsPair = [_ethereumTokenAddress, _maticTokenAddress, _wingsTokenAddress];
        _wingsGoPair       = [_wingsTokenAddress, _maticTokenAddress, _goTokenAddress];
        _wingsEthereumPair = [_wingsTokenAddress, _maticTokenAddress, _ethereumTokenAddress];
    }
    
    function getName() external view returns (string memory)
    {
        return _name;
    }
    
    function getRewardsFund() public view returns (uint256)
    {
        return _ethereumToken.balanceOf(address(this)) - _totalStakingDeposits;
    }
    
    function getTotalStakingDeposits() external view returns (uint256)
    {
        return _totalStakingDeposits;
    }
    
    function getDepositFee() external view returns (uint256)
    {
        return _depositFee;
    }
    
    function getHarvestCooldownBlocks() external view returns (uint256)
    {
        return _harvestCooldownBlocks;
    }
    
    function getStakingBlockRange() external view returns (uint256)
    {
        return _stakingBlockRange;
    } 
    
    function buyGoToken(uint256 wingsAmount) private
    {
        require(wingsAmount > 0, "Vault: Wings amount cannot be 0");
    
        address[] memory wingsGoPairMemory = _wingsGoPair;
        
        //Swap Wings for Gō
        _wingsToken.approve(_jetSwapRouterAddress, wingsAmount);
        _jetSwapRouter.swapExactTokensForTokens(wingsAmount, 0, wingsGoPairMemory, address(this), block.timestamp + _swapWaitingBlocks);
        
        //Donate to Gō farm
        uint256 goAmount = _goToken.balanceOf(address(this));
        
        if (goAmount > 0)
        {
            _goToken.approve(_goFarmAddress, goAmount);
            _goFarm.donate(goAmount);
        }
    }
    
    function updateRewardsFund() private
    {
        uint256 elapsedBlocks = block.number - _lastUpdate;
    
        if (elapsedBlocks > _updateCooldownBlocks)
        {
            address[] memory wingsEthereumPairMemory = _wingsEthereumPair;
                
            //Harvest pending Wings
            _masterChef.claimReward(_pearlNoteAddress, _tokenId);
            
            uint256 wingsAmount = _wingsToken.balanceOf(address(this));
            
            uint256 performanceFeeAmount = wingsAmount * _performanceFee / 100;
            uint256 autoCompoundFeeAmount = wingsAmount * _autoCompoundFee / 100;
            
            //Buy Gō and donate it to Gō farm
            if (performanceFeeAmount > 0)
                buyGoToken(performanceFeeAmount);
                
            //Auto-compound
            if (autoCompoundFeeAmount > 0)
            {
                _wingsToken.approve(_masterChefAddress, autoCompoundFeeAmount);
                _masterChef.extendLock(_pearlNoteAddress, _tokenId, autoCompoundFeeAmount);
            }
            
            //Swap Wings for Ethereum
            wingsAmount = _wingsToken.balanceOf(address(this));
            
            if (wingsAmount > 0)
            {
                _wingsToken.approve(_jetSwapRouterAddress, wingsAmount);
                _jetSwapRouter.swapExactTokensForTokens(wingsAmount, 0, wingsEthereumPairMemory, address(this), block.timestamp + _swapWaitingBlocks);
            }
            
            _lastUpdate = block.number;
        }
    }
    
    function deposit(uint256 amount) external 
    {
        require(amount >= 100, "Vault: minimum deposit amount: 100");
        
        _ethereumToken.transferFrom(msg.sender, address(this), amount);
        
        uint256 fee = amount * _depositFee / 100;
        uint256 netAmount = amount - fee;
        
        //Update Vault data
        _userData[msg.sender].stakingDeposit += netAmount;
        _userData[msg.sender].stakingBlock = block.number;
        
        _totalStakingDeposits += netAmount;
        
        //Swap deposit fee for Wings
        address[] memory ethereumWingsPairMemory = _ethereumWingsPair;
        
        _ethereumToken.approve(_jetSwapRouterAddress, fee);
        _jetSwapRouter.swapExactTokensForTokens(fee, 0, ethereumWingsPairMemory, address(this), block.timestamp + _swapWaitingBlocks);
        
        //Deposit Wings on JetSwap Pool
        uint256 wingsAmount = _wingsToken.balanceOf(address(this));
            
        if (wingsAmount > 0)
        {
            _wingsToken.approve(_masterChefAddress, wingsAmount);
            
            if (_isFirstDeposit)
            {
            	//Create note
            	_masterChef.lock(_pearlNoteAddress, wingsAmount);
            	            	
            	//Get token id
            	uint256 index = _pearlNote.balanceOf(address(this)) - 1;
            	_tokenId = _pearlNote.tokenOfOwnerByIndex(address(this), index);
            	
            	_isFirstDeposit = false;
            }
			else            	
            	_masterChef.extendLock(_pearlNoteAddress, _tokenId, wingsAmount);
        }
        
        //Update rewards fund
        updateRewardsFund();
    }

    function withdraw() external
    {
        uint256 blocksStaking = computeBlocksStaking();

        if (blocksStaking > _harvestCooldownBlocks)
            harvest();
        
        emergencyWithdraw();
    }
    
    function emergencyWithdraw() public
    {
        uint256 stakingDeposit = _userData[msg.sender].stakingDeposit;
        
        require(stakingDeposit > 0, "Vault: withdraw amount cannot be 0");
        
        _userData[msg.sender].stakingDeposit = 0;
 
        _ethereumToken.transfer(msg.sender, stakingDeposit);
        
        _totalStakingDeposits -= stakingDeposit;
    }

    function computeUserReward() public view returns (uint256)
    {
        require(_userData[msg.sender].stakingDeposit > 0, "Vault: staking deposit is 0");
    
        uint256 rewardsFund = getRewardsFund();
        
        uint256 userReward = 0;
    
        uint256 blocksStaking = computeBlocksStaking();
        
        if (blocksStaking > 0)
	    {
	        uint256 userBlockRatio = _decimalFixMultiplier;
	    
	        if (blocksStaking < _stakingBlockRange)
	            userBlockRatio = blocksStaking * _decimalFixMultiplier / _stakingBlockRange; 
		    
		    uint256 userDepositRatio = _decimalFixMultiplier;
		    
		    if (_userData[msg.sender].stakingDeposit < _totalStakingDeposits)
		        userDepositRatio = _userData[msg.sender].stakingDeposit * _decimalFixMultiplier / _totalStakingDeposits;
		    
		    uint256 totalRatio = userBlockRatio * userDepositRatio / _decimalFixMultiplier;
		    
		    userReward = totalRatio * rewardsFund / _decimalFixMultiplier;
		}
		
		return userReward;
    }

    function harvest() public 
    {
        require(_userData[msg.sender].stakingDeposit > 0, "Vault: staking deposit is 0");

        uint256 blocksStaking = computeBlocksStaking();

        require(blocksStaking > _harvestCooldownBlocks, "Vault: harvest cooldown in progress");
    
        updateRewardsFund();
        
        uint256 userReward = computeUserReward();
        
        _userData[msg.sender].stakingBlock = block.number;

        _ethereumToken.transfer(msg.sender, userReward);
    }
    
    function getStakingDeposit() external view returns (uint256)
    {
        UserData memory userData = _userData[msg.sender];
    
        return (userData.stakingDeposit);
    }
    
    function getStakingBlock() external view returns (uint256)
    {
        UserData memory userData = _userData[msg.sender];
    
        return (userData.stakingBlock);
    }
    
    function computeBlocksStaking() public view returns (uint256)
    {
        uint256 blocksStaking = 0;
        
        if (_userData[msg.sender].stakingDeposit > 0)
            blocksStaking = block.number - _userData[msg.sender].stakingBlock;
        
        return blocksStaking;
    }

	function onERC721Received(address, address, uint256, bytes calldata) external override pure returns(bytes4) 
	{
		return this.onERC721Received.selector;
	}  
}