/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;
pragma experimental ABIEncoderV2;

import "@0x/contracts-erc20/contracts/src/interfaces/IERC20Token.sol";
import "@0x/contracts-erc20/contracts/src/LibERC20Token.sol";
import "@0x/contracts-exchange-libs/contracts/src/IWallet.sol";
import "@0x/contracts-utils/contracts/src/DeploymentConstants.sol";
import "../interfaces/IERC20Bridge.sol";
import "../interfaces/IShell.sol";


contract ShellBridge is
    IERC20Bridge,
    IWallet,
    DeploymentConstants
{

    /// @dev Swaps specified tokens against the Shell contract
    /// @param toTokenAddress The token to give to `to`.
    /// @param from The maker (this contract).
    /// @param to The recipient of the bought tokens.
    /// @param amount Minimum amount of `toTokenAddress` tokens to buy.
    /// @param bridgeData The abi-encoded "from" token address.
    /// @return success The magic bytes if successful.
    // solhint-disable no-unused-vars
    function bridgeTransferFrom(
        address toTokenAddress,
        address from,
        address to,
        uint256 amount,
        bytes calldata bridgeData
    )
        public
        returns (bytes4 success)
    {
        // Decode the bridge data to get the `fromTokenAddress` and `pool`.
        (address fromTokenAddress, address pool) = abi.decode(bridgeData, (address, address));

        uint256 fromTokenBalance = IERC20Token(fromTokenAddress).balanceOf(address(this));
        // Grant an allowance to the exchange to spend `fromTokenAddress` token.
        LibERC20Token.approveIfBelow(fromTokenAddress, pool, fromTokenBalance);

        // Try to sell all of this contract's `fromTokenAddress` token balance.
        uint256 boughtAmount = IShell(pool).originSwap(
            fromTokenAddress,
            toTokenAddress,
            fromTokenBalance,
            amount, // min amount
            block.timestamp + 1
        );
        LibERC20Token.transfer(toTokenAddress, to, boughtAmount);

        emit ERC20BridgeTransfer(
            fromTokenAddress,
            toTokenAddress,
            fromTokenBalance,
            boughtAmount,
            from,
            to
        );
        return BRIDGE_SUCCESS;
    }

    /// @dev `SignatureType.Wallet` callback, so that this bridge can be the maker
    ///      and sign for itself in orders. Always succeeds.
    /// @return magicValue Magic success bytes, always.
    function isValidSignature(
        bytes32,
        bytes calldata
    )
        public
        view
        returns (bytes4 magicValue)
    {
        return LEGACY_WALLET_MAGIC_VALUE;
    }
}
