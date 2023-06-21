// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "solidity-bytes-utils/contracts/BytesLib.sol";

import "../BountyContract.sol";
import "./BigNumbers.sol";
import "./miller-rabin/MillerRabin.sol";

abstract contract PrimeFactoringBounty is BountyContract {
  using BigNumbers for *;

  function _verifySolution(uint256 lockNumber, bytes[] memory solution) internal view override returns (bool) {
    BigNumber memory product = BigNumbers.one();
    for (uint256 i = 0; i < solution.length; i++) {
      bytes memory primeFactor = solution[i];
      require(MillerRabin.isPrime(primeFactor), 'Given solution is not prime');
      product = product.mul(primeFactor.init(false));
    }

    BigNumber memory lock = locks[lockNumber].init(false);
    return product.eq(lock);
  }
}
