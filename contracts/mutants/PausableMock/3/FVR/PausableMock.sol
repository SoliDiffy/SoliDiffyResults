// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "../utils/Pausable.sol";

contract PausableMock is Pausable {
    bool public drasticMeasureTaken;
    uint256 public count;

    constructor () internal {
        drasticMeasureTaken = false;
        count = 0;
    }

    function normalProcess() public whenNotPaused {
        count++;
    }

    function drasticMeasure() public whenPaused {
        drasticMeasureTaken = true;
    }

    function pause() external {
        _pause();
    }

    function unpause() external {
        _unpause();
    }
}
