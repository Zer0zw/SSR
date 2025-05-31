# Project Name
OriginTrail Starfleet Staking

# Description
1. Missing Funds
    
    As hinted in FR2, contributors will not be able to withdraw their tokens after the minimum threshold is reached, that is once `min_threshold_reached == true`, because of the `require` statement on L103 in the `withdrawTokens()` function.
    
    According to FR4, the owner of the contract has the privilege to transfer its full balance to a custodian during the BRIDGE_PERIOD. Additionally, as per FR5, the owner can perform accounting (i.e. specify who the contributors are and how much they contributed) in the fallback period. This accounting will allow contributors to withdraw the indicated amount of tokens. These 2 operations are of high risk and high impact therefore it is necessary to satisfy:
    
    "NFR2 The Starfleet staking smart contract manager SHALL utilize a secure multisignature wallet for contract management."
    
    However, it is unclear why such an accounting function is needed, since the information regarding the contributors and their deposited amounts are already stored in the list of the `stake` state variable. Calling the `accountStarTRAC` is error prone (e.g., participants could be missed or amounts could be incorrect) and costly (i.e. gas costs) since the number of participants could be very high. If the number of participants is high enough, the function may fail due to an out of gas error, which would mean that the input array of `contributors` and `amounts` needs to be partitioned and the functions needs to be called multiple times for each partition, which would make the process even more error prone.
    
    Moreover, there is no guarantee that the transferred tokens will be returned from the custodian in full and on time, i.e. when the bridge period is over. The contributors have to trust the owner that this will be the case. During the Bridge Launch Period the `custodian` address has no specific interface to comply with and can also be a non-contract. As per FR4, the contract owner can
    withdraw all the tokens to an arbitrary EOA.

# Root Cause
```solidity
// Functional requirement FR2
function withdrawTokens() public {

    require(!min_threshold_reached, "Cannot withdraw if minimum threshold has been reached");
    require(stake[msg.sender] > 0,"Cannot withdraw if there are no tokens staked with this address");
    uint256 amount = stake[msg.sender];
    stake[msg.sender] = 0;

    uint256 participant_index = participant_indexes[msg.sender];
    require(participant_index < participants.length, "Sender is not listed in participant list");
    if (participant_index != participants.length.sub(1)) {
        address last_participant = participants[participants.length.sub(1)];
        participants[participant_index] = last_participant;
        participant_indexes[last_participant] = participant_index;
    }
    participants.pop();

    bool transaction_result = token.transfer(msg.sender, amount);
    require(transaction_result, "Token transaction execution failed!");
    emit TokenWithdrawn(msg.sender, amount);


}