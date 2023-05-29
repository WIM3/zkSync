// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Token.sol";

contract Airdrop is Ownable {
  using SafeMath for uint;
  address public tokenAddr;
  Token public token;

  event EtherTransfer(address beneficiary, uint amount);

  constructor() {}

  function setTokenAddress(address _tokenAddr) public onlyOwner returns (bool) {
    token = Token(_tokenAddr);
    tokenAddr = _tokenAddr;
    return true;
  }

  function dropTokens(
    address[] calldata _recipients,
    uint256[] calldata _amount
  ) public onlyOwner returns (bool) {
    require(_recipients.length == _amount.length);
    for (uint256 i = 0; i < _recipients.length; i++) {
      require(_recipients[i] != address(0));
      require(Token(tokenAddr).transfer(_recipients[i], _amount[i]));
    }

    return true;
  }

  function dropEther(
    address[] calldata _recipients,
    uint256[] calldata _amount
  ) public payable onlyOwner returns (bool) {
    uint total = 0;

    for (uint j = 0; j < _amount.length; j++) {
      total = total.add(_amount[j]);
    }

    require(total <= msg.value);
    require(_recipients.length == _amount.length);

    for (uint i = 0; i < _recipients.length; i++) {
      require(_recipients[i] != address(0));
      (bool success, ) = payable(_recipients[i]).call{ value: _amount[i] }("");
      require(success, "Ether transfer failed");
      emit EtherTransfer(_recipients[i], _amount[i]);
    }

    return true;
  }

  function updateTokenAddress(address _tokenAddr) public onlyOwner {
    token = Token(_tokenAddr);
    tokenAddr = _tokenAddr;
  }

  function withdrawTokens(address beneficiary) public onlyOwner {
    uint256 amount = Token(tokenAddr).balanceOf(address(this));
    // Cast the contract address to an address type
    address tokenAddress = address(Token(tokenAddr));
    // Use call instead of transfer
    (bool success, ) = tokenAddress.call(
      abi.encodeWithSignature("transfer(address,uint256)", beneficiary, amount)
    );
    // Check the return value and revert if failed
    require(success, "Token withdrawal failed");
  }

  function withdrawEther(address payable beneficiary) public onlyOwner {
    uint256 amount = address(this).balance;
    (bool success, ) = beneficiary.call{ value: amount }("");
    require(success, "Ether withdrawal failed");
  }
}
