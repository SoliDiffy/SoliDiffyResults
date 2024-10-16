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

pragma solidity ^0.5.16;
pragma experimental ABIEncoderV2;

import "@0x/contracts-asset-proxy/contracts/src/interfaces/IAssetData.sol";
import "@0x/contracts-exchange/contracts/src/interfaces/IExchange.sol";
import "@0x/contracts-utils/contracts/src/DeploymentConstants.sol";


// solhint-disable no-empty-blocks
contract Addresses is
    DeploymentConstants
{
    address internal exchangeAddress;
    address internal erc20ProxyAddress;
    address internal erc721ProxyAddress;
    address internal erc1155ProxyAddress;
    address internal staticCallProxyAddress;
    address internal chaiBridgeAddress;
    address internal dydxBridgeAddress;

    constructor (
        address exchange_,
        address chaiBridge_,
        address dydxBridge_
    )
        public
    {
        exchangeAddress = exchange_;
        chaiBridgeAddress = chaiBridge_;
        dydxBridgeAddress = dydxBridge_;
        erc20ProxyAddress = IExchange(exchange_).getAssetProxy(IAssetData(address(0)).ERC20Token.selector);
        erc721ProxyAddress = IExchange(exchange_).getAssetProxy(IAssetData(address(0)).ERC721Token.selector);
        erc1155ProxyAddress = IExchange(exchange_).getAssetProxy(IAssetData(address(0)).ERC1155Assets.selector);
        staticCallProxyAddress = IExchange(exchange_).getAssetProxy(IAssetData(address(0)).StaticCall.selector);
    }
}
