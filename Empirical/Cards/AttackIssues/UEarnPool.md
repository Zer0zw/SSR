# Project Name
UEarnPool

# Description
The staking rewards in this contract include team rewards, where, upon completing a staking action, a reward is distributed to the referrer (i.e., the inviter), and the team staking reward is updated. However, the lack of a time restriction between staking and claiming rewards allows an attacker to repeatedly perform the "stake-claim reward" operation within the same block, thereby gaining improper profits.

# Root Cause
```solidity
function stake(uint256 pid, uint256 amount) external {
    require(!_pause, "Pause");
    uint256 unit = _amountUnit;
    amount = amount / unit;
    amount = amount * unit;
    require(amount >= _minAmount, "<min");
    address account = msg.sender;

    Pool storage pool = _pools[pid];
    pool.totalAmount += amount;

    uint256 reward = amount * pool.rewardRate / _feeDivFactor;
    uint256 feeAmount = amount * _feeRate / _feeDivFactor;
    _userRecords[account].push(
        Record(pid, amount, feeAmount, reward, block.timestamp, block.timestamp + pool.duration, 0)
    );
    UserInfo storage userInfo = _userInfos[account];
    userInfo.amount += amount;
    if (!userInfo.active) {
        userInfo.active = true;
    }

    IERC20 token = IERC20(_tokenAddress);
    token.transferFrom(account, address(this), amount);

    _addInviteReward(account, amount);
    _addTeamAmount(account, amount);
}
    
function claimTeamReward(address account) external {
    uint256 level = getUserLevel(account);
    LevelConfig storage levelConfig;
    uint256 pendingReward;
    uint256 levelReward;
    if (level != MAX) {
        for (uint256 i; i <= level;) {
            levelConfig = _levelConfigs[i];
            if (_userInfos[account].levelClaimed[i] == 0) {
                if (i == 0) {
                    levelReward = levelConfig.teamAmount * levelConfig.rewardRate / _feeDivFactor;
                } else {
                    levelReward = (levelConfig.teamAmount - _levelConfigs[i - 1].teamAmount) * levelConfig.rewardRate / _feeDivFactor;
                }
                pendingReward += levelReward;
                _userInfos[account].levelClaimed[i] = levelReward;
            }
        unchecked{
            ++i;
        }
        }
    }
    if (pendingReward > 0) {
        IERC20(_tokenAddress).transfer(account, pendingReward);
    }
}

function _addInviteReward(address account, uint256 amount) private {
    uint256 inviteLength = _inviteLength;
    UserInfo storage invitorInfo;
    address invitor;
    IERC20 token = IERC20(_tokenAddress);
    for (uint256 i; i < inviteLength;) {
        invitor = _invitor[account];
        if (address(0) == invitor) {
            break;
        }
        account = invitor;
        invitorInfo = _userInfos[invitor];
    unchecked{
        uint256 inviteReward = amount * _inviteFee[i] / _feeDivFactor;
        if (inviteReward > 0) {
            invitorInfo.inviteReward += inviteReward;
            token.transfer(invitor, inviteReward);
        }
        ++i;
    }
    }
}