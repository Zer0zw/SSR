// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

interface IDelabsAdventurePassStaking {

    struct Position {
        address owner;
        uint40 lockedPeriod;
        uint40 startTime;
        uint40 lockStartTime;
        uint16 level;
    }

    struct ReadablePosition {
        uint256 tokenId;
        address owner;
        uint16 level;
        uint40 lockedPeriod;
        uint40 startTime;
        uint40 lockStartTime;
        uint40 tokenStakingTime;
        uint40 tokenLockedTimeLeft;
        bool isTokenStaked;
        bool isTokenLocked;
    }

    error SenderIsNotTokenOwner( uint256 tokenId );
    error TokenAlreadyStaked( uint256 tokenId );
    error TokenIsNotStaked( uint256 tokenId );
    error TokenHasToBeStaked( uint256 tokenId );
    error TokenIsLocked( uint256 tokenId );
    error InvalidLockedPeriod( uint40 lockedPeriod );

    event MetadataUpdate(uint256 tokenId); // eip-4906
    event TokenStaked( uint256 tokenId, uint40 lockedPeriod, uint16 previousLevel, uint16 targetLevel );
    event TokenUnstaked( uint256 tokenId, uint16 currentLevel );
    event TokenLocked( uint256 tokenId, uint40 lockedPeriod, uint16 previousLevel, uint16 targetLevel );
    event TokenLevelSet( uint256 tokenId, uint16 level );
    event AdventurePassContractChanged( address newContract );
    event StakingLevelsUpdated();

}

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

abstract contract Initializable {

    uint8 private _initialized;

    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly

            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function setApprovalForAll(address operator, bool _approved) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}

interface IDelabsAdventurePass is IERC721 {

}

abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    uint256[49] private __gap;
}

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}

