/**
 *Submitted for verification at BscScan.com on 2023-01-25
*/

// Dependency file: C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\access\IAccessControl.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

// pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}


// Dependency file: C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\utils\Context.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

// pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// Dependency file: C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\utils\Strings.sol

// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

// pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}


// Dependency file: C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\utils\introspection\IERC165.sol

// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

// pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// Dependency file: C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\utils\introspection\ERC165.sol

// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

// pragma solidity ^0.8.0;

// import "C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\utils\introspection\IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


// Dependency file: C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\access\AccessControl.sol

// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

// pragma solidity ^0.8.0;

// import "C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\access\IAccessControl.sol";
// import "C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\utils\Context.sol";
// import "C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\utils\Strings.sol";
// import "C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\utils\introspection\ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}


// Dependency file: C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\token\ERC20\IERC20.sol

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

// pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


// Dependency file: C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\interfaces\IERC20.sol

// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

// pragma solidity ^0.8.0;

// import "C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\token\ERC20\IERC20.sol";


// Dependency file: C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\security\ReentrancyGuard.sol

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

// pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


// Dependency file: contracts\interfaces\IUniswapV2Router02.sol

// Uniswap V2
// pragma solidity >=0.5.0;

interface IUniswapV2Router02 {
  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;

  function factory() external pure returns (address);

  function WETH() external pure returns (address);

  function addLiquidityETH(
    address token,
    uint256 amountTokenDesired,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
    external
    payable
    returns (
      uint256 amountToken,
      uint256 amountETH,
      uint256 liquidity
    );
}


// Dependency file: contracts\interfaces\IUniswapV2Factory.sol

// Uniswap V2
// pragma solidity >=0.5.0;

interface IUniswapV2Factory {
  function createPair(address tokenA, address tokenB) external returns (address pair);
  function getPair(address tokenA, address tokenB) external view returns (address pair);
}


// Dependency file: contracts\interfaces\IUniswapV2Pair.sol

// Uniswap V2
// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

  function token0() external view returns (address);
}


// Root file: contracts\SrvStaking.sol

pragma solidity 0.8.17;

// import 'C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\access\AccessControl.sol';
// import 'C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\interfaces\IERC20.sol';
// import 'C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\security\ReentrancyGuard.sol';
// import 'contracts\interfaces\IUniswapV2Router02.sol';
// import 'contracts\interfaces\IUniswapV2Factory.sol';
// import 'contracts\interfaces\IUniswapV2Pair.sol';

/**
 * Separate the staking in weeks
 * Each week is given a certain amount of USDT
 * You can join a week by putting SRV before it starts
 * If you join during a week, you'll start earning rewards during the next one
 * If you withdraw your tokens during a week, you will earn no rewards for this period
 * What you earn is the % of your stake in the pool for this week. Adding more tokens during the week has no effect
 */

