// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

//import "@matterlabs/hardhat-zksync-verify";

contract Token is ERC20 {
  uint8 private _dec = 18;
  uint256 private _totalSupply = 1000000000 * (10 ** uint256(_dec));

  constructor() ERC20("GALL v1.0", "GALL") {
    _mint(msg.sender, _totalSupply);
  }
}
