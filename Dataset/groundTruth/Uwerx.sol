// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

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

library Address {

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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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
}

contract WERXStaking is Ownable, ReentrancyGuard{
	using SafeERC20 for IERC20;
	
	struct UserInfo {
	   uint256 amount; 
	   uint256 startTime;
	   uint256 endTime;
	   uint256 APY;
	   bool claimStatus;
    }
	
	uint256[4] public stakingPeriod;
	uint256[4] public minStakingToken;
	uint256[4] public stakingAPY;
	
	address public stakedToken;
	uint256 public totalStaked;
	
	mapping(address => mapping(uint256 => mapping(uint256 => UserInfo))) public mapUserInfo;
	mapping(address => mapping(uint256 => uint256)) public stakingCount;
	
    event Stake(address user, uint256 amount);
    event UNStake(address user, uint256 amount);
	event NewMinStakingToken(uint256 P1MinStaking, uint256 P2MinStaking, uint256 P3MinStaking, uint256 P4MinStaking);
	event NewStakingAPY(uint256 P1StakingAPY, uint256 P2StakingAPY, uint256 P3StakingAPY, uint256 P4StakingAPY);
	event MigrateTokens(address token, address receiver, uint256 amount);
	event MigrateMATIC(address receiver, uint256 amount);
	
	constructor() {
	   stakingPeriod[0] = 30 days;
	   stakingPeriod[1] = 72 days;
	   stakingPeriod[2] = 150 days;
	   stakingPeriod[3] = 365 days;
	   
	   minStakingToken[0] = 10 * 10**18;
	   minStakingToken[1] = 10 * 10**18;
	   minStakingToken[2] = 10 * 10**18;
	   minStakingToken[3] = 10 * 10**18;
	   
	   stakingAPY[0] = 500;
	   stakingAPY[1] = 1400;
	   stakingAPY[2] = 3200;
	   stakingAPY[3] = 7900;
	   
	   stakedToken = address(0x9b2CFE1608250BEA375c6199b474B402BaD920da);
    }

	receive() external payable {}
	
	function stakeToken(uint256 amount, uint256 plan) external nonReentrant {
		require(plan < stakingPeriod.length, "Staking Plan not found");
		require(IERC20(stakedToken).balanceOf(msg.sender) >= amount, "Balance not available for staking");
		require(amount >= minStakingToken[plan], "Amount is less than minimum staking amount");
		
		stakingCount[address(msg.sender)][plan] += 1;
		uint256 stakeCount = stakingCount[msg.sender][plan];
		
		mapUserInfo[address(msg.sender)][plan][stakeCount].amount = amount;
		mapUserInfo[address(msg.sender)][plan][stakeCount].startTime = block.timestamp;
		mapUserInfo[address(msg.sender)][plan][stakeCount].endTime = block.timestamp + stakingPeriod[plan];
		mapUserInfo[address(msg.sender)][plan][stakeCount].APY = stakingAPY[plan];
		mapUserInfo[address(msg.sender)][plan][stakeCount].claimStatus = false;
		
		totalStaked += amount;
		IERC20(stakedToken).safeTransferFrom(address(msg.sender), address(this), amount);
        emit Stake(address(msg.sender), amount);
    }
	
	function unstakeToken(uint256 plan, uint256 count) external nonReentrant{
	    require(mapUserInfo[address(msg.sender)][plan][count].amount > 0, "Staking not found");
	    require(mapUserInfo[address(msg.sender)][plan][count].claimStatus == false, "Already unstaked");
		require(mapUserInfo[address(msg.sender)][plan][count].endTime < block.timestamp, "Can't unstake before staking end period");
		
		uint256 amount = mapUserInfo[address(msg.sender)][plan][count].amount;
		uint256 APY = mapUserInfo[address(msg.sender)][plan][count].APY;
		uint256 reward = (amount * APY) / 10000;
		
		totalStaked -= amount;
		mapUserInfo[address(msg.sender)][plan][count].claimStatus = true;
		
		IERC20(stakedToken).safeTransfer(address(msg.sender), amount + reward);
		emit UNStake(address(msg.sender), amount + reward);
         
    }
	
	function SetMinStakingToken(uint256 P1MinStaking, uint256 P2MinStaking, uint256 P3MinStaking, uint256 P4MinStaking) external onlyOwner {
	    require(P1MinStaking > 1 * 10**18, "Incorrect `P1 Min Staking` value");
		require(P2MinStaking > 1 * 10**18, "Incorrect `P2 Min Staking` value");
		require(P3MinStaking > 1 * 10**18, "Incorrect `P3 Min Staking` value");
		require(P4MinStaking > 1 * 10**18, "Incorrect `P4 Min Staking` value");
		
	    minStakingToken[0] = P1MinStaking;
        minStakingToken[1] = P2MinStaking;
        minStakingToken[2] = P3MinStaking;
		minStakingToken[3] = P4MinStaking;
		emit NewMinStakingToken(P1MinStaking, P2MinStaking, P3MinStaking, P4MinStaking);
    }
	
	function SetStakingAPY(uint256 P1StakingAPY, uint256 P2StakingAPY, uint256 P3StakingAPY, uint256 P4StakingAPY) external onlyOwner {
	    require(P1StakingAPY > 0, "Incorrect `P1 Staking APY` value");
		require(P2StakingAPY > 0, "Incorrect `P2 Staking APY` value");
		require(P3StakingAPY > 0, "Incorrect `P3 Staking APY` value");
		require(P4StakingAPY > 0, "Incorrect `P4 Staking APY` value");
		
	    stakingAPY[0] = P1StakingAPY;
        stakingAPY[1] = P2StakingAPY;
        stakingAPY[2] = P3StakingAPY;
		stakingAPY[3] = P4StakingAPY;
		emit NewStakingAPY(P1StakingAPY, P2StakingAPY, P3StakingAPY, P4StakingAPY);
    }
	
	function migrateTokens(address token, address receiver, uint256 amount) external onlyOwner {
	   require(token != address(stakedToken), "Can't withdraw token");
       require(token != address(0), "Zero address");
	   require(receiver != address(0), "Zero address");
	   require(IERC20(token).balanceOf(address(this)) >= amount, "Insufficient balance on contract");
	   
	   IERC20(token).safeTransfer(address(receiver), amount);
       emit MigrateTokens(token, receiver, amount);
    }
	
	function migrateMATIC(address receiver, uint256 amount) external onlyOwner {
	    require(receiver != address(0), "Zero address");
		require(address(this).balance >= amount, "Insufficient balance on contract");
		
		(bool success, ) = receiver.call{value: amount}("");
        require(success, "Address: Unable to send value, recipient may have reverted");
		emit MigrateMATIC(receiver, amount);
    }
}

