# Project Name
Solex Launch

# Description
1. Incomplete Claiming Process Controls
    
    The program allows contributors to continue making contributions even after they are able to start claiming their rewards, which is achieved by boolean variable `claiming_enabled` is set to true. This practice deviates from standard presale mechanisms where, typically, contributions are halted once the claiming phase begins. Allowing contributions to continue after the commencement of the claiming phase could lead to confusion among participants and potential discrepancies. This issue arises from the lack of a check in the `contribute` function to prevent new contributions once the claiming phase is active.
    
2. Program Centralization Risk
    
    The programs's functionality and behavior are heavily dependent on external parameters or configurations. While external configuration can offer flexibility, it also poses several centralization risks that warrant attention. Centralization risks arising from the dependence on external configuration include Single Point of Control, Vulnerability to Attacks, Operational Delays, Trust Dependencies, and Decentralization Erosion.
    
    Furthermore, after the admin sets these key configurations, they have the authority to change some of these initial values that are crucial for the smooth functionality of the program.
    
    Lastly, the admin has to enable the claiming of rewards that is initially disabled. Once it is enabled, it can never be disabled again.

# Root Cause
```solidity
// Incomplete Claiming Process Controls
pub fn contribute(ctx: Context<ContributeSOL>, amount: u64) -> Result<()> {
    ... 
    Ok(())
}

// Program Centralization Risk
pub fn create_presale(...)->Result<()>{...}

pub fn enable_claiming(ctx: Context<UpdatePresalePool>) -> Result<()> {
    let pool = &mut ctx.accounts.presale;
    pool.claiming_enabled = true;
    Ok(())
}

pub fn change_sale_dates(
    ctx: Context<UpdatePresalePool>,
    start_timestamp: i64,
    end_timestamp: i64
) -> Result<()> {
    let pool = &mut ctx.accounts.presale;

    // Check that the start_timestamp is less than the end_timestamp
    require!(start_timestamp < end_timestamp, PresaleError::EndTimestampIsBeforeStartTimestamp);

    pool.start_timestamp = start_timestamp;
    pool.end_timestamp = end_timestamp;

    Ok(())
}