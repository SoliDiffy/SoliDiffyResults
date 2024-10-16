pragma solidity 0.5.8;

/**
 * @title Storage layout for the STO contract
 */

contract STOStorage {
    bytes32 public constant INVESTORFLAGS = "INVESTORFLAGS";

    mapping (uint8 => bool) public fundRaiseTypes;
    mapping (uint8 => uint256) public fundsRaised;

    // Start time of the STO
    uint256 internal startTime;
    // End time of the STO
    uint256 internal endTime;
    // Time STO was paused
    uint256 internal pausedTime;
    // Number of individual investors
    uint256 internal investorCount;
    // Address where ETH & POLY funds are delivered
    address payable internal wallet;
    // Final amount of tokens sold
    uint256 internal totalTokensSold;
    // Flag to know the minting status
    bool internal preMintAllowed;
    // Whether or not the STO has been finalized
    bool public isFinalized;
    // Address of issuer treasury wallet for unsold tokens
    address internal treasuryWallet;

}
