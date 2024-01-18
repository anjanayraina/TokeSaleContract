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

# Design Choices

The `TokenSaleContract` design reflects several choices aimed at creating a structured and manageable token sale event. Here's a brief explanation of the key design choices:

## Separate Sale Phases
The contract distinguishes between pre-sale and public sale phases to cater to different groups of investors. Pre-sales often offer better terms to early backers or smaller investors, while public sales are open to a wider audience.

## Fixed Caps and Contribution Limits
The contract enforces hard caps on the total amount that can be raised (`PRE_SALE_CAP` and `PUBLIC_SALE_CAP`) and sets minimum and maximum contribution limits per participant for each phase. These limits help prevent individual investors from dominating the sale and ensure wider distribution of tokens.

## Owner-Controlled Sale Activation
The ability for the contract owner to toggle the sale phases on and off provides control over the timing of the sale and the ability to pause or end a sale phase in response to external factors.

## Contribution Tracking
Contributions are tracked per address to enforce individual contribution limits and to facilitate refunds if necessary.

## Simplified Token Pricing
The `_calculateTokens` function uses a fixed exchange rate for simplicity. In a real-world scenario, this could be replaced with a more complex pricing mechanism that accounts for dynamic pricing, bonuses, or tiered discounts.

## Token Distribution
The `distributeTokens` function allows the owner to distribute tokens outside of the sale mechanism, which can be used for airdrops, rewards, or compensating team members and advisors.

## Refund Mechanism
The `refund` function allows participants to get their ETH back if certain conditions are met. This provides a level of protection for participants and can be a trust-building feature.

## Use of SafeERC20
The contract uses OpenZeppelin's SafeERC20 library to safely interact with the ERC20 token contract, protecting against reentrancy and other token-related vulnerabilities.

## Custom Errors
The use of custom errors instead of traditional `require` statements with string messages saves gas and provides clearer error handling.

## Event Emission
Events are emitted for key actions, providing transparency and enabling off-chain services to monitor and react to contract activity.

## Inheritance from Ownable
The contract inherits from OpenZeppelin's `Ownable` to leverage a well-tested implementation of ownership and access control.

# Security Features

## Reentrancy Protection
The use of OpenZeppelin's SafeERC20 library for token transfers helps prevent reentrancy attacks, which are a common vulnerability in smart contracts that handle cryptocurrency transactions.

## Fixed Caps and Contribution Limits
By setting hard caps on the total amount that can be raised and individual contribution limits, the contract prevents excessive contributions that could lead to a monopoly of the token supply and mitigates the risk of a single entity exerting too much influence over the token.

## Owner Privileges and Access Control
The contract inherits from OpenZeppelin's Ownable contract, which provides a secure implementation of ownership and access control. This ensures that only the contract owner can activate or deactivate sale phases and distribute tokens, reducing the risk of unauthorized access.

## Custom Errors
The use of custom errors instead of traditional require statements with string messages not only saves gas but also makes the contract's behavior more predictable by clearly defining the conditions under which functions will revert.

## Event Logging
The contract emits events for significant state changes and actions, such as the activation of sale phases, token purchases, token distributions, and refunds. This transparency helps in monitoring the contract's activity and can aid in the detection of suspicious behavior.

## Checks-Effects-Interactions Pattern
The contract appears to follow the checks-effects-interactions pattern, where state changes are made before external calls (e.g., token transfers), reducing the surface for reentrancy attacks.

## Refund Mechanism
The refund function is designed to allow participants to withdraw their contributions under certain conditions. This function requires participants to return the purchased tokens, which helps prevent token dumping and price manipulation.

## No External Calls in Constructors
The contract does not make external calls in its constructor, which is a good practice to avoid attacks during deployment.

## Immutable State Variables
The use of constant state variables for caps and contribution limits ensures that these values cannot be altered after contract deployment, providing assurance to participants about the rules of the token sale.

## Gas Limitations
The contract does not have functions that could run out of gas due to unbounded loops or excessive computation, which is important for preventing denial-of-service (DoS) attacks.

