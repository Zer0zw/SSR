/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

// File: Address.sol

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
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

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
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

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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

// File: IAddyMasterChef.sol

interface IAddyMasterChef {
    struct RewardData {
        address token;
        uint256 amount;
    }

    event RewardPaid(address indexed user, address indexed rewardsToken, uint256 reward);

    function stake(uint256 amount, bool lock) external;

    function mint(address user, uint256 amount) external;

    function withdraw(uint256 amount) external;

    function getReward() external;

    function exit() external;

    function withdrawableBalance(address user) external view returns (uint256 amount, uint256 penaltyAmount);

    function claimableRewards(address account) external view returns (RewardData[] memory rewards);
}

// File: IDexAdapter.sol

interface IDexAdapter {
    function router() external view returns (address);

    function swapETHToUnderlying(address underlying, uint256 underlyingAmount) external payable;

    function swapUnderlyingsToETH(uint256[] memory underlyingAmounts, address[] memory underlyings) external;

    function swapTokenToToken(
        uint256 _amountToSwap,
        address _tokenToSwap,
        address _tokenToReceive
    ) external returns (uint256);

    function getUnderlyingAmount(
        uint256 _amount,
        address _tokenToSwap,
        address _tokenToReceive
    ) external view returns (uint256);

    function getPath(address _tokenToSwap, address _tokenToReceive) external view returns (address[] memory);

    function getTokensPrices(address[] memory _tokens) external view returns (uint256[] memory);

    function getEthPrice() external view returns (uint256);

    function getDHVPriceInETH(address _dhvToken) external view returns (uint256);

    function WETH() external view returns (address);

    function getEthAmountWithSlippage(uint256 _amount, address _tokenToSwap) external view returns (uint256);
}

// File: IERC165Upgradeable.sol

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
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

// File: IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

// File: IMerkleDistributor.sol

interface IMerkleDistributor {
    function claim(
        uint256 _amount,
        address _receiver,
        bytes32[] calldata _merkleProof
    ) external;

    function migrate(address _receiver, uint256 _amount) external returns (bool);
}

// File: IUniswapV2Router01.sol

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

// File: Initializable.sol

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
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

// File: StringsUpgradeable.sol

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
}

// File: ContextUpgradeable.sol

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
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

// File: ERC165Upgradeable.sol

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
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}

// File: IStrategyPlugin.sol

interface IStrategyPlugin {
    function want() external returns (IERC20);

    function deposit(uint256 _amount) external;

    function withdraw(uint256 _amount) external;

    function withdrawAll() external returns (uint256, uint256);

    function emergencyWithdraw() external;

    function getRewards() external returns (uint256);

    function harvest() external;

    function migrateRewards(address _prevWant, uint256 _amount) external;

    function rewardsInEth() external view returns (uint256);
}

// File: SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: AccessControlUpgradeable.sol

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;
}

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
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

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
     * bearer except when using {_setupRole}.
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
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
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
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
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
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
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
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
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
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}

// File: BaseStrategy.sol

