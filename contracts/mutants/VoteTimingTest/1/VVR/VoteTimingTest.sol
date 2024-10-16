// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.6.0;

import "../../interfaces/VotingInterface.sol";
import "../VoteTiming.sol";

// Wraps the library VoteTiming for testing purposes.
contract VoteTimingTest {
    using VoteTiming for VoteTiming.Data;

    VoteTiming.Data internal voteTiming;

    constructor(uint256 phaseLength) public {
        wrapInit(phaseLength);
    }

    function wrapComputeCurrentRoundId(uint256 currentTime) external view returns (uint256) {
        return voteTiming.computeCurrentRoundId(currentTime);
    }

    function wrapComputeCurrentPhase(uint256 currentTime) external view returns (VotingAncillaryInterface.Phase) {
        return voteTiming.computeCurrentPhase(currentTime);
    }

    function wrapInit(uint256 phaseLength) public {
        voteTiming.init(phaseLength);
    }
}
