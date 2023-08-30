# SolarX Token (ERC20)

**SolarX** is an ERC20-compatible token smart contract implemented on the Polygon blockchain.

# Contracts

This folder contains all contracts for solarx.ai. In the root is the actual deployed smart contract for the SolarX erc20 token.

## Features

- ERC20 standard implementation
- Transaction commission mechanism for certain transfers. (Future implementation)

# Usage

To interact with the SolarX token, you can deploy the smart contract on the Polygon blockchain or a blockchain of your choice compatible with the ERC-20 Token Standard.

- **Transfer Tokens:** Use the `transfer` and `transferFrom` functions to move SolarX tokens between addresses, with a portion of the transaction amount going to a designated mining pool if there is a transfer fee set.
- **Mint Tokens:** Only addresses with the `MINTER_ROLE` can mint new tokens.
- **Burn Tokens:** Only the address of `advisors` can burn a limited amount of tokens.

**Note** - **[SolarX team]**: We will run in two blockchains, polygon blockchain and x chain of SOLARX blockchain. For example, if a user request withdraw of 100, from X CHAIN to send to the POLYGON BLOCKCHAIN the mint will be functionalize on polygon chain and if the max supply is 1000, it will add 100$ more dollars to the max supply. However, the total max supply will be fixed and wont change even if the users transfer from one blockchain to the other.

Coins are minted on the receiving chain when transferred from one chain to another and burned on the sending chain, helping maintain a consistent coin supply and ensuring the integrity of the overall network. It provides a mechanism for users to seamlessly transfer and utilize the SOLX coin across both chains while mitigating risks associated with any potential disruptions.


## Configuration

- **Mining Pool Address:** The address of the designated mining pool can be set using the `setMiningPoolAddress` function.
- **Commission Percentage:** The commission percentage for transactions can be adjusted using the `setCommissionPercentage` function.
- **Max Burn Limit:** The maximum allowed burn amount can be set using the `setMaxBurn` function.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
