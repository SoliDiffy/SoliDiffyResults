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

import "../src/StakingProxy.sol";


contract TestStakingProxy is
    StakingProxy
{
    address internal constant SHOULD_REVERT_STAKING_ADDRESS = 0x5ed6A38c6bEcEd15b0AB58566b6fD7A00463d2F7;

    // solhint-disable no-empty-blocks
    constructor(address _stakingContract)
        public
        StakingProxy( _stakingContract)
    {}

    function assertValidStorageParams()
        public
        view
    {
        require(
            stakingContract != SHOULD_REVERT_STAKING_ADDRESS,
            "FORCED_STORAGE_PARAMS_REVERT"
        );
    }
}
