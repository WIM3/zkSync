// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AMYToken.sol";
import "./Vesting.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/** 
  * @title TokenSale sale contract. 
  * @author Steve M
  * @notice This contract is for the sale of AMY tokens in exchange for USDC tokens. 
            There are 5 sale stages each with its rate and cap.
            Stage caps and rates are hardcoded and 
            as defined in the Whitepaper https://token.amy.network/assets/docs/AMY_Token_WHITEPAPER.pdf.
  */
contract TokenSale is Ownable {
  using SafeMath for uint256;

  uint256 private rate;
  uint256 private cap;
  address private wallet;
  Token private myToken;
  Vesting private vesting;
  IERC20 private paymentCoin;

  enum SaleStage {
    SeedSale,
    PrivateSale1,
    PrivateSale2,
    PrivateSale3,
    Ended
  }
  SaleStage private stage;

  struct SaleStageProps {
    uint256 rate;
    uint256 cap;
  }

  mapping(SaleStage => SaleStageProps) private stages;

  mapping(SaleStage => uint256) stageTotalDeposit;

  /**
   * @notice Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokensPurchased(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );

  /**
   * @notice Event for token vesting logging fund launch
   * @param beneficiary who will get the tokens once they are vested
   * @param fund vest fund that will received the tokens
   * @param tokenAmount amount of tokens purchased
   */
  event TokensVested(address indexed beneficiary, address fund, uint256 tokenAmount);

  /**
   * @notice In the constructur we setup the allocations and rages for the 5 sale stages.
   */
  constructor(
    address amyAddress,
    address vestingAddress,
    address payable saleWallet,
    address erc20Token
  ) {
    amy = AMYToken(amyAddress);
    vesting = Vesting(vestingAddress);
    wallet = saleWallet;
    paymentCoin = IERC20(erc20Token);

    stages[SaleStage.SeedSale] = SaleStageProps(2000, amy.totalSupply().mul(10).div(100));
    stages[SaleStage.PrivateSale1] = SaleStageProps(667, amy.totalSupply().mul(9).div(100));
    stages[SaleStage.PrivateSale2] = SaleStageProps(500, amy.totalSupply().mul(8).div(100));
    stages[SaleStage.PrivateSale3] = SaleStageProps(400, amy.totalSupply().mul(7).div(100));
    stages[SaleStage.Ended] = SaleStageProps(200, 0);

    setStage(0);
  }

  /**
   * @notice gets the Vesting contract.
   * @return vesting.
   */
  function getVesting() public view returns (Vesting) {
    return vesting;
  }

  /**
   * @notice gets the AMYToken contract.
   * @return amy.
   */
  function getToken() public view returns (IERC20) {
    return amy;
  }

  /**
   * @notice gets the wallet address where sale proceeds are deposited.
   * @return wallet.
   */
  function getWallet() public view returns (address) {
    return wallet;
  }

  /**
   * @notice gets the current sale rate between USDC and AMY tokens. The rate is "sale stage" dependednt.
   * @return rate the current sale conversion rate from USDC to AMY.
   */
  function getRate() public view returns (uint256) {
    return rate;
  }

  /**
   * @notice gets the current sale supply of AMY tokens. This is variates as tokens are sold.
   * @return amy.balanceOf(address(this)) the sale contract's current holding of AMY tokens.
   */
  function saleSupply() public view returns (uint256) {
    return amy.balanceOf(address(this));
  }

  /**
   * @notice gets the current sale max cap of AMY tokens, based on the current "sale stage".
   * @return cap the private variable holding the current cap limit.
   */
  function getCap() public view returns (uint256) {
    return cap;
  }

  /**
   * @notice gets the current sale stage.
   * @return stage the current sale contract stage.
   */
  function getStage() public view returns (SaleStage) {
    return stage;
  }

  /**
   * @notice sets the current sale stage.
   */
  function setStage(uint newStage) public onlyOwner {
    if (uint(SaleStage.SeedSale) == newStage) {
      stage = SaleStage.SeedSale;
    } else if (uint(SaleStage.PrivateSale1) == newStage) {
      stage = SaleStage.PrivateSale1;
    } else if (uint(SaleStage.PrivateSale2) == newStage) {
      stage = SaleStage.PrivateSale2;
    } else if (uint(SaleStage.PrivateSale3) == newStage) {
      stage = SaleStage.PrivateSale3;
    } else if (uint(SaleStage.Ended) == newStage) {
      stage = SaleStage.Ended;
    }

    rate = stages[stage].rate;
    cap = stages[stage].cap;
  }

  struct SaleStageRow {
    SaleStage stage;
    SaleStageProps props;
    bool active;
  }

  /**
   * @notice gets the state of aech stage of the sale.
   * @return SaleStageRow[] the state of each sale stage.
   */
  function getStages() public view returns (SaleStageRow[] memory) {
    SaleStageRow[] memory response = new SaleStageRow[](4);

    response[0] = SaleStageRow(
      SaleStage.SeedSale,
      stages[SaleStage.SeedSale],
      stage == SaleStage.SeedSale
    );
    response[1] = SaleStageRow(
      SaleStage.PrivateSale1,
      stages[SaleStage.PrivateSale1],
      stage == SaleStage.PrivateSale1
    );
    response[2] = SaleStageRow(
      SaleStage.PrivateSale2,
      stages[SaleStage.PrivateSale2],
      stage == SaleStage.PrivateSale2
    );
    response[3] = SaleStageRow(
      SaleStage.PrivateSale3,
      stages[SaleStage.PrivateSale3],
      stage == SaleStage.PrivateSale3
    );

    return response;
  }

  /**
   * @notice this if to end and finilized the sale contract once all sales and stages are over. Any funds lefts are transferred back to owner.
   */
  function finalize() public onlyOwner {
    require(
      amy.transfer(owner(), amy.balanceOf(address(this))),
      "AMY Vesting: finilizing transfer issue."
    );
  }

  /** 
    * @notice called from the front-end when an investors buys AMY tokens. This will 
              check all the requirements and then transfer the just purchased AMY token 
              into a vesting contract fund calling the vesting.deposit method.
    */
  function buyVesting(uint256 amount) public {
    //best if these are done on the client side
    require(
      address(vesting) != address(0),
      "AMY Vesting: contract undefined, needs to be configured."
    );
    require(
      vesting.listingTime() > block.timestamp,
      "AMY Sale: the AMY Token is already listed, this sale is closed."
    );
    require(
      paymentCoin.balanceOf(msg.sender) >= amount,
      "AMY Sale: need more balance of the purchasing token."
    );
    require(amount > 0, "AMY Sale: need to purchese more then zero.");

    uint256 supply = amy.balanceOf(address(this));
    require(
      supply > 0 && supply <= amy.totalSupply(),
      "AMY Sale: sale token Supply should be > 0 and <= totalSupply."
    );

    uint256 amyAmount = (amount.mul(rate)).mul(10 ** 12); // this is to catch the difference in decimal between AMY and UADC from 18 to 6 decimals.
    require(amyAmount <= supply, "AMY Sale: not enough AMY Token left for sale.");

    uint256 totalDeposited = 0;
    if (stageTotalDeposit[stage] != 0) {
      totalDeposited = stageTotalDeposit[stage];
    }

    require(
      cap >= totalDeposited.add(amyAmount),
      "AMY Sale: not enough AMY Token left for this stage."
    );

    require(paymentCoin.transferFrom(msg.sender, wallet, amount));

    require(amy.transfer(address(vesting), amyAmount), "AMY Vesting: tokens not transferred.");
    require(vesting.deposit(msg.sender, amyAmount), "AMY Vesting: tokens not deposited.");

    stageTotalDeposit[stage] = totalDeposited.add(amyAmount);

    emit TokensPurchased(msg.sender, address(this), amount, amyAmount);
  }
}
