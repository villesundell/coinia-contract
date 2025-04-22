# The remastered token smart contract for Coinia Vy

**Coinia Vy** is arguably the first legal experiment to get a tokenized smart contract–based organization officially registered (in Finland, Business ID [2755797‑6](https://opencorporates.com/companies/fi/2755797-6)) without any traditional paperwork for the organization itself (such as bylaws). You can read more about the experiment in my blog post, “[Creating a ‘chainterprise’ in Finland on Ethereum](https://www.linkedin.com/pulse/creating-chainterprise-finland-ethereum-ville-sundell/)” (2016).

## Remastered version (2025)

This release is a remastered version of the original 2016 code. It adheres to modern Solidity coding conventions, is a [Truffle](https://github.com/trufflesuite/truffle) project, and is released under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

This codebase results in the correct (Mainnet‑deployed) [bytecode](./build/contracts/CoiniaVy.json) when built with:

* Truffle v5.11.5 (core 5.11.5)
* Ganache v7.9.1
* Solidity v0.4.4+commit.4633f3de (solc-js)
* Node v20.2.0
* Web3.js v1.10.0

## Original version (2016)

The raw source code, as it was on Nov 6, 2016, is published under DOI [10.5281/zenodo.12511117](https://doi.org/10.5281/zenodo.12511117) and licensed under [GPL v2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html).

The token contract was deployed at [**0x69F2A483a2ad4B910Fa03A0F380d61f6DBE20017**](https://etherscan.io/address/0x69F2A483a2ad4B910Fa03A0F380d61f6DBE20017) on Ethereum Mainnet block [**#2577204**](https://etherscan.io/block/2577204) (Nov 6, 2016 02:37:14 PM UTC) in transaction [**0x298c55f9c71ddf7a45e8771338e069d5f54a649d93c72bfc89043bbd28250430**](https://etherscan.io/tx/0x298c55f9c71ddf7a45e8771338e069d5f54a649d93c72bfc89043bbd28250430).

*The latest version of this repository is published under DOI [10.5281/zenodo.12511116](https://zenodo.org/doi/10.5281/zenodo.12511116).*
