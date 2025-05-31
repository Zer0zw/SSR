/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
        // solhint-disable-next-line no-inline-assembly
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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

        // solhint-disable-next-line avoid-low-level-calls
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
}

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via _msgSender() and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IPYDEXReferral {
    function DEPOSIT_REFFERAL_COMMISSION() external view returns (uint256);

    function depositCommissionStatuses(address) external view returns (bool);

    function referralsCount(address) external view returns (uint256);

    function referrers(address) external view returns (address);

    function secondTier() external view returns (uint256);

    function thirdTier() external view returns (uint256);

    function getMyFirstLevelCommissionRate(address _user)
        external
        view
        returns (uint256);

    function recordReferral(address _user, address _referrer) external;

    function recordReferralCommission(
        address _referrer,
        uint256 _commission,
        uint256 level
    ) external;

    function getReferrer(address _user)
        external
        view
        returns (
            address firstLevel,
            address secondLevel,
            address thirdLevel
        );
}

interface IPRVNFTInterface {
    function approve(address to, uint256 tokenId) external;

    function balanceOf(address owner) external view returns (uint256);

    function getApproved(uint256 tokenId) external view returns (address);

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    function ownerOf(uint256 tokenId) external view returns (address);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function setApprovalForAll(address operator, bool approved) external;

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function tokenByIndex(uint256 index) external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256);

    function tokenTypes(uint256) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferOwnership(address newOwner) external;

    function withdraw() external;

    function flipSaleState() external;

    function withdrawAllFunds() external;

    function withdrawToken(address _token) external;
}

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

library SafeCal {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
}

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */

