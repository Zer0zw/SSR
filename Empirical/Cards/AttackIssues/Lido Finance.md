# Project Name
Lido Finance

# Description
The exploit is based on the fact that, as per the [Ethereum consensus layer specification](https://github.com/ethereum/consensus-specs/blob/dev/specs/phase0/beacon-chain.md?ref=blog.lido.fi#deposits), the validator public key is associated with the withdrawal credentials (WC) on the first valid deposit that uses the public key. Subsequent deposits will use the WC from the first deposit even if another WC are specified.

While this design choice is not an issue for self-stakers, it opens an attack vector for delegated staking, including liquid staking protocols. These protocols, Lido among them, use protocol-controlled WC to ensure only the protocol can withdraw users’ funds. In Lido’s case, WC point to a [smart contract managed by the DAO](https://research.lido.fi/t/withdrawal-credentials-in-lido/795/2?ref=blog.lido.fi). The current Ethereum consensus layer design allows a node operator to associate the validator’s public key with the validator-controlled WC by front-running a deposit transaction sent by a protocol with another deposit transaction specifying the same public key, validator-controlled WC, and 1 ETH amount. The end state is a validator managing 1 ETH of node operators’ funds and 32 ETH of users’ funds, fully controlled and withdrawable by the node operator.

# Root Cause
Not Open Source