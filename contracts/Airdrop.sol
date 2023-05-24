// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
//import "@matterlabs/hardhat-zksync-verify";
import "./ISLEToken.sol";

contract Airdrop is Ownable {
  using SafeMath for uint;

  address public tokenAddr;

  event EtherTransfer(address beneficiary, uint amount);

  constructor() /*address _tokenAddr*/ {
    //tokenAddr = _tokenAddr;
    //owner = payable(msg.sender);
  }

  function setTokenAddress(address _tokenAddr) public onlyOwner returns (bool) {
    tokenAddr = _tokenAddr;
    return true;
  }

  function dropTokens(
    address[] calldata _recipients,
    uint256[] calldata _amount
  ) public onlyOwner returns (bool) {
    for (uint i = 0; i < _recipients.length; i++) {
      require(_recipients[i] != address(0));
      require(ISLEToken(tokenAddr).transfer(_recipients[i], _amount[i]));
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
      payable(_recipients[i]).transfer(_amount[i]);
      emit EtherTransfer(_recipients[i], _amount[i]);
    }

    return true;
  }

  function updateTokenAddress(address newTokenAddr) public onlyOwner {
    tokenAddr = newTokenAddr;
  }

  function withdrawTokens(address beneficiary) public onlyOwner {
    require(
      ISLEToken(tokenAddr).transfer(beneficiary, ISLEToken(tokenAddr).balanceOf(address(this)))
    );
  }

  function withdrawEther(address payable beneficiary) public onlyOwner {
    beneficiary.transfer(address(this).balance);
  }
}