library SafeBEP20 {
    using Address for address;
    using SafeCal for uint256;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeBEP20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeBEP20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    function MAX_SUPPLY() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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

    function mint(address user, uint256 amount) external;

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract PYDEXGMasterChef is Ownable, ReentrancyGuard, IERC721Receiver {
    using SafeCal for uint256;
    using SafeBEP20 for IBEP20;

    IPRVNFTInterface public _privacyNFT;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 stakedNFTId;
        uint256 nftRewardDebt;

        //
        // We do some fancy math here. Basically, any point in time, the amount of PYDEXs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accPydexPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accPydexPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IBEP20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. PYDEXs to distribute per block.
        uint256 lastRewardBlock; // Last block number that PYDEXs distribution occurs.
        uint256 accPydexPerShare;
        NFTStakingInfo nftStakingInfo;
        uint16 depositFeeBP; // Deposit fee in basis points
        uint256 lpSupply;
    }

    struct NFTStakingInfo {
        uint256 accPydexPerSilverNFTShare;
        uint256 accPydexPerGoldNFTShare;
        uint256 accPydexPerDiamondNFTShare;
        uint256 tokensStakedBySilverStakers;
        uint256 tokensStakedByGoldStakers;
        uint256 tokensStakedByDiamondStakers;
        uint256 silverNFTsLocked;
        uint256 goldNFTsLocked;
        uint256 diamondNFTsLocked;
        bool isNFTStakingEnabled;
    }

    mapping(address => bool) public poolsList;

    uint256 constant TYPE_SILVER_NFT_RATIO = 200; // 20%
    uint256 constant TYPE_GOLD_NFT_RATIO = 300; // 30%
    uint256 constant TYPE_DIAMOND_NFT_RATIO = 500; // 50%
    uint256 public constant nftRewardSplitPercent = 200; // 20%

    IBEP20 public pydex;
    // Deposit Fee address
    address public feeAddress;
    address public devAddress;

    // PYDEX tokens created per block.
    uint256 public pydexPerBlock;
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when PYDEX mining starts.
    uint256 public startBlock;

    // Pydex referral contract address.
    IPYDEXReferral public pydexReferral;

    event onPoolAdded(
        uint256 _allocPoint,
        IBEP20 _lpToken,
        uint16 _depositFeeBP,
        bool _withUpdate
    );
    event onPoolSet(
        uint256 _pid,
        uint256 _allocPoint,
        uint16 _depositFeeBP,
        bool _withUpdate
    );

    event Deposit(
        address indexed user,
        uint256 indexed pid,
        uint256 amount,
        uint256 refCommission
    );
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event EmissionRateUpdated(
        address indexed caller,
        uint256 previousAmount,
        uint256 newAmount
    );
    event ReferralCommissionPaid(
        address indexed user,
        address indexed referrer,
        uint256 commissionAmount
    );

    event onSetFeeAddress(address previousAddress, address newAddress);
    event onSetDevAddress(address previousAddress, address newAddress);
    event onPayPendingReward(uint256 normalReward, uint256 nftReward);

    event onSetPydexReferral(address previousAddress, address newAddress);
    event onRewardPaid(
        address user,
        uint256 firstLevelCommission,
        uint256 secondevelCommission,
        uint256 thirdLevelCommission,
        uint256 remainingReward
    );

    event onPRVNFTSet(address previousPRVNFT, address newPRVNFT);
    event onNFTReceived(
        address operator,
        address from,
        uint256 tokenId,
        bytes data
    );
    event onNFTStaked(uint256 pid, uint256 nftID);
    event onNFTUnstaked(uint256 pid, uint256 nftID);

    constructor(
        IBEP20 _pydex,
        uint256 _startBlock,
        uint256 _pydexPerBlock
    ) {
        pydex = _pydex;
        startBlock = _startBlock;
        pydexPerBlock = _pydexPerBlock;
        feeAddress = _msgSender();
        devAddress = _msgSender();
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function setPRVNft(IPRVNFTInterface privacyNFT) public onlyOwner {
        emit onPRVNFTSet(address(_privacyNFT), address(privacyNFT));
        if (address(_privacyNFT) != address(0)) {
            require(_privacyNFT.balanceOf(address(this)) == 0, "Staked in MC");
        }
        _privacyNFT = privacyNFT;
    }

    function onERC721Received(
        address _operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        emit onNFTReceived(_operator, from, tokenId, data);
        return 0x150b7a02;
    }

    function stakeNFT(uint256 _pid, uint256 nftID) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        require(address(pool.lpToken) != address(0), "Invalid Pool");
        require(
            pool.nftStakingInfo.isNFTStakingEnabled,
            "Can't Stake in this Pool"
        );
        UserInfo storage user = userInfo[_pid][_msgSender()];

        require(user.amount > 0, "Can't Stake NFT without staking Token");
        require(user.stakedNFTId == 0, "NFT already staked");
        updatePool(_pid);
        payPendingReward(_pid);
        _privacyNFT.safeTransferFrom(_msgSender(), address(this), nftID);
        user.stakedNFTId = nftID;
        user.rewardDebt = user.amount.mul(pool.accPydexPerShare).div(1e18);

        uint256 nftType = _privacyNFT.tokenTypes(nftID);

        if (nftType == 1) {
            pool.nftStakingInfo.silverNFTsLocked = pool
                .nftStakingInfo
                .silverNFTsLocked
                .add(1);
            pool.nftStakingInfo.tokensStakedBySilverStakers = pool
                .nftStakingInfo
                .tokensStakedBySilverStakers
                .add(user.amount);
            user.nftRewardDebt = user
                .amount
                .mul(pool.nftStakingInfo.accPydexPerSilverNFTShare)
                .div(1e18);
        } else if (nftType == 2) {
            pool.nftStakingInfo.goldNFTsLocked = pool
                .nftStakingInfo
                .goldNFTsLocked
                .add(1);
            pool.nftStakingInfo.tokensStakedByGoldStakers = pool
                .nftStakingInfo
                .tokensStakedByGoldStakers
                .add(user.amount);

            user.nftRewardDebt = user
                .amount
                .mul(pool.nftStakingInfo.accPydexPerGoldNFTShare)
                .div(1e18);
        } else if (nftType == 3) {
            pool.nftStakingInfo.diamondNFTsLocked = pool
                .nftStakingInfo
                .diamondNFTsLocked
                .add(1);
            pool.nftStakingInfo.tokensStakedByDiamondStakers = pool
                .nftStakingInfo
                .tokensStakedByDiamondStakers
                .add(user.amount);

            user.nftRewardDebt = user
                .amount
                .mul(pool.nftStakingInfo.accPydexPerDiamondNFTShare)
                .div(1e18);
        } else {
            revert("Invalid NFT");
        }

        updatePool(_pid);
        emit onNFTStaked(_pid, nftID);
    }

    function unstakeNFT(uint256 _pid) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        require(address(pool.lpToken) != address(0), "Invalid Pool");
        UserInfo storage user = userInfo[_pid][_msgSender()];
        require(user.stakedNFTId != 0, "No NFT Staked");
        updatePool(_pid);
        payPendingReward(_pid);
        uint256 nftId = user.stakedNFTId;
        user.stakedNFTId = 0;
        _privacyNFT.safeTransferFrom(address(this), _msgSender(), nftId);
        uint256 nftType = _privacyNFT.tokenTypes(nftId);
        if (nftType == 1) {
            pool.nftStakingInfo.silverNFTsLocked = pool
                .nftStakingInfo
                .silverNFTsLocked
                .sub(1);
            pool.nftStakingInfo.tokensStakedBySilverStakers = pool
                .nftStakingInfo
                .tokensStakedBySilverStakers
                .sub(user.amount);
        } else if (nftType == 2) {
            pool.nftStakingInfo.goldNFTsLocked = pool
                .nftStakingInfo
                .goldNFTsLocked
                .sub(1);
            pool.nftStakingInfo.tokensStakedByGoldStakers = pool
                .nftStakingInfo
                .tokensStakedByGoldStakers
                .sub(user.amount);
        } else if (nftType == 3) {
            pool.nftStakingInfo.diamondNFTsLocked = pool
                .nftStakingInfo
                .diamondNFTsLocked
                .sub(1);
            pool.nftStakingInfo.tokensStakedByDiamondStakers = pool
                .nftStakingInfo
                .tokensStakedByDiamondStakers
                .sub(user.amount);
        } else {
            revert("Invalid NFT");
        }
        user.nftRewardDebt = 0;
        updatePool(_pid);

        emit onNFTUnstaked(_pid, nftId);
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(
        uint256 _allocPoint,
        IBEP20 _lpToken,
        bool isNFTStakingEnabled,
        uint16 _depositFeeBP,
        bool _withUpdate
    ) external onlyOwner {
        require(_depositFeeBP <= 500, "add: invalid deposit fee basis points");
        if (_withUpdate) {
            massUpdatePools();
        }
        require(poolsList[address(_lpToken)] == false, "Pool Already Added");
        uint256 lastRewardBlock = block.number > startBlock
            ? block.number
            : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);

        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accPydexPerShare: 0,
                nftStakingInfo: NFTStakingInfo({
                    accPydexPerSilverNFTShare: 0,
                    accPydexPerGoldNFTShare: 0,
                    accPydexPerDiamondNFTShare: 0,
                    tokensStakedBySilverStakers: 0,
                    tokensStakedByGoldStakers: 0,
                    tokensStakedByDiamondStakers: 0,
                    silverNFTsLocked: 0,
                    goldNFTsLocked: 0,
                    diamondNFTsLocked: 0,
                    isNFTStakingEnabled: isNFTStakingEnabled
                }),
                depositFeeBP: _depositFeeBP,
                lpSupply: 0
            })
        );

        poolsList[address(_lpToken)] = true;

        emit onPoolAdded(_allocPoint, _lpToken, _depositFeeBP, _withUpdate);
    }

    // Update the given pool's PYDEX allocation point and deposit fee. Can only be called by the owner.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool isNFTStakingEnabled,
        uint16 _depositFeeBP,
        bool _withUpdate
    ) external onlyOwner {
        require(_depositFeeBP <= 500, "set: invalid deposit fee basis points");
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].nftStakingInfo.isNFTStakingEnabled = isNFTStakingEnabled;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;
        emit onPoolSet(_pid, _allocPoint, _depositFeeBP, _withUpdate);
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        public
        pure
        returns (uint256)
    {
        return _to.sub(_from);
    }

   

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpSupply;
        if (lpSupply == 0 || pool.allocPoint == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);

        uint256 totalPydexReward = multiplier
            .mul(pydexPerBlock)
            .mul(pool.allocPoint)
            .div(totalAllocPoint);

        uint256 devRewards = totalPydexReward.div(5);
        if (
            pydex.totalSupply().add(totalPydexReward).add(devRewards) <=
            pydex.MAX_SUPPLY()
        ) {
            //  mint as normal as not at maxSupply
            pydex.mint(address(this), totalPydexReward);
            pydex.mint(devAddress, devRewards); //mint rewards for dev 5%
        } else {
            // mint the difference only to MC, update pydexReward
            totalPydexReward = pydex.MAX_SUPPLY().sub(pydex.totalSupply());
            pydex.mint(address(this), totalPydexReward);
        }

        if (totalPydexReward != 0) {
            if (pool.nftStakingInfo.isNFTStakingEnabled) {
                uint256 accPydexReward = totalPydexReward;
                uint256 nftRewardSplitAmount = totalPydexReward
                    .mul(nftRewardSplitPercent)
                    .div(1000);
                uint256 silverShare = 0;
                uint256 goldShare = 0;
                uint256 diamondShare = 0;

                if (pool.nftStakingInfo.silverNFTsLocked > 0) {
                    silverShare = nftRewardSplitAmount
                        .mul(TYPE_SILVER_NFT_RATIO)
                        .div(1000);
                    pool.nftStakingInfo.accPydexPerSilverNFTShare = pool
                        .nftStakingInfo
                        .accPydexPerSilverNFTShare
                        .add(
                            silverShare.mul(1e18).div(
                                pool.nftStakingInfo.tokensStakedBySilverStakers
                            )
                        );
                }

                if (pool.nftStakingInfo.goldNFTsLocked > 0) {
                    goldShare = nftRewardSplitAmount
                        .mul(TYPE_GOLD_NFT_RATIO)
                        .div(1000);
                    pool.nftStakingInfo.accPydexPerGoldNFTShare = pool
                        .nftStakingInfo
                        .accPydexPerGoldNFTShare
                        .add(
                            goldShare.mul(1e18).div(
                                pool.nftStakingInfo.tokensStakedByGoldStakers
                            )
                        );
                }

                if (pool.nftStakingInfo.diamondNFTsLocked > 0) {
                    diamondShare = nftRewardSplitAmount
                        .mul(TYPE_DIAMOND_NFT_RATIO)
                        .div(1000);
                    pool.nftStakingInfo.accPydexPerDiamondNFTShare = pool
                        .nftStakingInfo
                        .accPydexPerDiamondNFTShare
                        .add(
                            diamondShare.mul(1e18).div(
                                pool.nftStakingInfo.tokensStakedByDiamondStakers
                            )
                        );
                }

                uint256 totalNFTAllocation = silverShare.add(goldShare).add(
                    diamondShare
                );
                uint256 remainingReward = accPydexReward.sub(
                    totalNFTAllocation
                );
                pool.accPydexPerShare = pool.accPydexPerShare.add(
                    remainingReward.mul(1e18).div(lpSupply)
                );
            } else {
                pool.accPydexPerShare = pool.accPydexPerShare.add(
                    totalPydexReward.mul(1e18).div(lpSupply)
                );
            }
        }
        pool.lastRewardBlock = block.number;
    }


     // View function to see pending PYDEXs on frontend.
    function pendingPYDEX(uint256 _pid, address _user)
        external
        view
        returns (
            uint256 normalReward,
            uint256 nftReward,
            uint256 totalRewards
        )
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accPydexPerShare = pool.accPydexPerShare;
        uint256 lpSupply = pool.lpSupply;
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);

        uint256 accPydexPerSilverNFTShare= 0; 
        uint256 accPydexPerGoldNFTShare = 0;
        uint256 accPydexPerDiamondNFTShare = 0;

        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 totalPydexReward = multiplier
                .mul(pydexPerBlock)
                .mul(pool.allocPoint)
                .div(totalAllocPoint);
           

            if (totalPydexReward != 0) {
                if (pool.nftStakingInfo.isNFTStakingEnabled) {
                    uint256 accPydexReward = totalPydexReward;
                    uint256 nftRewardSplitAmount = totalPydexReward
                        .mul(nftRewardSplitPercent)
                        .div(1000);
                    uint256 silverShare = 0;
                    uint256 goldShare = 0;
                    uint256 diamondShare = 0;

                    if (pool.nftStakingInfo.silverNFTsLocked > 0) {
                        silverShare = nftRewardSplitAmount
                            .mul(TYPE_SILVER_NFT_RATIO)
                            .div(1000);
                        accPydexPerSilverNFTShare = pool
                            .nftStakingInfo
                            .accPydexPerSilverNFTShare
                            .add(
                                silverShare.mul(1e18).div(
                                    pool.nftStakingInfo.tokensStakedBySilverStakers
                                )
                            );
                    }

                    if (pool.nftStakingInfo.goldNFTsLocked > 0) {
                        goldShare = nftRewardSplitAmount
                            .mul(TYPE_GOLD_NFT_RATIO)
                            .div(1000);
                        accPydexPerGoldNFTShare= pool
                            .nftStakingInfo
                            .accPydexPerGoldNFTShare
                            .add(
                                goldShare.mul(1e18).div(
                                    pool.nftStakingInfo.tokensStakedByGoldStakers
                                )
                            );
                    }

                    if (pool.nftStakingInfo.diamondNFTsLocked > 0) {
                        diamondShare = nftRewardSplitAmount
                            .mul(TYPE_DIAMOND_NFT_RATIO)
                            .div(1000);
                        accPydexPerDiamondNFTShare = pool
                            .nftStakingInfo
                            .accPydexPerDiamondNFTShare
                            .add(
                                diamondShare.mul(1e18).div(
                                    pool.nftStakingInfo.tokensStakedByDiamondStakers
                                )
                            );
                    }

                    uint256 totalNFTAllocation = silverShare.add(goldShare).add(
                        diamondShare
                    );
                    uint256 remainingReward = accPydexReward.sub(
                        totalNFTAllocation
                    );

                    accPydexPerShare = accPydexPerShare.add(
                        remainingReward.mul(1e18).div(lpSupply)
                    );
                } else {
                   accPydexPerShare = accPydexPerShare.add(
                        totalPydexReward.mul(1e18).div(lpSupply)
                    );
                }
            }

            normalReward = user.amount.mul(accPydexPerShare).div(1e18).sub(
                user.rewardDebt
            );

            uint256 nftType = _privacyNFT.tokenTypes(user.stakedNFTId);
            if (nftType == 1) {
                nftReward = user
                    .amount
                    .mul(accPydexPerSilverNFTShare)
                    .div(1e18)
                    .sub(user.nftRewardDebt);
            } else if (nftType == 2) {
                nftReward = user
                    .amount
                    .mul(accPydexPerGoldNFTShare)
                    .div(1e18)
                    .sub(user.nftRewardDebt);
            } else if (nftType == 3) {
                nftReward = user
                    .amount
                    .mul(accPydexPerDiamondNFTShare)
                    .div(1e18)
                    .sub(user.nftRewardDebt);
            }

            totalRewards = normalReward.add(nftReward);
        }
    }

    // Deposit LP tokens to MasterChef for PYDEX allocation.
    function deposit(
        uint256 _pid,
        uint256 _amount,
        address _referrer
    ) external nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        updatePool(_pid);
        if (_amount > 0 && address(pydexReferral) != address(0)) {
            pydexReferral.recordReferral(_msgSender(), _referrer);
        }

        payPendingReward(_pid);
        uint256 refCommission = 0;
        uint256 finalAmount = 0;

        if (_amount > 0) {
            uint256 preAmount = pool.lpToken.balanceOf(address(this)); // deflationary check
            pool.lpToken.safeTransferFrom(
                address(_msgSender()),
                address(this),
                _amount
            );
            _amount = pool.lpToken.balanceOf(address(this)).sub(preAmount);
            refCommission = payCommissionOnDeposit(
                pool.lpToken,
                _amount,
                _msgSender()
            );
            if (pool.depositFeeBP > 0) {
                uint256 depositFee = _amount.mul(pool.depositFeeBP).div(10000);
                pool.lpToken.safeTransfer(feeAddress, depositFee);
                finalAmount = _amount.sub(depositFee).sub(refCommission);
            } else {
                finalAmount = _amount.sub(refCommission);
            }

            user.amount = user.amount.add(finalAmount);
            pool.lpSupply = pool.lpSupply.add(finalAmount);
        }
        user.rewardDebt = user.amount.mul(pool.accPydexPerShare).div(1e18);

        if (pool.nftStakingInfo.isNFTStakingEnabled && user.stakedNFTId != 0) {
            uint256 nftType = _privacyNFT.tokenTypes(user.stakedNFTId);
            if (nftType == 1) {
                user.nftRewardDebt = user
                    .amount
                    .mul(pool.nftStakingInfo.accPydexPerSilverNFTShare)
                    .div(1e18);
                pool.nftStakingInfo.tokensStakedBySilverStakers = pool
                    .nftStakingInfo
                    .tokensStakedBySilverStakers
                    .add(finalAmount);
            } else if (nftType == 2) {
                user.nftRewardDebt = user
                    .amount
                    .mul(pool.nftStakingInfo.accPydexPerGoldNFTShare)
                    .div(1e18);
                pool.nftStakingInfo.tokensStakedByGoldStakers = pool
                    .nftStakingInfo
                    .tokensStakedByGoldStakers
                    .add(finalAmount);
            } else if (nftType == 3) {
                user.nftRewardDebt = user
                    .amount
                    .mul(pool.nftStakingInfo.accPydexPerDiamondNFTShare)
                    .div(1e18);
                pool.nftStakingInfo.tokensStakedByDiamondStakers = pool
                    .nftStakingInfo
                    .tokensStakedByDiamondStakers
                    .add(finalAmount);
            }
        }
        emit Deposit(_msgSender(), _pid, _amount, refCommission);
    }

    // Withdraw LP tokens from .
    function withdraw(uint256 _pid, uint256 _amount) external nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        payPendingReward(_pid);
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(_msgSender()), _amount);
            pool.lpSupply = pool.lpSupply.sub(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accPydexPerShare).div(1e18);
        if (pool.nftStakingInfo.isNFTStakingEnabled && user.stakedNFTId != 0) {
            uint256 nftType = _privacyNFT.tokenTypes(user.stakedNFTId);
            if (nftType == 1) {
                user.nftRewardDebt = user
                    .amount
                    .mul(pool.nftStakingInfo.accPydexPerSilverNFTShare)
                    .div(1e18);
                pool.nftStakingInfo.tokensStakedBySilverStakers = pool
                    .nftStakingInfo
                    .tokensStakedBySilverStakers
                    .sub(_amount);
            } else if (nftType == 2) {
                user.nftRewardDebt = user
                    .amount
                    .mul(pool.nftStakingInfo.accPydexPerGoldNFTShare)
                    .div(1e18);
                pool.nftStakingInfo.tokensStakedByGoldStakers = pool
                    .nftStakingInfo
                    .tokensStakedByGoldStakers
                    .sub(_amount);
            } else if (nftType == 3) {
                user.nftRewardDebt = user
                    .amount
                    .mul(pool.nftStakingInfo.accPydexPerDiamondNFTShare)
                    .div(1e18);
                pool.nftStakingInfo.tokensStakedByDiamondStakers = pool
                    .nftStakingInfo
                    .tokensStakedByDiamondStakers
                    .sub(_amount);
            }
        }
        emit Withdraw(_msgSender(), _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) external nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        user.nftRewardDebt = 0;
        pool.lpSupply = pool.lpSupply.sub(amount);

        if (pool.nftStakingInfo.isNFTStakingEnabled && user.stakedNFTId != 0) {
            uint256 nftType = _privacyNFT.tokenTypes(user.stakedNFTId);
            if (nftType == 1) {
                pool.nftStakingInfo.tokensStakedBySilverStakers = pool
                    .nftStakingInfo
                    .tokensStakedBySilverStakers
                    .sub(amount);
            } else if (nftType == 2) {
                pool.nftStakingInfo.tokensStakedByGoldStakers = pool
                    .nftStakingInfo
                    .tokensStakedByGoldStakers
                    .sub(amount);
            } else if (nftType == 3) {
                pool.nftStakingInfo.tokensStakedByDiamondStakers = pool
                    .nftStakingInfo
                    .tokensStakedByDiamondStakers
                    .sub(amount);
            }
        }
        pool.lpToken.safeTransfer(address(_msgSender()), amount);

        emit EmergencyWithdraw(_msgSender(), _pid, amount);
    }

    function payPendingReward(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];

        uint256 normalPending = user
            .amount
            .mul(pool.accPydexPerShare)
            .div(1e18)
            .sub(user.rewardDebt);
        uint256 nftReward = 0;
        if (pool.nftStakingInfo.isNFTStakingEnabled && user.stakedNFTId != 0) {
            uint256 nftType = _privacyNFT.tokenTypes(user.stakedNFTId);
            if (nftType == 1) {
                nftReward = user
                    .amount
                    .mul(pool.nftStakingInfo.accPydexPerSilverNFTShare)
                    .div(1e18)
                    .sub(user.nftRewardDebt);
            } else if (nftType == 2) {
                nftReward = user
                    .amount
                    .mul(pool.nftStakingInfo.accPydexPerGoldNFTShare)
                    .div(1e18)
                    .sub(user.nftRewardDebt);
            } else if (nftType == 3) {
                nftReward = user
                    .amount
                    .mul(pool.nftStakingInfo.accPydexPerDiamondNFTShare)
                    .div(1e18)
                    .sub(user.nftRewardDebt);
            }
        }

        uint256 pending = normalPending.add(nftReward);

        if (pending > 0) {
            (
                address firstLevel,
                address secondLevel,
                address thirdLevel
            ) = pydexReferral.getReferrer(_msgSender());

            emit onPayPendingReward(normalPending, nftReward);
            uint256 totalCommission = 0;
            uint256 firstLCommission;
            uint256 secondLCommission;
            uint256 thirdLCommission;

            if (firstLevel != address(0)) {
                firstLCommission = pydexReferral
                    .getMyFirstLevelCommissionRate(_msgSender())
                    .mul(pending)
                    .div(1000);
                totalCommission = totalCommission.add(firstLCommission);
                pydexReferral.recordReferralCommission(
                    firstLevel,
                    firstLCommission,
                    1
                );
                safePydexTransfer(firstLevel, firstLCommission);
            }

            if (secondLevel != address(0)) {
                secondLCommission = pydexReferral.secondTier().mul(pending).div(
                        1000
                    );
                totalCommission = totalCommission.add(secondLCommission);
                pydexReferral.recordReferralCommission(
                    secondLevel,
                    secondLCommission,
                    2
                );

                safePydexTransfer(secondLevel, secondLCommission);
            }

            if (thirdLevel != address(0)) {
                thirdLCommission = pydexReferral.thirdTier().mul(pending).div(
                    1000
                );
                totalCommission = totalCommission.add(thirdLCommission);
                pydexReferral.recordReferralCommission(
                    thirdLevel,
                    thirdLCommission,
                    3
                );

                safePydexTransfer(thirdLevel, thirdLCommission);
            }

            safePydexTransfer(_msgSender(), pending.sub(totalCommission));
            emit onRewardPaid(
                _msgSender(),
                firstLCommission,
                secondLCommission,
                thirdLCommission,
                pending.sub(totalCommission)
            );
        }
    }

    // Safe pydex transfer function, just in case if rounding error causes pool to not have enough PYDEXs.
    function safePydexTransfer(address _to, uint256 _amount) internal {
        uint256 pydexBal = pydex.balanceOf(address(this));
        if (_amount > pydexBal) {
            pydex.transfer(_to, pydexBal);
        } else {
            pydex.transfer(_to, _amount);
        }
    }

    function getNftStakingInfo(uint256 _pid)
        public
        view
        returns (NFTStakingInfo memory)
    {
        return poolInfo[_pid].nftStakingInfo;
    }

    function setFeeAddress(address _feeAddress) external  onlyOwner{
        require(_feeAddress != address(0), "setFeeAddress: ZERO");
        emit onSetFeeAddress(feeAddress, _feeAddress);
        feeAddress = _feeAddress;
    }



    function setDevAddress(address _devAddress) external onlyOwner {
        require(_devAddress != address(0), "setDevAddress: ZERO");
        emit onSetDevAddress(devAddress, _devAddress);
        devAddress = _devAddress;
    }

    function updateEmissionRate(uint256 _newpydexPerBlock) external onlyOwner {
        require(
            _newpydexPerBlock <= 100e18,
            "Can't set emissions more than 100 PYDEX perblock"
        );
        massUpdatePools();
        emit EmissionRateUpdated(
            _msgSender(),
            pydexPerBlock,
            _newpydexPerBlock
        );
        pydexPerBlock = _newpydexPerBlock;
    }

    // Update the pydex referral contract address by the owner
    function setPydexReferral(IPYDEXReferral _pydexReferral)
        external
        onlyOwner
    {
        require(
            address(pydexReferral) == address(0),
            "PYDEXReferral already set"
        );
        emit onSetPydexReferral(
            address(pydexReferral),
            address(_pydexReferral)
        );
        _pydexReferral.getReferrer(address(this));
        pydexReferral = _pydexReferral;
    }

    function payCommissionOnDeposit(
        IBEP20 token,
        uint256 amount,
        address user
    ) internal returns (uint256) {
        address refererer = pydexReferral.referrers(user);
        uint256 commissionAmount = 0;
        if (
            refererer != address(0) &&
            pydexReferral.depositCommissionStatuses(refererer)
        ) {
            commissionAmount = amount
                .mul(pydexReferral.DEPOSIT_REFFERAL_COMMISSION())
                .div(1000);
            token.safeTransfer(refererer, commissionAmount);
        }
        return commissionAmount;
    }
}