contract SrvStaking is AccessControl, ReentrancyGuard {
  bytes32 public constant ADMIN = keccak256('ADMIN');

  address public admin;
  IERC20 public srv;
  IERC20 public busd;

  uint256 public currentWeek = 0;
  uint256[] public rewardsPerWeek;
  uint256[] public totalActiveStakedPerWeek;
  uint256[] public totalInactiveStakedPerWeek;

  mapping(address => uint256) public activeStakedSrv; // SRV staked for this week & the next, per account
  mapping(address => uint256) public inactiveStakedSrv; // SRV inactive for this week but staked for the next, per account
  mapping(address => uint256) public lastStakeTime; // When the last stake was performed, per account. Used to move inactive staked SRV to active staked SRV
  mapping(address => uint256) public lastClaimTime; // When the last claim time was performed, per account. Used to know how much each account can claim
  mapping(address => uint256) public totalBusdClaimed; // Amount of BUSD claimed in total, per account

  event Staked(address account, uint256 srvAmount);
  event Withdrawn(address account, uint256 srvAmount);
  event Claimed(address account, uint256 busdAmount);

  constructor(address _srv, address _busd) {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    grantRole(ADMIN, msg.sender);
    admin = msg.sender;

    srv = IERC20(_srv);
    busd = IERC20(_busd);

    rewardsPerWeek.push(0); // Week 0 has 0 rewards
    totalActiveStakedPerWeek.push(0); // Initialize week 0 with 0 active SRV tokens staked
    totalInactiveStakedPerWeek.push(0); // Initialize week 0 with 0 inactive SRV tokens staked
  }

  receive() external payable {}

  function stake(uint256 _srvAmount) external nonReentrant {
    _stake(msg.sender, _srvAmount);
  }

  function withdraw() external nonReentrant {
    _withdraw(msg.sender);
  }

  function claim() external nonReentrant {
    _claim(msg.sender, getBusdAmountToClaim(msg.sender));
  }

  function getBusdAmountToClaim(address _account) public view returns (uint256) {
    uint256 totalUserSrvStaked = activeStakedSrv[_account] + inactiveStakedSrv[_account];
    if (totalUserSrvStaked == 0) return 0;
    if (currentWeek <= lastClaimTime[_account]) return 0;

    /**
     * If I claim on week #10 & last staked on week #4:
     * --> rewards from weeks #0-3 were already claimed --> ignore
     * --> rewards from week #4 need to be claimed using active SRV balance
     * --> rewards from weeks #5-9 need to be claimed using active & inactive SRV balances
     * --> rewards from weeks #10+ are not available yet --> ignore
     */

    uint256 rewards = 0;

    // BUSD to claim for the week of lastStakeTime
    uint256 userLastStakeTime = lastStakeTime[_account];
    if (lastClaimTime[_account] == userLastStakeTime && rewardsPerWeek[userLastStakeTime] > 0) {
      rewards += (activeStakedSrv[_account] * rewardsPerWeek[userLastStakeTime]) / totalActiveStakedPerWeek[userLastStakeTime];
    }

    // BUSD to claim for the weeks after lastStakeTime
    uint256 claimStart = lastClaimTime[_account];
    if (claimStart == lastStakeTime[_account]) claimStart++; // Ignore the week of last stake, it is dealt with above
    for (uint256 i = claimStart; i < currentWeek; i++) {
      if (rewardsPerWeek[i] > 0) rewards += (totalUserSrvStaked * rewardsPerWeek[i]) / totalActiveStakedPerWeek[i];
    }

    return rewards;
  }

  function _stake(address _account, uint256 _srvAmount) internal {
    // Safety check
    require(srv.balanceOf(_account) >= _srvAmount, 'User SRV balance is too low');

    // Send SRV from account to contract
    srv.transferFrom(_account, address(this), _srvAmount);

    // Claim BUSD if needed
    uint256 busdAmountToClaim = getBusdAmountToClaim(_account);
    _claim(_account, busdAmountToClaim);

    // Add funds to inactive balance
    inactiveStakedSrv[_account] += _srvAmount;
    totalInactiveStakedPerWeek[currentWeek] += _srvAmount;

    // Emit event
    emit Staked(_account, _srvAmount);

    // Update last stake time
    lastStakeTime[_account] = currentWeek;
  }

  function _withdraw(address _account) internal {
    // Safety check
    uint256 srvAmountToWithdraw = activeStakedSrv[_account] + inactiveStakedSrv[_account];
    require(srvAmountToWithdraw >= 0, 'User has no staked SRV to withdraw');
    require(srv.balanceOf(address(this)) >= srvAmountToWithdraw, 'Not enough SRV on contract to withdraw user staked SRV');

    // Claim BUSD if needed
    uint256 busdAmountToClaim = getBusdAmountToClaim(_account);
    _claim(_account, busdAmountToClaim);

    // Reset SRV balance
    uint256 currentActiveBalance = activeStakedSrv[_account];
    uint256 currentInactiveBalance = inactiveStakedSrv[_account];
    activeStakedSrv[_account] = 0;
    inactiveStakedSrv[_account] = 0;
    totalActiveStakedPerWeek[currentWeek] -= currentActiveBalance;
    totalInactiveStakedPerWeek[currentWeek] -= currentInactiveBalance;

    // Emit event
    emit Withdrawn(_account, srvAmountToWithdraw);

    // Send SRV from contract to account
    srv.transfer(_account, srvAmountToWithdraw);
  }

  function _claim(address _account, uint256 _busdAmount) internal {
    // If user already staked / claimed this week: return
    if (lastStakeTime[_account] == currentWeek || lastClaimTime[_account] == currentWeek) return;

    // Update last claim time
    lastClaimTime[_account] = currentWeek;

    // Move inactive balance to active balance if necessary
    uint256 oldInactiveStakedSrv = inactiveStakedSrv[_account];
    if (oldInactiveStakedSrv > 0) {
      // Remove from inactive balance
      inactiveStakedSrv[_account] = 0;
      // ? No need to update this anymore, was already updated in startNextWeekAdmin()
      // totalInactiveStakedPerWeek[currentWeek] -= oldInactiveStakedSrv;

      // Add to active balance
      activeStakedSrv[_account] += oldInactiveStakedSrv;
      // ? No need to update this anymore, was already updated in startNextWeekAdmin()
      // totalActiveStakedPerWeek[currentWeek] += oldInactiveStakedSrv;
    }
    
    // Exit if BUSD amount to claim is 0
    if (_busdAmount == 0) return;

    // Increment totalBusdClaimed
    totalBusdClaimed[_account] += _busdAmount;

    // Emit event
    emit Claimed(_account, _busdAmount);

    // Send BUSD from contract to account
    busd.transfer(_account, _busdAmount);
  }

  // Withdraws an amount of BNB stored on the contract
  function withdrawBNBAdmin(uint256 _amount) external onlyRole(ADMIN) {
    payable(msg.sender).transfer(_amount);
  }

  // Withdraws an amount of ERC20 tokens stored on the contract
  function withdrawERC20Admin(address _erc20, uint256 _amount) external onlyRole(ADMIN) {
    IERC20(_erc20).transfer(msg.sender, _amount);
  }

  function changeAdmin(address _admin) external onlyRole(ADMIN) {
    revokeRole(ADMIN, admin);
    grantRole(ADMIN, _admin);
    admin = _admin;
  }

  function revokeAdmin(address _adminToRevoke) external onlyRole(ADMIN) {
    revokeRole(ADMIN, _adminToRevoke);
  }

  function stakeAdmin(address _account, uint256 _srvAmount) external onlyRole(ADMIN) {
    _stake(_account, _srvAmount);
  }

  function withdrawAdmin(address _account) external onlyRole(ADMIN) {
    _withdraw(_account);
  }

  function claimAdmin(address _account) external onlyRole(ADMIN) {
    _claim(_account, getBusdAmountToClaim(_account));
  }

  function addWeekAdmin(uint256 _busdAmount) external onlyRole(ADMIN) {
    require(busd.balanceOf(msg.sender) >= _busdAmount, 'Not enough BUSD to add new week');

    rewardsPerWeek.push(_busdAmount);
    if (_busdAmount > 0) busd.transferFrom(msg.sender, address(this), _busdAmount);
  }

  function startNextWeekAdmin() external onlyRole(ADMIN) {
    // Next week: move inactive SRV to active SRV
    totalActiveStakedPerWeek.push(totalActiveStakedPerWeek[currentWeek] + totalInactiveStakedPerWeek[currentWeek]);

    // Next week: set inactive SRV amount to 0
    totalInactiveStakedPerWeek.push(0);

    // Increment current week
    currentWeek++;
  }

  function setWeekAdmin(uint256 _currentWeek) external onlyRole(ADMIN) {
    currentWeek = _currentWeek;
  }

  function setRewardsPerWeekAdmin(uint256 _rewards, uint256 _week) external onlyRole(ADMIN) {
    rewardsPerWeek[_week] = _rewards;
  }

  function setTotalActiveStakedPerWeekAdmin(uint256 _totalActiveStaked, uint256 _week) external onlyRole(ADMIN) {
    totalActiveStakedPerWeek[_week] = _totalActiveStaked;
  }

  function setTotalInactiveStakedPerWeekAdmin(uint256 _totalInactiveStaked, uint256 _week) external onlyRole(ADMIN) {
    totalInactiveStakedPerWeek[_week] = _totalInactiveStaked;
  }

  function setActiveStakedSrvAdmin(uint256 _activeStaked, address _account) external onlyRole(ADMIN) {
    activeStakedSrv[_account] = _activeStaked;
  }

  function setInactiveStakedSrvAdmin(uint256 _inactiveStaked, address _account) external onlyRole(ADMIN) {
    inactiveStakedSrv[_account] = _inactiveStaked;
  }
}