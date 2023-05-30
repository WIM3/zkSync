// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
  string private _name;
  string private _symbol;
  address private _owner;
  uint8 private _dec = 18;
  uint256 private _totalSupply = 1000000000 * (10 ** uint256(_dec));

  /*
  constructor() ERC20("GALL v1.0", "GALL") {
    _mint(msg.sender, _totalSupply);
  }
*/
  constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {
    _name = name_;
    _symbol = symbol_;
    _owner = msg.sender;
    _mint(_owner, _totalSupply);
  }

  modifier onlyOwner() {
    require(msg.sender == _owner, "Only the contract owner can call this function");
    _;
  }

  function changeName(string memory newName) external onlyOwner {
    _name = newName;
  }

  function changeSymbol(string memory newSymbol) external onlyOwner {
    _symbol = newSymbol;
  }
}
