# Crowd Funding Project

A Solidity-based decentralized application enabling users to receive ETH donations for their projects.

## Overview

This project is a smart contract written in Solidity that facilitates ETH donations.  
It allows individuals or organizations to set up a decentralized platform to receive contributions directly from donors.

## Features

- **Decentralized Donations**: Receive ETH directly from donors without intermediaries.
- **Transparent Transactions**: All transactions are recorded on the Ethereum blockchain, ensuring transparency.
- **Secure**: Utilizes Ethereum's security features to protect funds.
- **Deployable on any blockchain**: Has a Pricefeed input area which you can fetch on any blockchain to deploy this smart contract to.

## Prerequisites

- [Foundry](https://book.getfoundry.sh/): A toolkit for Ethereum application development.

## Installation

1. **Install Foundry**:

   Follow the instructions in the [Foundry Book](https://book.getfoundry.sh/getting-started/installation.html) to install Foundry and its components.

2. **Clone the Repository**:

   ```bash
   git clone https://github.com/Heavens01/Crowd_Funding_Project.git
   cd Crowd_Funding_Project
   ```

3. **Build the Project**:

    ```bash
    forge build
    ```

4. **Run Test**: Ensure the smart contract functions correctly by running tests.

    ```bash
    forge test
    ```

5. **Format Solidity Code**: To maintain code consistency, format the Solidity files. I highly recommend you do this.

    ```bash
    forge fmt
    ```

6. **Generate Gas Snapshots**: Measure gas usage with...

    ```bash
    forge snapshot
    ```

7. **Deploy the Contract**: Deploy the smart contract to a blockchain.
    - *Note: You can use the Anvil network as the rpc-url and get the private key of your chosen wallet there too.*

    ```bash
    forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url <your_rpc_url> --private-key <your_private_key>
    ```

    OR run this if you have encrypted your private key and have a keystore

    ```bash
    forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url <your_rpc_url> --account <your_keystore_account_name>
    ```
    
## Using the Makefile

The Makefile includes convenient short commands for deploying and interacting with the project.
Run the following command to see available options:

```bash
make help
```

### Useful Commands
- Deploy the Contract:

```bash
make deploy
```

- Interact with the Contract:

```bash
make interact
```

- Run Tests:

```bash
make test
```

- Format Code:

```bash
make format
```

- Clean Build Files:

```bash
make clean
```

*Refer to the Makefile for additional commands.*

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request for any enhancements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.