/**
 * SPDX-License-Identifier: UNLICENSED
 */
pragma solidity 0.6.10;

/**
 * @notice Chainlink oracle mock
 */
contract MockChainlinkAggregator {
    /// @dev mock for round timestmap
    mapping(uint256 => uint256) internal roundTimestamp;
    /// @dev mock for round price
    mapping(uint256 => int256) internal roundAnswer;

    int256 internal lastAnswer;

    function getAnswer(uint256 _roundId) public view returns (int256) {
        return roundAnswer[_roundId];
    }

    function getTimestamp(uint256 _roundId) public view returns (uint256) {
        return roundTimestamp[_roundId];
    }

    function latestAnswer() public view returns (int256) {
        return lastAnswer;
    }

    /// @dev function to mock setting round timestamp
    function setRoundTimestamp(uint256 _roundId, uint256 _timestamp) public {
        roundTimestamp[_roundId] = _timestamp;
    }

    /// @dev function to mock setting round timestamp
    function setRoundAnswer(uint256 _roundId, int256 _answer) public {
        roundAnswer[_roundId] = _answer;
    }

    function setLatestAnswer(int256 _answer) public {
        lastAnswer = _answer;
    }
}
