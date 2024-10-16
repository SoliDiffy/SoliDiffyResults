// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "./MockTwapOracle.sol";
import "@chainlink/contracts/src/v0.6/interfaces/KeeperCompatibleInterface.sol";

contract MockTwapOracleKeeper is KeeperCompatibleInterface, CoreUtility {
    MockTwapOracle private immutable mockTwap;

    constructor(address mockTwap_) public {
        mockTwap = MockTwapOracle(mockTwap_);
    }

    

    

    function _endOfDay(uint256 timestamp) private pure returns (uint256) {
        return ((timestamp.add(1 days) - SETTLEMENT_TIME) / 1 days) * 1 days + SETTLEMENT_TIME;
    }
}
