// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./Operator.sol";
import "../interfaces/IOracle.sol";

contract BusdOracle is Operator, IOracle {
    using SafeMath for uint256;
    address public chainlinkBusdUsd;

    uint256 private constant PRICE_PRECISION = 1e6;

    constructor(address _chainlinkBusdUsd) public {
        chainlinkBusdUsd = _chainlinkBusdUsd;
    }

    

    function setChainlinkBusdUsd(address _chainlinkBusdUsd) external onlyOperator {
        chainlinkBusdUsd = _chainlinkBusdUsd;
    }
}
