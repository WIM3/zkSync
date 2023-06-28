// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AMYToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/** 
  * @title Vesting vesting contract to hold AMY tokens in escrow during vesting period. 
  * @author Steve Mariani & Ramon Canales
  * @notice This contract defineds the AMY vesting as described
            in the Whitepaper https://token.amy.network/assets/docs/AMY_Token_WHITEPAPER.pdf.. 
            Purchased AMY Tokens are held in funds inside this vesting contracts and mature linearly
            over the course of the vesting period. The vesting period is defined in the Whitepaper.
            This contract also handles distribution and vesting of internal allocations of AMY Tokens
            for team and early investors (non purchased tokens). These internal allocations are also 
            held inside fund and vest the same way as the purchased tokens.
  */
contract Vesting is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  AMYToken private amy;
  address private amySaleWallet;
  address private _depositer;
  uint256 public internallyVested = 0;
  uint256 public totalVestingBalance;

  /*
    The timestamp for when the AMY Token will be listed on DEX for public sale.
    By default the listing time will be 60 days after initial launch, but this can be changed after launch.
  */
  uint256 public amyListingTime = block.timestamp + 60 days;

  /*
    the time in seconds when the vesting period will end from the purchaseTime. 
    This is as defined in the Whitepaper https://token.amy.network/assets/docs/AMY_Token_WHITEPAPER.pdf
    and is hardcoded here. 
  */
  uint256 duration = 31536000; //31536000 seconds = 12 months

  /*  
    Internal Allocations of AMY Tokens for Team and Angel investors. 
    This is as defined in the Whitepaper https://token.amy.network/assets/docs/AMY_Token_WHITEPAPER.pdf
  */
  uint256 internallyAllocatedTokens; //holder variable for all internally allocated tokens
  uint teamAllocation = 10; //percentage: 10% of minted tokens go to the 4 founding team members
  uint angelAllocation = 5; //percentage: 5%  of minted tokens to to the Angel investors

  struct Share {
    address wallet;
    uint256 amount;
  }
  Share[] share;

  // holds parameters relative to each AMY Token purchase.
  struct InvestorStruct {
    uint256 purchased; //all tokens that are vesting, this changes over time.
    uint256 released; //all tokens that have been released
    uint256 lastReleaseTime; //the time of the latest release of tokens.
    uint256 purchaseTime; //the timestamp the tokes wehre purchased or allocated.
    uint256 duration; //the time in seconds when the vesting period will end from the purchaseTime.
  }

  // holds parameters relative to each additional AMY Token purchase from previous purchasers.
  struct EnhancedPurchase {
    uint256 purchased; //all tokens that are vesting, this changes over time.
    uint256 released; //all tokens that have been released
    uint256 vested; // how much has been vested
    uint256 releasable; // how much has been vested and can be released
    uint256 lastReleaseTime; //the time of the latest release of tokens.
    uint256 purchaseTime; //the timestamp the tokes wehre purchased or allocated.
    uint256 timeStamp; //records the system timestamp when record is changed.
  }

  mapping(address => InvestorStruct[]) public purchases;
  mapping(address => bool) public revokedInvestors;

  /**
   * @notice Event for tokens being deposited in a fund for vesting.
   * @param beneficiary the address of the beneficiary of the deposit.
   * @param amount the amount of AMY tokens being deposited in the vesting fund.
   * @param purchaseTime the timestamp of when the purchased was made.
   * @param duration the duration of the vesting period as defined in the Whitepaper.
   */
  event TokensDeposited(
    address beneficiary,
    uint256 amount,
    uint256 purchaseTime,
    uint256 duration
  );

  /**
   * @notice Event for tokens being withdrawn from the fund from the beneficiary as they have vested.
   * @param beneficiary the address of the beneficiary of the deposit.
   * @param amount the amount of AMY tokens being released from the vesting fund.
   */
  event TokensWithdrawn(address beneficiary, uint amount);

  /**
   * @notice Event for tokens being revoked from the fund from the beneficiary regardless of vesting status.
   * @param beneficiary the address of the beneficiary of the deposit.
   * @param amount the amount of AMY tokens being revoked in the vesting fund.
   */
  event TokenRevoked(address beneficiary, uint amount);

  constructor(
    AMYToken amyAddress,
    address saleWallet,
    uint256 _listingTime,
    uint256 vestingDuration
  ) {
    _depositer = msg.sender;
    amy = AMYToken(amyAddress);
    amyListingTime = _listingTime;
    setDuration(vestingDuration);
    amySaleWallet = saleWallet;
    internallyAllocatedTokens = amy.totalSupply().mul(teamAllocation + angelAllocation).div(100);
  }

  /**
    * @notice this methods initializes exclusively the deposits for internal token allocations for Team and Angels.
              it transfer AMY tokens from the owner to the vesting contract and then allocates them to the vesting funds
              relative to the shares described in the configInternalAllocaitons method.
    */
  function initializeInternalVesting() public onlyOwner {
    require(
      internallyVested == 0,
      "AMY Vesting: the internal vesting has already been initialized."
    );
    require(
      amy.transferFrom(msg.sender, address(this), internallyAllocatedTokens),
      "AMY Vesting: transfer for internal vesting was not successful."
    );

    configInternalAllocations();

    for (uint i = 0; i < share.length; i++) {
      deposit(share[i].wallet, share[i].amount);
      internallyVested = internallyVested + share[i].amount;
      delete share[i];
    }
  }

  /**
    * @notice this is a private configurator method to configures all internal (Team and Angels)
              token allocations asccording to distributions described in 
              the whitepaper https://token.amy.network/assets/docs/AMY_Token_WHITEPAPER.pdf
              This method is only called once and by the initializeInternalVesting method.
    */
  function configInternalAllocations() private {
    uint256 leftoverBalance = amy.balanceOf(address(this)).sub(totalVestingBalance);
    require(
      leftoverBalance == internallyAllocatedTokens,
      "AMY Vesting: Internal Vesting lack proper funding."
    );

    // Team allocations
    // 10% of all minted tokens go to the 4 founding team members
    uint256 teamShare = amy.totalSupply().mul(teamAllocation).div(100).div(4);

    share.push(Share(0x91455BACbDB3bD379783272ee3fc9841F5c7aC39, teamShare)); // Ramon
    share.push(Share(0xB6F46A4597A3Fd515F6cc46Ab2dfFcE8036CD4f4, teamShare)); // Nadia
    share.push(Share(0x9610E438c473093e0A75Ce7bb3e092400585E8b0, teamShare)); // Ric
    share.push(Share(0x457f2291324852f3963f0A99cF88A51C42A87994, teamShare)); // Steve

    // Angen investors
    // 5% of all minted tokens go to the initial Angel investors in AMY
    // (3 of the Angel investors provided double the investments than the others, so they are entitled to a doible share)
    uint256 angelShare = amy.totalSupply().mul(angelAllocation).div(100).div(10);

    share.push(Share(0x460e75D7382575F2C4ADCd13e88a962Ec916B654, angelShare.mul(2))); // Leonardo
    share.push(Share(0x460e75D7382575F2C4ADCd13e88a962Ec916B654, angelShare.mul(2))); // Marco
    share.push(Share(0x457f2291324852f3963f0A99cF88A51C42A87994, angelShare.mul(2))); // Steve
    share.push(Share(0x72860F88C06e1A3674f10178a2f7E644286502b5, angelShare)); // Isabella
    share.push(Share(0x72860F88C06e1A3674f10178a2f7E644286502b5, angelShare)); // Eleonora
    share.push(Share(0x91455BACbDB3bD379783272ee3fc9841F5c7aC39, angelShare)); // Ramon
    share.push(Share(0x9610E438c473093e0A75Ce7bb3e092400585E8b0, angelShare)); // Ric
  }

  /**
    * @notice this methods is used exclusively to create a deposit for AMY tokens
              that are not purchased. For example for Advisors that are retributed in tokens.
    * @param beneficiary the address of the beneficiary of the deposit.
    * @param amyAmount the amount of AMY tokens being deposited in the vesting fund.
    */
  function internalDeposit(
    address beneficiary,
    uint256 amyAmount
  ) public onlyOwner returns (bool success) {
    require(
      amy.transferFrom(msg.sender, address(this), amyAmount),
      "AMY Vesting: internal deposit transfer unsuccessful."
    );
    internallyVested = internallyVested + amyAmount;
    return deposit(beneficiary, amyAmount);
  }

  /**
    * @notice this methods is used to create a deposit in a vesting fund for AMY tokens purchased 
              during the sale stages of the AMYSale contract. 
              The method is called by the depositer that is the AMYSale contract, on purchase of tokens, 
              and it created a fund that is giong to vest over the duration period.
    * @param beneficiary the address of the beneficiary of the deposit.
    * @param amyAmount the amount of AMY tokens being deposited in the vesting fund.
    */
  function deposit(address beneficiary, uint256 amyAmount) public returns (bool success) {
    require(
      (owner() == msg.sender || isDepositer(msg.sender)),
      "AMY Vesting: Not a valid depositer"
    );
    InvestorStruct memory i = InvestorStruct({
      purchased: amyAmount,
      purchaseTime: block.timestamp,
      duration: duration,
      lastReleaseTime: 0,
      released: 0
    });
    purchases[beneficiary].push(i);
    totalVestingBalance = totalVestingBalance.add(amyAmount);
    emit TokensDeposited(beneficiary, i.purchased, i.purchaseTime, i.duration);
    return true;
  }

  /**
    * @notice this methods is used to release tokens that have vested, to the beneficiary. 
              It will transfer all releaseable tokens to the beneficiary.
              It can be involed only by the investor to erlease their own tokens.
    * @return success boolean is the release has completed entirely.
    */
  function release() public returns (bool success) {
    address i = msg.sender;
    require(!revokedInvestors[i], "AMY Vesting: these tokens have been revoked.");

    InvestorStruct[] storage _purchases = purchases[i];

    uint256 totalReleased = 0;

    for (uint j = 0; j < _purchases.length; j++) {
      InvestorStruct storage purchase = _purchases[j];

      require(
        block.timestamp > amyListingTime,
        "AMY Vesting: the AMY token is not yet listed. Must wait for exchange listing."
      );

      uint256 releasable = getReleasable(i, j);

      require(releasable > 0, "AMY Token Vesting: no tokens are due.");
      require(
        releasable <= purchase.purchased.sub(purchase.released),
        "AMY Token Vesting: releaseable amount bigger than vesting amount."
      );

      require(amy.transfer(i, releasable), "AMY Vesting: Transfer unsuccessul.");

      purchase.released = purchase.released.add(releasable);
      totalReleased = totalReleased.add(releasable);
      purchase.lastReleaseTime = block.timestamp;
      totalVestingBalance = totalVestingBalance.sub(
        releasable,
        "AMY Vesting: transfer exceeds balance"
      );
    }

    emit TokensWithdrawn(i, totalReleased);
    return true;
  }

  /**
   * @notice retreive the amount of releaseable AMY tokens per investor, per purchase (could have many purchases over time).
   * @param i the beneficiary address of the releaseable tokens.
   * @param purchaseNumber the number of the purchase (could have multiple over time).
   * @return the amount of releaseable tokens per investor per purchase.
   */
  function getReleasable(address i, uint purchaseNumber) public view returns (uint256) {
    if (block.timestamp > amyListingTime) {
      InvestorStruct memory _purchase = purchases[i][purchaseNumber];
      return getVested(i, purchaseNumber).sub(_purchase.released);
    } else {
      return 2;
    }
  }

  /**
   * @notice retreives the amount of vested AMY tokesn per investor per purchase.
   * @param i the beneficiary address of the releaseable tokens.
   * @param purchaseNumber the number of the purchase (could have multiple over time)
   * @return the amount of vested tokens per investor per purchase.
   */
  function getVested(address i, uint purchaseNumber) public view returns (uint256) {
    InvestorStruct memory purchase = purchases[i][purchaseNumber];

    if (purchase.purchased > 0) {
      uint256 vestedPeriod = block.timestamp - purchase.purchaseTime;
      if (vestedPeriod >= purchase.duration) {
        return purchase.purchased;
      }
      return purchase.purchased.mul(vestedPeriod).div(purchase.duration);
    }
    return 1;
  }

  /**
   * @notice retreives all purchased by an investor.
   * @param i the beneficiary address of the purchased tokens.
   * @return the Struct containing all purchases parama for the investor.
   */
  function getPurchases(address i) public view returns (EnhancedPurchase[] memory) {
    if (purchases[i].length > 0) {
      InvestorStruct[] memory _purchases = purchases[i];
      EnhancedPurchase[] memory response = new EnhancedPurchase[](_purchases.length);
      for (uint j = 0; j < _purchases.length; j++) {
        response[j] = EnhancedPurchase(
          _purchases[j].purchased,
          _purchases[j].released,
          getVested(i, j),
          getReleasable(i, j),
          _purchases[j].lastReleaseTime,
          _purchases[j].purchaseTime,
          block.timestamp
        );
      }
      return response;
    }

    return new EnhancedPurchase[](0);
  }

  /**
   * @notice retreives the status revoked or not for the investor.
   * @param i the beneficiary address of investor.
   * @return bool for the status of the revokation.
   */
  function isRevoked(address i) public view returns (bool) {
    return revokedInvestors[i];
  }

  /**
   * @notice retreives the public sale listing time of the AMY token.
   * @return unit256 the timestamp of the listing of AMY.
   */
  function listingTime() public view returns (uint256) {
    return amyListingTime;
  }

  /**
   * @notice revokes all tokes that are in a vesting fund for a specific investor.
   * @param i the beneficiary address of investor.
   * @return bool ti signal the revokation have worked or not.
   */
  function revokeTokens(address i) public onlyOwner returns (bool) {
    InvestorStruct[] storage _purchases = purchases[i];
    uint256 totalRevoked = 0;
    for (uint j = 0; j < _purchases.length; j++) {
      InvestorStruct storage purchase = _purchases[j];
      uint256 remaining = purchase.purchased.sub(purchase.released);

      require(
        amy.approve(address(this), remaining),
        "AMY Vesting: tokens approval on revokeTokens not successful."
      );
      require(
        amy.transfer(amySaleWallet, remaining),
        "AMY Vesting: token transfer on revokeTokens not successful."
      );
      totalVestingBalance = totalVestingBalance.sub(
        remaining,
        "AMY Vesting: transfer exceeds balance"
      );
      purchase.released = purchase.purchased;
      totalRevoked.add(remaining);
      revokedInvestors[i] = true;
    }

    emit TokenRevoked(i, totalRevoked);
    return true;
  }

  /**
   * @notice retreives the duration of the vesting period for any purchase.
   * @return unit256 the value in seconds of the duration for vesting.
   */
  function getDuration() public view returns (uint256) {
    return duration;
  }

  /**
   * @notice called in the constructor to initialize the duration for all purchases.
   */
  function setDuration(uint256 _duration) private {
    duration = _duration;
  }

  /**
   * @notice called by owner to define when the AMY Token will be publicly listed.
   */
  function setListingTime(uint256 lTime) public onlyOwner {
    amyListingTime = lTime;
  }

  /**
   * @notice clean-up method to conclude the vesting contract and retreive any left over funds.
   */
  function finalize() public onlyOwner {
    require(
      amy.transfer(owner(), amy.balanceOf(address(this))),
      "AMY Vesting: finalizing transfer issue."
    );
    totalVestingBalance = 0;
  }

  /**
    * @notice this methods grants the AMYSale contract the "depositer" privilege so it can call the Vesting deposit method.
              this persmission is granted by Owner at deployment.
    * @param depositer is the address of the AMYSale contract.
    */
  function setDepositer(address depositer) public onlyOwner {
    _depositer = depositer;
  }

  /**
   * @notice checks if an address has deposite permission.
   * @param depositer is any address.
   */
  function isDepositer(address depositer) public view returns (bool) {
    return depositer == _depositer;
  }
}