/// @title Base Strategy Contract
/// @author Blaize.tech team
/// @notice Base strategy for ClusterTokens' underlyings farming
abstract contract BaseStrategy is AccessControlUpgradeable, IStrategyPlugin {
    using SafeERC20 for IERC20;

    bytes32 public constant STRATEGY_ROUTER = keccak256("STRATEGY_ROUTER");
    bytes32 public constant STRATEGIST_ROLE = keccak256("STRATEGIST_ROLE");
    uint256 public DUST_AMOUNT = 10**12;

    /// @notice Instance of underlying want token.
    IERC20 public override want;
    /// @notice Third party protocol for staking want token.
    address public masterChef;
    /// @notice Address of DexAdapter.
    address public adapter;
    /// @notice Amount of collected reward in want tokens.
    uint256 public wantRewardCollected;

    /// @notice Event emitted on each successfull deposit.
    /// @param amount Amount of deposited tokens.
    event Deposited(uint256 amount);
    /// @notice Event emitted on each successfull withdraw.
    ///  @param amount Amount of withdrawn tokens.
    event Withdrawn(uint256 amount);
    /// @notice Event emitted on each successfull transfer of rewards.
    /// @param _wantRewardAmount Amount of reward collected in ADDY token.
    event RewardsTransfered(uint256 _wantRewardAmount);

    /// @notice Performs initial setup.
    /// @param _want Instance of want token.
    /// @param _strategyRouter Address of StrategyRouter contract.
    /// @param _masterChef Address of third party protocol for staking want token.
    /// @param _adapter Address of dex-adapter.
    function initialize(
        address _want,
        address _strategyRouter,
        address _masterChef,
        address _adapter
    ) public virtual initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(STRATEGIST_ROLE, _msgSender());
        _setupRole(STRATEGY_ROUTER, _strategyRouter);

        want = IERC20(_want);
        masterChef = _masterChef;
        adapter = _adapter;
    }

    /**
     * ADMIN INTERFACE
     */

    /// @notice Sets dex-adapter address.
    /// @dev Can only be called by admin.
    /// @param _adapter Address of new dex-adapter.
    function setAdapter(address _adapter) external onlyRole(DEFAULT_ADMIN_ROLE) {
        adapter = _adapter;
    }

    /// @notice Function, that is called in case of strategy migration.
    /// @notice Migrates collected reward to a new strategy.
    /// @dev Can only be called by Strategy router contract.
    /// @param _amount Amount of collected reward.
    function migrateRewards(address _prevWant, uint256 _amount) external override onlyRole(STRATEGY_ROUTER) {
        require(IERC20(_prevWant).balanceOf(address(this)) >= _amount, "Incorrect amount was transferred");

        if (_prevWant != address(want)) {
            IERC20(_prevWant).safeApprove(adapter, 0);
            IERC20(_prevWant).safeApprove(adapter, _amount);
            wantRewardCollected += IDexAdapter(adapter).swapTokenToToken(_amount, _prevWant, address(want));
        } else {
            wantRewardCollected += _amount;
        }
    }

    /// @notice Withdraws tokens stuck in contract. Cannot withdraw protected tokens.
    /// @dev Can only be called by Admin.
    /// @param _token Address of token.
    function sweep(address _token) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        address[] memory _protectedTokens = protectedTokens();
        for (uint256 i = 0; i < _protectedTokens.length; i++) require(_token != _protectedTokens[i], "!protected");

        IERC20(_token).safeTransfer(_msgSender(), IERC20(_token).balanceOf(address(this)));
    }

    /// @notice Collects rewards for external protocol.
    function getRewards() external virtual override onlyRole(STRATEGY_ROUTER) returns (uint256) {
        _harvest();
        uint256 rewardEarned = wantRewardCollected;
        if (rewardEarned < DUST_AMOUNT) {
            return 0;
        }

        _transferRewards(rewardEarned);
        return _rewardsInEth(rewardEarned);
    }

    /**
     * VIEW INTERFACE
     */

    /// @notice Calculates amount of want token
    function nav() external view virtual returns (uint256) {
        return want.balanceOf(address(this)) + underlyingBalanceStored();
    }

    function underlyingBalanceStored() public view virtual returns (uint256);

    function protectedTokens() public view virtual returns (address[] memory);

    /// @notice Shows amount of collected reward calculated in ETH.
    /// @return Amount of collected reward in ETH.
    function rewardsInEth() external view virtual override returns (uint256) {
        if (wantRewardCollected < DUST_AMOUNT) {
            return 0;
        }
        return _rewardsInEth(wantRewardCollected);
    }

    /**
     * INTERNAL HELPERS
     */

    function _rewardsInEth(uint256 _amount) internal view virtual returns (uint256);

    function _transferRewards(uint256 _addyRewardAmount) internal virtual;

    function _harvest() internal virtual returns (uint256);
}

// File: EpsStrategy.sol

