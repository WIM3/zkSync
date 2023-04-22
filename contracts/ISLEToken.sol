//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.8;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';


contract ISLEToken is ERC20 {

  string private _name = 'ISLE Token v0.0';
  string private _symbol = 'ISLEv0.0';
  uint8 private _dec = 10;
  uint256 private _totalSupply = 1000000000 * (10 ** uint256(_dec));


    constructor(uint256 initialSupply) ERC20(_name, _symbol) {
        _mint(msg.sender, _totalSupply);
    }
}