contract DelabsAdventurePassStaking is IDelabsAdventurePassStaking, Initializable, PausableUpgradeable, OwnableUpgradeable {

    IDelabsAdventurePass private adventurePass;

    mapping(uint40 => uint16) public stakingLevels;
    mapping(uint256 => Position) public stakingPositions;

    constructor() {
        _disableInitializers();
    }

    // @dev Initializer as we using an upgradable contract
    function initialize(address adventurePassAddress) public initializer {
        adventurePass = IDelabsAdventurePass(adventurePassAddress);

        // inits
        __Ownable_init();
        __Pausable_init();
    }


    // -- STAKING --

    // @dev Stake and lock (optional) one token
    function stake(uint256 tokenId, uint40 lockedPeriod) external whenNotPaused {

        //if( adventurePass.ownerOf(tokenId) != msg.sender ) revert SenderIsNotTokenOwner(tokenId);
        if( lockedPeriod > 0 && stakingLevels[lockedPeriod] <= 0 ) revert InvalidLockedPeriod(lockedPeriod);

        _stake(msg.sender, tokenId, lockedPeriod);

    }

    // @dev Stake and lock (optional) one or more tokens
    function batchStake(uint256[] calldata tokenIds, uint40 lockedPeriod) external whenNotPaused {

        if( lockedPeriod > 0 && stakingLevels[lockedPeriod] <= 0 ) revert InvalidLockedPeriod(lockedPeriod);

        uint256 tokenLen = tokenIds.length;

        for(uint256 i; i < tokenLen; i++) {
            _stake(msg.sender, tokenIds[i], lockedPeriod);
        }
    }

    // @dev Unstake one token
    function unstake(uint256 tokenId) external whenNotPaused {

        _unstake(msg.sender, tokenId);

    }

    // @dev Unstake one or more tokens
    function batchUnstake(uint256[] calldata tokenIds) external whenNotPaused {

        uint256 tokenLen = tokenIds.length;

        for(uint256 i; i < tokenLen; i++) {
            _unstake(msg.sender, tokenIds[i]);
        }
    }

    // @dev Lock a staked token
    function lock(uint256 tokenId, uint40 lockedPeriod) external whenNotPaused {

        if( lockedPeriod > 0 && stakingLevels[lockedPeriod] <= 0 ) revert InvalidLockedPeriod(lockedPeriod);

        _lock(msg.sender, tokenId, lockedPeriod);

    }

    // @dev Lock one or more staked token
    function batchLock(uint256[] calldata tokenIds, uint40 lockedPeriod) external whenNotPaused {

        if( lockedPeriod > 0 && stakingLevels[lockedPeriod] <= 0 ) revert InvalidLockedPeriod(lockedPeriod);

        uint256 tokenLen = tokenIds.length;

        for(uint256 i; i < tokenLen; i++) {
            _lock(msg.sender, tokenIds[i], lockedPeriod);
        }

    }


    // -- VIEWS --

    // @dev Check if given token is staked
    function isTokenStaked(uint256 tokenId) external view returns(bool) {
        Position memory stakingPosition = stakingPositions[tokenId];
        return stakingPosition.startTime > 0;
    }

    // @dev Check if given token is locked
    function isTokenLocked(uint256 tokenId) external view returns(bool) {
        Position memory stakingPosition = stakingPositions[tokenId];
        return stakingPosition.lockedPeriod > 0;
    }

    // @dev Get staking start timestamp of given token
    function getTokenStakingStart(uint256 tokenId) external view returns(uint256) {
        Position memory stakingPosition = stakingPositions[tokenId];
        return stakingPosition.startTime;
    }

    // @dev Get lock start timestamp of given token
    function getTokenLockStart(uint256 tokenId) external view returns(uint256) {
        Position memory stakingPosition = stakingPositions[tokenId];
        return stakingPosition.lockStartTime;
    }

    // @dev Get staking time (in seconds) of given token
    function getTokenStakingTime(uint256 tokenId) external view returns(uint256) {
        Position memory stakingPosition = stakingPositions[tokenId];
        return (stakingPosition.startTime > 0 ? (block.timestamp - stakingPosition.startTime) : 0);
    }

    // @dev Get locked period (in seconds) of given token
    function getTokenLockedPeriod(uint256 tokenId) external view returns(uint256) {
        Position memory stakingPosition = stakingPositions[tokenId];
        return stakingPosition.lockedPeriod;
    }

    // @dev Get locked time left (in seconds) of given token
    function getTokenLockedTimeLeft(uint256 tokenId) external view returns(uint256) {
        Position memory stakingPosition = stakingPositions[tokenId];
        if( stakingPosition.startTime > 0 && stakingPosition.lockedPeriod > 0 && (stakingPosition.lockStartTime+stakingPosition.lockedPeriod) > block.timestamp) {
            return (stakingPosition.lockStartTime+stakingPosition.lockedPeriod) - block.timestamp;
        }
        return 0;
    }

    // @dev Get level of given token
    function getTokenLevel(uint256 tokenId) external view returns(uint64) {
        Position memory stakingPosition = stakingPositions[tokenId];
        return stakingPosition.level;
    }

    // @dev Get all staked tokenIds of given owner
    function getOwnerStakedTokenIds(address owner) public view returns(uint256[] memory) {

        unchecked {

            uint256[] memory stakedTokenIds = new uint256[](3433);
            uint256 stakedTokenBalance;
            uint256 arrCounter;
            uint256 stakedIndex;

            for(uint256 tokenId = 1; tokenId <= 3433; tokenId++) {
                Position memory stakingPosition = stakingPositions[tokenId];

                if( stakingPosition.owner == owner ) {
                    stakedTokenBalance++;
                    stakedTokenIds[arrCounter++] = tokenId;
                }
            }

            if( stakedTokenBalance > 0 ) {
                arrCounter = 0;

                uint256[] memory trimmedStakedTokenIds = new uint256[](stakedTokenBalance);

                do {
                    trimmedStakedTokenIds[arrCounter++] = stakedTokenIds[stakedIndex++];
                } while( stakedTokenIds[stakedIndex] > 0 );

                return trimmedStakedTokenIds;

            } else {

                uint256[] memory trimmedStakedTokenIds;
                return trimmedStakedTokenIds;
            }

        }

    }

    // @dev Get all staked positions of given owner
    function getOwnerStakedTokenPositions(address owner) public view returns(ReadablePosition[] memory) {

        unchecked {

            uint256[] memory stakedTokenIds = getOwnerStakedTokenIds(owner);
            ReadablePosition[] memory stakedTokenPositions = new ReadablePosition[](stakedTokenIds.length);

            for(uint256 i = 0; i < stakedTokenIds.length; i++) {
                stakedTokenPositions[i] = _convertToReadablePosition(stakedTokenIds[i], stakingPositions[stakedTokenIds[i]]);
            }

            return stakedTokenPositions;

        }

    }

    // @dev Get all staked tokenIds
    function getStakedTokenIds() public view returns(uint256[] memory) {

        unchecked {

            uint256[] memory stakedTokenIds = new uint256[](3433);
            uint256 stakedTokenBalance;
            uint256 arrCounter;
            uint256 stakedIndex;

            for(uint256 tokenId = 1; tokenId <= 3433; tokenId++) {
                Position memory stakingPosition = stakingPositions[tokenId];

                if( stakingPosition.startTime > 0 ) {
                    stakedTokenBalance++;
                    stakedTokenIds[arrCounter++] = tokenId;
                }
            }

            if( stakedTokenBalance > 0 ) {
                arrCounter = 0;

                uint256[] memory trimmedStakedTokenIds = new uint256[](stakedTokenBalance);

                do {
                    trimmedStakedTokenIds[arrCounter++] = stakedTokenIds[stakedIndex++];
                } while( stakedTokenIds[stakedIndex] > 0 );

                return trimmedStakedTokenIds;

            } else {

                uint256[] memory trimmedStakedTokenIds;
                return trimmedStakedTokenIds;
            }

        }

    }

    // @dev Get all staked positions
    function getStakedTokenPositions() public view returns(ReadablePosition[] memory) {

        unchecked {

            uint256[] memory stakedTokenIds = getStakedTokenIds();
            ReadablePosition[] memory stakedTokenPositions = new ReadablePosition[](stakedTokenIds.length);

            for(uint256 i = 0; i < stakedTokenIds.length; i++) {
                stakedTokenPositions[i] = _convertToReadablePosition(stakedTokenIds[i], stakingPositions[stakedTokenIds[i]]);
            }

            return stakedTokenPositions;

        }

    }

    // @dev Get token position by given tokenId
    function getTokenPosition(uint256 tokenId) public view returns(ReadablePosition memory) {

        unchecked {
            return _convertToReadablePosition(tokenId, stakingPositions[tokenId]);
        }

    }


    // -- INTERNAL --

    // @dev Internal stake function
    function _stake(address sender, uint256 tokenId, uint40 lockedPeriod) internal {

        Position storage stakingPosition = stakingPositions[tokenId];

        if( stakingPosition.startTime > 0 ) revert TokenAlreadyStaked(tokenId);

        uint16 previousLevel = stakingPosition.level;

        stakingPosition.owner = sender;
        stakingPosition.startTime = uint40(block.timestamp);

        if( lockedPeriod > 0 ) {
            stakingPosition.lockStartTime = uint40(block.timestamp);
            stakingPosition.lockedPeriod = lockedPeriod;
            stakingPosition.level += stakingLevels[lockedPeriod];
        }

        adventurePass.transferFrom(sender, address(this), tokenId);

        emit TokenStaked(tokenId, lockedPeriod, previousLevel, stakingPosition.level);
        emit MetadataUpdate(tokenId);
    }

    // @dev Internal unstake function
    function _unstake(address recipient, uint256 tokenId) internal {

        Position storage stakingPosition = stakingPositions[tokenId];

        if( recipient != stakingPosition.owner ) revert SenderIsNotTokenOwner(tokenId);
        if( stakingPosition.startTime <= 0 ) revert TokenIsNotStaked(tokenId);
        if( stakingPosition.lockedPeriod > 0 && (stakingPosition.lockStartTime+stakingPosition.lockedPeriod) > block.timestamp ) revert TokenIsLocked(tokenId);

        stakingPosition.owner = address(0);
        stakingPosition.startTime = 0;
        stakingPosition.lockStartTime = 0;
        stakingPosition.lockedPeriod = 0;

        adventurePass.transferFrom(address(this), recipient, tokenId);

        emit TokenUnstaked(tokenId, stakingPosition.level);
    }

    // @dev Internal force unstake function. Only use with caution [!]
    function _forceUnstake(uint256 tokenId) internal {

        Position storage stakingPosition = stakingPositions[tokenId];

        if( stakingPosition.startTime <= 0 ) revert TokenIsNotStaked(tokenId);

        address recipient = stakingPosition.owner;

        stakingPosition.owner = address(0);
        stakingPosition.startTime = 0;
        stakingPosition.lockStartTime = 0;
        stakingPosition.lockedPeriod = 0;

        adventurePass.transferFrom(address(this), recipient, tokenId);

        emit TokenUnstaked(tokenId, stakingPosition.level);
    }

    // @dev Internal lock function
    function _lock(address holder, uint256 tokenId, uint40 lockedPeriod) internal {

        Position storage stakingPosition = stakingPositions[tokenId];

        if( holder != stakingPosition.owner ) revert SenderIsNotTokenOwner(tokenId);
        if( stakingPosition.startTime <= 0 ) revert TokenHasToBeStaked(tokenId);
        if( stakingPosition.lockedPeriod > 0 && (stakingPosition.lockStartTime+stakingPosition.lockedPeriod) > block.timestamp ) revert TokenIsLocked(tokenId);

        uint16 previousLevel = stakingPosition.level;

        stakingPosition.lockStartTime = uint40(block.timestamp);
        stakingPosition.lockedPeriod = lockedPeriod;
        stakingPosition.level += stakingLevels[lockedPeriod];

        emit TokenLocked(tokenId, lockedPeriod, previousLevel, stakingPosition.level);
        emit MetadataUpdate(tokenId);
    }

    // @dev Converts a stakingPosition to a readable staking position
    function _convertToReadablePosition(uint256 tokenId, Position memory stakingPosition) internal view returns (ReadablePosition memory) {

        ReadablePosition memory readableStakingPosition;

        readableStakingPosition.tokenId = tokenId;
        readableStakingPosition.owner = stakingPosition.owner;
        readableStakingPosition.level = stakingPosition.level;
        readableStakingPosition.startTime = stakingPosition.startTime;
        readableStakingPosition.lockStartTime = stakingPosition.lockStartTime;
        readableStakingPosition.lockedPeriod = stakingPosition.lockedPeriod;
        readableStakingPosition.isTokenStaked = stakingPosition.startTime > 0;
        readableStakingPosition.isTokenLocked = stakingPosition.lockedPeriod > 0;
        readableStakingPosition.tokenStakingTime = (stakingPosition.startTime > 0 ? uint40((block.timestamp - stakingPosition.startTime)) : 0);

        if( stakingPosition.startTime > 0 && stakingPosition.lockedPeriod > 0 && (stakingPosition.lockStartTime+stakingPosition.lockedPeriod) > block.timestamp) {
            readableStakingPosition.tokenLockedTimeLeft = uint40((stakingPosition.lockStartTime+stakingPosition.lockedPeriod) - block.timestamp);
        }

        return readableStakingPosition;
    }


    // -- ADMIN --

    // @dev Force unstake one or more tokens (skips contract pause and locked periods)
    function forceBatchUnstake(uint256[] calldata tokenIds) external onlyOwner {

        uint256 tokenLen = tokenIds.length;

        for(uint256 i; i < tokenLen; i++) {
            _forceUnstake(tokenIds[i]);
        }
    }

    // @dev Set level of given token
    function setTokenLevel(uint256 tokenId, uint16 level) external onlyOwner {
        Position storage stakingPosition = stakingPositions[tokenId];
        stakingPosition.level = level;

        emit TokenLevelSet(tokenId, level);
    }

    // @dev Set the adventure pass contract address
    function setAdventurePassContract(address adventurePassAddress) external onlyOwner {
        adventurePass = IDelabsAdventurePass(adventurePassAddress);

        emit AdventurePassContractChanged(adventurePassAddress);
    }

    // @dev Set available staking levels by locked periods
    function setStakingLevels(uint40[] calldata lockedPeriods, uint16[] calldata levels) external onlyOwner {
        uint256 arrLength = lockedPeriods.length;

        for(uint256 i; i < arrLength; i++ ) {
            stakingLevels[lockedPeriods[i]] = levels[i];
        }

        emit StakingLevelsUpdated();
    }

    // @dev Upsert one staking level by locked period
    function upsertStakingLevel(uint40 lockedPeriod, uint16 level) external onlyOwner {
        stakingLevels[lockedPeriod] = level;

        emit StakingLevelsUpdated();
    }

    // @dev Pause staking
    function pauseStaking() external onlyOwner {
        _pause();
    }

    // @dev Unpause staking
    function unpauseStaking() external onlyOwner {
        _unpause();
    }

    uint256[50] private __gap;

}