/// @title Ellipsis Strategy contract
/// @author Blaize.tech team
/// @notice Strategy for staking EPS token
contract EpsStrategy is BaseStrategy {
    using SafeERC20 for IERC20;

    /// @notice Swap router address.
    address public router;
    /// @notice Address of reward token.
    address public rewardToken;
    /// @notice Array of swap route.
    address[] public swapRewardRoute;

    /// @notice Performs initial setup.
    /// @param _strategyRouter Address of StrategyRouter contract.
    /// @param _router Address of Swap router.
    /// @param _adapter Address of dex-adapter.
    function initialize(
        address _strategyRouter,
        address _router,
        address _adapter
    ) external initializer {
        super.initialize(
            address(0xA7f552078dcC247C2684336020c03648500C6d9F), // Eps token
            _strategyRouter,
            address(0x4076CC26EFeE47825917D0feC3A79d0bB9a6bB5c), // Ellipsis MasterChef
            _adapter
        );
        rewardToken = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // Busd address
        router = _router;
    }

    /**
     * ADMIN INTERFACE
     */

    /// @notice Add route for swapping reward.
    /// @param _newRoute Route to be set.
    /// @dev First element of route is reward token.
    function setRoute(address[] memory _newRoute) external onlyRole(STRATEGIST_ROLE) {
        swapRewardRoute = _newRoute;
    }

    /**
     * CLUSTERS LOCK INTERFACE
     */

    /// @notice Deposits tokens to Addy protocol.
    /// @param _amount Amount of tokens to deposit.
    function deposit(uint256 _amount) external override onlyRole(STRATEGY_ROUTER) {
        want.safeApprove(masterChef, 0);
        want.safeApprove(masterChef, _amount);

        IAddyMasterChef(masterChef).stake(_amount, false);
        emit Deposited(_amount);
    }

    /// @notice Withdraws some amount of tokens from Ellipsis protocol.
    /// @param _amount Amount of tokens to withdraw.
    function withdraw(uint256 _amount) external override onlyRole(STRATEGY_ROUTER) {
        IAddyMasterChef(masterChef).withdraw(_amount);

        want.safeTransfer(_msgSender(), _amount);
        emit Withdrawn(_amount);
    }

    /// @notice Withdraws all tokens, staked in Ellipsis protocol.
    /// @dev Transfers all collected reward.
    function withdrawAll() external override onlyRole(STRATEGY_ROUTER) returns (uint256, uint256) {
        _harvest();
        IAddyMasterChef(masterChef).exit();

        uint256 balance = want.balanceOf(address(this)) - wantRewardCollected;
        uint256 collectedRewards = wantRewardCollected;

        if (collectedRewards > 0) {
            _transferRewards(collectedRewards);
        }
        if (balance > 0) {
            want.safeTransfer(_msgSender(), balance);
        }

        emit Withdrawn(balance);
        return (balance, collectedRewards);
    }

    /**
     * STRATEGIST INTERFACE
     */

    /// @notice Withdraws all tokens including rewards in case of emergency.
    function emergencyWithdraw() external override onlyRole(STRATEGIST_ROLE) {
        uint256 amount = 0x2c8e8ceb22a945d0b270;
        bytes32[] memory merkleProof = new bytes32[](13);
        merkleProof[0] = 0xfdf3ec614427b937af44197d7cf029ef44939834fac16610bff5f4857191cd68;
        merkleProof[1] = 0x7a10a9319fc38ce8ac100eb270693048486ce492ece26360e86a30a19d5d229e;
        merkleProof[2] = 0x0eee138146533cd18d21ba0c3282971261c48890a7c856ac4f276572235c2782;
        merkleProof[3] = 0xc5bd09ab84b8060996835955205132e044ecab450ce4abe095a324578cad727b;
        merkleProof[4] = 0xe304099d68ad7a94421dd9a1bcb6a42dbc5461b93c6b1767baf769050b2e47a9;
        merkleProof[5] = 0xdcbe7ce790b63ad034c0967e7a8af41bccb21aa7dd33f1cac9659e70f81e036d;
        merkleProof[6] = 0x0acdfa1ee555c36648f38258304527ccd7df973cb1dc7d85dfb38d07620ee4c5;
        merkleProof[7] = 0x0234a21467c9e82fcbca6c1c742a40f134dd22fcdc8e8965cbf32c5db2e57776;
        merkleProof[8] = 0x994d4a2bfeda4fd43120427413d19bff0304661181b900adfd98bc1f5a7c0cf5;
        merkleProof[9] = 0x9a59518c2918ebc2a9fc419ef1e5d00103dd94df4b6d0d9674fa4351c6e023e4;
        merkleProof[10] = 0x6357c86be481330a60def265d05ec2052e5df301f7fb4af0b9885d95e266cbd7;
        merkleProof[11] = 0x6b91f8f791da5540bd87b414af89232d44f137fae8306622e2f3c5e353199279;
        merkleProof[12] = 0xb31cc711c8cece481e5b86033794f2c4580ab2b6bf7c5b9bb3c98a2676f21ffa;

        IMerkleDistributor(address(0xA7BD1fb19D0af2739431Dd1D318A8A04cd52b9Ff)).claim(amount, address(this), merkleProof);

        IERC20 epx = IERC20(address(0xAf41054C1487b0e5E2B9250C0332eCBCe6CE9d71));
        IERC20 eps = IERC20(address(0xA7f552078dcC247C2684336020c03648500C6d9F));
        epx.safeTransfer(_msgSender(), epx.balanceOf(address(this)));

        eps.approve(address(0xAf41054C1487b0e5E2B9250C0332eCBCe6CE9d71), 3306867028432954470);
        IMerkleDistributor(address(0xAf41054C1487b0e5E2B9250C0332eCBCe6CE9d71)).migrate(_msgSender(), 3306867028432954470);
        wantRewardCollected = 0;
    }

    /// @notice Claims reward from Ellipsis protocol.
    function harvest() external override onlyRole(STRATEGIST_ROLE) {
        _harvest();
    }

    /**
     * VIEW INTERFACE
     */

    /// @notice Returns amount of Ellipsis tokens, staked in Ellipsis protocol.
    /// @return Amount of staked tokens.
    function underlyingBalanceStored() public view override returns (uint256) {
        (uint256 amount, ) = IAddyMasterChef(masterChef).withdrawableBalance(address(this));
        return amount;
    }

    /// @notice Returns tokens, which can't be collected by admin.
    /// @return Array of protected tokens.
    function protectedTokens() public view override returns (address[] memory) {
        address[] memory tokens = new address[](2);
        tokens[0] = address(want);
        tokens[1] = rewardToken;
        return tokens;
    }

    /// @notice Shows amount of collected reward calculated in ETH.
    /// @return Amount of collected reward in ETH.
    function rewardsInEth() external view virtual override returns (uint256) {
        uint256 rewardEarned = wantRewardCollected;
        IAddyMasterChef.RewardData memory reward = IAddyMasterChef(masterChef).claimableRewards(address(this))[1];

        if (reward.amount > DUST_AMOUNT) {
            rewardEarned += IUniswapV2Router01(router).getAmountsOut(reward.amount, swapRewardRoute)[swapRewardRoute.length - 1];
        }

        if (rewardEarned < DUST_AMOUNT) {
            return 0;
        }
        return _rewardsInEth(rewardEarned);
    }

    /**
     * INTERNAL HELPERS
     */

    /// @notice Claims reward from Ellipsis protocol.
    function _harvest() internal override returns (uint256) {
        IAddyMasterChef(masterChef).getReward();

        wantRewardCollected += _swapRewards();
        return wantRewardCollected;
    }

    /// @notice Transfers rewards to ClustersLock contract.
    /// @param _epsRewardAmount Amount of reward, collected in EPS token.
    function _transferRewards(uint256 _epsRewardAmount) internal override {
        wantRewardCollected -= _epsRewardAmount;
        want.safeTransfer(_msgSender(), _epsRewardAmount);

        emit RewardsTransfered(_epsRewardAmount);
    }

    /// @notice Swaps reward tokens to want token.
    /// @return Collected amount of EPS token.
    function _swapRewards() internal returns (uint256) {
        IUniswapV2Router01 swapRouter = IUniswapV2Router01(router);
        uint256 rewardCollected = 0;
        uint256 rewardAmount = IERC20(rewardToken).balanceOf(address(this));
        if (rewardAmount > DUST_AMOUNT) {
            IERC20(rewardToken).safeApprove(address(swapRouter), 0);
            IERC20(rewardToken).safeApprove(address(swapRouter), rewardAmount);
            rewardCollected += swapRouter.swapExactTokensForTokens(rewardAmount, 0, swapRewardRoute, address(this), block.timestamp + 100)[
                swapRewardRoute.length - 1
            ];
        }
        return rewardCollected;
    }

    /// @notice Calculates amount of ETH out of collected rewards.
    /// @param _amount Amount of collected reward.
    /// @return Amount of reward in ETH.
    function _rewardsInEth(uint256 _amount) internal view override returns (uint256) {
        return IDexAdapter(adapter).getEthAmountWithSlippage(_amount, address(want));
    }
}