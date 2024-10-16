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

import "@0x/contracts-extensions/contracts/src/LibAssetDataTransfer.sol";
import "../src/MixinExchangeWrapper.sol";
import "../src/MixinReceiver.sol";


contract TestForwarder is
    MixinExchangeWrapper,
    MixinReceiver
{
    using LibAssetDataTransfer for bytes;

    // solhint-disable no-empty-blocks
    constructor ()
        public
        MixinExchangeWrapper(
            address(0),
            address(0)
        )
    {}

    function areUnderlyingAssetsEqual(
        bytes memory assetData1,
        bytes memory assetData2
    )
        public
        returns (bool)
    {
        /* return _areUnderlyingAssetsEqual(
            assetData1,
            assetData2
        ); */
    }

    function transferOut(
        bytes memory assetData,
        uint256 amount
    )
        public
    {
        assetData.transferOut(amount);
    }
}
