// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

library OTSeaErrors {
    error InvalidAmount();
    error InvalidAddress();
    error InvalidIndex(uint256 index);
    error InvalidAmountAtIndex(uint256 index);
    error InvalidAddressAtIndex(uint256 index);
    error DuplicateAddressAtIndex(uint256 index);
    error AddressNotFoundAtIndex(uint256 index);
    error Unauthorized();
    error ExpectationMismatch();
    error InvalidArrayLength();
    error InvalidFee();
    error NotAvailable();
    error InvalidPurchase();
    error InvalidETH(uint256 expected);
    error Unchanged();
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

library SafeERC20 {
    using Address for address;

    error SafeERC20FailedOperation(address token);

    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}

library Address {

    error AddressInsufficientBalance(address account);

    error AddressEmptyCode(address target);

    error FailedInnerCall();

    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly

            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}

interface IERC20Permit {

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);

    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

abstract contract ListHelper {
    uint16 internal constant LOOP_LIMIT = 500;
    bool internal constant ALLOW_ZERO = true;
    bool internal constant DISALLOW_ZERO = false;

    error InvalidStart();
    error InvalidEnd();
    error InvalidSequence();

    modifier onlyValidSequence(
        uint256 _start,
        uint256 _end,
        uint256 _total,
        bool _allowZero
    ) {
        _checkSequence(_start, _end, _total, _allowZero);
        _;
    }

    function _checkSequence(
        uint256 _start,
        uint256 _end,
        uint256 _total,
        bool _allowZero
    ) private pure {
        if (_allowZero) {
            if (_start >= _total) revert InvalidStart();
            if (_end >= _total) revert InvalidEnd();
        } else {
            if (_start == 0 || _start > _total) revert InvalidStart();
            if (_end == 0 || _end > _total) revert InvalidEnd();
        }
        if (_start > _end) revert InvalidStart();
        if (_end - _start + 1 > LOOP_LIMIT) revert InvalidSequence();
    }

    function _validateListLength(uint256 _length) internal pure {
        if (_length == 0 || LOOP_LIMIT < _length) revert OTSeaErrors.InvalidArrayLength();
    }
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IERC20Errors {

    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    error ERC20InvalidSender(address sender);

    error ERC20InvalidReceiver(address receiver);

    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    error ERC20InvalidApprover(address approver);

    error ERC20InvalidSpender(address spender);
}

interface IERC721Errors {

    error ERC721InvalidOwner(address owner);

    error ERC721NonexistentToken(uint256 tokenId);

    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    error ERC721InvalidSender(address sender);

    error ERC721InvalidReceiver(address receiver);

    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    error ERC721InvalidApprover(address approver);

    error ERC721InvalidOperator(address operator);
}

interface IERC1155Errors {

    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    error ERC1155InvalidSender(address sender);

    error ERC1155InvalidReceiver(address receiver);

    error ERC1155MissingApprovalForAll(address operator, address owner);

    error ERC1155InvalidApprover(address approver);

    error ERC1155InvalidOperator(address operator);

    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}

contract TransferHelper is Context {
    using SafeERC20 for IERC20;

    mapping(address => uint256) private _maroonedETH;

    error NativeTransferFailed();

    event MaroonedETH(address account, uint256 amount);
    event MaroonedETHClaimed(address account, address receiver, uint256 amount);

    function claimMaroonedETH(address _receiver) external {
        if (_receiver == address(0)) revert OTSeaErrors.InvalidAddress();
        uint256 amount = _maroonedETH[_msgSender()];
        if (amount == 0) revert OTSeaErrors.NotAvailable();
        _maroonedETH[_msgSender()] = 0;
        _transferETHOrRevert(_receiver, amount);
        emit MaroonedETHClaimed(_msgSender(), _receiver, amount);
    }

    function getMaroonedETH(address _account) external view returns (uint256) {
        if (_account == address(0)) revert OTSeaErrors.InvalidAddress();
        return _maroonedETH[_account];
    }

    function _safeETHTransfer(address _account, uint256 _amount) internal {
        (bool success, ) = _account.call{value: _amount}("");
        if (!success) {
            _maroonedETH[_account] += _amount;
            emit MaroonedETH(_account, _amount);
        }
    }

    function _transferETHOrRevert(address _account, uint256 _amount) internal {
        (bool success, ) = _account.call{value: _amount}("");
        if (!success) revert NativeTransferFailed();
    }

    function _transferInTokens(IERC20 _token, uint256 _amount) internal returns (uint256) {
        uint256 balanceBefore = _token.balanceOf(address(this));
        _token.safeTransferFrom(_msgSender(), address(this), _amount);
        return _token.balanceOf(address(this)) - balanceBefore;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    error OwnableUnauthorizedAccount(address account);

    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract OTSeaStaking is Ownable, TransferHelper, ListHelper {
    using SafeERC20 for IERC20;

    struct Deposit {

        uint32 rewardReferenceEpoch;
        uint88 amount;
    }

    struct Epoch {
        uint168 startedAt;
        uint88 totalStake;
        uint256 sharePerToken;
    }

    IUniswapV2Router02 private constant _router =
        IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    uint256 private constant REWARD_PRECISION = 10e38;
    address private immutable _revenueDistributor;
    bool public isDepositingAllowed;
    uint32 private _currentEpoch = 1;
    IERC20 private _otseaERC20;
    mapping(address => Deposit[]) private _deposits;
    mapping(uint32 => Epoch) private _epochs;

    error NoRewards();
    error InvalidEpoch();
    error DepositNotFound(uint256 index);

    event Initialized(address token);
    event ToggledDepositing(bool isDepositingAllowed);
    event Deposited(address indexed account, uint256 indexed index, Deposit deposit);
    event Withdrawal(
        address indexed account,
        address indexed receiver,
        uint256[] indexes,
        uint88 amount
    );
    event Claimed(
        address indexed account,
        address indexed receiver,
        uint256[] indexes,
        uint256 amount
    );
    event Compounded(
        address indexed account,
        uint256[] indexes,
        uint256 amountSwapped,
        uint256 indexed newDepositIndex,
        Deposit deposit
    );
    event EpochEnded(uint32 indexed id, Epoch epoch, uint256 distributed);

    modifier onlyRevenueDistributor() {
        _isCallerRevenueDistributor();
        _;
    }

    constructor(address _multiSigAdmin, address revenueDistributor_) Ownable(_multiSigAdmin) {
        if (address(revenueDistributor_) == address(0)) revert OTSeaErrors.InvalidAddress();
        _revenueDistributor = revenueDistributor_;
    }

    function initialize(IERC20 _token) external onlyOwner {
        if (address(_token) == address(0)) revert OTSeaErrors.InvalidAddress();
        if (_isInitialized()) revert OTSeaErrors.NotAvailable();
        _otseaERC20 = _token;
        _epochs[1].startedAt = uint168(block.timestamp);
        emit Initialized(address(_token));
    }

    function toggleDepositing() external onlyOwner {
        if (!_isInitialized()) revert OTSeaErrors.NotAvailable();
        isDepositingAllowed = !isDepositingAllowed;
        emit ToggledDepositing(isDepositingAllowed);
    }

    function distribute() external payable onlyRevenueDistributor {
        uint32 currentEpoch = _currentEpoch;
        uint256 sharePerToken = (REWARD_PRECISION * msg.value) / _epochs[currentEpoch].totalStake;
        _epochs[currentEpoch].sharePerToken += sharePerToken;
        _nextEpoch();
        emit EpochEnded(currentEpoch, _epochs[currentEpoch], msg.value);
    }

    function skipEpoch() external onlyRevenueDistributor {
        uint32 currentEpoch = _currentEpoch;
        _nextEpoch();
        emit EpochEnded(currentEpoch, _epochs[currentEpoch], 0);
    }

    function stake(uint88 _amount) external {
        if (!isDepositingAllowed) revert OTSeaErrors.NotAvailable();
        if (_amount == 0) revert OTSeaErrors.InvalidAmount();
        _checkSufficientAmount(_amount);

        Deposit memory deposit = _createDeposit(_amount);
        _otseaERC20.safeTransferFrom(_msgSender(), address(this), uint256(_amount));
        emit Deposited(_msgSender(), _deposits[_msgSender()].length - 1, deposit);
    }

    function withdraw(uint256[] calldata _indexes, address _receiver) external {
        if (_receiver == address(0)) revert OTSeaErrors.InvalidAddress();
        (uint88 totalAmount, uint256 totalRewards) = _withdrawMultiple(_indexes);
        if (totalRewards != 0) {
            _transferETHOrRevert(_receiver, totalRewards);
            emit Claimed(_msgSender(), _receiver, _indexes, totalRewards);
        }
        _otseaERC20.safeTransfer(_receiver, uint256(totalAmount));
        emit Withdrawal(_msgSender(), _receiver, _indexes, totalAmount);
    }

    function claim(uint256[] calldata _indexes, address _receiver) external {
        if (_receiver == address(0)) revert OTSeaErrors.InvalidAddress();
        uint256 totalRewards = _claimMultiple(_indexes);
        _transferETHOrRevert(_receiver, totalRewards);
        emit Claimed(_msgSender(), _receiver, _indexes, totalRewards);
    }

    function compound(
        uint256[] calldata _indexes,
        uint256 _amountToSwap,
        uint88 _minTokenAmount,
        address _remainderReceiver
    ) external {
        if (_amountToSwap == 0 || _minTokenAmount == 0) revert OTSeaErrors.InvalidAmount();
        uint256 totalRewards = _claimMultiple(_indexes);
        if (totalRewards < _amountToSwap) revert OTSeaErrors.InvalidAmount();
        uint256 remaining = totalRewards - _amountToSwap;
        if (remaining != 0) {
            if (_remainderReceiver == address(0)) revert OTSeaErrors.InvalidAddress();
            _transferETHOrRevert(_remainderReceiver, remaining);
            emit Claimed(_msgSender(), _remainderReceiver, _indexes, remaining);
        }
        uint88 tokens = _swapETHForTokens(_amountToSwap, _minTokenAmount);
        Deposit memory deposit = _createDeposit(tokens);
        emit Compounded(
            _msgSender(),
            _indexes,
            _amountToSwap,
            _deposits[_msgSender()].length - 1,
            deposit
        );
    }

    function getEpoch(uint32 _epoch) external view returns (Epoch memory) {
        if (_epoch == 0 || _currentEpoch + 1 < _epoch) revert InvalidEpoch();
        return _epochs[_epoch];
    }

    function getCurrentEpoch() external view returns (uint32, Epoch memory) {
        return (_currentEpoch, _epochs[_currentEpoch]);
    }

    function getTotalDeposits(address _account) public view returns (uint256 total) {
        if (_account == address(0)) revert OTSeaErrors.InvalidAddress();
        return _deposits[_account].length;
    }

    function getDeposit(address _account, uint256 _index) external view returns (Deposit memory) {
        if (getTotalDeposits(_account) <= _index) revert DepositNotFound(_index);
        return _deposits[_account][_index];
    }

    function getDepositsInSequence(
        address _account,
        uint256 _startIndex,
        uint256 _endIndex
    )
        external
        view
        onlyValidSequence(_startIndex, _endIndex, getTotalDeposits(_account), ALLOW_ZERO)
        returns (Deposit[] memory deposits)
    {
        deposits = new Deposit[](_endIndex - _startIndex + 1);
        uint256 index;
        uint256 depositIndex = _startIndex;
        for (depositIndex; depositIndex <= _endIndex; ) {
            deposits[index] = _deposits[_account][depositIndex];
            unchecked {
                index++;
                depositIndex++;
            }
        }
        return deposits;
    }

    function getDepositsByList(
        address _account,
        uint256[] calldata _indexes
    ) external view returns (Deposit[] memory deposits) {
        uint256 length = _indexes.length;
        _validateListLength(length);
        uint256 total = getTotalDeposits(_account);
        deposits = new Deposit[](length);
        for (uint256 i; i < length; ) {
            if (total <= _indexes[i]) revert DepositNotFound(_indexes[i]);
            deposits[i] = _deposits[_account][_indexes[i]];
            unchecked {
                i++;
            }
        }
        return deposits;
    }

    function calculateRewards(
        address _account,
        uint256[] calldata _indexes
    ) external view returns (uint256 rewards) {
        uint256 length = _indexes.length;
        _validateListLength(length);
        uint256 total = getTotalDeposits(_account);
        for (uint256 i; i < length; ) {
            if (total <= _indexes[i]) revert DepositNotFound(_indexes[i]);
            rewards += _calculateRewards(_account, _indexes[i]);
            unchecked {
                i++;
            }
        }
        return rewards;
    }

    function _nextEpoch() private {

        uint32 nextEpoch = ++_currentEpoch;
        _epochs[nextEpoch].startedAt = uint88(block.timestamp);
        _epochs[nextEpoch].sharePerToken = _epochs[nextEpoch - 1].sharePerToken;
        _epochs[nextEpoch].totalStake += _epochs[nextEpoch - 1].totalStake;
    }

    function _createDeposit(uint88 _amount) private returns (Deposit memory deposit) {
        uint32 nextEpoch = _currentEpoch + 1;
        deposit = Deposit(nextEpoch, _amount);
        _deposits[_msgSender()].push(deposit);
        _epochs[nextEpoch].totalStake += _amount;
        return deposit;
    }

    function _withdrawMultiple(
        uint256[] calldata _indexes
    ) private returns (uint88 totalAmount, uint256 totalRewards) {
        uint256 length = _indexes.length;
        _validateListLength(length);
        uint256 total = getTotalDeposits(_msgSender());
        uint32 currentEpoch = _currentEpoch;
        for (uint256 i; i < length; ) {
            if (total <= _indexes[i]) revert DepositNotFound(_indexes[i]);
            totalRewards += _calculateRewards(_msgSender(), _indexes[i]);
            Deposit memory deposit = _deposits[_msgSender()][_indexes[i]];
            if (deposit.rewardReferenceEpoch == 0) revert OTSeaErrors.NotAvailable();
            _deposits[_msgSender()][_indexes[i]].rewardReferenceEpoch = 0;

            _epochs[
                currentEpoch < deposit.rewardReferenceEpoch
                    ? deposit.rewardReferenceEpoch
                    : currentEpoch
            ].totalStake -= deposit.amount;
            totalAmount += deposit.amount;
            unchecked {
                i++;
            }
        }
        return (totalAmount, totalRewards);
    }

    function _claimMultiple(uint256[] calldata _indexes) private returns (uint256 totalRewards) {
        uint256 length = _indexes.length;
        _validateListLength(length);
        uint256 total = getTotalDeposits(_msgSender());
        uint32 currentEpoch = _currentEpoch;
        for (uint256 i; i < length; ) {
            if (total <= _indexes[i]) revert DepositNotFound(_indexes[i]);
            totalRewards += _calculateRewards(_msgSender(), _indexes[i]);
            _deposits[_msgSender()][_indexes[i]].rewardReferenceEpoch = currentEpoch;
            unchecked {
                i++;
            }
        }
        if (totalRewards == 0) revert NoRewards();
        return totalRewards;
    }

    function _swapETHForTokens(
        uint256 _amountToSwap,
        uint88 _minTokenAmount
    ) private returns (uint88) {
        address[] memory path = new address[](2);
        path[0] = _router.WETH();
        path[1] = address(_otseaERC20);
        uint256[] memory amounts = _router.swapExactETHForTokens{value: _amountToSwap}(
            uint256(_minTokenAmount),
            path,
            address(this),
            block.timestamp
        );
        return uint88(amounts[1]);
    }

    function _calculateRewards(address _account, uint256 _index) private view returns (uint256) {
        uint32 rewardReferenceEpoch = _deposits[_account][_index].rewardReferenceEpoch;
        if (rewardReferenceEpoch == 0 || _currentEpoch <= rewardReferenceEpoch) {
            return 0;
        }
        return
            (_deposits[_account][_index].amount *
                (_epochs[_currentEpoch - 1].sharePerToken -
                    _epochs[rewardReferenceEpoch - 1].sharePerToken)) / REWARD_PRECISION;
    }

    function _checkSufficientAmount(uint88 _amount) private view {
        if (_otseaERC20.balanceOf(_msgSender()) < _amount)
            revert IERC20Errors.ERC20InsufficientBalance(
                _msgSender(),
                _otseaERC20.balanceOf(_msgSender()),
                uint256(_amount)
            );
        if (_otseaERC20.allowance(_msgSender(), address(this)) < _amount)
            revert IERC20Errors.ERC20InsufficientAllowance(
                address(this),
                _otseaERC20.allowance(_msgSender(), address(this)),
                uint256(_amount)
            );
    }

    function _isInitialized() private view returns (bool) {
        return address(_otseaERC20) != address(0);
    }

    function _isCallerRevenueDistributor() private view {
        if (_msgSender() != _revenueDistributor) revert OTSeaErrors.Unauthorized();
    }
}

