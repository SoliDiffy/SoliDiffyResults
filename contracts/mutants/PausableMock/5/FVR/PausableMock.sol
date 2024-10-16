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

    function pause() public {
        _pause();
    }

    function unpause() public {
        _unpause();
    }
}
