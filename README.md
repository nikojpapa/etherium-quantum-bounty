# Quantum Bounty with Fallback Account

This repository implements a proof of concept of two parts:
1. A quantum bounty contract
   - This contract has public `locks` and a `withdraw` function, which takes "keys" to the locks. Theoretically, the only way to find the keys should be by necessity of a quantum computer.
   - If someone can call `withdraw` successfully, then it can be assumed that quantum supremacy has been achieved to enough of an extent where a malicious person could either currently break blockchain encryption, or will be able to soon.
   - One has incentive to solve the bounty because all the funds of the contract will be sent to the user that successfully calls `withdraw`.
2. A fallback account
   - This is an account that holds a user's funds.
   - While the bounty contract is unsolved, the account uses standard ECDSA encryption schemes.
   - After the bounty is solved, the account will additionally use a quantum safe encryption scheme.

New contracts and libraries are in `contracts/bounty-contracts` and `contracts/bounty-fallback-account`
New tests are in `test/bounty-contracts` and `tests/bounty-fallback-account`.

Note that these are works in progress, but still show enough proof of concept for viability of similar implementations.

## Current implementations
### Bounty Contract
There are currently three versions of a proof-of-concept for bounty contracts

#### Factoring the product of large primes (PrimeFactoringBounty)
In these bounty contracts, the locks are products of large prime numbers, and the keys are the prime factors that compose the locks. There are two versions:
   1. Products are generated by the contract
      - Located at `contracts/bounty-contracts/prime-factoring-bounty/prime-factoring-bounty-with-lock-generation/PrimeFactoringBountyWithLockGeneration.sol`
      - This relies on [VRFConsumerBase](https://docs.chain.link/vrf/v2/introduction) for randomness, but this implementation is currently untested. However, the core logic for using the randomness is tested and located at `contracts/bounty-contracts/prime-factoring-bounty/prime-factoring-bounty-with-lock-generation/RandomNumberAccumulator.sol` with tests at `test/bounty-contracts/prime-factoring-bounty/prime-factoring-bounty-with-lock-generation/random-number-accumulator.test.ts`.
      - This does not rely on a third party to construct the locks.
      - This is not fully completed, and has a failing test to indicate so. The remaining test is, however, only an optimization.
   2. Products are given in the constructor
       - Located at `contracts/bounty-contracts/prime-factoring-bounty/prime-factoring-bounty-with-predetermined-locks/PrimeFactoringBountyWithPredeterminedLocks.sol`
       - Tests at `test/bounty-contracts/prime-factoring-bounty/prime-factoring-bounty-with-predetermined-locks/prime-factoring-bounty-with-predetermined-locks.test.ts`
      - This reduces gas cost on deployment.

#### Signing messages given public addresses (SignatureBounty)
In this bounty contract, the locks are public addresses given on deploy and the keys are signed messages using the addresses.
   - Located at `contracts/bounty-contracts/signature-bounty/SignatureBounty.sol`
   - Tests at `test/bounty-contracts/signature-bounty/signature-bounty.test.ts`
   - This is more true to what a user would be concerned about when worried about their funds. However, it is more strict than prime factoring as one would expect prime factoring to be one of the first solvable problems on a quantum computer.

### Fallback Account
- Located at `contracts/bounty-fallback-account/BountyFallbackAccount.sol`
- Tests at `test/bounty-fallback-account/bounty-fallback-account.test.ts`

This is an account that uses the standard ECDSA encryption/decryption scheme when transferring funds as long as the linked bounty contract is not solved. If it is solved, then it also requires the correct lamport signature. On every transaction, either before or after the bounty is solved, it also requires a new public lamport key. This is because the private key can only be used once, and since the private key must be sent on each transaction, the public key must be updated as the previous one is no longer secure. This way, as long as the necessary signatures are verified, the lamport key is updated.

Because of this, the signature sent to this account consists of three parts, where they are all sent as bytes one after another. The Lamport keys, normally an 2D array, are sent as just the flattened values one after another in bytes.
1. The ECDSA signature
2. The Lamport signature for the current public key
3. New public Lamport keys for the next transaction


### Deploy scripts
Deploy scripts are located in the `deploy` directory, where a fallback account and an associated `SignatureBounty` was deployed to Goerli.

- Account address: `0xD151E5Fc0a3E895097B705a40B183058036ad111`
- SignatureBounty address: `0xe5c4c1107ed3426eC5c488E6F9D1598d7AFe3A90`


## Dev Info
### Deploying
```bash
npx hardhat deploy --tags <TAGS_EXPORTED_FROM_etherium-quantum-bounty/deploy/...>
```

### Testing
```bash
npx hardhat test --grep "<SUBSTRING_OF_NAME_IN_'DESCRIBE'_FUNCTION>"
```

### Resources
- [Solidity By Example](https://solidity-by-example.org/)
- [Useful Solidity utilities](https://docs.openzeppelin.com/)
      

# README of parent repo
Implementation of contracts for [ERC-4337](https://eips.ethereum.org/EIPS/eip-4337) account abstraction via alternative mempool.

## Resources

[Vitalik's post on account abstraction without Ethereum protocol changes](https://medium.com/infinitism/erc-4337-account-abstraction-without-ethereum-protocol-changes-d75c9d94dc4a)

[Discord server](http://discord.gg/fbDyENb6Y9)

[Bundler reference implementation](https://github.com/eth-infinitism/bundler)

[Bundler specification test suite](https://github.com/eth-infinitism/bundler-spec-tests)
