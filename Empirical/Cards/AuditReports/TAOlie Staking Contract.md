# Project Name
TAOlie Staking Contract

# Description
1. Potential Reduced Rewards
    
    The current implementation allows the `locktime` to be reset each time a user makes a deposit. While the system prevents the actual unlock timestamp from being shortened by comparing and setting the maximum value, the `locktime` used for reward calculation is still updated with each deposit. This means that if a user sets a lower locktime during a subsequent deposit, their rewards will be calculated based on this lower value. This behavior can lead to users receiving fewer rewards than they are entitled to.
    
2. Program Centralization Risk
    
    The program's functionality and behavior are heavily dependent on external parameters or configurations. While external configuration can offer flexibility, it also poses several centralization risks that warrant attention. Centralization risks arising from the dependence on external configuration include Single Point of Control, Vulnerability to Attacks, Operational Delays, Trust Dependencies, and Decentralization Erosion. Specifically, the program's functionality and behavior are heavily dependent on external parameters or configurations. Specifically, the administrative control over the `initialize` and `changeapy` functions introduces a significant centralization risk. These functions must be executed by a specific authorized account to set and update critical parameters within the protocol. If this account is compromised, it could lead to unauthorized changes in the APY settings or reinitialization of the contract, potentially affecting all users.

# Root Cause
```solidity
// Potential Reduced Rewards
let amount = calculate_rewards(user.deposted_amount, user.last_claim_timestamp, current_timestamp, user.locktime, apy_conf);

let apy_to_use = if apy_available {
    match locktime {
        0 => apy.apy_day_1,
        1 => apy.apy_month_1,
        3 => apy.apy_month_3,
        6 => apy.apy_month_6,
        12 => apy.apy_year_1,
        _ => {
            msg!("Unknown timelock");
            return 0;
        }
    }
}

// Program Centralization Risk
pub fn initialize(ctx: Context<Initialize>, admin: Pubkey) -> Result<()> {

  if let COption::Some(mint_authority) = ctx.accounts.depin_mint.mint_authority {
    require_keys_eq!(mint_authority, ctx.accounts.from.key(), InitializeError::AuthorityError);
  } else {
      return Err(InitializeError::AuthorityError.into());
  }

  let stake = &mut ctx.accounts.taolie_stake;
  let apy = &mut ctx.accounts.apy_pda;
  let base_account = &mut ctx.accounts.base_account;

  if stake.is_initialized {
    return Err(InitializeError::AlreadyInitializedError.into());
  }

  stake.total_amount = 0;
  apy.apy_day_1 = 6;
  apy.apy_month_1 = 12;
  apy.apy_month_3 = 20;
  apy.apy_month_6 = 35;
  apy.apy_year_1 = 100;

  apy.last_apy_day_1 = 6;
  apy.last_apy_month_1 = 12;
  apy.last_apy_month_3 = 20;
  apy.last_apy_month_6 = 35;
  apy.last_apy_year_1 = 100;
  
  apy.lock_time = Clock::get()?.unix_timestamp;

  base_account.admin = admin;

  stake.is_initialized = true;
  
  Ok(())
}

pub fn calculate_rewards(
    amount: u64,
    last_claim_timestamp: i64,
    current_timestamp: i64,
    locktime: u64,
    apy: ApyConf,
) -> u64 {
    let time_diff: u64 = (current_timestamp - last_claim_timestamp)
        .try_into()
        .unwrap();
    let apy_available: bool = current_timestamp > apy.lock_time;

    let apy_to_use = if apy_available {
        match locktime {
            0 => apy.apy_day_1,
            1 => apy.apy_month_1,
            3 => apy.apy_month_3,
            6 => apy.apy_month_6,
            12 => apy.apy_year_1,
            _ => {
                msg!("Unknown timelock");
                return 0;
            }
        }
    } else {
        match locktime {
            0 => apy.last_apy_day_1,
            1 => apy.last_apy_month_1,
            3 => apy.last_apy_month_3,
            6 => apy.last_apy_month_6,
            12 => apy.last_apy_year_1,
            _ => {
                msg!("Unknown timelock");
                return 0;
            }
        }
    };

    (((amount * apy_to_use / 100) / 10 / (365 * 24 * 60 * 60)) * time_diff)  // Get 10% of Reward
        .try_into()
        .unwrap()
}