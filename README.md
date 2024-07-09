# Escrow Smart Contract

This repository contains a Solidity smart contract for a simple escrow system, along with tests and deployment scripts using the Foundry framework.

## Overview

The Escrow contract facilitates a secure transaction between a buyer and a seller, with additional roles for an inspector and a lender. It manages the state of the transaction through various stages, from awaiting payment to completion.

## Contract Features

- Manages four parties: buyer, seller, inspector, and lender
- Implements a state machine for the escrow process
- Allows for deposit, inspection confirmation, sale approval, and cancellation
- Includes access control to ensure only authorized parties can perform specific actions

## Smart Contract

The main contract is `Escrow.sol`, which includes the following key functions:

- `deposit()`: Allows the buyer to deposit funds
- `confirmInspection()`: Allows the inspector to confirm or reject the inspection
- `approveSale()`: Allows the buyer to approve the sale and release funds to the seller
- `cancelSale()`: Allows the buyer to cancel the sale and retrieve the deposited funds

## Getting Started:

### Installation and Deployment

1. Clone the repository:
   ```bash
   git clone https://github.com/mishraji874/Escrow-Smart-Contract.git
2. Navigate to the project directory:
    ```bash
    cd Escrow-Smart-Contract
3. Initialize Foundry and Forge:
    ```bash
    forge init
4. Create the ```.env``` file and paste the [Alchemy](https://www.alchemy.com/) api for the Sepolia Testnet and your Private Key from the Metamask.

5. Compile and deploy the smart contracts:

    If you want to deploy to the local network anvil then run this command:
    ```bash
    forge script script/DeployEscrow.s.sol --rpc-url {LOCAL_RPC_URL} --private-key {PRIVATE_KEY}
    ```
    If you want to deploy to the Sepolia testnet then run this command:
    ```bash
    forge script script/DeployEscrow.s.sol --rpc-url ${SEPOLIA_RPC_URL} --private-key ${PRIVATE_KEY}
### Running Tests

Run the automated tests for the smart contract:

```bash
forge test
```