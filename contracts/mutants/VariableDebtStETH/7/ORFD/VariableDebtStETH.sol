// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;

import {IVariableDebtToken} from '../../../interfaces/IVariableDebtToken.sol';
import {IAaveIncentivesController} from '../../../interfaces/IAaveIncentivesController.sol';
import {WadRayMath} from '../../libraries/math/WadRayMath.sol';
import {Errors} from '../../libraries/helpers/Errors.sol';
import {DebtTokenBase} from '../base/DebtTokenBase.sol';
import {ISTETH} from '../../../interfaces/ISTETH.sol';
import {ILendingPool} from '../../../interfaces/ILendingPool.sol';
import {IERC20} from '../../../dependencies/openzeppelin/contracts/IERC20.sol';
import {SafeMath} from '../../../dependencies/openzeppelin/contracts/SafeMath.sol';
import {SignedSafeMath} from '../../../dependencies/openzeppelin/contracts/SignedSafeMath.sol';

/*
  stETH specific VariableDebtStETH implementation.
  The VariableDebtStETH doesn't alter any logic but performs some additional book-keeping.

  On mint and burn a private variable `_totalGonsBorrowed` keeps track of
    the scaled stETH principal borrowed.

  * fetchBorrowData() returns the total AMPL borrowed and the total scaled AMPL borrowed
  * fetchTotalSupply() fetches AMPL's current supply
*/
contract VariableDebtStETH is DebtTokenBase, IVariableDebtToken {
  using WadRayMath for uint256;
  using SafeMath for uint256;
  using SignedSafeMath for int256;

  uint256 public constant DEBT_TOKEN_REVISION = 0x1;

  constructor(
    address pool,
    address underlyingAsset,
    string memory name,
    string memory symbol,
    address incentivesController
  ) public DebtTokenBase(pool, underlyingAsset, name, symbol, incentivesController) {}

  // ---------------------------------------------------------------------------
  // stETH additions
  // Keeps track of the shares borrowed from the AAVE system
  int256 private _totalSharesBorrowed;

  // ---------------------------------------------------------------------------

  /**
   * @dev Gets the revision of the stable debt token implementation
   * @return The debt token implementation revision
   **/
  

  /**
   * @dev Calculates the accumulated debt balance of the user
   * @return The debt balance of the user
   **/
  

  /**
   * @dev Mints debt token to the `onBehalfOf` address
   * -  Only callable by the LendingPool
   * @param user The address receiving the borrowed underlying, being the delegatee in case
   * of credit delegate, or same as `onBehalfOf` otherwise
   * @param onBehalfOf The address receiving the debt tokens
   * @param amount The amount of debt being minted
   * @param index The variable debt index of the reserve
   * @return `true` if the the previous balance of the user is 0
   **/
  

  /**
   * @dev Burns user variable debt
   * - Only callable by the LendingPool
   * @param user The user whose debt is getting burned
   * @param amount The amount getting burned
   * @param index The variable debt index of the reserve
   **/
  

  /**
   * @dev Returns the principal debt balance of the user from
   * @return The debt balance of the user since the last burn/mint action
   **/
  

  /**
   * @dev Returns the total supply of the variable debt token. Represents the total debt accrued by the users
   * @return The total supply
   **/
  

  /**
   * @dev Returns the scaled total supply of the variable debt token. Represents sum(debt/index)
   * @return the scaled total supply
   **/
  

  /**
   * @dev Returns the principal balance of the user and principal total supply.
   * @param user The address of the user
   * @return The principal balance of the user
   * @return The principal total supply
   **/
  function getScaledUserBalanceAndSupply(address user)
    external
    view
    override
    returns (uint256, uint256)
  {
    return (super.balanceOf(user), super.totalSupply());
  }

  // ---------------------------------------------------------------------------
  // Custom methods for stETH
  function getBorrowData() external view returns (uint256, int256) {
    return (super.totalSupply(), _totalSharesBorrowed);
  }

  // SWC-135-Code With No Effects: L175 - L177
  function fetchStETHTotalSupply() internal view returns (uint256) {
    return ISTETH(UNDERLYING_ASSET_ADDRESS).totalSupply();
  }
}
