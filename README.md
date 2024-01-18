# Protocol Overview

The protocol is designed to facilitate a token sale with distinct pre-sale and public sale phases. Here's an overview of its functionality:

## Token Association
The contract is associated with an ERC20 token, which is specified at the time of contract deployment.

## Sale Phases
There are two distinct sale phases:

1. **Pre-Sale**: A phase where tokens can be purchased up to a certain cap `PRE_SALE_CAP` with minimum and maximum contribution limits per participant `PRESALE_MINIMUM_CONTRIBUTION_PER_PARTICIPANT` and `PRESALE_MAXIMUM_CONTRIBUTION_PER_PARTICIPANT`.
2. **Public Sale**: A phase with a higher cap `PUBLIC_SALE_CAP` and different minimum and maximum contribution limits per participant `PUBLICSALE_MINIMUM_CONTRIBUTION_PER_PARTICIPANT` and `PUBLICSALE_MAXIMUM_CONTRIBUTION_PER_PARTICIPANT`.
3. **Sale Activation**: The contract owner can activate or deactivate each sale phase using `changePreSaleStatus` and `changePublicSaleStatus` functions.

## Token Purchase
Participants can buy tokens by sending ETH to the `buyTokens` function. The number of tokens received is determined by the `_calculateTokens` function, which converts the ETH amount to a token amount (in this case, at a fixed rate of 1 ETH = 10 tokens).

## Contribution Tracking
Contributions are tracked per address, and the total contributions are recorded to ensure caps are not exceeded.

## Token Distribution
The contract owner can distribute tokens to any address using the `distributeTokens` function.

## Refunds
Participants can request refunds through the `refund` function, which requires them to return the purchased tokens. Refunds are only processed when the pre-sale is not active, and the public sale is either active or has ended, and the participant's contribution is above the minimum threshold.

## Events
The contract emits events for state changes (`PresaleStatusChanged`, `PublicSaleStatusChanged`), token purchases (`TokensPurchased`), token distributions (`TokensDistributed`), and refunds (`RefundProcessed`).

## Error Handling
Custom errors are defined for various failure conditions, such as when a sale is not active, caps are exceeded, or balance requirements are not met.

## Ownership
The contract inherits from OpenZeppelin's `Ownable` contract, which provides basic authorization control functions, simplifying the implementation of user permissions.



# How to run
1.  **Install Foundry**

First, run the command below to get Foundryup, the Foundry toolchain installer:

``` bash
curl -L https://foundry.paradigm.xyz | bash
```

Then, in a new terminal session or after reloading your PATH, run it to get the latest forge and cast binaries:

``` console
foundryup
```

2. **Clone This Repo and install dependencies**
``` 
git clone https://github.com/anjanayraina/Assigment1
cd Assigment1
forge install

```

3. **Run the Tests**

``` 
forge test
```

