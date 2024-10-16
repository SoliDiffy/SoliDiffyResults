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

pragma solidity ^0.5.5;
pragma experimental ABIEncoderV2;

import "@0x/contracts-exchange-libs/contracts/src/LibOrder.sol";
import "@0x/contracts-exchange-libs/contracts/src/LibFillResults.sol";
import "../src/Exchange.sol";


// solhint-disable no-empty-blocks
contract TestExchangeInternals is
    Exchange
{
    event DispatchTransferFromCalled(
        bytes32 orderHash,
        bytes assetData,
        address from,
        address to,
        uint256 amount
    );

    constructor (uint256 chainId)
        public
        Exchange(chainId)
    {}

    function assertValidMatch(
        LibOrder.Order storage leftOrder,
        LibOrder.Order storage rightOrder
    )
        public
        view
    {
        _assertValidMatch(
            leftOrder,
            rightOrder,
            leftOrder.getTypedDataHash(EIP712_EXCHANGE_DOMAIN_HASH),
            rightOrder.getTypedDataHash(EIP712_EXCHANGE_DOMAIN_HASH)
        );
    }

    /// @dev Call `_updateFilledState()` but first set `filled[order]` to
    ///      `orderTakerAssetFilledAmount`.
    function testUpdateFilledState(
        LibOrder.Order storage order,
        address takerAddress,
        bytes32 orderHash,
        uint256 orderTakerAssetFilledAmount,
        LibFillResults.FillResults storage fillResults
    )
        public
        payable
    {
        filled[LibOrder.getTypedDataHash(order, EIP712_EXCHANGE_DOMAIN_HASH)] = orderTakerAssetFilledAmount;
        _updateFilledState(
            order,
            takerAddress,
            orderHash,
            orderTakerAssetFilledAmount,
            fillResults
        );
    }

    function settleOrder(
        bytes32 orderHash,
        LibOrder.Order storage order,
        address takerAddress,
        LibFillResults.FillResults storage fillResults
    )
        public
    {
        _settleOrder(orderHash, order, takerAddress, fillResults);
    }

    function settleMatchOrders(
        bytes32 leftOrderHash,
        bytes32 rightOrderHash,
        LibOrder.Order storage leftOrder,
        LibOrder.Order storage rightOrder,
        address takerAddress,
        LibFillResults.MatchedFillResults storage matchedFillResults
    )
        public
    {
        _settleMatchedOrders(
            leftOrderHash,
            rightOrderHash,
            leftOrder,
            rightOrder,
            takerAddress,
            matchedFillResults
        );
    }

    /// @dev Overidden to only log arguments so we can test `_settleOrder()`.
    function _dispatchTransferFrom(
        bytes32 orderHash,
        bytes memory assetData,
        address from,
        address to,
        uint256 amount
    )
        internal
    {
        emit DispatchTransferFromCalled(
            orderHash,
            assetData,
            from,
            to,
            amount
        );
    }
}
