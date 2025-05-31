// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
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
}

interface IBeaconUpgradeable {

    function implementation() external view returns (address);
}

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library CountersUpgradeable {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
    }

    function __ERC1967Upgrade_init_unchained() internal initializer {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallSecure(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        address oldImplementation = _getImplementation();

        // Initial upgrade and setup call
        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }

        // Perform rollback test if not already in progress
        StorageSlotUpgradeable.BooleanSlot storage rollbackTesting = StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            // Trigger rollback using upgradeTo from the new implementation
            rollbackTesting.value = true;
            _functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            // Check rollback was effective
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            // Finally reset to the new implementation and log the upgrade
            _upgradeTo(newImplementation);
        }
    }

    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event AdminChanged(address previousAdmin, address newAdmin);

    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    event BeaconUpgraded(address indexed beacon);

    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
    uint256[50] private __gap;
}

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

abstract contract UUPSUpgradeable is Initializable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
        __UUPSUpgradeable_init_unchained();
    }

    function __UUPSUpgradeable_init_unchained() internal initializer {
    }

    function upgradeTo(address newImplementation) external virtual {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, bytes(""), false);
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, data, true);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual;
    uint256[50] private __gap;
}

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

contract NFTStaking is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter stakingItemIds;

    address stakingTokenAddress;

    struct StakingItem {
        address nftContractAddress;
        address account;
        uint amount;
        uint startTime;
        bool isWithdrawnWithoutMinting;
        bool isClaimed;
    }

    mapping(uint => StakingItem) idToStakingItem;
    mapping(address => uint) collectionMaxStaking;

    function initialize() initializer public {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImplementation) internal onlyOwner override {}

    function version() pure public virtual returns (string memory) {
        return "v1";
    }

    function getStakingItemIdHeight() public view virtual returns (uint) {
        return stakingItemIds.current();
    }

    function setFirstStakingItemAsEmpty() public onlyOwner virtual {
        uint stakingItemId = stakingItemIds.current();
        stakingItemIds.increment();

        idToStakingItem[stakingItemId] = StakingItem(
            address(0),
            address(0),
            0,
            0,
            false,
            false
        );
    }

    function setStakingTokenAddress(address payable _stakingTokenAddress) public onlyOwner virtual {
        stakingTokenAddress = _stakingTokenAddress;
    }

    function getStakingTokenAddress() public view virtual returns (address) {
        return stakingTokenAddress;
    }

    function stake(address _nftContractAddress, uint amount) public virtual {
        uint currentStakingItemId = getCurrentStakingItemId(msg.sender, _nftContractAddress);
        require(currentStakingItemId == 0, "You have a current staking item. You can only stake once for every address.");

        uint mintedStakingItemId = getMintedStakingItemId(msg.sender, _nftContractAddress);
        require(mintedStakingItemId == 0, "You have already staked and minted with this address. Use another account to stake a new one.");

        IERC20Upgradeable stakingTokenContract = IERC20Upgradeable(stakingTokenAddress);
        uint allowance = stakingTokenContract.allowance(msg.sender, address(this));

        require(amount >= allowance, "Please approve the staking contract with the right staking amount.");

        stakingTokenContract.transferFrom(msg.sender, address(this), amount);

        uint stakingItemId = stakingItemIds.current();
        stakingItemIds.increment();

        idToStakingItem[stakingItemId] = StakingItem(
            _nftContractAddress,
            msg.sender,
            amount,
            block.timestamp,
            false,
            false
        );
    }

    function unstake(uint _idToStakingItem) public virtual {
        require(msg.sender == idToStakingItem[_idToStakingItem].account, "Staking item doesn't belong to this account.");
        idToStakingItem[_idToStakingItem].isWithdrawnWithoutMinting = true;

        IERC20Upgradeable stakingTokenContract = IERC20Upgradeable(stakingTokenAddress);
        stakingTokenContract.transfer(idToStakingItem[_idToStakingItem].account, idToStakingItem[_idToStakingItem].amount);
    }

    function setCollectionMaxStaking(address nftContractAddress, uint quantity) public onlyOwner virtual {
        collectionMaxStaking[nftContractAddress] = quantity;
    }

    function setStakingItemAsClaimed(uint _idToStakingItem) public virtual {
        require(collectionMaxStaking[msg.sender] > 0, "Collection is not in the whitelist.");

        idToStakingItem[_idToStakingItem].isClaimed = true;

        IERC20Upgradeable stakingTokenContract = IERC20Upgradeable(stakingTokenAddress);
        stakingTokenContract.transfer(idToStakingItem[_idToStakingItem].account, idToStakingItem[_idToStakingItem].amount);
    }

    function getStakingItemNftContractAddress(uint stakingItemId) public view virtual returns (address) {
        return idToStakingItem[stakingItemId].nftContractAddress;
    }

    function getStakingItem(uint stakingItemId) public view virtual returns (StakingItem memory) {
        return idToStakingItem[stakingItemId];
    }

    function getStakingItemAccount(uint stakingItemId) public view virtual returns (address) {
        return idToStakingItem[stakingItemId].account;
    }

    function getStakingItemAmount(uint stakingItemId) public view virtual returns (uint) {
        return idToStakingItem[stakingItemId].amount;
    }

    function getStakingItemStartTime(uint stakingItemId) public view virtual returns (uint) {
        return idToStakingItem[stakingItemId].startTime;
    }

    function getStakingItemIsWithdrawnWithoutMinting(uint stakingItemId) public view virtual returns (bool) {
        return idToStakingItem[stakingItemId].isWithdrawnWithoutMinting;
    }

    function getStakingItemIsClaimed(uint stakingItemId) public view virtual returns (bool) {
        return idToStakingItem[stakingItemId].isClaimed;
    }

    function getCurrentStakingItemId(address account, address nftContractAddress) public view virtual returns (uint) {
        uint currentStakingItemId;

        for(uint i = 0; i < stakingItemIds.current(); i++) {
            if(idToStakingItem[i].account == account && idToStakingItem[i].nftContractAddress == nftContractAddress && !idToStakingItem[i].isWithdrawnWithoutMinting && !idToStakingItem[i].isClaimed) {
                currentStakingItemId = i;
            }
        }

        return currentStakingItemId;
    }

    function getMintedStakingItemId(address account, address nftContractAddress) public view virtual returns (uint) {
        uint mintedStakingItemId;

        for(uint i = 0; i < stakingItemIds.current(); i++) {
            if(idToStakingItem[i].account == account && idToStakingItem[i].nftContractAddress == nftContractAddress && idToStakingItem[i].isClaimed) {
                mintedStakingItemId = i;
            }
        }

        return mintedStakingItemId;
    }

    function getStakingItemId(address account, address nftContractAddress) public view virtual returns (uint) {
        uint currentStakingItemId;
        for(uint i = 0; i < stakingItemIds.current(); i++) {
            if(idToStakingItem[i].account == account && idToStakingItem[i].nftContractAddress == nftContractAddress && !idToStakingItem[i].isWithdrawnWithoutMinting && !idToStakingItem[i].isClaimed) {
                currentStakingItemId = i;
            }
        }

        return currentStakingItemId;
    }

    function totalDeposits(address nftContractAddress) public view virtual returns (uint) {
        uint _totalDeposits = 0;

        for(uint i = 0; i < stakingItemIds.current(); i++) {
            if(idToStakingItem[i].nftContractAddress == nftContractAddress && !idToStakingItem[i].isWithdrawnWithoutMinting && !idToStakingItem[i].isClaimed) {
                _totalDeposits += idToStakingItem[i].amount;
            }
        }

        return _totalDeposits;
    }

    function totalStakes(address nftContractAddress) public view virtual returns (uint) {
        uint _totalStakes = 0;

        for(uint i = 0; i < stakingItemIds.current(); i++) {
            if(idToStakingItem[i].nftContractAddress == nftContractAddress && !idToStakingItem[i].isWithdrawnWithoutMinting) {
                _totalStakes++;
            }
        }

        return _totalStakes;
    }

    function remainingRewards(address nftContractAddress) public view virtual returns (uint) {
        return collectionMaxStaking[nftContractAddress] - totalStakes(nftContractAddress);
    }
}

