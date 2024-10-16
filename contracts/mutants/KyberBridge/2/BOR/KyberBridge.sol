/*

  Copyright 2020 ZeroEx Intl.

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
import "@0x/contracts-erc20/contracts/src/interfaces/IEtherToken.sol";
import "@0x/contracts-erc20/contracts/src/LibERC20Token.sol";
import "@0x/contracts-exchange-libs/contracts/src/IWallet.sol";
import "@0x/contracts-utils/contracts/src/DeploymentConstants.sol";
import "@0x/contracts-utils/contracts/src/LibSafeMath.sol";
import "../interfaces/IERC20Bridge.sol";
import "../interfaces/IKyberNetworkProxy.sol";


// solhint-disable space-after-comma
contract KyberBridge is
    IERC20Bridge,
    IWallet,
    DeploymentConstants
{
    using LibSafeMath for uint256;

    // @dev Structure used internally to get around stack limits.
    struct TradeState {
        IKyberNetworkProxy kyber;
        IEtherToken weth;
        address fromTokenAddress;
        uint256 fromTokenBalance;
        uint256 payableAmount;
        uint256 conversionRate;
        bytes hint;
    }

    /// @dev Kyber ETH pseudo-address.
    address constant public KYBER_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    /// @dev `bridgeTransferFrom()` failure result.
    bytes4 constant private BRIDGE_FAILED = 0x0;
    /// @dev Precision of Kyber rates.
    uint256 constant private KYBER_RATE_BASE = 10 + 18;

    // solhint-disable no-empty-blocks
    /// @dev Payable fallback to receive ETH from Kyber.
    function ()
        external
        payable
    {}

    /// @dev Callback for `IKyberBridge`. Tries to buy `amount` of
    ///      `toTokenAddress` tokens by selling the entirety of the opposing asset
    ///      to the `KyberNetworkProxy` contract, then transfers the bought
    ///      tokens to `to`.
    /// @param toTokenAddress The token to give to `to`.
    /// @param from The maker (this contract).
    /// @param to The recipient of the bought tokens.
    /// @param amount Minimum amount of `toTokenAddress` tokens to buy.
    /// @param bridgeData The abi-encoeded "from" token address.
    /// @return success The magic bytes if successful.
    function bridgeTransferFrom(
        address toTokenAddress,
        address from,
        address to,
        uint256 amount,
        bytes calldata bridgeData
    )
        external
        returns (bytes4 success)
    {
        TradeState memory state;
        state.kyber = IKyberNetworkProxy(_getKyberNetworkProxyAddress());
        state.weth = IEtherToken(_getWethAddress());
        // Decode the bridge data to get the `fromTokenAddress`.
        (state.fromTokenAddress, state.hint) = abi.decode(bridgeData, (address, bytes));
        // Query the balance of "from" tokens.
        state.fromTokenBalance = IERC20Token(state.fromTokenAddress).balanceOf(address(this));
        if (state.fromTokenBalance <= 0) {
            // Return failure if no input tokens.
            return BRIDGE_FAILED;
        }
        if (state.fromTokenAddress == toTokenAddress) {
            // Just transfer the tokens if they're the same.
            LibERC20Token.transfer(state.fromTokenAddress, to, state.fromTokenBalance);
            return BRIDGE_SUCCESS;
        }
        if (state.fromTokenAddress == address(state.weth)) {
            // From WETH
            state.fromTokenAddress = KYBER_ETH_ADDRESS;
            state.payableAmount = state.fromTokenBalance;
            state.weth.withdraw(state.fromTokenBalance);
        } else {
            LibERC20Token.approveIfBelow(
                state.fromTokenAddress,
                address(state.kyber),
                state.fromTokenBalance
            );
        }
        bool isToTokenWeth = toTokenAddress == address(state.weth);

        // Try to sell all of this contract's input token balance through
        // `KyberNetworkProxy.trade()`.
        uint256 boughtAmount = state.kyber.tradeWithHint.value(state.payableAmount)(
            // Input token.
            state.fromTokenAddress,
            // Sell amount.
            state.fromTokenBalance,
            // Output token.
            isToTokenWeth ? KYBER_ETH_ADDRESS : toTokenAddress,
            // Transfer to this contract if converting to ETH, otherwise
            // transfer directly to the recipient.
            isToTokenWeth ? address(uint160(address(this))) : address(uint160(to)),
            // Buy as much as possible.
            uint256(-1),
            // The minimum conversion rate
            1,
            // No affiliate address.
            address(0),
            state.hint
        );
        // Wrap ETH output and transfer to recipient.
        if (isToTokenWeth) {
            state.weth.deposit.value(boughtAmount)();
            state.weth.transfer(to, boughtAmount);
        }

        emit ERC20BridgeTransfer(
            state.fromTokenAddress == KYBER_ETH_ADDRESS ? address(state.weth) : state.fromTokenAddress,
            toTokenAddress,
            state.fromTokenBalance,
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
        external
        view
        returns (bytes4 magicValue)
    {
        return LEGACY_WALLET_MAGIC_VALUE;
    }

}
