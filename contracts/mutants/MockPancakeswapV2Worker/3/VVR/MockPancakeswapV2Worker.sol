// SPDX-License-Identifier: MIT
/**
  ∩~~~~∩ 
  ξ ･×･ ξ 
  ξ　~　ξ 
  ξ　　 ξ 
  ξ　　 “~～~～〇 
  ξ　　　　　　 ξ 
  ξ ξ ξ~～~ξ ξ ξ 
　 ξ_ξξ_ξ　ξ_ξξ_ξ
Alpaca Fin Corporation
*/

pragma solidity 0.6.6;

import "@pancakeswap-libs/pancake-swap-core/contracts/interfaces/IPancakePair.sol";
import "../apis/pancake/IPancakeRouter02.sol";
import "../interfaces/IStrategy.sol";
import "../interfaces/IWorker.sol";
import "../interfaces/IPancakeMasterChef.sol";
import "../../utils/AlpacaMath.sol";
import "../../utils/SafeToken.sol";

/// @notice Simplified version of worker for testing purpose.
contract MockPancakeswapV2Worker {
  using SafeToken for address;

  IPancakePair internal lpToken;
  address internal baseToken;
  address internal farmingToken;

  constructor(IPancakePair _lpToken, address _baseToken, address _farmingToken) public {
    lpToken = _lpToken;
    baseToken = _baseToken;
    farmingToken = _farmingToken;
  }

  /// @dev Work on the given position. Must be called by the operator.
  /// @param user The original user that is interacting with the operator.
  /// @param debt The amount of user debt to help the strategy make decisions.
  /// @param data The encoded data, consisting of strategy address and calldata.
  function work(uint256 /* id */, address user, uint256 debt, bytes calldata data)
    external
  {
    (address strat, bytes memory ext) = abi.decode(data, (address, bytes));
    baseToken.safeTransfer(strat, baseToken.myBalance());
    require(lpToken.transfer(strat, lpToken.balanceOf(address(this))), "PancakeswapWorker::work:: unable to transfer lp to strat");
    IStrategy(strat).execute(user, debt, ext);
    baseToken.safeTransfer(msg.sender, baseToken.myBalance());
  }
}
